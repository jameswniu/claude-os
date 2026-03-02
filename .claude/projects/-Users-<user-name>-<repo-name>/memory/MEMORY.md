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

## Claude Code File System

- `/CLAUDE.md` - Team instructions, checked into git
- `/.claude/CLAUDE.md` - Personal instructions, gitignored
- `/.claude/commands/review.md` - /review slash command
- `/.claude/settings.local.json` - Permission auto-approvals
- `~/.claude/projects/{project}/memory/MEMORY.md` - This file, auto-loaded
- `~/.claude/projects/{project}/memory/log.md` - Session log, read on demand
- `code-reviews.md` -- reference material
