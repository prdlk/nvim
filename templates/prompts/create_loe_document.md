# Create a level of effort document

Estimate the effort, resources and risks for the task or project described below.

## Steps

1. If the work targets an existing codebase, read the relevant code, tests and build setup to size it; cite `path` for what drives the estimate (for example the number of modules touched).
2. Break the work into tasks: design, development, testing, deployment, and any security or operational work.
3. Estimate each task as a range (optimistic to pessimistic) in hours, days or sprints, with a T-shirt size. State the assumptions behind each range. Mark anything you cannot estimate as unknown and say what is needed to estimate it.
4. Add contingency based on the risks and unknowns, and show it separately from the base estimate.

## Output

Markdown with these sections:

1. Task overview: summary, objectives, expected outcomes, stakeholders.
2. Business impact: problem, expected benefits, business or regulatory risks.
3. Scope and deliverables: in scope, out of scope, milestones, acceptance criteria.
4. Resource requirements: table of roles and number of people; tooling, infrastructure, licenses.
5. Estimated effort: table with Task, Size, Low, High, Assumptions; totals for low, high and contingency.
6. Dependencies: external APIs, vendors, teams, hardware or software.
7. Risks and mitigations: technical, security, operational; note which could cause overruns.
8. Assumptions and constraints: budget, team availability, deadlines.
9. Questions and open items: what would narrow the ranges.

Write plain markdown without bold or italics.

## Input

{{_cursor_}}
