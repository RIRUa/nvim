-- ------------------------------------
-- LSP
-- ------------------------------------
---@type LazyPluginSpec
return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Luaのためにmasonを導入（config = true で自動初期化）
            { "williamboman/mason.nvim",          config = true },
            { "williamboman/mason-lspconfig.nvim" },
        },
        config = function()
            -- 1. Mason で管理したい Lua の LSP だけを自動インストール対象にする
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls" },
            })

            -- 2. 【非推奨対策の肝】
            -- require('lspconfig').lua_ls.setup() を完全に廃止し、
            -- Neovim 0.11標準の vim.lsp.config() で設定データを登録する
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
    }
}
