# Scene 3: Phase 2 - Learning Loop
# Duration target: ~60 seconds
# Shows the gh CLI mistake → log → pattern → rule progression

Output scenes/scene-3-learning-loop.mp4

Set Shell "zsh"
Set FontSize 16
Set Width 1280
Set Height 720
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 40ms
Set WindowBar Colorful

Hide
Type "cd ~/media-strategy-generator"
Enter
Sleep 500ms
Type "clear"
Enter
Sleep 500ms
Show

Type "echo '=== How Claude Learns From Its Mistakes ==='"
Enter
Sleep 2s

# Step 1: Show the log entries
Type "echo ''"
Enter
Type "echo 'STEP 1: Session logs capture what happened'"
Enter
Type "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'"
Enter
Sleep 1s
Type "grep -A2 'gh.*CLI\\|gh CLI' ~/.claude/projects/-Users-james-niu-media-strategy-generator/memory/history/logs.md | head -20"
Enter
Sleep 6s

# Step 2: Show the MEMORY.md pattern
Type "echo ''"
Enter
Type "echo 'STEP 2: Recurring patterns get added to MEMORY.md'"
Enter
Type "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'"
Enter
Sleep 1s
Type "grep -A1 'gh.*CLI' ~/.claude/projects/-Users-james-niu-media-strategy-generator/memory/MEMORY.md"
Enter
Sleep 5s

# Step 3: Show the permanent rule
Type "echo ''"
Enter
Type "echo 'STEP 3: Confirmed patterns become permanent rules'"
Enter
Type "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'"
Enter
Sleep 1s
Type "grep -B1 -A1 'gh.*CLI\\|gh CLI' .claude/CLAUDE.local.md"
Enter
Sleep 5s

# Summary
Type "echo ''"
Enter
Type "echo 'Day 1: Claude tries gh CLI → fails'"
Enter
Type "echo 'Day 2: Same mistake again → logged'"
Enter
Type "echo 'Day 3: Pattern recognized → rule created'"
Enter
Type "echo 'Day 4+: Claude never makes that mistake again'"
Enter
Sleep 6s
