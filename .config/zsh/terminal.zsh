## ============================================
## ターミナル設定
## ============================================
# screenセッションの場合はTERMをxtermに設定
case "${TERM}" in
screen)
    TERM=xterm
    ;;
esac

# ターミナルタイプ別の設定
case "${TERM}" in
kterm*)
    stty erase '^H'  # ktermではバックスペースを^Hに設定
    ;;
cons25)
    unset LANG       # cons25ではLANGを無効化
    ;;
*)
    ;;
esac

# ターミナルタイトルにカレントディレクトリを含める
case "${TERM}" in
xterm*|kterm*)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# 制御文字の設定（Ctrl+S/Ctrl+Qによるフロー制御を無効化）
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi
