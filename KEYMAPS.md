# キーマップ一覧

この Neovim 設定で定義しているショートカットのまとめ。

- **Leader キー**: `Space`
- **LocalLeader キー**: `\`
- 迷ったら `Space` を押して **which-key** の候補表示を見る（`<leader>?` でバッファローカルのキーマップ一覧）

## 接頭辞マップ

| 接頭辞 | 用途 | 定義元 |
|---|---|---|
| `<leader>f` | 検索（telescope） | `plugins/finder.lua` |
| `<leader>c` | コード操作（LSP） | `config/lsp.lua` |
| `<leader>g` | Git（gitsigns） | `plugins/git.lua` |
| `<leader>u` | UI トグル | 各プラグイン |
| `<leader>t` / `e` / `b` | ファイラ（neo-tree） | `plugins/filer.lua` |
| `gs` | 囲み文字操作（mini.surround） | `plugins/editor.lua` |

> 単独で使うキーを他のキーの接頭辞にしない（例: `<leader>b` を使うので `<leader>b*` は作らない）。

---

## 基本操作

| キー | モード | 動作 |
|---|---|---|
| `<Esc>` | n | 検索ハイライトを消す |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | n | ウィンドウ移動（左 / 下 / 上 / 右） |
| `<Tab>` | n | 折り畳みを開く（`zo`） |
| `<S-Tab>` | n | 折り畳みを閉じる（`zc`） |
| `<leader><Tab>` | n | すべての折り畳みを開く（`zR`） |
| `<leader><S-Tab>` | n | すべての折り畳みを閉じる（`zM`） |
| `<leader>?` | n | バッファローカルのキーマップ表示（which-key） |

## バッファ（barbar）

| キー | モード | 動作 |
|---|---|---|
| `<S-h>` | n | 前のバッファ |
| `<S-l>` | n | 次のバッファ |
| `<leader>x` | n | バッファを閉じる |

## ファイラ（neo-tree）

| キー | モード | 動作 |
|---|---|---|
| `<leader>t` | n | ツリーの開閉 |
| `<leader>e` | n | 現在のファイルをツリーで表示 |
| `<leader>b` | n | バッファ一覧（フロート） |
| `<leader>.` | neo-tree 内 | 親ディレクトリへ移動 |

## 検索（telescope）

| キー | モード | 動作 |
|---|---|---|
| `<leader>ff` | n | ファイル検索 |
| `<leader>fg` | n | 文字列検索（live grep、要 `rg`） |
| `<leader>fb` | n | バッファ検索 |
| `<leader>fh` | n | ヘルプタグ検索 |

## ジャンプ（flash）

| キー | モード | 動作 |
|---|---|---|
| `s` | n / x / o | 画面内の任意位置へジャンプ |
| `S` | n / x / o | Treesitter ノードを選んでジャンプ |
| `r` | o | リモートジャンプ |
| `R` | o / x | Treesitter 検索 |
| `<C-s>` | c | コマンドライン検索で flash を切り替え |

## 囲み文字（mini.surround）

| キー | モード | 動作 |
|---|---|---|
| `gsa` | n / x | 囲みを追加 |
| `gsd` | n | 囲みを削除 |
| `gsr` | n | 囲みを置換 |
| `gsf` / `gsF` | n | 囲みを右 / 左へ探す |
| `gsh` | n | 囲みをハイライト |
| `gsn` | n | `n_lines` を更新 |

## TODO コメント（todo-comments）

| キー | モード | 動作 |
|---|---|---|
| `]t` | n | 次の TODO コメントへ |
| `[t` | n | 前の TODO コメントへ |

## LSP

バッファローカル。**サーバーが対応している機能のみ**有効になる。

| キー | モード | 動作 |
|---|---|---|
| `gd` | n | 定義へジャンプ |
| `gr` | n | 参照一覧 |
| `gi` | n | 実装へジャンプ |
| `gt` | n | 型定義へジャンプ |
| `<leader>k` | n | ホバードキュメント |
| `<leader>rn` | n | リネーム |
| `<leader>ca` | n | コードアクション |
| `<leader>cl` | n | Code Lens 実行 |
| `<leader>cf` | n | フォーマット（conform / LSP フォールバック） |
| `<C-k>` | i | シグネチャヘルプ |

> Neovim 0.11 標準の `grr` / `gri` / `grn` / `gra` / `grt` / `grx` は `gr` と衝突するため削除済み。

## Git（gitsigns）

| キー | モード | 動作 |
|---|---|---|
| `<leader>gb` | n | カーソル行の blame（詳細） |
| `<leader>gB` | n | ファイル全体の blame |
| `<leader>ug` | n | 行末 blame の表示切り替え |

## UI トグル（`<leader>u`）

| キー | モード | 動作 |
|---|---|---|
| `<leader>ug` | n | 行末 Git blame |
| `<leader>ur` | n | Markdown 装飾（render-markdown） |
| `<leader>up` | n | Markdown プレビュー |
| `<leader>uc` | n | bongo-cat の切り替え |

## 補完・スニペット（blink.cmp / LuaSnip）

| キー | モード | 動作 |
|---|---|---|
| `<C-Space>` | i | 補完メニュー / ドキュメントの表示・非表示 |
| `<Tab>` | i | 次の候補を選択 → なければスニペットの次の位置へ |
| `<S-Tab>` | i | 前の候補を選択 → なければスニペットの前の位置へ |
| `<Up>` / `<Down>` | i | 候補の前 / 次を選択 |
| `<CR>` | i | 候補を確定（なければ通常の改行 / autopairs） |
| `<C-e>` | i | 補完メニューを閉じる |

### スニペット

| トリガー | 言語 | 内容 |
|---|---|---|
| `iferr` | Go | `if err != nil { return ... }`（囲んでいる関数の戻り値型から `return` を自動生成） |

## 保存時の自動処理（キー操作不要）

| 対象 | 処理 |
|---|---|
| Lua / Go など | conform.nvim で自動フォーマット（`format_on_save`） |
| Go（gopls） | `source.organizeImports` で import を整理 |

---

## メンテナンスメモ

- キーマップは各プラグインのスペック内（`keys` / `config`）に分散しているため、追加・変更したらこのファイルも更新する。
- 全体の構成は [CLAUDE.md](./CLAUDE.md) を参照。
