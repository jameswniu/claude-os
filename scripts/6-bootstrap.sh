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

# Slash commands (always overwrite with latest)
for FILE in "$EX/.claude/commands"/*.md; do
    [ -f "$FILE" ] || continue
    mkdir -p .claude/commands
    NAME=$(basename "$FILE")
    cp "$FILE" ".claude/commands/$NAME"
    echo "  SYNCED   commands/$NAME"
done

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

# Ensure install.sh has run (aliases + PATH)
if ! command -v checkpoint &>/dev/null; then
    bash "$CLAUDE_OS/install.sh"
    echo "  INSTALLED shell aliases (bootstrap, checkpoint)"
fi

# Phase 2: Run sync scripts to populate topic files from Confluence/Notion
echo ""
echo "  Syncing topic files..."

if [ -n "$CONFLUENCE_EMAIL" ] && [ -n "$CONFLUENCE_TOKEN" ]; then
    if bash "$CLAUDE_OS/scripts/4-sync-confluence.sh"; then
        echo "  SYNCED   Confluence topics"
    else
        echo "  FAILED   Confluence sync (check ~/claude-os/output/4-sync-confluence.log)"
    fi
else
    echo "  SKIPPED  Confluence (set CONFLUENCE_EMAIL + CONFLUENCE_TOKEN in ~/.zshrc)"
fi

if [ -n "$NOTION_TOKEN" ]; then
    if bash "$CLAUDE_OS/scripts/5-sync-notion.sh"; then
        echo "  SYNCED   Notion topics"
    else
        echo "  FAILED   Notion sync (check ~/claude-os/output/5-sync-notion.log)"
    fi
else
    echo "  SKIPPED  Notion (set NOTION_TOKEN in ~/.zshrc)"
fi

echo ""
echo "Done. Start Claude Code and ask: \"What do you know about this project?\""
