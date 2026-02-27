#!/bin/bash
# 5-sync-notion.sh — Runs every 24 hours
# 1. Auto-discovers new relevant Notion pages and adds them to MEMORY.md
# 2. Syncs all (notion:ID) entries from MEMORY.md to topic files

LOG_DIR="$HOME/claude-os/output"
NOTION_API="https://api.notion.com/v1"

# Auto-detect: find the first MEMORY.md (prefer one with notion: entries, fallback to any)
MEMORY_FILE=$(grep -rl 'notion:' "$HOME/.claude/projects"/*/memory/MEMORY.md 2>/dev/null | head -1)
if [ -z "$MEMORY_FILE" ]; then
    MEMORY_FILE=$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null | head -1)
fi
if [ -z "$MEMORY_FILE" ]; then
    echo "$(date): No MEMORY.md found, skipping" >> "$LOG_DIR/5-sync-notion.log"
    exit 0
fi
MEMORY_DIR=$(dirname "$MEMORY_FILE")

mkdir -p "$LOG_DIR"

if [ -z "$NOTION_TOKEN" ]; then
    echo "$(date): NOTION_TOKEN not set, skipping" >> "$LOG_DIR/5-sync-notion.log"
    exit 0
fi

if [ ! -f "$MEMORY_FILE" ]; then
    echo "$(date): MEMORY.md not found at $MEMORY_FILE, skipping" >> "$LOG_DIR/5-sync-notion.log"
    exit 0
fi

# --- Phase 1: Auto-discover new pages ---

# Search queries (Notion search API searches across all shared pages)
SEARCH_QUERIES=(
    "claude"
    "AI tools"
    "prompt"
)

# Relevance filter: page title must contain at least one of these terms (case-insensitive)
RELEVANT_TERMS="claude code|claude os|ai tool|ai code|ai dev|ai review|ai pr|prompt|llm|plugin|marketplace"

# Exclude filter: page titles matching these terms are skipped (case-insensitive)
EXCLUDE_TERMS="upgrade|hackathon|meeting notes|archive"

# Collect already-synced page IDs from MEMORY.md
EXISTING_IDS=$(grep 'notion:' "$MEMORY_FILE" | sed -n 's/.*(notion:\([^)]*\)).*/\1/p')

for QUERY in "${SEARCH_QUERIES[@]}"; do
    SEARCH_RESULT=$(curl -s -X POST \
        "$NOTION_API/search" \
        -H "Authorization: Bearer $NOTION_TOKEN" \
        -H "Notion-Version: 2022-06-28" \
        -H "Content-Type: application/json" \
        -d "{\"query\": \"$QUERY\", \"filter\": {\"value\": \"page\", \"property\": \"object\"}, \"page_size\": 25}")

    TMPFILE=$(mktemp)
    echo "$SEARCH_RESULT" > "$TMPFILE"

    python3 -c "
import json, re

with open('$TMPFILE') as f:
    data = json.load(f)

existing = set('''$EXISTING_IDS'''.split())
memory_file = '$MEMORY_FILE'
relevant_terms = '$RELEVANT_TERMS'
exclude_terms = '$EXCLUDE_TERMS'
relevant_pattern = re.compile(relevant_terms, re.IGNORECASE)
exclude_pattern = re.compile(exclude_terms, re.IGNORECASE)

with open(memory_file) as f:
    content = f.read()

lines = content.split('\n')
last_notion_idx = -1
last_confluence_idx = -1
for i, line in enumerate(lines):
    if '(notion:' in line and '\`topics/' in line:
        last_notion_idx = i
    if '(confluence:' in line and '\`topics/' in line:
        last_confluence_idx = i

# Insert after last notion entry, or after last confluence entry, or after Topic Files header
insert_idx = last_notion_idx if last_notion_idx >= 0 else last_confluence_idx
if insert_idx < 0:
    # Look for Topic Files section header
    for i, line in enumerate(lines):
        if 'Topic Files' in line and line.startswith('#'):
            insert_idx = i + 2  # skip header and blank line
            break
if insert_idx < 0:
    # No Topic Files section, append one
    lines.append('')
    lines.append('## Topic Files (on demand, read when relevant)')
    lines.append('')
    insert_idx = len(lines) - 1

new_pages = []
for r in data.get('results', []):
    page_id = r['id'].replace('-', '')
    # Extract title
    title = 'Untitled'
    props = r.get('properties', {})
    for key, val in props.items():
        if val.get('type') == 'title':
            title_parts = val.get('title', [])
            title = ''.join(t.get('plain_text', '') for t in title_parts)
            break
    if page_id not in existing and relevant_pattern.search(title) and not exclude_pattern.search(title):
        filename = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-') + '.md'
        new_pages.append((page_id, filename, title))
        existing.add(page_id)

if new_pages and insert_idx >= 0:
    new_lines = []
    for page_id, filename, title in new_pages:
        new_lines.append(f'- \`topics/{filename}\` — {title} (notion:{page_id})')
    lines = lines[:insert_idx + 1] + new_lines + lines[insert_idx + 1:]
    with open(memory_file, 'w') as f:
        f.write('\n'.join(lines))

print(len(new_pages))
" 2>/dev/null

    rm -f "$TMPFILE"
done

TOTAL_NEW=$(grep -c 'notion:' "$MEMORY_FILE")
echo "$(date): Discovery complete. $TOTAL_NEW total notion entries in MEMORY.md" >> "$LOG_DIR/5-sync-notion.log"

# --- Phase 2: Sync all entries ---

SYNCED=0
FAILED=0

while IFS= read -r LINE; do
    FILENAME=$(echo "$LINE" | sed -n 's/.*`topics\/\([^`]*\)`.*/\1/p')
    PAGE_ID=$(echo "$LINE" | sed -n 's/.*(notion:\([^)]*\)).*/\1/p')

    if [ -z "$FILENAME" ] || [ -z "$PAGE_ID" ]; then
        continue
    fi

    mkdir -p "$MEMORY_DIR/topics"
    OUTFILE="$MEMORY_DIR/topics/$FILENAME"

    # Format page ID with dashes if not already formatted
    FORMATTED_ID=$(echo "$PAGE_ID" | sed 's/^\([a-f0-9]\{8\}\)\([a-f0-9]\{4\}\)\([a-f0-9]\{4\}\)\([a-f0-9]\{4\}\)\([a-f0-9]\{12\}\)$/\1-\2-\3-\4-\5/')

    # Fetch page metadata (title)
    TITLE_RESULT=$(curl -s -w "\n%{http_code}" \
        "$NOTION_API/pages/$FORMATTED_ID" \
        -H "Authorization: Bearer $NOTION_TOKEN" \
        -H "Notion-Version: 2022-06-28")

    TITLE_HTTP=$(echo "$TITLE_RESULT" | tail -1)
    TITLE_BODY=$(echo "$TITLE_RESULT" | sed '$d')

    if [ "$TITLE_HTTP" != "200" ]; then
        echo "$(date): FAILED $FILENAME (page fetch HTTP $TITLE_HTTP)" >> "$LOG_DIR/5-sync-notion.log"
        FAILED=$((FAILED + 1))
        continue
    fi

    # Fetch page blocks (content)
    RESULT=$(curl -s -w "\n%{http_code}" \
        "$NOTION_API/blocks/$FORMATTED_ID/children?page_size=100" \
        -H "Authorization: Bearer $NOTION_TOKEN" \
        -H "Notion-Version: 2022-06-28")

    HTTP_CODE=$(echo "$RESULT" | tail -1)
    BODY=$(echo "$RESULT" | sed '$d')

    if [ "$HTTP_CODE" != "200" ]; then
        echo "$(date): FAILED $FILENAME (blocks fetch HTTP $HTTP_CODE)" >> "$LOG_DIR/5-sync-notion.log"
        FAILED=$((FAILED + 1))
        continue
    fi

    # Write blocks JSON to temp file to avoid shell quoting issues
    TMPFILE=$(mktemp)
    TITLE_TMPFILE=$(mktemp)
    echo "$TITLE_BODY" > "$TITLE_TMPFILE"
    echo "$BODY" > "$TMPFILE"

    python3 -c "
import sys, json, re

with open('$TITLE_TMPFILE') as f:
    title_data = json.load(f)
with open('$TMPFILE') as f:
    blocks_data = json.load(f)

# Extract title
title = 'Untitled'
props = title_data.get('properties', {})
for key, val in props.items():
    if val.get('type') == 'title':
        title_parts = val.get('title', [])
        title = ''.join(t.get('plain_text', '') for t in title_parts)
        break

page_id = '$PAGE_ID'
source = f'https://www.notion.so/{page_id}'

def rich_text_to_md(rich_texts):
    result = ''
    for rt in rich_texts:
        text = rt.get('plain_text', '')
        annotations = rt.get('annotations', {})
        if annotations.get('bold'):
            text = f'**{text}**'
        if annotations.get('italic'):
            text = f'*{text}*'
        if annotations.get('code'):
            text = f'\`{text}\`'
        if annotations.get('strikethrough'):
            text = f'~~{text}~~'
        href = rt.get('href')
        if href:
            text = f'[{text}]({href})'
        result += text
    return result

def block_to_md(block, indent=0):
    btype = block.get('type', '')
    prefix = '  ' * indent

    if btype == 'paragraph':
        text = rich_text_to_md(block['paragraph'].get('rich_text', []))
        return f'{prefix}{text}'
    elif btype.startswith('heading_'):
        level = int(btype[-1])
        text = rich_text_to_md(block[btype].get('rich_text', []))
        return f'{\"#\" * level} {text}'
    elif btype == 'bulleted_list_item':
        text = rich_text_to_md(block[btype].get('rich_text', []))
        return f'{prefix}- {text}'
    elif btype == 'numbered_list_item':
        text = rich_text_to_md(block[btype].get('rich_text', []))
        return f'{prefix}1. {text}'
    elif btype == 'to_do':
        text = rich_text_to_md(block[btype].get('rich_text', []))
        checked = block[btype].get('checked', False)
        return f'{prefix}- [{\"x\" if checked else \" \"}] {text}'
    elif btype == 'toggle':
        text = rich_text_to_md(block[btype].get('rich_text', []))
        return f'{prefix}- {text}'
    elif btype == 'code':
        text = rich_text_to_md(block[btype].get('rich_text', []))
        lang = block[btype].get('language', '')
        return f'\`\`\`{lang}\n{text}\n\`\`\`'
    elif btype == 'quote':
        text = rich_text_to_md(block[btype].get('rich_text', []))
        return f'{prefix}> {text}'
    elif btype == 'callout':
        text = rich_text_to_md(block[btype].get('rich_text', []))
        return f'{prefix}> {text}'
    elif btype == 'divider':
        return '---'
    elif btype == 'table_of_contents':
        return ''
    elif btype == 'image':
        url = block[btype].get('file', {}).get('url', '') or block[btype].get('external', {}).get('url', '')
        caption = rich_text_to_md(block[btype].get('caption', []))
        return f'![{caption}]({url})' if url else ''
    elif btype == 'bookmark':
        url = block[btype].get('url', '')
        caption = rich_text_to_md(block[btype].get('caption', []))
        return f'[{caption or url}]({url})' if url else ''
    elif btype == 'child_page':
        child_title = block[btype].get('title', '')
        return f'- [{child_title}]'
    else:
        return ''

lines = []
for block in blocks_data.get('results', []):
    line = block_to_md(block)
    if line is not None:
        lines.append(line)

md = '\n\n'.join(lines)
md = re.sub(r'\n{3,}', '\n\n', md)

print(f'# {title}\n\nSource: {source}\n\n{md}')
" > "$OUTFILE" 2>/dev/null

    rm -f "$TMPFILE" "$TITLE_TMPFILE"

    if [ $? -eq 0 ]; then
        LINES=$(wc -l < "$OUTFILE")
        echo "$(date): OK $FILENAME ($LINES lines)" >> "$LOG_DIR/5-sync-notion.log"
        SYNCED=$((SYNCED + 1))
    else
        echo "$(date): FAILED $FILENAME (parse error)" >> "$LOG_DIR/5-sync-notion.log"
        FAILED=$((FAILED + 1))
    fi
done < <(grep 'notion:' "$MEMORY_FILE" | grep '`topics/')

echo "$(date): Sync complete. $SYNCED synced, $FAILED failed." >> "$LOG_DIR/5-sync-notion.log"
