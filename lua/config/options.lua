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

vim.opt.clipboard = "unnamedplus"

-- Escで検索ハイライトを消す
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")


-- ========================================
-- Leader key
-- ========================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ctrl + h/j/k/l でウィンドウ移動
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
