# Write a Semgrep rule

Write a Semgrep rule that detects a described code pattern, together with a test file that proves it works.

## Steps

1. Understand the target: the pattern to catch, the language, why it is a problem, and what correct code looks like. Search the repository for real examples with `rg` so the rule matches how the code is written. If the description is ambiguous, state your interpretation.
2. Check the tooling with `semgrep --version`. For syntax you are unsure about, consult `semgrep --help` or the docs at https://semgrep.dev/docs/writing-rules/overview rather than guessing.
3. Write `rule.yaml` with a lowercase-hyphenated `id`, a `message` that says what is wrong and how to fix it, `severity` (`INFO`, `WARNING`, `ERROR`), `languages`, and the pattern. Start with the simplest pattern that matches, then narrow it.
4. Write a test file next to it (same base name, language extension). Put `// ruleid: <id>` (or the language's comment syntax) on the line above each case that must match and `// ok: <id>` above cases that must not. Include true positives, near misses, and variations in formatting and naming.
5. Validate and test: `semgrep --validate --config rule.yaml`, then `semgrep --test .`. Fix the rule or tests and rerun until both pass.
6. Optionally run the rule on the repository (`semgrep --config rule.yaml .`) and check the hits for false positives.

## Rule fields and operators

- `pattern`: match code; `$X` is a metavariable, `...` matches any sequence.
- `patterns`: all listed conditions must hold (AND). `pattern-either`: any may hold (OR).
- `pattern-not`, `pattern-not-inside`: exclude matches. `pattern-inside`: require an enclosing context.
- `pattern-regex`, `metavariable-regex`, `metavariable-pattern`, `metavariable-comparison`: constrain what a metavariable or text may be.
- `fix`: autofix text that can use metavariables. `metadata`: CWE, references, confidence.
- `mode: taint` with `pattern-sources`, `pattern-sinks`, `pattern-sanitizers`: for data-flow rules.

## Output

The paths of `rule.yaml` and the test file, the final test result, and a short note on what the rule deliberately does not catch.

## Input

{{_cursor_}}
