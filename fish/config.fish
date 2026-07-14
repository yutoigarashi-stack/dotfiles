if status is-interactive
    # Commands to run in interactive sessions can go here
end
# Homebrew
eval (/opt/homebrew/bin/brew shellenv fish)

set -gx MISE_ENV development,local
~/.local/bin/mise activate fish | source
