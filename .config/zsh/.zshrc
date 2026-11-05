## ============================================
## Locale
## ============================================
export LANG=C.UTF-8
# root gets the plain C locale
case ${UID} in
0)
    LANG=C
    ;;
esac


## ============================================
## Keymap
## ============================================
# Use the emacs keymap explicitly. zsh picks viins on its own when $EDITOR or
# $VISUAL contains "vi" (EDITOR=vim), which disables Ctrl+A/E/K and friends.
# Must come before every other bindkey (fzf, modules, plugins): bindkey binds
# into the current main keymap, and -e switches main to another keymap.
bindkey -e


## ============================================
## Shell options
## ============================================

# === Directories ===
setopt auto_cd              # Typing a directory name cd's into it
setopt auto_pushd           # cd pushes onto the directory stack (cd -<Tab> lists it)
setopt noautoremoveslash    # Keep a trailing slash after completing a directory

# === Completion and input ===
setopt interactive_comments # Allow # comments on the command line
setopt list_packed          # Pack the completion list into fewer lines
setopt menu_complete        # Insert the first match right away
setopt complete_aliases     # Complete aliases as commands of their own

# === Globbing and expansion ===
setopt magic_equal_subst    # Expand ~ after = in arguments (e.g. --prefix=~/x)
setopt extended_glob        # Treat #, ~ and ^ as glob operators
setopt nonomatch            # Pass an unmatched glob through instead of erroring

# === Misc ===
setopt nobeep
setopt notify               # Report background job status immediately
setopt numericglobsort      # Sort numbered file names numerically
setopt promptsubst          # Expand $(...) in prompts (starship relies on it)
setopt print_eight_bit      # Print 8-bit (e.g. Japanese) file names as is
#setopt correct             # Spelling correction for commands (off)


## ============================================
## History
## ============================================
# Location and size
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=100000      # Entries kept in memory
SAVEHIST=100000      # Entries saved to the file

setopt share_history            # Share history across running zsh sessions
setopt hist_ignore_dups         # Skip a command identical to the previous one
setopt hist_ignore_space        # Skip commands that start with a space
setopt hist_expire_dups_first   # Drop duplicates first when trimming history
setopt hist_verify              # Show a history expansion before running it
setopt hist_no_store            # Do not record the history (fc -l) command itself


## ============================================
## Colors
## ============================================
# Set LS_COLORS (also used by completion below) from GNU dircolors, which
# coreutils on macOS installs as gdircolors
if type dircolors > /dev/null 2>&1; then
    eval "$(dircolors)"
elif type gdircolors > /dev/null 2>&1; then
    eval "$(gdircolors)"
fi


## ============================================
## Completion
## ============================================
# Directory for extra completion functions
fpath=(${HOME}/.local/share/zsh/functions/Completion ${fpath})

# Initialize completion; keep the dump file in the cache directory
[[ -d ${XDG_CACHE_HOME:-$HOME/.cache}/zsh ]] || mkdir -p ${XDG_CACHE_HOME:-$HOME/.cache}/zsh
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# Completion menu
zstyle ':completion:*' menu select interactive         # Arrow-key menu that narrows as you type
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  # Color candidates like ls
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Lowercase input matches either case

# Process completion (kill <Tab>): own processes, PIDs in red
zstyle ':completion:*:processes' command "ps -u $USER -o pid,stat,%cpu,%mem,cputime,command"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'


## ============================================
## Tool integration
## ============================================
# fzf: Ctrl-T (file), Ctrl-R (history), Alt-C (cd). Needs fzf 0.48+.
if type fzf > /dev/null 2>&1; then
    source <(fzf --zsh 2>/dev/null)
fi

# zoxide: z <query> jumps to a frecent directory, zi picks one with fzf.
if type zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi


## ============================================
## zed
## ============================================
autoload zed  # zsh's built-in editor: zed <file> edits a file in zle


# =========================================================
# Modular Config Files
# =========================================================

# The modules live next to this file in $ZDOTDIR (~/.config/zsh, set by
# ~/.zshenv). The fallback covers a shell started with ZDOTDIR unset.
_zmod_dir="${ZDOTDIR:-$HOME/.config/zsh}"

# fzf configuration
source "$_zmod_dir/fzf.zsh"

# Aliases
source "$_zmod_dir/aliases.zsh"

# Custom keybindings
source "$_zmod_dir/bindings.zsh"

# Prompt/theme
source "$_zmod_dir/prompt.zsh"

# Terminal
source "$_zmod_dir/terminal.zsh"

# Plugins and plugin manager. Keep this last: zsh-autosuggestions and
# fast-syntax-highlighting wrap the widgets that exist when they load, so a
# widget defined afterwards (e.g. the zle-line-finish hook in prompt.zsh) would
# escape them.
source "$_zmod_dir/plugins.zsh"


## ============================================
## Platform and machine-specific settings
## ============================================
# Loaded last so they can override anything above.
# macOS-specific settings (pyenv/rbenv, gcloud, zellij and yazi helpers).
[[ "$OSTYPE" == darwin* && -f "$_zmod_dir/macos.zsh" ]] && source "$_zmod_dir/macos.zsh"

# Optional settings for this machine only, kept out of the repo (secrets etc.).
# Older setups have it in $HOME.
if [[ -f "$_zmod_dir/.zshrc.mine" ]]; then
    source "$_zmod_dir/.zshrc.mine"
elif [[ -f "$HOME/.zshrc.mine" ]]; then
    source "$HOME/.zshrc.mine"
fi
unset _zmod_dir
