" ============================================
" Vim設定ファイル
" ============================================
" このファイルは以下の機能を提供します：
" 1. プラグイン管理（NeoBundle）
" 2. 基本環境設定
" 3. キーマッピングと操作性向上
" 4. 日本語環境対応
" 5. ステータスライン設定
" 6. 開発支援機能

" ============================================
" 基本設定
" ============================================
" vi互換モードを無効化（Vimの機能をフル活用）
if &compatible
    set nocompatible
endif

" ファイルタイプ検出を一旦無効化（プラグイン読み込み後に有効化）
filetype off

" ============================================
" プラグイン管理（NeoBundle）
" ============================================
" NeoBundleの自動インストールと初期化
if has('vim_starting')
    " NeoBundleがインストールされていない場合は自動インストール
    if !isdirectory(expand("~/.vim/bundle/neobundle.vim/"))
        echo "Installing neobundle..."
        " GitからNeoBundleをクローン
        :call system("git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim")
    endif
    " NeoBundleのランタイムパスを追加
    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" NeoBundleの初期化
call neobundle#begin(expand('~/.vim/bundle'))
let g:neobundle_default_git_protocol='https'  " HTTPSプロトコルを使用

" プラグインの定義
NeoBundleFetch 'Shougo/neobundle.vim'        " NeoBundle本体
NeoBundle 'vimoutliner/vimoutliner'          " アウトライン編集支援
NeoBundle 'itchyny/lightline.vim'            " ステータスライン
NeoBundle 'w0ng/vim-hybrid'                  " カラースキーム
NeoBundle 'Shougo/vinarise.vim'              " バイナリエディタ
NeoBundle 'Shougo/unite.vim'                 " 統合インターフェース
NeoBundle 'Shougo/vimshell.vim'              " シェル統合
NeoBundle 'Shougo/vimproc'                   " 非同期処理

" プラグインのチェックと読み込み
NeoBundleCheck
call neobundle#end()

" ファイルタイプ検出を有効化
filetype plugin indent on

" ============================================
" 表示設定
" ============================================
" カラー設定
set t_Co=256                                 " 256色対応
syntax on                                    " シンタックスハイライト有効
colorscheme hybrid                           " カラースキーム設定
set bg=dark                                  " 背景をダーク配色として扱う

" 行番号とルーラー
set number                                   " 行番号表示
set ruler                                    " 右下に行・列番号表示

" カーソル表示
set cursorline                              " 現在行を強調表示
set cursorcolumn                            " 現在列を強調表示

" 折り返しとスクロール
set wrap                                    " 長い行を折り返し表示
set textwidth=0                             " 自動折り返しを無効化
set scrolloff=5                             " スクロール時の余白行数

" 不可視文字の表示
set list                                    " 不可視文字を表示
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↓

" ステータスライン
set laststatus=2                            " 常にステータスラインを表示
set showcmd                                 " コマンドを画面下部に表示

" ============================================
" エンコーディング設定
" ============================================
set encoding=utf8                           " Vim内部のエンコーディング
set fileencoding=utf-8                      " ファイル保存時のエンコーディング

" ============================================
" ファイル操作設定
" ============================================
" バックアップとスワップファイル
set noswapfile                              " スワップファイルを作成しない
set nowritebackup                           " 書き込み時のバックアップを作成しない
set nobackup                                " バックアップファイルを作成しない

" バッファ操作
set hidden                                  " 変更中のファイルでも他のファイルを開ける
set switchbuf=useopen                       " 既に開いているバッファがあればそれを使用

" ============================================
" インデント設定
" ============================================
set tabstop=4                               " タブ文字の表示幅
set shiftwidth=4                            " 自動インデントの幅
set autoindent                              " 自動インデント
set expandtab                               " タブをスペースに展開
set shiftround                              " インデントをshiftwidthの倍数に丸める

" ============================================
" 検索設定
" ============================================
set ignorecase                              " 検索時に大文字小文字を区別しない
set smartcase                               " 大文字を含む場合は大文字小文字を区別
set incsearch                               " インクリメンタルサーチ
set hlsearch                                " 検索結果をハイライト表示

" 検索履歴
set history=10000                           " コマンド・検索履歴を10000件保存

" ============================================
" 補完設定
" ============================================
set infercase                               " 補完時に大文字小文字を推測

" ============================================
" 括弧とマッチング
" ============================================
set matchpairs& matchpairs+=<:>            " 対応括弧に<と>を追加
set showmatch                               " 対応括弧をハイライト表示
set matchtime=3                             " 対応括弧の表示時間（3秒）

" ============================================
" 移動とナビゲーション
" ============================================
set nostartofline                           " 移動コマンドで行頭に移動しない

" ============================================
" バックスペース設定
" ============================================
set backspace=indent,eol,start              " バックスペースでインデント、改行、行頭を削除可能

" ============================================
" 音とビジュアル
" ============================================
set vb t_vb=                                " ビープ音を無効化
set novisualbell                            " ビジュアルベルを無効化

" ============================================
" クリップボード設定
" ============================================
" set clipboard+=unnamed                      " OSのクリップボードを使用
" set clipboard=unnamed                       " ヤンクをクリップボードにコピー

" ============================================
" マウス設定
" ============================================
"set mouse=a                                " マウスモード有効（コメントアウト）
set ttymouse=xterm2                         " xtermとscreen対応

" ============================================
" キーマッピング設定
" ============================================

" === 基本操作 ===
" 削除でレジスタに格納しない（ビジュアルモードでの選択後は格納する）
nnoremap x "_x

" 入力モード中にjjでESC
inoremap jj <Esc>

" ESCを二回押すことで検索ハイライトを消す
nmap <silent> <Esc><Esc> :nohlsearch<CR>

" w!!でスーパーユーザーとして保存（sudoが使える環境限定）
cmap w!! w !sudo tee > /dev/null %

" === 検索関連 ===
" カーソル下の単語を*で検索（ビジュアルモード）
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v, '\/'), "\n", '\\n', 'g')<CR><CR>

" 検索後にジャンプした際に検索単語を画面中央に持ってくる
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" === 移動改善 ===
" 表示行単位で行移動する
nnoremap <silent> j gj
nnoremap <silent> k gk

" vを二回で行末まで選択
vnoremap v $h

" TABで対応ペアにジャンプ
nnoremap <Tab> %
vnoremap <Tab> %

" === ウィンドウ操作 ===
" Ctrl + hjkl でウィンドウ間を移動
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Shift + 矢印でウィンドウサイズを変更
nnoremap <S-Left>  <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up>    <C-w>-<CR>
nnoremap <S-Down>  <C-w>+<CR>

" === インサートモードでの移動 ===
inoremap <c-d> <delete>
inoremap <c-j> <down>
inoremap <c-k> <up>
inoremap <c-h> <left>
inoremap <c-l> <right>

" === 画面切り替え（重複あり、要整理） ===
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <c-h> <c-w>h

" === 行移動 ===
" 行末、行の最初への移動のキーマップ設定
:map! <C-e> <Esc>$a
:map! <C-a> <Esc>^i
:map <C-e> <Esc>$a
:map <C-a> <Esc>^i

" === トグル機能 ===
" T + ? で各種設定をトグル
nnoremap [toggle] <Nop>
nmap T [toggle]
nnoremap <silent> [toggle]s :setl spell!<CR>:setl spell?<CR>    " スペルチェック
nnoremap <silent> [toggle]l :setl list!<CR>:setl list?<CR>      " 不可視文字表示
nnoremap <silent> [toggle]t :setl expandtab!<CR>:setl expandtab?<CR>  " タブ展開
nnoremap <silent> [toggle]w :setl wrap!<CR>:setl wrap?<CR>      " 折り返し
nnoremap <silent> [toggle]p :setl paste!<CR>:setl paste?<CR>    " ペーストモード

" === プラグイン連携 ===
" \ + rでスクリプト実行（quickrun連携）
nmap <Leader>r <plug>(quickrun)

" ============================================
" 日本語環境対応
" ============================================
" 全角スペースのハイライト設定
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    " カラースキーム変更時に全角スペースハイライトを再設定
    autocmd ColorScheme       * call ZenkakuSpace()
    " 全角スペースのハイライト指定
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
  augroup END
  call ZenkakuSpace()
endif

" ============================================
" ステータスライン設定（lightline）
" ============================================
let g:lightline = {
        \ 'colorscheme': 'wombat',
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
        \ },
        \ 'component_function': {
        \   'modified': 'LightLineModified',
        \   'readonly': 'LightLineReadonly',
        \   'fugitive': 'LightLineFugitive',
        \   'filename': 'LightLineFilename',
        \   'fileformat': 'LightLineFileformat',
        \   'filetype': 'LightLineFiletype',
        \   'fileencoding': 'LightLineFileencoding',
        \   'mode': 'LightLineMode'
        \ }
        \ }

" ステータスライン用のカスタム関数
function! LightLineModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
endfunction

function! LightLineFilename()
  return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
    return fugitive#head()
  else
    return ''
  endif
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

" ============================================
" 個人設定ファイルの読み込み
" ============================================
" ~/.vimrc.localが存在する場合のみ設定を読み込む
let s:local_vimrc = expand('~/.vimrc.local')
if filereadable(s:local_vimrc)
    execute 'source ' . s:local_vimrc
endif