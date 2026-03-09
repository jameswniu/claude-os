# ClaudeOS (Draft)

Source: (internal URL)

**ClaudeOS Boot Camp**

  * **Duration:** Self-paced, three phases (iterate on each)

  * **Style:** Hands-on configuration + automation setup

  * **Prerequisites:** Claude Code CLI installed, macOS (Phase 3 automation), any OS (Phases 1-2)

3

# 1. Overview

## What Teams Are Asking

Department| Top 3 Pain Points| Evals (Time Saved)  
---|---|---  
**Engineering**|  "Review this 20-file PR for regressions" / "Fix the failing tests in this branch" / "Refactor this service to use the new API pattern"| PR reviews 2-3x faster / Debug-to-fix cycle cut in half / Major time savings on refactors  
**Data & Analytics**| "Debug this data pipeline failure" / "Write a query to reconcile these two datasets" / "Generate tests for this BI transformation"| Significant reduction in triage time / Query generation: hours to minutes / Test scaffolding up to 80% faster  
**Product & Design**| "Draft acceptance criteria from this Jira epic" / "What's the blast radius of removing this field?" / "Summarize what shipped this sprint from the PR list"| First drafts in minutes instead of hours / Impact analysis up to 60% faster / Sprint summaries: nearly instant  
**IT & ProdOps**| "Why is this deployment failing? Here are the logs" / "Generate Terraform for this new service" / "Trace this incident across these three log files"| Incident triage 2-3x faster / IaC generation: hours to minutes / Cross-log investigations significantly shorter  
**Ad Operations**|  "Why is this campaign showing zero impressions?" / "Validate these tag configs against the spec" / "Generate a report comparing these two ad server outputs"| Major reduction in troubleshooting time / Validation up to 70% faster / Report generation: minutes not hours  
**Sales**|  "Draft a technical response to this RFP section" / "Summarize this product update for a client meeting" / "Build a competitive comparison from these feature lists"| RFP drafts 2-3x faster / Summarization: nearly instant / Competitive analysis up to 65% faster  
**Investment & Buying**| "Calculate pacing for this campaign across these channels" / "Flag any budget overages in this media plan" / "Reconcile this billing report against the insertion order"| Pacing calculations: hours to minutes / Budget audits up to 80% faster / Reconciliation significantly faster  
**Integrated Planners**|  "Build a media plan template from this brief" / "Compare reach and frequency across these three scenarios" / "Pull performance benchmarks for this vertical"| Plan drafting up to 60% faster / Scenario comparison 2-3x faster / Research: major time savings  
  
Claude Code can do all of this out of the box. The memory system below makes it do it _consistently_ , with your team's rules, patterns, and conventions baked in.

Research: persistent memory and autonomous learning loops

  * [A Self-Improving Coding Agent (arXiv 2504.15228)](https://arxiv.org/abs/2504.15228) -- Agent autonomously edits its own code, improving SWE-Bench from 17% to 53% through reflection and iterative self-modification

  * [Comprehensive Survey of Self-Evolving AI Agents (arXiv 2508.07407)](https://arxiv.org/abs/2508.07407) -- Defines self-evolution as agents autonomously modifying memory, tools, and prompts to sustain improved performance across tasks

  * [Thoughtworks: AIOps -- What We Learned in 2025](https://www.thoughtworks.com/insights/blog/generative-ai/aiops-what-we-learned-in-2025) -- AIOps performance bounded by context availability; persistent memory is the critical missing piece for autonomous operations

  * [Claude Code Memory System (Anthropic Docs)](https://docs.anthropic.com/en/docs/claude-code/memory) -- Hierarchical persistent memory (CLAUDE.md, auto-memory, project rules) transforms stateless LLM into project-aware agent

  * [Unite.AI: Agentic SRE -- Self-Healing Infrastructure (2026)](https://www.unite.ai/agentic-sre-how-self-healing-infrastructure-is-redefining-enterprise-aiops-in-2026/) -- Closed-loop pipelines that detect, diagnose, and remediate issues with minimal human intervention

  * [Cognitive Infrastructure: AI for Self-Healing Systems (ResearchGate 2025)](https://www.researchgate.net/publication/397127719) -- ML + knowledge graphs reduce downtime 45%, operational costs 30% via continuous self-adaptation

## Three-Phase Overview

Phase| What| Effort| Result  
---|---|---|---  
**1. Static Context**|  Configure four files that load into every Claude Code session| 30 min setup| Claude knows your project's architecture, rules, and conventions from the first message  
**2. Manual Learning Loop**|  Log sessions, distill patterns, promote stable rules| 5 min/day| Claude gets smarter over time as it accumulates your team's patterns  
**3. Automation**|  Scheduled scripts replace the manual loop| 15 min setup| Hands-off: Claude continuously learns without manual intervention  
  
# 2. Quickstart

Phases 1 and 2 require no additional tooling beyond Claude Code itself. Follow the sections below to configure your static context files and start the manual learning loop. Phase 3 automation scripts are distributed separately. The scripts are attached to this page.

**Attached scripts:** The .sh files attached to this page are the learning loop scripts referenced in Phase 3. You need to run them to schedule the launchd plists on Mac. See the Setup section below for details.

1-log.sh, 2-distill.sh, 3-promote.sh, 4-sync-confluence.sh, 5-sync-notion.sh, 5-checkpoint.sh, 6-bootstrap.sh

## Switching Repos

When you `cd` into a new repo and start Claude Code:

File| Carries over?| Why  
---|---|---  
`~/.claude/CLAUDE.md`| Yes| Global file, loads in every project  
`CLAUDE.md`| Yes (if in git)| Comes with the clone  
`.claude/CLAUDE.md`| No| Gitignored, lives only in that repo  
`.claude/settings.local.json`| No| Gitignored, lives only in that repo  
`~/.claude/commands/`| Yes| User-level, available in every project  
`MEMORY.md`, `history/logs.md`, topic files| No| Stored per project path, new repo = empty  
  
To set up a new repo, copy your personal `.claude/CLAUDE.md` and `.claude/settings.local.json` from an existing project, then start Claude Code.

## What's Built-in vs What ClaudeOS Adds

**Claude Code built-in** (official product features):

File| Location| Behavior  
---|---|---  
`CLAUDE.md`| Repo root| Auto-loaded at session start  
`.claude/CLAUDE.md`| Inside repo| Auto-loaded at session start  
`.claude/settings.local.json`| Inside repo| Auto-loaded, client-side only  
`~/.claude/commands/`| Home directory| Indexed at session start, available in every project  
`~/.claude/CLAUDE.md`| Home directory| Global, auto-loaded in every project  
`MEMORY.md`| `~/.claude/projects/{slug}/memory/`| Auto-loaded (first 200 lines)  
  
**ClaudeOS adds** (custom layer on top):

Feature| What it does  
---|---  
`history/logs.md`| Chronological session history (Claude Code only creates MEMORY.md)  
Topic files| On-demand reference files synced from Confluence/Notion  
Learning loop| log (1h) -> distill (24h) -> promote (7d) automation scripts  
Checkpoint| Snapshot and filter workspace files to preserve templates across projects  
  
# 3. Phase 1: Static Context

**Official documentation:**

  * [Settings](https://code.claude.com/docs/en/settings) (configuration scopes, precedence, permission syntax)

  * [Memory](https://code.claude.com/docs/en/memory) (CLAUDE.md files, auto memory, /memory command)

Four files loaded into every Claude Code session automatically.

wide760text

## CLAUDE.md Scope and Precedence

Scope| Location| Purpose| Shared with  
---|---|---|---  
**Managed policy**|  macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`  
Linux/WSL: `/etc/claude-code/CLAUDE.md`| Organization-wide instructions managed by IT/DevOps| All users in organization  
**Project**| `./CLAUDE.md` or `./.claude/CLAUDE.md`| Team-shared instructions for the project| Team members via source control  
**User**| `~/.claude/CLAUDE.md`| Personal preferences for all projects| Just you (all projects)  
**Local**| `./CLAUDE.local.md`| Personal project-specific preferences, not checked into git| Just you (current project)  
  
**Precedence (highest to lowest):**

  1. Managed policy (cannot be overridden)

  2. Command line arguments

  3. Local (`.claude/settings.local.json`)

  4. Project (`.claude/settings.json`)

  5. User (`~/.claude/settings.json`)

## 3.1 Team CLAUDE.md (repo root)

Should already exist in your repo root. If not, create one with build commands, architecture overview, testing requirements, and code style rules.

Run `/init` to generate a starting CLAUDE.md automatically. Claude analyzes your codebase and creates a file with build commands, test instructions, and project conventions it discovers. If a CLAUDE.md already exists, `/init` suggests improvements rather than overwriting.

**Example:**

wide760markdown

### Writing Effective Instructions

CLAUDE.md files are loaded into the context window, consuming tokens alongside your conversation. How you write instructions affects how reliably Claude follows them.

  * **Size:** Target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence. Split using imports or `.claude/rules/` files.

  * **Structure:** Use markdown headers and bullets to group related instructions. Organized sections are easier to follow than dense paragraphs.

  * **Specificity:** Write instructions concrete enough to verify. "Use 2-space indentation" instead of "Format code properly." "Run `npm test` before committing" instead of "Test your changes."

  * **Consistency:** If two rules contradict each other, Claude may pick one arbitrarily. Review periodically to remove outdated or conflicting instructions.

## 3.2 Personal .claude/CLAUDE.md (gitignored)

Create `.claude/CLAUDE.md` for your personal workflow preferences, review style, environment constraints, and behavior rules. This file is gitignored, so only you see it.

Also available: `CLAUDE.local.md` (project root, also gitignored) for per-project personal preferences.

**Example:**

wide760markdown

## 3.3 settings.local.json (client-side, zero tokens)

`.claude/settings.local.json` controls which tool calls auto-approve without prompting. It is **client-side only** and **never sent to the LLM** , so it costs zero tokens. It accumulates automatically as you approve tool calls, or you can edit it directly.

**Example:**

wide760json

### Permission Rule Syntax

Rule| Effect  
---|---  
`Bash`| Matches all Bash commands  
`Bash(npm run *)`| Matches commands starting with `npm run`  
`Read(./.env)`| Matches reading the .env file  
`WebFetch(domain:example.com)`| Matches fetch requests to example.com  
`Edit(./**)`| Matches editing any file (glob pattern)  
  
Rules are evaluated in order: **deny first, then ask, then allow**. The first matching rule wins. `*` matches any single path segment, `**` matches across directory levels.

## 3.4 MEMORY.md (auto-loaded, 200-line limit)

Claude writes to `MEMORY.md` as it learns about your project. Each project gets its own memory directory at `~/.claude/projects/<project>/memory/`. The `<project>` path is derived from the git repository, so all worktrees and subdirectories within the same repo share one auto memory directory.

**The first 200 lines of MEMORY.md are loaded at the start of every conversation.** Content beyond line 200 is not loaded. This 200-line limit applies only to MEMORY.md. CLAUDE.md files are loaded in full regardless of length.

**200-line limit:** Keep MEMORY.md concise. Move detailed notes into separate topic files (see next section). The 200-line cap matters because MEMORY.md is injected into every request.

### Auto Memory

Auto memory lets Claude accumulate knowledge across sessions without you writing anything. Claude saves notes for itself as it works: build commands, debugging insights, architecture notes, code style preferences. Claude decides what is worth remembering based on whether the information would be useful in a future conversation.

Auto memory is on by default. Toggle via `/memory` in a session or set `autoMemoryEnabled: false` in project settings.

### The /memory Command

Run `/memory` to list all CLAUDE.md and rules files loaded in your current session, toggle auto memory on/off, and open the auto memory folder. Select any file to open it in your editor.

When you ask Claude to remember something (e.g., "always use pnpm, not npm"), Claude saves it to auto memory. To add instructions to CLAUDE.md instead, ask Claude directly or edit via `/memory`.

**Example MEMORY.md:**

wide760markdown

## 3.5 Topic Files (on-demand, zero tokens)

Drop markdown files in the memory directory for reference material too large for MEMORY.md: Confluence docs, API specs, runbooks, architecture diagrams, onboarding guides. These are **not auto-loaded** , so they cost **zero tokens** until Claude reads them mid-session.

Add one-line hints in MEMORY.md pointing to `filename.md` so Claude knows they exist and when to read them.

Topic files can be pulled from Confluence via API. Each team's Confluence space requires separate access, so topic files can cross-pull from other teams' spaces when given permission. This makes it easy to build a shared knowledge base across org boundaries without duplicating docs.

## 3.6 .claude/rules/ (path-specific rules)

For larger projects, organize instructions into multiple files using the `.claude/rules/` directory. Rules can be scoped to specific file paths using YAML frontmatter, so they only load into context when Claude works with matching files.

**Directory structure:**

wide760text

**Path-specific rule example:**

wide760yaml

### Glob Patterns

Pattern| Matches  
---|---  
`**/*.ts`| All TypeScript files in any directory  
`src/**/*`| All files under src/ directory  
`*.md`| Markdown files in the project root  
`src/components/*.tsx`| React components in a specific directory  
`src/**/*.{ts,tsx}`| TypeScript and TSX files under src/  
  
Rules without a `paths` field are loaded unconditionally. Path-scoped rules trigger when Claude reads files matching the pattern.

User-level rules in `~/.claude/rules/` apply to every project on your machine. Project rules have higher priority than user rules.

## 3.7 Slash Commands

Custom slash commands are stored as markdown files in `.claude/commands/` (project-level) or `~/.claude/commands/` (user-level, available in every project). Command names and descriptions are indexed at session start (~2% of context window). The full command content only loads when invoked.

**Attached prompts:** The .md prompt files (review.md, ui.md, vid.md) are attached to this page. /ui and /review work on CMM and msg repo (tested). Type `/review ticket#`, **not PR#** , as there may be overlapping numbers.

review.md, ui.md, vid.md

These are starter templates. Personalize them for your team or repo: run a prompt once, let Claude tailor it to your workflow, then ask Claude to update the file once everything fits like a glove.

### /review

Format: `/review {ticket-number}`

Fetches the branch, auto-detects the target branch, runs a full diff and regression scan, then reviews every file line by line. Issues are categorized by type (feature-regression, data-integrity, error-handling, race-condition, security, logic, style) and impact level (HIGH/MEDIUM/LOW).

### /ticket

Format: `/ticket {ticket-content}`

Accepts a ticket (XML, screenshot, copy-paste, any format), extracts the ticket ID and title, creates a branch (`{TICKET_ID}_{snake_cased_title}`), updates from dev/main, and summarizes the requirements.

## 3.8 Imports (@path syntax)

CLAUDE.md files can import additional files using `@path/to/import` syntax. Imported files are expanded and loaded into context at launch. Both relative and absolute paths are allowed. Imported files can recursively import other files, with a **maximum depth of five hops**.

wide760text

The first time Claude Code encounters external imports in a project, it shows an approval dialog listing the files. If you decline, the imports stay disabled.

## 3.9 Verify

Start a new Claude Code session and ask: **" What do you know about this project?"** Claude should reference content from CLAUDE.md, .claude/CLAUDE.md, and MEMORY.md.

# 4. Phase 2: Manual Learning Loop

Add a session log and manually run distill/promote cycles to build up your memory over time. No setup needed beyond creating logs.md. You can manually write to any file at any time.

## Who Does What

Action| Who| When| Target File  
---|---|---|---  
Log sessions| Individual developer| After each session| `logs.md` (personal)  
Distill patterns| Individual developer| End of day| `MEMORY.md` (personal)  
Promote to personal rules| Individual developer| End of week| `.claude/CLAUDE.md` (personal, gitignored)  
Promote to team rules| Team together| End of sprint review| `CLAUDE.md` (shared, checked into git)  
  
The first three steps are personal. The last step is a team activity: during sprint reviews or retros, share patterns that kept coming up across the team and collectively decide which ones belong in the shared CLAUDE.md.

## The Loop

When| Action| Target  
---|---|---  
After each session| Append entry| `logs.md`  
End of day| Distill patterns| `MEMORY.md`  
End of week| Promote stable rules| `.claude/CLAUDE.md`  
End of sprint| Team promotes shared rules| `CLAUDE.md` (git tracked)  
  
## Setup

**1. Add logs.md**

Create `~/.claude/projects/{project}/memory/history/logs.md`:

wide760markdown

**2. Add memory rule** to your personal `.claude/CLAUDE.md`:

wide760markdown

**3. Distill (daily)**

At the end of each day, tell Claude:

wide760text

**4. Promote to personal rules (weekly)**

At the end of each week, tell Claude:

wide760text

**5. Promote to team rules (sprint review)**

During sprint reviews, share friction patterns across the team. If multiple people hit the same issue, add it to the shared CLAUDE.md at the repo root. Example: "Claude keeps trying to use gh CLI." "Same here, three times this sprint." -> Add to CLAUDE.md: `gh CLI is NOT installed. Do not attempt to use it.`

## Tutorials: Three Roles, Three Workflows

Each tutorial follows the same arc: start manual to learn the rhythm, set up automation, then go hands-off.

760Sarah, Backend Engineer (DSP Backend)

Sarah builds REST APIs in Python/FastAPI. She uses Claude Code to generate endpoints, debug stack traces, and write tests.

### Week 1: Manual Iteration

Monday, she asks Claude to generate a new `/api/campaigns/:id/metrics` endpoint. Claude puts validation in the controller instead of the service layer. She logs it manually:

markdown

End of day, she tells Claude to distill. MEMORY.md gets:

markdown

By Friday, the same issue came up 3 more times. She promotes to her personal rules:

markdown

### Week 2: Set Up Automation

She sets up the Phase 3 automation. The log, distill, and promote cycles now run on a schedule.

### Week 3+: Hands-off

The automation handles the loop. Claude no longer puts validation in controllers. When she notices something new mid-session, she still writes it directly to MEMORY.md or .claude/CLAUDE.md.

760Derek, Account Executive (Sales)

Derek responds to RFPs and prepares client-facing materials. He uses Claude Code to draft proposal sections, compare features, and summarize product updates.

### Week 1: Manual Iteration

A client sends an RFP asking about real-time reporting capabilities. Claude writes a generic answer that misses Basis-specific terminology and includes features that don't exist yet. He logs it:

markdown

End of day, he distills to MEMORY.md:

markdown

By Friday, the naming issue came up in two more RFP sections and a client email. He promotes:

markdown

### Week 2+: Automation

Claude now consistently uses correct product names in first drafts. He adds a topic file synced from the product marketing Confluence page so Claude always has the latest feature list.

760Lisa, Ad Operations Manager (Trafficking)

Lisa manages campaign trafficking, tag implementation, and delivery troubleshooting. She uses Claude Code to debug tag configurations, trace delivery issues, and generate QA checklists.

### Week 1: Manual Iteration

A campaign shows zero impressions. Claude uses Google Ad Manager terminology instead of Basis DSP terms and misses the most common cause (timezone mismatch). She logs it:

markdown

End of day, she distills:

markdown

By Friday, the terminology issue appeared twice more. She promotes:

markdown

### Week 2+: Automation

She sets up the Phase 3 automation and adds a topic file from the trafficking team's Confluence runbook. Claude now has the full QA checklist on demand.

## What Good Looks Like

After a few weeks, your `.claude/CLAUDE.md` should contain rules that were earned through repeated experience, not guessed upfront:

wide760text

# 5. Phase 3: Automated Learning Loop

Replace the manual loop with scheduled scripts that run without intervention.

## Architecture

Frequency| Script| Action| Budget| Tools  
---|---|---|---|---  
Every 1 hour| `1-log.sh`| Append new sessions to logs.md| $0.25| Edit only  
Every 24 hours| `2-distill.sh`| Distill logs.md patterns into MEMORY.md| $0.50| Read + Edit  
Every 7 days| `3-promote.sh`| Promote stable patterns to .claude/CLAUDE.md| $0.50| Read + Edit  
Every 24 hours| `4-sync-confluence.sh`| Auto-discover + sync Confluence pages to topic files| Free (REST API)| curl only  
Every 24 hours| `5-sync-notion.sh`| Auto-discover + sync Notion pages to topic files| Free (REST API)| curl only  
  
Scripts 1-3 run headless Claude Code (`claude -p`) to do the reading and writing. Scripts 4-5 sync external pages directly via REST API (no LLM needed).

## Script Details

### 1-log.sh (every 1 hour)

  * Reads `~/.claude/history.jsonl` for recent session entries

  * Tracks last run via `.last-log-run` timestamp file; skips if no new sessions

  * Loops over all projects with a MEMORY.md

  * Resolves project directory from slug using `history.jsonl`

  * Pre-extracts last 50 lines of logs.md to avoid agent reading full file (cost cap)

  * Runs `claude -p` with `--allowedTools "Edit" --max-budget-usd 0.25`

### 2-distill.sh (every 24 hours)

  * Archives entries older than 30 days to `history/archive/YYYY-MM.md`

  * Pre-extracts last 3 days of logs to bound cost

  * Runs `claude -p` with `--allowedTools "Read,Edit" --max-budget-usd 0.50`

  * Instruction: identify NEW patterns, add under appropriate topic section, keep under 200 lines, do NOT modify Topic Files section

### 3-promote.sh (every 7 days)

  * Reads MEMORY.md for patterns that appeared 3+ times or are confirmed across multiple sessions

  * Checks if patterns are already captured as rules in .claude/CLAUDE.md

  * Promotes stable patterns that are NOT yet rules

  * Never removes existing rules

  * Runs `claude -p` with `--allowedTools "Read,Edit" --max-budget-usd 0.50`

### 4-sync-confluence.sh (every 24 hours)

  * **Discovery:** Searches Confluence using queries derived from MEMORY.md and CLAUDE.md content (section headings, bold terms, topic descriptions)

  * Filters results by relevant terms (must match) and exclude terms (must not match)

  * Auto-adds new relevant pages to the Topic Files section of MEMORY.md

  * **Sync:** Scans MEMORY.md for all `(confluence:PAGE_ID)` entries

  * Fetches each page via Confluence REST API, converts HTML to markdown using `html2text`

  * Writes result to memory directory as a topic file

  * Free (REST API only, no LLM)

### 5-sync-notion.sh (every 24 hours)

  * **Discovery:** Searches Notion using queries derived from MEMORY.md and CLAUDE.md content

  * Auto-adds new relevant pages to the Topic Files section of MEMORY.md

  * **Sync:** Scans MEMORY.md for all `(notion:PAGE_ID)` entries

  * Fetches each page's blocks via Notion API, converts blocks to markdown

  * Free (REST API only, no LLM)

## Setup

Phase 3 automation scripts are distributed separately. Setup instructions are included with the scripts.

### Confluence Sync Setup

Get an API token at <https://id.atlassian.com/manage-profile/security/api-tokens> and add credentials:

wide760bash

Load the sync agent:

wide760bash

To manually add a Confluence page, add a line to the Topic Files section of MEMORY.md:

wide760markdown

The page ID is in the Confluence URL (e.g., `1597341723` from `.../pages/1597341723/PageTitle`).

### Notion Sync Setup

Create an internal integration at <https://www.notion.so/my-integrations>.

wide760bash

**Share pages with the integration:** Open each Notion page, click `...` (top right) -> "Connections" -> add your integration name.

wide760bash

### Verify and Monitor

wide760bash

All loaded agents should appear with a `0` exit status. A `-` in the PID column means the script is not currently running (normal between scheduled runs).

Check script output in the logs directory for troubleshooting.

### Schedules

Agent| StartInterval| Frequency  
---|---|---  
`com.claude.memory-log`| 3600| Every 1 hour  
`com.claude.memory-distill`| 86400| Every 24 hours  
`com.claude.memory-sync`| 86400| Every 24 hours  
`com.claude.memory-notion`| 86400| Every 24 hours  
`com.claude.memory-promote`| 604800| Every 7 days  
  
For testing, use 3x speed: 1200 / 28800 / 198720 seconds.

## Checkpoint

After syncing, snapshot your workspace files to preserve templates. Checkpointing filters project-specific values into generic placeholders and merges content across projects. **Accumulate-only merge:** checkpointing never subtracts, only adds. The template grows monotonically as you work across more projects.

## Option B: Cloud (Subject to Approval)

For shared infrastructure that runs even when individual machines are off. Replace `claude -p` in the scripts with direct Claude API calls.

  * **Bitbucket Pipelines:** Scheduled pipelines, already in your toolchain

  * **AWS Lambda + EventBridge:** Serverless, pay-per-invocation

  * **GitHub Actions:** Cron schedules, free tier available

# 6. File Tree

## Your Repo (Phase 1 & 2)

wide760text

# 7. Guardrails & Best Practices

Guardrail| Why  
---|---  
Keep MEMORY.md under 200 lines| Content beyond line 200 is not loaded into context. Move detailed notes to topic files.  
Budget caps on every script| `--max-budget-usd` prevents runaway costs. Default: $0.25 log, $0.50 distill, $0.50 promote.  
Maintain a Recurring Mistakes section in MEMORY.md| Self-corrections compound. Each entry prevents the same mistake in all future sessions.  
Don't over-journal| Only log meaningful work (PR reviews, code changes, new learnings). Skip trivial messages.  
Review .claude/CLAUDE.md periodically| Remove outdated or conflicting rules. Contradicting rules cause Claude to pick arbitrarily.  
Never store artifacts on PR branches| Merges into main. Use orphan git tags or a separate artifacts branch.  
  
# 8. FAQ

760Can I lock my screen?

Yes. launchd agents run as long as you're logged in. Lock screen does not stop them.

760What about sleep?

Sleep pauses launchd jobs. Missed intervals are skipped, not queued. To prevent this, disable system sleep while keeping display sleep: `sudo pmset -a displaysleep 15 sleep 0 disksleep 0`. The display turns off after 15 minutes, but the system stays awake and launchd keeps firing on schedule.

760Does this only work on Mac?

Phase 3 automation (launchd) is macOS only. On Linux, replace the plist files with cron jobs. Phases 1 and 2 (static context and manual loop) work on any OS that runs Claude Code.

760How much does the automation cost?

Each script run is capped with `--max-budget-usd`. Default: $0.25 for log, $0.50 for distill, $0.50 for promote. The Confluence and Notion syncs use no LLM (just curl), so they're free. At production frequency: ~$4/week.

760What if MEMORY.md gets too long?

Keep it under 200 lines. Lines beyond 200 are truncated when loaded into context. Archive old log entries monthly. Move detailed notes to topic files.

760Can multiple projects share the same loop?

Each project gets its own memory directory under `~/.claude/projects/`. The scripts loop over all projects with a MEMORY.md automatically, no need for separate script copies.

760Does MEMORY.md eat tokens every message?

Yes. It's injected into the system prompt at session start and stays in context for every request. That's why the 200-line cap matters. Topic files, by contrast, cost zero tokens until Claude reads them mid-session.

760Does settings.local.json eat tokens?

No. It's client-side only, never sent to the LLM. It only controls which tool calls auto-approve without prompting.

760What are topic files?

Additional markdown files in the memory directory alongside MEMORY.md. They're loaded on demand (zero tokens until read). Use them for Confluence docs, API specs, runbooks, or any reference material too large for MEMORY.md. Add one-line hints in MEMORY.md so Claude knows they exist.

760How do I add a Confluence page as a topic file?

Add a line to the Topic Files section of your MEMORY.md: `- `my-page.md` -- Description `. The page ID is in the Confluence URL. The sync script will fetch it on the next run.

760Can I pull from other teams' Confluence spaces?

Yes, if you have read access. The sync script works with any Confluence space. Request access from the team, then add their page IDs to MEMORY.md.

760How do slash commands work with tokens?

Command names and descriptions are indexed at session start (~2% of context window). The full command content only loads when you invoke it (e.g., `/review`). Having many commands registered costs minimal tokens.

760What's the difference between CLAUDE.md and .claude/CLAUDE.md?

`CLAUDE.md` (repo root) is shared, checked into git, visible to the whole team. `.claude/CLAUDE.md` (gitignored) is personal, only you see it. Use the shared one for team rules, the personal one for your own preferences.

760How can I get the claude-os repo?

DM James on Slack.

# 9. Official Documentation

  * [Settings](https://code.claude.com/docs/en/settings) (configuration scopes, precedence, permission syntax, sandbox)

  * [Memory](https://code.claude.com/docs/en/memory) (CLAUDE.md files, auto memory, .claude/rules/, /memory command)

  * [Skills](https://code.claude.com/docs/en/skills) (repeatable workflows, slash commands)

  * [Common Workflows](https://code.claude.com/docs/en/common-workflows) (practical usage patterns)

  * [Sub-agents](https://code.claude.com/docs/en/sub-agents) (parallel execution, subagent memory)

  * [Permissions](https://code.claude.com/docs/en/permissions) (permission modes, tool-specific rules, sandbox)
