## ============================================
## プロンプト設定
## ============================================
# 色を使用できるようにする
autoload colors
colors

# プロンプト設定（ユーザー権限によって色を変更）
case ${UID} in
0)
    # rootユーザー: 赤色でユーザー名@ホスト名を表示
    PROMPT="%{${fg[red]}%}%n%{${fg[yellow]}%}@%m%{${reset_color}%}# "
    PROMPT2="%{${fg[cyan]}%}%_%{${reset_color}%}# "
    ;;
*)
    # 一般ユーザー: 黄色でユーザー名@ホスト名を表示
    PROMPT="%{${fg[yellow]}%}%n@%m%{${reset_color}%}$ "
    PROMPT2="%{${fg[cyan]}%}%_%{${reset_color}%}$ "
    ;;
esac
# 右側プロンプト: カレントディレクトリと時刻を表示
RPROMPT="%{${fg[blue]}%}[%~]%{${reset_color}%} [%*]"
# スペルチェックプロンプト
SPROMPT="%r is correct? [n,y,a,e]: "

# プロンプトのリセット関数（Enter押下時にプロンプトを再描画）
re-prompt() {
    zle .reset-prompt
    zle .accept-line
}
zle -N accept-line re-prompt

# Prevent Python virtualenv from polluting the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

#eval "$(starship init zsh)"
