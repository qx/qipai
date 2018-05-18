local MIN_HUXI = 10
local table_mgr = require "table_mgr"

local cache_table = {}
function add_to_table(cards, level, huxi, eye)
    local big_key = 0
    local small_key = 0
    local kan
    for i = 1, 10 do
        big_key = big_key * 10 + cards[i]
        small_key = small_key * 10 + cards[i + 10]
    end

    local key = string.format("%d-%d-%d", big_key, small_key, eye)
    local t = cache_table[key]
    if t and t >= huxi then
        return true
    end

    table_mgr:add_eye(tostring(big_key), huxi)
    cache_table[key] = huxi
    return false
end

function add_menzi(cards, level, huxi)
    -- 1-8大的顺子
    -- 9-16小的顺子
    -- 17-26大的绞
    -- 27-36小的绞
    -- 37 大的2,7,10
    -- 38 小的2,7,10
    local tmp = { 0, 0, 0 }
    for i = 1, 38 do
        local add_huxi = 0
        tmp[1] = 0
        tmp[2] = 0
        tmp[3] = 0
        if i <= 8 then
            tmp[1] = i
            tmp[2] = i + 1
            tmp[3] = i + 2
        elseif i <= 16 then
            tmp[1] = i + 2
            tmp[2] = i + 3
            tmp[3] = i + 4
        elseif i <= 26 then
            tmp[1] = i - 16
            tmp[2] = i - 16
            tmp[3] = i - 6
        elseif i <= 36 then
            tmp[1] = i - 16
            tmp[2] = i - 16
            tmp[3] = i - 26
        elseif i == 37 then
            tmp[1] = 2
            tmp[2] = 7
            tmp[3] = 10
        elseif i == 38 then
            tmp[1] = 12
            tmp[2] = 17
            tmp[3] = 20
        end
        local add = true
        for _, index in ipairs(tmp) do
            cards[index] = cards[index] + 1
            if add and cards[index] >= 3 then
                add = false
            end
        end

        if add then
            if i == 1 or i == 37 then
                add_huxi = 6
            elseif i == 9 or i == 38 then
                add_huxi = 3
            end
            local added = add_to_table(cards, level, huxi + add_huxi)
            if not added then
                if level < 5 then
                    add_menzi(cards, level + 1, huxi + add_huxi)
                end
            end
        end

        for _, index in ipairs(tmp) do
            cards[index] = cards[index] - 1
        end

    end
end

function main()
    local cards = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    }
    local begin = os.time()
    print("generate start")
    for i = 1, 20 do
        cards[i] = 2
        print("eye", i)
        add_to_table(cards, 1, 0)
        add_menzi(cards, 1, 0)
        cards[i] = 0
    end
    table_mgr:dump_eye_tbl()
    print("generate end, use", os.time() - begin, "S")
end

main()
