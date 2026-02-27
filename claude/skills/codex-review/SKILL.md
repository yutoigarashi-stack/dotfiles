---
name: codex-review
description: 現在の変更に対して Codex によるコードレビューを実行する
---

現在のブランチの変更に対して、Codex CLI を使ったコードレビューを実行してください。

## 手順

1. `git diff --stat main` で現在のブランチの変更概要を確認する
2. 変更がない場合は、その旨を報告して終了する
3. `@codex-reviewer` subagent を呼び出してレビューを Codex に委譲する
   - $ARGUMENTS が指定されている場合はファイルパスとして扱い、`TARGET_PATH=$ARGUMENTS` として subagent に伝える
   - $ARGUMENTS が未指定の場合はブランチ全体の diff をレビュー対象とする
4. subagent からの結果をユーザーに提示する
5. 指摘がある場合、修正するかどうかをユーザーに確認する

## 重要

- 自分自身でレビューを行わないこと。必ず Codex に委譲する
- レビュー結果の生ファイルは `${TMPDIR:-/tmp}/codex-review-latest.md` に保存される
