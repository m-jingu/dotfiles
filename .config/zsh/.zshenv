# ~/.config/zsh/.zshenv (macOS and Linux; Mac-only parts check $OSTYPE).
# Sourced from ~/.zshenv, which sets ZDOTDIR=~/.config/zsh.

# ---------- XDG base directories ----------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Exporting the XDG_* variables above changes where some tools look on macOS:
# lazygit uses ~/.config/lazygit instead of ~/Library/Application Support/lazygit
# (accepted 2026-11-05). glow and Go's os.UserConfigDir ignore them.
# less (590+) already keeps its history in $XDG_STATE_HOME/lesshst.

# Keep per-tool state out of $HOME for tools that do not follow XDG on their
# own. Only CLI tools started from zsh see these; GUI apps do not.
export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/npmrc"
export NPM_CONFIG_CACHE="$HOME/.cache/npm"
export PYTHON_HISTORY="$HOME/.local/state/python/history"   # Python 3.13+
export REDISCLI_HISTFILE="$HOME/.local/state/redis/rediscli_history"
export WGETRC="$HOME/.config/wget/wgetrc"
export MPLCONFIGDIR="$HOME/.config/matplotlib"
export PARALLEL_HOME="$HOME/.config/parallel"
export ANSIBLE_HOME="$HOME/.local/share/ansible"
export BUNDLE_USER_HOME="$HOME/.local/share/bundle"

# ---------- Editor ----------
# Default editor used by git, crontab, etc.
export EDITOR="vim"
export VISUAL="vim"

# ---------- Pager ----------
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# ---------- PATH ----------
# Keep PATH free of duplicates: nested shells (zellij panes, scripts) source
# this file again on top of an already populated PATH.
typeset -U path PATH

# Personal binaries/scripts
export PATH="$HOME/.local/bin:$PATH"

# Homebrew for every zsh on macOS, including non-interactive ones. Login shells
# reorder PATH afterwards through path_helper; .zprofile restores the order.
if [[ "$OSTYPE" == darwin* ]]; then
  path=(/opt/homebrew/bin /opt/homebrew/sbin /opt/homebrew/opt/unzip/bin $path)
fi

# Trust an internal CA so Node (Claude Code MCP over https) can verify
# an internal server certificate.
# Skipped on Macs without the certificate, where Node would warn on every run.
[[ -r "$HOME/.config/certs/internal-ca.pem" ]] &&
  export NODE_EXTRA_CA_CERTS="$HOME/.config/certs/internal-ca.pem"

# ---------- Starship ----------
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"

