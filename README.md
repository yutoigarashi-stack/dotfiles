# dotfiles

個人の設定ファイルを管理するリポジトリ。

## セットアップ

```bash
chmod +x install.sh
./install.sh
```

## 配置先

| ファイル | シンボリックリンク先 |
| --- | --- |
| `fish/config.fish` | `~/.config/fish/config.fish` |
| `ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` |
| `codex/config.toml` | `~/.codex/config.toml` |
| `codex/rules/` | `~/.codex/rules/` |
| `nvim/init.lua` | `~/.config/nvim/init.lua` |
| `claude/agents/` | `~/.claude/agents/` |
| `claude/commands/` | `~/.claude/commands/` |
| `agents/skills/herdr/` | `~/.claude/skills/herdr/`, `~/.codex/skills/herdr/` |

## Agent plugins

`install.sh` はmarketplace
[`yutoigarashi-stack/agent-skills`](https://github.com/yutoigarashi-stack/agent-skills)
をCodexとClaude Codeへ登録し、次のpluginをインストールする。

- `anki-workflows`
- `git-workflows`

pluginの導入に成功すると、dotfilesが作成した次の旧skillリンクだけを削除する。

- `anki-add-cards`
- `reminders-to-anki`

## Herdr skill

`agents/skills/herdr/SKILL.md` は `herdr` バイナリに同梱された skill（`herdr --skill` の出力）を
そのままコミットしたもので、`install.sh` が Claude Code と Codex の skills ディレクトリへリンクする。

`install.sh` はインストール済みの `herdr --skill` とコミット済みの内容を比較し、
ずれていれば警告する。`herdr update` の後に警告が出たら次のコマンドで更新し、PR にする。

```bash
herdr --skill > agents/skills/herdr/SKILL.md
```
