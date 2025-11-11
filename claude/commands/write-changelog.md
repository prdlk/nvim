---
description: Copy CHANGELOG.md into mdx docs
---

Update @docs/reference/changelog.mdx with all the updates found in @CHANGELOG.md using the following component:

```mdx
<Update label="2024-10-11" description="v0.1.0" tags={["Mintlify"]}>
  This is an update with a label, description, and tag.
</Update>
```

## Requirements

- Use the exact values found in @CHANGELOG.md and skip any releases without any content
- Skip any releases already documented inside @docs/reference/changelog.mdx
