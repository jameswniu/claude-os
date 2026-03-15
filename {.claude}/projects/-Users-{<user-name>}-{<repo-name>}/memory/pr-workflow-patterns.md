---
name: PR Workflow Patterns
description: PR comment style, merge requirements, review patterns, and thread reply conventions
type: feedback
---

## PR Comment Style

- Always show draft to user before posting (see global memory for full rule)
- Keep comments bite-sized, plain human language
- Only flag issues with one-liner + before/after fix
- No headers, categories, impact labels, regression dumps, or notes sections
- When PR comments reference supporting evidence (GIF recordings, screenshots, artifact tags, etc.), always include direct links to the specific files, not just the parent folder or tag page.
- Scope and constrain: only flag real problems with actionable fixes. Don't add "notes," observations, or FYI callouts that invite bikeshedding. If it's not worth fixing, don't mention it.
- Bitbucket thread reply style: what->how->why sequence for engineer audience, "I built..." opening when describing own work

## PR Merge Requirements

- **CMM**: minimum **2 approvals** to merge (verified from merged PRs: #30765, #30793, #30762, #30738 all merged with exactly 2)
- **MSG**: minimum **1 approval** to merge (verified from merged PRs: #230, #231 merged with just 1 out of 5 reviewers)
- Not all reviewers need to approve. Don't frame unapproved reviewers as "blocking" when the threshold is already met.

## PR Review Patterns

- Standard order: (1) run tests, (2) /review, (3) /ui. If user jumps ahead, remind them to run tests first. Never post approval before tests pass.
- Two PR types: config-only (version bumps, YAML changes) and feature PRs (multi-file, complex)
- Config PRs are low-risk but still get full test suite runs
- Feature PRs often need multiple review sessions as PR evolves
- Tool usage is overwhelmingly read-only: Bash >> Read >> Grep >> Edit >> Write
- `/review <number>` always refers to ticket number (BP-XXXXX), not the PR number
- In review comments, always ask PR author to confirm tests pass before approving merge
- Own PR workflow: show comments before posting, no approval prompt. Verdict in general comment, notes/changes inline.

## PR List Display

- Only show PRs where user is reviewer, with Mergeable/Commented/Approved columns
- See `feedback_pr_list_format.md` for full details
