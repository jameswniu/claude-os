#!/bin/bash
# 1-log.sh — Runs every 20 min (test) / 1 hour (prod)
# Reads recent Claude Code session history and appends a summary to logs.md
# Loops over all projects with a MEMORY.md

HISTORY="$HOME/.claude/history.jsonl"
LOG_DIR="$HOME/claude-os/output"

mkdir -p "$LOG_DIR"

# If MEMORY_FILE is set (launchd per-project mode), scope to that project only
if [ -n "$MEMORY_FILE" ] && [ -f "$MEMORY_FILE" ]; then
    MEMORY_FILES="$MEMORY_FILE"
else
    # Manual run: process all projects
    MEMORY_FILES=$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null)
fi
if [ -z "$MEMORY_FILES" ]; then
    echo "$(date): No MEMORY.md files found, skipping" >> "$LOG_DIR/1-log.log"
    exit 0
fi

ERRORS=0

while IFS= read -r MEMORY_FILE; do
    MEMORY_DIR=$(dirname "$MEMORY_FILE")
    SLUG=$(echo "$MEMORY_DIR" | sed 's|.*/projects/||; s|/memory.*||')
    PROJECT_DIR=$(python3 -c "
import json, os
slug = '$SLUG'
with open(os.path.expanduser('~/.claude/history.jsonl')) as f:
    for line in f:
        try:
            proj = json.loads(line.strip()).get('project', '')
            if proj and proj.replace('/', '-').replace('.', '-') == slug:
                print(proj)
                break
        except:
            pass
" 2>/dev/null)
    if [ -z "$PROJECT_DIR" ]; then
        echo "$(date): [$SLUG] Could not resolve project directory, skipping" >> "$LOG_DIR/1-log.log"
        continue
    fi
    LAST_RUN_FILE="$MEMORY_DIR/.last-log-run"

    # Check if there are new sessions since last run
    if [ -f "$LAST_RUN_FILE" ]; then
        LAST_RUN=$(cat "$LAST_RUN_FILE")
    else
        LAST_RUN=0
    fi

    CURRENT_TIME=$(date +%s)
    HISTORY_MOD=$(stat -f %m "$HISTORY" 2>/dev/null || echo 0)

    # Skip if no new sessions since last run
    if [ "$HISTORY_MOD" -le "$LAST_RUN" ]; then
        echo "$(date): [$PROJECT_DIR] No new sessions since last run, skipping" >> "$LOG_DIR/1-log.log"
        continue
    fi

    # Count new session entries since last run
    NEW_ENTRIES=$(python3 -c "
import json, sys
last = int($LAST_RUN)
project = '$PROJECT_DIR'
with open('$HISTORY') as f:
    for line in f:
        try:
            entry = json.loads(line.strip())
            ts = entry.get('timestamp', 0) / 1000
            proj = entry.get('project', '')
            if ts > last and proj == project:
                print(entry.get('display', ''))
        except:
            pass
")

    if [ -z "$NEW_ENTRIES" ]; then
        echo "$(date): [$PROJECT_DIR] No new sessions for this project, skipping" >> "$LOG_DIR/1-log.log"
        echo "$CURRENT_TIME" > "$LAST_RUN_FILE"
        continue
    fi

    echo "$(date): [$PROJECT_DIR] New sessions found, summarizing..." >> "$LOG_DIR/1-log.log"

    # Pre-extract recent logs to avoid agent reading full file (cost cap)
    RECENT_LOGS=$(tail -50 "$MEMORY_DIR/history/logs.md" 2>/dev/null || echo "")

    (
        cd "$PROJECT_DIR" || exit 1
        unset CLAUDECODE

        claude -p "You are a memory logger. Append a new timestamped entry to $MEMORY_DIR/history/logs.md for today's date ($(date +%Y-%m-%d)). If today's date section already exists, append bullet points to it. If not, create a new section.

Here is the end of the existing logs.md for format reference:
$RECENT_LOGS

Recent user messages from this project:
$NEW_ENTRIES

Rules:
- Only log meaningful work (PR reviews, code changes, config updates, new learnings)
- Skip trivial messages (greetings, confirmations)
- Each bullet should be one concise line
- Match the existing format shown above
- Use the Edit tool to append at the end of the file" \
          --allowedTools "Edit" \
          --permission-mode bypassPermissions \
          --max-budget-usd 0.25 \
          < /dev/null
    ) >> "$LOG_DIR/1-log.log" 2>&1

    if [ $? -ne 0 ]; then
        echo "$(date): [$PROJECT_DIR] ERROR: log failed (exit code $?)" >> "$LOG_DIR/1-log.log"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    echo "$CURRENT_TIME" > "$LAST_RUN_FILE"
    echo "$(date): [$PROJECT_DIR] Log complete" >> "$LOG_DIR/1-log.log"

done <<< "$MEMORY_FILES"

if [ "$ERRORS" -gt 0 ]; then
    echo "$(date): Finished with $ERRORS error(s)" >> "$LOG_DIR/1-log.log"
    exit 1
fi
