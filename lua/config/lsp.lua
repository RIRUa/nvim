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
        -- 言語サーバーが Type Definition をサポートしているかチェック
        if client:supports_method("textDocument/typeDefinition") then
            local opts = { noremap = true, silent = true, buffer = buf, desc = "LSP: Go to Type Definition" }

            -- キーマップを設定（ここでは 'gt' に割り当てていますが、好みに合わせて変更してください）
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
        end

        -- 1. 関数の引数ヘルプ（インサートモード中に Ctrl+k で呼び出せるようにする）
        if client:supports_method("textDocument/signatureHelp") then
            vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
        end

        -- 2. Code Lens の実行（goplsのテスト実行などに必須）
        if client:supports_method("textDocument/codeLens") then
            vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Code Lens run" })
        end

        -- 3. カーソル下の同じ変数を自動ハイライト（キーマップではなく自動コマンド）
        if client:supports_method("textDocument/documentHighlight") then
            local group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = buf,
                group = group,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = buf,
                group = group,
                callback = vim.lsp.buf.clear_references,
            })
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
