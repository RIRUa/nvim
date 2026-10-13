-- ------------------------------------
-- 補完
-- ------------------------------------
return {
    {
        "saghen/blink.cmp",
        version = "1.*",

        opts = {
            keymap = {
                preset = "none",

                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

                ["<CR>"] = { "accept", "fallback" },

                ["<Tab>"] = {
                    "select_next",
                    "snippet_forward",
                    "fallback",
                },

                ["<S-Tab>"] = {
                    "select_prev",
                    "snippet_backward",
                    "fallback",
                },

                ["<Up>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },

                ["<C-e>"] = { "hide" },
            },


            appearance = {
                nerd_font_variant = "mono",
            },

            completion = {
                documentation = {
                    auto_show = true,
                },
            },

            sources = {
                default = { "lsp", "path", "buffer" },
            },

            fuzzy = {
                implementation = "prefer_rust_with_warning",
            },
        },

        opts_extend = {
            "sources.default",
        },
    },
}
