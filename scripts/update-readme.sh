#!/bin/bash
# update-readme.sh - Validate that the file tree in README.md is up to date
# The file tree is now a manually maintained bullet list (not auto-generated)
# This script checks that key files mentioned in the README actually exist

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

MISSING=0

check_file() {
    if [ ! -e "$1" ]; then
        echo "MISSING: $1 (referenced in README.md)"
        MISSING=$((MISSING + 1))
    fi
}

check_file "install.sh"
check_file "scripts/1-log.sh"
check_file "scripts/2-distill.sh"
check_file "scripts/3-promote.sh"
check_file "scripts/4-sync-confluence.sh"
check_file "scripts/5-checkpoint.sh"
check_file "scripts/6-init.sh"
check_file "scripts/update-readme.sh"
check_file "tests/test.sh"
check_file "launchd/com.claude.memory-log.plist"
check_file "launchd/com.claude.memory-distill.plist"
check_file "launchd/com.claude.memory-promote.plist"
check_file "launchd/com.claude.memory-sync.plist"
check_file ".github/workflows/test.yml"
check_file "EXAMPLES"

if [ "$MISSING" -eq 0 ]; then
    echo "All files referenced in README.md exist."
else
    echo "$MISSING file(s) missing."
    exit 1
fi
