# Claude Code Memory System

A layered context and learning loop system for Claude Code. Execution rolled out in three phases.

## Architecture

### Phase 1 - Static Context

Four files loaded into every Claude Code session automatically.

```mermaid
flowchart TD
    A["📄 CLAUDE.md"]
    B["📄 .claude/CLAUDE.md"]
    C["⚙️ settings.local.json"]
    D["🧠 MEMORY.md"]
    S["🤖 Claude Code Session"]

    A --> S
    B --> S
    C --> S
    D --> S

    style A fill:#4CAF50,color:#fff,stroke:#2E7D32,stroke-width:2px
    style B fill:#5C6BC0,color:#fff,stroke:#303F9F,stroke-width:2px
    style C fill:#FFA726,color:#fff,stroke:#E65100,stroke-width:2px
    style D fill:#EF5350,color:#fff,stroke:#C62828,stroke-width:2px
    style S fill:#212121,color:#fff,stroke:#424242,stroke-width:2px
```

### Phase 2 & 3 - Learning Loop

Session data flows through three stages: log, distill, promote.

```mermaid
flowchart TD
    S["Session"] -- "1h" --> L["log.md"]
    L -- "24h" --> D["MEMORY.md"]
    D -- "7d" --> R[".claude/CLAUDE.md"]
    R -. "next session" .-> S

    style S fill:#212121,color:#fff,stroke:#424242,stroke-width:2px
    style L fill:#78909C,color:#fff,stroke:#455A64,stroke-width:2px
    style D fill:#EF5350,color:#fff,stroke:#C62828,stroke-width:2px
    style R fill:#5C6BC0,color:#fff,stroke:#303F9F,stroke-width:2px

    linkStyle 0 stroke:#78909C,stroke-width:2px
    linkStyle 1 stroke:#EF5350,stroke-width:2px
    linkStyle 2 stroke:#5C6BC0,stroke-width:2px
    linkStyle 3 stroke:#9E9E9E,stroke-width:1px,stroke-dasharray:5
```

### Automation Scripts

```mermaid
flowchart TD
    C["Scheduler"]

    C --> L1["1-log.sh"]
    C --> L2["2-distill.sh"]
    C --> L3["3-promote.sh"]

    L1 --> LOG["log.md"]
    L2 --> MEM["MEMORY.md"]
    L3 --> RUL[".claude/CLAUDE.md"]

    LOG -. reads .-> L2
    MEM -. reads .-> L3

    style C fill:#FF8F00,color:#fff,stroke:#E65100,stroke-width:2px
    style L1 fill:#546E7A,color:#fff,stroke:#37474F,stroke-width:2px
    style L2 fill:#546E7A,color:#fff,stroke:#37474F,stroke-width:2px
    style L3 fill:#546E7A,color:#fff,stroke:#37474F,stroke-width:2px
    style LOG fill:#78909C,color:#fff,stroke:#455A64,stroke-width:2px
    style MEM fill:#EF5350,color:#fff,stroke:#C62828,stroke-width:2px
    style RUL fill:#5C6BC0,color:#fff,stroke:#303F9F,stroke-width:2px

    linkStyle 0,1,2 stroke:#FF8F00,stroke-width:2px
    linkStyle 3,4,5 stroke:#4CAF50,stroke-width:2px
    linkStyle 6,7 stroke:#9E9E9E,stroke-width:1px,stroke-dasharray:5
```

---

## Quick Reference

| File | Location | Purpose | Loaded |
|------|----------|---------|--------|
| `CLAUDE.md` | Repo root | Team rules, build commands, architecture, code style | Auto, every session |
| `.claude/CLAUDE.md` | Repo `.claude/` (gitignored) | Personal workflow preferences, environment constraints | Auto, every session |
| `settings.local.json` | Repo `.claude/` (gitignored) | Tool permissions and auto-approval rules | Auto, every session |
| `MEMORY.md` | `~/.claude/projects/{project}/memory/` | Learned patterns, API notes, project conventions | Auto, every session |
| `log.md` | `~/.claude/projects/{project}/memory/` | Append-only chronological session history | On demand |
| `commands/review.md` | Repo `.claude/commands/` | Custom slash commands (e.g., /review) | When invoked |

Example templates for all files are in the [`examples/`](examples/) directory.

---

## Phase 1: Static Context (Start Here)

Set up the four core files that give Claude persistent context across sessions.

### Files

| File | Scope | Purpose |
|------|-------|---------|
| `/CLAUDE.md` | Team (checked into git) | Build commands, architecture, testing rules, code style |
| `/.claude/CLAUDE.md` | Personal (gitignored) | Your workflow preferences, review style, environment constraints |
| `/.claude/settings.local.json` | Personal (gitignored) | Which commands auto-approve without prompting |
| `~/.claude/projects/{project}/memory/MEMORY.md` | Personal (auto-loaded) | Learned patterns: API endpoints, architecture notes, conventions |

### Setup

1. **Team CLAUDE.md** - should already exist in your repo root. If not, create one with build commands, architecture overview, testing requirements, and code style rules.

2. **Personal CLAUDE.md** - create `/.claude/CLAUDE.md` for your own rules. Examples:
   - PR review workflow preferences
   - Comment style (no em dashes, no verdicts, etc.)
   - Environment constraints (missing CLI tools, API endpoints)
   - Behavior rules (no unsolicited edits, which config file to use for what)

3. **Settings** - `/.claude/settings.local.json` accumulates automatically as you approve tool calls. You can also edit it directly:
   ```json
   {
     "permissions": {
       "allow": [
         "Bash(git:*)",
         "Bash(make:*)",
         "Bash(curl:*)"
       ]
     }
   }
   ```

4. **Memory** - Claude writes to `MEMORY.md` as it learns about your project. Organize by topic for quick lookup. Keep under 200 lines (content beyond line 200 gets truncated in context).

### Verify

Start a new Claude Code session and ask: "What do you know about this project?" It should reference content from all four files.

---

## Phase 2: Manual Learning Loop

Add a session log and manually run distill/promote cycles to build up your memory over time.

### New File

| File | Purpose |
|------|---------|
| `~/.claude/projects/{project}/memory/log.md` | Append-only chronological session history |

### The Loop

```
After each session  →  Append entry to log.md
End of day          →  Distill log.md patterns into MEMORY.md
End of week         →  Promote stable MEMORY.md patterns to .claude/CLAUDE.md
```

### Setup

1. **Add log.md** - create `~/.claude/projects/{project}/memory/log.md`:
   ```markdown
   # Session Log

   ## YYYY-MM-DD

   - What you worked on, what you learned, what went wrong
   ```

2. **Add memory rule** to your personal `/.claude/CLAUDE.md`:
   ```markdown
   ## Memory

   - Hybrid approach: `MEMORY.md` for topical lookup, `log.md` for chronological history.
   - At the end of each session, append a dated entry to `log.md`.
   - Update `MEMORY.md` topics only when stable new patterns are confirmed.
   ```

3. **Distill (daily)** - at the end of each day, tell Claude:
   ```
   Read memory/log.md and memory/MEMORY.md.
   Distill any new patterns from today's logs into MEMORY.md.
   Do not duplicate existing entries.
   ```

4. **Promote (weekly)** - at the end of each week, tell Claude:
   ```
   Read memory/MEMORY.md and .claude/CLAUDE.md.
   If any pattern in MEMORY.md appeared 3+ times and is not yet a rule,
   add it to .claude/CLAUDE.md under the appropriate section.
   ```

### What Good Looks Like

After a few weeks, your `.claude/CLAUDE.md` should contain rules that were earned through repeated experience, not guessed upfront. Example progression:

```
log.md:    "02-18: Claude tried gh CLI, not installed"
log.md:    "02-19: Claude tried gh CLI again"
log.md:    "02-20: Claude tried gh CLI a third time"
           ↓ distill
MEMORY.md: "gh CLI is not installed, recurring friction (3x)"
           ↓ promote
CLAUDE.md: "gh CLI is NOT installed. Do not attempt to use it."
```

---

## Phase 3: Automated Learning Loop

Automate the loop so it runs without manual intervention.

### Architecture

```
Every 1 hour   →  1-log.sh    →  Append new sessions to log.md
Every 24 hours →  2-distill.sh →  Distill log.md patterns into MEMORY.md
Every 7 days   →  3-promote.sh →  Promote stable patterns to .claude/CLAUDE.md
```

Each script runs headless Claude Code (`claude -p`) to do the reading and writing.

### Option A: Local (macOS launchd)

Best for individual use. Runs when your Mac is on, catches up on missed runs after sleep.

**Install:**
```bash
# Clone the repo
git clone https://github.com/jameswniu/claude-os.git ~/scripts/claude-memory
cd ~/scripts/claude-memory && mkdir -p output
chmod +x scripts/*.sh

# Edit scripts: update PROJECT_DIR and MEMORY_DIR paths for your project

# Copy launchd plists
cp launchd/com.claude.memory-*.plist ~/Library/LaunchAgents/

# Load all three
launchctl load ~/Library/LaunchAgents/com.claude.memory-log.plist
launchctl load ~/Library/LaunchAgents/com.claude.memory-distill.plist
launchctl load ~/Library/LaunchAgents/com.claude.memory-promote.plist
```

**Verify:**
```bash
launchctl list | grep com.claude
```

**Monitor:**
```bash
cat ~/scripts/claude-memory/output/*.log
```

**Stop:**
```bash
launchctl unload ~/Library/LaunchAgents/com.claude.memory-*.plist
```

**Schedules (adjustable in plist files):**

| Agent | StartInterval | Frequency |
|-------|--------------|-----------|
| `com.claude.memory-log` | 3600 | Every 1 hour |
| `com.claude.memory-distill` | 86400 | Every 24 hours |
| `com.claude.memory-promote` | 604800 | Every 7 days |

For testing, use 3x speed: 1200 / 28800 / 198720 seconds.

### Option B: Cloud (Recommended for Teams)

Best for shared infrastructure. Runs even when individual machines are off.

**Requirements:**
- A cloud compute environment (AWS Lambda, CI pipeline, or small VM)
- Claude API key (not Claude Code CLI)
- Git access to push memory file changes

**Approach:**
Replace `claude -p` in the scripts with direct Claude API calls via a Python script:

```python
import anthropic

client = anthropic.Anthropic()

# Read memory files from git repo
# Send to Claude API with distill/promote instructions
# Commit updated files back to repo
```

**Suggested platforms:**
- **Bitbucket Pipelines** - scheduled pipelines, already in your toolchain
- **AWS Lambda + EventBridge** - serverless, pay-per-invocation
- **GitHub Actions** - cron schedules, free tier available

---

## File Tree

**Your repo (Phase 1 & 2):**
```
/your-repo/
├── CLAUDE.md                          ← Team rules (git tracked)
├── .claude/
│   ├── CLAUDE.md                      ← Personal rules (gitignored)
│   ├── settings.local.json            ← Permission auto-approvals (gitignored)
│   └── commands/
│       └── review.md                  ← Custom slash commands
│
~/.claude/projects/{project}/memory/
├── MEMORY.md                          ← Topical patterns (auto-loaded)
├── log.md                             ← Session history (read on demand)
└── archive/
    └── YYYY-MM.md                     ← Rolled-off old logs
```

**This repo (Phase 3 automation):**
```
claude-os/
├── README.md
├── scripts/
│   ├── 1-log.sh                       ← Append new sessions to log.md
│   ├── 2-distill.sh                   ← Distill log patterns into MEMORY.md
│   └── 3-promote.sh                   ← Promote stable patterns to CLAUDE.md
├── launchd/
│   ├── com.claude.memory-log.plist    ← Every 1 hour
│   ├── com.claude.memory-distill.plist← Every 24 hours
│   └── com.claude.memory-promote.plist← Every 7 days
├── tests/
│   └── test.sh                        ← 37 validation checks
├── .github/
│   └── workflows/
│       └── test.yml                   ← CI on push and PR
└── output/                            ← Script execution logs (gitignored)
```

---

## FAQ

**Can I lock my screen?**
Yes. launchd agents run as long as you're logged in. Lock screen does not stop them.

**What about sleep?**
launchd catches up on missed runs when the Mac wakes. No data is lost.

**How much does the automation cost?**
Each script run is capped with `--max-budget-usd`. Default: $0.05 for log, $0.10 for distill, $0.10 for promote. At production frequency: ~$2.50/week.

**What if MEMORY.md gets too long?**
Keep it under 200 lines. Lines beyond 200 are truncated when loaded into context. Archive old log entries monthly.

**Can multiple projects share the same loop?**
Each project gets its own memory directory under `~/.claude/projects/`. You'd need separate script copies (or parameterize PROJECT_DIR) per project.
