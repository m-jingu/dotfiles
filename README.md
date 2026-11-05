# dotfiles

Personal shell and editor configuration for macOS and Linux.

## Contents

- **Zsh** (`.zshenv` and `.config/zsh/`): `~/.zshenv` only sets `ZDOTDIR=~/.config/zsh`; everything else lives in `~/.config/zsh/`
- **Starship** (`.config/zsh/starship.toml`): prompt. Without starship, zsh falls back to a plain prompt with the same layout
- **Vim** (`.config/vim/vimrc`): Vim 9.1.0327 and later read `~/.config/vim` natively. Used on Linux
- **Neovim** (`.config/nvim/`): macOS only. A port of the vimrc with a few plugins managed by the built-in `vim.pack` (Neovim 0.12+); `EDITOR`, `vi` and `vim` point to `nvim` on macOS when it is installed
- **Git global ignore** (`.config/git/ignore`): git reads this path by default, so no `core.excludesFile` is needed
- **Mintty** (`.minttyrc`): Windows terminal; `install.sh` links it on Windows (MSYS / Cygwin) only
- **Ghostty** (`.config/ghostty/config`): terminal emulator (macOS)
- **Zellij** (`.config/zellij/config.kdl`, `layouts/dev.kdl`, `themes/nord-hl.kdl`): terminal multiplexer
- **Yazi** (`.config/yazi/`): file manager

## Setup

### Requirements

- git
- bash (to run `install.sh`)
- zsh

### Install

1. Clone the repository (public, no authentication needed):
```bash
git clone https://github.com/m-jingu/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Run the install script:
```bash
./install.sh
```

3. Open a new terminal, or reload the shell:
```bash
exec zsh
```

The zsh plugins (zsh-autosuggestions, zsh-history-substring-search, fast-syntax-highlighting)
are cloned into `~/.local/share/zsh/plugins/` by `install.sh`, and by zsh at startup if any is
missing. Update them with `zplugin-update`.

If starship is not installed, `install.sh` ends by printing the command that installs it on
this OS (Homebrew, pacman, apk, pkg, apt when packaged, or the official installer into
`~/.local/bin`, which needs no sudo).

## Layout

```
dotfiles/
├── .zshenv         # Bootstrap: sets ZDOTDIR and sources ~/.config/zsh/.zshenv
├── .minttyrc       # Mintty (Windows only)
├── .config/        # Linked into ~/.config file by file
│   ├── ghostty/config
│   ├── git/ignore
│   ├── nvim/       # init.lua, nvim-pack-lock.json (macOS only)
│   ├── vim/vimrc
│   ├── yazi/       # yazi.toml, keymap.toml, init.lua, package.toml, helper scripts
│   ├── zellij/
│   │   ├── config.kdl
│   │   ├── layouts/
│   │   │   └── dev.kdl
│   │   └── themes/
│   │       └── nord-hl.kdl
│   └── zsh/
│       ├── .zshenv     # Environment variables and PATH (Homebrew paths on macOS only)
│       ├── .zprofile   # Reorders PATH after path_helper (macOS only)
│       ├── .zshrc      # Interactive shell; sources the modules below
│       ├── macos.zsh   # pyenv/rbenv, gcloud, rustup, zdev/za/y (macOS only)
│       ├── {aliases,bindings,fzf,plugins,prompt,terminal}.zsh
│       └── starship.toml
├── install.sh      # Setup script
└── README.md       # This file
```

## Customization

### Local settings

Machine-specific settings go in files that are read if present and are not tracked here:

- **Zsh**: `~/.config/zsh/.zshrc.mine` is sourced last (secrets and anything for one machine only)
- **Vim**: `~/.config/vim/vimrc.local` is sourced at the end of `vimrc`
- **Neovim**: `~/.config/nvim/local.lua` is run at the end of `init.lua`

They extend or override the shared settings without editing them.

### How `.config` is linked

Files under `.config` are linked one by one rather than as whole directories, because
`~/.config` also holds configs and state this repository does not manage.
The entries listed in `MACOS_ONLY` in `install.sh` (`nvim/`, zsh's `.zprofile` and `macos.zsh`)
are linked on macOS only. Machine-specific files (`~/.config/zsh/.zshrc.mine`, `~/.config/git/config`, ...)
stay out of the repository as plain files.

Vim plugins (`~/.config/vim/bundle`) are a real directory; only `vimrc` is a link.
viminfo and netrw history go to `~/.local/state/vim/`.

### Optional tools

`.config/zsh/.zshrc` enables these when they are installed and does nothing otherwise:

- **fzf** (0.48+): `Ctrl-T` files, `Ctrl-R` history, `Alt-C` change directory
- **zoxide**: `z <keyword>` jumps to a frequently used directory, `zi` picks one with fzf

## Troubleshooting

### Backups

When `install.sh` replaces an existing file with a link, it keeps the old file as a backup:

```bash
ls -la ~/*.backup.*
```

Delete them once they are no longer needed.

### Reloading

After changing the configuration:

```bash
# Zsh
exec zsh

# Vim / Neovim (inside the editor)
:source $MYVIMRC
```
