# Write a pull request description

Draft the title and description for a pull request from the changes on the current branch.

## Steps

1. Identify the base branch: the one named in the notes below, else the repository default (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`, or `git symbolic-ref refs/remotes/origin/HEAD`).
2. Read `git log <base>..HEAD` and `git diff <base>...HEAD --stat`, then the full diff. Run `git status` to note uncommitted work that the PR will not include.
3. Look for a PR template: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `docs/pull_request_template.md`, `pull_request_template.md`, or files in `.github/PULL_REQUEST_TEMPLATE/`. If one exists, fill in its sections instead of using the structure below.
4. Work out why the change exists from commit messages, linked issues, comments, and code. If the reason is not discoverable, say it is unknown rather than inventing one.
5. Check how it can be tested: existing tests the change touches, new tests added, and commands to run them. Run them if cheap, and report only results you observed.

## Output

- Title: imperative, at most 72 characters, following the repository's convention (see `git log --oneline -15`).
- Description, when no template applies:
  - `## Summary`: what changed, in a few sentences.
  - `## Why`: the problem or goal, with linked issues (`Fixes #123`).
  - `## Changes`: notable changes by area, citing files or functions. Skip mechanical details the diff shows.
  - `## How to test`: concrete commands or steps.
  - `## Risks`: behavior changes, migrations, breaking changes, performance or security impact, anything not covered by tests.
- Do not open the PR. Only if the notes ask for it, run `gh pr create --base <base> --title "<title>" --body-file <file>` after pushing is confirmed to be wanted, and print the PR URL.

## Notes

{{_cursor_}}
