#!/bin/bash
# 1-log.sh — Runs every 20 min (test) / 1 hour (prod)
# Reads recent Claude Code session history and appends a summary to logs.md

PROJECT_DIR="/Users/james.niu/media-strategy-generator"
MEMORY_DIR="/Users/james.niu/.claude/projects/-Users-james-niu-media-strategy-generator/memory"
HISTORY="/Users/james.niu/.claude/history.jsonl"
LAST_RUN_FILE="$MEMORY_DIR/.last-log-run"
LOG_DIR="/Users/james.niu/claude-os/output"

mkdir -p "$LOG_DIR"

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
    echo "$(date): No new sessions since last run, skipping" >> "$LOG_DIR/1-log.log"
    exit 0
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
    echo "$(date): No new sessions for this project, skipping" >> "$LOG_DIR/1-log.log"
    echo "$CURRENT_TIME" > "$LAST_RUN_FILE"
    exit 0
fi

echo "$(date): New sessions found, summarizing..." >> "$LOG_DIR/1-log.log"

cd "$PROJECT_DIR"

claude -p "You are a memory logger. Read the file at $MEMORY_DIR/logs.md. Then read the recent session history below and append a new timestamped entry to logs.md for today's date ($(date +%Y-%m-%d)). If today's date section already exists, append bullet points to it. If not, create a new section.

Recent user messages from this project:
$NEW_ENTRIES

Rules:
- Only log meaningful work (PR reviews, code changes, config updates, new learnings)
- Skip trivial messages (greetings, confirmations)
- Each bullet should be one concise line
- Use the existing logs.md format" \
  --allowedTools "Read,Edit" \
  --permission-mode bypassPermissions \
  --max-budget-usd 0.05 \
  < /dev/null >> "$LOG_DIR/1-log.log" 2>&1

echo "$CURRENT_TIME" > "$LAST_RUN_FILE"
echo "$(date): Log complete" >> "$LOG_DIR/1-log.log"
