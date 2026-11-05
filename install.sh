#!/bin/bash

## ============================================
## dotfiles セットアップスクリプト
## ============================================
# このスクリプトは以下の処理を行います：
# 1. zsh プラグインのインストール
# 2. ドットファイルのシンボリックリンク作成（.config 配下はファイル単位）
# 3. 必要なディレクトリの作成
# 4. 権限の設定

set -e  # エラーが発生したら即座に終了
set -u  # 未定義変数を使用したらエラー

# カラー出力の設定（環境に応じて自動判定）
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    # ターミナル出力でtputが利用可能な場合
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    # カラー出力が利用できない場合
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
fi

# ログ関数
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

# エラーハンドリング関数
error_exit() {
    log_error "$1"
    exit 1
}

# スクリプトの実行ディレクトリを取得（シンボリックリンクを解決）
if [[ -L "$0" ]]; then
    # シンボリックリンクの場合、リンク先を取得
    SCRIPT_DIR=$(cd "$(dirname "$(readlink "$0")")" && pwd)
else
    # 通常のファイルの場合
    SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
fi

log_info "Starting dotfiles setup..."
log_info "Script directory: $SCRIPT_DIR"

# ホームディレクトリの存在確認
if [[ ! -d "$HOME" ]]; then
    error_exit "Home directory ($HOME) not found"
fi

## ============================================
## zsh プラグインのインストール
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
## 必要なディレクトリの作成
## ============================================
log_info "Creating necessary directories..."

# zsh関連ディレクトリ
mkdir -p "$HOME/.local/share/zsh/functions/Completion"
mkdir -p "$HOME/.local/share/zsh/autoload"

# vim関連ディレクトリ
mkdir -p "$HOME/.config/vim/bundle"
mkdir -p "$HOME/.config/vim/backup"
mkdir -p "$HOME/.config/vim/swap"
mkdir -p "$HOME/.config/vim/undo"
mkdir -p "$HOME/.local/state/vim"

log_success "Directory creation completed"

## ============================================
## ドットファイルのシンボリックリンク作成
## ============================================
log_info "Creating symbolic links for dotfiles..."

# 除外するファイル・ディレクトリのリスト
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
    "zsh/.zshenv"
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

# zsh reads its rc files from $ZDOTDIR (~/.config/zsh) when /etc/zshenv sets it,
# and from ~ otherwise. Link .zshrc into both places; the modules it sources are
# under .config/zsh and are linked above.
link_file "$SCRIPT_DIR/.zshrc" "$HOME/.config/zsh/.zshrc"

# On macOS the env files above are only read when /etc/zshenv points zsh there.
# Editing /etc needs root, so only tell the user what to add.
if [[ "$(uname -s)" == Darwin ]] && ! grep -q 'ZDOTDIR' /etc/zshenv 2>/dev/null; then
    log_warning "/etc/zshenv does not set ZDOTDIR; zsh will not read ~/.config/zsh/.zshenv"
    echo "  Add this with: sudo vi /etc/zshenv"
    echo '    export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"'
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
## 権限の設定
## ============================================
log_info "Setting file permissions..."

# スクリプトファイルに実行権限を付与
chmod +x "$SCRIPT_DIR/install.sh"

# ホームディレクトリの権限を適切に設定（セキュリティのため）
chmod 755 "$HOME"

log_success "Permission setting completed"

## ============================================
## 完了メッセージ
## ============================================
echo
log_success "dotfiles setup completed!"
echo
echo "${BOLD}Setup Results:${RESET}"
echo "  - Links created: $LINKED_COUNT files"
echo "  - Skipped: $SKIPPED_COUNT files"
echo
echo "${BOLD}Next Steps:${RESET}"
echo "  1. Open a new terminal or run the following command:"
echo "     ${BLUE}exec zsh${RESET}"
echo
echo "  2. If you encounter issues, check backup files:"
echo "     ${BLUE}ls -la ~/*.backup.*${RESET}"
echo

# バックアップファイルが存在する場合の通知
if ls "$HOME"/*.backup.* >/dev/null 2>&1; then
    log_warning "Backup files have been created. Remove them when no longer needed."
fi

log_info "Setup complete!"
