## ============================================
## エイリアス設定
## ============================================
# 基本コマンド
alias where="command -v"  # コマンドのパスを表示
alias j="jobs -l"          # ジョブ一覧を詳細表示
alias vi="vim"             # viをvimにエイリアス

# OS別のlsエイリアス設定
case "${OSTYPE}" in
darwin*|freebsd*)
    alias ls="ls -G"              # macOS/FreeBSD: カラー表示
    ;;
linux*|msys*)
    alias ls="ls -F --color=auto" # Linux: ファイルタイプ表示 + カラー
    ;;
cygwin*)
    alias ls="ls --color=auto"    # Cygwin: カラー表示
    ;;
esac

# coreutilsのglsがインストールされている場合は優先使用
if type gls > /dev/null 2>&1; then
    alias ls='gls --color=auto'
fi

# ezaがインストールされている場合は優先使用
if type eza > /dev/null 2>&1; then
    alias ls='eza --group-directories-first --time-style=iso'
fi

# lsの便利なエイリアス
alias la="ls -a"   # 隠しファイルも表示
alias ll="ls -lh"   # 詳細表示
alias lla="ls -lha"

# Tree view
alias tree='eza --tree --icons auto'

# 検索・差分コマンドのカラー表示
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# =========================================================
# Navigation
# =========================================================
alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

