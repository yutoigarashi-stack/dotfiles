# codex-reviewer command references

## 新規セッション

```bash
set -o pipefail
CODEX_TMPDIR="${TMPDIR:-/tmp}"
TARGET_PATH="${TARGET_PATH:-}"

if [[ -n "$TARGET_PATH" ]]; then
  DIFF=$(git diff main -- "$TARGET_PATH")
else
  DIFF=$(git diff main)
fi

COMMIT_HASH=$(git rev-parse --short HEAD)
PROMPT="Review the following code changes (commit: ${COMMIT_HASH}).

Focus on:
- Bugs, logic errors, null/nil pointer risks
- Error handling correctness
- Security concerns
- Code idioms and patterns consistent with the surrounding codebase

Diff:
${DIFF}

Output structured markdown. Score each issue 0-100 confidence.
Only report issues with confidence >= 80."

codex exec --sandbox read-only "$PROMPT" | tee "${CODEX_TMPDIR}/codex-review-latest.md"

SESSION_FILE=$(ls -t ~/.codex/sessions/**/*.jsonl | head -1)
SESSION_ID=$(head -1 "$SESSION_FILE" | jq -r '.id')
echo "$SESSION_ID" > "${CODEX_TMPDIR}/codex-review-session-id"
```

## resume セッション

このテンプレートは resume 専用。初回実行でセッション ID がない場合は新規セッションテンプレートを使う。

```bash
set -o pipefail
CODEX_TMPDIR="${TMPDIR:-/tmp}"
TARGET_PATH="${TARGET_PATH:-}"

if [[ ! -f "${CODEX_TMPDIR}/codex-review-session-id" ]]; then
  echo "前回セッションがないため新規実行します。" >&2
  exit 1
fi

SESSION_ID=$(cat "${CODEX_TMPDIR}/codex-review-session-id")

if [[ -n "$TARGET_PATH" ]]; then
  DIFF=$(git diff main -- "$TARGET_PATH")
else
  DIFF=$(git diff main)
fi

COMMIT_HASH=$(git rev-parse --short HEAD)
PROMPT="Developer addressed previous review. New commit: ${COMMIT_HASH}

New diff:
${DIFF}

Check if previous issues were fixed. Report any new issues.
If all resolved: output LGTM"

codex exec resume "$SESSION_ID" "$PROMPT" | tee "${CODEX_TMPDIR}/codex-review-latest.md"
```

## セッション整合性チェック（任意）

```bash
CODEX_TMPDIR="${TMPDIR:-/tmp}"
SESSION_FILE=$(ls -t ~/.codex/sessions/**/*.jsonl | head -1)
SESSION_CWD=$(head -1 "$SESSION_FILE" | jq -r '.cwd // empty')
CURRENT_DIR=$(pwd)

if [[ -n "$SESSION_CWD" && "$SESSION_CWD" != "$CURRENT_DIR" ]]; then
  rm -f "${CODEX_TMPDIR}/codex-review-session-id"
fi
```
