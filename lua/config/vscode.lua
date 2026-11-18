-- --------------------
-- VSCode の設定ファイルを neo-tree 用の設定に変換する
--   - explorer.fileNesting.patterns -> neo-tree の nesting_rules
--   - files.exclude                 -> neo-tree の never_show_by_pattern（glob のまま渡す）
-- 読み込み元: ユーザー設定 → カレントの .vscode/settings.json（後者が優先）
-- --------------------
local M = {}

-- JSONC（コメント・末尾カンマ付き JSON）を素の JSON に変換する
local function strip_jsonc(text)
    -- 1 パス目: コメントを除去（文字列内の // や /* は対象外）
    local out, i, n, in_str = {}, 1, #text, false
    while i <= n do
        local c = text:sub(i, i)
        if in_str then
            out[#out + 1] = c
            if c == "\\" then
                out[#out + 1] = text:sub(i + 1, i + 1)
                i = i + 1
            elseif c == '"' then
                in_str = false
            end
        else
            local two = text:sub(i, i + 1)
            if c == '"' then
                in_str = true
                out[#out + 1] = c
            elseif two == "//" then
                local nl = text:find("\n", i, true)
                i = (nl or n + 1) - 1
            elseif two == "/*" then
                local _, e = text:find("*/", i + 2, true)
                i = e or n
            else
                out[#out + 1] = c
            end
        end
        i = i + 1
    end
    text = table.concat(out)

    -- 2 パス目: } や ] の直前にある末尾カンマを除去
    out, i, n, in_str = {}, 1, #text, false
    while i <= n do
        local c = text:sub(i, i)
        if in_str then
            out[#out + 1] = c
            if c == "\\" then
                out[#out + 1] = text:sub(i + 1, i + 1)
                i = i + 1
            elseif c == '"' then
                in_str = false
            end
        elseif c == '"' then
            in_str = true
            out[#out + 1] = c
        elseif c == "," then
            local nxt = text:match("^%s*([%]}])", i + 1)
            if not nxt then
                out[#out + 1] = c
            end
        else
            out[#out + 1] = c
        end
        i = i + 1
    end
    return table.concat(out)
end

local function read_settings(path)
    local f = io.open(path, "r")
    if not f then
        return {}
    end
    local text = f:read("*a")
    f:close()
    local ok, decoded = pcall(vim.json.decode, strip_jsonc(text))
    if not ok or type(decoded) ~= "table" then
        vim.schedule(function()
            vim.notify("VSCode 設定の読み込みに失敗: " .. path, vim.log.levels.WARN)
        end)
        return {}
    end
    return decoded
end

local function user_settings_path()
    local sysname = vim.uv.os_uname().sysname
    if sysname == "Darwin" then
        return vim.fs.joinpath(vim.env.HOME, "Library/Application Support/Code/User/settings.json")
    elseif sysname == "Windows_NT" then
        return vim.fs.joinpath(vim.env.APPDATA or "", "Code/User/settings.json")
    end
    return vim.fs.joinpath(vim.env.HOME, ".config/Code/User/settings.json")
end

-- Lua パターンのメタ文字をエスケープする
local function escape_lua(s)
    return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end

-- ---------- ネスト ----------

-- VSCode のネストパターン 1 件を neo-tree の rule に変換する（変換できなければ nil）
--   key:   "*.ts" や "package.json"（最初の * がキャプチャ）
--   value: "${capture}.js, ${capture}.d.ts"
local function convert_nesting(key, value)
    if type(key) ~= "string" or type(value) ~= "string" then
        return nil
    end
    key = key:gsub("^%*%*/", "")

    local pattern
    local star = key:find("*", 1, true)
    if star then
        -- 最初の * だけキャプチャ、以降の * は任意の文字列
        local head, tail = key:sub(1, star - 1), key:sub(star + 1)
        pattern = "^" .. escape_lua(head) .. "(.+)" .. escape_lua(tail):gsub("%%%*", ".*") .. "$"
    else
        pattern = "^" .. escape_lua(key) .. "$"
    end
    -- キーに * が無い場合の ${capture} はファイル名全体（%0）として扱う
    local capture = star and "%1" or "%0"

    local files = {}
    for part in value:gmatch("[^,]+") do
        part = vim.trim(part)
        -- ${basename} などの未対応変数を含むものは変換しない
        local has_unsupported = part:gsub("%${capture}", ""):find("%${", 1)
        if part ~= "" and not has_unsupported then
            -- 置換文字列として使うので、リテラルの % は先にエスケープする
            part = part:gsub("%%", "%%%%"):gsub("%${capture}", function()
                return capture
            end)
            files[#files + 1] = part
        end
    end
    if #files == 0 then
        return nil
    end
    return { pattern = pattern, files = files }
end

-- ---------- 除外 ----------

-- {a,b} を展開する（1 階層のみ）
local function expand_braces(glob)
    local pre, body, post = glob:match("^(.-){([^{}]*)}(.*)$")
    if not pre then
        return { glob }
    end
    local result = {}
    for alt in (body .. ","):gmatch("([^,]*),") do
        vim.list_extend(result, expand_braces(pre .. alt .. post))
    end
    return result
end

-- files.exclude の glob を neo-tree の glob に正規化する。
-- neo-tree は "/" を含むものはフルパス、含まないものはファイル名に対して照合し、
-- glob 自体は neo-tree 側で Lua パターンに変換される（* は / も跨ぐ）。
local function normalize_glob(glob)
    glob = glob:gsub("^%*%*/", "") -- 先頭の **/ は不要（名前照合になる）
    glob = glob:gsub("%*%*", "*")
    if glob:find("/", 1, true) then
        glob = "*/" .. glob -- フルパスの途中から一致させる
    end
    return glob
end

-- ---------- エントリポイント ----------

---@return { nesting_rules: table, never_show_by_pattern: string[] }
function M.load()
    local settings = {}
    local nesting, exclude = {}, {}
    local nesting_enabled = true

    for _, path in ipairs({
        user_settings_path(),
        vim.fs.joinpath(vim.fn.getcwd(), ".vscode", "settings.json"),
    }) do
        settings = read_settings(path)
        if settings["explorer.fileNesting.enabled"] ~= nil then
            nesting_enabled = settings["explorer.fileNesting.enabled"] == true
        end
        -- オブジェクト型の設定はスコープ間でキー単位にマージされる
        for k, v in pairs(settings["explorer.fileNesting.patterns"] or {}) do
            nesting[k] = v
        end
        for k, v in pairs(settings["files.exclude"] or {}) do
            exclude[k] = v
        end
    end

    local nesting_rules = {}
    if nesting_enabled then
        for key, value in pairs(nesting) do
            local rule = convert_nesting(key, value)
            if rule then
                nesting_rules["vscode:" .. key] = rule
            end
        end
    end

    local never_show = {}
    for glob, enabled in pairs(exclude) do
        -- { when = ... } 形式の条件付き除外は未対応（true のものだけ使う）
        if enabled == true then
            for _, g in ipairs(expand_braces(glob)) do
                never_show[#never_show + 1] = normalize_glob(g)
            end
        end
    end
    table.sort(never_show)

    return { nesting_rules = nesting_rules, never_show_by_pattern = never_show }
end

return M
