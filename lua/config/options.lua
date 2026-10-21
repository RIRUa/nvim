-- ========================================
-- 基本設定
-- ========================================

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

vim.opt.termguicolors = true
vim.opt.cursorline = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

-- CursorHold（LSP の同一シンボルハイライトなど）を早く発火させる
vim.opt.updatetime = 250

vim.opt.clipboard = "unnamedplus"

-- Escで検索ハイライトを消す
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")


-- ========================================
-- Leader key
-- ========================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\" -- config/lazy.lua と揃える

-- Ctrl + h/j/k/l でウィンドウ移動
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- ========================================
-- コードの折り畳み機能
-- ========================================
function Foldtext()
    local line = vim.fn.getline(vim.v.foldstart)
    local count = vim.v.foldend - vim.v.foldstart + 1
    return string.format("%s (%d lines folded)", line, count)
end

vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99
vim.opt.foldtext = "v:lua.Foldtext()"
vim.opt.fillchars = { fold = " " }

vim.keymap.set("n", "<Tab>", "zo")
vim.keymap.set("n", "<S-Tab>", "zc")
vim.keymap.set("n", "<Leader><Tab>", "zR")
vim.keymap.set("n", "<Leader><S-Tab>", "zM")
