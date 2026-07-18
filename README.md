# dotfiles

個人の設定ファイルを管理するリポジトリ。

## セットアップ

ワンライナーでセットアップする場合:

```bash
git clone https://github.com/yutoigarashi-stack/dotfiles.git && cd dotfiles && chmod +x install.sh && ./install.sh
```

既にリポジトリをクローン済みの場合:

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
| `claude/skills/` | `~/.claude/skills/` |
| `claude/commands/` | `~/.claude/commands/` |
| `codex/skills/*/` | `~/.codex/skills/*/`（個別リンク） |
| `.tmux.conf` | `~/.tmux.conf` |
