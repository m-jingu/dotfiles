# ~/.zshenv: bootstrap only. Everything else lives in ~/.config/zsh.
#
# zsh looks for .zshenv in $ZDOTDIR (or $HOME when unset) before any other rc
# file, so ZDOTDIR has to be set here, outside ~/.config/zsh. zsh then reads
# .zprofile, .zshrc and .zlogin from $ZDOTDIR, but not $ZDOTDIR/.zshenv, which
# is sourced explicitly below. Kept in $HOME rather than /etc/zshenv so that
# machines without sudo work too.
export ZDOTDIR="$HOME/.config/zsh"

# Real environment settings (macOS only; install.sh does not link it on Linux).
[[ -r "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"
