return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            theme = "auto", -- カラースキームに合わせて自動調整
            section_separators = "",
            component_separators = "",
            icons_enabled = true,
        },
    },
}
