#!/bin/bash

## ============================================
## dotfiles セットアップスクリプト
## ============================================
# このスクリプトは以下の処理を行います：
# 1. zplugプラグインマネージャーのインストール
# 2. ドットファイルのシンボリックリンク作成
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
## zplug のインストール
## ============================================
log_info "Installing zplug plugin manager..."

ZPLUG_HOME="$HOME/.zplug"

# zplugが既にインストールされているかチェック
if [[ -d "$ZPLUG_HOME" ]]; then
    log_warning "zplug is already installed ($ZPLUG_HOME)"
    read -p "Reinstall? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Removing existing zplug..."
        rm -rf "$ZPLUG_HOME"
    else
        log_info "Skipping zplug installation"
    fi
fi

# zplugが存在しない場合のみインストール
if [[ ! -d "$ZPLUG_HOME" ]]; then
    # gitが利用可能かチェック
    if ! command -v git >/dev/null 2>&1; then
        error_exit "git is not installed. Please install git and run again"
    fi

    # ネットワーク接続をチェック
    if ! ping -c 1 github.com >/dev/null 2>&1; then
        log_warning "Cannot connect to GitHub. You might be in an offline environment"
    fi

    # zplugをクローン
    if git clone https://github.com/zplug/zplug "$ZPLUG_HOME"; then
        log_success "zplug installation completed"
    else
        error_exit "Failed to install zplug"
    fi
fi

## ============================================
## 必要なディレクトリの作成
## ============================================
log_info "Creating necessary directories..."

# zsh関連ディレクトリ
mkdir -p "$HOME/.zsh/functions/Completion"
mkdir -p "$HOME/.zsh/autoload"

# vim関連ディレクトリ
mkdir -p "$HOME/.vim/bundle"
mkdir -p "$HOME/.vim/backup"
mkdir -p "$HOME/.vim/swap"
mkdir -p "$HOME/.vim/undo"

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
)

# ドットファイルを検索してリンク作成
LINKED_COUNT=0
SKIPPED_COUNT=0

for file in "$SCRIPT_DIR"/.??*; do
    # ファイルが存在しない場合はスキップ
    [[ ! -e "$file" ]] && continue
    
    # ファイル名を取得
    filename=$(basename "$file")
    
    # 除外リストに含まれているかチェック
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
    
    # リンク先のパス
    link_target="$HOME/$filename"
    
    # 既存のファイル・リンクの処理
    if [[ -e "$link_target" ]] || [[ -L "$link_target" ]]; then
        if [[ -L "$link_target" ]]; then
            # 既存のシンボリックリンクの場合
            existing_target=$(readlink "$link_target")
            if [[ "$existing_target" == "$file" ]]; then
                log_info "Already linked: $filename"
                ((++SKIPPED_COUNT))
                continue
            else
                log_warning "Removing existing link: $filename (was: $existing_target)"
                rm "$link_target"
            fi
        else
            # 既存のファイル・ディレクトリの場合
            log_warning "Backing up existing file: $filename"
            mv "$link_target" "${link_target}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
    fi
    
    # シンボリックリンクを作成
    if ln -sf "$file" "$link_target"; then
        log_success "Link created: $filename"
        ((++LINKED_COUNT))
    else
        log_error "Failed to create link: $filename"
    fi
done

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
echo "     ${BLUE}source ~/.zshrc${RESET}"
echo
echo "  2. To install zplug plugins:"
echo "     ${BLUE}zplug install${RESET}"
echo
echo "  3. If you encounter issues, check backup files:"
echo "     ${BLUE}ls -la ~/*.backup.*${RESET}"
echo

# バックアップファイルが存在する場合の通知
if ls "$HOME"/*.backup.* >/dev/null 2>&1; then
    log_warning "Backup files have been created. Remove them when no longer needed."
fi

log_info "Setup complete!"
