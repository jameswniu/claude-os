---
name: Compass Roadmap Context
description: Context from Kyle's architecture diagrams and team discussions about Compass AI roadmap, priorities, and ownership.
type: project
---

## Timeline

- 2026-03-11: Kyle shared two WIP Compass architecture diagrams (Architecture Layers + High Level Registry Architecture)
- 2026-03-12: James created v3 architecture diagrams via Lucidchart MCP, shared with Kyle for feedback
- Diagrams are aspirational; most components don't exist yet (14 of 26 components missing)
- Expect heavy iteration after Kyle/team review

## v3 Diagrams (will change)

- L0 Business Capabilities: https://lucid.app/lucidchart/e059feb2-28c1-4667-b764-d6923fb74e57/edit
- L1 Logical Architecture: https://lucid.app/lucidchart/c985c465-e2eb-426f-a30d-2954122771c8/edit
- L2 Physical Architecture: https://lucid.app/lucidchart/23723980-5d3b-49d5-9adc-0cb5b4b10489/edit

Stakeholders: L0 = Product/Leadership, L1 = Engineering Leads, L2 = Dev Teams

## Pipeline Vision

Aligned diagrams → Claude generates Jira tickets + code + reviews → accelerated execution

## Current State (as of 2026-03-11)

- MCP endpoint live with 12 tools (brands, clients, campaigns, media plans, line items)
- MSG ((project-name)) proxied through CMM with SSE
- Compass Admin is an iframe shell loading MSG
- No orchestration, no agents, no registry, no memory/vector/cortex

## Ownership Context

- Dalyn owns the Aha roadmap for Compass features
- STT/voice was flagged as a prioritization consideration

## Open Questions for Kyle (sent 2026-03-11)

1. MVP next step: more tools, first agent, or registry layer?
2. A2A timeline and first consumers
3. Tool Registry: self-registering vs. curated catalog
4. Memory + Vector + Cortex: what backs each, new service vs. external product
