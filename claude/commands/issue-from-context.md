# Create GitHub Issue from Code Context

Analyzes code context and creates a GitHub issue using Claude with MCP.

Usage: `/issue-from-context <description>`

Example: `/issue-from-context Fix authentication bug in login flow`

---

Description: {{ARGS}}

Instructions:
1. Use mcp::github::search_issues to find related issues
2. Use mcp::exa::get_code_context_exa to find relevant code patterns
3. Use mcp::github::create_issue to create a new issue with:
   - Title based on the description
   - Body with Summary, Requirements, and Acceptance Criteria
   - Relevant labels and assignees
4. Return the created issue number in format: #123
