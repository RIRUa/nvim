local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local d = ls.dynamic_node

local numeric_types = {
    int = true, int8 = true, int16 = true, int32 = true, int64 = true,
    uint = true, uint8 = true, uint16 = true, uint32 = true, uint64 = true, uintptr = true,
    float32 = true, float64 = true, complex64 = true, complex128 = true,
    byte = true, rune = true,
}

-- 型名からゼロ値のリテラルを返す
local function zero_value(type_text)
    if type_text == "string" then
        return [[""]]
    elseif type_text == "bool" then
        return "false"
    elseif numeric_types[type_text] then
        return "0"
    elseif type_text:match("^%[%d") or type_text:match("^struct") then
        return type_text .. "{}" -- 配列・無名構造体
    elseif type_text:match("^[%*%[]") or type_text:match("^map%[") or type_text:match("^<%-")
        or type_text:match("^chan") or type_text:match("^func") or type_text:match("^interface")
        or type_text == "any" or type_text == "error" then
        return "nil" -- ポインタ・スライス・map・chan・func・interface
    end
    return type_text .. "{}" -- 名前付き構造体など
end

-- カーソルを囲む関数（関数宣言・メソッド・無名関数）のノードを探す
local function enclosing_func()
    local ok, parser = pcall(vim.treesitter.get_parser, 0, "go")
    if not ok or not parser then
        return nil
    end
    parser:parse()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local node = vim.treesitter.get_node({ bufnr = 0, pos = { row - 1, col } })
    while node do
        local ty = node:type()
        if ty == "function_declaration" or ty == "method_declaration" or ty == "func_literal" then
            return node
        end
        node = node:parent()
    end
    return nil
end

-- 戻り値の型を（名前付き戻り値も含めて）1 つずつ展開して返す
local function result_types(func_node)
    local result = func_node:field("result")[1]
    if not result then
        return {}
    end
    if result:type() ~= "parameter_list" then
        return { vim.treesitter.get_node_text(result, 0) }
    end

    local types = {}
    for child in result:iter_children() do
        if child:type() == "parameter_declaration" then
            local type_text = vim.treesitter.get_node_text(child:field("type")[1], 0)
            -- `a, b int` のように名前が複数ある場合はその数だけ展開する
            for _ = 1, math.max(#child:field("name"), 1) do
                table.insert(types, type_text)
            end
        end
    end
    return types
end

-- 関数の戻り値を解析して、適切な return 文を組み立てる
local function go_return_values()
    local func_node = enclosing_func()
    if not func_node then
        -- パーサーがない・関数外の場合のフォールバック
        return sn(nil, { t("return err") })
    end

    local types = result_types(func_node)
    if #types == 0 then
        return sn(nil, { t("return") })
    end

    local vals = {}
    for idx, type_text in ipairs(types) do
        -- 最後の戻り値が error 型なら err を返す
        if idx == #types and type_text == "error" then
            table.insert(vals, "err")
        else
            table.insert(vals, zero_value(type_text))
        end
    end

    return sn(nil, { t("return " .. table.concat(vals, ", ")) })
end

-- スニペットの定義。 `iferr` と打ち込んで展開します
return {
    s("iferr", {
        t({ "if err != nil {", "\t" }),
        d(1, go_return_values, {}), -- 動的に戻り値を生成
        t({ "", "}" }),
    })
}
