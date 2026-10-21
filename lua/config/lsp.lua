-- ========================================
-- LSP設定
-- ========================================
-- ========================================
-- LSP共通設定 (有効化 & キーマッピング)
-- ========================================

vim.lsp.enable({ "lua_ls", "gopls" })

-- 0.11 標準の gr* マッピングは自前の `gr`（references）と接頭辞が衝突し、
-- `gr` 入力後に timeoutlen 分待たされるため削除する
for _, lhs in ipairs({ "grr", "gri", "grn", "grt", "grx" }) do
    pcall(vim.keymap.del, "n", lhs)
end
pcall(vim.keymap.del, { "n", "x" }, "gra")

-- Goファイル保存時にインポートを自動追加・削除する
local function organize_imports(client, buf)
    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = { only = { "source.organizeImports" }, diagnostics = {} }
    local response = client:request_sync("textDocument/codeAction", params, 1000, buf)
    for _, action in pairs(response and response.result or {}) do
        if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        end
        -- action 自体が Command の場合（command が文字列）と CodeAction の場合（table）の両対応
        local command = type(action.command) == "table" and action.command or (action.command and action)
        if command then
            client:exec_cmd(command, { bufnr = buf })
        end
    end
end

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
            vim.keymap.set("n", "gt", vim.lsp.buf.type_definition,
                { buffer = buf, silent = true, desc = "LSP: Go to Type Definition" })
        end

        -- 1. 関数の引数ヘルプ（インサートモード中に Ctrl+k で呼び出せるようにする）
        if client:supports_method("textDocument/signatureHelp") then
            vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = buf, desc = "Signature help" })
        end

        -- 2. Code Lens の実行（goplsのテスト実行などに必須）
        if client:supports_method("textDocument/codeLens") then
            vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { buffer = buf, desc = "Code Lens run" })
        end

        -- 3. カーソル下の同じ変数を自動ハイライト（キーマップではなく自動コマンド）
        if client:supports_method("textDocument/documentHighlight") then
            -- 再アタッチ（:LspRestart など）で重複登録されないようバッファ毎に作り直す
            local group = vim.api.nvim_create_augroup("my.lsp.highlight." .. buf, { clear = true })
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

        -- Goファイル保存時にインポートを自動追加・削除する
        if client.name == "gopls" then
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("my.lsp.go." .. buf, { clear = true }),
                buffer = buf,
                callback = function()
                    organize_imports(client, buf)
                end,
            })
        end

        -- フォーマット（補完は blink.cmp に任せるので vim.lsp.completion は有効化しない）
        if client:supports_method("textDocument/formatting") then
            vim.keymap.set("n", "<leader>cf", function() require("conform").format({ lsp_format = "fallback" }) end,
                { buffer = buf, desc = "Format buffer (LSP/Conform)" })
        end
    end,
})
