# codex-implement command references

## 新規実行

```bash
CODEX_TMPDIR="${TMPDIR:-/tmp}"
codex exec --sandbox workspace-write "$ARGUMENTS"
SESSION_FILE=$(ls -t ~/.codex/sessions/**/*.jsonl | head -1)
SESSION_ID=$(head -1 "$SESSION_FILE" | jq -r '.id')
echo "$SESSION_ID" > "${CODEX_TMPDIR}/codex-session-id"
```

## 継続実行（resume）

```bash
codex exec resume "$(cat "${TMPDIR:-/tmp}/codex-session-id")" "<追加指示>"
```
