# Create a design document

Write a design document for the system or idea described in the notes, using the C4 model for the architecture sections.

## Context

Companies differ in risk appetite: a startup tolerates more risk than a regulated enterprise. State the risk posture you assume and why.

## Steps

1. If the notes refer to an existing codebase, read the relevant code, configs, infrastructure definitions and existing docs (`README`, `docs/`, ADRs) and ground the document in them. Cite `path:line` for facts taken from code. Otherwise work from the described idea.
2. Separate what is known (from the notes or code) from what you assume. Do not invent technologies, vendors or numbers; list gaps under Questions and Assumptions.
3. Write the sections below. Use Mermaid for the C4 diagrams (see `create_mermaid_visualization_for_github` conventions: quote labels with special characters).

## Output

1. Business posture: priorities and goals the system serves, goals and non-goals, and the most important business risks.
2. Security posture: existing security controls and accepted risks (label each "security control" or "accepted risk"), secure development lifecycle and deployment model, recommended high-priority controls missing from the notes, and the security requirements that matter for this system.
3. Design:
   - C4 context: Mermaid diagram with the system in the centre, surrounded by users and external systems.
   - C4 container: Mermaid diagram of the major containers, technology choices and how they communicate.
   - C4 deployment: Mermaid diagram of how containers are deployed onto infrastructure per environment.
   - After each diagram, a table with columns Name, Type, Description, Responsibilities, Security controls.
   - Data: main entities, stores, sensitivity and retention.
4. Risk assessment: the critical business processes to protect, and the data to protect with its sensitivity.
5. Questions and assumptions: open questions, and the default assumptions made for business posture, security posture and design.

Write plain markdown without bold or italics.

## Input

{{_cursor_}}
