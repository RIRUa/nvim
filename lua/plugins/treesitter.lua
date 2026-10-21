-- ------------------------------------
-- Treesitter
-- ------------------------------------
-- main ブランチ API 前提。パーサーのインストールには tree-sitter-cli が必要
-- （plugins/lsp.lua の mason-tool-installer で導入）。
local parsers = { "go", "gomod", "gosum", "lua", "vim", "vimdoc", "query" }

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = false,
        -- mason が PATH に bin を追加してから install() を呼ぶため（tree-sitter-cli を使う）
        dependencies = { "mason-org/mason.nvim" },
        config = function()
            local ts = require("nvim-treesitter")
            ts.setup()
            ts.install(parsers) -- インストール済みなら何もしない（非同期）

            -- main ブランチではハイライトを自前で開始する必要がある
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("my.treesitter", {}),
                pattern = { "go", "gomod", "gosum", "lua", "vim", "help", "query" },
                callback = function(args)
                    pcall(vim.treesitter.start, args.buf)
                end,
            })
        end,
    },
}
