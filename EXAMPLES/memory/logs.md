# Session Log

## 2026-02-18 (Day 1 — Getting Started)

- First Claude Code sessions on media-strategy-generator repo
- Began building structured PR review workflow
- Early friction: Claude tried to use `gh` CLI (not installed), had to discover fallback to git + Bitbucket API
- Claude misinterpreted a review request as a PR creation request for BP-29421, had to re-clarify

## 2026-02-19 (Day 2 — PR Review Pipeline Takes Shape)

- Continued iterating on /review slash command
- Reviewed BP-29421 (streaming orchestrator feature, ~21 changed files)
- Discovered need to always fetch remote branch first, not diff against local checkout
- Added PR Review Workflow rules to .claude/CLAUDE.md
- Added Environment Constraints section (no `gh` CLI, use git + curl with Bitbucket REST API)

## 2026-02-20 (Day 3 — Model Version Bump Reviews Begin)

- Started reviewing BP-29836 and related model version bump PRs (Claude 4.5 → 4.6)
- Config-only PRs across YAML env files and eval configs
- Checked consistency of version strings across all config files
- Ran full test suites (1,401+ tests) even for config-only changes
- Flagged pre-existing discrepancies between env files and eval configurations

## 2026-02-21 (Day 4 — Scaling Reviews)

- Multiple BP-29421 review sessions (streaming orchestrator)
- Deep analysis: finally-block cleanup patterns, per-turn marker clearing, edge cases
- Multiple BP-29836 version bump review sessions
- Some sessions timed out mid-output before review was fully delivered
- Added rule: "output the complete review in a single response, do not pause mid-output"

## 2026-02-22 (Day 5 — Continued Reviews)

- Continued BP-29421 and BP-29836 reviews as PRs evolved
- Regression scan script refined (grep for removed functions still referenced elsewhere)
- Friction: regression scans hit node_modules, causing timeouts and false positives
- Claude made unsolicited YAML edit (changed large_model value), user rejected it

## 2026-02-23 (Day 6 — Feature Flag Review)

- Reviewed BP-29476 (feature flags implementation), ~3 sessions
- Multi-step protocol now consistent: fetch, detect target, diff, scan, per-file review, summary
- Claude wrote personal preferences to shared CLAUDE.md instead of .claude/CLAUDE.md, user corrected
- Added no-verdict rule to PR Comment Style section

## 2026-02-24 (Day 7 — Multi-Clauding)

- 7 overlap events detected across 14 sessions (parallel review sessions)
- Continued version bump and feature PR reviews
- Reviewed BP-29420 (streaming orchestrator changes), thorough single-session review

## 2026-02-25 (Day 8 — Pipeline Refinement)

- Further BP-29421 review sessions as PR continued evolving
- Tooling friction: wrong branch checkout, had to verify diffs via remote refs
- Session cut-offs continued to be an issue for longer reviews

## 2026-02-26 (Day 9 — First Insights + Memory System)

### Insights Run #1 (morning)
- 79 sessions analyzed, 315 messages, 4 active days
- 50/50 analyzed sessions classified as code review
- 80% fully achieved, 42/50 likely satisfied
- Top friction: missing `gh` CLI, branch confusion, sessions ending before completion
- Suggestions: custom skills, hooks, headless mode, separate profiles for config vs feature PRs

### Session Work
- Reviewed PR #203 (BP-29291): Documentation-only change to media plan SKILL.md, added workflow steps and exact field names for create_media_plan tool
- Posted PR comment, initially included verdict — violated existing .claude/CLAUDE.md rule on line 14. Edited comment to remove it.
- Learned Bitbucket API comment versioning: PUT with current `version` number, got `CommentOutOfDateException` on first attempt with stale version
- Discovered accidental nested settings file at `.claude/commands/.claude/settings.local.json`, confirmed duplicate, deleted it
- Explored Claude Code file system with user: CLAUDE.md (team), .claude/CLAUDE.md (personal), commands/review.md (skills), settings.local.json (permissions), memory/ (persistence)
- Set up hybrid memory system: MEMORY.md for topic lookup, log.md for chronological record
- User preference: timestamped memory for future learning loop / rolling window
- Wrote Slack message summarizing Claude Code's native context/memory system as a table

### Insights Run #2 (evening)
- 103 sessions analyzed (90 in detail), 417 messages, 193 hours, 6 commits
- 57 PR reviews, 22 version bump reviews, 15 BP-29421 sessions, 5 Bitbucket integration, 6 exploration
- 1,258 Bash, 373 Read, 222 Grep, 45 Edit, 9 Write
- 93% satisfaction, 80% fully achieved
- New suggestions: parallel multi-PR reviews, self-healing review pipeline, expand from review to TDD

### Late Session
- User asked about enforcing test runs when pushing PRs — interest in adding pre-push hooks or CI gates for test execution

### Rollout Planning & GitHub Setup (evening-night)
- Planned two-phase company rollout: (1) Claude, personal Claude, memory, settings.local.json (2a) add log.md, manual learning loop (3) local/cloud setup, automatic loop
- Created Mermaid architecture diagram for Claude OS system (memory, hooks, skills, insights pipeline)
- Set up GitHub repo at github.com/jameswniu for publishing: installed `gh` CLI via Homebrew, authenticated via browser
- Clarified /review always hits local branch/Bitbucket, never personal GitHub
- Polished Mermaid diagrams: straightened arrows, added color variations
- Renamed project to "claude-os" per user preference
- Removed em dashes from documentation per style rules

## 2026-02-27 (Day 10 — Claude OS Automation & Account Questions)

- Q&A session: user asked about Claude headless mode, budget limits, and why nested features are banned in certain contexts
- Discussed switching from company Claude Code account to personal account (billing changes only, same functionality)
- Re-ran claude-os automation scripts 1 through 4 in correct order (log, distill, promote, sync-confluence)
- Troubleshot script execution: user needed step-by-step guidance on running scripts from a separate zsh terminal
- Fixed script issues (likely path or permission errors) and re-ran all 4 automation scripts successfully
- Worked on claude-os repo documentation: reformatted FAQ to show answers below questions, enforced copy-paste boxes only for runnable code (not prose/explanations), audited all markdown files for compliance
- Pushed documentation updates to claude-os repo
- User asked about Claude's identity and AI capabilities
- Debugged automation scripts failing when run from Claude Code terminal: scripts 1-2 completed but script 3 (promote) dropped into interactive bash shell due to `CLAUDECODE` env var triggering nested session detection
- Fixed all 3 scripts (1-log, 2-distill, 3-promote): added `unset CLAUDECODE` before `claude -p` calls
- Bumped script 1 budget from $0.05 to $0.15 (was being exceeded on almost every run)
- Fixed Confluence token placeholder in `com.claude.memory-sync.plist` (was `YOUR_TOKEN_HERE`, replaced with real token)
- Discovered PATH issue in all 4 launchd plists: `claude` lives at `~/.local/bin/claude` but plists only had `/usr/local/bin:/usr/bin:/bin`. Added `~/.local/bin` to PATH in all 4 plists
- Applied `sudo pmset -a displaysleep 15 sleep 0 disksleep 0` to prevent Mac from sleeping (launchd jobs now run 24/7 even with screen locked)

---

## Cumulative Friction Log

| Date | Friction | Resolution |
|------|----------|------------|
| 02-18 | Claude tried to CREATE a PR instead of reviewing one | Re-clarified instructions, built /review command |
| 02-18 | `gh` CLI not installed | Added to .claude/CLAUDE.md Environment Constraints |
| 02-19 | Diffed against local checkout instead of remote branch | Added fetch-first rule to .claude/CLAUDE.md |
| 02-21 | Sessions timed out mid-review output | Added "complete review in single response" rule |
| 02-22 | Regression scan hit node_modules | Need to add exclusion (not yet in CLAUDE.md) |
| 02-22 | Claude made unsolicited YAML edit | User rejected, need "no unsolicited edits" rule |
| 02-23 | Claude wrote prefs to shared CLAUDE.md | User corrected, personal prefs go in .claude/CLAUDE.md |
| 02-23 | Verdict posted in PR comment | Added no-verdict rule to .claude/CLAUDE.md |
| 02-26 | Verdict posted again (this session) | Rule existed but wasn't followed, edited comment |
| 02-26 | Bitbucket comment version stale on update | Learned: must use current `version` number in PUT |
| 02-27 | Scripts fail from Claude Code terminal (CLAUDECODE env var) | Added `unset CLAUDECODE` to scripts 1-3 |
| 02-27 | `claude` not on launchd PATH | Added `~/.local/bin` to PATH in all 4 plists |
| 02-27 | Script 1 budget too low ($0.05) | Bumped to $0.15 |
| 02-27 | Confluence token placeholder in plist | Replaced with real token |
| 02-27 | Mac sleep kills launchd jobs | Applied `pmset sleep 0` to prevent system sleep |
