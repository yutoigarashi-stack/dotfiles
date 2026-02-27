# CLAUDE.md

## 開発フロー

- **開発モデル**: trunk-based development
- **ブランチ戦略**: `main` ブランチからトピックブランチを作成し、1 PR につき 1 ブランチ
  - 指定がない限り PR / トピックブランチの作成は必須
- **ブランチ命名規則**: `<type>/<kebab-case-description>` 形式
  - type は Conventional Commits の type に準拠
  - 例: `docs/add-claude-md`, `refactor/install-script-link-function`
- **マージ方法**: squash merge で `main` へマージ
  - コミットメッセージの末尾に PR 番号を付与すること（例: `feat(auth): ログイン機能を追加 (#7)`）
  - `gh pr merge <number> --squash --subject "<type>(<scope>): <説明> (#<number>)"` を使用
- **ブランチ削除**: マージ後、ローカルブランチは削除する。リモートブランチは削除しない（コミットメッセージの PR 番号から作業記録を辿れるようにするため）
- **Git コマンド**: `git checkout` ではなく、目的別に分離された `git switch`（ブランチ切り替え）と `git restore`（ファイル復元）を使うこと

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
