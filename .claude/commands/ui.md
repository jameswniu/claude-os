UI smoke test a pull request or repo (multi-turn flow)

IMPORTANT: Follow every step below in order. Pause where indicated. Do not skip steps.

## Setup

Format: /ui1 {ticket-number}
Examples:
  /ui1 BP-29577
  /ui1 BP-29836

This command runs a UI smoke test against localhost:3001 for a given branch and records a GIF.
Covers: single-turn chat, multi-turn strategy flow, SSE streaming, persisted state, reconnection, and edge cases.

---

## Step 1: Extension check (PAUSE 1)

Call `tabs_context_mcp` with `createIfEmpty: true`.

If the call fails or returns an error:
- Tell the user: "Claude in Chrome extension is not connected. Install it from the Chrome Web Store, open Chrome, and click Connect in the extension popup."
- STOP. Do not proceed until the user confirms the extension is working.

If it succeeds, continue.

---

## Step 2: Fetch branch and read diff

Run: `git fetch origin`

First check remote branches:
Run: `git branch -r | grep {ticket-number}`

If no remote branch found, check local branches:
Run: `git branch | grep {ticket-number}`

If no branch found anywhere, report "No branch found matching {ticket-number}" and stop.
If multiple branches match, list them and ask which one.

Track whether the branch is remote or local for diff commands below.

Auto-detect the target branch:
- Remote branch: `git merge-base origin/main origin/{branch}`
- Local branch: `git merge-base origin/main {branch}`

Then get the diff:
- Remote: `git diff origin/main...origin/{branch} --stat` and `--name-only`
- Local: `git diff origin/main...{branch} --stat` and `--name-only`

Also read the full diff for key files:
- Remote: `git diff origin/main...origin/{branch} -- {files}`
- Local: `git diff origin/main...{branch} -- {files}`

Focus on: frontend components, hooks, utils, orchestrator SSE/streaming/chat routes, agent worker, and any test files.

---

## Step 3: Categorize changes and plan test scope

Look at the changed files from Step 2. Determine the test profile:

### Profile A: Full multi-turn strategy flow
Trigger: PR touches strategy generation, agent workflow, tool calls, artifact rendering, or chat orchestration.
Run: Steps 4a through 4d (complete two-turn flow with artifact verification).

### Profile B: Chat & SSE focused
Trigger: PR touches SSE, streaming, reconnection, chat history, tool output display, or frontend hooks/utils.
Run: Steps 4a (turn 1 only) + 4b + 4c + 4e (targeted checks from diff).

### Profile C: Quick sanity check
Trigger: PR changes are backend-only, config, tests-only, migrations, CI/CD, Docker, Makefile.
Run: Steps 4a (turn 1 only) + 4b. Confirm the app loads and basic chat works.

### Profile D: Frontend-only (non-chat)
Trigger: PR touches frontend files but not chat flow (e.g., layout, sidebar, settings, navigation).
Run: Steps 4a (turn 1 only) + 4b + manual verification of the specific UI change from the diff.

Tell the user which profile you picked and why. If unclear, ask.

---

## Step 4: Run UI test

### 4a: Send the test prompt and complete the flow

1. Use the blank tab from Step 1 (returned by `tabs_context_mcp`). If all existing tabs have content, create a new tab via `tabs_create_mcp`.
2. Navigate to `http://localhost:3001`
3. Wait for the page to load fully. If it doesn't load within 10 seconds, check:
   - Is the frontend dev server running? (`curl -s -o /dev/null -w "%{http_code}" http://localhost:3001`)
   - If not: tell the user "Frontend dev server not running on localhost:3001. Start it with `make frontend-dev` or `make alldev`." and STOP.
4. Check for console errors on page load via `read_console_messages` with `onlyErrors: true`. Flag any errors.
5. Enable network tracking by calling `read_network_requests` (needed to capture `/history` calls later)
6. Start GIF recording via `gif_creator` with action `start_recording`
7. Take a screenshot to capture the initial state

#### Choose the test prompt

Select a prompt based on the test profile:

**Profile A (full strategy flow):**
```
Create a media strategy named "Coffee Launch Q2" for this brief: Client: Acme Coffee Company | Campaign: Premium Coffee Launch 2024 | Objectives: Achieve 25% brand awareness in target markets within Q2 2024 | Target Audience: Urban professionals, 25-45, household income $75k+ | Budget: $500,000 | Timeline: April 1 - June 30, 2024
```

**Profile B (chat & SSE) or Profile C (sanity check):**
Use a lightweight prompt that triggers at least one tool call without the full strategy generation:
```
Summarize this campaign brief: Client: Acme Coffee Company | Campaign: Premium Coffee Launch 2024 | Budget: $500,000 | Timeline: April 1 - June 30, 2024
```
If the diff suggests a specific feature or flow to exercise, adapt the prompt to trigger that flow instead.

**Profile D (frontend non-chat):**
Use the same lightweight prompt as Profile B/C, then manually navigate to verify the specific UI change from the diff (e.g., open a sidebar, check a settings panel, verify a layout change).

8. Find the chat input using `find` tool (query: "chat input text area")
9. Use `form_input` with the ref to set the chosen message text (avoids newlines triggering premature form submission).

NOTE: Use pipe-delimited single line to avoid newlines submitting the form.
NOTE: `form_input` only fills the textarea value -- it does not submit. You must press Enter (Return key) or click the send button separately to send the message.

10. Submit the message (press Enter or click send)

#### Turn 1: Wait for first response

11. Wait for the first response to stream in. Take periodic screenshots (every 10s). Allow up to 60 seconds.
12. Watch for tool call cards to appear. Do NOT assume specific tool names -- instead, use `find` tool to search for "tool call card" or "tool card" and record whatever tool names actually appear.
13. Once the response completes (send button reappears, stop button gone), take a screenshot capturing all tool cards.
14. Check for console errors via `read_console_messages` with `onlyErrors: true`.

**If Profile B, C, or D: Skip to Step 4b after Turn 1 completes.**

#### Turn 2: Continue the conversation (Profile A only)

15. Find the chat input again using `find` tool
16. Use `form_input` to type: `looks good, proceed`
17. Press Enter to submit
18. The AI will begin a longer generation cycle -- typically involving strategy generation tool calls (60-90 seconds each).

#### Wait for generation to complete

NOTE: The AI may run multiple tool call cycles. The polling loop should wait for ALL cycles to complete (stop button disappears for good), not just the first tool call.

19. Poll every 15 seconds, up to 20 iterations (300s max):
    - Use `find` tool to search for "stop generation button"
    - If NO stop button found, the response is complete -- break out of the loop
    - If stop button IS found, still running -- wait 15 more seconds and repeat
    - Take a screenshot only every 3rd iteration (every ~45s) to conserve GIF frames
20. If after 300 seconds it's still running, take a final screenshot and note the timeout.

#### Verify artifact appeared (Profile A only)

NOTE: The artifact may not appear until after the AI finishes streaming its full text response,
which can be 10-20 seconds AFTER the last tool call completes. After the stop button disappears,
wait an additional 10 seconds before checking for the artifact panel.

21. After the response completes, wait 10 seconds, then use `find` tool to search for "artifact panel" or "strategy" on the right side of the screen.
    - If no artifact panel is visible, scroll down to check if an artifact card appears in the chat
    - If still no artifact, flag: "WARNING: No artifact generated in the full flow"

#### Capture streaming state

NOTE: The "Scroll to bottom" button may not reach newly streamed content.
To navigate, use `find` to locate specific elements (e.g., tool cards by searching "tool card")
and then `scroll_to` with the ref. For scrolling to top, use `scroll` with direction `up` and amount `10`,
repeated as needed until the user's original message is visible.

22. Scroll up to the top of the conversation to capture ALL tool call cards. Use `find` to locate them dynamically -- do not assume fixed tool names.
23. Take a screenshot -- this is the **streaming state**
24. Scroll down to capture the final response and artifact panel (if Profile A), take another screenshot

### 4b: Verify the persisted state (CRITICAL)

The streaming state and the persisted state can diverge. SSE events may include cleaned-up fields (like `display_name`) that the `/history` endpoint does not. After the response completes:

25. Refresh the page (press F5)
26. Wait 5 seconds for the chat history to reload from the `/history` API
27. Take a screenshot. This captures the **persisted state**.
28. Compare the two screenshots (streaming vs persisted). Look for differences in:
    - Tool call card names (prefixes reappearing, formatting changes)
    - Missing or broken tool output cards
    - Duplicate tool outputs (same tool output appearing multiple times)
    - Tool markers leaking into message text (e.g., `<!--tool:...-->` visible in the chat)
    - Missing or broken elements that were present during streaming
    - Layout shifts or rendering differences
    - Artifact panel presence/absence changes

### 4c: Inspect API responses

The app is a SPA and the URL stays at `/`. Extract the chat ID from network requests, not the URL path.

29. Use `read_network_requests` with `urlPattern: "/v1/chat"` to find the chat ID from the history call URL
30. Use `javascript_tool` to fetch the history endpoint directly with the extracted chat ID:
    ```javascript
    fetch('/v1/chat/{chat-id}/history')
      .then(r => r.json())
      .then(data => {
        const msgs = data.messages || [];
        const toolCalls = msgs.flatMap(m => m.tool_calls || []);
        const toolOutputs = msgs.flatMap(m => m.tool_outputs || []);
        return JSON.stringify({
          message_count: msgs.length,
          tool_calls: toolCalls.map(tc => ({ name: tc.name, display_name: tc.display_name })),
          tool_outputs: toolOutputs.map(to => ({ tool_name: to.tool_name, display_name: to.display_name })),
          generation_status: msgs[msgs.length - 1]?.generation_status
        }, null, 2);
      })
    ```
31. Check the raw response for:
    - Are `name` fields using raw prefixed names (e.g., `media_strategies_create_strategy`)?
    - Is `display_name` present? If missing, the frontend has no clean name to show after reload.
    - Do the values match what the UI is rendering?
    - Are there duplicate tool outputs (same tool_name appearing more times than expected)?
    - Is `generation_status` correct? ("completed" not stuck at "generating")

### 4d: UI-specific checks (Profile A and B)

32. If **UI-affecting**: verify the specific changed behavior from the PR diff.
    - Read the relevant changed files from Step 2 to know exactly what to look for.
    - For SSE/streaming changes: verify events arrive correctly during streaming.
    - For tool display changes: verify tool cards render with correct names and content.
    - For reconnection changes: test by refreshing mid-generation if the PR touches reconnection logic.
    - For strip/filter changes: check that markers are not visible in rendered messages.
33. Take a final screenshot of the current (persisted) state
34. Check for console errors one more time via `read_console_messages` with `onlyErrors: true`.

### 4e: Targeted edge case checks (based on diff)

Run these checks ONLY if the PR diff touches the relevant area:

**If PR touches SSE reconnection (`useSSEReconnection`, reconnection hooks):**
- After the chat completes, refresh the page to trigger a reconnection scenario.
- Verify `hasReconnected` state doesn't leak across sessions: navigate to a different session (if possible) and back.
- Check that tool markers are stripped correctly after reconnection.

**If PR touches tool output display (`ChatToolOutput`, `tool_outputs`, `display_name`):**
- Verify tool output cards show clean names (no server prefixes like `media_strategies_`).
- Check that each tool call has exactly one corresponding tool output (no duplicates, no missing).
- Compare streaming tool cards vs persisted tool cards after refresh.

**If PR touches chat history (`ChatHistoryService`, `/history` endpoint):**
- Fetch `/v1/chat/{id}/history` and verify the response structure.
- Check that all fields expected by the frontend are present.
- Verify message ordering is correct.

**If PR touches artifact rendering:**
- Verify the artifact panel appears on the right side.
- Check that artifact content renders correctly (not raw JSON or markdown source).
- Verify artifact title matches expected format.

**If PR touches `generation_status` or error handling:**
- Check that `generation_status` transitions correctly: "generating" -> "completed".
- If testable: simulate a failure scenario and verify status goes to "failed" (not stuck at "generating").

35. Stop GIF recording via `gif_creator` with action `stop_recording`

---

## Step 5: Save artifacts

Artifacts must NOT be committed to the PR branch (they would get merged into main).

1. Export the GIF via `gif_creator` with action `export`, download `true`, filename `{ticket}-ui-test.gif`
2. If issues were found, annotate the page:
   - Use `javascript_tool` to inject red borders and labels on problem elements (e.g., `el.style.border = '3px solid red'` and append a label div with red background)
   - Capture the annotated state via GIF creator (start recording, perform one scroll action for a frame, stop, export with `showClickIndicators: false, showActionLabels: false, showProgressBar: false, showWatermark: false`)
   - Export as `{ticket}-annotated-bug.gif`
3. Handle Downloads filename collisions: check for `{ticket}-ui-test (1).gif` etc. in `~/Downloads/`

### Store artifacts on a git tag (not the PR branch)

4. Create a temporary branch from main, commit artifacts, tag, delete branch:
```bash
git stash  # if needed
git checkout -b {ticket}-ui-test-artifacts origin/main
mkdir -p demo-captures
cp ~/Downloads/{latest-gif-file} demo-captures/{ticket}-ui-test.gif
cp ~/Downloads/{latest-annotated-file} demo-captures/{ticket}-annotated-bug.gif  # if applicable
git add demo-captures/
git commit -m "chore: UI smoke test artifacts for {ticket} (do not merge)"
git tag {ticket}-ui-test-evidence
git push origin {ticket}-ui-test-evidence
git checkout {original-branch}
git branch -D {ticket}-ui-test-artifacts
```

Artifact URLs use tag refs (permanent, won't get merged):
```
https://stash.centro.net/projects/CEN/repos/media-strategy-generator/browse/demo-captures/{file}?at=refs/tags/{ticket}-ui-test-evidence
```

---

## Step 6: Present findings

Present findings to the user. Always include BOTH states:

**Streaming state** (what appeared during SSE):
- What tool names were shown (report the actual names observed, not assumed ones)
- Whether tool cards rendered correctly
- Any issues during streaming
- Console errors (if any)

**Persisted state** (what appeared after page refresh / history reload):
- What tool names are shown now
- Whether anything changed from the streaming state
- Raw API field values from the `/history` response (tool_name, display_name)
- Whether tool outputs are duplicated or missing
- Whether tool markers leak into visible text

**Divergence check:**
- If streaming and persisted states match: "Streaming and persisted states are consistent."
- If they diverge: "BUG: Streaming state shows [X] but persisted state shows [Y]. The /history endpoint returns [raw field values]. Root cause: [explanation]."

**Generation status check:**
- Verify `generation_status` is "completed" (not stuck at "generating").
- If stuck: "BUG: generation_status is stuck at 'generating'. Likely cause: [explanation from diff analysis]."

**If UI-affecting:**
- Also report on the specific PR behavior being tested
- Reference the annotated screenshot in the open browser tab

**If non-UI-affecting and both states are consistent:**
- Report: "Ran smoke test on localhost:3001. Chat renders correctly in both streaming and persisted states. Tool calls display properly, no regressions observed."

Include links to the artifact tag on Bitbucket.

**Test profile used:** State which profile (A/B/C/D) was selected and why.

STOP. Done.

---

## Cleanup

Tags can be deleted when no longer needed:
```bash
git push origin --delete {ticket}-ui-test-evidence
git tag -d {ticket}-ui-test-evidence
```
