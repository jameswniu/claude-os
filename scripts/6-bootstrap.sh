#!/bin/bash
# 6-bootstrap.sh — Pull claude-os repo config into a live workspace
# Usage: cd ~/some-repo && bash ~/claude-os/scripts/6-bootstrap.sh

CLAUDE_OS="$HOME/claude-os"
EX="$CLAUDE_OS/EXAMPLES"
PROJECT=$(pwd)
SLUG=$(echo "$PROJECT" | tr '/.' '-' | sed 's/^//')
MEM="$HOME/.claude/projects/${SLUG}/memory"

echo "Project: $PROJECT"
echo ""

# Phase 1: Static context
mkdir -p .claude "$MEM/topics"

[ ! -f CLAUDE.md ] && cp "$EX/CLAUDE.md" ./CLAUDE.md && echo "  CREATED  CLAUDE.md" || echo "  EXISTS   CLAUDE.md"
[ ! -f .claude/CLAUDE.md ] && cp "$EX/.claude/CLAUDE.md" .claude/CLAUDE.md && echo "  CREATED  .claude/CLAUDE.md" || echo "  EXISTS   .claude/CLAUDE.md"
[ ! -f .claude/settings.local.json ] && cp "$EX/.claude/settings.local.json" .claude/settings.local.json && echo "  CREATED  .claude/settings.local.json" || echo "  EXISTS   .claude/settings.local.json"
[ ! -f "$MEM/MEMORY.md" ] && cp "$EX/memory/MEMORY.md" "$MEM/MEMORY.md" && echo "  CREATED  MEMORY.md" || echo "  EXISTS   MEMORY.md"
[ ! -f "$MEM/logs.md" ] && cp "$EX/memory/logs.md" "$MEM/logs.md" && echo "  CREATED  logs.md" || echo "  EXISTS   logs.md"

# Topic files (always overwrite with latest)
for FILE in "$EX/memory/topics"/*.md; do
    [ -f "$FILE" ] || continue
    NAME=$(basename "$FILE")
    cp "$FILE" "$MEM/topics/$NAME"
    echo "  SYNCED   topics/$NAME"
done

# Add .claude/ to .gitignore if not already there
if [ -f .gitignore ]; then
    grep -q "^\.claude/$" .gitignore || echo ".claude/" >> .gitignore && echo "  UPDATED  .gitignore"
else
    echo ".claude/" > .gitignore && echo "  CREATED  .gitignore"
fi

echo ""
echo "Done. Start Claude Code and ask: \"What do you know about this project?\""
