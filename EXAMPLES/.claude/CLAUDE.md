## PR Review Workflow

- All PR reviews target Bitbucket (`stash.centro.net`), never personal GitHub repos.
- Always fetch the remote branch first with `git fetch origin` before analyzing any PR.
- Never use `gh` CLI. Use `git` commands and `curl` with Bitbucket Server REST API instead.
- Detect the target branch (usually `main`) via `git merge-base`. Diff against remote refs (`origin/main...origin/branch`), never local checkout.
- Exclude `node_modules/`, `dist/`, `.next/` from all grep and regression scans.
- When writing the final review summary, output the complete review in a single response. Do not pause or wait for confirmation mid-output.
- Two PR types exist: config-only (version bumps, YAML) and feature PRs (multi-file). Config PRs are low-risk and don't need full blast-radius analysis.

## PR Comment Style

- No em dashes. Use commas, periods, or parentheses instead.
- Keep comments condensed and concise. Get straight to the point.
- Do not include a verdict section (APPROVE, REQUEST CHANGES, etc.) when posting review comments on PRs.

## Behavior Rules

- Do not make unsolicited file edits. Only modify files the user explicitly asks to change. If you notice something improvable, mention it but do not edit.
- Personal preferences go in `.claude/CLAUDE.md` (this file, gitignored). Never write personal rules to the root `CLAUDE.md` (shared, checked into git).
- When posting Bitbucket comments, PUT with the current `version` number. It increments on each edit.

## Environment Constraints

- `gh` CLI is installed but reserved for GitHub repos only. Never use it for Bitbucket PR reviews.
- Use `git` commands for branch operations and `curl` with Bitbucket Server REST API for PR metadata.
- Bitbucket base URL: `https://stash.centro.net`, Project: `CEN`, Repo: `media-strategy-generator`.
- Bitbucket API endpoints: PR list at `/rest/api/1.0/projects/CEN/repos/media-strategy-generator/pull-requests`, comments at `.../pull-requests/{id}/comments`.
- Bitbucket auth: basic auth with username:token extracted from git remote URL.
- Branch naming: `BP-{ticket}_description` or `BP-{ticket}-description`.

## Prompts

- Langfuse is the source of truth for all prompts. Never hardcode prompt text in the codebase or in scripts.
- Use `get_text_prompt()` or `get_prompt_template()` from `src/utils/prompts.py` to fetch prompts at runtime.

## Memory

- Hybrid approach: `MEMORY.md` is organized by topic for quick lookup. `logs.md` is append-only chronological session history.
- At the end of each session, append a dated entry to `logs.md` summarizing what was done and learned.
- Update `MEMORY.md` topics only when stable new patterns or facts are confirmed.

## Claude OS

- Repo: `~/claude-os` (GitHub: `jameswniu/claude-os`)
- Checkpoint command: run `checkpoint` from this project to snapshot config/memory to the repo.
- Automation scripts run on launchd: log (1h), distill (24h), promote (7d), sync-confluence (24h).
