---
name: Lucid MCP setup
description: How to add/reconnect Lucid MCP in Claude Code
type: advice
date: 2026-03-13
tags: [mcp, lucid, setup]
---

## Problem
Teammate couldn't connect Lucid MCP server. OAuth token had expired.

## Fix
```
claude mcp add lucid --transport http https://mcp.lucid.app/mcp -s user
```

The `-s user` flag is critical. Without it the server gets added at the wrong scope.

## Reusable Pattern
OAuth tokens expire; remove and re-add the MCP server to trigger a fresh OAuth flow. Always use `-s user` for user-scoped MCP servers.
