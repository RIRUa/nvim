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
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },
    {
        "shellRaining/hlchunk.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local ts_node_type = require("hlchunk.utils.ts_node_type")
            ts_node_type.go = {
                function_declaration = "function_declaration",
                method_declaration = "method_declaration",
                if_statement = "if_statement",
                for_statement = "for_statement",
                expression_switch_statement = "expression_switch_statement",
                type_switch_statement = "type_switch_statement",
                select_statement = "select_statement",
                block = "block",
            }

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
