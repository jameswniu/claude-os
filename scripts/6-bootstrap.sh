#!/bin/bash
# 6-bootstrap.sh — Pull claude-os repo config into a live workspace
# Usage: cd ~/some-repo && bash ~/claude-os/scripts/6-bootstrap.sh

CLAUDE_OS="$HOME/claude-os"
PROJECT=$(pwd)

# Guard: don't run from inside .claude/ or non-repo directories
if [ "$(basename "$PROJECT")" = ".claude" ]; then
    echo "Error: run bootstrap from the project root, not from .claude/"
    exit 1
fi

cd "$CLAUDE_OS" && git pull --ff-only 2>/dev/null
cd "$PROJECT"
EX="$CLAUDE_OS/EXAMPLES"
SLUG=$(echo "$PROJECT" | tr '/.' '-' | sed 's/^//')
MEM="$HOME/.claude/projects/${SLUG}/memory"

echo "Project: $PROJECT"
echo ""

# Phase 1: Sync all files from production EXAMPLES
mkdir -p .claude "$MEM"

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
for FILE in "$EX/memory"/*.md; do
    [ -f "$FILE" ] || continue
    NAME=$(basename "$FILE")
    [ "$NAME" = "MEMORY.md" ] && continue
    [ "$NAME" = "logs.md" ] && continue
    cp "$FILE" "$MEM/$NAME"
    echo "  SYNCED   $NAME"
done

# Add .claude/ to .gitignore if not already there
if [ -f .gitignore ]; then
    grep -q "^\.claude/$" .gitignore || echo ".claude/" >> .gitignore && echo "  UPDATED  .gitignore"
else
    echo ".claude/" > .gitignore && echo "  CREATED  .gitignore"
fi

# Ensure install.sh has run (commands + PATH + pre-push hook)
if ! command -v checkpoint &>/dev/null; then
    bash "$CLAUDE_OS/install.sh"
    export PATH="$HOME/.local/bin:$PATH"
    echo "  INSTALLED commands (bootstrap, checkpoint)"
fi

# Phase 2: Run sync scripts to populate topic files from Confluence/Notion
echo ""
echo "  Syncing topic files..."

CONFLUENCE_COUNT=0
NOTION_COUNT=0

export MEMORY_FILE="$MEM/MEMORY.md"

if [ -n "$CONFLUENCE_EMAIL" ] && [ -n "$CONFLUENCE_TOKEN" ]; then
    if bash "$CLAUDE_OS/scripts/4-sync-confluence.sh"; then
        CONFLUENCE_COUNT=$(grep -c 'confluence:' "$MEM/MEMORY.md" 2>/dev/null || echo 0)
        echo "  SYNCED   Confluence ($CONFLUENCE_COUNT topics)"
    else
        echo "  FAILED   Confluence sync (check ~/claude-os/output/4-sync-confluence.log)"
    fi
else
    echo "  SKIPPED  Confluence (see README for setup)"
fi

if [ -n "$NOTION_TOKEN" ]; then
    if bash "$CLAUDE_OS/scripts/5-sync-notion.sh"; then
        NOTION_COUNT=$(grep -c 'notion:' "$MEM/MEMORY.md" 2>/dev/null || echo 0)
        echo "  SYNCED   Notion ($NOTION_COUNT topics)"
    else
        echo "  FAILED   Notion sync (check ~/claude-os/output/5-sync-notion.log)"
    fi
else
    echo "  SKIPPED  Notion (see README for setup)"
fi

# Phase 3: Set up per-project launchd agents
if [ -z "$SKIP_LAUNCHD" ] && [ -d "$HOME/Library" ]; then
    echo ""
    echo "  Setting up automation..."
    PROJ_NAME=$(basename "$PROJECT")
    LAUNCH_DIR="$HOME/Library/LaunchAgents"
    mkdir -p "$LAUNCH_DIR"

    # Remove old single-project agents (replaced by per-project ones)
    for OLD in com.claude.memory-log com.claude.memory-distill com.claude.memory-promote com.claude.memory-sync com.claude.memory-notion; do
        [ -f "$LAUNCH_DIR/$OLD.plist" ] && launchctl unload "$LAUNCH_DIR/$OLD.plist" 2>/dev/null && rm -f "$LAUNCH_DIR/$OLD.plist"
    done

    generate_plist() {
        local name=$1 script=$2 interval=$3
        local label="com.claude.$PROJ_NAME.$name"
        local plist="$LAUNCH_DIR/$label.plist"

        cat > "$plist" << PEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$label</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>$CLAUDE_OS/scripts/$script</string>
	</array>
	<key>StartInterval</key>
	<integer>$interval</integer>
	<key>StandardOutPath</key>
	<string>$CLAUDE_OS/output/$PROJ_NAME-$name-stdout.log</string>
	<key>StandardErrorPath</key>
	<string>$CLAUDE_OS/output/$PROJ_NAME-$name-stderr.log</string>
	<key>EnvironmentVariables</key>
	<dict>
		<key>PATH</key>
		<string>$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin</string>
		<key>MEMORY_FILE</key>
		<string>$MEM/MEMORY.md</string>
PEOF

        # Include credentials if available
        [ -n "$CONFLUENCE_EMAIL" ] && cat >> "$plist" << PEOF
		<key>CONFLUENCE_EMAIL</key>
		<string>$CONFLUENCE_EMAIL</string>
PEOF
        [ -n "$CONFLUENCE_TOKEN" ] && cat >> "$plist" << PEOF
		<key>CONFLUENCE_TOKEN</key>
		<string>$CONFLUENCE_TOKEN</string>
PEOF
        [ -n "$NOTION_TOKEN" ] && cat >> "$plist" << PEOF
		<key>NOTION_TOKEN</key>
		<string>$NOTION_TOKEN</string>
PEOF

        cat >> "$plist" << 'PEOF'
	</dict>
</dict>
</plist>
PEOF

        launchctl unload "$plist" 2>/dev/null
        launchctl load -w "$plist" 2>/dev/null
        echo "  LOADED   $label"
    }

    generate_plist log              1-log.sh              3600
    generate_plist distill          2-distill.sh          86400
    generate_plist promote          3-promote.sh          604800
    generate_plist sync-confluence  4-sync-confluence.sh  86400
    generate_plist sync-notion      5-sync-notion.sh      86400
fi

echo ""
echo "Done. Start Claude Code and ask: \"What do you know about this project?\""
