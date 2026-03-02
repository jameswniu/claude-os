# Memory

Topical reference for quick lookup. See `history/logs.md` for chronological session history.

## Bitbucket API

- Base URL: (learned per project)
- Project and repo: (learned per project)
- PR list endpoint: (learned per project)
- PR comments endpoint: (learned per project)
- To update a comment, PUT with the current `version` number (increments on each edit).
- Auth: basic auth with username:token from git remote URL

## Branch Naming

- Branches follow pattern: (learned per project)
- Target branch is almost always `main`. Detect via `git merge-base`.

## Project Architecture

- Services, ports, directories: (learned per project)
- Tech stack: (learned per project)
- Test suite: (learned per project)

## PR Comment Style

- Always show comment to user before posting (never post blind)
- Keep comments bite-sized, plain human language
- Only flag issues with one-liner + before/after fix
- No headers, categories, impact labels, regression dumps, or notes sections
- When PR comments reference supporting evidence (GIF recordings, screenshots, artifact tags, etc.), always include direct links to the specific files, not just the parent folder or tag page.

## PR Review Patterns

- Two PR types: config-only (version bumps, YAML changes) and feature PRs (multi-file, complex)
- Config PRs are low-risk but still get full test suite runs
- Feature PRs often need multiple review sessions as PR evolves
- Tool usage is overwhelmingly read-only: Bash >> Read >> Grep >> Edit >> Write

## Recurring Mistakes (Self-Corrections)

- **Unsolicited edits**: Do not modify files unless user explicitly asks. Flag suggestions in review output instead.
- **Wrong config file**: Personal preferences go in `.claude/CLAUDE.md` (gitignored), never in root `CLAUDE.md` (shared).
- **PR comment style**: Violated Feb 27 (BP-29423). Iterated 4 times from structured report to plain language. Must keep bite-sized: issue + before/after fix + whether rest looks good. No headers, categories, or impact labels.

## User Preferences

- Hands-off, delegation-oriented. Issues a command and lets Claude run autonomously.
- Brief corrective nudges when things go wrong, not lengthy re-explanations.
- Wants timestamped memory for future learning loop / rolling window implementation.
- Hybrid memory system: MEMORY.md (topical lookup) + history/logs.md (chronological sessions).
- No verdicts in PR comments. No unsolicited edits. No em dashes in comments.

## Topic Files (on demand, read when relevant)

Reference docs in the memory directory. Zero tokens until read.
- `ai-code-reviewer-project.md` -- when planning AI code review integrations
- `ai-development-tools-use-case-library.md` -- when exploring AI tool use cases or writing prompts
- `ai-pr-summaries.md` -- reference material
- `ai-tools-quickstart.md` -- reference material
- `ai-updates-q4-2025.md` -- reference material
- `apps-engineering-growth-framework.md` -- reference material
- `apps-engineering-pad-skills-assessment-supplement.md` -- reference material
- `apps-engineering-resource-library-formerly-onboarding.md` -- reference material
- `apps-engineering-team.md` -- reference material
- `archived-git-branching-and-pull-request-guidelines.md` -- historical reference for legacy branching rules
- `claude-code-pricing.md` -- reference material
- `claudehub.md` -- when onboarding to Claude Code or finding internal resources
- `code-reviews.md` -- when reviewing PRs or discussing review practices
- `informal-tech-mentorship.md` -- when mentoring or structuring knowledge transfer
- `plugin-marketplace.md` -- reference material
- `scalable-applications-and-architecture.md` -- when designing services or making architecture decisions
- `tickets-branching-and-pull-requests-oh-my.md` -- when setting up git workflows or branching strategies
- `tips-bash-mode.md` -- reference material
- Synced every 24h. Scripts auto-discover relevant new pages and add them here.

## Claude OS Repo

- Location: `~/claude-os` (GitHub: `jameswniu/claude-os`)
- Documents the layered context + learning loop system for Claude Code
- `EXAMPLES/` — Snapshots of live config/memory files (scrubbed of secrets)
- `scripts/` — Automation: 1-log, 2-distill, 3-promote, 4-sync-confluence, 5-sync-notion, 6-bootstrap (checkpoint is a zsh alias)
- `launchd/` — macOS scheduler plists for scripts 1-5
- `tests/test.sh` — 53 validation tests (includes 6 CI guards against project-specific content leaking into templates)
- Checkpoint: run `checkpoint` (alias) from any project dir to snapshot files to the repo. Run after syncing topic files to push them to EXAMPLES/.
- Automation scripts must run in order (1→2→3→4); can run from Claude Code terminal now (fixed)
- Scripts 1-3 need `unset CLAUDECODE` before `claude -p` to avoid nested session error
- Launchd plists at `~/Library/LaunchAgents/com.claude.memory-*.plist`
- Launchd PATH must include `~/.local/bin` (where `claude` is installed)
- `pmset sleep 0` applied to keep Mac awake so launchd jobs run 24/7
- Company rollout plan: (1) CLAUDE.md, personal CLAUDE.md, memory, settings.local.json (2) add logs.md, manual learning loop (3) local/cloud setup, automatic loop
- Documentation style: FAQ answers below questions (not inline), copy-paste boxes only for runnable code (not prose/explanations)
- `chpwd` hook in `~/.zshrc` auto-checkpoints in background when leaving a directory with `.claude/`
- EXAMPLES/ files are templatized (placeholders, no project-specific URLs/tickets/architecture); checkpoint only syncs memory + topics, not config templates
- Sync scripts derive search queries dynamically from MEMORY.md + CLAUDE.md (no hardcoded queries, relevance filters, or exclude terms)
- Sync scripts exit 2 (not 0) when credentials missing, so callers distinguish skip from success

## UI Smoke Testing

- Automated UI smoke tests via browser extension on localhost
- Export before/after GIF recordings as PR evidence
- Store test artifacts on orphan git tags (not PR branches) to avoid merging demo files into main
- PR comment links should use raw URLs pointing to tags for GIF/image display

## Claude Code File System

- `/CLAUDE.md` - Team instructions, checked into git
- `/.claude/CLAUDE.md` - Personal instructions, gitignored
- `/.claude/commands/review.md` - /review slash command
- `/.claude/settings.local.json` - Permission auto-approvals
- `~/.claude/projects/{project}/memory/MEMORY.md` - This file, auto-loaded
- `~/.claude/projects/{project}/memory/history/logs.md` - Session log, read on demand
- `code-reviews.md` -- reference material
## Artifact Management

- Never store test artifacts, GIFs, or demo recordings on PR branches (merges into main)
- Use orphan git tags (e.g., `BP-29577-ui-test-evidence`) for storing PR evidence
- Force-updating a git tag orphans the old commit and loses files not carried forward
- When moving artifacts between refs, verify all linked files exist on the new ref before pushing
- PR comment links to artifacts use `raw/` URLs pointing to tag refs
