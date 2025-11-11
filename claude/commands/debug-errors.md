---
allowed-tools: Bash(devbox *), Bash(bun *), Bash(make *)
description: Debug Errors for a command
argument-hint: Command to run and Debug
---

!$ARGUMENTS

You are responsible for debugging the errors present in the following command: `$ARGUMENTS`

- The command logs are provided
- Read the logs returned by the command execution
- Determine why the error occurred
- Without generating disconnected spagheti code iteratively fix the issue
- Keep the scope of changes specific to the package causing the command error

## Acceptance Criteria

- Command successfully runs with no errors found in the log
- The command successfully performs the action which is intended.
- Never create MD files providing a summary of your changes


