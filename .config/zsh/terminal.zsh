## ============================================
## Terminal
## ============================================
# Inside screen, present the terminal as xterm
case "${TERM}" in
screen)
    TERM=xterm
    ;;
esac

# Quirks of specific terminal types
case "${TERM}" in
kterm*)
    stty erase '^H'  # kterm sends ^H for Backspace
    ;;
cons25)
    unset LANG       # The FreeBSD console cannot show UTF-8
    ;;
*)
    ;;
esac

# Put user@host:cwd in the terminal title before each prompt
case "${TERM}" in
xterm*|kterm*)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# Turn off XON/XOFF flow control so Ctrl+S and Ctrl+Q reach zsh
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi
