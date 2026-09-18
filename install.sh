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

# plugin への移行後に、dotfiles が作成した旧 skill リンクだけを外す
remove_legacy_skill_link() {
    local dest="$1"
    local expected_src="$2"
    local name="$3"

    if [[ -L "$dest" && "$(readlink "$dest")" == "$expected_src" ]]; then
        rm -f "$dest"
        echo "移行: $name の旧 skill リンクを削除"
    elif [[ -e "$dest" || -L "$dest" ]]; then
        echo "維持: $name ($dest はdotfilesが作成した旧リンクではありません)"
    fi
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
# herdr バイナリに同梱された skill (`herdr --skill` の出力) を agents/skills/herdr に
# コミットして管理し、各エージェントの skills ディレクトリへリンクする。
# バイナリ側が更新されてコミット済みの内容とずれたら警告する（更新は手動で PR にする）
HERDR_SKILL_DIR="$DOTFILES_DIR/agents/skills/herdr"
if command -v herdr &>/dev/null; then
    if ! diff -q <(herdr --skill) "$HERDR_SKILL_DIR/SKILL.md" >/dev/null; then
        echo "警告: agents/skills/herdr/SKILL.md が herdr $(herdr --version | awk '{print $2}') の \`herdr --skill\` と異なります"
        echo "      herdr --skill > agents/skills/herdr/SKILL.md で更新してコミットしてください"
    fi
fi

# Claude Code
mkdir -p "$HOME/.claude"
link_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json" "claude/settings.json"
link_file "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md" "claude/CLAUDE.md"
link_file "$DOTFILES_DIR/claude/agents" "$HOME/.claude/agents" "claude/agents"
link_file "$DOTFILES_DIR/claude/commands" "$HOME/.claude/commands" "claude/commands"
# 以前は ~/.claude/skills ごと dotfiles にリンクしていたが、そのディレクトリは廃止済みで
# リンクが壊れているため外し、実ディレクトリに skill を個別にリンクする
remove_legacy_skill_link "$HOME/.claude/skills" "$DOTFILES_DIR/claude/skills" "claude/skills"
mkdir -p "$HOME/.claude/skills"
link_file "$HERDR_SKILL_DIR" "$HOME/.claude/skills/herdr" "agents/skills/herdr"
if command -v claude &>/dev/null; then
    claude plugin marketplace add yutoigarashi-stack/agent-skills --scope user
    claude plugin marketplace update yutoigarashi-skills
    claude plugin install anki-workflows@yutoigarashi-skills --scope user
    claude plugin install git-workflows@yutoigarashi-skills --scope user
    claude plugin update anki-workflows@yutoigarashi-skills --scope user
    claude plugin update git-workflows@yutoigarashi-skills --scope user
    remove_legacy_skill_link "$HOME/.claude/skills/anki-add-cards" "$DOTFILES_DIR/claude/skills/anki-add-cards" "claude/skills/anki-add-cards"
    remove_legacy_skill_link "$HOME/.claude/skills/reminders-to-anki" "$DOTFILES_DIR/claude/skills/reminders-to-anki" "claude/skills/reminders-to-anki"
else
    echo "スキップ: Anki Workflows plugin (Claude Codeが見つかりません)"
fi

# Codex
mkdir -p "$HOME/.codex"
link_file "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "codex/AGENTS.md"
link_file "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml" "codex/config.toml"
# ファイル単位のリンクではCodexが.rulesを読み込まないため、ディレクトリごとリンクする
link_file "$DOTFILES_DIR/codex/rules" "$HOME/.codex/rules" "codex/rules"
mkdir -p "$HOME/.codex/skills"
link_file "$HERDR_SKILL_DIR" "$HOME/.codex/skills/herdr" "agents/skills/herdr"
if command -v codex &>/dev/null; then
    codex plugin marketplace add yutoigarashi-stack/agent-skills --ref main
    codex plugin marketplace upgrade yutoigarashi-skills
    codex plugin add anki-workflows@yutoigarashi-skills
    codex plugin add git-workflows@yutoigarashi-skills
    remove_legacy_skill_link "$HOME/.codex/skills/anki-add-cards" "$DOTFILES_DIR/codex/skills/anki-add-cards" "codex/skills/anki-add-cards"
    remove_legacy_skill_link "$HOME/.codex/skills/reminders-to-anki" "$DOTFILES_DIR/codex/skills/reminders-to-anki" "codex/skills/reminders-to-anki"
else
    echo "スキップ: Anki Workflows plugin (Codexが見つかりません)"
fi

# Neovim
mkdir -p "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua" "nvim/init.lua"

echo "完了"
