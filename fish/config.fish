if status is-interactive
    # Commands to run in interactive sessions can go here
end
set -gx MISE_ENV development,local
~/.local/bin/mise activate fish | source

# Homebrew
eval (/opt/homebrew/bin/brew shellenv fish)
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
