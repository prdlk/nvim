---
allowed-tools: Bash(git *), Bash(cut *), Bash(sort *), Bash(uniq *)
description: Resolve Duplicate Files in Repo
---

### Discovered Duplicate Files in Git Tree


!git ls-tree -r HEAD | cut -c 13- | sort | uniq -D -w 40

## Responsibilities

- Read the path of each file which is a duplicate in the above list
- Determine the role of the file in the codebase
- Deduce which part of the repo could modularize the usage of the file.
- Migrate the file into a shared package approach and update the workspace imports
- Delete all now deprecated duplicate files

## Acceptance Criteria

- Shared library updated to reduce duplicates.
- We only have 1 file for each functionality of our codebase.
- Never create MD files providing a summary of your changes


