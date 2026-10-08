#!/bin/zsh
# Open a file read-only in a pager that takes the whole pane. Pagers do not
# capture the mouse, so zellij's mouse selection can copy any part of it.
case "${1:l}" in
	# glow wraps at 80 columns unless told otherwise; use the full pane width
	*.md|*.markdown) PAGER="less -R" glow -p -s dark -w "$(tput cols)" "$1" ;;
	*) less -R "$1" ;;
esac
