# CLAUDE.md

## 開発フロー

- **開発モデル**: trunk-based development
- **ブランチ戦略**: `main` ブランチからトピックブランチを作成し、1 PR につき 1 ブランチ
  - 指定がない限り PR / トピックブランチの作成は必須
- **Stacked PR**: 変更が大きい場合や前の PR に依存する変更は、`gh stack`（`init` / `add` / `submit`）で stacked PR を作り、レビュー可能な単位に分割すること
  - マージは従来どおり PR ごとに `gh pr merge <number> --squash --subject "..."` で行う（`gh stack merge` は stack 単位のアトミックマージで `--subject` 相当のオプションがなく、コミットメッセージ規約を満たせないため）
  - 依存先の PR がマージされたら `gh stack sync` を実行する。マージ済みレイヤーの取り除き（`git rebase --onto` 相当）と上位 PR の base 付け替えは `gh stack` が行うため、`git rebase --onto` や `gh pr edit --base` を手動で実行しないこと（手作業と `gh stack` の管理が混在すると stack メタデータと実態が食い違い、sync が diverged 扱いで中断する原因になるため）
  - マージ済みブランチの削除は `gh stack sync --prune` で行う（削除されるのはローカルブランチのみ）
- **ブランチ命名規則**: `<type>/<kebab-case-description>` 形式
  - type は Conventional Commits の type に準拠
  - 例: `docs/add-claude-md`, `refactor/install-script-link-function`
- **マージ方法**: squash merge で `main` へマージ
  - コミットメッセージの末尾に PR 番号を付与すること（例: `feat(auth): ログイン機能を追加 (#7)`）
  - `gh pr merge <number> --squash --subject "<type>(<scope>): <説明> (#<number>)"` を使用
- **ブランチ削除**: マージ後、ローカルブランチは削除する。リモートブランチは削除しない（コミットメッセージの PR 番号から作業記録を辿れるようにするため）
- **Git コマンド**: `git checkout` ではなく、目的別に分離された `git switch`（ブランチ切り替え）と `git restore`（ファイル復元）を使うこと

## パッケージ管理

- **パッケージマネージャー**: npm は使用せず、**pnpm** を使用すること
- **バージョン指定**: `latest` は使用せず、具体的なバージョンを指定すること

## 設計レビュー

- エージェントに設計レビューを依頼する際は、各判断を可逆性と変更コストで分類させること
- 後から容易に変更できる低コストな要素は原則としてレビュー対象から外し、データモデル、外部インターフェース、セキュリティ境界、状態移行、外部依存など変更が困難な判断に集中させること
- 容易に変更できる要素でも、正確性、セキュリティ、データ損失、運用停止に関わる問題は無視させないこと

## Git コミットメッセージ規約

- コミットメッセージは必ず**日本語**で記述すること
- **Conventional Commits** の形式に従うこと

### フォーマット

```
<type>(<scope>): <日本語の説明>

[任意の本文]

[任意のフッター]
```

### Type の種類

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（空白、フォーマット等）
- `refactor`: バグ修正でも機能追加でもないコード変更
- `perf`: パフォーマンス改善
- `test`: テストの追加・修正
- `chore`: ビルドプロセスやツールの変更

### 例

```
feat(auth): ログイン機能を追加

fix(api): ユーザー取得時のnullエラーを修正

docs(readme): インストール手順を更新

refactor(utils): 日付処理関数を整理
```
