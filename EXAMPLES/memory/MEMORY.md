# Memory

Topical reference for quick lookup. See `log.md` for chronological session history.

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
- Hybrid memory system: MEMORY.md (topical lookup) + log.md (chronological sessions).
- No verdicts in PR comments. No unsolicited edits. No em dashes in comments.

## Artifact Management

- Never store test artifacts, GIFs, or demo recordings on PR branches (merges into main)
- Use orphan git tags (e.g., `BP-29577-ui-test-evidence`) for storing PR evidence
- Force-updating a git tag orphans the old commit and loses files not carried forward
- When moving artifacts between refs, verify all linked files exist on the new ref before pushing
- PR comment links to artifacts use `raw/` URLs pointing to tag refs

## Claude Code File System

- `/CLAUDE.md` - Team instructions, checked into git
- `/.claude/CLAUDE.md` - Personal instructions, gitignored
- `/.claude/commands/review.md` - /review slash command
- `/.claude/settings.local.json` - Permission auto-approvals
- `~/.claude/projects/{project}/memory/MEMORY.md` - This file, auto-loaded
- `~/.claude/projects/{project}/memory/log.md` - Session log, read on demand
