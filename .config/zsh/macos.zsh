# macOS-specific interactive settings, sourced from .zshrc on Darwin only
# (install.sh does not link this file elsewhere). Formerly ~/.zshrc.mine.
# Settings for one machine only (secrets, experiments) go in the untracked
# $ZDOTDIR/.zshrc.mine instead.

#export LANG=ja_JP.UTF-8

# Homebrew is put on PATH by $ZDOTDIR/.zshenv and moved back in front of the system
# directories by $ZDOTDIR/.zprofile (macOS path_helper reorders PATH in login shells).

# pyenv / rbenv: put the shims on PATH now and run the real `init` only on the
# first call of the command itself. Running both inits eagerly cost ~200ms per
# shell. Versions are still resolved per directory by the shims.
#
# pyenv-virtualenv's init is deliberately not loaded: its precmd hook added
# ~120ms to every prompt, only to export VIRTUAL_ENV on cd. `pyenv activate`
# / `pyenv shell` keep working through the lazily defined pyenv function.
export PYENV_ROOT="$HOME/.pyenv"
export VIRTUAL_ENV_DISABLE_PROMPT=1
path=("$PYENV_ROOT/shims" $path)
pyenv() {
	unfunction pyenv
	eval "$(command pyenv init - zsh)"
	pyenv "$@"
}

path=("$HOME/.rbenv/shims" $path)
rbenv() {
	unfunction rbenv
	eval "$(command rbenv init - zsh)"
	rbenv "$@"
}

# Rust: Homebrew's rustup is keg-only and ships the cargo/rustc proxies in its
# own bin. ~/.cargo/bin (added by ~/.cargo/env below) keeps only binaries from
# `cargo install`.
[[ -d /opt/homebrew/opt/rustup/bin ]] && path=(/opt/homebrew/opt/rustup/bin $path)

# Each tool may be missing on a fresh Mac; skip it quietly then.
for _f in /opt/homebrew/share/google-cloud-sdk/{path,completion}.zsh.inc "$HOME/.cargo/env"; do
	[[ -r "$_f" ]] && source "$_f"
done
unset _f

path=("$HOME/bin" "$HOME/.local/bin" $path)

#alias ssh-config-update="cat ~/.ssh/conf.d/*.conf ~/.ssh/conf.d/common-config > ~/.ssh/config"

## ============================================
## Zellij
## ============================================
# Open the "dev" layout in a tab named after the current directory.
# Zellij layouts cannot expand env vars, so the name is injected from here.
zdev() {
	local name="${1:-${PWD:t}}"
	local layout="$HOME/.config/zellij/layouts/dev.kdl"

	if [[ -n "$ZELLIJ" ]]; then
		# Inside a session: name the tab at creation time, so the rename can
		# never land on the tab this command was run from.
		zellij action new-tab --layout "$layout" --name "$name" --cwd "$PWD" >/dev/null
	else
		# Starting a new session: inject the tab name into a temporary copy.
		local dir="$(mktemp -d -t zdev)"
		awk -v n="$name" '!done && /^[[:space:]]*tab \{/ {
			match($0, /^[[:space:]]*/)
			print substr($0, 1, RLENGTH) "tab name=\"" n "\" {"
			done = 1
			next
		}
		{ print }' "$layout" > "$dir/dev.kdl"
		zellij --layout "$dir/dev.kdl"
		command rm -rf -- "$dir"
	fi
}

# Attach to a running session, e.g. from a normal Ghostty window when the
# quick terminal would cover other windows. Picks with fzf if several run.
za() {
	if [[ -n "$1" ]]; then
		zellij attach "$1"
		return
	fi

	local -a sessions
	sessions=(${(f)"$(zellij list-sessions --no-formatting 2>/dev/null | grep -v EXITED)"})
	sessions=(${sessions%% *})
	case ${#sessions} in
		0) print -u2 "za: no running zellij session"; return 1 ;;
		1) zellij attach "$sessions[1]" ;;
		*) local s
		   s="$(print -l -- $sessions | fzf --prompt='session> ')" || return
		   zellij attach "$s" ;;
	esac
}

## ============================================
## Yazi
## ============================================
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
