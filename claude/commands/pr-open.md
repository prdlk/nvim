---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(gh pr:*)
description: Mark Issue as Complete and Stage a PR
---

- Create a Pull Request for the changes made in this branch using the gh cli.
- Read the PLAN.md file and distill all information into a concise PR Body.
- Add all the entities and relations based off the insights found in @PLAN.md
- DO NOT continue if a PLAN.md file does not exist.

## Requirements

- Do not create a PR if you are on the default branch
- Ensure all issues that were fixed in this branch are listed in the PR body grouped by type
- Make sure the body of the PR contains the proper context of the issue along with the final implementation changes made
- Add the 'breaking' label to the PR for any changes made to sql or protobuf
- Add the 'enhance' label to the PR for any changes made to optimize the system architecture
- Add the 'feature' label to the PR for any new features added to the codebase
- Always assign the PR to @prnk28
- Every PR must include either a 'breaking', 'enhance', 'feature', 'docs', or 'tests' label
- Delete the PLAN.md file after the PR has been made.
- Open the PR on the Web after it has been made.
