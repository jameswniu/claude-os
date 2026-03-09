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
- **Wrong config file**: Personal preferences go in `.claude/CLAUDE.local.md` (gitignored), never in root `CLAUDE.md` (shared).
- **Stale files in copy-only sync**: When a script copies files to a target directory, always clean the target first if the source is the single source of truth. Copy-only accumulates stale files. Use delete-then-copy (or rsync --delete).
- **Flagging theoretical issues**: Don't flag issues that can't happen in practice (e.g., hypothetical future scenarios). Focus on real, actionable findings.
- **Force-updating git tags**: Orphans the old commit -- files not carried forward are lost. When moving artifacts between refs, verify all linked files exist on the new ref before pushing.
- **PR comment style**: Violated Feb 27 (BP-29423). Iterated 4 times from structured report to plain language. Must keep bite-sized: issue + before/after fix + whether rest looks good. No headers, categories, or impact labels.
- **Non-semver git tags**: Broke CMM release automation (which expects only semver tags). Arturo deleted the offending tag. Never use tags for artifacts in repos with semver release automation. Use dedicated artifact branches instead.
- **Wrong-repo scoping**: When multiple repos are involved (e.g., CMM + media-strategy-generator), always confirm which repo a change belongs to before suggesting edits.
- **Wiping PR reviewers**: Bitbucket PUT replaces the entire PR object. Always GET the full PR first and include `reviewers` (and all other fields) in the PUT payload when updating title/description.
- **Wrong config file**: Personal preferences go in `.claude/CLAUDE.local.md` (gitignored), never in root `CLAUDE.md` (shared). Recurred Mar 4; required rollback.
- **Bitbucket PR PUT wipes fields**: Mar 3 (BP-29577). Sent only `version` + `description`, wiped all 6 reviewers. Must always include all existing fields in PUT body.
- **@mention verification**: After posting any outgoing message (PR comment, Slack, WhatsApp, etc.), always verify that @mentions/tags rendered as clickable elements (links or `data-mention-id` spans), not plain text. If plain text, edit and fix immediately. Bitbucket mention syntax in editor is `@"username"` (inserted via autocomplete Enter key, not click). Rendered mentions have `data-mention-id` attribute on parent span.
- **Learning loop slug-to-path**: `sed 's|-|/|g'` cannot reverse Claude project slugs (ambiguous: `-` could be from `/`, `.`, or literal `-`). Must match forward (path-to-slug via `replace('/','-').replace('.','-')`) against known paths in `history.jsonl`. Fixed Mar 3.
## User Preferences

- Hands-off, delegation-oriented. Issues a command and lets Claude run autonomously.
- Brief corrective nudges when things go wrong, not lengthy re-explanations.
- Wants timestamped memory for future learning loop / rolling window implementation.
- Hybrid memory system: MEMORY.md (topical lookup) + history/logs.md (chronological sessions).
- No verdicts in PR comments. No unsolicited edits. No em dashes in comments.
- PR comments must include direct Bitbucket links when referencing tags, branches, or other repo resources (not just plain text names)
- Interested in pre-push hooks or CI gates to enforce test runs before pushing
- No verdicts in PR comments. No unsolicited edits. No em dashes in comments. No double dashes (--) in outgoing human communication (PR comments, Slack messages, etc.).
- Never add `Co-Authored-By` trailers to git commits.
- No verdicts in PR comments. No unsolicited edits. No em dashes in comments. Always include clickable PR link at the bottom when presenting reviews or asking for approval to post/approve.
- **Always include the PR link after posting a comment.** Every time a PR comment is posted, include the full Bitbucket PR URL in the response so the user can click through.
- **No Co-Authored-By lines in commits.** Never append `Co-Authored-By: Claude ...` trailers to commit messages. Applies to all repos.
- **No double dashes in outgoing messages.** Never use `--` (em-dash substitute) in messages to humans (Slack, PR comments, etc.). Use commas, periods, or restructure the sentence instead.
- **Always verify sends.** After sending any outgoing message (Slack, PR comment, etc.), take a screenshot to confirm it was delivered and check for typos/formatting issues before reporting success.
- **@mentions require browser.** When user asks to tag someone, use browser (Chrome automation) to post -- Bitbucket REST API renders @mentions as plain text without notifications. CLI/API is fine for comments that don't tag anyone. Applies to all platforms (Bitbucket, Slack, WhatsApp, etc.). If CLI is later verified to support proper mentions on a platform, can switch back to CLI for that platform.
- **Always attach test evidence.** PR comments about UI/smoke tests must include screenshots/GIFs as proof. Don't post test results without attached artifacts.
## Topic Files (on demand, read when relevant)

Reference docs in the memory directory. Zero tokens until read.
- `03-05-2026-claude-code-with-chrome.md` -- reference material
- `agent-dx-patterns.md` -- reference material
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
- `basis-environments-overview.md` -- reference material
- `claude-code-pricing.md` -- reference material
- `claude-code-settings-security-incident.md` -- reference material
- `claudehub.md` -- when onboarding to Claude Code or finding internal resources
- `claudeos-beta.md` -- reference material
- `claudeos.md` -- reference material
- `code-reviews.md` -- when reviewing PRs or discussing review practices
- `datadog-compass.md` -- reference material
- `datadog-crash-course.md` -- reference material
- `demo-recording.md` -- reference material
- `git-fundamentals.md` -- reference material
- `how-to-write-a-self-review-for-developers.md` -- reference material
- `informal-tech-mentorship.md` -- when mentoring or structuring knowledge transfer
- `plugin-marketplace.md` -- reference material
- `problem-2-semantic-versioning.md` -- reference material
- `scalable-applications-and-architecture.md` -- when designing services or making architecture decisions
- `shell-basics.md` -- reference material
- `team-values.md` -- reference material
- `team.md` -- reference material
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
- Launchd PATH must include `~/.local/bin` (where `claude` is installed)
- `pmset sleep 0` applied to keep Mac awake so launchd jobs run 24/7
- Company rollout plan: (1) CLAUDE.md, personal CLAUDE.md, memory, settings.local.json (2) add logs.md, manual learning loop (3) local/cloud setup, automatic loop
- Documentation style: FAQ answers below questions (not inline), copy-paste boxes only for runnable code (not prose/explanations)
- `chpwd` hook in `~/.zshrc` auto-checkpoints in background when leaving a directory with `.claude/`
- EXAMPLES/ files are templatized (placeholders, no project-specific URLs/tickets/architecture); checkpoint only syncs memory + topics, not config templates
- Sync scripts derive search queries dynamically from MEMORY.md + CLAUDE.md (no hardcoded queries, relevance filters, or exclude terms)
- Sync scripts exit 2 (not 0) when credentials missing, so callers distinguish skip from success
- **Template/docs repo only — NOT a runtime dependency.** Audited 2026-03-06: all 10 learning loop jobs run with zero references to ~/claude-os.
- `~/claude-os/scripts/` and `~/claude-os/launchd/` do NOT exist; templates live inside `{<repo-name>}/.claude/scripts/`
- `~/claude-os/output/` — 27 stale historical log files, no longer written to
### Learning Loop (fully decoupled, verified 2026-03-06)
- 10 scripts (1-5 x 2 projects) live in `<project>/.claude/scripts/`, use `LOG_DIR="$SCRIPT_DIR/../logs"` (project-local)
- 10 plists at `~/Library/LaunchAgents/com.claude.{centro-media-manager,media-strategy-generator}.{log,distill,promote,sync-confluence,sync-notion}.plist`
- Plist intervals: log=3600s, distill=86400s, promote=604800s, sync-confluence=86400s, sync-notion=86400s
- Scripts run in order (1→2→3→4→5); scripts 1-3 need `unset CLAUDECODE` before `claude -p`
- Sync scripts derive search queries dynamically from MEMORY.md + CLAUDE.md (no hardcoded queries)
- Conceptual model: dynamic reinforcement through log distillation (1→2→3) and MEMORY.md promotion, not static weights or built-in RL
- **Dependency**: `html2text` Python module required by 4-sync-confluence.sh (installed via `pip3 install --break-system-packages html2text`)
### Manual-only utilities (not scheduled)
- **5-checkpoint.sh** (MSG only) — pushes live config into claude-os templates. Run via `checkpoint` alias.
- **6-bootstrap.sh** (MSG only) — pulls templates from claude-os into a new project
### Other
- Team wants claude-os published as a branch on existing repo, not standalone
## UI Smoke Testing

- Automated UI smoke tests via browser extension on localhost
- Export before/after GIF recordings as PR evidence
- Store test artifacts on orphan git tags (not PR branches) to avoid merging demo files into main
- PR comment links should use raw URLs pointing to tags for GIF/image display

## Claude Code File System

- `/CLAUDE.md` — Team instructions, checked into git
- `/.claude/` — Gitignored as of 02-27 (removed from tracking, added to `.gitignore`)
- `/.claude/CLAUDE.local.md` — Personal instructions, gitignored
- `/.claude/commands/review.md` — /review slash command
- `/.claude/settings.local.json` — Permission auto-approvals
- `~/.claude/projects/{project}/memory/MEMORY.md` — This file, auto-loaded
- `~/.claude/projects/{project}/memory/history/logs.md` — Session log, read on demand
- `~/.claude/projects/{project}/memory/*.md` — Topic files, read on demand
- `ai-pr-summaries.md` -- reference material
- `ai-tools-quickstart.md` -- reference material
- `ai-updates-q4-2025.md` -- reference material
- `apps-engineering-growth-framework.md` -- reference material
- `apps-engineering-pad-skills-assessment-supplement.md` -- reference material
- `apps-engineering-resource-library-formerly-onboarding.md` -- reference material
- `apps-engineering-team.md` -- reference material
- `claude-code-pricing.md` -- reference material
- `informal-tech-mentorship.md` -- reference material
- `plugin-marketplace.md` -- reference material
- `scalable-applications-and-architecture.md` -- reference material
- `tips-bash-mode.md` -- reference material
- `code-reviews.md` -- reference material
- `/.claude/` — Partially gitignored (scripts/, logs/, commands/, worktrees/ ignored; settings.json tracked)
- `/.claude/CLAUDE.local.md` — Personal instructions, auto-gitignored by Claude Code (`*.local.*` pattern)
- `/.claude/worktrees/` — Used by EnterWorktree tool for parallel git worktree sessions
- `~/.claude/commands/review.md` — /review slash command (user-level, available across repos)
- `~/.claude/commands/ticket.md` — /ticket slash command (user-level, available across repos)
- Settings scoping (highest to lowest priority): `.claude/settings.local.json` (personal, gitignored) > `.claude/settings.json` (project, checked in) > `~/.claude/settings.json` (user-level) > `/Library/Application Support/ClaudeCode/managed-settings.json` (enterprise)
- Root-level `settings.json` (outside `.claude/`) is NOT recognized by Claude Code
- `~/.claude/settings.local.json` is NOT recognized by Claude Code (verified by testing)
- Claude Code auto-gitignores `*.local.*` files (`settings.local.json`, `CLAUDE.local.md`) when created; `settings.json` is NOT auto-ignored (intended to be shared)
- `/init` generates `.claude/settings.local.json`; pressing "yes" on a tool prompt also auto-saves the allowlist entry there
- Some shell commands (e.g., `echo`, `cat`, `whoami`) auto-approve regardless of allowlist configuration; `ls` does NOT (requires explicit allowlisting)
- Commands with `$()` substitution always prompt regardless of allowlist
- CLAUDE.md can exist in any subdirectory (infinite locations, loaded on demand); settings.json is 3 fixed locations only
- **Security**: CLAUDE.md = AI context (low risk); settings.json = CLI execution permissions (high risk, silently auto-runs commands)
- PR #30710 incident: Jon un-ignored `.claude/` without asking why it was ignored. See `claude-code-settings-security-incident.md`
- `/.claude/commands/review.md` - /review slash command (project-level)
- `~/.claude/commands/` - User-level slash commands (vid, ui) shared across projects
- `/ui` vs `/ui1`: `/ui1` is newer with multi-turn flow and mid-generation refresh support
- `03-05-2026-claude-code-with-chrome.md` -- reference material
- `agent-dx-patterns.md` -- reference material
- `basis-environments-overview.md` -- reference material
- `demo-recording.md` -- reference material
- `how-to-write-a-self-review-for-developers.md` -- reference material
- `team-values.md` -- reference material
- `team.md` -- reference material
## Artifact Management

- Never store test artifacts, GIFs, or demo recordings on PR branches (merges into main)
- Use orphan git tags (e.g., `BP-29577-ui-test-evidence`) for storing PR evidence
- Force-updating a git tag orphans the old commit and loses files not carried forward
- When moving artifacts between refs, verify all linked files exist on the new ref before pushing
- PR comment links to artifacts use `raw/` URLs pointing to tag refs
- Never store test artifacts, GIFs, or demo recordings on PR branches that merge to main
- Use dedicated artifact branches (e.g., `BP-29577-ui-test-evidence`) for storing PR evidence
- Do NOT use git tags for artifacts. Non-semver tags break release automation in repos like CMM that depend on semver-only tags
- PR comment links to artifacts use `raw/` URLs pointing to the artifact branch
- Bitbucket browse URLs: prefer `?at=refs/heads/branch` (full ref) over `?at=branch` (short name) for reliability. Audit artifact links after branch changes.
## Team

- See `team.md` for full profiles. Quick reference:
- **Kyle Bernstein** -- Engineering Lead. Most commits, drives architecture and API key rollout.
- **Julian Selser** -- Scrum Master. Runs sprints, E2E tests, repo split discussion.
- **John Richardson** -- James's onboarding buddy. Streaming/SSE architect.
- **Mitra (Mitravasu Prakash)** -- Evals lead. Owns eval pipeline and model configs.
- **Juan Costamagna** -- Developer. Artifact nav fixes, Compass rename exploration.
- **Robin Lee** -- Developer, CMM point person. Media plan features, CMM proxy knowledge.
- **James Niu** -- Developer, AI tooling. Bug fixes, Claude Code automation, UI smoke testing.
- External: Camilo (DevOps), Mike Hoyle (contributor), Jonah (dept head/budget), Cyan (Cloud Ops)

## Claude-OS

- Repo: `~/claude-os` (GitHub: `jameswniu/claude-os`)
- Checkpoint: run `checkpoint` from any project to snapshot config/memory. Design principle: preserve signal with minimal overwrite; abstract repo-specific details.
- Bootstrap: run `bootstrap` to onboard a new repo (kicks off config + memory structure)
- Launchd automation: log (1h), distill (24h), promote (7d), sync-confluence (24h), sync-notion (24h)
- Per-project plists for msg and cmm repos (separate learning loops)
- Cost scaling: linear with log size; distill/promote summarize and compress
- Distill (24h): compresses older logs.md entries + updates MEMORY.md. Promote (7d): updates topic files from accumulated knowledge.
- `history.jsonl`: Claude Code session telemetry, consumed by learning loop scripts
- Repo uses `{<repo-name>}/.claude/` template directories mirroring real deployment paths; checkpoint splits `$REPO_TMPL` (config) + `$MEM_TMPL` (memory)
- Team rollout planned via 3-phase bootcamp (Microsoft Forms for signup)
- **3-layer config for coaching**: persona in `~/.claude/CLAUDE.md`, team rules in repo `CLAUDE.md`, on-demand knowledge in `MEMORY.md`. Key message: "outsource communication to AI, keep the thinking."

## Demo Recording

- See `demo-recording.md` for full details (script, voices, flags, subtitle style, known issues).

## Output Versioning Rule

- **NEVER overwrite output files.** Always version outputs with timestamps or descriptive suffixes.
- Applies to: videos, GIFs, audio, exports, any generated artifact the user might want to compare.
- Pattern: `filename-v1-description.ext`, `filename-v2-description.ext`, or `filename-YYYYMMDD-HHMMSS.ext`
- Save all versions. Let the user decide which to keep.
