---
description: Run edge case testing via browser automation for a ticket
argument_name: ticket
---

# Edge Case Testing

Perform interactive edge case testing for `$ARGUMENTS` using browser automation (Chrome MCP).

## Prerequisites

- Dev servers must be running (`make alldev` or equivalent)
- Chrome browser with Claude extension must be active

## Steps

1. **Read the PR diff** to understand what changed:
   ```bash
   git diff main...HEAD --stat
   git diff main...HEAD
   ```

2. **Identify edge cases** based on the diff:
   - For frontend changes: focus on UI states, error handling, responsive behavior, refresh persistence
   - For backend changes: focus on API error responses, edge input values, concurrent requests
   - For both: focus on the integration points between changed components

3. **Start browser testing** using Chrome MCP tools:
   - Call `mcp__claude-in-chrome__tabs_context_mcp` to get current browser state
   - Navigate to `http://localhost:3001` (standalone) or `http://localhost:3000` (CMM embedded)
   - For each edge case:
     a. Describe what you're about to test
     b. Execute the test steps via browser automation
     c. Take a screenshot of the result
     d. Record PASS/FAIL with explanation

4. **Edge case categories to cover:**
   - **Refresh persistence**: Does state survive page reload?
   - **Empty/null states**: What happens with missing data?
   - **Rapid interactions**: Double-clicks, fast navigation
   - **Browser back/forward**: Does history navigation work?
   - **Error recovery**: What happens when the backend is slow or returns errors?
   - **Boundary values**: Long text, special characters, large files

5. **Report results** as a checklist:
   ```
   Edge Case Results for $ARGUMENTS:
   - [x] PASS: <description>
   - [ ] FAIL: <description> — <what went wrong>
   ```

6. **Store evidence** (screenshots) using the worktree artifact pattern:
   ```bash
   ARTIFACT_DIR=$(mktemp -d)
   if git rev-parse --verify origin/$ARGUMENTS-edge-evidence >/dev/null 2>&1; then
     git worktree add "$ARTIFACT_DIR" origin/$ARGUMENTS-edge-evidence
     cd "$ARTIFACT_DIR"
   else
     git worktree add --detach "$ARTIFACT_DIR"
     cd "$ARTIFACT_DIR"
     git checkout --orphan $ARGUMENTS-edge-evidence
     git rm -rf . 2>/dev/null
   fi
   # copy screenshots here
   git add .
   git commit --no-verify -m "Edge case test evidence for $ARGUMENTS"
   git push --no-verify origin $ARGUMENTS-edge-evidence
   cd -
   git worktree remove "$ARTIFACT_DIR"
   ```

7. **Post findings** to the PR as a comment (after user approval).
