-- ------------------------------------
-- LSP
-- ------------------------------------
---@type LazySpec
return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Luaのためにmasonを導入（config = true で自動初期化）
            { "mason-org/mason.nvim",           config = true },
            { "mason-org/mason-lspconfig.nvim" },
            "saghen/blink.cmp", -- capabilities の取得に使う
        },
        config = function()
            -- 1. Mason で管理したい LSP を自動インストール対象にする
            require("mason-lspconfig").setup({
                -- gopls は mise で管理するため含めない
                ensure_installed = { "lua_ls" },
            })

            -- 2. require('lspconfig').xxx.setup() は使わず、
            -- Neovim 0.11標準の vim.lsp.config() で設定データを登録する
            -- 全サーバー共通: blink.cmp が対応する補完機能を伝える
            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(),
            })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            -- Neovimの global型（vimなど）を認識させて警告を消す
                            globals = { "vim" },
                        },
                    },
                },
            })
        end,
    },
    {
        -- LSP 以外の Mason パッケージ（mason-lspconfig の ensure_installed は LSP 専用）
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "tree-sitter-cli", -- nvim-treesitter (main) のパーサービルドに必要
            },
        },
    },
    {
        -- Neovim の Lua API（vim.*）の補完・型情報を lua_ls に与える
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {},
    },
}
