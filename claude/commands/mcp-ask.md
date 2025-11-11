# Ask Claude with MCP Context

Call Claude Code with MCP server context (github, exa, context7).

Usage: `/mcp-ask <query>`

Example: `/mcp-ask How do I implement OAuth2 in React?`

---

This command uses the context7, exa, and github MCP servers to gather relevant context, then provides a comprehensive answer.

Query: {{ARGS}}

Instructions:
1. Use mcp::context7 tools to search for relevant code context
2. Use mcp::exa::get_code_context_exa to find documentation
3. Use mcp::github tools if repository-related
4. Provide a detailed answer with code examples
