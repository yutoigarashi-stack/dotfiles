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
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` |
| `codex/config.toml` | `~/.codex/config.toml` |
| `nvim/init.lua` | `~/.config/nvim/init.lua` |
| `claude/agents/` | `~/.claude/agents/` |
| `claude/commands/` | `~/.claude/commands/` |

## Agent plugins

`install.sh` はmarketplace
[`yutoigarashi-stack/agent-skills`](https://github.com/yutoigarashi-stack/agent-skills)
をCodexとClaude Codeへ登録し、`anki-workflows` pluginをインストールする。

pluginの導入に成功すると、dotfilesが作成した次の旧skillリンクだけを削除する。

- `anki-add-cards`
- `reminders-to-anki`
