# Suggest a Gas Town command

Find the exact `gt` command (or short sequence) that accomplishes the goal described below.

## Context

Gas Town (`gt`) is a multi-agent workspace manager built on Beads (`bd`). A town holds rigs (project repos), each with agents such as polecats (ephemeral workers), a witness, and a refinery (merge queue); the mayor coordinates across rigs. Work items are beads, dispatched with `gt sling` and batched in convoys. Commands change between versions, so do not rely on memory.

## Steps

1. Run `gt --help` to list commands, then `gt <command> --help` for the likely candidates and their subcommands. Run `gt status` if current state matters.
2. Pick the most direct command for the goal. Use only commands and flags you saw in the help output.
3. If the command needs IDs or names (bead, rig, polecat), look them up with the read-only listing commands first, or mark them as placeholders.
4. If several approaches exist (for example a synchronous `gt nudge` versus an asynchronous `gt mail send`), mention the alternative and when to prefer it.
5. If the goal is ambiguous or the command is not available in this install, say so and ask or suggest the nearest option.

## Output

- The command in a `bash` block.
- One line explaining what it does.
- A warning if it has side effects: stops or kills sessions, releases or unslings work, closes beads, spawns workers, or touches other rigs. Name any prerequisite, such as a running mayor.
- Do not run commands that change state; read-only commands are fine.

## Goal

{{_cursor_}}
