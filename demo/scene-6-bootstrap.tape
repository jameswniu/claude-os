# Scene 6: Bootstrap Any Project
# Duration target: ~16 seconds (audio: 14.4s)
# Shows what bootstrap creates

Output scenes/scene-6-bootstrap.mp4

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

Type "echo '=== Bootstrap Any Project ==='"
Enter
Sleep 1s

Type "echo ''"
Enter
Type "echo 'One command sets up any repo:'"
Enter
Type "echo '  cd ~/new-repo && bootstrap'"
Enter
Sleep 2s

Type "echo ''"
Enter
Type "echo 'Installs:'"
Enter
Type "echo '  CLAUDE.md, .claude/CLAUDE.local.md, settings.local.json'"
Enter
Type "echo '  Slash commands, automation scripts, starter memory'"
Enter
Type "echo '  LaunchAgents for scheduled jobs'"
Enter
Sleep 2s

# Show the template
Type "echo ''; echo 'Template structure:'"
Enter
Type "ls ~/claude-os/'<repo-name>'/.claude/scripts/"
Enter
Sleep 3s

Type "echo ''"
Enter
Type "echo 'checkpoint saves changes back. Your conventions travel with you.'"
Enter
Sleep 3s
