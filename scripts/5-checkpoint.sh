#!/bin/bash
# 5-checkpoint.sh — Snapshot live config/memory files into claude-os EXAMPLES
# Usage: bash ~/claude-os/scripts/5-checkpoint.sh  (run from any project dir)

CLAUDE_OS="$HOME/claude-os"
EX="$CLAUDE_OS/EXAMPLES"
PROJECT=$(pwd)
SLUG=$(echo "$PROJECT" | tr '/.' '-' | sed 's/^//')
MEM="$HOME/.claude/projects/${SLUG}/memory"

[ ! -d "$MEM" ] && echo "No memory dir for $(basename "$PROJECT")" && exit 1

# Copy files, scrub secrets
mkdir -p "$EX/.claude/commands" "$EX/memory/topics"
cp "$PROJECT/CLAUDE.md" "$EX/" 2>/dev/null
cp "$PROJECT/.claude/CLAUDE.md" "$EX/.claude/" 2>/dev/null
cp "$PROJECT/.claude/commands"/*.md "$EX/.claude/commands/" 2>/dev/null
sed -E 's/ATATT[A-Za-z0-9_=+\/-]{20,}/REDACTED/g' "$PROJECT/.claude/settings.local.json" > "$EX/.claude/settings.local.json" 2>/dev/null
cp "$MEM/MEMORY.md" "$MEM/logs.md" "$EX/memory/" 2>/dev/null
cp "$MEM/topics"/*.md "$EX/memory/topics/" 2>/dev/null

# Commit and push
cd "$CLAUDE_OS"
git add EXAMPLES/
git diff --cached --quiet && echo "No changes." && exit 0
git commit -m "Checkpoint from $(basename "$PROJECT") ($(date +%Y-%m-%d))"
git push
