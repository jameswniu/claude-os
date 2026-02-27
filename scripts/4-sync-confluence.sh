#!/bin/bash
# 4-sync-confluence.sh — Runs every 24 hours
# Scans MEMORY.md for (confluence:ID) entries and syncs them to topic files

MEMORY_DIR="/Users/james.niu/.claude/projects/-Users-james-niu-media-strategy-generator/memory"
LOG_DIR="/Users/james.niu/claude-os/output"
CONFLUENCE_BASE="https://basis.atlassian.net/wiki/rest/api/content"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"

mkdir -p "$LOG_DIR"

if [ -z "$CONFLUENCE_EMAIL" ] || [ -z "$CONFLUENCE_TOKEN" ]; then
    echo "$(date): CONFLUENCE_EMAIL or CONFLUENCE_TOKEN not set, skipping" >> "$LOG_DIR/4-sync-confluence.log"
    exit 0
fi

if [ ! -f "$MEMORY_FILE" ]; then
    echo "$(date): MEMORY.md not found at $MEMORY_FILE, skipping" >> "$LOG_DIR/4-sync-confluence.log"
    exit 0
fi

# Parse MEMORY.md for lines matching: `topics/filename.md` — description (confluence:PAGE_ID)
SYNCED=0
FAILED=0

while IFS= read -r LINE; do
    FILENAME=$(echo "$LINE" | sed -n 's/.*`topics\/\([^`]*\)`.*/\1/p')
    PAGE_ID=$(echo "$LINE" | sed -n 's/.*(confluence:\([^)]*\)).*/\1/p')

    if [ -z "$FILENAME" ] || [ -z "$PAGE_ID" ]; then
        continue
    fi

    mkdir -p "$MEMORY_DIR/topics"
    OUTFILE="$MEMORY_DIR/topics/$FILENAME"

    RESULT=$(curl -s -w "\n%{http_code}" -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
        "$CONFLUENCE_BASE/$PAGE_ID?expand=body.storage" \
        -H "Accept: application/json")

    HTTP_CODE=$(echo "$RESULT" | tail -1)
    BODY=$(echo "$RESULT" | sed '$d')

    if [ "$HTTP_CODE" != "200" ]; then
        echo "$(date): FAILED $FILENAME (HTTP $HTTP_CODE)" >> "$LOG_DIR/4-sync-confluence.log"
        FAILED=$((FAILED + 1))
        continue
    fi

    echo "$BODY" | python3 -c "
import sys, json, html2text

data = json.loads(sys.stdin.read())
html = data['body']['storage']['value']
title = data.get('title', 'Untitled')
page_id = '$PAGE_ID'

h = html2text.HTML2Text()
h.body_width = 0
h.ignore_links = False
h.ignore_images = True
h.ignore_emphasis = False

md = h.handle(html)

# Clean up common Confluence macro artifacts
import re
lines = md.split('\n')
clean = []
prev_line = ''
for line in lines:
    stripped = line.strip()
    if re.match(r'^[a-f0-9]{10,}$', stripped):
        continue
    if re.match(r'^none$', stripped):
        continue
    if re.match(r'^note[a-f0-9]+$', stripped):
        continue
    if re.match(r'^:.*:.*#', stripped):
        continue
    if re.match(r'^[\d]+(true|false|default|flat|none)+', stripped):
        continue
    if re.match(r'^:[a-z_]+:\s*$', stripped):
        continue
    line = re.sub(r'\s+[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\s*$', '', line)
    line = re.sub(r'\\\\([*._~])', r'\1', line)
    if stripped and stripped == prev_line:
        continue
    prev_line = stripped
    clean.append(line)

md = '\n'.join(clean)
md = re.sub(r'(complete|not started|in progress|cancelled)\s*(Green|Yellow|Red)', r'\1', md, flags=re.IGNORECASE)
md = re.sub(r'\n{3,}', '\n\n', md)

space_key = data.get('_expandable', {}).get('space', '').split('/')[-1] if '_expandable' in data else ''
source = f'https://basis.atlassian.net/wiki/spaces/{space_key}/pages/{page_id}' if space_key else f'https://basis.atlassian.net/wiki/rest/api/content/{page_id}/view'
print(f'# {title}\n\nSource: {source}\n\n{md}')
" > "$OUTFILE" 2>/dev/null

    if [ $? -eq 0 ]; then
        LINES=$(wc -l < "$OUTFILE")
        echo "$(date): OK $FILENAME ($LINES lines)" >> "$LOG_DIR/4-sync-confluence.log"
        SYNCED=$((SYNCED + 1))
    else
        echo "$(date): FAILED $FILENAME (parse error)" >> "$LOG_DIR/4-sync-confluence.log"
        FAILED=$((FAILED + 1))
    fi
done < <(grep 'confluence:' "$MEMORY_FILE" | grep '`topics/')

echo "$(date): Sync complete. $SYNCED synced, $FAILED failed." >> "$LOG_DIR/4-sync-confluence.log"
