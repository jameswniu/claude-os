---
name: Compass Architecture Code Mapping
description: Layer-by-layer mapping of Kyle's Compass architecture diagrams to actual CMM code. What exists, what's aspirational, what uses different tech.
type: project
---

## Source

Kyle shared two WIP Compass architecture diagrams (2026-03-11):
1. Compass Architecture Layers
2. High Level Registry Architecture

## Scorecard

- **EXISTS (8)**: UI, Basis, Auth0, DSP, Walled Gardens, Analytics, Financial Layer, MCP endpoint
- **SEED/PARTIAL (4)**: Compass (MCP controller only), Strategic Planning, GWI (research client), BDM (billing context only)
- **DOES NOT EXIST (14)**: Memory, Stream (Redis Streams), Tool Registry, Tool Store, Agent Store, all 6 named Agents, A2A, 3rd Party Agent, Web Search, Cortex, Vector, DSP Wrapper, Agent Registry

## Key Code Locations

- MCP controller: `app/controllers/external/api/mcp_controller.rb` (stateless passthrough, 12 hardcoded tools)
- MCP tools: `app/tools/mcp/` (12 files: brands, clients, campaigns, media plans, line items)
- MCP auth: `app/services/mcp/tool_authenticator.rb` (Bearer token via Auth0)
- MCP gem: `mcp` 0.6.0, protocol version 2025-03-26
- Compass Admin: `app/controllers/internal/compass_admin_controller.rb` (iframe shell for MSG)
- Auth0: `app/models/auth/auth0_token.rb` (JWT RS256), `app/services/auth/basic_login_service.rb`
- Only .well-known route: `/.well-known/jwks` (Auth0 JWKS)
- DSP: `lib/centro_dsp/client.rb` + 80+ files in `app/services/dsp/`
- Pacing services (not agents): `app/services/dsp/pacing_service.rb`, `campaign_pacing_service.rb`
- Event streaming: RabbitMQ (Bunny) + Kafka, 37 consumers in `app/consumers/` across 7 domains. NOT Redis Streams.
- Research/GWI seed: `app/services/research/market_trends_client.rb` (generic research API)
- Comscore (different context): `app/services/dsp/comscore_report.rb` (DSP reach measurement, not agent integration)
- No cortex, vector, pgvector, or agent registry anywhere in codebase
