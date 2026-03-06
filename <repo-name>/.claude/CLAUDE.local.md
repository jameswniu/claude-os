## PR Review Workflow

- Always fetch the remote branch first with `git fetch origin` before analyzing any PR.
- Detect the target branch (usually `main`) via `git merge-base`. Diff against remote refs, never local checkout.
- Exclude `node_modules/`, `dist/`, `.next/` from all grep and regression scans.
- When writing the final review summary, output the complete review in a single response.
- Two PR types: config-only (version bumps, YAML) and feature PRs (multi-file). Config PRs are low-risk.
- Git hosting platform and API details: (learned per project)
## PR Reviews & Comments

- No em dashes. Use commas, periods, or parentheses instead.
- Format: short human-readable description of the issue, then before/after code (or suggested fix), then whether the rest looks good. That's it.
- Write concisely in plain human language. No structured reports, no headers, no categories/impact labels, no regression dumps, no verbose AI-style prose.
- Do not include a verdict section (APPROVE, REQUEST CHANGES, etc.) unless explicitly asked.
- Always include direct Bitbucket links when referencing tags, branches, or other repo resources in PR comments (not just plain text names).
- When posting PR comments (Bitbucket or GitHub), ALWAYS include direct file links/permalinks. Never reference files without clickable links.
- When working with multiple repos or companion PRs, always confirm the exact repo and PR number before posting comments or approvals. Never assume which repo a PR belongs to.
- Always show the full comment text to the user for approval BEFORE posting. Never post without showing first.
- When posting Bitbucket comments, PUT with the current `version` number. It increments on each edit.

## Behavior Rules

- Do not make unsolicited file edits. Only modify files the user explicitly asks to change — scope changes EXACTLY to what was requested. If ambiguous, ask before proceeding.
- Personal preferences go in `.claude/CLAUDE.local.md` (this file, gitignored). Never write personal rules to the root `CLAUDE.md` (shared, checked into git).

## Artifacts & Storage

- Never store test artifacts, GIFs, or temporary files on the PR branch itself. Use git tags on detached commits or a separate artifacts branch to avoid merge pollution.

## General Conventions

- When user says "no X" or "remove X", interpret it as "delete X entirely", not "do X automatically without asking". Always confirm destructive or ambiguous reinterpretations before acting.

## Environment Constraints

- Git hosting platform, API base URL, auth method: (learned per project)
- Branch naming convention: (learned per project)
## Prompts

- Prompt management system: (learned per project)
## Memory

- Hybrid approach: `MEMORY.md` is organized by topic for quick lookup. `history/logs.md` is append-only chronological session history.
- At the end of each session, append a dated entry to `history/logs.md` summarizing what was done and learned.
- Update `MEMORY.md` topics only when stable new patterns or facts are confirmed.

## Claude OS

- Repo: `~/claude-os` (GitHub: `jameswniu/claude-os`)
- Checkpoint command: run `checkpoint` from this project to snapshot config/memory to the repo.
- Automation scripts run on launchd: log (1h), distill (24h), promote (7d), sync-confluence (24h).
