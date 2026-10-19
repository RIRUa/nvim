local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node

-- 関数の戻り値を解析して、適切な return 文の初期値を返す関数
local function go_return_values()
    -- 現在のカーソル位置から上に向かって関数のシグネチャを探す
    local line = vim.fn.search([[func\s\+\k\+\s*(.*)\s*(.*)\s*{]], "bnW")
    if line == 0 then
        -- 戻り値の括弧がない単純な定義（func foo() error { など）
        line = vim.fn.search([[func\s\+\k\+\s*(.*)[^{]*{]], "bnW")
    end

    if line == 0 then
        -- 関数が見つからない場合のフォールバック
        return sn(nil, { t("return err") })
    end

    local func_line = vim.fn.getline(line)

    -- 戻り値部分を抽出
    local returns = ""

    -- 1. 括弧があるパターン: func foo() (string, error) {
    local paren_returns = func_line:match("%)%s*%(([^%)]+)%)%s*{")
    if paren_returns then
        returns = paren_returns
    else
        -- 2. 括弧がないパターン: func foo() error {
        local no_paren_returns = func_line:match("%)%s*([^{]+)%s*{")
        if no_paren_returns then
            returns = no_paren_returns
        end
    end

    -- 前後の余計な空白を削除
    returns = vim.trim(returns)

    -- 戻り値がない、または空の関数の場合
    if returns == "" then
        return sn(nil, { t("return") })
    end

    -- カンマで分割して戻り値の数をカウント
    local vals = {}
    for val in string.gmatch(returns, "[^,]+") do
        val = vim.trim(val)
        if val ~= "" then
            table.insert(vals, val)
        end
    end

    local nodes = {}
    table.insert(nodes, t("return "))

    -- 戻り値の数と型に応じてデフォルト値を生成
    for idx, val in ipairs(vals) do
        -- 最後の戻り値は通常 error 型なので "err" を配置
        if idx == #vals then
            table.insert(nodes, t("err"))
        else
            -- 各型のデフォルト値を判定（型名部分を抽出）
            local type_name = val:match("%S+\\$") or val -- 名前付き戻り値 "id string" 対策

            if type_name:match("^%*") or type_name == "any" or type_name == "interface{}" then
                table.insert(nodes, t("nil"))
            elseif type_name == "string" then
                table.insert(nodes, t([[""]]))
            elseif type_name == "bool" then
                table.insert(nodes, t("false"))
            elseif type_name:match("int") or type_name:match("float") or type_name == "byte" or type_name == "rune" then
                table.insert(nodes, t("0"))
            else
                -- 判別できない型（構造体など）は一旦 nil
                table.insert(nodes, t("nil"))
            end
            table.insert(nodes, t(", "))
        end
    end

    return sn(nil, nodes)
end

-- スニペットの定義。 `ie` と打ち込んで展開します
return {
    s("iferr", {
        t({ "if err != nil {", "\t" }),
        d(1, go_return_values, {}), -- 動的に戻り値を生成
        t({ "", "}" }),
    })
}
