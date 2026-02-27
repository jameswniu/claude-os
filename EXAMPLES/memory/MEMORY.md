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

- 98% of sessions are code review, not code writing
- Two PR types: config-only (version bumps, YAML changes) and feature PRs (multi-file, complex)
- Config PRs are low-risk but still get full test suite runs — could be optimized with a lightweight profile
- Feature PRs (e.g., BP-29421 streaming orchestrator, 21+ files) often need multiple review sessions as PR evolves
- Tool usage is overwhelmingly read-only: Bash >> Read >> Grep >> Edit >> Write

## Recurring Mistakes (Self-Corrections)

- **Verdict in PR comments**: Rule exists in .claude/CLAUDE.md line 14. Violated twice (02-23, 02-26). Must check before posting.
- **`gh` CLI**: Not installed. Discovered early (02-18), added to CLAUDE.md, but still attempted occasionally. Always use git + curl.
- **Wrong branch**: Must always `git fetch origin` first and diff against remote refs (`origin/main...origin/branch`), never local checkout.
- **Unsolicited edits**: Do not modify files unless user explicitly asks. Flag suggestions in review output instead.
- **Wrong config file**: Personal preferences go in `.claude/CLAUDE.md` (gitignored), never in root `CLAUDE.md` (shared).
- **node_modules in scans**: Exclude `node_modules/`, `dist/`, `.next/` from all grep/regression scans to avoid timeouts and false positives.

## User Preferences

- Hands-off, delegation-oriented. Issues a command and lets Claude run autonomously.
- Brief corrective nudges when things go wrong, not lengthy re-explanations.
- Wants timestamped memory for future learning loop / rolling window implementation.
- Hybrid memory system: MEMORY.md (topical lookup) + logs.md (chronological sessions).
- No verdicts in PR comments. No unsolicited edits. No em dashes in comments.

## Topic Files (on demand, read when relevant)

Reference docs in `topics/` subfolder. Zero tokens until read.

- `topics/claudehub.md` — ClaudeHub main page: onboarding, quick links, key concepts, marketplace info, code examples
- `topics/use-case-library.md` — Proven prompts for code generation, debugging, testing, documentation, code review
- `topics/tips-bash-mode.md` — Tip: using `!` bash mode for efficient command execution
- `topics/plugin-marketplace.md` — Plugin marketplace plan: repos, current plugins, status, architecture
- Source: Confluence (BET space). Synced every 24h, may be slightly stale.

## Claude OS Repo

- Location: `~/claude-os` (GitHub: `jameswniu/claude-os`)
- Documents the layered context + learning loop system for Claude Code
- `EXAMPLES/` — Snapshots of live config/memory files (scrubbed of secrets)
- `scripts/` — Automation: 1-log, 2-distill, 3-promote, 4-sync-confluence, 5-checkpoint
- `launchd/` — macOS scheduler plists for scripts 1-4
- `tests/test.sh` — 46 validation tests
- Checkpoint: run `checkpoint` (alias) from any project dir to snapshot files to the repo

## Claude Code File System

- `/CLAUDE.md` — Team instructions, checked into git
- `/.claude/CLAUDE.md` — Personal instructions, gitignored
- `/.claude/commands/review.md` — /review slash command
- `/.claude/settings.local.json` — Permission auto-approvals
- `~/.claude/projects/{project}/memory/MEMORY.md` — This file, auto-loaded
- `~/.claude/projects/{project}/memory/logs.md` — Session log, read on demand
- `~/.claude/projects/{project}/memory/topics/` — Topic files, read on demand
