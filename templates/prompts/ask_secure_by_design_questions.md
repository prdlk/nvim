# Ask secure-by-design questions

Produce the questions a builder should answer to make sure the system described below is secure by design.

## Steps

1. If the notes point at an existing codebase or design, read it first and skip questions it already answers; cite what you found. Otherwise work from the described idea.
2. Identify the components, data, users and trust boundaries, and how the system will realistically be used and attacked.
3. Write questions specific to this system, not generic checklist items. Cover the areas that apply: architecture and trust boundaries, authentication, authorization, data protection (at rest, in transit, retention), input handling, secrets and keys, dependencies and supply chain, logging and detection, availability and abuse, deployment and infrastructure, privacy and compliance, failure and recovery.

## Output

- Overview: two sentences on what is being built and why securing it matters.
- Questions grouped by area under headings. Within each area, order by priority (high, medium, low). Each question is followed by one line on why it matters (the risk it addresses).
- Optionally, a short list of the five questions to answer first.

## Input

{{_cursor_}}
