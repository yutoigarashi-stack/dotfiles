---
name: codex-implement
description: 実装タスクを Codex に委譲して Claude Code のトークンを節約する
---

実装タスクを Codex CLI に委譲し、コード実装とファイル編集まで実行してください。

## 引数

`$ARGUMENTS` に実装タスクの説明が含まれます。必須です。
空の場合は、タスク説明の入力を案内してください。

初回入力は次の 4 項目で構成する。

- `Task`: 1-2 文で目的を記述
- `Scope`: 主対象のファイルまたは対象ディレクトリ
- `Acceptance`: 受け入れ条件を 3 件以内
- `Constraints`: 禁止事項または技術制約

## 実行フロー

1. Level 1（最小入力）で Codex に `$ARGUMENTS` を渡し、実装と必要なファイル編集を実行させる
2. セッション ID を `${TMPDIR:-/tmp}/codex-session-id` に保存する
3. `git diff` で変更内容を確認する
4. プロジェクトのテストを実行する
5. 失敗時は段階的詳細化で `codex exec resume` に修正を依頼する（最大 3 回）
6. 実装内容とテスト結果を要約して返す
7. 3 回のリトライでも解決しない場合は、ユーザーに判断を委ねる

## 段階的詳細化（Level 1-3）

- `Level 1`: Task / Scope / Acceptance / Constraints のみで実行する
- `Level 2`: 失敗したテスト名やエラー要約を `Failure` として追加する
- `Level 3`: 前回との差分指示のみを `Delta` として追加する

`resume` 時は `Failure` と `Delta` のみを追記し、背景説明や過去ログの再掲を避ける。
`Scope` は主対象であり、実装完了に必要な関連編集は許可する。

## 出力フォーマット（固定）

Codex の最終出力は次の 3 セクション固定で要求する。

- `Summary`
- `Changed Files`
- `Validation`

## 実行テンプレート

詳細なシェル例は以下を参照:
`claude/skills/codex-implement/references/commands.md`

## 重要

- Codex の成果物を自分でやり直さない
- レビュー → 修正のループは最大 3 回まで
- 長時間タスクで文脈が劣化した場合は新規セッションへ切り替える
