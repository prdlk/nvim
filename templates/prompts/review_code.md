# Review code changes

Review a set of code changes and report the problems worth fixing, most severe first.

## Steps

1. Find the change. Default to `git diff main...HEAD` (use the repository's default branch if it is not `main`), plus `git status` for uncommitted work. If the notes name files, a commit range, or a PR, use that instead (`gh pr diff <n>`).
2. Read the surrounding code, not only the diff: callers, tests, and types the change touches. A hunk often looks right until you see how it is used.
3. Run the repository's tests, linter, or type checker if they are quick and discoverable (check the README, `Makefile`, `package.json`). Use failures as evidence.
4. Check in this order: correctness and logic errors, security (injection, authn/authz, secrets, unsafe deserialization, input validation), data loss and migrations, error handling and concurrency, performance, test coverage, then maintainability. Report style only if the repository has a documented convention the change breaks.
5. Verify each finding against the code before reporting it. If you are unsure, say what you could not confirm instead of asserting it.

## Output

Start with a one-paragraph summary of what the change does and your overall verdict. Then list findings ordered by severity (blocker, major, minor, nit). For each:

- `path/to/file:line`: short title
- Problem: what is wrong, with the triggering input or scenario.
- Why it matters: the concrete consequence.
- Fix: a specific change, with a code snippet when short.

End with what is done well, if anything stands out, and any checks you ran with their results.

## Notes

{{_cursor_}}
