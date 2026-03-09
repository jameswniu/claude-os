# Demo Recording

- Script: `frontend/e2e/narrated-demo.ts`
- Single slash command: `/demo <use case>` (e.g. `/demo streaming artifact walkthrough`)
- Flow: prompt for voice, explore codebase, draft scene plan, wait for approval, execute
- TTS engines: macOS (Daniel voice, free) or ElevenLabs (clone voice, higher quality)
- ElevenLabs clone voice ID: `qItT3HvEwn8PumhQm6HC`
- macOS preferred voice: Daniel
- Key flags: `--tts macos --macos-voice Daniel`, `--voice-id <id>`, `--name <prefix>`, `--headed`
- Architecture: WARMUP_TURNS (multi-turn chat, fast-forwarded) + SCENES (narrated browser actions)
- Generation waits compressed at SPEEDUP_FACTOR (10x). Timing is automatic from audio durations.
- Output: `demo-recordings/<name>-narrated.mp4`
- Known issues: narration can drift to end of video; subtitle sync fragile; Playwright follow-up prompt typing unreliable
- **Subtitle style** (use for ALL video burns): `FontSize=11,FontName=Helvetica Neue,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BackColour=&H80000000,BorderStyle=3,Outline=1,Shadow=0,MarginV=25`
