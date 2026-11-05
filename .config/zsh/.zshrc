## ============================================
## 環境変数設定
## ============================================
# ロケール設定
export LANG=C.UTF-8
# rootユーザーの場合はロケールをCに設定
case ${UID} in
0)
    LANG=C
    ;;
esac


## ============================================
## キーマップ
## ============================================
# Use the emacs keymap explicitly. zsh picks viins on its own when $EDITOR or
# $VISUAL contains "vi" (EDITOR=vim), which disables Ctrl+A/E/K and friends.
# Must come before every other bindkey (fzf, modules, plugins): bindkey binds
# into the current main keymap, and -e switches main to another keymap.
bindkey -e


## ============================================
## シェルオプション設定
## ============================================

# === ディレクトリ操作関連 ===
setopt auto_cd              # ディレクトリ名を入力するだけで移動
setopt auto_pushd           # cd時にディレクトリスタックに追加（cd -[tab]で履歴表示可能）
setopt noautoremoveslash    # コマンドライン末尾のスラッシュを自動削除しない

# === 入力補完・表示関連 ===
setopt interactive_comments # インタラクティブモードでコメントを許可
setopt list_packed          # 補完リストを詰めて表示
setopt nolistbeep           # 補完リスト表示時のビープ音を無効化
setopt menu_complete        # 補完候補を自動的に選択
setopt complete_aliases     # エイリアスも補完対象に含める

# === パターンマッチング・展開関連 ===
setopt magic_equal_subst    # = の後にファイル名展開を有効化（例: PATH=~/.local/bin）
setopt extended_glob         # '#', '~', '^'をパターンとして使用可能
setopt nonomatch             # パターンマッチ失敗時のエラーメッセージを非表示

# === その他の動作設定 ===
setopt nobeep
setopt notify               # バックグラウンドジョブの状態を即座に通知
setopt numericglobsort      # ファイル名を数値的にソート
setopt promptsubst          # プロンプト内でコマンド置換を有効化
setopt print_eight_bit      # 8ビット文字をそのまま表示
#setopt correct              # コマンドのスペルミスを自動修正


## ============================================
## 履歴設定
## ============================================
# 履歴ファイルの場所とサイズ
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=100000      # メモリに保持する履歴数
SAVEHIST=100000      # ファイルに保存する履歴数

# 履歴管理オプション
setopt append_history
setopt share_history            # 複数のzshセッション間で履歴を共有
setopt hist_ignore_dups         # 直前のコマンドと同じ場合は履歴に追加しない
setopt hist_ignore_space        # スペースで始まるコマンドは履歴に追加しない
setopt hist_expire_dups_first  # 履歴が上限に達した場合、重複を優先的に削除
setopt hist_verify              # 履歴展開したコマンドを実行前に確認
setopt hist_no_store            # historyコマンド（fc -l）を履歴に保存しない


## ============================================
## カラー設定
## ============================================
# lsコマンドのカラー設定（OS別）
# dircolors/gdircolorsでLS_COLORSを設定
if type dircolors > /dev/null 2>&1; then
    eval "$(dircolors)"
elif type gdircolors > /dev/null 2>&1; then
    eval "$(gdircolors)"
fi


## ============================================
## 補完設定
## ============================================
# カスタム補完関数のパスを追加
fpath=(${HOME}/.local/share/zsh/functions/Completion ${fpath})

# 補完システムの初期化
[[ -d ${XDG_CACHE_HOME:-$HOME/.cache}/zsh ]] || mkdir -p ${XDG_CACHE_HOME:-$HOME/.cache}/zsh
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# 補完メニューの設定
zstyle ':completion:*' menu select interactive  # メニュー形式で補完候補を表示し、インタラクティブに選択
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  # 補完候補にLS_COLORSの色を適用
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# プロセス補完の設定
zstyle ':completion:*:processes' command "ps -u $USER -o pid,stat,%cpu,%mem,cputime,command"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'


## ============================================
## ツール連携
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
## zshエディタ
## ============================================
autoload zed  # zedエディタを読み込み（zsh -f で起動可能）


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
# widget defined afterwards (e.g. accept-line in prompt.zsh) would escape them.
source "$_zmod_dir/plugins.zsh"


## ============================================
## ユーザー設定ファイルの読み込み
## ============================================
# 個人用の設定ファイルがあれば読み込む（このファイルより優先）
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
