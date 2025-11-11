---
allowed-tools: Bash(gh issue:*), Bash(gh api:*), Bash(gh milestone:*), Bash(bun run:*), Bash(echo *)
description: Write Go Specific Documentation
---

Write and update Go documentation comments for all Go source files in the directory path specified by $ARGUMENTS, following the latest Go documentation standards and our project conventions.

## Steps

1. **Scan the directory at path `$ARGUMENTS` for all `.go` source files.**
2. **For each Go file found:**
   - Add or improve package-level doc comments.
     - Place the main package comment directly above the `package` declaration, or in a dedicated `doc.go` file for large overviews.
     - The first sentence should summarize the package and will be used as its synopsis.
   - For each exported function, method, type, variable, and constant:
     - Write a doc comment immediately preceding its declaration, with no intervening blank line.
     - Start the comment with the name of the item being documented.
     - Use clear, complete sentences that explain what the item does, its purpose, and any important details.
     - For deprecated items, add a paragraph starting with `Deprecated:` and explain the deprecation.
     - For known issues, add a comment starting with `BUG(username):` to be included in the “Bugs” section.
   - For struct fields, add comments if they are exported and not self-explanatory.
   - For HTTP handlers using swaggo/swag, format docstrings according to swaggo’s OpenAPI requirements.
3. **Formatting and Style:**
   - Write comments as you would want to read them, even if godoc didn’t exist.
   - Use proper Go doc formatting:
     - Separate paragraphs with a blank line.
     - Indent pre-formatted text.
     - URLs will be auto-linked; no special markup needed.
   - Avoid documenting unexported (private) identifiers unless necessary for maintainers.
   - Do not modify code logic or formatting—only add or update doc comments.
4. **Save changes directly to the source files.**
5. **Confirm completion with a message.**

## Requirements

- Prioritize clear, concise, and idiomatic Go documentation.
- Use `mcp__godoc_search` to find relevant Go code examples or documentation patterns.
- If unfamiliar with a package or function, prompt for additional context before proceeding.
- Do not document non-Go files or unrelated assets.
- Follow existing project documentation and coding standards.

## When Writing API Handlers

- Use swaggo/swag comment structure for all echo HTTP Handlers to generate OpenAPI-compatible documentation.
- Include parameter, response, and summary annotations as required by swaggo.

### Example Swaggo Docs

```go
// ShowAccount godoc
// @Summary Show an account
// @Description get string by ID
// @Tags accounts
// @Accept json
// @Produce json
// @Param id path int true "Account ID"
// @Success 200 {object} model.Account
// @Failure 400 {object} httputil.HTTPError
// @Failure 404 {object} httputil.HTTPError
// @Failure 500 {object} httputil.HTTPError
// @Router /accounts/{id} [get]
func (c *Controller) ListAccounts(ctx echo.Context) {
q := ctx.Request.URL.Query().Get("q")
accounts, err := model.AccountsAll(q)
if err != nil {
httputil.NewError(ctx, http.StatusNotFound, err)
return
}
ctx.JSON(http.StatusOK, accounts)
}
//...
```

## Best Practices (from official Go guidelines)

- Comments for exported identifiers should begin with the name of the identifier.
- The first sentence should be a concise summary, suitable for display in package listings.
- Use full sentences and proper punctuation.
- For large package overviews, use a dedicated `doc.go` file.
- Mark deprecated items with `Deprecated:` and known bugs with `BUG(username):`.
- Keep comments up to date as code evolves.

## References

- [Go Doc Comments (Official Guide)](https://go.dev/doc/comment)
- [Godoc: documenting Go code (Go Blog)](https://go.dev/blog/godoc)
- [swaggo/swag Documentation](https://github.com/swaggo/swag)
