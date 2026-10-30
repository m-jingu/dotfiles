# dotfiles

個人的な開発環境設定ファイルのリポジトリ

## 概要

このリポジトリには、以下の開発環境の設定ファイルが含まれています：

- **Zsh設定** (`.zshrc`) - シェル環境の設定
- **Vim設定** (`.config/vim/vimrc`) - エディタの設定（Vim 9.1.0327 以降が `~/.config/vim` を読む）
- **Git グローバル ignore** (`.config/git/ignore`) - git が標準で読む場所なので `core.excludesFile` は不要
- **Mintty設定** (`.minttyrc`) - Windowsターミナルの設定（install.sh は Windows 上でのみリンクする）
- **Ghostty設定** (`.config/ghostty/config`) - ターミナルエミュレータ
- **Zellij設定** (`.config/zellij/config.kdl`, `layouts/{dev,n}.kdl`) - ターミナルマルチプレクサ
- **Yazi設定** (`.config/yazi/yazi.toml`) - ファイラ

## セットアップ

### 前提条件

- Gitがインストールされていること
- Bashが使用可能なこと

### インストール手順

1. リポジトリをクローン：
```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. インストールスクリプトを実行：
```bash
./install.sh
```

3. 新しいターミナルを開くか、設定を再読み込み：
```bash
source ~/.zshrc
```

zsh プラグイン（zsh-autosuggestions / zsh-syntax-highlighting）は `install.sh` が
`~/.zsh/plugins/` に git clone する。更新は `git -C ~/.zsh/plugins/<name> pull`。

## ディレクトリ構造

```
dotfiles/
├── .zshrc          # Zsh設定ファイル
├── .minttyrc       # Mintty設定ファイル
├── .config/        # ~/.config 配下（ファイル単位でリンク）
│   ├── ghostty/config
│   ├── git/ignore
│   ├── vim/vimrc
│   ├── yazi/yazi.toml
│   └── zellij/
│       ├── config.kdl
│       └── layouts/
│           ├── dev.kdl
│           └── n.kdl
├── install.sh      # セットアップスクリプト
└── README.md       # このファイル
```

## カスタマイズ

### 個人設定の追加

各設定ファイルは、個人用の設定ファイルを読み込む機能を持っています：

- **Zsh**: `~/.zshrc.mine` があれば自動的に読み込みます
- **Vim**: `~/.config/vim/vimrc.local` があれば自動的に読み込みます

これらのファイルを作成することで、共有設定を上書きせずに個人設定を追加できます。

### `.config` の扱い

`.config` 配下はディレクトリごとではなくファイル単位でシンボリックリンクを張る
（`~/.config` には管理対象外の設定や状態ファイルも置かれるため）。
このリポジトリは private。マシン固有の設定（`.zshenv`、`.zprofile`、`.zshrc.mine`、
`~/.config/git/config` など）は入れず、実ファイルのまま置く。

Vim のプラグイン（`~/.config/vim/bundle`）は実ディレクトリで、`vimrc` だけがリンク。
viminfo と netrw の履歴は `~/.local/state/vim/` に書く。

### 連携しているツール

`.zshrc` は次のツールがインストールされていれば有効化する（無ければ何もしない）。

- **fzf**（0.48 以降）: `Ctrl-T` ファイル、`Ctrl-R` 履歴、`Alt-C` ディレクトリ移動
- **zoxide**: `z <キーワード>` でよく使うディレクトリへ移動、`zi` で fzf から選択

## トラブルシューティング

### バックアップファイルの確認

インストール時に既存のファイルをバックアップした場合、以下のコマンドで確認できます：

```bash
ls -la ~/*.backup.*
```

不要になったら削除してください。

### 設定の再読み込み

設定を変更した後は、以下のコマンドで再読み込みできます：

```bash
# Zsh設定
source ~/.zshrc

# Vim設定（Vim内で）
:source $MYVIMRC
```

