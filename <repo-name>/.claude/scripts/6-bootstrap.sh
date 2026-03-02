#!/bin/bash
# 6-bootstrap.sh — Pull claude-os repo config into a live workspace
# Usage: cd ~/some-repo && bash ~/claude-os/<repo-name>/.claude/scripts/6-bootstrap.sh

CLAUDE_OS="$HOME/claude-os"
PROJECT=$(pwd)

# Guard: don't run from inside .claude/ or non-repo directories
if [ "$(basename "$PROJECT")" = ".claude" ]; then
    echo "Error: run bootstrap from the project root, not from .claude/"
    exit 1
fi

cd "$CLAUDE_OS" && git pull --ff-only 2>/dev/null
cd "$PROJECT"
REPO_TMPL="$CLAUDE_OS/<repo-name>"
MEM_TMPL="$CLAUDE_OS/.claude/projects/-Users-<user-name>-<repo-name>/memory"
SLUG=$(echo "$PROJECT" | tr '/.' '-' | sed 's/^//')
MEM="$HOME/.claude/projects/${SLUG}/memory"

git_cat() {
    local relpath="${1#$CLAUDE_OS/}"
    git -C "$CLAUDE_OS" show "origin/main:$relpath"
}
git_ls() {
    local relpath="${1#$CLAUDE_OS/}"
    git -C "$CLAUDE_OS" ls-tree --name-only "origin/main" "$relpath/"
}

file_age() {
    local mtime=$(stat -f%m "$1" 2>/dev/null)
    local now=$(date +%s)
    local days=$(( (now - mtime) / 86400 ))
    if [ $days -eq 0 ]; then echo "today"
    elif [ $days -eq 1 ]; then echo "1d ago"
    else echo "${days}d ago"
    fi
}

seed_file() {
    local dest=$1 src=$2 label=$3
    if [ ! -f "$dest" ]; then
        git_cat "$src" > "$dest"
        local size=$(du -h "$dest" | cut -f1 | tr -d ' ')
        echo "  CREATED  $label (copied ${size} from template)"
    else
        echo "  EXISTS   $label (last modified $(file_age "$dest"))"
    fi
}

echo "Project: $PROJECT"
echo ""

# Phase 1: Sync all files from <repo-name> template
mkdir -p .claude "$MEM/history"

seed_file .claude/CLAUDE.md "$REPO_TMPL/.claude/CLAUDE.md" .claude/CLAUDE.md
seed_file .claude/settings.local.json "$REPO_TMPL/.claude/settings.local.json" .claude/settings.local.json
seed_file "$MEM/MEMORY.md" "$MEM_TMPL/MEMORY.md" MEMORY.md
# Migrate old logs.md to history/ subfolder
[ -f "$MEM/logs.md" ] && mv "$MEM/logs.md" "$MEM/history/logs.md" && echo "  MIGRATED logs.md -> history/logs.md"
seed_file "$MEM/history/logs.md" "$MEM_TMPL/history/logs.md" history/logs.md

# Slash commands (always overwrite with latest)
git_ls "$REPO_TMPL/.claude/commands" | while read RELPATH; do
    NAME=$(basename "$RELPATH")
    [[ "$NAME" == *.md ]] || continue
    mkdir -p .claude/commands
    DEST=".claude/commands/$NAME"
    TMPFILE=$(mktemp)
    git_cat "$CLAUDE_OS/$RELPATH" > "$TMPFILE"
    if [ -f "$DEST" ] && cmp -s "$TMPFILE" "$DEST"; then
        echo "  EXISTS   commands/$NAME"
    else
        CHANGED_LINES=0
        [ -f "$DEST" ] && CHANGED_LINES=$(diff "$DEST" "$TMPFILE" | grep -c '^[<>]')
        cp "$TMPFILE" "$DEST"
        if [ "$CHANGED_LINES" -gt 0 ]; then
            echo "  SYNCED   commands/$NAME (updated, $CHANGED_LINES lines changed)"
        else
            echo "  SYNCED   commands/$NAME (new)"
        fi
    fi
    rm -f "$TMPFILE"
done

# Topic files (seed only from origin/main templates, don't overwrite — sync scripts fetch raw content)
git_ls "$MEM_TMPL" | while read RELPATH; do
    NAME=$(basename "$RELPATH")
    [ "$NAME" = "MEMORY.md" ] && continue
    [[ "$NAME" == *.md ]] || continue
    seed_file "$MEM/$NAME" "$MEM_TMPL/$NAME" "$NAME"
done

# Add .claude/ to .gitignore if not already there
if [ -f .gitignore ]; then
    if ! grep -q "^\.claude/$" .gitignore; then
        echo ".claude/" >> .gitignore
        echo "  UPDATED  .gitignore (appended .claude/)"
    else
        echo "  EXISTS   .gitignore (already has .claude/)"
    fi
else
    echo ".claude/" > .gitignore
    echo "  CREATED  .gitignore (with .claude/)"
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
    BEFORE_COUNT=$(grep -c 'confluence:' "$MEM/MEMORY.md" 2>/dev/null || echo 0)
    if bash "$REPO_TMPL/.claude/scripts/4-sync-confluence.sh"; then
        AFTER_COUNT=$(grep -c 'confluence:' "$MEM/MEMORY.md" 2>/dev/null || echo 0)
        NEW_COUNT=$((AFTER_COUNT - BEFORE_COUNT))
        if [ "$NEW_COUNT" -gt 0 ]; then
            echo "  SYNCED   Confluence ($AFTER_COUNT topics, $NEW_COUNT new)"
        else
            echo "  SYNCED   Confluence ($AFTER_COUNT topics)"
        fi
    else
        echo "  FAILED   Confluence sync (check ~/claude-os/output/4-sync-confluence.log)"
    fi
else
    echo "  SKIPPED  Confluence (see README for setup)"
fi

if [ -n "$NOTION_TOKEN" ]; then
    BEFORE_COUNT=$(grep -c 'notion:' "$MEM/MEMORY.md" 2>/dev/null || echo 0)
    if bash "$REPO_TMPL/.claude/scripts/5-sync-notion.sh"; then
        AFTER_COUNT=$(grep -c 'notion:' "$MEM/MEMORY.md" 2>/dev/null || echo 0)
        NEW_COUNT=$((AFTER_COUNT - BEFORE_COUNT))
        if [ "$NEW_COUNT" -gt 0 ]; then
            echo "  SYNCED   Notion ($AFTER_COUNT topics, $NEW_COUNT new)"
        else
            echo "  SYNCED   Notion ($AFTER_COUNT topics)"
        fi
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

    human_interval() {
        local s=$1
        if [ $s -ge 604800 ]; then echo "every $((s/604800))w"
        elif [ $s -ge 86400 ]; then echo "every $((s/86400))d"
        elif [ $s -ge 3600 ]; then echo "every $((s/3600))h"
        else echo "every ${s}s"
        fi
    }

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
		<string>$REPO_TMPL/.claude/scripts/$script</string>
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
        echo "  LOADED   $label ($script, $(human_interval $interval))"
    }

    generate_plist log              1-log.sh              3600
    generate_plist distill          2-distill.sh          86400
    generate_plist promote          3-promote.sh          604800
    generate_plist sync-confluence  4-sync-confluence.sh  86400
    generate_plist sync-notion      5-sync-notion.sh      86400
fi

echo ""
echo "Done. Start Claude Code and ask: \"What do you know about this project?\""
