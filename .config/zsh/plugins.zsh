## ============================================
## プラグイン設定
## ============================================
# Plugins are plain git clones under ~/.local/share/zsh/plugins (install.sh clones them;
# update with `git -C ~/.local/share/zsh/plugins/<name> pull`). Sourcing them directly
# replaces zplug, which alone took ~350ms of every shell startup.
# fast-syntax-highlighting must come last: it wraps every widget defined so far.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=15'  # 提案テキストの色を白色に設定

ZPLUGINDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
#_zplugin_load jeffreytse zsh-vi-mode
_zplugin_load zdharma-continuum fast-syntax-highlighting

# history-substring-search: Up/Down match the typed text anywhere in a past
# command (Ctrl+P/N in bindings.zsh keep the prefix-only search).
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up    # application cursor mode
bindkey '^[OB' history-substring-search-down
