---
name: Perplexity Integration
description: Perplexity Computer as a dispatchable node in the multi-agent orchestration setup, plus API/MCP details
type: project
---

## Perplexity Computer as a Node

User wants to treat Perplexity Computer (perplexity.ai/computer/tasks) as a dispatchable node in the Claude Code multi-agent workflow. Claude Code orchestrates and sends research tasks to Perplexity Computer via chrome browser automation, reads results back, and feeds them into downstream workflows.

**Why:** User operates a multi-agent setup where Claude Code is the orchestrator dispatching work to multiple AI tools (Perplexity, Slack MCP, Atlassian MCP, Lucid, Graph API, etc.). Perplexity Computer excels at deep web research tasks that benefit from its built-in search and multi-model routing.

**How to apply:** When a task involves web research, immigration tracking, competitive analysis, or any deep search workflow, consider dispatching to Perplexity Computer via browser automation as a parallel node rather than doing all research inline.

## Integration Options

1. **Browser automation (current approach)**: Navigate to perplexity.ai/computer/tasks via chrome MCP, submit prompts, read results. No API needed, uses existing Pro subscription.
2. **Perplexity MCP server**: `claude mcp add perplexity --env PERPLEXITY_API_KEY="key" -- npx -y @perplexity-ai/mcp-server` - exposes search, chat, deep research, reasoning as tools.
3. **Sonar API**: REST at `https://api.perplexity.ai/chat/completions` - OpenAI-compatible, pay-per-token.
4. **Agent API**: `POST /v1/agent` - multi-step agentic workflows with built-in web_search + fetch_url. Presets: fast-search, pro-search, deep-research, advanced-deep-research.

## Perplexity Computer Details

- No public API for Computer product; browser automation is the only programmatic path
- Tasks page: `perplexity.ai/computer/tasks`
- Supports multi-model routing (19 models), file writing, browser use
- User's active tasks include immigration research, PR risk dashboards

## Pricing (API/MCP path)

- Sonar: $1/M input, $1/M output
- Sonar Pro: $3/M input, $15/M output
- Deep Research: $2/M input, $8/M output + $5/1K search queries
- Search API: $5/1K requests (raw results only)

## 2026 Note

Perplexity CTO (March 11, 2026) announced shift away from MCP toward Agent API as flagship. MCP server still maintained but Agent API is preferred path for new integrations.
