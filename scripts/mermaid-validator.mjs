#!/usr/bin/env node
// Persistent mermaid syntax validator, driven by lua/config/mermaid.lua.
//
// mermaid's own parsers are the only authoritative syntax check: tree-sitter's
// mermaid grammar rejects a large amount of valid mermaid (`graph`, `style`,
// `classDef`, `click`, `box`, `create`, ... measured at 12/40 valid samples),
// so it is used for highlighting only and every diagnostic comes from here.
//
// Protocol: newline-delimited JSON, one request per line on stdin, one
// response per line on stdout, correlated by `id`.
//   -> {"id":1,"text":"flowchart TD\n  A --> B\n"}
//   <- {"id":1,"ok":true}
//   <- {"id":1,"ok":false,"line":2,"col":8,"message":"Expecting 'SQE', ..."}
// `line` is 1-based and `col` is 0-based, both relative to the request text.
//
// The process exits on stdin EOF and after `--idle-ms` without a request, so
// the ~300MB mermaid+jsdom heap is not resident for the whole nvim session.

const idleArg = process.argv.indexOf("--idle-ms");
const IDLE_MS = idleArg === -1 ? 300_000 : Number(process.argv[idleArg + 1]) || 300_000;

// mermaid reaches for DOMPurify (and therefore a DOM) while parsing several
// diagram types, so a jsdom window has to exist before it is imported.
const { JSDOM } = await import("jsdom");
const dom = new JSDOM("<!DOCTYPE html><body></body>", { pretendToBeVisual: true });
for (const key of ["window", "document", "DOMParser", "Element", "Node", "SVGElement", "HTMLElement", "navigator"]) {
  const value = key === "window" ? dom.window : dom.window[key];
  // node >= 21 exposes `navigator` as a getter-only global
  Object.defineProperty(globalThis, key, { value, configurable: true, writable: key !== "navigator" });
}

const mermaid = (await import("mermaid")).default;
mermaid.initialize({ startOnLoad: false, suppressErrorRendering: true });

/** Drop everything mermaid strips before parsing, keeping a line map.
 *
 * mermaid removes frontmatter, `%%` comments, `%%{init}%%` directives and
 * leading blank lines before a diagram parser ever sees the text, so the line
 * numbers it reports count the *stripped* text. Doing the same removals here
 * makes mermaid's own pass a no-op and `map` translates back: reduced line i
 * (0-based) came from original line `map[i]` (0-based).
 * @param {string} text
 * @returns {{text: string, map: number[]}}
 */
function preprocess(text) {
  const lines = text.split("\n");
  const kept = [];
  const map = [];
  let index = 0;

  // frontmatter: only when `---` opens the very first non-blank line
  if (/^\s*---[ \t]*$/.test(lines[index] ?? "")) {
    for (let scan = index + 1; scan < lines.length; scan++) {
      if (/^\s*---[ \t]*$/.test(lines[scan])) {
        index = scan + 1;
        break;
      }
    }
  }

  for (; index < lines.length; index++) {
    const line = lines[index];
    if (/^\s*%%(?!\{)/.test(line)) continue; // comment line
    if (/^\s*%%\{/.test(line)) {
      // directive: single line, or spanning lines until the `}%%` close
      while (!/\}%%/.test(lines[index]) && index + 1 < lines.length) index++;
      continue;
    }
    if (kept.length === 0 && /^\s*$/.test(line)) continue; // leading blank
    kept.push(line);
    map.push(index);
  }

  return { text: kept.join("\n"), map };
}

/** Position of a parse failure within the request text.
 * @param {any} error
 * @returns {{line: number, col: number}}
 */
function position(error) {
  const loc = error?.hash?.loc;
  // jison parsers: 1-based lines, 0-based columns
  if (typeof loc?.first_line === "number") {
    return { line: loc.first_line, col: typeof loc.first_column === "number" ? loc.first_column : 0 };
  }
  const message = String(error?.message ?? error);
  // langium parsers and the lexers report position in prose only
  const both = /\bline (\d+), column (\d+)/.exec(message);
  if (both) return { line: Number(both[1]), col: Math.max(0, Number(both[2]) - 1) };
  const lineOnly = /\bline (\d+)/.exec(message);
  if (lineOnly) return { line: Number(lineOnly[1]), col: 0 };
  return { line: 1, col: 0 };
}

/** Human-readable one-line reason, with position prose and echoed source removed.
 * @param {any} error
 * @returns {string}
 */
function describe(error) {
  if (error?.name === "UnknownDiagramError") return "unknown diagram type";
  const lines = String(error?.message ?? error)
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);
  // jison spells the failure out on a trailing `Expecting ...` line, after an
  // excerpt of the source and a caret line that are noise in a diagnostic
  const detail = lines.find((line) => /^(Expecting|Expected|Unrecognized|Invalid|Unknown)/.test(line));
  const text = (detail ?? lines[lines.length - 1] ?? "parse error")
    .replace(/^Parsing failed:\s*/, "")
    .replace(/^Parse error on line \d+(, column \d+)?:?\s*/, "")
    .replace(/^Lexical error on line \d+\.\s*/, "");
  return text.length > 300 ? `${text.slice(0, 297)}...` : text;
}

/** @param {string} text @returns {Promise<object>} */
async function validate(text) {
  const { text: stripped, map } = preprocess(text);
  try {
    await mermaid.parse(stripped);
    return { ok: true };
  } catch (error) {
    const { line, col } = position(error);
    // map back to the request text; an out-of-range line means mermaid pointed
    // past the stripped text, so fall back to its last line
    const mapped = map[line - 1] ?? map[map.length - 1] ?? 0;
    return { ok: false, line: mapped + 1, col, message: describe(error) };
  }
}

let idleTimer;
function resetIdleTimer() {
  clearTimeout(idleTimer);
  idleTimer = setTimeout(() => process.exit(0), IDLE_MS);
  idleTimer.unref?.();
}

const queue = [];
let draining = false;

async function drain() {
  if (draining) return;
  draining = true;
  while (queue.length) {
    const request = queue.shift();
    const result = await validate(String(request.text ?? ""));
    process.stdout.write(`${JSON.stringify({ id: request.id, ...result })}\n`);
  }
  draining = false;
}

let buffer = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  resetIdleTimer();
  buffer += chunk;
  let newline = buffer.indexOf("\n");
  while (newline !== -1) {
    const line = buffer.slice(0, newline).trim();
    buffer = buffer.slice(newline + 1);
    newline = buffer.indexOf("\n");
    if (!line) continue;
    try {
      queue.push(JSON.parse(line));
    } catch {
      // a malformed request line cannot be correlated to a response; drop it
    }
  }
  void drain();
});
process.stdin.on("end", () => process.exit(0));
process.stdout.on("error", () => process.exit(0));
resetIdleTimer();
