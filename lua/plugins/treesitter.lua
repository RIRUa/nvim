-- ------------------------------------
-- Treesitter
-- ------------------------------------
-- main ブランチ API 前提。パーサーのインストールには tree-sitter-cli が必要。
local parsers = { "go", "gomod", "gosum", "lua", "vim", "vimdoc", "query" }

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = false,
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
