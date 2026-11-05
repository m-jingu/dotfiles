## ============================================
## キーバインド設定
## ============================================
# The emacs keymap is selected at the top of .zshrc.
# 履歴検索機能の読み込み
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# 履歴検索のキーバインド
bindkey "^p" history-beginning-search-backward-end  # Ctrl+P: 前方一致で履歴を遡る
bindkey "^n" history-beginning-search-forward-end   # Ctrl+N: 前方一致で履歴を進む
bindkey "\e[Z" reverse-menu-complete                # Shift+Tab: 補完メニューを逆方向に移動

