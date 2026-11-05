## ============================================
## Key bindings
## ============================================
# The emacs keymap is selected at the top of .zshrc.

# History search that keeps the cursor at the end of the line
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey "^p" history-beginning-search-backward-end  # Ctrl+P: older entry starting with the typed text
bindkey "^n" history-beginning-search-forward-end   # Ctrl+N: newer entry starting with the typed text
bindkey "\e[Z" reverse-menu-complete                # Shift+Tab: move backwards in the completion menu
