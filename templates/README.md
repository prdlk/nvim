# Code Templates

Essential templates for modern development with Cosmos SDK, Protobuf, and Vite+Cloudflare.

## 🚀 Usage

### Quick Access
- **`<C-a><C-t>`** - Open Snacks template picker (primary)
- **`<C-a>t`** - Create a new template file
- **`<C-a>T`** - Open Telescope template picker (alternative)
- `:TemplateSnacks` - Command for Snacks picker
- `:TemplateCreate <category/filename> [filetype]` - Create new template
- `:TemplateTelescope` - Command for Telescope picker

### Template Variables

Templates support the following placeholders:

#### Built-in Variables
- `{{_date_}}` - Current date and time
- `{{_cursor_}}` - Cursor position after insertion
- `{{_file_name_}}` - Current file name (without extension)
- `{{_camel_case_file_}}` - File name converted to CamelCase
- `{{_upper_file_}}` - File name in UPPERCASE
- `{{_author_}}` - Author name (configured in plugin)
- `{{_email_}}` - Email address (configured in plugin)
- `{{_variable_}}` - Prompts for custom variable name
- `{{_lua:<expr>_}}` - Execute Lua expression

#### Custom Registered Variables
- `{{_path_}}` - Full path to current file
- `{{_relative_path_}}` - Relative path to current file
- `{{_dir_}}` - Directory of current file
- `{{_project_}}` - Current project/directory name

## 📁 Available Templates

### Cosmos SDK (Go) - `/cosmos`

#### `keeper.go.tpl`
Creates a Cosmos SDK keeper with store management and parameter store.

**Use for:** Module keeper implementation
**Variables:** Uses `{{_file_name_}}` for module name

#### `msg_server.go.tpl`
Creates a message server implementation for handling transactions.

**Use for:** Transaction message handlers
**Variables:** `{{_variable_}}` for the message type name

#### `query_server.go.tpl`
Creates a query server implementation for handling read queries.

**Use for:** Query handlers for module state
**Variables:** `{{_variable_}}` for the query method name

#### `handler.go.tpl`
Creates a message handler router for the module.

**Use for:** Main message routing logic

### Protobuf - `/proto`

#### `message.proto.tpl`
Creates a basic protobuf message definition.

**Use for:** Data structures and types
**Variables:** `{{_variable_}}` for the message name

#### `tx.proto.tpl`
Creates a transaction message service with RPC definitions.

**Use for:** Transaction (Msg) service definitions
**Variables:** `{{_variable_}}` for the transaction method name

#### `query.proto.tpl`
Creates a query service with gRPC and HTTP annotations.

**Use for:** Query service definitions with REST endpoints
**Variables:** `{{_variable_}}` for the query method name

### Vite + Cloudflare + TanStack - `/vite`

#### `worker.ts.tpl`
Creates a Cloudflare Worker with proper TypeScript types.

**Use for:** Cloudflare Worker scripts
**File type:** TypeScript

#### `pages-function.ts.tpl`
Creates a Cloudflare Pages Function.

**Use for:** Cloudflare Pages API routes
**File type:** TypeScript

#### `page.tsx.tpl`
Creates a TanStack Router page component.

**Use for:** Full page routes with TanStack Router
**File type:** TypeScript React

#### `component.tsx.tpl`
Creates a memoized React component with TypeScript.

**Use for:** Reusable React components
**File type:** TypeScript React

#### `hook.ts.tpl`
Creates a custom React hook with TypeScript.

**Use for:** Reusable React hooks
**File type:** TypeScript

#### `api.ts.tpl`
Creates a TanStack Query API client with CRUD operations.

**Use for:** API integration with TanStack Query
**File type:** TypeScript
**Includes:** Query keys, fetch functions, and hooks

## 💡 Examples

### Creating a Cosmos SDK Message Server

1. Create/open a file: `msg_server_create_post.go`
2. Press `<C-a><C-t>`
3. Select `msg_server.go.tpl`
4. Enter variable name when prompted: `CreatePost`
5. Template is inserted with all placeholders filled

### Creating a TanStack Query API

1. Create/open a file: `posts.ts`
2. Press `<C-a><C-t>`
3. Select `api.ts.tpl`
4. Template creates full API client with:
   - Query keys
   - Fetch functions
   - React hooks for queries and mutations

### Creating a React Component

1. Create/open a file: `user_card.tsx`
2. Press `<C-a><C-t>`
3. Select `component.tsx.tpl`
4. Component created with name `UserCard` (auto-converted to CamelCase)

## 🎨 Customization

### Adding Your Own Templates

#### Quick Method (Recommended)
1. Press `<C-a>t` to start the TemplateCreate command
2. Type category and filename (e.g., `vite/form.tsx`)
3. Optional: specify filetype (defaults to current buffer's filetype)
4. Template file is created automatically and opens for editing

Example command:
```vim
:TemplateCreate vite/form.tsx typescriptreact
```

#### Manual Method
1. Create a new `.tpl` file in the templates directory
2. Add filetype marker as first line: `;; <filetype>`
3. Use template variables as needed
4. Save and use with `<C-a><C-t>`

Example:
```typescript
;; typescript
/**
 * {{_file_name_}}
 * @author {{_author_}}
 * @project {{_project_}}
 * @path {{_relative_path_}}
 */

export const {{_camel_case_file_}} = {{_cursor_}}
```

### Template Organization

- Use subdirectories to organize templates by category
- Template picker shows category in selection: `[category] filename`
- Templates are filtered by current file type automatically

## 🔧 Configuration

Edit template configuration in `lua/plugins/template.lua`:

```lua
template.setup {
  temp_dir = vim.fn.stdpath "config" .. "/templates",
  author = "Your Name",
  email = "your.email@example.com",
}
```

## 📚 Resources

- [template.nvim GitHub](https://github.com/glepnir/template.nvim)
- [Cosmos SDK Docs](https://docs.cosmos.network/)
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [TanStack Router](https://tanstack.com/router)
- [TanStack Query](https://tanstack.com/query)
