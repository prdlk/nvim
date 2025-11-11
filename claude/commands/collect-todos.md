Collect all TODO comments found recursively in the repository and create grouped issues for them.

## Steps

1. Recursively scan all source code files in the repository for TODO comments.
2. Group TODOs by related feature, module, or context if possible.
3. For each group of TODOs:
   - Create a new issue summarizing the group of TODOs using `mcp**github**create_issue`.
   - Include the relevant file paths and line numbers where TODOs were found.
   - Provide clear, concise descriptions of the tasks needed to resolve the TODOs.
4. Avoid creating duplicate issues for the same TODOs.
5. Confirm completion with a summary message listing all created issues.

## Requirements

- Always keep issue titles short and descriptive.
- Include expected data types or code examples if applicable.
- Keep issue bodies succinct with only essential context.
- Use `mcp__exa_search` to find associated documentation for TODO tasks.
- Label issues appropriately (e.g., `enhance`, `bug`, `feature`, `docs`).
- Prompt for additional context if TODO comments are unclear.
