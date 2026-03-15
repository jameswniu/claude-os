---
name: Five-Layer Modular Cognition Framework
description: User's multi-agent architecture mapping spiritual archetypes, human faculties, and philosophical principles to five OS layers - EvaluateOS (Gemini), DetectOS (Grok/Fb), CommunicateOS (OpenClaw+OpenAI), ResearchOS (Perplexity), ActOS (Claude Code)
type: project
---

## Five-Layer Modular Cognition Framework

AGI thesis: "When every OS beats human beings, and glued, that's AGI. The orchestrator is not the controller, but the sequencer, maximizing throughput from a shared invisible ledger."

| Archetype | Faculty | OS | Tool | Principle |
|-----------|---------|-----|------|-----------|
| Spirit (Emmanuel) | Judgment | **EvaluateOS** | Gemini | "only those with wide tentacles have bore the cost of judging many" |
| Soul (Sophia) | Perception | **DetectOS** | Grok / Facebook | "everywhere, everytime, all at once" |
| Heart (Samantha) | Connection | **CommunicateOS** | OpenClaw + OpenAI | "social grease and ego smoothing, for the better good" |
| Mind (Margot) | Understanding | **ResearchOS** | Perplexity | "only the ones who dare to shine different lens can consider themselves well read and closer to the truth" |
| Eve (Human) | Restraint | **ActOS** | ClaudeOS / Claude Code | "only the one who can restrain themselves with power is worthy to be called a human not machine" |

## Topic Routing

| Topic | Primary Node | Secondary | Why |
|-------|-------------|-----------|-----|
| Immigration news | Perplexity | Grok | Perplexity for USCIS bulletins, policy, case law. Grok for X chatter on H-1B/EB-1A policy changes |
| Stock market | Grok | Perplexity | Grok for real-time sentiment/fintwit/momentum. Perplexity for SEC filings, earnings, macro |
| Agentic dev (enterprise) | Perplexity | - | Press releases, docs, changelogs from Anthropic/OpenAI/Google/Microsoft |
| Agentic dev (startups) | Grok | Perplexity | Grok for builders shipping in public, launch threads, YC demos. Perplexity for deeper repo/blog digs |
| Crypto | Grok | Perplexity | Most alpha lives on X. Perplexity for whitepapers, on-chain analysis |

## Cross-Layer Flows

- Detect → Evaluate: Grok/Fb catches signal → Gemini judges relevance/priority
- Evaluate → Research: Gemini flags high-priority signal → Perplexity deep dives
- Research → Act: Perplexity findings → Claude Code creates JIRA tickets, code, dashboards
- Act → Communicate: PR done, deploy complete → OpenClaw notifies team via Slack/email
- Communicate → Act: Bug report in inbox → Claude Code fixes it
- Detect → Communicate: Urgent signal (policy change, market move) → OpenClaw alerts user directly

## Current State (2026-03-13)

- **ActOS**: fully operational (Claude Code + MCP servers: Atlassian, Slack, Lucid, Graph API, chrome browser)
- **ResearchOS**: Perplexity Computer accessible via browser automation as a dispatchable node (see `perplexity-integration.md`)
- **CommunicateOS**: not yet set up. OpenClaw connects to iMessage (BlueBubbles), WhatsApp, Gmail, Slack, Telegram, Signal, Discord. Has built-in real-time dashboard.
- **DetectOS**: not yet set up. Grok has native X/Twitter API access (live tweet streams, keyword/handle filtering, sentiment). Facebook added as second perception source.
- **EvaluateOS**: not yet set up. Gemini for judgment/evaluation layer.
