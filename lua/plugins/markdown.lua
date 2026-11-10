-- ------------------------------------
-- Markdown
-- ------------------------------------
-- パーサー（markdown / markdown_inline）は plugins/treesitter.lua で導入する。
return {
    {
        -- バッファ内で見出し・コードブロック・表・チェックボックスなどを装飾表示する
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        ft = { "markdown" },
        keys = {
            { "<leader>ur", "<cmd>RenderMarkdown buf_toggle<cr>", desc = "Markdown 装飾の切り替え" },
        },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },
    {
        -- ブラウザでのライブプレビュー
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
        -- ビルド済みバイナリをダウンロードする（node 不要）
        build = function()
            -- 遅延読み込みのため、build 時点では autoload 関数が使えない。先にロードする
            require("lazy").load({ plugins = { "markdown-preview.nvim" } })
            vim.fn["mkdp#util#install"]()
        end,
        keys = {
            { "<leader>up", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown プレビューの切り替え" },
        },
    },
}
