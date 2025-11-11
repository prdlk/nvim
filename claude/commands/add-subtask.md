---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(gh issue:*)
description: Add a Subtask to the Current Issue or Another Issue
---

Create a new sub-issue with the provided parent issue with an appropriate title, relevant file paths, and links to documentation if applicable using the following context: #$ARGUMENTS

## Warnings

- **If no Issue Number is provided use `gh issue list` and provide the number and titles for open issues. Only after a number is provided do you create a subtask for the parent task**
- Use the provided context in order to generate the new sub-issue and require it to be linked to the parent issue.

## Requirements:

- Always keep the title short and descriptive so that it can be recorded as a single line in a changelog entry
- Always include any expected data types as code formatted examples if necessary
- Always include the relevant file paths of expected files to be changed
- Always keep the issue body as succinct as possible with only essential context
- Always use mcp\_\_exa_search to find associated documentation for the tasks
- If protobuf or sql files will be changed with this issue add the 'breaking' label to the issue
- Always assign the issue to myself
