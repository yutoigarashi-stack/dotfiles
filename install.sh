#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        -h|--help)
            echo "使い方: $0 [--dry-run]"
            echo "  --dry-run  変更せずに実行予定を表示する"
            exit 0 ;;
        *) echo "不明な引数: $arg" >&2; exit 1 ;;
    esac
done

# 変更するコマンドは必ずこの関数を経由する
run() {
    if "$DRY_RUN"; then
        printf '[dry-run]'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

# シンボリックリンクを作成する関数
# 既存ファイルがある場合は上書きするか確認する
link_file() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [[ ! -e "$src" ]]; then
        echo "警告: $name のリンク元が存在しません: $src" >&2
        return 1
    fi

    # 既に正しいリンクの場合はスキップ
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        echo "スキップ: $name (既にリンク済み)"
        return
    fi

    # 既存ファイル/ディレクトリがある場合は上書き確認
    if [[ -e "$dest" || -L "$dest" ]]; then
        if ! "$DRY_RUN"; then
            echo -n "$dest は既に存在します。バックアップして置き換えますか? [y/N] "
            local answer
            if ! read -r answer || [[ "$answer" != "y" && "$answer" != "Y" ]]; then
                echo "スキップ: $name"
                return
            fi
        fi
        local backup_base
        backup_base="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        local backup="$backup_base"
        local index=0
        while [[ -e "$backup" || -L "$backup" ]]; do
            index=$((index + 1))
            backup="${backup_base}.${index}"
        done
        echo "バックアップ: $dest -> $backup"
        run mv "$dest" "$backup"
    fi

    run ln -s "$src" "$dest"
    echo "$name -> $dest"
}

# plugin への移行後に、dotfiles が作成した旧 skill リンクだけを外す
remove_legacy_skill_link() {
    local dest="$1"
    local expected_src="$2"
    local name="$3"

    if [[ -L "$dest" && "$(readlink "$dest")" == "$expected_src" ]]; then
        run rm -f "$dest"
        echo "移行: $name の旧 skill リンクを削除"
    elif [[ -e "$dest" || -L "$dest" ]]; then
        echo "維持: $name ($dest はdotfilesが作成した旧リンクではありません)"
    fi
}

# fish
if ! command -v brew &>/dev/null; then
    echo "エラー: Homebrew を先にインストールしてください" >&2
    exit 1
fi
if ! brew list fish &>/dev/null; then
    echo "fish をインストールしています..."
    run brew install fish
fi
run mkdir -p "$HOME/.config/fish"
link_file "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish" "fish/config.fish"

# Ghostty
GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
run mkdir -p "$GHOSTTY_CONFIG_DIR"
link_file "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_CONFIG_DIR/config" "ghostty/config"

# Herdr
run mkdir -p "$HOME/.config/herdr"
link_file "$DOTFILES_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml" "herdr/config.toml"
# herdr バイナリに同梱された skill (`herdr --skill` の出力) を agents/skills/herdr に
# コミットして管理し、各エージェントの skills ディレクトリへリンクする。
# バイナリ側が更新されてコミット済みの内容とずれたら警告する（更新は手動で PR にする）
HERDR_SKILL_DIR="$DOTFILES_DIR/agents/skills/herdr"
if ! "$DRY_RUN" && command -v herdr &>/dev/null; then
    if ! diff -q <(herdr --skill) "$HERDR_SKILL_DIR/SKILL.md" >/dev/null; then
        echo "警告: agents/skills/herdr/SKILL.md が herdr $(herdr --version | awk '{print $2}') の \`herdr --skill\` と異なります"
        echo "      herdr --skill > agents/skills/herdr/SKILL.md で更新してコミットしてください"
    fi
fi

# Claude Code
run mkdir -p "$HOME/.claude"
link_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json" "claude/settings.json"
link_file "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md" "claude/CLAUDE.md"
# 以前は ~/.claude/skills ごと dotfiles にリンクしていたが、そのディレクトリは廃止済みで
# リンクが壊れているため外し、実ディレクトリに skill を個別にリンクする
remove_legacy_skill_link "$HOME/.claude/skills" "$DOTFILES_DIR/claude/skills" "claude/skills"
run mkdir -p "$HOME/.claude/skills"
link_file "$HERDR_SKILL_DIR" "$HOME/.claude/skills/herdr" "agents/skills/herdr"
if command -v claude &>/dev/null; then
    run claude plugin marketplace add yutoigarashi-stack/agent-skills --scope user
    run claude plugin marketplace update yutoigarashi-skills
    run claude plugin install anki-workflows@yutoigarashi-skills --scope user
    run claude plugin install git-workflows@yutoigarashi-skills --scope user
    run claude plugin update anki-workflows@yutoigarashi-skills --scope user
    run claude plugin update git-workflows@yutoigarashi-skills --scope user
    remove_legacy_skill_link "$HOME/.claude/skills/anki-add-cards" "$DOTFILES_DIR/claude/skills/anki-add-cards" "claude/skills/anki-add-cards"
    remove_legacy_skill_link "$HOME/.claude/skills/reminders-to-anki" "$DOTFILES_DIR/claude/skills/reminders-to-anki" "claude/skills/reminders-to-anki"
else
    echo "スキップ: Anki Workflows plugin (Claude Codeが見つかりません)"
fi

# Codex
run mkdir -p "$HOME/.codex"
link_file "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "codex/AGENTS.md"
link_file "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml" "codex/config.toml"
# ファイル単位のリンクではCodexが.rulesを読み込まないため、ディレクトリごとリンクする
link_file "$DOTFILES_DIR/codex/rules" "$HOME/.codex/rules" "codex/rules"
run mkdir -p "$HOME/.codex/skills"
link_file "$HERDR_SKILL_DIR" "$HOME/.codex/skills/herdr" "agents/skills/herdr"
if command -v codex &>/dev/null; then
    run codex plugin marketplace add yutoigarashi-stack/agent-skills --ref main
    run codex plugin marketplace upgrade yutoigarashi-skills
    run codex plugin add anki-workflows@yutoigarashi-skills
    run codex plugin add git-workflows@yutoigarashi-skills
    remove_legacy_skill_link "$HOME/.codex/skills/anki-add-cards" "$DOTFILES_DIR/codex/skills/anki-add-cards" "codex/skills/anki-add-cards"
    remove_legacy_skill_link "$HOME/.codex/skills/reminders-to-anki" "$DOTFILES_DIR/codex/skills/reminders-to-anki" "codex/skills/reminders-to-anki"
else
    echo "スキップ: Anki Workflows plugin (Codexが見つかりません)"
fi

# Neovim
run mkdir -p "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua" "nvim/init.lua"
link_file "$DOTFILES_DIR/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json" "nvim/lazy-lock.json"

if "$DRY_RUN"; then
    echo "dry-run 完了（既存パスの置き換えは承認した場合の予定）"
else
    echo "完了"
fi
