Record a narrated Compass demo video. Argument: use case description (e.g. `/demo streaming artifact walkthrough`).

## Instructions

### 1. Prompt for voice
Always ask which TTS voice to use (no default, always ask):
- **macOS Daniel** (free, fast, no API key needed)
- **ElevenLabs clone** (higher quality, requires API key)

### 2. Understand the use case
- Read the argument passed to `/demo` to understand what to showcase
- Get the current branch: `git branch --show-current`
- Explore relevant code/diffs to understand the feature: `git diff origin/main...HEAD --stat`
- Read key changed files to understand what the demo should highlight

### 3. Draft a scene plan
Propose a scene manifest for user review. Present it as a readable plan with:

**WARMUP_TURNS** (2-3 turns): Multi-turn conversation that builds context before the main demo.
Each turn has:
- `narration`: voiceover text
- `prompt`: text typed into chat
- `subtitle`: shown on screen during generation

**SCENES** (3-5 scenes): Post-warmup narrated scenes with browser actions.
Each scene has:
- `narration`: voiceover text
- `action`: description of browser actions (clicking artifacts, scrolling, typing follow-ups)

Include whether a `FOLLOW_UP_AFTER_SCENE` is needed (triggers a mid-demo follow-up message).

### 4. Wait for user approval
Do NOT proceed until the user explicitly approves the scene plan. Incorporate any feedback.

### 5. Execute

**Check prerequisites:**
- Verify ffmpeg: `which ffmpeg`. If missing, run `brew install ffmpeg`.
- Verify `frontend/e2e/narrated-demo.ts` exists.
- Verify frontend dev server: `curl -s -o /dev/null -w "%{http_code}" http://localhost:3001`
- Verify orchestrator health: `curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health`
- If either service is down, start `make alldev` in the background and poll both endpoints until they return 200 (timeout after 120s).

**Edit the scene manifest:**
Edit `frontend/e2e/narrated-demo.ts` with the approved WARMUP_TURNS and SCENES arrays.

**Run the recording:**

macOS Daniel:
```bash
cd frontend && npx tsx e2e/narrated-demo.ts --tts macos --macos-voice Daniel --name compass-demo-macos
```

ElevenLabs clone:
```bash
cd frontend && ELEVENLABS_API_KEY=2fe97d0140864f701370850ce07308dfb09f24ffcabed5f0b343ebe141ef0d7d npx tsx e2e/narrated-demo.ts --voice-id qItT3HvEwn8PumhQm6HC --name compass-demo-clone
```

Add `--headed` if the user wants to watch the browser during recording.

**Copy and verify:**
```bash
cp demo-recordings/<name>-narrated.mp4 ~/Downloads/
open ~/Downloads/<name>-narrated.mp4
```

Ask the user if it looks good or needs re-recording.

## Scene writing reference

- **Warmup turns** type a prompt, send it, wait for generation (fast-forwarded at SPEEDUP_FACTOR 10x), then move to the next turn. Narration plays during typing.
- **Scenes** run after warmup. They narrate over browser actions (clicking artifacts, scrolling, typing follow-ups).
- `FOLLOW_UP_AFTER_SCENE` controls which scene triggers a follow-up message (generation is fast-forwarded).
- Use `page.pressSequentially()` with a `delay` for visible typing effects.
- Prefer polling for DOM elements over `page.waitForTimeout()`.
- `BUFFER_MS` (1s) between scenes prevents audio overlap.
- Subtitles are rendered as an in-page overlay, captured by Playwright's video recorder.
- Timing is automatic from audio durations. No manual ms offsets needed.

## Voice references

- macOS preferred voice: Daniel
- ElevenLabs clone voice ID: `qItT3HvEwn8PumhQm6HC`
- ElevenLabs API key: `2fe97d0140864f701370850ce07308dfb09f24ffcabed5f0b343ebe141ef0d7d`

## Key flags

| Flag | Description | Default |
|------|-------------|---------|
| `--tts macos` | Use macOS built-in TTS | `elevenlabs` |
| `--macos-voice <name>` | macOS voice name | `Reed` |
| `--voice-id <id>` | ElevenLabs voice ID | env var |
| `--api-key <key>` | ElevenLabs API key | env var |
| `--name <prefix>` | Output filename prefix | `compass-demo` |
| `--speed <float>` | ElevenLabs speaking speed | `0.7` |
| `--headed` | Show browser window | headless |
