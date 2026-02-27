#!/bin/bash
# 5-sync-notion.sh — Runs every 24 hours
# Re-fetches registered Notion pages into topic files in the memory directory

MEMORY_DIR="/Users/james.niu/.claude/projects/-Users-james-niu-media-strategy-generator/memory"
LOG_DIR="/Users/james.niu/claude-os/output"
NOTION_API="https://api.notion.com/v1"

mkdir -p "$LOG_DIR"

# Auth: reads from environment variable NOTION_TOKEN
if [ -z "$NOTION_TOKEN" ]; then
    echo "$(date): NOTION_TOKEN not set, skipping" >> "$LOG_DIR/5-sync-notion.log"
    exit 0
fi

# Registry: page_id | filename | description
# Add new pages here to sync them automatically
# To find a page ID: open the page in Notion, copy the URL, the ID is the 32-char hex string at the end
PAGES=(
    # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|example.md|Example page"
)

SYNCED=0
FAILED=0

for ENTRY in "${PAGES[@]}"; do
    IFS='|' read -r PAGE_ID FILENAME DESCRIPTION <<< "$ENTRY"
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

    # Convert Notion blocks to markdown
    python3 -c "
import sys, json

title_data = json.loads('''$TITLE_BODY''')
blocks_data = json.loads('''$BODY''')

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

# Collapse 3+ consecutive blank lines to 2
import re
md = re.sub(r'\n{3,}', '\n\n', md)

print(f'# {title}\n\nSource: {source}\n\n{md}')
" > "$OUTFILE" 2>/dev/null

    if [ $? -eq 0 ]; then
        LINES=$(wc -l < "$OUTFILE")
        echo "$(date): OK $FILENAME ($LINES lines)" >> "$LOG_DIR/5-sync-notion.log"
        SYNCED=$((SYNCED + 1))
    else
        echo "$(date): FAILED $FILENAME (parse error)" >> "$LOG_DIR/5-sync-notion.log"
        FAILED=$((FAILED + 1))
    fi
done

echo "$(date): Sync complete. $SYNCED synced, $FAILED failed." >> "$LOG_DIR/5-sync-notion.log"
