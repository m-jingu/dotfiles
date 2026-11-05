-- Neovim configuration (macOS). Ports .config/vim/vimrc, which Linux hosts
-- keep using with plain Vim. Settings that are already Neovim defaults
-- (hlsearch, incsearch, autoindent, backspace, history=10000, laststatus=2,
-- showcmd, nostartofline, hidden, belloff=all, utf-8) are not repeated.

-- ============================================
-- Remote plugin providers
-- ============================================
-- Turn off the Python/Ruby/Perl/Node providers; nothing here uses them. The
-- Python one probes python3 (a pyenv shim on macOS) the first time a .py file
-- opens, which took about a second.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- ============================================
-- Plugins (vim.pack, built into Neovim 0.12+)
-- ============================================
-- Installed on first start into ~/.local/share/nvim/site/pack/core/opt and
-- pinned in nvim-pack-lock.json next to this file. Update with
-- :lua vim.pack.update()

-- nvim-treesitter needs its parsers rebuilt whenever the plugin is updated.
-- Defined before vim.pack.add so it also sees the first install.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  "https://github.com/w0ng/vim-hybrid",              -- Color scheme (same as the vimrc)
  "https://github.com/nvim-lualine/lualine.nvim",    -- Status line (replaces lightline)
  "https://github.com/lewis6991/gitsigns.nvim",      -- Git change signs in the sign column
  "https://github.com/vimoutliner/vimoutliner",      -- Outline editing (.otl files)
  -- Tree-sitter parsers and queries; the main branch needs the tree-sitter
  -- CLI and a C compiler to build parsers (brew install tree-sitter-cli)
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

-- ============================================
-- Display
-- ============================================
-- Truecolor is detected automatically (termguicolors), so hybrid uses its
-- GUI palette; the vimrc turns it on the same way to look identical.
vim.o.background = "dark"
vim.cmd.colorscheme("hybrid")

vim.o.number = true
vim.o.cursorline = true            -- Highlight the current line
vim.o.cursorcolumn = true          -- Highlight the current column
vim.o.wrap = true                  -- Soft-wrap long lines
vim.o.textwidth = 0                -- Never hard-wrap while typing
vim.o.scrolloff = 5                -- Keep 5 lines visible around the cursor

-- Invisible characters
vim.o.list = true
vim.o.listchars = "tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↓"

-- The mode is shown by lualine
vim.o.showmode = false

-- Mouse off, as in the vimrc, so zellij's mouse selection copies text
vim.o.mouse = ""

-- ============================================
-- Files
-- ============================================
vim.o.fileencoding = "utf-8"
vim.o.swapfile = false
vim.o.writebackup = false
vim.o.backup = false
vim.o.switchbuf = "useopen"        -- Jump to a window already showing the buffer

-- ============================================
-- Indentation
-- ============================================
vim.o.tabstop = 4                  -- Width of a tab character
vim.o.shiftwidth = 4               -- Width of one indent level
vim.o.expandtab = true             -- Indent with spaces
vim.o.shiftround = true            -- Round indents to a multiple of shiftwidth

-- ============================================
-- Search, completion and matching
-- ============================================
vim.o.ignorecase = true            -- Case-insensitive search...
vim.o.smartcase = true             -- ...unless the pattern has uppercase
vim.o.infercase = true             -- Adjust the case of completed words
vim.opt.matchpairs:append("<:>")   -- Treat < > as a pair too
vim.o.showmatch = true             -- Briefly jump to the matching bracket
vim.o.matchtime = 3                -- ...for 0.3 seconds

-- ============================================
-- Key mappings
-- ============================================
local map = vim.keymap.set

-- x deletes into the black hole register (visual-mode x still yanks)
map("n", "x", '"_x')

-- jj leaves insert mode
map("i", "jj", "<Esc>")

-- Esc twice clears the search highlight
map("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>", { silent = true })

-- * in visual mode searches for the selected text
map("x", "*", [["vy/\V<C-r>=substitute(escape(@v, '\/'), "\n", '\\n', 'g')<CR><CR>]], { silent = true })

-- Center the match on screen after jumping to it
for _, key in ipairs({ "n", "N", "*", "#", "g*", "g#" }) do
  map("n", key, key .. "zz")
end

-- j/k move by screen line through wrapped lines
map("n", "j", "gj", { silent = true })
map("n", "k", "gk", { silent = true })

-- vv selects to the end of the line
map("x", "v", "$h")

-- Tab jumps to the matching pair
map({ "n", "x" }, "<Tab>", "%")

-- Ctrl + h/j/k/l moves between windows
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Shift + arrows resize the window
map("n", "<S-Left>", "<C-w><")
map("n", "<S-Right>", "<C-w>>")
map("n", "<S-Up>", "<C-w>-")
map("n", "<S-Down>", "<C-w>+")

-- Cursor keys in insert mode
map("i", "<C-d>", "<Del>")
map("i", "<C-j>", "<Down>")
map("i", "<C-k>", "<Up>")
map("i", "<C-h>", "<Left>")
map("i", "<C-l>", "<Right>")

-- Ctrl+E / Ctrl+A go to the end / first non-blank of the line, as in the shell
map({ "n", "x", "o" }, "<C-e>", "<Esc>$a")
map({ "n", "x", "o" }, "<C-a>", "<Esc>^i")
map({ "i", "c" }, "<C-e>", "<Esc>$a")
map({ "i", "c" }, "<C-a>", "<Esc>^i")

-- T followed by a key toggles an option and echoes its new value
local function toggle(key, option)
  map("n", "T" .. key, function()
    vim.opt_local[option] = not vim.opt_local[option]:get()
    vim.cmd("setlocal " .. option .. "?")
  end, { desc = "Toggle " .. option })
end
toggle("s", "spell")      -- Ts: spell checking
toggle("l", "list")       -- Tl: invisible characters
toggle("t", "expandtab")  -- Tt: expand tabs to spaces
toggle("w", "wrap")       -- Tw: soft wrap
-- Tp (paste mode) is not ported: Neovim pastes bracketed text without it.

-- :w!! (write through sudo) is not ported: Neovim runs :w !cmd without a
-- terminal, so sudo cannot ask for the password there.

-- ============================================
-- Japanese text support
-- ============================================
-- Underline full-width (ideographic) spaces, which look like plain spaces
local zenkaku = vim.api.nvim_create_augroup("ZenkakuSpace", { clear = true })
local function zenkaku_highlight()
  vim.api.nvim_set_hl(0, "ZenkakuSpace", { underline = true, fg = "darkgrey", ctermfg = "darkgrey" })
end
zenkaku_highlight()
-- Color schemes reset highlights; define the group again after each one
vim.api.nvim_create_autocmd("ColorScheme", { group = zenkaku, callback = zenkaku_highlight })
-- Match U+3000 in every window (once per window)
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
  group = zenkaku,
  callback = function()
    if not vim.w.zenkaku_match then
      vim.w.zenkaku_match = vim.fn.matchadd("ZenkakuSpace", "\u{3000}")
    end
  end,
})

-- ============================================
-- Tree-sitter (nvim-treesitter)
-- ============================================
-- Parsers to keep installed in ~/.local/share/nvim/site/parser. install()
-- builds them in the background, and only when the tree-sitter CLI exists.
-- Loading the installer costs ~10ms, so it is only called when a parser is
-- actually missing.
local parsers = {
  "bash", "c", "css", "diff", "dockerfile", "git_config", "gitcommit",
  "gitignore", "go", "html", "javascript", "json", "kdl", "lua", "make",
  "markdown", "markdown_inline", "python", "query", "regex", "rust", "sql",
  "toml", "typescript", "vim", "vimdoc", "yaml",
}
local parser_dir = vim.fn.stdpath("data") .. "/site/parser/"
local missing = vim.tbl_filter(function(lang)
  return not vim.uv.fs_stat(parser_dir .. lang .. ".so")
end, parsers)
if #missing > 0 and vim.fn.executable("tree-sitter") == 1 then
  require("nvim-treesitter").install(missing)
end

-- Highlight with tree-sitter wherever a parser exists for the filetype;
-- other filetypes keep the regex syntax files. Folding stays manual.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("Treesitter", { clear = true }),
  callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})

-- ============================================
-- Plugin setup
-- ============================================
require("lualine").setup({
  options = {
    theme = "wombat",              -- Same palette as the vimrc's lightline
    icons_enabled = false,         -- Plain text; no nvim-web-devicons needed
  },
})

require("gitsigns").setup()

-- ============================================
-- Local overrides
-- ============================================
-- Source ~/.config/nvim/local.lua when it exists (kept out of the repo)
local local_config = vim.fn.stdpath("config") .. "/local.lua"
if vim.uv.fs_stat(local_config) then
  dofile(local_config)
end
