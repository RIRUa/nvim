local function set_hlchunk_colors()
    vim.api.nvim_set_hl(0, "HLChunk1", {
        fg = "#ff0000",
        bold = true,
    })
    vim.api.nvim_set_hl(0, "HLChunk2", {
        fg = "#ff8800",
        bold = true,
    })
end

return {
    -- todo-comments の設定は coding.lua にある
    {
        "shellRaining/hlchunk.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("hlchunk").setup({
                chunk = {
                    enable = true,
                    use_treesitter = false,
                },
                indent = {
                    enable = true,
                },
            })

            set_hlchunk_colors()

            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = set_hlchunk_colors,
            })
        end,
    },
    {
        -- キーマップの候補表示（押下途中に続きのキーを出す）
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix",
            spec = {
                -- 接頭辞のグループ名（個別のキーは各スペックの desc を使う）
                { "<leader>f", group = "find (telescope)" },
                { "<leader>c", group = "code (LSP)" },
                { "<leader>u", group = "ui toggle" },
            },
        },
        keys = {
            {
                "<leader>?",
                function() require("which-key").show({ global = false }) end,
                desc = "Buffer local keymaps",
            },
        },
    },
    {
        -- 画面内の任意の位置へ数打鍵でジャンプする
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<C-s>", mode = "c",               function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
    },
    {
        -- 括弧・引用符の自動補完（blink.cmp の <CR> は fallback で autopairs に渡る）
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            check_ts = true,
        },
    },
    {
        -- 囲み文字の追加・削除・変更。flash の s / S と衝突しないよう gs 接頭辞にしている
        "echasnovski/mini.surround",
        version = false,
        keys = {
            { "gsa", desc = "Add surrounding",     mode = { "n", "x" } },
            { "gsd", desc = "Delete surrounding" },
            { "gsr", desc = "Replace surrounding" },
            { "gsf", desc = "Find surrounding (right)" },
            { "gsF", desc = "Find surrounding (left)" },
            { "gsh", desc = "Highlight surrounding" },
            { "gsn", desc = "Update n_lines" },
        },
        opts = {
            mappings = {
                add = "gsa",
                delete = "gsd",
                find = "gsf",
                find_left = "gsF",
                highlight = "gsh",
                replace = "gsr",
                update_n_lines = "gsn",
            },
        },
    },
}
