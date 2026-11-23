# Create a Beads issue

Turn the issue described below into a single `bd create` command.

## Steps

1. Run `bd create --help` (and `bd --help` if needed) to see the flags this version supports. Use only flags that appear there, since they change between releases.
2. Run `bd list` or `bd search "<keywords>"` to check that the issue does not already exist. If it does, report the existing ID instead of creating a duplicate.
3. Decide the core fields from the description:
   - Title: short, imperative ("Fix broken login on production").
   - Type: `bug`, `feature`, `task`, `epic`, or `chore`; confirm against the help output.
   - Priority: P0 critical (outage, data loss, security), P1 high, P2 normal (default), P3 low, P4 someday. Include it only when it is not the default.
   - Description: context, expected behavior, acceptance criteria. Add facts from the notes only; do not invent details.
   - Labels: one to four, preferring labels already in use (`bd list` shows them).
   - Dependencies or parent: only when the notes name related issues, using IDs you have verified exist.
4. Quote strings and escape inner quotes. For long descriptions, use whatever file or stdin option the help output offers.

## Output

- Print the command in a `bash` block with a one-line rationale for type and priority.
- Run it only if the notes say to, then show the created ID.

## Issue

{{_cursor_}}
