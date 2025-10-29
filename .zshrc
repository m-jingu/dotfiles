## Environment variable configuration
#
# LANG
#
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac


## Default shell configuration
#
# set prompt
#
autoload colors
colors

case ${UID} in
0)
    PROMPT="%{${fg[red]}%}%n%{${fg[yellow]}%}@%m%{${reset_color}%}# "
    PROMPT2="%{${fg[cyan]}%}%_%{${reset_color}%}# "
    ;;
*)
    PROMPT="%{${fg[yellow]}%}%n@%m%{${reset_color}%}$ "
    PROMPT2="%{${fg[cyan]}%}%_%{${reset_color}%}$ "
    ;;
esac
RPROMPT="%{${fg[blue]}%}[%~]%{${reset_color}%} [%*]"
SPROMPT="%r is correct? [n,y,a,e]: " 

# reset prompt
re-prompt() {
    zle .reset-prompt
    zle .accept-line
}
zle -N accept-line re-prompt

setopt auto_cd              # change directory just by typing its name
#setopt correct              # auto correct mistakes
setopt interactive_comments # allow comments in interactive mode
setopt magic_equal_subst    # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch            # hide error message if there is no match for the pattern
setopt notify               # report the status of background jobs immediately
setopt numericglobsort      # sort filenames numerically when it makes sense
setopt promptsubst          # enable command substitution in prompt
setopt list_packed          # compacked complete list display
setopt auto_pushd           # auto directory pushd that you can get dirs list by cd -[tab]
setopt noautoremoveslash    # no remove postfix slash of command line
setopt nolistbeep           # no beep sound when complete list displayed
setopt print_eight_bit      # print eight bit characters literally in completion lists
setopt extended_glob        # treat the '#', '~' and '^' characters as part of patterns for filename generation
bindkey "^I" menu-complete

## Keybind configuration
#
# emacs like keybind (e.x. Ctrl-a gets to line head and Ctrl-e gets
#   to end) and something additions
#
bindkey -e
bindkey "^[[1~" beginning-of-line # Home gets to line head
bindkey "^[[4~" end-of-line # End gets to line end
bindkey "^[[3~" delete-char # Del

# historical backward/forward search with linehead string binded to ^P/^N
#
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end

# reverse menu completion binded to Shift-Tab
#
bindkey "\e[Z" reverse-menu-complete


## Command history configuration
#
HISTFILE=${HOME}/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplication command history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt hist_no_store          # remove the history (fc -l) command from the history list when invoked
#setopt share_history          # share command history data


## Completion configuration
#
fpath=(${HOME}/.zsh/functions/Completion ${fpath})
autoload -Uz compinit
compinit


## zsh editor
#
autoload zed

## Alias configuration
#
# expand aliases before completing
#
setopt complete_aliases     # aliased ls needs if file/dir completions work

alias where="command -v"
alias j="jobs -l"
alias vi="vim"

# set LS_COLORS
if type dircolors > /dev/null 2>&1; then
    eval "$(dircolors)"
elif type gdircolors > /dev/null 2>&1; then
    eval "$(gdircolors)"
fi

case "${OSTYPE}" in
freebsd*|darwin*)
    alias ls="ls -G"
    ;;
linux*|msys*)
    alias ls="ls -F --color=auto"
    ;;
cygwin*)
    alias ls="ls --color=auto"
    ;;
esac

# if coreutils
if type gls > /dev/null 2>&1; then
    alias ls='gls --color=auto'
fi

alias la="ls -a"
alias ll="ls -l"

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:processes' command "ps -u $USER -o pid,stat,%cpu,%mem,cputime,command"


## terminal configuration
#
case "${TERM}" in
screen)
    TERM=xterm
    ;;
esac

case "${TERM}" in
kterm*)
    stty erase '^H'
    ;;
cons25)
    unset LANG
    ;;
*)
    ;;
esac

# set terminal title including current directory
#
case "${TERM}" in
xterm*|kterm*)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# User specific aliases and functions
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi

# enable auto-suggestions based on the history
if [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=15'
fi

## load user .zshrc configuration file
#
[ -f ${HOME}/.zshrc.mine ] && source ${HOME}/.zshrc.mine

