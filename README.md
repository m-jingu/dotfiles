# dotfiles

個人的な開発環境設定ファイルのリポジトリ

## 概要

このリポジトリには、以下の開発環境の設定ファイルが含まれています：

- **Zsh設定** (`.zshrc`) - シェル環境の設定
- **Vim設定** (`.vimrc`) - エディタの設定
- **Mintty設定** (`.minttyrc`) - Windowsターミナルの設定

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

4. （オプション）zplugプラグインをインストール：
```bash
zplug install
```

## ディレクトリ構造

```
dotfiles/
├── .zshrc          # Zsh設定ファイル
├── .vimrc          # Vim設定ファイル
├── .minttyrc       # Mintty設定ファイル
├── install.sh      # セットアップスクリプト
└── README.md       # このファイル
```

## カスタマイズ

### 個人設定の追加

各設定ファイルは、個人用の設定ファイルを読み込む機能を持っています：

- **Zsh**: `~/.zshrc.mine` があれば自動的に読み込みます
- **Vim**: `~/.vimrc.local` があれば自動的に読み込みます

これらのファイルを作成することで、共有設定を上書きせずに個人設定を追加できます。

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
:source ~/.vimrc
```

