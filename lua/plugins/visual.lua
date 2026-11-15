-- ------------------------------------
-- 見た目
-- ------------------------------------
return {
    {
        "folke/tokyonight.nvim",
        priority = 1000,

        config = function()
            require("tokyonight").setup({
                transparent = true,
                styles = {
                    sidebars = "transparent",
                    floats = "transparent",
                },
            })

            -- アクティブなウィンドウだけ背景を付ける（非アクティブは Normal のまま透過）
            -- NormalNC は Normal の上に重ねて合成されるため、Normal 自体は透過のままにして
            -- アクティブ窓にだけ winhighlight で背景を差し替える。
            local bg_names = { "LineNr", "CursorLineNr", "FoldColumn", "SignColumn", "EndOfBuffer" }
            local bg_types = {} -- 種類 -> 背景色（define_window_bg で設定）

            local function define_window_bg()
                local c = require("tokyonight.colors").setup()
                bg_types = {
                    Active = c.bg_dark1 or c.bg_dark, -- 通常のエディタ窓
                    Sidebar = c.bg_dark, -- neo-tree
                    Terminal = c.bg_dark,
                    Help = c.bg_dark,
                    Quickfix = c.bg_highlight,
                }
                for kind, bg in pairs(bg_types) do
                    vim.api.nvim_set_hl(0, "WinBg" .. kind, { bg = bg })
                    -- 行番号などは前景色を保ったまま背景だけ差し替えたグループを作る
                    for _, name in ipairs(bg_names) do
                        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
                        hl.bg = bg
                        vim.api.nvim_set_hl(0, ("WinBg%s_%s"):format(kind, name), hl)
                    end
                end
            end

            -- filetype / buftype から背景の種類を決める（該当なしは通常窓の Active）
            local function window_bg_kind(buf)
                local ft = vim.bo[buf].filetype
                local bt = vim.bo[buf].buftype
                if bt == "terminal" then
                    return "Terminal"
                elseif ft == "neo-tree" then
                    return "Sidebar"
                elseif ft == "help" or ft == "man" then
                    return "Help"
                elseif ft == "qf" then
                    return "Quickfix"
                end
                return "Active"
            end

            -- winhighlight 文字列から指定したキーの項目を取り除く
            local function strip_winhl(winhl, keys)
                local out = {}
                for entry in vim.gsplit(winhl, ",", { plain = true, trimempty = true }) do
                    local lhs = entry:match("^([^:]+):")
                    if not (lhs and keys[lhs]) then
                        table.insert(out, entry)
                    end
                end
                return out
            end

            local managed = { Normal = true }
            for _, name in ipairs(bg_names) do
                managed[name] = true
            end

            -- 現在のタブ内の全ウィンドウに対し、アクティブ窓だけ背景を適用する
            local function apply_window_bg()
                local current = vim.api.nvim_get_current_win()
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    -- フローティングウィンドウ（補完・hover など）は触らない
                    if vim.api.nvim_win_get_config(win).relative == "" then
                        local winhl = vim.wo[win].winhighlight
                        -- 自前の設定が入っていなければ、他プラグイン（neo-tree 等）の設定として保存する
                        if not winhl:find("WinBg", 1, true) then
                            vim.w[win].winhl_orig = winhl
                        end
                        local entries = strip_winhl(vim.w[win].winhl_orig or "", managed)
                        if win == current then
                            local kind = window_bg_kind(vim.api.nvim_win_get_buf(win))
                            table.insert(entries, "Normal:WinBg" .. kind)
                            for _, name in ipairs(bg_names) do
                                table.insert(entries, ("%s:WinBg%s_%s"):format(name, kind, name))
                            end
                        end
                        local new = table.concat(entries, ",")
                        if new ~= winhl then
                            vim.wo[win].winhighlight = new
                        end
                    end
                end
            end

            local group = vim.api.nvim_create_augroup("WindowBackground", { clear = true })
            vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "TermOpen", "WinEnter" }, {
                group = group,
                -- neo-tree などが後から winhighlight を設定する場合があるので、処理を一拍遅らせる
                callback = function()
                    vim.schedule(apply_window_bg)
                end,
            })
            -- カラースキーム再読み込み時にハイライトを定義し直す
            vim.api.nvim_create_autocmd("ColorScheme", {
                group = group,
                callback = define_window_bg,
            })

            vim.cmd([[colorscheme tokyonight-night]])
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
                    toggle = "<leader>uc", -- Set to false to disable（<leader>b は neo-tree と接頭辞が衝突するため）
                },
            })
        end,
    }
}
