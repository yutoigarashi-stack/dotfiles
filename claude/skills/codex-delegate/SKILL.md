---
name: codex-delegate
description: 反復的な実装タスクを Codex CLI に委譲して Claude Code のトークンを節約する。テスト作成、lint 修正、ボイラープレート生成、マイグレーションスキャフォールディング時に自動トリガーされる。
---

# codex-delegate

反復的な実装タスクを Codex CLI に委譲し、Claude Code のトークン消費を節約する skill。

## 委譲すべきタスク

- テストの作成とパスするまでの反復
- lint / format エラーの一括修正
- ボイラープレート生成
- 一括リファクタリング（find-and-replace 的な作業）
- ドキュメント生成

## 委譲すべきでないタスク

- アーキテクチャの判断
- 会話の全コンテキストが必要な複雑なデバッグ
- 設計レベルの意思決定

## 実行方法

### 新規タスク

```bash
CODEX_TMPDIR="${TMPDIR:-/tmp}"
codex exec --sandbox workspace-write "<タスクの説明>"
SESSION_ID=$(head -1 "$(ls -t ~/.codex/sessions/**/*.jsonl | head -1)" | jq -r '.id')
echo "$SESSION_ID" > "${CODEX_TMPDIR}/codex-session-id"
```

### 前回セッションの継続

```bash
CODEX_TMPDIR="${TMPDIR:-/tmp}"
SESSION_ID=$(cat "${CODEX_TMPDIR}/codex-session-id")
codex exec resume "$SESSION_ID" "<追加指示>"
```

## 委譲後の手順

1. `git diff` で Codex の変更内容を確認する
2. プロジェクトのテストコマンドを判定して実行する（例: `go test ./...`, `npm test`, `pytest` など）
3. 変更内容をユーザーに要約する。Codex の成果物をやり直してはならない
