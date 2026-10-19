-- ------------------------------------
-- 補完
-- ------------------------------------
return {
    {
        'L3MON4D3/LuaSnip',
        version = "v2.*",                -- 2026年現在の安定メジャーバージョン
        build = "make install_jsregexp", -- スニペット内の正規表現を動かすため（任意）
        config = function()
            -- これを追加することで、上の go.lua が自動で読み込まれます
            require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/lua/my_snippets" } })
        end
    },
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = {
            "L3MON4D3/LuaSnip",             -- 依存関係に LuaSnip を指定
            "rafamadriz/friendly-snippets", -- 定番スニペット集
        },
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

                autocomplete = {
                    enable = false,
                }
            },

            sources = {
                default = { "lsp", "path", 'snippets', "buffer" },
                providers = {
                    snippets = {
                        opts = {
                            search_paths = function()
                                local paths = { vim.fn.stdpath("config") .. "/snippets" }
                                local cwd = vim.fn.getcwd()
                                local project_vscode_path = cwd .. "/.vscode"
                                if vim.fn.isdirectory(project_vscode_path) == 1 then
                                    table.insert(paths, project_vscode_path)
                                end
                                return paths
                            end
                        }
                    }
                }
            },

            fuzzy = {
                implementation = "prefer_rust_with_warning",
            },

            -- スニペットエンジンの設定（Neovim v0.10+ の標準機能を使用）
            snippets = {
                preset = 'luasnip' -- または 'default' (vim.snippet)
            },
        },

        opts_extend = {
            "sources.default",
        },
    },
}
