# Scene 5: Slash Commands
# Duration target: ~20 seconds (audio: 18.4s)
# Shows slash commands and the /review output

Output scenes/scene-5-terminal.mp4

Set Shell "zsh"
Set FontSize 15
Set Width 1280
Set Height 720
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 30ms
Set WindowBar Colorful

Hide
Type "cd ~/media-strategy-generator"
Enter
Sleep 500ms
Type "clear"
Enter
Sleep 500ms
Show

Type "echo '=== Custom Slash Commands ==='"
Enter
Sleep 1s

Type "echo '  /review <ticket>  — Full PR code review'"
Enter
Type "echo '  /ticket <ticket>  — Analyze a Jira ticket'"
Enter
Type "echo '  /demo <use case>  — Record a narrated demo'"
Enter
Type "echo '  /ui <ticket>      — UI smoke test'"
Enter
Sleep 2s

# Show actual review output
Type "echo ''"
Enter
Type "echo '━━━ Output from: /review BP-29577 ━━━'"
Enter
Type "echo ''"
Enter
Type "echo 'Reviewed all changes across backend and frontend.'"
Enter
Type "echo ''"
Enter
Type "echo 'Backend (agent_worker.py, persistence_utils.py):'"
Enter
Type "echo '  delete_tool_outputs_since() is well-scoped.'"
Enter
Type "echo '  Cleanup guarded with try/except.'"
Enter
Type "echo ''"
Enter
Type "echo 'Frontend (stripToolMarkers.ts, useSSEReconnection.ts):'"
Enter
Type "echo '  Marker stripping matches established patterns.'"
Enter
Type "echo '  hasReconnected resets on session switch.'"
Enter
Type "echo ''"
Enter
Type "echo 'Issues found and fixed during review: 2'"
Enter
Type "echo 'Tests: 9 new tests, all passing.'"
Enter
Type "echo ''"
Enter
Type "echo '→ Posted to Bitbucket PR #212. Kyle approved.'"
Enter
Sleep 4s
