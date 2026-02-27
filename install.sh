#!/bin/bash
# Install checkpoint and bootstrap commands

mkdir -p ~/.local/bin

cat > ~/.local/bin/checkpoint << 'EOF'
#!/bin/bash
bash ~/claude-os/scripts/5-checkpoint.sh
EOF
chmod +x ~/.local/bin/checkpoint

cat > ~/.local/bin/bootstrap << 'EOF'
#!/bin/bash
bash ~/claude-os/scripts/6-init.sh
EOF
chmod +x ~/.local/bin/bootstrap

# Ensure ~/.local/bin is on PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    SHELL_RC="$HOME/.zshrc"
    [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo "Added ~/.local/bin to PATH in $SHELL_RC. Run: source $SHELL_RC"
fi

echo "Installed: checkpoint, bootstrap"
