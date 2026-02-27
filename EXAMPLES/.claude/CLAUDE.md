## PR Review Workflow

- Always fetch the remote branch first with `git fetch origin` before analyzing any PR.
- Detect the target branch (usually `main`) via `git merge-base`. Diff against remote refs, never local checkout.
- Exclude `node_modules/`, `dist/`, `.next/` from all grep and regression scans.
- When writing the final review summary, output the complete review in a single response.
- Two PR types: config-only (version bumps, YAML) and feature PRs (multi-file). Config PRs are low-risk.
- Git hosting platform and API details: (learned per project)

## PR Comment Style

- No em dashes. Use commas, periods, or parentheses instead.
- Format: short human-readable description of the issue, then before/after code (or suggested fix), then whether the rest looks good.
- Write in plain human language. No structured reports, no headers, no categories/impact labels.
- Do not include a verdict section (APPROVE, REQUEST CHANGES, etc.) when posting review comments.

## Behavior Rules

- Always show the full comment text to the user for approval BEFORE posting. Never post without showing first.
- Do not make unsolicited file edits. Only modify files the user explicitly asks to change.
- Personal preferences go in `.claude/CLAUDE.md` (this file, gitignored). Never write personal rules to the root `CLAUDE.md` (shared, checked into git).

## Environment Constraints

- Git hosting platform, API base URL, auth method: (learned per project)
- Branch naming convention: (learned per project)

## Memory

- Hybrid approach: `MEMORY.md` is organized by topic for quick lookup. `logs.md` is append-only chronological session history.
- At the end of each session, append a dated entry to `logs.md` summarizing what was done and learned.
- Update `MEMORY.md` topics only when stable new patterns or facts are confirmed.

## Claude OS

- Repo: `~/claude-os` (GitHub: `jameswniu/claude-os`)
- Checkpoint command: run `checkpoint` from this project to snapshot config/memory to the repo.
- Bootstrap command: run `bootstrap` from this project to pull templates and sync topics.
