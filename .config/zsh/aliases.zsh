## ============================================
## Aliases
## ============================================
# Basic commands
alias j="jobs -l"         # List jobs with their PIDs
alias vi="vim"

# ls: pick the color flag the platform's ls understands
case "${OSTYPE}" in
darwin*|freebsd*)
    alias ls="ls -G"              # BSD ls: color
    ;;
linux*|msys*)
    alias ls="ls -F --color=auto" # GNU ls: type indicators and color
    ;;
cygwin*)
    alias ls="ls --color=auto"
    ;;
esac

# Prefer GNU ls from coreutils (gls) when it is installed
if type gls > /dev/null 2>&1; then
    alias ls='gls --color=auto'
fi

# Prefer eza over both when it is installed
if type eza > /dev/null 2>&1; then
    alias ls='eza --group-directories-first --time-style=iso'
fi

# ls shortcuts (they follow whichever ls alias won above)
alias la="ls -a"    # Include hidden files
alias ll="ls -lh"   # Long listing with human-readable sizes
alias lla="ls -lha"

# Tree view with eza; plain tree (if installed) is left alone otherwise
if type eza > /dev/null 2>&1; then
    alias tree='eza --tree --icons auto'
fi

# Color output for search, diff and ip
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# =========================================================
# Navigation
# =========================================================
alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory
