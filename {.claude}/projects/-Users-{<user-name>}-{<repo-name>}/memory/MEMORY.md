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
- Scope and constrain: only flag real problems with actionable fixes. Don't add "notes," observations, or FYI callouts that invite bikeshedding. If it's not worth fixing, don't mention it.
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
- **Skipped merge-dev before PR**: Always merge dev into the feature branch before creating a PR to catch conflicts early. Also run `bundle install` if Gemfile.lock changed.
- See `recurring-mistakes.md` for full list (unsolicited edits, wrong config file, wiped reviewers, wrong-repo scoping, etc.)
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
- In all human-facing communication (PR comments, Slack, etc.): scope and constrain. Only raise real problems. Don't add "notes," FYI observations, or tangential callouts that invite unnecessary discussion.
- PR description format and test checkbox rules: see global `~/.claude/memory/MEMORY.md`
- Slash command backup rule: see global `~/.claude/memory/MEMORY.md`
- When saving to memory or config files, always show the full absolute file path (starting from `/Users/james.niu/`) so the user can click it
- No `@claude` tag in Slack messages; avoid Slack MCP's auto-appended tag when possible
## Topic Files (on demand, read when relevant)

Reference docs in the memory directory. Zero tokens until read.
- `01-26-2026-using-bash-mode.md` -- reference material
- `03-05-2026-claude-code-with-chrome.md` -- reference material
- `03-05-2026-installing-the-atlassian-mcp-in-claude-code.md` -- reference material
- `advice-patterns.md` -- reference material
- `advice_lucid-mcp-setup.md` -- reference material
- `agent-dx-patterns.md` -- reference material
- `ai-code-reviewer-project.md` -- when planning AI code review integrations
- `ai-development-tools-use-case-library.md` -- when exploring AI tool use cases or writing prompts
- `ai-pr-summaries.md` -- reference material
- `ai-tools-quickstart.md` -- reference material
- `ai-updates-q4-2025.md` -- reference material
- `apps-eng-onboarding-task-board.md` -- reference material
- `apps-engineering-ai-updates-q4-2025.md` -- reference material
- `apps-engineering-growth-framework.md` -- reference material
- `apps-engineering-pad-skills-assessment-supplement.md` -- reference material
- `apps-engineering-resource-library-formerly-onboarding.md` -- reference material
- `apps-engineering-team.md` -- reference material
- `archived-git-branching-and-pull-request-guidelines.md` -- historical reference for legacy branching rules
- `basis-apprenticeship.md` -- reference material
- `basis-environments-overview.md` -- reference material
- `basis-hack-ai-thon-october-2023.md` -- reference material
- `basis-intern.md` -- reference material
- `basis-platform-monitoring-guide.md` -- reference material
- `basis-recruiting.md` -- reference material
- `claude-code-filesystem.md` -- reference material
- `claude-code-pricing-evaluation-week-of-11-24-2025.md` -- reference material
- `claude-code-pricing.md` -- reference material
- `claude-code-settings-security-incident.md` -- reference material
- `claude-os-details.md` -- reference material
- `claudehub.md` -- when onboarding to Claude Code or finding internal resources
- `claudeos-beta.md` -- reference material
- `claudeos.md` -- reference material
- `code-reviews.md` -- when reviewing PRs or discussing review practices
- `compass-architecture.md` -- reference material
- `compass-roadmap-context.md` -- reference material
- `datadog-compass.md` -- reference material
- `datadog-crash-course.md` -- reference material
- `demo-recording.md` -- reference material
- `early-jira-ticket-criteria-for-new-hires.md` -- reference material
- `feedback_ms365_mcp_broken.md` -- reference material
- `git-fundamentals.md` -- reference material
- `graph-transcript-workflow.md` -- reference material
- `how-to-write-a-self-review-for-developers.md` -- reference material
- `informal-tech-mentorship.md` -- when mentoring or structuring knowledge transfer
- `modular-cognition.md` -- reference material
- `perplexity-integration.md` -- reference material
- `plugin-marketplace.md` -- reference material
- `pr-workflow-patterns.md` -- reference material
- `problem-2-semantic-versioning.md` -- reference material
- `recurring-mistakes.md` -- reference material
- `rubocop-todo-yml-agent-cleanup.md` -- reference material
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
- `scripts/` — Automation: 1-log, 2-distill, 3-promote, 4-sync-confluence, 5-sync-notion, 6-gc, checkpoint, bootstrap
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
- **checkpoint.sh** — pushes live config into claude-os templates. Run via `checkpoint` CLI command.
- **bootstrap.sh** — pulls templates from claude-os into a new project
### Other
- Team wants claude-os published as a branch on existing repo, not standalone
- See `claude-os-details.md` for details (learning loop, checkpoint/bootstrap, shared state, external deps)
- `~/claude-os` is a passive template store. Checkpoint writes to it, bootstrap reads from it.
- Bootstrap only copies repo-level commands; user-level commands (`~/.claude/commands/`) are manual edit only
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
- See `claude-code-filesystem.md` for full details (settings scoping, gitignore behavior, security notes, reference material pointers)
## Default CMM PR Reviewers

Always add these reviewers when creating or updating a CMM pull request:
- brendan.white
- robin.lee
- kyle.bernstein
- nafisa.sarowar
- josh.davison
- patrick.schwisow

Slack channel for CMM PR discussions: `#lavender-tangerine-dev`

## PR Workflow

- See `pr-workflow-patterns.md` for comment style, merge requirements, review patterns, PR list display format

## Basis Apps Org Chart
- See global memory: `~/.claude/memory/basis-apps-org-chart.md` - all teams, members, roles, engineering leads

## Teammate Advice
- See `advice_*.md` files for setup help given to teammates, patterns extracted before archival
- See `advice-patterns.md` for distilled reusable patterns (promoted to MEMORY.md at 3+ occurrences)

## JIRA Integration

- Use JIRA API directly for ticket creation (no browser needed)
- Ticket structure: Overview, Requirements, Acceptance Criteria (artifact-based: doc/code/diagram)
- Formatting: bold for main headings, underlined for subheaders, italic for notes sections

## Lucid MCP

- Connected Lucid MCP server for diagram search, listing, and creation
- Setup/re-add command: `claude mcp add lucid --transport http https://mcp.lucid.app/mcp -s user`
- If "Needs authentication", remove and re-add to trigger fresh OAuth flow
- Diagram workflow: create via MCP, verify in browser, iterate (step-by-step verify-before-create)
- Diagram-to-execution pipeline: Lucidchart diagrams inform JIRA tickets, code, and review acceleration
- Supports precise styling: sizing, colors, shapes, connectors, text formatting across L0/L1/L2 diagram levels

## Slack MCP

- Slack MCP auto-appends "sent using @claude" tag to all messages; no API-level opt-out available
- Workaround: post via Slack API directly or remove tag post-send

## Microsoft Graph / Teams Transcripts

- See `graph-transcript-workflow.md` for full workflow: search, download, parse VTT transcripts via Graph API
- CLI tool: `~/bin/graph-transcript` (search, download, calendar, recent)
- Token: `~/.graph-token` (Graph Explorer, ~24h lifetime)
- Slash command: `/transcript` for interactive search/summarize/action workflow
- Uses OneDrive/SharePoint file search (OnlineMeetings scope blocked by tenant admin)
- **VTT speaker labels can be reversed**: infer correct speakers from conversational context, not raw labels
- **OneDrive "Shared with me" API gap**: items visible in browser but blocked via Graph API; don't waste time retrying programmatic access
- **Graph API org chart blocked**: Directory.Read.All requires IT admin consent. Don't re-attempt without IT approval.

## Atlassian MCP

- Connected community Atlassian MCP server: JIRA, Bitbucket, Confluence (all via single HTTP access token)
- Targets Bitbucket Server (Stash/on-prem), NOT Cloud. Official Atlassian MCP only supports Cloud.
- Shared MCP server repo with one-line install from Claude Code terminal (no git clone needed); re-run to update
- Teammates need their own config with personal credentials; commands using MCP tools fail without the server installed
- Curl-based commands work independently as fallback

## Claude Code Team Distribution

- Starter files in CMM repo: `claude/pro.md` (full Claude Code Pro) and `claude/team.md` (Team Premium plan)
- Distributed to `#lavender-tangerine-dev` with setup instructions for teammates

## Perplexity Integration

- Perplexity Computer treated as a dispatchable node in multi-agent setup
- Browser automation path: chrome MCP to `perplexity.ai/computer/tasks` (no API for Computer product)
- Also available: MCP server (sonar models), Sonar REST API, Agent API (`/v1/agent`)
- See `perplexity-integration.md` for full details, pricing, setup commands

## Multi-Agent Architecture Vision

- Four-layer pipeline: RadarOS (Grok, social/real-time) → ResearchOS (Perplexity, deep research) → CommunicateOS (OpenClaw+GPT) → BuildOS (Claude Code)
- Orchestrator role: sequencer, not controller. Invisible shared ledger concept.
- Architecture doc exported to Downloads folder (2026-03-13)

## MS-365 MCP

- MS-365 MCP device code login flow does NOT work. Never attempt it. See `feedback_ms365_mcp_broken.md`.
- For Teams/Outlook/Calendar, use Graph API directly (`~/.graph-token`), Slack MCP, or browser automation instead.
- Other topic files: `03-05-2026-claude-code-with-chrome.md`, `agent-dx-patterns.md`, `basis-environments-overview.md`, `compass-architecture.md`, `compass-roadmap-context.md`, `demo-recording.md`, `team-values.md`, `team.md`, `advice_lucid-mcp-setup.md`
- `ai-development-tools-use-case-library.md` -- reference material
- `ai-pr-summaries.md` -- reference material
- `ai-tools-quickstart.md` -- reference material
- `modular-cognition.md` -- reference material
- `tips-bash-mode.md` -- reference material
