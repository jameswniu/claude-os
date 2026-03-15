---
name: Recurring Mistakes (Self-Corrections)
description: Historical mistakes and self-corrections to avoid repeating — unsolicited edits, wrong config files, wiped reviewers, etc.
type: feedback
---

- **Unsolicited edits**: Do not modify files unless user explicitly asks. Flag suggestions in review output instead.
- **Wrong config file**: Personal preferences go in `.claude/CLAUDE.local.md` (gitignored), never in root `CLAUDE.md` (shared).
- **Stale files in copy-only sync**: When a script copies files to a target directory, always clean the target first if the source is the single source of truth. Copy-only accumulates stale files. Use delete-then-copy (or rsync --delete).
- **Flagging theoretical issues**: Don't flag issues that can't happen in practice (e.g., hypothetical future scenarios). Focus on real, actionable findings.
- **Non-semver git tags**: Broke CMM release automation (which expects only semver tags). Arturo deleted the offending tag. Never use tags for artifacts in repos with semver release automation. Use dedicated artifact branches instead.
- **Wrong-repo scoping**: When multiple repos are involved (e.g., CMM + (project-name)), always confirm which repo a change belongs to before suggesting edits.
- **Wiping PR reviewers**: Bitbucket PUT replaces the entire PR object. Always GET the full PR first and include `reviewers` (and all other fields) in the PUT payload when updating title/description.
- **Skipped merge-dev before PR**: Always merge dev into the feature branch before creating a PR to catch conflicts early. Also run `bundle install` if Gemfile.lock changed.
- **Posted PR comment without showing user first**: Always draft the comment, show it to the user, and get explicit approval before POSTing. Also always ask whether to formally approve the PR (not just comment). Never post blind.
- **Auto-posted Slack message without approval**: See global memory "Never auto-send" rule. Plans saying "reply" or "send" are not user approval.
- **Used general PR comment instead of inline**: Change requests and low-risk notes go as inline comments pinned to file/line. One general PR comment for verdict justification only.
- **PR title parroted ticket title**: PR title must match the actual diff scope, not just repeat the ticket title verbatim. Check the diff before writing the title.
- **Wrong-repo slash command**: Slash commands (`/ui`, `/review`, `/demo`, `/vid`) contain repo-specific URLs (Bitbucket artifact URLs, PR comment permalinks). Always use the command copy from the repo where the PR/branch lives, not the primary working directory.
