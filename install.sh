#!/bin/bash
# Install checkpoint and bootstrap commands

mkdir -p ~/.local/bin

cat > ~/.local/bin/checkpoint << 'EOF'
#!/bin/bash
bash ~/claude-os/{repo}/.claude/scripts/5-checkpoint.sh
EOF
chmod +x ~/.local/bin/checkpoint

cat > ~/.local/bin/bootstrap << 'EOF'
#!/bin/bash
bash ~/claude-os/{repo}/.claude/scripts/6-bootstrap.sh
EOF
chmod +x ~/.local/bin/bootstrap

# Set up shell config
SHELL_RC="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"

# Ensure ~/.local/bin is on PATH
if ! grep -q '\.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
fi

# Add shell aliases
grep -q 'alias checkpoint=' "$SHELL_RC" 2>/dev/null && sed -i '' '/alias checkpoint=/d' "$SHELL_RC"
grep -q 'alias bootstrap=' "$SHELL_RC" 2>/dev/null && sed -i '' '/alias bootstrap=/d' "$SHELL_RC"
cat >> "$SHELL_RC" << 'ALIASES'

# Claude OS
alias checkpoint="bash ~/claude-os/{repo}/.claude/scripts/5-checkpoint.sh"
alias bootstrap="bash ~/claude-os/{repo}/.claude/scripts/6-bootstrap.sh"
ALIASES

# Install pre-push hook
CLAUDE_OS="$HOME/claude-os"
ln -sf "$CLAUDE_OS/{repo}/.claude/hooks/pre-push" "$CLAUDE_OS/.git/hooks/pre-push"

# Apply immediately
source "$SHELL_RC" 2>/dev/null

echo "Installed: checkpoint, bootstrap, pre-push hook (ready to use)"
