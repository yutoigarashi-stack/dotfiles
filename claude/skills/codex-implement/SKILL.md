---
name: codex-implement
description: 実装タスクを Codex に委譲して Claude Code のトークンを節約する
---

実装タスクを Codex CLI に委譲して実行してください。

## 引数

$ARGUMENTS に実装タスクの説明が含まれています。この引数は必須です。
引数が空の場合は、タスクの説明を入力するようユーザーに案内してください。

## 手順

1. Codex にタスクを委譲する:
   ```bash
   CODEX_TMPDIR="${TMPDIR:-/tmp}"
   codex exec --sandbox workspace-write "$ARGUMENTS"
   SESSION_ID=$(head -1 "$(ls -t ~/.codex/sessions/**/*.jsonl | head -1)" | jq -r '.id')
   echo "$SESSION_ID" > "${CODEX_TMPDIR}/codex-session-id"
   ```
2. Codex 完了後、変更内容を確認する:
   ```bash
   git diff
   ```
3. プロジェクトのテストコマンドを判定して実行する（例: `go test ./...`, `npm test`, `pytest` など）
4. 実装内容とテスト結果をユーザーに要約する
5. テストが失敗した場合、resume で Codex に修正を依頼する（最大 3 回）:
   ```bash
   codex exec resume "$(cat "${CODEX_TMPDIR}/codex-session-id")" "Tests failed. Fix the failures shown below: <テスト出力>"
   ```
6. 3 回のリトライでも解決しない場合は、ユーザーに判断を委ねる

## 重要

- Codex の成果物を自分でやり直してはならない
- レビュー → 修正のループは最大 3 回まで
- Codex セッションが長くなりすぎた場合は新規セッションに切り替える
