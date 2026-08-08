if status is-interactive
    # npmの代わりにpnpmを使用する
    alias npm pnpm
end
# Homebrew
eval (/opt/homebrew/bin/brew shellenv fish)

set -gx MISE_ENV development,local
~/.local/bin/mise activate fish | source
