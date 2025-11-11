---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(gh issue:*), Bash(git worktree:*)
description: Enhance a OpenAPI Schema File
argument-hint: OpenAPI File path and Module Readme
---

- Update the contents of the following openapi file with clean documentation
- Use the provided Module Readme for context

$ARGUMENTS

- Follow the best practices for the OpenAPI V3 Spec
- Provide clean concise language for API docs
- If docs are already formatted ensure they are properly formatted
- Add x-mint metadata to the paths to assist with mintlify docs generation

## Mintlify Docs Metadata

### x-mint extension
- The x-mint extension is a custom OpenAPI extension that provides additional control over how your API documentation is generated and displayed.

**Metadata**

- Override the default metadata for generated API pages by adding x-mint: metadata to any operation. You can use any metadata field that would be valid in MDX frontmatter except for openapi:


{
  "paths": {
    "/users": {
      "get": {
        "summary": "Get users",
        "description": "Retrieve a list of users",
        "x-mint": {
          "metadata": {
            "title": "List all users",
            "description": "Fetch paginated user data with filtering options",
            "og:title": "Display a list of users"
          }
        },
        "parameters": [
          {
            // Parameter configuration
          }
        ]
      }
    }
  }
}

Add content before the auto-generated API documentation using x-mint: content:

{
  "paths": {
    "/users": {
      "post": {
        "summary": "Create user",
        "x-mint": {
          "content": "## Prerequisites\n\nThis endpoint requires admin privileges and has rate limiting.\n\n<Note>User emails must be unique across the system.</Note>"
        },
        "parameters": [
          {
            // Parameter configuration
          }
        ]
      }
    }
  }
}
The content extension supports all Mintlify MDX components and formatting.

{
  "paths": {
    "/legacy-endpoint": {
      "get": {
        "summary": "Legacy endpoint",
        "x-mint": {
          "href": "/deprecated-endpoints/legacy-endpoint"
        }
      }
    },
    "/documented-elsewhere": {
      "post": {
        "summary": "Special endpoint",
        "x-mint": {
          "href": "/guides/special-endpoint-guide"
        }
      }
    }
  }
}
When x-mint: href is present, the navigation entry will link directly to the specified URL instead of generating an API page.

