#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# シンボリックリンクを作成する関数
# 既存ファイルがある場合は上書きするか確認する
link_file() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [[ -e "$dest" || -L "$dest" ]]; then
        # 既に正しいリンクの場合はスキップ
        if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
            echo "スキップ: $name (既にリンク済み)"
            return
        fi

        echo -n "$dest は既に存在します。上書きしますか? [y/N] "
        read -r answer
        if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
            echo "スキップ: $name"
            return
        fi
    fi

    ln -snf "$src" "$dest"
    echo "$name -> $dest"
}

# Ghostty
GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$GHOSTTY_CONFIG_DIR"
link_file "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_CONFIG_DIR/config" "ghostty/config"

# Claude Code
mkdir -p "$HOME/.claude"
link_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json" "claude/settings.json"
link_file "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md" "claude/CLAUDE.md"

# tmux
link_file "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf" ".tmux.conf"

echo "完了"
