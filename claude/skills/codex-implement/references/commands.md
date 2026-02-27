# codex-implement command references

## 新規実行

```bash
CODEX_TMPDIR="${TMPDIR:-/tmp}"
PROMPT=$(cat <<EOF
$ARGUMENTS

実装を完了するために、必要なファイル編集を実際に実行してください。
Scope は主対象を示すもので、関連する最小限の変更は許可します。

出力は次の3セクションのみ:
- Summary
- Changed Files
- Validation
EOF
)

codex exec --sandbox workspace-write "$PROMPT"
SESSION_FILE=$(ls -t ~/.codex/sessions/**/*.jsonl | head -1)
SESSION_ID=$(head -1 "$SESSION_FILE" | jq -r '.id')
echo "$SESSION_ID" > "${CODEX_TMPDIR}/codex-session-id"
```

## 継続実行（resume）

```bash
SESSION_ID="$(cat "${TMPDIR:-/tmp}/codex-session-id")"
FAILURE="<失敗したテスト名とエラー要約>"
DELTA="<前回との差分指示のみ>"

PROMPT=$(cat <<EOF
Failure:
$FAILURE

Delta:
$DELTA

不足分の実装と必要なファイル編集を実際に実行してください。

出力は次の3セクションのみ:
- Summary
- Changed Files
- Validation
EOF
)

codex exec resume "$SESSION_ID" "$PROMPT"
```

## 任意: 出力スキーマで固定する

```bash
codex exec --sandbox workspace-write \
  --output-schema ./claude/skills/codex-implement/references/output-schema.json \
  "$PROMPT"
```
