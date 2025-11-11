---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(gh issue:*), Bash(git worktree:*)
description: Plan how to complete the Github Issue
argument_hint: Issue Number to Plan
---

## Context

- View the issue body: `!gh issue view $ARGUMENTS`
- Always use the `mcp__ref_search_documentation` tool to find relevant library documentation for the Issue
- Always use the `mcp__web_search_exa` tool to find any missing information needed to plan the Issue implementation strategy

## Instructions

0. Gather the Issue context
1. Create a markdown file as PLAN.md
2. Make the H1 tag a markdown link to the issue with the title as text
3. Create 4 H2 Sections named: Summary, Action Items, Documentation, and Changes
4. Populate the Summary section with a concise summary of the github issue for a LLM code agent based on efficient smart requirements
5. Populate the Action Items section with the list of tasks from the Github Issue matched with the associated affected files
6. Use the @agent-organizer-agent to assign each of the action items to the correct agent. - Example: "> Use @agent-golang-pro"
7. Populate the Documentation section with all the relevant context we gathered and any relevant links
