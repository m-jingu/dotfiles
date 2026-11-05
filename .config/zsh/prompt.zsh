## ============================================
## プロンプト設定
## ============================================
# 色を使用できるようにする
autoload colors
colors

# Prevent Python virtualenv from polluting the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Starship draws the prompt; its config is $STARSHIP_CONFIG (set in .zshenv).
eval "$(starship init zsh)"

# Transient prompt: once a line is accepted, redraw it as a bare "❯ cmd" with
# the time it was run on the right, so only the line being edited carries the
# full starship prompt. Starship's enable_transience does not support zsh, so
# swap PROMPT/RPROMPT in zle-line-finish and put them back in precmd.
# zjcopy finds command lines by this "❯ " prefix; keep them in sync.
typeset -g _starship_prompt=$PROMPT _starship_rprompt=$RPROMPT

_transient_prompt_restore() {
    PROMPT=$_starship_prompt
    RPROMPT=$_starship_rprompt
}

_transient_prompt_collapse() {
    PROMPT='%(?.%F{green}.%F{red})❯%f '
    RPROMPT='%F{8}%*%f'
    zle .reset-prompt
}

autoload -Uz add-zsh-hook add-zle-hook-widget
add-zsh-hook precmd _transient_prompt_restore
add-zle-hook-widget zle-line-finish _transient_prompt_collapse
