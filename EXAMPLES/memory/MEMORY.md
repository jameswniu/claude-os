
 Memory

Topical reference for quick lookup. See `logs.md` for chronological session history.

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
- **Stale files in copy-only sync**: When a script copies files to a target directory, always clean the target first if the source is the single source of truth. Copy-only accumulates stale files. Use delete-then-copy (or rsync --delete).
- **Flagging theoretical issues**: Don't flag issues that can't happen in practice (e.g., hypothetical future scenarios). Focus on real, actionable findings.
- **Force-updating git tags**: Orphans the old commit -- files not carried forward are lost. When moving artifacts between refs, verify all linked files exist on the new ref before pushing.

## User Preferences

- Hands-off, delegation-oriented. Issues a command and lets Claude run autonomously.
- Brief corrective nudges when things go wrong, not lengthy re-explanations.
- Wants timestamped memory for future learning loop / rolling window implementation.
- Hybrid memory system: MEMORY.md (topical lookup) + logs.md (chronological sessions).
- No verdicts in PR comments. No unsolicited edits. No em dashes in comments.
- PR comments must include direct Bitbucket links when referencing tags, branches, or other repo resources (not just plain text names)
- Interested in pre-push hooks or CI gates to enforce test runs before pushing

## Topic Files (on demand, read when relevant)

Reference docs in the memory directory. Zero tokens until read.
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

- `/CLAUDE.md` — Team instructions, checked into git
- `/.claude/` — Gitignored as of 02-27 (removed from tracking, added to `.gitignore`)
- `/.claude/CLAUDE.md` — Personal instructions, gitignored
- `/.claude/commands/review.md` — /review slash command
- `/.claude/settings.local.json` — Permission auto-approvals
- `~/.claude/projects/{project}/memory/MEMORY.md` — This file, auto-loaded
- `~/.claude/projects/{project}/memory/logs.md` — Session log, read on demand
- `~/.claude/projects/{project}/memory/*.md` — Topic files, read on demand
