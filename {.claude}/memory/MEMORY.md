# Global Memory

## User profiles

## PR Review Process
- Standard order: (1) run tests, (2) /review, (3) /ui. Always follow this sequence.
- If the user jumps ahead (e.g. runs /review before tests), remind them to run tests first. Tests catch real bugs that code review misses.
- Never post a review approval comment before tests have passed.

## PR Titles
- Format: `[TICKET-ID] {exact ticket title}` - always use the Jira/ticket title verbatim, not a rephrased summary or tool/class names
- Example: `[BP-29294] Add MCP Tool: Update Line Item by ID (Dates/Budget/KPIs/etc.)` not `[BP-29294] Add UpdateLineItemTool to MCP server`

## PR Descriptions
- Use three headings: **Problem**, **Fix**, **Tests**. No other format.
- Tests section uses checkboxes (`- [ ]` / `- [x]`). Only check boxes for tests actually run and passed. Never lie about checks.

## Slash Commands
- When editing any slash command, backup the old version as `{name}_yyyymmdd_timestamp.md` before overwriting

## Git
- Never add `Co-Authored-By` trailers to git commits
- Always merge the base branch into the feature branch before creating a PR
- Run dependency install if lock file changed after merging

## Communication
- No em dashes (—) or en dashes (–) in outgoing messages - use regular dashes (-) instead
- No unicode arrows (→, ←, etc.) - use ASCII arrows (->, <-, etc.) instead
- No double dashes (--) in outgoing human communication (PR comments, Slack messages, etc.)
- Exception: em dashes, en dashes, and unicode arrows are fine inside code blocks
- Scope and constrain: only raise real problems with actionable fixes. Don't add "notes," FYI observations, or tangential callouts that invite unnecessary discussion. If it's not worth fixing, don't mention it.
