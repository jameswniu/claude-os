# Scene 4: Phase 3 - Hands-Off Automation
# Duration target: ~17 seconds (audio: 14.9s)
# Shows launchd agents and what each does

Output scenes/scene-4-automation.mp4

Set Shell "zsh"
Set FontSize 16
Set Width 1280
Set Height 720
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 30ms
Set WindowBar Colorful

Hide
Type "clear"
Enter
Sleep 500ms
Show

Type "echo '=== Five Scheduled Scripts, Hands-Off ==='"
Enter
Sleep 1s

# Show launchd agents
Type "launchctl list | grep com.claude"
Enter
Sleep 4s

# Show what each one does
Type "echo ''"
Enter
Type "echo '  log        — every hour    — captures session history'"
Enter
Type "echo '  distill    — every 24h     — extracts patterns'"
Enter
Type "echo '  promote    — every 7 days  — promotes patterns to rules'"
Enter
Type "echo '  sync-conf  — every 24h     — pulls Confluence docs'"
Enter
Type "echo '  sync-notion— every 24h     — pulls Notion docs'"
Enter
Sleep 3s

# Show the scripts
Type "echo ''; echo 'All scripts:'"
Enter
Type "ls ~/claude-os/'<repo-name>'/.claude/scripts/"
Enter
Sleep 4s
