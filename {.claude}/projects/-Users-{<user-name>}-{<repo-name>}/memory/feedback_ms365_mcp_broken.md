---
name: MS-365 MCP login broken
description: MS-365 MCP device code login flow does not work for this user - never attempt it
type: feedback
---

Do not attempt `mcp__ms-365__login` or any MS-365 MCP tools that require auth. The device code flow consistently fails.

**Why:** User has tried multiple times and it never works. Repeatedly showing the device code URL frustrates them.

**How to apply:** When the user needs to interact with Teams/Outlook/Calendar, use alternatives:
- Slack MCP for messaging
- Graph API directly via `~/.graph-token` and `curl`/WebFetch for Graph operations
- Browser automation as a last resort
