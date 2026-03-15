---
name: Advice patterns
description: Reusable patterns extracted from teammate advice, distilled for long-term retention
type: reference
---

# Advice Patterns

Distilled from individual `advice_*.md` files before archival. Patterns recurring 3+ times get promoted to MEMORY.md or CLAUDE.local.md.

## MCP Server Reconnection
**Pattern:** OAuth tokens expire; remove and re-add the MCP server to trigger a fresh OAuth flow.
**Applies to:** Lucid, Atlassian, any OAuth-based MCP server.
**Source:** advice_lucid-mcp-setup.md (2026-03-13)
**Occurrences:** 1
