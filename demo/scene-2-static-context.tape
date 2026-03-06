# Scene 2: Phase 1 - Static Context
# Duration target: ~25 seconds (audio: 23.3s)
# Shows the four files that load into every session

Output scenes/scene-2-static-context.mp4

Set Shell "zsh"
Set FontSize 16
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

# Show the file structure
Type "echo '=== Four files load into every Claude Code session ==='"
Enter
Sleep 1500ms

Type "echo ''"
Enter
Type "echo '1. CLAUDE.md — Team rules (checked into git)'"
Enter
Type "echo '2. .claude/CLAUDE.local.md — Personal rules (gitignored)'"
Enter
Type "echo '3. .claude/settings.local.json — Permission auto-approvals'"
Enter
Type "echo '4. ~/.claude/projects/.../memory/MEMORY.md — Persistent memory'"
Enter
Sleep 2s

# Show team CLAUDE.md
Type "echo ''; echo '━━━ CLAUDE.md (team build commands) ━━━'"
Enter
Type "head -18 CLAUDE.md"
Enter
Sleep 3s

# Show personal rules
Type "echo ''; echo '━━━ .claude/CLAUDE.local.md (personal rules) ━━━'"
Enter
Type "head -15 .claude/CLAUDE.local.md"
Enter
Sleep 3s

# Show memory
Type "echo ''; echo '━━━ MEMORY.md (persistent memory) ━━━'"
Enter
Type "head -25 ~/.claude/projects/-Users-james-niu-media-strategy-generator/memory/MEMORY.md"
Enter
Sleep 4s

# Show topic file count
Type "echo ''; echo '+ 22 topic files auto-synced from Confluence'"
Enter
Type "ls ~/.claude/projects/-Users-james-niu-media-strategy-generator/memory/*.md | xargs -I{} basename {} | head -10"
Enter
Sleep 3s
