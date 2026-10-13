-- ========================================
-- LSP設定
-- ========================================
-- ========================================
-- LSP共通設定 (有効化 & キーマッピング)
-- ========================================

vim.lsp.enable({ "lua_ls", "gopls" })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        local buf = args.buf

        -- 各種LSPキーマッピング（定義ジャンプ、ホバー、参照検索、実装移動、リネーム、コードアクション等）
        if client:supports_method("textDocument/definition") then
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf, desc = "Go to definition" })
        end
        if client:supports_method("textDocument/hover") then
            vim.keymap.set("n", "<leader>k", function() vim.lsp.buf.hover({ border = "single" }) end,
                { buffer = buf, desc = "Show hover documentation" })
        end
        if client:supports_method("textDocument/references") then
            vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = buf, desc = "LSP references" })
        end
        if client:supports_method("textDocument/implementation") then
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = buf, desc = "Go to implementation" })
        end
        if client:supports_method("textDocument/rename") then
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = buf, desc = "LSP rename" })
        end
        if client:supports_method("textDocument/codeAction") then
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "LSP code action" })
        end

        -- Goファイル保存時にインポートを自動追加・削除する設定（ここをコピペ）
        if client.name == "gopls" then
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("my.lsp.go", { clear = false }),
                buffer = args.buf,
                callback = function()
                    local params = vim.lsp.util.make_range_params()
                    params.context = { only = { "source.organizeImports" } }
                    local result = vim.lsp.buf_request_sync(args.buf, "textDocument/codeAction", params, 1000)
                    for _, res in pairs(result or {}) do
                        for _, r in pairs(res.result or {}) do
                            if r.edit then
                                vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
                            else
                                vim.lsp.buf.execute_command(r.command)
                            end
                        end
                    end
                end,
            })
        end

        -- フォーマット・補完関連
        if client:supports_method("textDocument/formatting") then
            vim.keymap.set("n", "<leader>f", function() require("conform").format({ lsp_fallback = true }) end,
                { buffer = buf, desc = "Format buffer (LSP/Conform)" })
        end
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})
