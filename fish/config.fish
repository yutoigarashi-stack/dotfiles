# Homebrew
eval (/opt/homebrew/bin/brew shellenv fish)

set -gx MISE_ENV development,local
~/.local/bin/mise activate fish | source

# herdr のペイン内では、ペイン名をカレントディレクトリに追従させる
if set -q HERDR_PANE_ID
    function __update_herdr_pane_title --on-variable PWD
        set -l dir_label (string replace -r -- '^'(string escape --style=regex -- $HOME) '~' $PWD)
        # 終了時のジョブ通知を出さないよう disown する
        herdr pane rename $HERDR_PANE_ID $dir_label >/dev/null 2>&1 &
        disown
    end

    # シェル起動時にも反映
    __update_herdr_pane_title
end
