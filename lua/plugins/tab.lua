return {
    {
        'romgrk/barbar.nvim',
        dependencies = {
            'lewis6991/gitsigns.nvim',     -- OPTIONAL: for git status
            'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
        },
        init = function() vim.g.barbar_auto_setup = false end,
        keys = {
            { "<S-h>",      "<cmd>BufferPrevious<CR>", mode = "n", desc = "Previous buffer" },
            { "<S-l>",      "<cmd>BufferNext<CR>",     mode = "n", desc = "Next buffer" },
            { "<leader>x",  "<cmd>BufferClose<CR>",    mode = "n", desc = "Close buffer" },
        },
        opts = {
            -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
            -- animation = true,
            -- insert_at_start = true,
            -- …etc.

            -- neo-tree を開いたときにタブラインがツリーと重ならないようオフセットする
            sidebar_filetypes = {
                ["neo-tree"] = { event = "BufWipeout" },
            },
        },
        version = '^1.0.0', -- optional: only update when a new 1.x version is released
    },
}
