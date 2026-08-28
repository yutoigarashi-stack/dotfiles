# CLAUDE.md

## 開発フロー

- **開発モデル**: trunk-based development
- **ブランチ戦略**: `main` ブランチからトピックブランチを作成し、1 PR につき 1 ブランチ
  - 指定がない限り PR / トピックブランチの作成は必須
- **Stacked PR**: 変更が大きい場合や前の PR に依存する変更は、GitHub の stacked PR を活用し、レビュー可能な単位に分割すること
  - 依存先の PR がマージされたら、`git rebase --onto main <依存先ブランチ>` で squash 済みのコミットを取り除き、PR の base を `main` に変更する（`gh pr edit <number> --base main`）（squash merge によりコミット SHA が変わるうえ、リモートブランチを削除しないため GitHub による base の自動付け替えが効かず、放置すると重複コミットとコンフリクトが上位 PR に残るため）
- **ブランチ命名規則**: `<type>/<kebab-case-description>` 形式
  - type は Conventional Commits の type に準拠
  - 例: `docs/add-claude-md`, `refactor/install-script-link-function`
- **マージ方法**: squash merge で `main` へマージ
  - コミットメッセージの末尾に PR 番号を付与すること（例: `feat(auth): ログイン機能を追加 (#7)`）
  - `gh pr merge <number> --squash --subject "<type>(<scope>): <説明> (#<number>)"` を使用
- **ブランチ削除**: マージ後、ローカルブランチは削除する。リモートブランチは削除しない（コミットメッセージの PR 番号から作業記録を辿れるようにするため）
- **Git コマンド**: `git checkout` ではなく、目的別に分離された `git switch`（ブランチ切り替え）と `git restore`（ファイル復元）を使うこと
- **Git pull**: 未コミットの変更がある状態で `git pull` する場合は `--autostash` を付け、手動の `git stash` / `git stash pop` は使わないこと（stash スタックは worktree 間で共有され、並行セッションのエントリを誤って pop する恐れがあるため。autostash は通常の stash スタックを経由しない）

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
