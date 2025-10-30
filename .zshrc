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
## プロンプト設定
## ============================================
# 色を使用できるようにする
autoload colors
colors

# プロンプト設定（ユーザー権限によって色を変更）
case ${UID} in
0)
    # rootユーザー: 赤色でユーザー名@ホスト名を表示
    PROMPT="%{${fg[red]}%}%n%{${fg[yellow]}%}@%m%{${reset_color}%}# "
    PROMPT2="%{${fg[cyan]}%}%_%{${reset_color}%}# "
    ;;
*)
    # 一般ユーザー: 黄色でユーザー名@ホスト名を表示
    PROMPT="%{${fg[yellow]}%}%n@%m%{${reset_color}%}$ "
    PROMPT2="%{${fg[cyan]}%}%_%{${reset_color}%}$ "
    ;;
esac
# 右側プロンプト: カレントディレクトリと時刻を表示
RPROMPT="%{${fg[blue]}%}[%~]%{${reset_color}%} [%*]"
# スペルチェックプロンプト
SPROMPT="%r is correct? [n,y,a,e]: " 

# プロンプトのリセット関数（Enter押下時にプロンプトを再描画）
re-prompt() {
    zle .reset-prompt
    zle .accept-line
}
zle -N accept-line re-prompt


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
setopt notify               # バックグラウンドジョブの状態を即座に通知
setopt numericglobsort      # ファイル名を数値的にソート
setopt promptsubst          # プロンプト内でコマンド置換を有効化
setopt print_eight_bit      # 8ビット文字をそのまま表示
#setopt correct              # コマンドのスペルミスを自動修正


## ============================================
## 履歴設定
## ============================================
# 履歴ファイルの場所とサイズ
HISTFILE=${HOME}/.zsh_history
HISTSIZE=10000      # メモリに保持する履歴数
SAVEHIST=10000      # ファイルに保存する履歴数

# 履歴管理オプション
setopt hist_expire_dups_first  # 履歴が上限に達した場合、重複を優先的に削除
setopt hist_ignore_dups         # 直前のコマンドと同じ場合は履歴に追加しない
setopt hist_ignore_space        # スペースで始まるコマンドは履歴に追加しない
setopt hist_verify              # 履歴展開したコマンドを実行前に確認
setopt hist_no_store            # historyコマンド（fc -l）を履歴に保存しない
#setopt share_history            # 複数のzshセッション間で履歴を共有


## ============================================
## キーバインド設定
## ============================================
# 履歴検索機能の読み込み
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# 履歴検索のキーバインド
bindkey "^p" history-beginning-search-backward-end  # Ctrl+P: 前方一致で履歴を遡る
bindkey "^n" history-beginning-search-forward-end   # Ctrl+N: 前方一致で履歴を進む
bindkey "\e[Z" reverse-menu-complete                # Shift+Tab: 補完メニューを逆方向に移動


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
fpath=(${HOME}/.zsh/functions/Completion ${fpath})

# 補完システムの初期化（-uオプションでセキュリティチェックをスキップ）
autoload -Uz compinit && compinit -u

# 補完メニューの設定
zstyle ':completion:*' menu select interactive  # メニュー形式で補完候補を表示し、インタラクティブに選択
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  # 補完候補にLS_COLORSの色を適用

# プロセス補完の設定
zstyle ':completion:*:processes' command "ps -u $USER -o pid,stat,%cpu,%mem,cputime,command"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'


## ============================================
## エイリアス設定
## ============================================
# 基本コマンド
alias where="command -v"  # コマンドのパスを表示
alias j="jobs -l"          # ジョブ一覧を詳細表示
alias vi="vim"             # viをvimにエイリアス

# OS別のlsエイリアス設定
case "${OSTYPE}" in
freebsd*|darwin*)
    alias ls="ls -G"              # macOS/FreeBSD: カラー表示
    ;;
linux*|msys*)
    alias ls="ls -F --color=auto" # Linux: ファイルタイプ表示 + カラー
    ;;
cygwin*)
    alias ls="ls --color=auto"    # Cygwin: カラー表示
    ;;
esac

# coreutilsのglsがインストールされている場合は優先使用
if type gls > /dev/null 2>&1; then
    alias ls='gls --color=auto'
fi

# lsの便利なエイリアス
alias la="ls -a"   # 隠しファイルも表示
alias ll="ls -l"   # 詳細表示

# 検索・差分コマンドのカラー表示
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'


## ============================================
## プラグイン設定
## ============================================
# zplugの初期化
source ~/.zplug/init.zsh

# プラグインの定義
zplug "zsh-users/zsh-autosuggestions", defer:2      # 履歴ベースの自動補完
zplug "zsh-users/zsh-syntax-highlighting", defer:2   # シンタックスハイライト

# 未インストールのプラグインがある場合、インストール確認
if ! zplug check; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# プラグインの読み込み
zplug load

# zsh-autosuggestionsの設定
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=15'  # 提案テキストの色を白色に設定


## ============================================
## ターミナル設定
## ============================================
# screenセッションの場合はTERMをxtermに設定
case "${TERM}" in
screen)
    TERM=xterm
    ;;
esac

# ターミナルタイプ別の設定
case "${TERM}" in
kterm*)
    stty erase '^H'  # ktermではバックスペースを^Hに設定
    ;;
cons25)
    unset LANG       # cons25ではLANGを無効化
    ;;
*)
    ;;
esac

# ターミナルタイトルにカレントディレクトリを含める
case "${TERM}" in
xterm*|kterm*)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# 制御文字の設定（Ctrl+S/Ctrl+Qによるフロー制御を無効化）
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi


## ============================================
## zshエディタ
## ============================================
autoload zed  # zedエディタを読み込み（zsh -f で起動可能）


## ============================================
## ユーザー設定ファイルの読み込み
## ============================================
# 個人用の設定ファイルがあれば読み込む（このファイルより優先）
[ -f ${HOME}/.zshrc.mine ] && source ${HOME}/.zshrc.mine
