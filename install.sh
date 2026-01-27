#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ghostty
GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$GHOSTTY_CONFIG_DIR"
ln -snf "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
echo "ghostty/config -> $GHOSTTY_CONFIG_DIR/config"

# Claude Code
mkdir -p "$HOME/.claude"
ln -snf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
echo "claude/settings.json -> ~/.claude/settings.json"

echo "完了"
