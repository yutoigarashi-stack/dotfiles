#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# シンボリックリンクを作成する関数
# 既存ファイルがある場合は上書きするか確認する
link_file() {
    local src="$1"
    local dest="$2"
    local name="$3"

    # 既に正しいリンクの場合はスキップ
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        echo "スキップ: $name (既にリンク済み)"
        return
    fi

    # 既存ファイル/ディレクトリがある場合は上書き確認
    if [[ -e "$dest" || -L "$dest" ]]; then
        echo -n "$dest は既に存在します。上書きしますか? [y/N] "
        read -r answer
        if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
            echo "スキップ: $name"
            return
        fi
        if [[ -d "$dest" && ! -L "$dest" ]]; then
            local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
            echo "バックアップ: $dest -> $backup"
            mv "$dest" "$backup"
        else
            rm -f "$dest"
        fi
    fi

    ln -s "$src" "$dest"
    echo "$name -> $dest"
}

# skills の配置先を、個別リンクを格納できる実ディレクトリにする
prepare_skills_directory() {
    local dest="$1"
    local legacy_src="$2"
    local name="$3"
    local answer
    local backup

    # 旧方式のディレクトリ全体リンクは、リンクだけを外して移行する
    if [[ -L "$dest" && "$(readlink "$dest")" == "$legacy_src" ]]; then
        rm -f "$dest"
        echo "移行: $name のディレクトリ全体リンクを個別リンク方式へ変更"
    elif [[ -L "$dest" ]]; then
        echo -n "$dest は別のシンボリックリンクです。バックアップして個別リンク方式へ変更しますか? [y/N] "
        read -r answer
        if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
            echo "スキップ: $name"
            return 1
        fi
        backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        echo "バックアップ: $dest -> $backup"
    elif [[ -e "$dest" && ! -d "$dest" ]]; then
        echo -n "$dest はディレクトリではありません。バックアップして個別リンク方式へ変更しますか? [y/N] "
        read -r answer
        if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
            echo "スキップ: $name"
            return 1
        fi
        backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        echo "バックアップ: $dest -> $backup"
    fi

    mkdir -p "$dest"
}

# リポジトリ内の各 skill を配置先へ個別にリンクする
link_skills() {
    local src_dir="$1"
    local dest_dir="$2"
    local name_prefix="$3"
    local skill_dir

    for skill_dir in "$src_dir"/*/; do
        if [[ -d "$skill_dir" ]]; then
            local skill_name
            skill_name="$(basename "$skill_dir")"
            link_file "${skill_dir%/}" "$dest_dir/$skill_name" "$name_prefix/$skill_name"
        fi
    done
}

# fish
if ! brew list fish &>/dev/null; then
    echo "fish をインストールしています..."
    brew install fish
fi
mkdir -p "$HOME/.config/fish"
link_file "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish" "fish/config.fish"

# Ghostty
GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$GHOSTTY_CONFIG_DIR"
link_file "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_CONFIG_DIR/config" "ghostty/config"

# Herdr
mkdir -p "$HOME/.config/herdr"
link_file "$DOTFILES_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml" "herdr/config.toml"

# Claude Code
mkdir -p "$HOME/.claude"
link_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json" "claude/settings.json"
link_file "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md" "claude/CLAUDE.md"
link_file "$DOTFILES_DIR/claude/agents" "$HOME/.claude/agents" "claude/agents"
link_file "$DOTFILES_DIR/claude/commands" "$HOME/.claude/commands" "claude/commands"
if prepare_skills_directory "$HOME/.claude/skills" "$DOTFILES_DIR/claude/skills" "claude/skills"; then
    link_skills "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills" "claude/skills"
fi

# Codex
mkdir -p "$HOME/.codex"
link_file "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "codex/AGENTS.md"
link_file "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml" "codex/config.toml"
if prepare_skills_directory "$HOME/.codex/skills" "" "codex/skills"; then
    link_skills "$DOTFILES_DIR/codex/skills" "$HOME/.codex/skills" "codex/skills"
fi

# Neovim
mkdir -p "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua" "nvim/init.lua"

echo "完了"
