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
    }
}
