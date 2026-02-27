#!/bin/bash
# 3-promote.sh — Runs every ~2.3 days (test) / weekly (prod)
# Reads MEMORY.md for stable patterns and promotes them to .claude/CLAUDE.md

PROJECT_DIR="/Users/james.niu/media-strategy-generator"
MEMORY_DIR="/Users/james.niu/.claude/projects/-Users-james-niu-media-strategy-generator/memory"
CLAUDE_MD="$PROJECT_DIR/.claude/CLAUDE.md"
LOG_DIR="/Users/james.niu/scripts/claude-memory/output"

mkdir -p "$LOG_DIR"

echo "$(date): Starting promote..." >> "$LOG_DIR/3-promote.log"

cd "$PROJECT_DIR"

claude -p "You are a rule promoter. Read both files:
1. $MEMORY_DIR/MEMORY.md (learned patterns)
2. $CLAUDE_MD (current personal rules)

Your job:
- Look for patterns in MEMORY.md that are stable and recurring (appeared 3+ times or confirmed across multiple sessions)
- Check if these patterns are already captured as rules in .claude/CLAUDE.md
- If a pattern is stable but NOT yet a rule, add it to the appropriate section in .claude/CLAUDE.md
- If a pattern contradicts an existing rule, flag it but do NOT change the rule (leave a comment in your output)
- Do NOT remove existing rules
- Do NOT add speculative or single-occurrence patterns
- Keep .claude/CLAUDE.md concise and actionable

Output what you promoted (or 'No new promotions' if nothing qualified)." \
  --allowedTools "Read,Edit" \
  --permission-mode bypassPermissions \
  --max-budget-usd 0.10 \
  -p >> "$LOG_DIR/3-promote.log" 2>&1

echo "$(date): Promote complete" >> "$LOG_DIR/3-promote.log"
