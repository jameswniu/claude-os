#!/bin/bash
# 5-checkpoint.sh — Snapshot live config/memory files into claude-os <repo-name>
# Usage: bash ~/claude-os/<repo-name>/.claude/scripts/5-checkpoint.sh  (run from any project dir)
#
# Reads from (running project):
#   - $PROJECT/.claude/CLAUDE.md            Personal rules with promoted learnings
#   - $MEM/MEMORY.md                        Accumulated knowledge
#   - $MEM/history/logs.md                   Session history
#   - $MEM/*.md (topic files)               Confluence-synced reference docs
#
# Writes to (filtered templates):
#   - <repo-name>/.claude/CLAUDE.md                                      Universal rules, project values replaced
#   - .claude/projects/-Users-<user-name>-<repo-name>/memory/MEMORY.md    Filtered + situation-based topic index
#   - .claude/projects/-Users-<user-name>-<repo-name>/memory/*.md          Distilled, 1:1 with source
#   - .claude/projects/-Users-<user-name>-<repo-name>/memory/history/logs.md  Copy as-is

CLAUDE_OS="$HOME/claude-os"
REPO_TMPL="$CLAUDE_OS/<repo-name>"
MEM_TMPL="$CLAUDE_OS/.claude/projects/-Users-<user-name>-<repo-name>/memory"
PROJECT=$(pwd)
SLUG=$(echo "$PROJECT" | tr '/.' '-' | sed 's/^//')
MEM="$HOME/.claude/projects/${SLUG}/memory"

[ ! -d "$MEM" ] && echo "No memory dir for $(basename "$PROJECT")" && exit 1

mkdir -p "$MEM_TMPL/history" "$REPO_TMPL/.claude"

echo "Checkpoint: $(basename "$PROJECT")"
echo "  Source: $MEM"
echo "  Target: $REPO_TMPL"
echo ""

# ============================================================
# 1. Filter MEMORY.md (existing logic + flat topic index)
# ============================================================
# Capture template checksum before any MEMORY.md modifications (steps 1, 5, 6)
MEM_TMPL_MD5=$(md5 -q "$MEM_TMPL/MEMORY.md" 2>/dev/null || echo "none")

# Skip MEMORY.md filter if source is empty or near-empty (prevents overwriting good template with blank)
MEMLINES=$(wc -l < "$MEM/MEMORY.md" 2>/dev/null || echo 0)
if [ "$MEMLINES" -ge 5 ]; then
python3 -c "
import re, sys

# Sections that are project-specific (keep structure, replace values with placeholders)
placeholders = {
    'bitbucket api': '''
- Base URL: (learned per project)
- Project and repo: (learned per project)
- PR list endpoint: (learned per project)
- PR comments endpoint: (learned per project)
- To update a comment, PUT with the current \x60version\x60 number (increments on each edit).
- Auth: basic auth with username:token from git remote URL
''',
    'branch naming': '''
- Branches follow pattern: (learned per project)
- Target branch is almost always \x60main\x60. Detect via \x60git merge-base\x60.
''',
    'project architecture': '''
- Services, ports, directories: (learned per project)
- Tech stack: (learned per project)
- Test suite: (learned per project)
''',
    'pr review patterns': '''
- Two PR types: config-only (version bumps, YAML changes) and feature PRs (multi-file, complex)
- Config PRs are low-risk but still get full test suite runs
- Feature PRs often need multiple review sessions as PR evolves
- Tool usage is overwhelmingly read-only: Bash >> Read >> Grep >> Edit >> Write
''',
    'ui smoke testing': '''
- Automated UI smoke tests via browser extension on localhost
- Export before/after GIF recordings as PR evidence
- Store test artifacts on orphan git tags (not PR branches) to avoid merging demo files into main
- PR comment links should use raw URLs pointing to tags for GIF/image display
''',
}

# Keywords in Recurring Mistakes that are project-specific (skip bullets containing these)
skip_mistake_keywords = ['verdict in pr', 'gh cli', 'wrong branch', 'node_modules', 'session cut-off']

with open('$MEM/MEMORY.md') as f:
    content = f.read()

# Normalize stale log path references
content = content.replace('\x60log.md\x60', '\x60history/logs.md\x60')
content = content.replace('memory/log.md', 'memory/history/logs.md')
content = re.sub(r'(?<![/\w])log\.md(?!\w)', 'history/logs.md', content)

sections = re.split(r'(^## .+$)', content, flags=re.MULTILINE)
out = sections[0]  # header before first ##

i = 1
while i < len(sections):
    heading = sections[i]
    body = sections[i+1] if i+1 < len(sections) else ''
    name = heading.lstrip('#').strip().lower()
    # Replace project-specific sections with placeholders
    if name in placeholders:
        out += heading + '\n\n' + placeholders[name] + '\n'
        i += 2
        continue
    # Rewrite topic file entries to situation-based index (strip source IDs)
    if 'topic files' in name:
        lines = body.split('\n')
        clean = []
        for l in lines:
            # Strip lines with (confluence:...) or (notion:...) source IDs
            if re.match(r'^- \x60', l) and ('(confluence:' in l or '(notion:' in l):
                continue
            clean.append(l)
        body = '\n'.join(clean) + '\n'
    # Strip project-specific recurring mistakes
    if 'recurring mistakes' in name:
        lines = body.split('\n')
        clean = []
        for l in lines:
            low = l.lower().replace('\x60', '')
            if l.startswith('- **') and any(k in low for k in skip_mistake_keywords):
                continue
            clean.append(l)
        body = '\n'.join(clean) + '\n'
    out += heading + body
    i += 2

# Clean up filtered content
out = re.sub(r'\n{3,}', '\n\n', out)
out = out.rstrip() + '\n'

# Merge with existing template (accumulate-only)
import os
tmpl_path = '$MEM_TMPL/MEMORY.md'

def parse_sections(text):
    parts = re.split(r'(^## .+$)', text, flags=re.MULTILINE)
    preamble = parts[0]
    secs = []
    i = 1
    while i < len(parts):
        h = parts[i]
        b = parts[i+1] if i+1 < len(parts) else ''
        secs.append((h.lstrip('#').strip().lower(), h, b))
        i += 2
    return preamble, secs

def merge_body(t_body, f_body):
    \"\"\"Line-level union: keep all template lines, append new filtered lines.\"\"\"
    def norm(line):
        return line.replace('\u2014', '-').replace('\u2013', '-').lower().strip()
    t_content = [l for l in t_body.split('\n') if l.strip()]
    f_content = [l for l in f_body.split('\n') if l.strip()]
    t_norms = {norm(l) for l in t_content}
    new = [l for l in f_content if norm(l) not in t_norms]
    if not new:
        return t_body
    return t_body.rstrip('\n') + '\n' + '\n'.join(new) + '\n'

existing = ''
if os.path.exists(tmpl_path):
    with open(tmpl_path) as f:
        existing = tmpl = f.read()
    t_pre, t_secs = parse_sections(tmpl)
    f_pre, f_secs = parse_sections(out)
    f_map = {n: (h, b) for n, h, b in f_secs}
    t_names = {n for n, _, _ in t_secs}
    merged = f_pre
    for n, h, b in t_secs:
        if n in f_map:
            merged += h + merge_body(b, f_map[n][1])
        else:
            merged += h + b
    for n, h, b in f_secs:
        if n not in t_names:
            merged += h + b
    out = re.sub(r'\n{3,}', '\n\n', merged)
    out = out.rstrip() + '\n'

with open(tmpl_path, 'w') as f:
    f.write(out)
" 2>/dev/null
fi

# ============================================================
# 2. Filter .claude/CLAUDE.md (personal rules)
# ============================================================
if [ -f "$PROJECT/.claude/CLAUDE.md" ]; then
    python3 -c "
import re

with open('$PROJECT/.claude/CLAUDE.md') as f:
    content = f.read()

# Universal sections to keep verbatim
keep_verbatim = ['pr comment style', 'pr reviews & comments', 'behavior rules', 'memory', 'claude os',
                 'artifacts & storage', 'general conventions']

# Sections to filter (keep heading, replace body with placeholders)
filter_sections = {
    'pr review workflow': '''
- Always fetch the remote branch first with \x60git fetch origin\x60 before analyzing any PR.
- Detect the target branch (usually \x60main\x60) via \x60git merge-base\x60. Diff against remote refs, never local checkout.
- Exclude \x60node_modules/\x60, \x60dist/\x60, \x60.next/\x60 from all grep and regression scans.
- When writing the final review summary, output the complete review in a single response.
- Two PR types: config-only (version bumps, YAML) and feature PRs (multi-file). Config PRs are low-risk.
- Git hosting platform and API details: (learned per project)
''',
    'environment constraints': '''
- Git hosting platform, API base URL, auth method: (learned per project)
- Branch naming convention: (learned per project)
''',
    'prompts': '''
- Prompt management system: (learned per project)
''',
}

sections = re.split(r'(^## .+$)', content, flags=re.MULTILINE)
out = sections[0]

i = 1
while i < len(sections):
    heading = sections[i]
    body = sections[i+1] if i+1 < len(sections) else ''
    name = heading.lstrip('#').strip().lower()

    if name in filter_sections:
        out += heading + '\n\n' + filter_sections[name].strip() + '\n'
    else:
        out += heading + body
    i += 2

# Strip project-specific URLs and values
out = re.sub(r'stash\.centro\.net[^\s\n]*', '(learned per project)', out)
out = re.sub(r'BP-\d+[_-]\w+', '(learned per project)', out)
out = re.sub(r'Project: \x60CEN\x60, Repo: \x60[^\x60]+\x60', 'Project and repo: (learned per project)', out)
out = re.sub(r'\n{3,}', '\n\n', out)
out = out.rstrip() + '\n'

# Merge with existing template (accumulate-only)
import os
tmpl_path = '$REPO_TMPL/.claude/CLAUDE.md'

def parse_sections(text):
    parts = re.split(r'(^## .+$)', text, flags=re.MULTILINE)
    preamble = parts[0]
    secs = []
    i = 1
    while i < len(parts):
        h = parts[i]
        b = parts[i+1] if i+1 < len(parts) else ''
        secs.append((h.lstrip('#').strip().lower(), h, b))
        i += 2
    return preamble, secs

def merge_body(t_body, f_body):
    \"\"\"Line-level union: keep all template lines, append new filtered lines.\"\"\"
    def norm(line):
        return line.replace('\u2014', '-').replace('\u2013', '-').lower().strip()
    t_content = [l for l in t_body.split('\n') if l.strip()]
    f_content = [l for l in f_body.split('\n') if l.strip()]
    t_norms = {norm(l) for l in t_content}
    new = [l for l in f_content if norm(l) not in t_norms]
    if not new:
        return t_body
    return t_body.rstrip('\n') + '\n' + '\n'.join(new) + '\n'

existing = ''
if os.path.exists(tmpl_path):
    with open(tmpl_path) as f:
        existing = tmpl = f.read()
    t_pre, t_secs = parse_sections(tmpl)
    f_pre, f_secs = parse_sections(out)
    f_map = {n: (h, b) for n, h, b in f_secs}
    t_names = {n for n, _, _ in t_secs}
    merged = f_pre
    for n, h, b in t_secs:
        if n in f_map:
            merged += h + merge_body(b, f_map[n][1])
        else:
            merged += h + b
    for n, h, b in f_secs:
        if n not in t_names:
            merged += h + b
    out = re.sub(r'\n{3,}', '\n\n', merged)
    out = out.rstrip() + '\n'

with open(tmpl_path, 'w') as f:
    f.write(out)
import sys
sys.exit(0 if out != existing else 2)
" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "  FILTERED  $REPO_TMPL/.claude/CLAUDE.md"
    else
        echo "  SKIPPED   $REPO_TMPL/.claude/CLAUDE.md"
    fi
fi

# ============================================================
# 3. Distill topic files (1:1, strip project-specific content)
# ============================================================
rm -f "$MEM_TMPL"/*.md.tmp 2>/dev/null
for TOPIC in "$MEM"/*.md; do
    [ -f "$TOPIC" ] || continue
    NAME=$(basename "$TOPIC")
    # Skip non-topic files
    [ "$NAME" = "MEMORY.md" ] && continue
    [ "$NAME" = "logs.md" ] && continue

    python3 -c "
import re, sys

with open('$TOPIC') as f:
    original = f.read()

content = original

# Strip Confluence page IDs
content = re.sub(r'\(confluence:\d+\)', '', content)
# Strip Notion page IDs
content = re.sub(r'\(notion:[a-f0-9]+\)', '', content)
# Strip Basis-specific URLs
content = re.sub(r'https?://stash\.centro\.net[^\s\n)]*', '(internal URL)', content)
content = re.sub(r'https?://[a-z]+\.basis\.com[^\s\n)]*', '(internal URL)', content)
content = re.sub(r'https?://basis\.atlassian\.net[^\s\n)]*', '(internal URL)', content)
# Strip internal project/team names that are Basis-specific
content = re.sub(r'\bCEN\b(?=/)', '(PROJECT)', content)
content = re.sub(r'media-strategy-generator', '(project-name)', content)
# Clean up
content = re.sub(r'\n{3,}', '\n\n', content)
content = content.rstrip() + '\n'

# Compare against existing template to decide FILTERED vs SKIPPED
import os
tmpl_path = '$MEM_TMPL/$NAME'
existing = ''
if os.path.exists(tmpl_path):
    with open(tmpl_path) as f:
        existing = f.read()

changed = content != existing
with open(tmpl_path, 'w') as f:
    f.write(content)

sys.exit(0 if changed else 2)
" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "  FILTERED  $MEM_TMPL/$NAME"
    else
        echo "  SKIPPED   $MEM_TMPL/$NAME"
    fi
done

# ============================================================
# 4. Copy logs.md as-is
# ============================================================
mkdir -p "$MEM_TMPL/history" && cp "$MEM/history/logs.md" "$MEM_TMPL/history/" 2>/dev/null
echo "  SKIPPED   $MEM_TMPL/history/logs.md"

# ============================================================
# 5. Update MEMORY.md template with situation-based topic index
# ============================================================
python3 -c "
import re, os

ex_memory = '$MEM_TMPL'
memory_md = os.path.join(ex_memory, 'MEMORY.md')

with open(memory_md) as f:
    content = f.read()

# Build situation-based index from existing topic files
topic_hints = {
    'code-reviews.md': 'when reviewing PRs or discussing review practices',
    'scalable-applications-and-architecture.md': 'when designing services or making architecture decisions',
    'tickets-branching-and-pull-requests-oh-my.md': 'when setting up git workflows or branching strategies',
    'informal-tech-mentorship.md': 'when mentoring or structuring knowledge transfer',
    'ai-development-tools-use-case-library.md': 'when exploring AI tool use cases or writing prompts',
    'ai-code-reviewer-project.md': 'when planning AI code review integrations',
    'archived-git-branching-and-pull-request-guidelines.md': 'historical reference for legacy branching rules',
    'claudehub.md': 'when onboarding to Claude Code or finding internal resources',
}

# Get actual topic files in <repo-name>
topic_files = sorted([
    f for f in os.listdir(ex_memory)
    if f.endswith('.md') and f != 'MEMORY.md'
])

# Build index lines
index_lines = []
for f in topic_files:
    hint = topic_hints.get(f, 'reference material')
    index_lines.append(f'- \x60{f}\x60 -- {hint}')

# Replace Topic Files section content
pattern = r'(## Topic Files \(on demand, read when relevant\)\n\n).*?((?=\n## )|$)'
replacement = r'\1' + 'Reference docs in the memory directory. Zero tokens until read.\n'
if index_lines:
    replacement += '\n'.join(index_lines) + '\n'
replacement += '- Synced every 24h. Scripts auto-discover relevant new pages and add them here.\n'

content = re.sub(pattern, replacement, content, flags=re.DOTALL)
content = re.sub(r'\n{3,}', '\n\n', content)
content = content.rstrip() + '\n'

with open(memory_md, 'w') as f:
    f.write(content)
" 2>/dev/null

# ============================================================
# 6. Ensure MEMORY.md Claude OS section has operational patterns
# ============================================================
python3 -c "
import re

with open('$MEM_TMPL/MEMORY.md') as f:
    content = f.read()

# Check if Claude OS section has the operational patterns
patterns_to_ensure = [
    'unset CLAUDECODE',
    '~/.local/bin',
    'exit 2 for skip',
    'pmset sleep 0',
]

has_all = all(p in content for p in patterns_to_ensure)
if not has_all:
    # Find the Claude OS section and ensure it has operational patterns
    sections = re.split(r'(^## .+$)', content, flags=re.MULTILINE)
    out = ''
    i = 0
    while i < len(sections):
        if i > 0 and 'claude os repo' in sections[i].lower():
            heading = sections[i]
            body = sections[i+1] if i+1 < len(sections) else ''
            # Ensure operational patterns are present
            if 'unset CLAUDECODE' not in body:
                body = body.rstrip() + '\n- Scripts 1-3 need \x60unset CLAUDECODE\x60 before \x60claude -p\x60 to avoid nested session error\n'
            if '~/.local/bin' not in body:
                body = body.rstrip() + '\n- Launchd PATH must include \x60~/.local/bin\x60 (where \x60claude\x60 is installed)\n'
            if 'exit 2' not in body:
                body = body.rstrip() + '\n- Exit code conventions: exit 0 for success, exit 1 for fail, exit 2 for skip (e.g., missing credentials)\n'
            if 'pmset' not in body:
                body = body.rstrip() + '\n- \x60pmset sleep 0\x60 applied to keep Mac awake so launchd jobs run 24/7\n'
            out += heading + body
            i += 2
        else:
            out += sections[i]
            i += 1

    out = re.sub(r'\n{3,}', '\n\n', out)
    out = out.rstrip() + '\n'
    with open('$MEM_TMPL/MEMORY.md', 'w') as f:
        f.write(out)
" 2>/dev/null

# Report MEMORY.md status (deferred until after steps 1, 5, 6 all complete)
MEM_TMPL_MD5_AFTER=$(md5 -q "$MEM_TMPL/MEMORY.md" 2>/dev/null || echo "none")
if [ "$MEM_TMPL_MD5" != "$MEM_TMPL_MD5_AFTER" ]; then
    echo "  FILTERED  $MEM_TMPL/MEMORY.md"
else
    echo "  SKIPPED   $MEM_TMPL/MEMORY.md"
fi

# ============================================================
# 7. Commit and push
# ============================================================
cd "$CLAUDE_OS"
git add '<repo-name>/' '.claude/'
git diff --cached --quiet && echo "No changes." && exit 0
git commit -m "Checkpoint from $(basename "$PROJECT") ($(date +%Y-%m-%d))"
echo ""
echo "Checkpoint committed locally (staging)."
echo "To push to production: cd ~/claude-os && git push && cd $PROJECT"
