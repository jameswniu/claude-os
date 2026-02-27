# Memory

Topical reference for quick lookup. See `logs.md` for chronological session history.

## Bitbucket API

- Base URL: `https://stash.centro.net`
- Project: `CEN`, Repo: `media-strategy-generator`
- PR list endpoint: `/rest/api/1.0/projects/CEN/repos/media-strategy-generator/pull-requests`
- PR comments endpoint: `.../pull-requests/{id}/comments`
- To update a comment, PUT with the current `version` number (increments on each edit). Stale version causes `CommentOutOfDateException`.
- Auth: basic auth with username:token from git remote URL

## Branch Naming

- Branches follow pattern: `BP-{ticket}_description` or `BP-{ticket}-description`
- Examples: `BP-29291_createmp`, `BP-29423-artifact-streaming-phase-2`, `BP-29704-move-prompt-to-langfuse`
- Target branch is almost always `main`. Detect via `git merge-base`.

## Project Architecture

- MCP Server (port 8001): `src/api/`
- Orchestrator (port 8000): `src/orchestrator/`
- Agent/LangGraph workflows: `src/agent/`
- Skills (LLM prompt docs): `src/orchestrator/skills/{skill_name}/SKILL.md`
- Prompt utilities: `src/utils/prompts.py` (uses Langfuse)
- Frontend: `frontend/` (React/Vite/TypeScript)
- Test suite: 1,401+ tests, run with `make test`
- External MCP tools (e.g., `create_media_plan`, `basis_core_create_media_plan`) not defined in this repo
- Media plan tools feature-gated via `media_plan_gated_tools` with user/org allowlists in `src/orchestrator/routes.py`

## PR Review Patterns

- Majority of sessions are code review, but code authoring is increasing (e.g., BP-29704 prompt migration to Langfuse, BP-29836 model version bumps)
- Two PR types: config-only (version bumps, YAML changes) and feature PRs (multi-file, complex)
- Config PRs are low-risk but still get full test suite runs — could be optimized with a lightweight profile
- Feature PRs (e.g., BP-29421 streaming orchestrator, 21+ files) often need multiple review sessions as PR evolves
- Tool usage is overwhelmingly read-only: Bash >> Read >> Grep >> Edit >> Write
- Usage baseline (02-26 insights): 103 sessions, 57 PR reviews, 93% satisfaction, 80% fully achieved
- Parallel multi-Claude sessions observed (02-24): 7 overlap events across 14 sessions

## Recurring Mistakes (Self-Corrections)

- **Verdict in PR comments**: Rule exists in .claude/CLAUDE.md line 14. Violated twice (02-23, 02-26). Must check before posting.
- **`gh` CLI**: Installed via Homebrew (02-26) for GitHub use (claude-os repo). Still use git + curl for Bitbucket PR reviews, never `gh`.
- **Wrong branch**: Must always `git fetch origin` first and diff against remote refs (`origin/main...origin/branch`), never local checkout.
- **Unsolicited edits**: Do not modify files unless user explicitly asks. Flag suggestions in review output instead.
- **Wrong config file**: Personal preferences go in `.claude/CLAUDE.md` (gitignored), never in root `CLAUDE.md` (shared).
- **node_modules in scans**: Exclude `node_modules/`, `dist/`, `.next/` from all grep/regression scans to avoid timeouts and false positives.
- **Session cut-offs on long reviews**: Recurring on 02-21 and 02-25. Rule added to output complete review in single response, but large PRs (20+ files) can still hit context/timeout limits. Consider chunking very large reviews.

## User Preferences

- Hands-off, delegation-oriented. Issues a command and lets Claude run autonomously.
- Brief corrective nudges when things go wrong, not lengthy re-explanations.
- Wants timestamped memory for future learning loop / rolling window implementation.
- Hybrid memory system: MEMORY.md (topical lookup) + logs.md (chronological sessions).
- No verdicts in PR comments. No unsolicited edits. No em dashes in comments.
- Interested in pre-push hooks or CI gates to enforce test runs before pushing

## Topic Files (on demand, read when relevant)

Reference docs in `topics/` subfolder. Zero tokens until read.

- `topics/claudehub.md` — ClaudeHub main page (confluence:1597341723)
- `topics/use-case-library.md` — AI dev tools use-case library (confluence:1559166979)
- `topics/tips-bash-mode.md` — Tip: using bash mode (confluence:1588723799)
- `topics/plugin-marketplace.md` — Plugin marketplace plan (confluence:1527939210)
- `topics/ai-code-reviewer.md` — AI Code Reviewer Project (confluence:1583513725)
- `topics/ai-updates-q4-2025.md` — Apps Engineering AI Updates Q4 2025 (confluence:1531248685)
- `topics/ai-tools-quickstart.md` — AI Tools Quick Start Initiative (confluence:1530822736)
- `topics/claude-code-pricing.md` — Claude Code Pricing Evaluation (confluence:1492484268)
- `topics/ai-pr-summaries.md` — AI Generated PR Summaries (confluence:1425604970)
- Synced every 24h. Scripts auto-discover relevant new pages and add them here.

## Claude OS Repo

- Location: `~/claude-os` (GitHub: `jameswniu/claude-os`)
- Documents the layered context + learning loop system for Claude Code
- `EXAMPLES/` — Snapshots of live config/memory files (scrubbed of secrets)
- `scripts/` — Automation: 1-log, 2-distill, 3-promote, 4-sync-confluence, 5-checkpoint
- `launchd/` — macOS scheduler plists for scripts 1-4
- `tests/test.sh` — 46 validation tests
- Checkpoint: run `checkpoint` (alias) from any project dir to snapshot files to the repo. Run after syncing topic files to push them to EXAMPLES/.
- Automation scripts must run in order (1→2→3→4); can run from Claude Code terminal now (fixed)
- Scripts 1-3 need `unset CLAUDECODE` before `claude -p` to avoid nested session error
- Launchd plists at `~/Library/LaunchAgents/com.claude.memory-*.plist`
- Launchd PATH must include `~/.local/bin` (where `claude` is installed)
- `pmset sleep 0` applied to keep Mac awake so launchd jobs run 24/7
- Company rollout plan: (1) CLAUDE.md, personal CLAUDE.md, memory, settings.local.json (2) add logs.md, manual learning loop (3) local/cloud setup, automatic loop
- Documentation style: FAQ answers below questions (not inline), copy-paste boxes only for runnable code (not prose/explanations)

## Claude Code File System

- `/CLAUDE.md` — Team instructions, checked into git
- `/.claude/` — Gitignored as of 02-27 (removed from tracking, added to `.gitignore`)
- `/.claude/CLAUDE.md` — Personal instructions, gitignored
- `/.claude/commands/review.md` — /review slash command
- `/.claude/settings.local.json` — Permission auto-approvals
- `~/.claude/projects/{project}/memory/MEMORY.md` — This file, auto-loaded
- `~/.claude/projects/{project}/memory/logs.md` — Session log, read on demand
- `~/.claude/projects/{project}/memory/topics/` — Topic files, read on demand
