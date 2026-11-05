# =========================================================
# fzf
# =========================================================
# Debian and Ubuntu install fd and bat as fdfind and batcat; use whichever
# name exists. Without fd, fzf falls back to its built-in file walker.
if (( $+commands[fd] )); then
  _fzf_fd=fd
elif (( $+commands[fdfind] )); then
  _fzf_fd=fdfind
fi
if (( $+commands[bat] )); then
  _fzf_bat=bat
elif (( $+commands[batcat] )); then
  _fzf_bat=batcat
fi

if [[ -n "$_fzf_fd" ]]; then
  # strip-cwd-prefix removes the leading ./ from results
  export FZF_DEFAULT_COMMAND="$_fzf_fd --type f --hidden --exclude .git --strip-cwd-prefix"
  # Ctrl-T uses fd as well
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# UI
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
'

# Preview with bat when available, otherwise the first 500 lines as plain text
if [[ -n "$_fzf_bat" ]]; then
  export _FZF_PREVIEW_CMD="$_fzf_bat --color=always --style=plain,numbers --line-range=:500 {}"
else
  export _FZF_PREVIEW_CMD='head -n 500 {}'
fi
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# Ctrl+F: file picker excluding hidden files
_fzf_file_no_hidden() {
  local cmd result
  if [[ -n "$_fzf_fd" ]]; then
    cmd="$_fzf_fd --type f --strip-cwd-prefix"
  else
    cmd="find . -type f -not -path '*/.*'"
  fi
  result=$(eval "$cmd" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"  # LBUFFER is the text left of the cursor
  zle reset-prompt
}
zle -N _fzf_file_no_hidden
bindkey '^F' _fzf_file_no_hidden

# Preview any file list piped in, e.g. `ff` alone lists the current tree
alias ff="fzf --preview '$_FZF_PREVIEW_CMD'"
