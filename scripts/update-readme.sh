#!/bin/bash
# update-readme.sh - Regenerate the file tree in README.md from actual repo structure
# Used as a pre-push hook or run manually

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

# Generate the actual file tree (excluding .git, output)
TREE=$(find . -not -path './.git/*' -not -path './output/*' -not -name '.git' -not -name 'output' -not -name '.DS_Store' -not -name '.' | sort | awk '
BEGIN { print "claude-os/" }
{
    gsub(/^\.\//, "")
    if ($0 == "") next
    n = split($0, parts, "/")
    indent = ""
    for (i = 1; i < n; i++) indent = indent "    "
    printf "%s├── %s\n", indent, parts[n]
}')

# Replace the file tree block in README
export TREE
python3 -c "
import os, re

with open('README.md', 'r') as f:
    content = f.read()

tree = os.environ['TREE']
new_block = '**This repo (Phase 3 automation):**\n\`\`\`\n' + tree + '\n\`\`\`'

pattern = r'\*\*This repo \(Phase 3 automation\):\*\*\n\`\`\`\n.*?\n\`\`\`'
updated = re.sub(pattern, new_block, content, flags=re.DOTALL)

if updated != content:
    with open('README.md', 'w') as f:
        f.write(updated)
    print('README.md file tree updated')
else:
    print('README.md file tree already current')
"
