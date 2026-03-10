#!/bin/bash
# 5-sync-notion.sh — Runs every 24 hours
# 1. Auto-discovers new relevant Notion pages and adds them to MEMORY.md (30-entry FIFO cap)
# 2. Syncs all (notion:ID) entries from MEMORY.md to topic files
# Loops over all projects with a MEMORY.md

LOG_DIR="$HOME/claude-os/output"
NOTION_API="https://api.notion.com/v1"

mkdir -p "$LOG_DIR"

if [ -z "$NOTION_TOKEN" ]; then
    echo "$(date): NOTION_TOKEN not set, skipping" >> "$LOG_DIR/5-sync-notion.log"
    exit 2
fi

# Find all project MEMORY.md files
MEMORY_FILES=$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null)
if [ -z "$MEMORY_FILES" ]; then
    echo "$(date): No MEMORY.md files found, skipping" >> "$LOG_DIR/5-sync-notion.log"
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
    [ -z "$PROJECT_DIR" ] && PROJECT_DIR="$SLUG"

    if [ ! -f "$MEMORY_FILE" ]; then
        continue
    fi

    echo "$(date): [$PROJECT_DIR] Starting sync..." >> "$LOG_DIR/5-sync-notion.log"

    # --- Phase 1: Auto-discover new pages ---

    # Find project CLAUDE.md by matching slug against real directories
    PROJECT_SLUG=$(basename "$(dirname "$(dirname "$MEMORY_FILE")")")
    CLAUDE_MD=""
    for F in "$HOME"/*/CLAUDE.md "$HOME"/*/*/CLAUDE.md; do
        [ -f "$F" ] || continue
        D=$(dirname "$F")
        if [ "$(echo "$D" | tr '/._ ' '-')" = "$PROJECT_SLUG" ]; then
            CLAUDE_MD="$F"
            break
        fi
    done

    # Extract search queries + relevance terms dynamically, then search Notion
    DISCOVERY_RESULT=$(python3 -c "
import re, json, subprocess, os

memory_file = '$MEMORY_FILE'
claude_md = '$CLAUDE_MD'
notion_api = '$NOTION_API'
notion_token = '$NOTION_TOKEN'

with open(memory_file) as f:
    memory = f.read()

claude_content = ''
if claude_md and os.path.exists(claude_md):
    with open(claude_md) as f:
        claude_content = f.read()

# --- Extract search queries from project context ---
queries = set()

# 1. Topic descriptions (highest signal, for organic growth)
for m in re.finditer(r'\x60[^\x60]+\x60\s+.+?\s+(.+?)\s+\([a-z]+:', memory):
    queries.add(m.group(1))

# 2. Section headings from MEMORY.md
skip_headings = {'topic files', 'memory', 'claude os', 'file system', 'cumulative friction'}
for m in re.finditer(r'^## (.+?)(?:\s*\(.*\))?\s*$', memory, re.MULTILINE):
    heading = m.group(1).strip()
    if heading.lower() not in skip_headings:
        queries.add(heading)

# 3. Section headings from CLAUDE.md
skip_claude = {'build', 'commands', 'docker', 'testing', 'style', 'quality', 'e2e', 'environment', 'configuration', 'local development'}
for m in re.finditer(r'^#{2,3} (.+?)$', claude_content, re.MULTILINE):
    heading = m.group(1).strip()
    if not any(s in heading.lower() for s in skip_claude):
        queries.add(heading)

# --- Extract relevance terms from both files ---
terms = set()
combined = memory + '\n' + claude_content

# Bold terms
for m in re.finditer(r'\*\*(.+?)\*\*', combined):
    term = m.group(1).strip().rstrip(':')
    if len(term) > 2 and len(term) < 40:
        terms.add(term.lower())

# Section headings as terms
for m in re.finditer(r'^#{1,3} (.+?)(?:\s*\(.*\))?\s*$', combined, re.MULTILINE):
    for word in re.split(r'[\s/]+', m.group(1)):
        word = re.sub(r'[^a-zA-Z0-9]', '', word)
        if len(word) > 2:
            terms.add(word.lower())

# Capitalized phrases (proper nouns/tools)
for m in re.finditer(r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+)+)\b', combined):
    terms.add(m.group(1).lower())

# Filter out generic terms
generic = {'the', 'this', 'that', 'with', 'from', 'into', 'all', 'run', 'use', 'set', 'not', 'for', 'and', 'are', 'can', 'may', 'will', 'has', 'get', 'new', 'key', 'see', 'how', 'code', 'file', 'files', 'line', 'start', 'check', 'install', 'important', 'must', 'pass', 'source', 'directories'}
terms = {t for t in terms if t not in generic and len(t) > 2}
relevant_pattern = '|'.join(re.escape(t) for t in sorted(terms)) if terms else '.'

# --- Search Notion and discover pages ---
existing_ids = set(re.findall(r'\(notion:([a-f0-9]+)\)', memory))

lines = memory.split('\n')

# Find insertion point (after last notion entry, or last confluence entry, or after Topic Files header)
last_idx = -1
for i, line in enumerate(lines):
    if '(notion:' in line and '\x60' in line:
        last_idx = i
if last_idx < 0:
    for i, line in enumerate(lines):
        if '(confluence:' in line and '\x60' in line:
            last_idx = i
if last_idx < 0:
    for i, line in enumerate(lines):
        if 'Topic Files' in line and line.startswith('#'):
            last_idx = i + 2
            break

total_new = 0
relevant_re = re.compile(relevant_pattern, re.IGNORECASE)

for query in sorted(queries):
    try:
        result = subprocess.run(
            ['curl', '-s', '-X', 'POST', f'{notion_api}/search',
             '-H', f'Authorization: Bearer {notion_token}',
             '-H', 'Notion-Version: 2022-06-28',
             '-H', 'Content-Type: application/json',
             '-d', json.dumps({'query': query, 'filter': {'value': 'page', 'property': 'object'}, 'page_size': 25})],
            capture_output=True, text=True, timeout=30
        )
        data = json.loads(result.stdout)
    except Exception:
        continue

    new_pages = []
    for r in data.get('results', []):
        page_id = r['id'].replace('-', '')
        title = 'Untitled'
        props = r.get('properties', {})
        for key, val in props.items():
            if val.get('type') == 'title':
                title_parts = val.get('title', [])
                title = ''.join(t.get('plain_text', '') for t in title_parts)
                break
        if page_id not in existing_ids and relevant_re.search(title):
            filename = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-') + '.md'
            new_pages.append((page_id, filename, title))
            existing_ids.add(page_id)

    if new_pages and last_idx >= 0:
        new_lines = [f'- \x60{fn}\x60 — {t} (notion:{pid})' for pid, fn, t in new_pages]
        # 30-entry FIFO cap: count all topic entries with source IDs
        topic_count = sum(1 for l in lines if re.match(r'^- \x60[^\x60]+\.md\x60.*\([a-z]+:', l))
        while topic_count + len(new_lines) > 30:
            for i, l in enumerate(lines):
                if re.match(r'^- \x60[^\x60]+\.md\x60.*\([a-z]+:', l):
                    lines.pop(i)
                    if i <= last_idx:
                        last_idx -= 1
                    topic_count -= 1
                    break
            else:
                break
        lines = lines[:last_idx + 1] + new_lines + lines[last_idx + 1:]
        last_idx += len(new_lines)
        total_new += len(new_lines)

if total_new > 0:
    with open(memory_file, 'w') as f:
        f.write('\n'.join(lines))

print(total_new)
" 2>/dev/null)

    echo "$(date): [$PROJECT_DIR] Discovery complete. $(grep -c 'notion:' "$MEMORY_FILE" 2>/dev/null || echo 0) total notion entries" >> "$LOG_DIR/5-sync-notion.log"

    # --- Phase 2: Sync all entries ---

    SYNCED=0
    FAILED=0

    while IFS= read -r LINE; do
        FILENAME=$(echo "$LINE" | sed -n 's/.*`\([^`]*\.md\)`.*/\1/p')
        PAGE_ID=$(echo "$LINE" | sed -n 's/.*(notion:\([^)]*\)).*/\1/p')

        if [ -z "$FILENAME" ] || [ -z "$PAGE_ID" ]; then
            continue
        fi

        OUTFILE="$MEMORY_DIR/$FILENAME"

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
            echo "$(date): [$PROJECT_DIR] FAILED $FILENAME (page fetch HTTP $TITLE_HTTP)" >> "$LOG_DIR/5-sync-notion.log"
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
            echo "$(date): [$PROJECT_DIR] FAILED $FILENAME (blocks fetch HTTP $HTTP_CODE)" >> "$LOG_DIR/5-sync-notion.log"
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
            echo "$(date): [$PROJECT_DIR] OK $FILENAME ($LINES lines)" >> "$LOG_DIR/5-sync-notion.log"
            SYNCED=$((SYNCED + 1))
        else
            echo "$(date): [$PROJECT_DIR] FAILED $FILENAME (parse error)" >> "$LOG_DIR/5-sync-notion.log"
            FAILED=$((FAILED + 1))
        fi
    done < <(grep 'notion:' "$MEMORY_FILE" | grep '`[^`]*\.md`')

    echo "$(date): [$PROJECT_DIR] Sync complete. $SYNCED synced, $FAILED failed." >> "$LOG_DIR/5-sync-notion.log"

    if [ "$FAILED" -gt 0 ]; then
        ERRORS=$((ERRORS + 1))
    fi

done <<< "$MEMORY_FILES"

if [ "$ERRORS" -gt 0 ]; then
    echo "$(date): Finished with $ERRORS project(s) having failures" >> "$LOG_DIR/5-sync-notion.log"
    exit 1
fi
