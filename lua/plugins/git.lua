-- ------------------------------------
-- Git
-- ------------------------------------
return {
    {
        "lewis6991/gitsigns.nvim",
        -- キーマップは <leader>g 接頭辞にまとめる（単独の <leader>g は使わない）
        keys = {
            { "<leader>gb", "<cmd>Gitsigns blame_line full=true<cr>", desc = "カーソル行の blame（詳細）" },
            { "<leader>gB", "<cmd>Gitsigns blame<cr>",                desc = "ファイル全体の blame" },
            { "<leader>ug", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "行末 blame の切り替え" },
        },
        opts = {
            current_line_blame = false, -- 行末表示は <leader>ug で切り替える
            current_line_blame_opts = { delay = 300 },
        },
    },
}
