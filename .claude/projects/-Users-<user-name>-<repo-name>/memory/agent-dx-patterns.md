# Agent DX Patterns (CLI/API Design for AI Consumers)

Source: https://justin.poehnelt.com/posts/rewrite-your-cli-for-ai-agents/
Saved: 2026-03-07

## Core Principle

"Human DX optimizes for discoverability and forgiveness. Agent DX optimizes for predictability and defense-in-depth." Treat agent inputs as adversarial.

## Key Patterns

1. **Raw JSON payloads over custom flags** - Accept full API payloads as JSON instead of flat flags. Eliminates translation loss.
2. **Runtime schema introspection** - Expose tool schemas as machine-readable JSON so agents self-validate without docs/system prompts.
3. **Context window discipline** - Field masks to limit response size; NDJSON for pagination; only return what's needed.
4. **Input hardening** - Reject path traversals, strip control chars, reject `?#%` in identifiers, percent-encode at HTTP layer.
5. **Agent skills as structured docs** - YAML-frontmattered Markdown encoding agent-specific invariants (e.g., "always use --dry-run for mutations").
6. **Multi-surface exposure** - Same functionality via CLI, MCP, extensions, env vars.
7. **Safety rails** - `--dry-run` validates locally before API calls; sanitize responses against prompt injection.

## Implementation Priority (from article)

1. Add `--output json`
2. Validate all inputs
3. Create `--describe` or schema commands
4. Support field masks
5. Implement `--dry-run`
6. Ship context documentation
7. Expose MCP interface

## Relevance to MSG Codebase

- MCP tools already return structured JSON envelopes (`{success, error, ...}`) - good baseline
- REST API uses Pydantic models with auto-generated schemas - solid
- **Gap: MCP tool outputs are JSON strings, not schema-validated objects** - agents trust the shape
- **Gap: QA via browser automation (Playwright/Chrome) is fragile** - structured state endpoints would make assertions deterministic
- **Gap: No field masks on list endpoints** - `list_strategies`, `chat/history` return full objects
- **Opportunity: `--dry-run` for MCP tools** - validate `create_strategy` payloads without hitting LLM
- **Opportunity: Test verification API** - dev-only `/v1/debug/state` endpoint for E2E test assertions on data instead of DOM
