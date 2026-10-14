-- ------------------------------------
-- 見た目
-- ------------------------------------
return {
    {
        "folke/tokyonight.nvim",
        priority = 1000,

        config = function()
            vim.cmd.colorscheme("tokyonight")
        end,
    },
    {
        "frostzt/bongo-cat.nvim",
        config = function()
            require("bongo-cat").setup({
                -- Window settings
                window = {
                    position = "bottom-right", -- "top-left", "top-right", "bottom-left", "bottom-right"
                    width = 40,
                    height = 12,
                    border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
                    winblend = 0,       -- Transparency (0-100)
                    zindex = 50,
                },

                -- Animation settings
                animation = {
                    fps = 30,
                    idle_timeout = 2000, -- Ms before cat goes idle
                    combo_decay = 1000,  -- Ms before combo resets
                },

                -- Combo thresholds (keystrokes per second)
                combo = {
                    enabled = true,
                    thresholds = {
                        normal = 0,
                        excited = 3, -- Gets sparkly
                        hyper = 6,   -- Both paws bongo!
                    },
                },

                -- Stats tracking
                stats = {
                    enabled = true,
                    persist = true, -- Save stats between sessions
                },

                -- Mode-specific appearances
                modes = {
                    enabled = true,
                },

                -- Event reactions
                events = {
                    on_save = true,  -- Happy animation on save
                    on_error = true, -- Sad animation on error
                },

                -- Auto-start
                auto_start = false,

                -- Keymaps
                keymaps = {
                    toggle = "<leader>bc", -- Set to false to disable
                },
            })
        end,
    }
}
