# Compass Team Profile

Product: **Compass** (media strategy generator, being renamed from (project-name))
Channel: `#basis-ai-dev` (Slack, private)
Repo: `(PROJECT)/(project-name)` on Bitbucket (internal)
Team size: 7

## Members

### Kyle Bernstein -- Engineering Lead
- Most commits in repo (108+), highest volume contributor
- Drives architectural decisions (repo naming, key management, tiered API keys)
- Handles Anthropic API key rollout (deprecating shared key, moving to personal keys via 1Password, tiered access)
- Works on: frontend (sidebar redesign BP-29661, E2E fixes BP-30025, edge cases BP-29853), Langfuse API (BP-29775), A2A + strategy agent
- Manages budget/procurement: goes through Tropic for paid tools, coordinates with Jonah's department
- Security-conscious: flags unapproved tools (Ollama), enforces approved-tool policy
- Style: direct, fast-moving, bundles fixes together. "please and thank you"

### Julian Selser -- Scrum Master
- Second most commits (100+), runs sprints
- Works on: frontend bugs (session loading BP-29930, new chat sidebar BP-29518), Docker/Helm, E2E tests, GPT integration
- Drives repo split discussion: proposed poll for splitting into Compass, Media Gen Agent, Commons
- Creates tickets for the team (BP-30025), pings people for tasks
- Interested in local LLM options (Ollama, GPU on EKS), security/budget tradeoffs
- Style: casual, asks clarifying questions, "dont stress, its fine", deletes polls and recreates with emojis

### John Richardson -- Onboarding Buddy (for James)
- Third most commits (48+), deep backend/streaming expertise
- Works on: artifact streaming (BP-29420 through BP-29423, phase 1+2), SSE reconnection, progress queue fixes (BP-30004), session state refactor (BP-29981), max_tokens fix (BP-29632)
- Primary architect of the streaming/SSE pipeline and artifact persistence
- Digs into hard bugs: traces through LLM eval issues, docx failures, prompt fiddling
- Style: thorough, investigative. "I thought about auto scrolling but talked myself out of it"

### Mitra (Mitravasu Prakash) -- Evals Lead
- 25 commits, owns evaluation pipeline
- Manages agent_eval configs, model version bumps (Claude 4.5 -> 4.6)
- Mentioned by Kyle as handling personal Anthropic key distribution ("Milad will be sending you all a personal Anthropic key")
- Note: "Milad" in Slack likely refers to Mitra/Mitravasu

### Juan Costamagna -- Developer
- 26+ commits (also commits as "Juan Ignacio Costamagna")
- Works on: artifact navigation fixes (BP-29611), repo renaming (BP-29619, renaming internal references from (project-name) to Compass)
- Explores what needs to change for the rename: Harness, Terraform, pipelines, S3 buckets, DB names
- Style: thorough explorer, creates draft PRs to map out scope

### Robin Lee -- Developer, CMM point person
- 5 commits, focused on media plan features
- Works on: media plan allowlist (BP-29291), media plan workflow documentation, SKILL.md for create_media_plan tool
- Go-to person for CMM (Campaign Management Module) questions and local setup ("ask Robin or Kyle how they get Compass working locally")
- Knows the CMM proxy layer that forwards requests to the orchestrator

### James Niu (you) -- Developer, AI Tooling
- 27+ commits, newest team member (onboarding buddy: John Richardson)
- Focus areas: bug fixes (BP-29577 duplicate tool outputs, BP-29704 Langfuse prompts), model version bumps (BP-29836), UI smoke testing
- AI tooling advocate: Claude Code, claude-os automation, PR review automation, AI code quality/self-healing
- Pushing for: AI council, code quality self-healing/testing hive with Claude, automated E2E with AI
- Connected directly to (project-name) (port 3001) for local dev, not through CMM proxy

## External References

- **Camilo Herrera** -- DevOps/Infra (33 commits, Terraform/instance configs, ASG scaling, health checks). Not in the core dev team of 7.
- **Mike Hoyle** -- 16 commits, appears in Slack sidebar DMs. Contributor but unclear if core team.
- **Jonah** -- Department head, budget authority. Referenced by Kyle for procurement.
- **Cyan** -- Cloud Ops contact for Harness/EKS namespace changes.
- **Akeem Yusuf-Aliyu** -- 2 commits, occasional contributor.

## Team Dynamics

- Kyle sets technical direction, Julian runs process, John is the deep-dive architect
- Active debates: repo split (Compass vs Media Gen Agent vs Commons), rename coordination, local LLM options
- Anthropic API key transition in progress: shared key -> personal keys via 1Password, tiered access levels
- Repo rename from (project-name) to Compass is in progress (Juan leading exploration)
- E2E tests are a shared responsibility but Julian and Kyle push hardest on them
- PRs get reviewed quickly in this team, culture of "please and thank you" and fast turnaround
