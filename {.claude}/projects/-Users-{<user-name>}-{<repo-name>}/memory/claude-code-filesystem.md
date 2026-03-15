---
name: Claude Code File System
description: Detailed file system layout, settings scoping, gitignore behavior, and security notes for Claude Code configuration files
type: reference
---

- `/CLAUDE.md` — Team instructions, checked into git
- `/.claude/` — Partially gitignored (scripts/, logs/, commands/, worktrees/ ignored; settings.json tracked)
- `/.claude/CLAUDE.local.md` — Personal instructions, auto-gitignored by Claude Code (`*.local.*` pattern)
- `/.claude/worktrees/` — Used by EnterWorktree tool for parallel git worktree sessions
- `~/.claude/commands/ticket.md` — /ticket slash command (user-level, available across repos; only user-level command remaining)
- `~/.claude/projects/{project}/memory/MEMORY.md` — This file, auto-loaded
- `~/.claude/projects/{project}/memory/history/logs.md` — Session log, read on demand
- `~/.claude/projects/{project}/memory/*.md` — Topic files, read on demand
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

## Reference Material (in memory directory)
- `03-05-2026-claude-code-with-chrome.md` -- reference material
- `agent-dx-patterns.md` -- reference material
- `basis-environments-overview.md` -- reference material
- `demo-recording.md` -- reference material
- `how-to-write-a-self-review-for-developers.md` -- reference material
- `team-values.md` -- reference material
- `team.md` -- reference material
- `compass-architecture.md` — Compass architecture diagram-to-code mapping (Kyle's 2026-03-11 diagrams, layer-by-layer status)
- `compass-roadmap-context.md` — Compass roadmap context (ownership, priorities, open questions for Kyle)
