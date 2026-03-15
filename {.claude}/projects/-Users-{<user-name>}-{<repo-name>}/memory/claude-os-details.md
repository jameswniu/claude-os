---
name: Claude OS Dependency Map
description: Map of how ~/claude-os serves as a passive template store for checkpoint/bootstrap, plus learning loop automation, shared state, and external deps
type: reference
---

# Claude OS Dependency Map (CMM)

Location: `~/claude-os` (GitHub: `jameswniu/claude-os`)

`~/claude-os` is a **passive template store**. It doesn't run anything. Checkpoint writes filtered config/memory into it; bootstrap reads templates from it and seeds new projects.

## Learning Loop (automated, launchd-scheduled)

Scripts at `/Users/james.niu/centro-media-manager/.claude/scripts/`. Data flow:

```
~/.claude/history.jsonl
  -> 1-log.sh (every 1h)     -> history/logs.md
  -> 2-distill.sh (every 24h) -> MEMORY.md (+ overflow early warning if >180 lines)
  -> 3-promote.sh (every 7d)  -> .claude/CLAUDE.local.md
```

External syncs (parallel, also automated):
```
MEMORY.md + CLAUDE.md
  -> 4-sync-confluence.sh (24h) -> discovers pages, writes topic files to memory/
  -> 5-sync-notion.sh (24h)     -> discovers pages, writes topic files to memory/
```

GC (weekly cleanup):
```
memory/*.md + ~/.claude/ configs
  -> 7-gc.sh (every 7d)  -> scores files (0-100), archives <30, flags 30-59 for consolidation
                          -> also enforces line limits: MEMORY.md <200, CLAUDE.md <150
                          -> scans both project-level and user-level configs
                          -> metadata sidecar: memory/.gc-metadata.json
```

15 plists total (5 per project x 3 projects): CMM, MSG, apps_eng_docs. All at `~/Library/LaunchAgents/com.claude.{project}.{name}.plist`.

Plist intervals: log=3600s, distill=86400s, promote=604800s, sync-confluence=86400s, sync-notion=86400s, gc=604800s.

## Checkpoint and Bootstrap (manual utilities)

| Script | What it does | Direction |
|--------|-------------|-----------|
| **5-checkpoint.sh** | Filters live files (strips URLs, replaces project-specific values with placeholders), merges into ~/claude-os/ templates using line-level union. Commits locally. | CMM -> claude-os |
| **6-bootstrap.sh** | Pulls templates from ~/claude-os/ into a new project. Replaces placeholders. Generates launchd plists. Runs install.sh. Also syncs slash commands, scripts, and git hooks. | claude-os -> CMM |

- `chpwd` hook in `~/.zshrc` auto-checkpoints in background when leaving a directory with `.claude/`
- Bootstrap copies repo-level commands only; user-level commands (`~/.claude/commands/`) are manual edit only

## Log Output

Scripts and plists write logs to `~/claude-os/output/` for centralized monitoring. Not a runtime dependency.

## External Dependencies

| Dependency | Used by | Notes |
|-----------|---------|-------|
| `claude` CLI | 1-log, 2-distill, 3-promote | Must be at `~/.local/bin/claude` |
| `python3` | All scripts | Standard `json` module only (except sync-confluence) |
| `html2text` | 4-sync-confluence | `pip3 install --break-system-packages html2text` |
| `CONFLUENCE_EMAIL` + `CONFLUENCE_TOKEN` | 4-sync-confluence | Exit 2 if missing |
| `NOTION_TOKEN` | 5-sync-notion | Exit 2 if missing |
| `git` | 5-checkpoint, 6-bootstrap | For template sync |
| `launchctl` | 6-bootstrap | Generates + loads launchd plists |
| `pmset sleep 0` | System-wide | Keeps Mac awake for launchd jobs |

## Shared State

| Path | Read by | Written by |
|------|---------|------------|
| `~/.claude/history.jsonl` | 1-log | Claude Code |
| `~/.claude/projects/.../memory/MEMORY.md` | 2-distill, 4-sync-confluence, 5-sync-notion | 2-distill, 4-sync-confluence, 5-sync-notion |
| `~/claude-os/output/` | human inspection | Scripts + launchd stderr |
| `~/claude-os/{<repo-name>}/` | 6-bootstrap | 5-checkpoint |

## Key Design Patterns

- **`unset CLAUDECODE`** before `claude -p` calls (avoids nested session error)
- **Line-level merge** in checkpoint (accumulate-only, never deletes template content)
- **30-entry FIFO** for auto-discovered Confluence/Notion pages in MEMORY.md
- **Exit 2** = skip (missing credentials), distinct from exit 1 (failure)
- **Placeholder system**: `{<repo-name>}`, `{<user-name>}` in templates, replaced during bootstrap
- **30-day archival** in 2-distill.sh: moves old log entries to `history/archive/{YYYY-MM}.md`
- **GC metadata sidecar** in `.gc-metadata.json` (not frontmatter, avoids confluence sync conflicts)
- **Advice pattern extraction**: individual advice files have 90-day TTL; "Reusable Pattern" sections get distilled into `advice-patterns.md` before archival

## Other

- Line limits: CLAUDE.md max 150 lines, MEMORY.md max 200 lines; checkpoint must enforce these when syncing
- `tests/test.sh` in claude-os has 53 validation tests (includes 6 CI guards against project-specific content leaking into templates)
- EXAMPLES/ files are templatized (placeholders, no project-specific URLs/tickets/architecture)
- Team wants claude-os published as a branch on existing repo, not standalone
