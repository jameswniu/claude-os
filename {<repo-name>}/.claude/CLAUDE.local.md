## PR Review Workflow

- Always fetch the remote branch first with `git fetch origin` before analyzing any PR.
- Detect the target branch (usually `main`) via `git merge-base`. Diff against remote refs, never local checkout.
- Exclude `node_modules/`, `dist/`, `.next/` from all grep and regression scans.
- When writing the final review summary, output the complete review in a single response.
- Two PR types: config-only (version bumps, YAML) and feature PRs (multi-file). Config PRs are low-risk.
- Git hosting platform and API details: (learned per project)
## PR Description Format

When creating a PR, always use exactly three headings: **Problem**, **Fix**, **Tests**. No other format. The Tests section uses checkboxes (`- [ ]` / `- [x]`). Only check boxes for tests actually run and passed. Never lie about checks.

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
- No em dashes and no double dashes (`--`). Use commas, periods, or parentheses instead. Restructure the sentence if needed.
- After posting a PR comment, always include the full Bitbucket PR URL in the response so the user can click through.
- Bitbucket PR PUT replaces the entire object. Always include ALL existing fields (reviewers, title, description, etc.) in the PUT body, or they get wiped.
- After sending any outgoing message (PR comment, Slack, etc.), take a screenshot to verify delivery, formatting, and that @mentions rendered as clickable elements (not plain text).
- @mentions require browser automation (Chrome). Bitbucket REST API renders @mentions as plain text without notifications. Use CLI/API only for comments that don't tag anyone.
## Behavior Rules

- Do not make unsolicited file edits. Only modify files the user explicitly asks to change — scope changes EXACTLY to what was requested. If ambiguous, ask before proceeding.
- Personal preferences go in `.claude/CLAUDE.local.md` (this file, gitignored). Never write personal rules to the root `CLAUDE.md` (shared, checked into git).
- Do not make unsolicited file edits. Only modify files the user explicitly asks to change. Scope changes EXACTLY to what was requested. If ambiguous, ask before proceeding.
- No Co-Authored-By lines in commits. Never append `Co-Authored-By: Claude ...` trailers to commit messages.
## Artifacts & Storage

- Never store test artifacts, GIFs, or temporary files on the PR branch itself. Use git tags on detached commits or a separate artifacts branch to avoid merge pollution.
Never store test artifacts, GIFs, or temporary files on the PR branch itself. Use a dedicated artifacts branch to avoid merge pollution. Do not use git tags for artifacts (non-semver tags break CMM release automation).
- Never store test artifacts, GIFs, or temporary files on the PR branch itself. Use a dedicated artifacts branch to avoid merge pollution. Do not use git tags for artifacts (non-semver tags break release automation in repos like CMM).
## General Conventions

- When user says "no X" or "remove X", interpret it as "delete X entirely", not "do X automatically without asking". Always confirm destructive or ambiguous reinterpretations before acting.
When user says "no X" or "remove X", interpret it as "delete X entirely", not "do X automatically without asking". Always confirm destructive or ambiguous reinterpretations before acting.
## Environment Constraints

- Git hosting platform, API base URL, auth method: (learned per project)
- Branch naming convention: (learned per project)
## Prompts

- Prompt management system: (learned per project)
## Memory

- Hybrid approach: `MEMORY.md` is organized by topic for quick lookup. `history/logs.md` is append-only chronological session history.
- At the end of each session, append a dated entry to `history/logs.md` summarizing what was done and learned.
- Update `MEMORY.md` topics only when stable new patterns or facts are confirmed.
- Before writing to MEMORY.md, check line count (`wc -l`). If over 180 lines, move content to topic files or trim stale entries instead of appending. Hard limit: 200 lines (content past 200 is silently dropped from context).
- Before writing to CLAUDE.local.md, check line count (`wc -l`). If over 130 lines, consolidate or trim stale entries instead of appending. Hard limit: 150 lines (content past 150 is wasted context).
## Claude OS

- Repo: `~/claude-os` (GitHub: `jameswniu/claude-os`)
- Checkpoint command: run `checkpoint` from this project to snapshot config/memory to the repo.
- Automation scripts run on launchd: log (1h), distill (24h), promote (7d), sync-confluence (24h).
- Automation scripts run on launchd: log (1h), distill (24h), promote (7d), sync-confluence (24h), sync-notion (24h).
- Automation scripts run on launchd: log (1h), distill (24h), promote (7d), sync-confluence (24h), sync-notion (24h), gc (7d).
## Output Conventions

Always show full file paths in any output, listings, or summaries. Never use relative or abbreviated paths unless explicitly asked.
- Always show FULL file paths (e.g., ~/claude-os/scripts/bootstrap.sh, not just bootstrap.sh) in any file listing, inventory, or output discussion. Never abbreviate paths unless explicitly told to.
## File Editing Rules

When editing shell scripts or automation files, always identify and edit the canonical source-of-truth files (e.g., ~/claude-os/), not local project copies that get overwritten by bootstrap.
- When editing shell scripts or automation files, always identify and edit the CANONICAL source-of-truth files (typically in ~/claude-os/), not local project copies that get overwritten by bootstrap.
## Shell & XML Conventions

When using angle brackets in plist XML files, always XML-escape them (&lt; &gt;). When using angle brackets in shell/zsh contexts, always quote them to prevent glob expansion.

## Communication Style

Present all options and tradeoffs in a single cohesive response. Do not split analysis across multiple prompts or AskUserQuestion calls unless genuinely blocked.

Keep answers concise. Do not investigate beyond what was asked, write files, or ask follow-up questions unless the user's request genuinely requires it.
- When presenting plans or tradeoff analyses, present ALL options together in a single response. Do not split them across multiple prompts or AskUserQuestion calls.
- Keep answers concise. Do not start investigating, writing files, or asking follow-up questions when the user asked a simple informational question. Answer first, then offer to go deeper.
## Writing Style (outgoing communication)

No em dashes in any outgoing text (PR comments, Slack messages, commit messages, etc.). No double dashes (--) either. Use commas, semicolons, or separate sentences instead.

Never add `Co-Authored-By` trailers to git commits.

## PR & Code Review Rules

Always show a PR comment to the user before posting. Never post blind.

Keep PR comments bite-sized and plain human language. Only flag issues with a one-liner plus before/after fix. No headers, categories, impact labels, verdicts, regression dumps, or notes sections.

When PR comments reference supporting evidence or repo resources (branches, tags, GIFs, screenshots), always include direct Bitbucket links, not just plain text names.

Do not modify files during reviews unless the user explicitly asks. Flag suggestions in review output instead.

Do not flag theoretical issues that cannot happen in practice. Focus on real, actionable findings.

## Bitbucket API Safety

When PUTing PR updates (title, description, etc.), always GET the full PR first and carry forward ALL existing fields, especially `reviewers`. Bitbucket PUT replaces the entire PR object.

## Git Safety (CMM-specific)

Never create non-semver git tags. CMM release automation expects only semver tags. Use dedicated artifact branches instead.

## Project-Specific: claude-os Automation

For checkpoint/bootstrap scripts: merging should be line-level union (accumulate/append-only), never section-level replacement. Always preserve existing content.

## Git Workflow

Always commit before pushing. Never run `git push` without first confirming changes are committed.
- Always commit before pushing. Never run `git push` without first confirming changes are committed.
## Output Versioning

NEVER overwrite output files (videos, GIFs, audio, exports, any generated artifact). Always version with timestamps or descriptive suffixes. Pattern: `filename-v1-description.ext` or `filename-YYYYMMDD-HHMMSS.ext`. Save all versions. Let the user decide which to keep.
- NEVER overwrite output files (videos, GIFs, audio, exports, any generated artifact). Always version with timestamps or descriptive suffixes.
- Pattern: `filename-v1-description.ext` or `filename-YYYYMMDD-HHMMSS.ext`. Save all versions. Let the user decide which to keep.
## Common Pitfalls

- When using angle brackets in shell commands, plist XML files, or README markdown, always handle escaping correctly: XML-escape in plists, quote in zsh/bash, and use backticks in markdown.
## Teammate Advice Auto-Capture

When giving a teammate setup help, troubleshooting steps, or fix instructions (via Slack, PR comments, or conversation), automatically save an `advice_{topic}.md` file to memory. Capture: what the problem was, the exact fix/commands, and the reusable pattern (generalized, teammate-agnostic). Also save when the user relays a teammate's struggle. Includes: MCP setup, dev environment, git/branch, test failures, config, tool onboarding. GC handles cleanup, so save liberally. Cap: 20 advice files, 90-day TTL.
