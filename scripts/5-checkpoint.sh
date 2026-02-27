#!/bin/bash
# 5-checkpoint.sh — Snapshot live config/memory files into claude-os EXAMPLES
# Usage: bash ~/claude-os/scripts/5-checkpoint.sh  (run from any project dir)

CLAUDE_OS="$HOME/claude-os"
EX="$CLAUDE_OS/EXAMPLES"
PROJECT=$(pwd)
SLUG=$(echo "$PROJECT" | tr '/.' '-' | sed 's/^//')
MEM="$HOME/.claude/projects/${SLUG}/memory"

[ ! -d "$MEM" ] && echo "No memory dir for $(basename "$PROJECT")" && exit 1

# Template files (CLAUDE.md, .claude/CLAUDE.md, settings.local.json, commands/review.md)
# are maintained manually in EXAMPLES. Checkpoint only syncs memory + topic files.
mkdir -p "$EX/memory/topics"
# Copy MEMORY.md but strip project-specific sections (keep only generic/reusable ones)
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
}

# Keywords in Recurring Mistakes that are project-specific (skip bullets containing these)
skip_mistake_keywords = ['verdict in pr', 'gh cli', 'wrong branch', 'node_modules', 'session cut-off']

with open('$MEM/MEMORY.md') as f:
    content = f.read()

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
    # Strip topic file entries (populated per-project by sync)
    if 'topic files' in name:
        lines = body.split('\n')
        body = '\n'.join(l for l in lines if not re.match(r'^- \x60topics/', l)) + '\n'
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

# Clean up trailing whitespace and ensure single newline at end
out = re.sub(r'\n{3,}', '\n\n', out)
out = out.rstrip() + '\n'
with open('$EX/memory/MEMORY.md', 'w') as f:
    f.write(out)
" 2>/dev/null
cp "$MEM/logs.md" "$EX/memory/" 2>/dev/null
rm -f "$EX/memory/topics"/*.md 2>/dev/null
cp "$MEM/topics"/*.md "$EX/memory/topics/" 2>/dev/null

# Commit and push
cd "$CLAUDE_OS"
git add EXAMPLES/
git diff --cached --quiet && echo "No changes." && exit 0
git commit -m "Checkpoint from $(basename "$PROJECT") ($(date +%Y-%m-%d))"
git push
