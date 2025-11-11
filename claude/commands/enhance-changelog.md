---
description: Copy CHANGELOG.md into mdx docs
---

- Read the contents of @docs/reference/changelog.mdx and find all referenced closed PRs.
- Use `!gh pr view <ISSUE_NUMBER>` to view the pull request body for context on the version update.

## Requirements

- Use the context found by viewing the PR to enhance the version update with helpful context on the release.
- Keep the update short and only provide a concise list of relevant changes.
- Always use the required Mintlify MDX format
- Skip any releases already documented inside @docs/reference/changelog.mdx
- Complete these tasks by assigning to @agent-documentation-expert

## Components Used

```mdx
<Update label="2024-10-11" description="v0.1.0" tags={["Mintlify"]}>
  This is an update with a label, description, and tag.
</Update>
```

