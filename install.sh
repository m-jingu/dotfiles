#!/bin/bash

## ============================================
## dotfiles setup script
## ============================================
# 1. Clone the zsh plugins
# 2. Create the directories the configs expect
# 3. Symlink the dotfiles (files under .config one by one)
# 4. Install yazi plugins and fix permissions
# 5. Print the starship install command if starship is missing
# Safe to run again: existing links are kept and other files are backed up.

set -e  # Exit on the first error
set -u  # Treat unset variables as errors

# Colored output only when stdout is a terminal with tput
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
fi

# Logging helpers
log_info() {
    echo "${BLUE}[INFO]${RESET} $1"
}

log_success() {
    echo "${GREEN}[SUCCESS]${RESET} $1"
}

log_warning() {
    echo "${YELLOW}[WARNING]${RESET} $1"
}

log_error() {
    echo "${RED}[ERROR]${RESET} $1" >&2
}

# Print an error and exit
error_exit() {
    log_error "$1"
    exit 1
}

# Directory of this script (resolving a symlink to it)
if [[ -L "$0" ]]; then
    SCRIPT_DIR=$(cd "$(dirname "$(readlink "$0")")" && pwd)
else
    SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
fi

log_info "Starting dotfiles setup..."
log_info "Script directory: $SCRIPT_DIR"

# $HOME must exist
if [[ ! -d "$HOME" ]]; then
    error_exit "Home directory ($HOME) not found"
fi

## ============================================
## zsh plugins
## ============================================
# Plain git clones sourced directly from .zshrc (zplug is no longer used).
log_info "Installing zsh plugins..."

ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
ZSH_PLUGINS=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-history-substring-search"
    "zdharma-continuum/fast-syntax-highlighting"
)

if ! command -v git >/dev/null 2>&1; then
    error_exit "git is not installed. Please install git and run again"
fi

mkdir -p "$ZSH_PLUGIN_DIR"
for repo in "${ZSH_PLUGINS[@]}"; do
    name="${repo##*/}"
    if [[ -d "$ZSH_PLUGIN_DIR/$name" ]]; then
        log_info "Already installed: $name (update: git -C $ZSH_PLUGIN_DIR/$name pull)"
    elif git clone --depth 1 "https://github.com/$repo" "$ZSH_PLUGIN_DIR/$name"; then
        log_success "Plugin installed: $name"
    else
        log_warning "Failed to install plugin: $name"
    fi
done

## ============================================
## Directories
## ============================================
log_info "Creating necessary directories..."

# Personal binaries (on PATH via .zshenv; starship's installer can target it)
mkdir -p "$HOME/.local/bin"

# zsh: extra completion functions
mkdir -p "$HOME/.local/share/zsh/functions/Completion"

# vim: plugins and editor state (viminfo, netrw)
mkdir -p "$HOME/.config/vim/bundle"
mkdir -p "$HOME/.local/state/vim"

log_success "Directory creation completed"

## ============================================
## Symlinks
## ============================================
log_info "Creating symbolic links for dotfiles..."

# Top-level entries that are not linked into $HOME (.config is handled below)
EXCLUDE_FILES=(
    ".git"
    ".DS_Store"
    "install.sh"
    "README.md"
    ".gitignore"
    ".gitattributes"
    ".config"
)

# mintty is the Windows (Git Bash / WSL) terminal; its config is useless elsewhere.
if [[ "$(uname -s)" != MINGW* ]] && [[ "$(uname -s)" != MSYS* ]] && [[ "$(uname -s)" != CYGWIN* ]]; then
    EXCLUDE_FILES+=(".minttyrc")
fi

LINKED_COUNT=0
SKIPPED_COUNT=0

# Link $1 (a file in this repo) to $2, backing up whatever is already there.
link_file() {
    local file=$1 link_target=$2
    local name=${link_target#"$HOME"/}

    if [[ -e "$link_target" ]] || [[ -L "$link_target" ]]; then
        if [[ -L "$link_target" ]]; then
            local existing_target
            existing_target=$(readlink "$link_target")
            if [[ "$existing_target" == "$file" ]]; then
                log_info "Already linked: $name"
                ((++SKIPPED_COUNT))
                return 0
            fi
            log_warning "Removing existing link: $name (was: $existing_target)"
            rm "$link_target"
        else
            log_warning "Backing up existing file: $name"
            mv "$link_target" "${link_target}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
    fi

    mkdir -p "$(dirname "$link_target")"
    if ln -s "$file" "$link_target"; then
        log_success "Link created: $name"
        ((++LINKED_COUNT))
    else
        log_error "Failed to create link: $name"
    fi
}

# Top-level dotfiles -> ~/
for file in "$SCRIPT_DIR"/.??*; do
    [[ ! -e "$file" ]] && continue
    filename=$(basename "$file")

    skip=false
    for exclude in "${EXCLUDE_FILES[@]}"; do
        if [[ "$filename" == "$exclude" ]]; then
            skip=true
            break
        fi
    done
    if [[ "$skip" == true ]]; then
        log_info "Skipping: $filename"
        ((++SKIPPED_COUNT))
        continue
    fi

    link_file "$file" "$HOME/$filename"
done

# Files under .config that only make sense on macOS (Homebrew paths, path_helper,
# pyenv/rbenv and other Mac-only tools). Not linked on Linux and others.
MACOS_ONLY=(
    "zsh/.zprofile"
    "zsh/macos.zsh"
)

# .config is linked file by file, never as a whole directory: ~/.config also
# holds state and configs this repo does not manage.
if [[ -d "$SCRIPT_DIR/.config" ]]; then
    while IFS= read -r -d '' file; do
        rel="${file#"$SCRIPT_DIR"/.config/}"
        if [[ "$(uname -s)" != Darwin ]]; then
            skip=false
            for mac_only in "${MACOS_ONLY[@]}"; do
                [[ "$rel" == "$mac_only" ]] && skip=true && break
            done
            if [[ "$skip" == true ]]; then
                log_info "Skipping (macOS only): .config/$rel"
                ((++SKIPPED_COUNT))
                continue
            fi
        fi
        link_file "$file" "$HOME/.config/$rel"
    done < <(find "$SCRIPT_DIR/.config" -type f ! -name .DS_Store -print0)
fi

# zsh now reads its rc files from ~/.config/zsh (~/.zshenv sets ZDOTDIR), so
# a ~/.zshrc left by an older layout of this repo is never read. Remove it.
if [[ -L "$HOME/.zshrc" ]] && [[ "$(readlink "$HOME/.zshrc")" == "$SCRIPT_DIR/.zshrc" ]]; then
    log_warning "Removing old link: .zshrc (moved to .config/zsh/.zshrc)"
    rm "$HOME/.zshrc"
fi

# Yazi plugins listed in .config/yazi/package.toml (deployed into ~/.config/yazi/plugins)
if command -v ya >/dev/null 2>&1; then
    log_info "Installing yazi plugins..."
    if ya pkg install >/dev/null; then
        log_success "Yazi plugins installed"
    else
        log_warning "Failed to install yazi plugins (retry: ya pkg install)"
    fi
fi

## ============================================
## Permissions
## ============================================
log_info "Setting file permissions..."

# Keep this script executable
chmod +x "$SCRIPT_DIR/install.sh"

# Make $HOME not writable by group or others
chmod 755 "$HOME"

log_success "Permission setting completed"

## ============================================
## Missing tools
## ============================================
# Prints the command that installs starship on this machine. Uses the OS
# package manager only where starship is known to be packaged; anything else
# gets the official installer into ~/.local/bin, which needs no sudo.
starship_install_cmd() {
    local fetch="curl -sS"
    if ! command -v curl >/dev/null 2>&1 && command -v wget >/dev/null 2>&1; then
        fetch="wget -qO-"
    fi
    local installer="$fetch https://starship.rs/install.sh | sh -s -- -b ~/.local/bin"

    case "$(uname -s)" in
        Darwin)  echo "brew install starship"; return ;;
        FreeBSD) echo "sudo pkg install starship"; return ;;
        Linux)   ;;
        *)       echo "$installer"; return ;;
    esac

    local id="" like=""
    if [[ -r /etc/os-release ]]; then
        id=$(. /etc/os-release && echo "${ID:-}")
        like=$(. /etc/os-release && echo "${ID_LIKE:-}")
    fi
    case " $id $like " in
        *" arch "*)
            echo "sudo pacman -S starship" ;;
        *" alpine "*)
            echo "sudo apk add starship" ;;
        *" debian "*|*" ubuntu "*)
            # Packaged only in newer releases (e.g. Debian 13, Kali), so ask apt.
            if apt-cache show starship >/dev/null 2>&1; then
                echo "sudo apt install starship"
            else
                echo "$installer"
            fi ;;
        *)
            # RHEL family (Rocky, Amazon Linux, ...) has no starship package.
            echo "$installer" ;;
    esac
}

STARSHIP_MISSING=false
if ! command -v starship >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/starship" ]]; then
    STARSHIP_MISSING=true
fi

## ============================================
## Summary
## ============================================
echo
log_success "dotfiles setup completed!"
echo
echo "${BOLD}Setup Results:${RESET}"
echo "  - Links created: $LINKED_COUNT files"
echo "  - Skipped: $SKIPPED_COUNT files"
echo
if [[ "$STARSHIP_MISSING" == true ]]; then
    log_warning "starship is not installed; the prompt needs it. Install it with:"
    echo "     ${BLUE}$(starship_install_cmd)${RESET}"
    echo
fi
echo "${BOLD}Next Steps:${RESET}"
echo "  1. Open a new terminal or run the following command:"
echo "     ${BLUE}exec zsh${RESET}"
echo
echo "  2. If you encounter issues, check backup files:"
echo "     ${BLUE}ls -la ~/*.backup.*${RESET}"
echo

# Remind about backups made of files that links replaced
if ls "$HOME"/*.backup.* >/dev/null 2>&1; then
    log_warning "Backup files have been created. Remove them when no longer needed."
fi

log_info "Setup complete!"
