# Review a design

Review the architecture design described below and report findings by severity with concrete recommendations.

## Steps

1. Read the design document or diagrams named in the notes in full. If it describes an existing codebase, read the relevant code to check that the design matches what is built, and cite `path:line` where it does not.
2. Assess each area: architecture and component design (responsibilities, redundancy, unnecessary complexity); external integrations; security (authentication, authorization, data protection, attack surface); scalability and performance (bottlenecks, horizontal scaling); reliability (failure modes, single points of failure, recovery); operability (deployment, monitoring, maintainability, onboarding of new clients or features); data management (storage, flows, tenant isolation); cost.
3. Cite the document section or code behind every finding. Where the document is silent, report that as a gap instead of assuming either way.
4. Note inconsistent terminology and sections that need a rewrite.

## Output

- Summary: the main strengths and the few changes that would matter most.
- Findings, grouped by severity (critical, high, medium, low). Each has: area, what is wrong or missing, evidence, impact, and a specific recommendation.
- Document quality: inconsistencies and parts to rewrite.
- Open questions for the authors.

## Input

{{_cursor_}}
