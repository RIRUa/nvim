# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

`~/.config/nvim` に置く個人用 Neovim 設定（Lua 製、プラグイン管理は lazy.nvim）。ビルド・テスト・lint の仕組みはない。コメントは日本語、インデントは 4 スペース。Neovim 0.11 以降の API（`vim.lsp.config` / `vim.lsp.enable` / `client:supports_method`）を前提にしている。

## よく使うコマンド

- 構文・起動確認（ヘッドレス）: `nvim --headless "+qa"` （エラーが出なければ起動OK）
- プラグインの同期: `nvim --headless "+Lazy! sync" +qa`
- 設定内で `:Lazy` / `:Mason` / `:LspInfo`（`:checkhealth vim.lsp`）/ `:ConformInfo` で状態確認
- `lazy-lock.json` は `.gitignore` 対象（コミットされない）

## アーキテクチャ

読み込み順は `init.lua` で決まる:

1. `config.options` — 基本オプション、リーダーキー（Space）、ウィンドウ移動・折り畳みのキーマップ
2. `config.lazy` — lazy.nvim のブートストラップと `require("lazy").setup`。`{ import = "plugins" }` により `lua/plugins/*.lua` が全て自動でスペックとして読み込まれる（`change_detection` は無効、`checker` は有効）。ここでも `mapleader`（Space）/ `maplocalleader`（`\`）を設定している（`config.options` と同じ値）
3. `config.lsp` — プラグインとは独立した LSP の有効化とキーマップ

### LSP まわり（複数ファイルにまたがる）

- `lua/plugins/lsp.lua`: mason / mason-lspconfig で `lua_ls` / `gopls` をインストールし、`vim.lsp.config("*", ...)`（blink.cmp の capabilities）と `vim.lsp.config("lua_ls", ...)` でサーバー設定を登録する（`require("lspconfig").xxx.setup()` は使わない方針）。`lazydev.nvim` で Lua の `vim.*` 補完を与える。
- `lua/config/lsp.lua`: `vim.lsp.enable({ "lua_ls", "gopls" })` で有効化し、`LspAttach` autocmd 内で「サーバーが対応している機能のみ」バッファローカルのキーマップを張る（`gd`, `gr`, `gi`, `gt`, `<leader>k`, `<leader>rn`, `<leader>ca`, `<leader>cl`, `<leader>cf`（format）, インサートの `<C-k>`）。`gopls` では保存時（`BufWritePre`）に `source.organizeImports` を適用する。補完は blink.cmp に任せており、`vim.lsp.completion` は有効化しない。0.11 標準の `grr`/`gri`/`grn`/`gra`/`grt`/`grx` は `gr` と接頭辞が衝突するため削除している。
- キーマップの接頭辞衝突に注意（`<leader>f*`=telescope、`<leader>rn`=rename、`<leader>c*`=LSP、`<leader>u*`=UI トグル、neo-tree は `<leader>t`/`<leader>e`/`<leader>b`）。単独で使うキーを他のキーの接頭辞にしない。
- 新しい言語サーバーを追加する場合は、(1) `lua/config/lsp.lua` の `vim.lsp.enable` に追加、(2) 必要なら `lua/plugins/lsp.lua` の `ensure_installed` と `vim.lsp.config` に追加、の両方が必要。
- `lua/plugins/formatter.lua`: conform.nvim（Lua は `stylua`、Go は `gofmt`、`format_on_save` + `lsp_format = "fallback"`）。`stylua` は Mason 管理ではないので手動インストールが必要。

### 補完・スニペット

`lua/plugins/cmp.lua` に LuaSnip と blink.cmp がある。blink.cmp は `preset = "none"` で全キーマップを自前定義（Tab/S-Tab で候補選択・スニペット移動、CR で確定）、`snippets.preset = 'luasnip'`。スニペットの読み込み元は 2 系統ある:

- `lua/my_snippets/` — LuaSnip の Lua 形式スニペット（`from_lua` ローダー。現状 `go.lua` の `iferr`。treesitter（go パーサー）で囲んでいる関数の戻り値型を解析して `return` を組み立てる dynamic node を含む）
- `snippets/` — VSCode 形式 JSON（LuaSnip の `from_vscode` ローダーで読む。friendly-snippets とプロジェクトの `.vscode/` も同じローダーで読み込む。blink.cmp は `luasnip` プリセットのため LuaSnip 経由でしかスニペットを読まない）

`lua/plugins/treesitter.lua` は nvim-treesitter の `main` ブランチ API 前提（`require("nvim-treesitter").install` でパーサー導入、`FileType` autocmd で `vim.treesitter.start`）。パーサーのビルドに `tree-sitter-cli` が必要で、`lua/plugins/lsp.lua` の mason-tool-installer が Mason 経由で導入する（初回起動時はインストールが間に合わずパーサーのビルドエラーが出ることがあるので、その場合は nvim を再起動する）。

### プラグインスペットの構成

`lua/plugins/` は役割別にファイルが分かれている（`filer`=neo-tree, `finder`=telescope, `git`=gitsigns, `tab`=barbar, `status_line`=lualine, `visual`=tokyonight/bongo-cat, `treesitter`, `editor`=hlchunk など）。キーマップは各プラグインのスペック内（`keys` または `config`）で定義されており、集中管理ファイルはない。

## 注意点

- `folke/todo-comments.nvim` の設定は `lua/plugins/coding.lua`（詳細設定＋`]t`/`[t`）にある。
- `lua/config/options.lua` と `lua/config/lazy.lua` の両方で `mapleader` / `maplocalleader` を設定している（Space / `\`）。lazy.nvim 読み込み前に設定されている必要がある。
- `telescope live_grep` と `todo-comments` は ripgrep (`rg`) が必要。
