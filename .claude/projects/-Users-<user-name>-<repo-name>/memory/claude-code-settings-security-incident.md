# Claude Code Settings Security Incident — PR #30710

**Date**: 2026-03-04 (PR created) / 2026-03-05 (responded)
**PR**: (internal URL)
**Ticket**: AEAID-19 (self-assigned by Jon Michalak, no reviewers initially)

## What happened

James merged PR #30694 which added `.claude/` to `.gitignore` as part of the GetLineItemsTool MCP work. Jon Michalak created PR #30710 to undo that change — replacing `.claude/` with `.claude/worktrees/` only. Jon tagged 4 people (Arturo, Brian, Ryan, Ted) publicly before asking James why `.claude/` was gitignored. PR was merged by Jon the same day.

## The PR diff

```diff
- .claude/
+
+ # Ignore Claude worktrees
+ .claude/worktrees/
```

This un-ignores everything in `.claude/` except `worktrees/`, exposing `settings.local.json`, `settings.json`, and `CLAUDE.md` to git tracking.

## Full comment thread

1. **Jon Michalak** (comment 599544): "Hey @james.niu just saw you merged this change. Any reason to ignore the whole `.claude/` directory? I was just going to do `./claude/worktrees` for now and was thinking at some point maybe we'd want to merge a `.claude/settings.json` with allowed commands for CMM or something like that. (I have a `.claude/settings.local.json` file that is already gitignore'd) Any thoughts from others? @arturo.urquiza @brian.mehrman @ryan.morris @ted.price. Totally fine with just declining this PR and ignoring the whole `.claude/` directory for now."
   - Arturo Urquiza thumbsup'd

2. **Ryan Morris** (comment 599550, approved PR): "I vote for just gitignoring the .local.json files too so that we can add repo-specific stuff in .claude/whatever...."
   - Jon thumbsup'd

3. **Brian Mehrman** (comment 599552, approved PR): "I dont think we have enough direction communicated to the team to make choices like this. Ignoring `.local.json` means we are assuming the rest of the team is working in the same manner. If we want to prescribe to the team how to best setup their claude environments so we dont end up with a mixture of setups creating a more complicated pattern we have to support."

4. **Jon Michalak** (comment 599554, reply to Brian): "I'm confused. The `settings.local.json` is already ignored by default."

5. **Ted Price** approved PR (no comment).

6. **Jon merges PR** — same day, before James responds.

7. **Jon DMs James**: "Hey James, just wanted to make you aware of this PR and this comment."

8. **James Niu** (comment 599636): "@Jon Michalak A few questions: Is there context behind the ticket? I see it's self-assigned with no reviewers. What's the pain point in worktrees? PR was already merged before asking for input, was there urgency? Worth noting settings.json and CLAUDE.md are very different scopes. Shared repo CLAUDE.md is AI context, low risk. settings.json controls execution permissions, that's a security surface."

9. **James Niu** (comment 599637): "Hey Jon, 1. You jumped to proposing a change without asking why .claude/ was gitignored in the first place. A shared settings.json with allowed commands is a shared execution policy that auto-applies to every dev who pulls, and nobody gets prompted. That's a security decision that deserves a deliberate team conversation, not a PR comment. 2. .claude/worktrees/ isn't the only thing that needs ignoring. So the surgical ignore isn't as simple as you're suggesting. 3. Tagging 4 people to weigh in on a non-urgent change that nobody asked for is unnecessary overhead. If you had a question about the approach, an initial DM would've been fine. Let's not push shared execution configs without a proper discussion first."

## Timeline (all times CT, 2026-03-04 unless noted)

| Time | Event |
|------|-------|
| 12:55 PM | Jon OPENED PR #30710 |
| 12:59 PM | Ted Price APPROVED (4 min, no comment) |
| 1:02 PM | Brian Mehrman APPROVED (7 min) |
| 1:14 PM | Jon added James as reviewer (19 min after open, after 2 approvals) |
| 1:18 PM | Jon COMMENTED tagging James + 4 others |
| 1:21 PM | Jon edited his comment |
| 1:35 PM | Ryan Morris commented + APPROVED |
| 1:44 PM | Jon force-pushed (rescoped commit) |
| 1:55 PM | Brian commented "not enough direction communicated" |
| 2:03 PM | Jon dismissed Brian ("settings.local.json is already ignored by default") |
| 6:18 PM | Jon MERGED (5h after opening, without James responding) |
| 3/5 3:35 AM | James commented (process/security questions) |
| 3/5 5:00 AM | James edited comment |
| 3/5 5:13 AM | James commented (3-point direct response) |

## Process issues

- Self-assigned ticket with no reviewers initially; got 2 approvals before adding James as reviewer
- Tagged 4 people publicly before asking James (the original author) privately
- Brian raised a valid concern ("I don't think we have enough direction communicated to the team") but was dismissed
- Jon DM'd James after the PR was already merged, not before
- Merged 5 hours after opening without waiting for the original author's input

## Technical misconceptions in the thread

### 1. "Just ignore `.claude/worktrees/`"

Partially correct. Claude Code auto-gitignores `*.local.*` files (`settings.local.json`, `CLAUDE.local.md`) when they're created. So `worktrees/` is the main thing that needs explicit ignoring. However, the bigger issue isn't what needs ignoring — it's what gets EXPOSED: `.claude/settings.json` becomes committable, which is an execution policy file.

### 2. Conflating CLAUDE.md with settings.json

Jon's comment suggests "at some point maybe we'd want to merge a `.claude/settings.json` with allowed commands." This conflates two fundamentally different scopes:

| | CLAUDE.md | settings.json |
|---|---|---|
| **What it is** | AI context / instructions | CLI execution permissions |
| **What it controls** | What Claude knows | What Claude can auto-execute |
| **Risk of sharing** | Low — worst case is bad instructions | High — silently auto-runs commands on every dev's machine |
| **Locations** | Infinite (any subdirectory) | 3 fixed locations only |

### 3. Ryan's suggestion: "just gitignore the .local.json files"

Incomplete. This would allow someone to check in `settings.json` with broad `Bash(*)` permissions that silently apply to every developer who pulls.

### 4. Jon: "settings.local.json is already ignored by default"

Correct. Claude Code auto-gitignores all `.local.*` files in `.claude/` when they're created. Official docs: "Claude Code will configure git to ignore `.claude/settings.local.json` when it is created." This also applies to `CLAUDE.local.md`. Jon was right on this point, and Brian's concern about `.local.json` was already handled by Claude Code. However, this makes the core issue worse: the only file NOT auto-ignored is `settings.json` — the execution policy file — which is exactly what Jon was proposing to share.

## Security analysis: CLAUDE.md vs settings.json

These are two fundamentally different layers of the Claude Code architecture. Treating them as the same thing — or casually proposing to share both — misses the critical distinction.

### The two layers

| | CLAUDE.md (AI orchestration layer) | settings.json (CLI execution layer) |
|---|---|---|
| **What it is** | Markdown instructions Claude reads | JSON config controlling tool permissions |
| **What it controls** | What Claude knows and how it behaves | What commands auto-execute without prompting |
| **Locations** | Infinite — any directory, subdirectories load on demand | 3 fixed locations only (+managed) |
| **Human in the loop** | Always — dev still gets prompted before any command runs | Removed — matching commands execute silently |
| **Bad input impact** | Claude gets bad instructions, but dev can reject every action | Commands fire without consent on every dev machine that pulls |
| **Reversibility** | High — bad instructions produce bad suggestions, dev says no | Low to zero — `rm -rf`, `git push --force`, DB drops execute before you see them |
| **Blast radius of sharing** | One repo's AI context | Every developer's CLI on every machine |
| **Analogy** | Giving someone a briefing doc | Giving someone sudo access to your terminal |

### Why Anthropic locked settings.json to 3 locations

This isn't an accident. Anthropic deliberately restricted where settings.json can live:

- **CLAUDE.md**: any directory, any subdirectory, infinite depth. Because it's context — the worst it can do is give Claude bad instructions, and the dev still approves every action.
- **settings.json**: exactly 3 locations (project, project-local, user) + managed. Because it controls execution. Anthropic does not let you scatter execution policies across subdirectories. You can't put a `src/api/settings.json` that auto-approves `Bash(rm -rf *)` just for that folder.

The location constraint IS the security design. If settings.json were as flexible as CLAUDE.md, any subdirectory could silently escalate execution permissions. Anthropic treats the execution layer as a controlled surface with known, auditable entry points.

This is also why `settings.local.json` is auto-gitignored but `settings.json` is not — Anthropic assumes that if you commit `settings.json`, you're making a deliberate team decision. The auto-gitignore on `.local.*` files is a safety net for personal configs. The absence of auto-gitignore on `settings.json` is by design: it's meant to be reviewable.

### Why settings.json is an execution policy, not a config file

When you add `Bash(bundle exec:*)` to `settings.json`, you're not configuring a preference. You're saying: "Any command starting with `bundle exec` can run on this machine without asking." That's an execution policy.

A shared `.claude/settings.json` checked into git means:
1. Every dev who pulls inherits those execution permissions automatically
2. No prompt, no notification, no consent dialog
3. The human-in-the-loop safety gate is permanently removed for matching commands
4. A single careless PR adding `Bash(*)` gives Claude full shell access on every dev machine

### The irreversibility problem

CLAUDE.md mistakes are reversible. Bad instructions lead to bad suggestions, but the developer still approves or rejects every action. The feedback loop is intact.

settings.json mistakes are not reversible. Once a command auto-executes:
- `git push --force` has already overwritten remote history
- `docker rm` has already destroyed containers
- Database migrations have already run
- There is no "undo prompt" because there was no prompt

This is why execution-layer configs deserve the same review scrutiny as CI/CD pipelines, deploy scripts, and infrastructure-as-code. You wouldn't let someone merge a Jenkinsfile change without review. `settings.json` is the same class of artifact.

### Valid settings locations (3 + managed, verified by testing)

1. `.claude/settings.local.json` — project personal (auto-gitignored by Claude Code)
2. `.claude/settings.json` — project shared (checked into git)
3. `~/.claude/settings.json` — user-level global
4. `/Library/Application Support/ClaudeCode/managed-settings.json` — enterprise (macOS)

**Invalid locations** (confirmed by testing):
- `~/.claude/settings.local.json` — does NOT work
- `./settings.json` (repo root) — does NOT work

### What Claude Code auto-approves regardless of settings

Some read-only commands (`ls`, `echo`, `cat`, `whoami`) auto-approve regardless of the allowlist — they're in Claude Code's built-in safe list. Commands with `$()` substitution always prompt regardless of the allowlist. Everything else is controlled by the settings files.

### Execution-layer permissions should be

- Personal (each dev controls their own risk tolerance)
- Deliberate (opt-in per command, not inherited via git pull)
- Reviewable (if shared, treated as security-sensitive code)

## How our repos are actually set up

### CLAUDE.md lives at repo root, not .claude/

In both `centro-media-manager` and `strategy-media-generator`, the project `CLAUDE.md` is at the repo root (`~/centro-media-manager/CLAUDE.md`), NOT at `.claude/CLAUDE.md` as the official docs suggest as an alternative. This is because `/init` (the Claude Code scaffold command) generates `CLAUDE.md` at the repo root. Devs running `/init` on CMM would have created `./CLAUDE.md`, and that's the convention we've followed.

This means `.claude/CLAUDE.md` in our repos (if it exists) is personal/user-scoped — which is why gitignoring `.claude/` was the right default. There's nothing shared in `.claude/` for our repos. The shared project instructions are at the root.

### Home directory structure

```
~/ is <first name>.<last name>@Basis-XXXXX
~/.claude/CLAUDE.md          — user-level, all projects
~/.claude/settings.json      — user-level settings (model, effort)
~/centro-media-manager/
  CLAUDE.md                  — project-scoped (shared, checked in)
  .claude/settings.local.json — personal permissions (gitignored)
  .claude/CLAUDE.md          — personal project instructions (gitignored)
```

### The .claude/ directory in our repos contains only personal files

Given our setup, `.claude/` contains:
- `settings.local.json` — personal execution permissions
- `CLAUDE.md` — personal project instructions (if used)
- `worktrees/` — auto-generated temp files

None of these should be shared. Gitignoring the entire `.claude/` directory is the correct default for our repos.

### CLAUDE.md as subdirectory constraints

CLAUDE.md files in subdirectories can also constrain Claude's behavior for that part of the codebase. For example, `src/api/CLAUDE.md` could say "never modify migration files from this directory" or "always use jbuilder views, not serializers." These load on demand when Claude reads files in those directories. This is a safe pattern because it's AI context, not execution permissions — the dev still approves every action.

Reference: https://www.linkedin.com/posts/that-aum_dear-developers-heres-how-to-get-the-most-activity-7434101933583515648-xem7

## James's PR comment (posted publicly)

Shared the full context with Jon and the team:

> You are correct for starting from the official documentation https://code.claude.com/docs/en/settings. I appreciate you running this by the team first. The same issue confused me earlier. But in practice, from how we set up strategy-media-generator and centro-media-manager repos:
>
> Home Directory: ~/ is <first name>.<last name>@Basis-XXXXX. ~/.claude/CLAUDE.md is user spec for all projects. No disagreement on this.
>
> After git clone: ~/<repo-name>/CLAUDE.md (NOT ~/<repo-name>/.claude/CLAUDE.md as in official document) has been project scoped. Recommend to put your settings.json in here, verified working in screenshot attached.
>
> Thus: ~/.<repo-name>/.claude/CLAUDE.md is project && user scope if you gitignore .claude. ~/.<repo-name>/.claude/CLAUDE.local.md does nothing to limit further scope. Inserting the *.local*. Is a future problem that has communication and enforcement complications.
>
> Layering on top of how we set up our repos so far, I wrote an articLAUDE (memory) architecture, and with popular demand set up a personalized coordinated learning claude-os: (internal URL)
>
> P.S. Whoever wrote CLAUDE documentation is optimizing for opacity and ease. As engineers, I encourage us to see that the hierarchy CLAUDE is going through is relative, not absolute. I used that CLAUDE.md file as an example of the first file CLAUDE reads as it worms through, now for a flip: Did you know you can use that file above at key nodes to constrain CLAUDE too?

## Resolution

Open task on PR. Awaiting Jon's response to the process and security questions.

## Auto-gitignore behavior (from official docs)

Claude Code automatically configures git to ignore:
- `.claude/settings.local.json` — when created
- `CLAUDE.local.md` — when created
- All `.local.*` files in `.claude/` directory

Files NOT auto-gitignored (intended to be shared):
- `.claude/settings.json` — execution permissions (THE security concern)
- `.claude/CLAUDE.md` — AI context
- `.claude/rules/` — scoped instructions

## Recommended .gitignore for .claude/

**Option A: Ignore everything (James's approach — safest)**
```gitignore
.claude/
```

**Option B: Surgical ignore (if team wants to share CLAUDE.md/rules)**
```gitignore
# Claude Code — generated files
.claude/worktrees/
# settings.local.json is auto-ignored by Claude Code
# settings.json is intentionally NOT ignored — but changes must be reviewed
```

Option B requires a team agreement that changes to `.claude/settings.json` get the same review scrutiny as CI/CD config changes. It should NOT be slipped in through a drive-by PR.
