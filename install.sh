#!/bin/bash
# Install checkpoint and bootstrap commands

mkdir -p ~/.local/bin

cat > ~/.local/bin/checkpoint << 'EOF'
#!/bin/bash
if [ -f .claude/scripts/checkpoint.sh ]; then
    bash .claude/scripts/checkpoint.sh
else
    echo "Run from a bootstrapped project directory."
    exit 1
fi
EOF
chmod +x ~/.local/bin/checkpoint

cat > ~/.local/bin/bootstrap << 'OUTER'
#!/bin/bash
if [ -f .claude/scripts/bootstrap.sh ]; then
    bash .claude/scripts/bootstrap.sh
else
    # First-time bootstrap: run directly from claude-os template
    TMPL="$HOME/claude-os/{<repo-name>}/.claude/scripts/bootstrap.sh"
    if [ -f "$TMPL" ]; then
        bash "$TMPL"
    else
        echo "claude-os not found at ~/claude-os. Clone it first."
        exit 1
    fi
fi
OUTER
chmod +x ~/.local/bin/bootstrap

# Set up shell config
SHELL_RC="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"

# Ensure ~/.local/bin is on PATH
if ! grep -q '\.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
fi

# Clean up legacy aliases (commands are now in ~/.local/bin)
grep -q 'alias checkpoint=' "$SHELL_RC" 2>/dev/null && sed -i '' '/alias checkpoint=/d' "$SHELL_RC"
grep -q 'alias bootstrap=' "$SHELL_RC" 2>/dev/null && sed -i '' '/alias bootstrap=/d' "$SHELL_RC"

# Install pre-push hook
CLAUDE_OS="$HOME/claude-os"
mkdir -p "$CLAUDE_OS/.git/hooks"
ln -sf "$CLAUDE_OS/{<repo-name>}/hooks/pre-push" "$CLAUDE_OS/.git/hooks/pre-push"

# Apply immediately
source "$SHELL_RC" 2>/dev/null

echo "Installed: checkpoint, bootstrap, pre-push hook (ready to use)"
