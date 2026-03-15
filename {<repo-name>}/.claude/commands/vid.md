Record a Playwright video demo of Compass and post it as a PR comment.

## Instructions

1. **Check prerequisites**
   - Verify `localhost:3001` is up (`curl -s -o /dev/null -w "%{http_code}" http://localhost:3001`). If not, run `make alldev` and wait for the frontend to return 200.
   - Ensure `frontend/e2e/record-demo.ts` exists. If missing, recreate it (see script template below).

2. **Understand the ticket context**
   - Identify the ticket number from the current branch name (e.g., `BP-29577` from `BP-29577-demo-capture-test`).
   - Read the relevant code changes on this branch vs main: `git diff origin/main...HEAD`
   - Choose test prompts that exercise the feature being tested. For example:
     - If the ticket is about tool call display, use a prompt that triggers MCP tool calls (strategy creation with a brief).
     - If the ticket is about chat streaming, use a simple conversational prompt.
     - If the ticket is about artifacts, use a prompt that generates an artifact.

3. **Update the recording script**
   - Edit `frontend/e2e/record-demo.ts` with the appropriate `TEST_PROMPT` and DOM selectors to verify the fix.
   - The script should poll for expected UI elements rather than using fixed sleeps.
   - Timeout at 60 seconds max.

4. **Record the demo**
   - Clear old recordings: `rm -f demo-recordings/*.webm demo-recordings/*.png 2>/dev/null`
   - Run: `cd frontend && npx tsx e2e/record-demo.ts`
   - Rename the output to `demo-recordings/compass-demo.webm`
   - Take note of the PASS/FAIL result from the script output.

5. **Store artifacts on a dedicated branch (not the PR branch)**
   Uses `git worktree` so the main working tree and `.claude/` are never touched.
   ```bash
   ARTIFACT_DIR=$(mktemp -d)
   if git rev-parse --verify origin/{ticket}-vid-evidence >/dev/null 2>&1; then
     git worktree add "$ARTIFACT_DIR" origin/{ticket}-vid-evidence
     cd "$ARTIFACT_DIR"
   else
     git worktree add --detach "$ARTIFACT_DIR"
     cd "$ARTIFACT_DIR"
     git checkout --orphan {ticket}-vid-evidence
     git rm -rf . 2>/dev/null
   fi
   cp demo-recordings/compass-demo.webm ./{ticket}-demo.webm
   cp demo-recordings/compass-demo-final.png ./{ticket}-demo-final.png
   git add .
   git commit --no-verify -m "Video demo artifacts for {ticket}"
   git push --no-verify origin {ticket}-vid-evidence
   cd -
   git worktree remove "$ARTIFACT_DIR"
   ```

6. **Post PR comment on Bitbucket**
   - Find the open PR number for this branch via the Bitbucket API.
   - Post a comment with:
     - Title referencing the ticket
     - What was tested (prompt used, what tool calls or UI elements appeared)
     - PASS/FAIL result
     - Direct links to the video and screenshot files on the artifact branch (use `?at=refs/heads/{ticket}-vid-evidence&raw` for download links)
   - Show the comment text to the user for approval before posting.

## Record Script Template

If `frontend/e2e/record-demo.ts` needs to be recreated:

```typescript
import { chromium } from '@playwright/test';
import * as path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const RECORDING_DIR = path.resolve(__dirname, '..', '..', 'demo-recordings');
const BASE_URL = 'http://localhost:3001';
const TIMEOUT_MS = 60_000;
const TEST_PROMPT = '<REPLACE WITH APPROPRIATE PROMPT>';

async function recordDemo() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    recordVideo: { dir: RECORDING_DIR, size: { width: 1280, height: 720 } },
    viewport: { width: 1280, height: 720 },
  });

  const page = await context.newPage();
  const startTime = Date.now();
  const elapsed = () => `${((Date.now() - startTime) / 1000).toFixed(1)}s`;

  await page.goto(BASE_URL);
  await page.waitForLoadState('networkidle');
  console.log(`[${elapsed()}] Page loaded`);
  await page.waitForTimeout(2000);

  const textarea = page.locator('textarea').first();
  await textarea.waitFor({ state: 'visible', timeout: 10_000 });
  await textarea.click();
  await textarea.fill(TEST_PROMPT);
  console.log(`[${elapsed()}] Prompt filled`);
  await page.waitForTimeout(500);

  const sendButton = page.locator('button[type="submit"], .message-actions .Button--primary').first();
  await sendButton.click();
  console.log(`[${elapsed()}] Message sent, waiting for response...`);

  // Poll for expected UI elements here (customize per ticket)
  const pollEnd = startTime + TIMEOUT_MS - 3000;
  while (Date.now() < pollEnd) {
    // Example: check for tool call completion
    const completed = await page.locator('.tool-call-expander').filter({ hasText: '✓' }).count();
    if (completed > 0) {
      console.log(`[${elapsed()}] Response detected`);
      await page.waitForTimeout(3000);
      break;
    }
    await page.waitForTimeout(1000);
  }

  await page.screenshot({ path: path.resolve(RECORDING_DIR, 'compass-demo-final.png') });
  const video = page.video();
  await context.close();
  const videoPath = video ? await video.path() : null;
  await browser.close();
  console.log(`[${elapsed()}] Video saved: ${videoPath ?? RECORDING_DIR}`);
}

recordDemo().catch((err) => { console.error('Recording failed:', err); process.exit(1); });
```
