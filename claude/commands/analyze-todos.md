Write TODO comments for all unimplemented methods or broken functions found in the repository source code.

## Steps

1. Recursively scan all source code files in the repository.
2. Identify functions or methods that are unimplemented (e.g., empty bodies, `panic("not implemented")`, or stub implementations).
3. Identify functions or methods that are broken or error-prone based on existing error handling or comments.
4. For each such function or method:
   - Insert a clear TODO comment above the function definition indicating it requires implementation or fixing.
   - The TODO comment should describe the expected functionality or the issue to be resolved.
5. Avoid duplicating TODO comments if one already exists for the function.
6. Save the modified source files.
7. Confirm completion with a summary message.

## Requirements

- TODO comments must be concise, actionable, and follow project comment style.
- Use `mcp__exa_search` or other tools to gather context if needed.
- Do not modify implemented or working functions.
- Do not read any generated files or edit
- Prompt for additional context if unclear about function status.
