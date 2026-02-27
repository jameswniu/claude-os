# Memory

Topical reference for quick lookup. See `logs.md` for chronological session history.

## User Preferences

- Hands-off, delegation-oriented. Issues a command and lets Claude run autonomously.
- Brief corrective nudges when things go wrong, not lengthy re-explanations.
- Hybrid memory system: MEMORY.md (topical lookup) + logs.md (chronological sessions).
- No em dashes in comments or documentation.

## Recurring Mistakes (Self-Corrections)

- **Unsolicited edits**: Do not modify files unless user explicitly asks. Flag suggestions in review output instead.
- **Wrong config file**: Personal preferences go in `.claude/CLAUDE.md` (gitignored), never in root `CLAUDE.md` (shared).
- **Stale files in copy-only sync**: When a script copies files to a target directory, always clean the target first if the source is the single source of truth. Use delete-then-copy (or rsync --delete).

## Topic Files (on demand, read when relevant)

Reference docs in `topics/` subfolder. Zero tokens until read.
- Synced every 24h. Scripts auto-discover relevant new pages and add them here.

## Claude OS Repo

- Location: `~/claude-os` (GitHub: `jameswniu/claude-os`)
- Checkpoint: run `checkpoint` from any project dir to snapshot files to the repo.
- Bootstrap: run `bootstrap` from any project dir to pull templates and sync topics.

## Claude Code File System

- `/CLAUDE.md` -- Team instructions, checked into git
- `/.claude/CLAUDE.md` -- Personal instructions, gitignored
- `/.claude/commands/` -- Slash commands
- `/.claude/settings.local.json` -- Permission auto-approvals
- `~/.claude/projects/{project}/memory/MEMORY.md` -- This file, auto-loaded
- `~/.claude/projects/{project}/memory/logs.md` -- Session log, read on demand
- `~/.claude/projects/{project}/memory/topics/` -- Topic files, read on demand
