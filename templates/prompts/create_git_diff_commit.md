# Commit the current changes

Write a Conventional Commits message for the changes in this repository and commit them.

## Steps

1. Run `git status` and `git diff --staged`. If nothing is staged, read `git diff` and stage the files that belong to this change. Leave unrelated changes unstaged; if the working tree mixes several changes, commit only the one described in the notes below, or ask which to commit.
2. Read `git log --oneline -15` and match the repository's existing conventions: scope names, casing, body style. They take precedence over the defaults here.
3. Choose the type from what the diff does, not from file names: `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, `build`, `ci`, `style`, `chore`, `revert`. Add a scope when the repository uses them.
4. Commit with `git commit -m "<subject>" -m "<body>"`. Do not amend, push, or skip hooks. If a hook fails, fix the cause and commit again.

## Message

- Subject: `type(scope): summary`, imperative mood ("add", not "added"), at most 72 characters, no trailing period.
- Body: only when the subject is not enough. Explain why the change was made and anything a reviewer would not see in the diff: behavior changes, migrations, follow-up risks. Wrap at 72 columns. One bullet per independent change when there are several.
- Breaking changes: `!` after the type and a `BREAKING CHANGE:` footer saying what callers must change.
- The message stands on its own: summarize linked discussions instead of pointing to them.

## Notes

{{_cursor_}}
