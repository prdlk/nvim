# Create a STRIDE threat model

Produce a STRIDE-per-element threat model for the system described below.

## Steps

1. Gather the design: read the design documents, architecture diagrams, infrastructure definitions and code named in the notes, or discover them (`README`, `docs/`, IaC, route and handler definitions). Cite `path:line` or document sections as evidence.
2. Identify the elements: external entities, processes, data stores and data flows.
3. List assets, trust boundaries, and data flows, marking the flows that cross a boundary.
4. For each element, apply the STRIDE categories that apply to its type (Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege), keeping only threats that are realistic for this system.
5. Rate likelihood and impact from the design and real-world exploitability, then derive severity (low, medium, high, critical). Say how hard each defence is.
6. Say which threats are already mitigated and where. For threats you leave without a control because they are unlikely or too costly to defend, state that and why.

## Output

1. Assets: data and resources that need protection.
2. Trust boundaries.
3. Data flows, with boundary crossings marked.
4. Threat table with columns: ID, Element, Threat category, Threat (specific, e.g. "credentials exposed in environment variables and command-line arguments"), Impact, Likelihood, Mitigation (existing, with reference, and recommended), Status (mitigated, partial, open, accepted). Order by severity.
5. Questions and assumptions.

Write plain markdown without bold or italics.

## Input

{{_cursor_}}
