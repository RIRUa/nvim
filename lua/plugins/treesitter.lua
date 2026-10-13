-- ------------------------------------
-- Treesitter
-- ------------------------------------
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        opts = {
            ensure_installed = { "go", "gomod", "gosum", "lua", "vim", "vimdoc", "query", },
        },
        config = function(_, opts) require("nvim-treesitter").setup(opts) end,
    },
}
