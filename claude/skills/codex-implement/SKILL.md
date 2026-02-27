---
name: codex-implement
description: 実装タスクを Codex に委譲して Claude Code のトークンを節約する
---

実装タスクを Codex CLI に委譲して実行してください。

## 引数

`$ARGUMENTS` に実装タスクの説明が含まれます。必須です。
空の場合は、タスク説明の入力を案内してください。

## 実行フロー

1. Codex に `$ARGUMENTS` を渡して新規実行する
2. セッション ID を `${TMPDIR:-/tmp}/codex-session-id` に保存する
3. `git diff` で変更内容を確認する
4. プロジェクトのテストを実行する
5. 失敗時は `codex exec resume` で修正を依頼する（最大 3 回）
6. 実装内容とテスト結果を要約して返す

## 実行例

```bash
CODEX_TMPDIR="${TMPDIR:-/tmp}"
codex exec --sandbox workspace-write "$ARGUMENTS"
SESSION_FILE=$(ls -t ~/.codex/sessions/**/*.jsonl | head -1)
SESSION_ID=$(head -1 "$SESSION_FILE" | jq -r '.id')
echo "$SESSION_ID" > "${CODEX_TMPDIR}/codex-session-id"
```

```bash
codex exec resume "$(cat "${TMPDIR:-/tmp}/codex-session-id")" "<追加指示>"
```

## 重要

- Codex の成果物を自分でやり直さない
- レビュー → 修正のループは最大 3 回まで
- 長時間タスクで文脈が劣化した場合は新規セッションへ切り替える
