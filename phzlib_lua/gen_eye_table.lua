local MIN_HUXI = 10
local table_mgr = require "table_mgr"

local cache_table = {}
function add_to_table(cards, level, huxi, eye)
    print("start at key: ",eye)
    local big_key = 0
    local small_key = 0
    local kan
    for i = 1, 10 do
        --print("i=",i)
        --print("cards[i]",cards[i])
        --print("big_key",big_key)
        big_key = big_key * 10 + cards[i]
        small_key = small_key * 10 + cards[i + 10]
    end

    local key = string.format("%d-%d eye->%d", big_key, small_key, eye)
    print(key)
    local t = cache_table[key]
    if t and t >= huxi then
        return true
    end
    table_mgr:add_eye(key, huxi)
    cache_table[key] = huxi
    return false
end

function add_menzi(cards, level, huxi, eye)
    -- 大1,2,3//6
    -- 小1,2,3//3
    -- 3-8大的顺子
    -- 11-16小的顺子
    -- 17-26大的绞
    -- 27-36小的绞
    -- 37 大的2,7,10//9
    -- 38 小的2,7,10//6

    local tmp = { 0, 0, 0 }
    for i = 1, 38 do
        local add_huxi = 0
        print("i :", i)
        tmp[1] = 0
        tmp[2] = 0
        tmp[3] = 0
        if i <= 8 then
            tmp[1] = i
            tmp[2] = i + 1
            tmp[3] = i + 2
            print(i,i+1,i+2)
        elseif i <= 16 then
            tmp[1] = i + 2
            tmp[2] = i + 3
            tmp[3] = i + 4
            print(i+2,i+3,i+4)
        elseif i <= 26 then
            tmp[1] = i - 16
            tmp[2] = i - 16
            tmp[3] = i - 6
            print(i-16,i-16,i-6)
        elseif i <= 36 then
            tmp[1] = i - 16
            tmp[2] = i - 16
            tmp[3] = i - 26
            print(i-16,i-16,i-26)
        elseif i == 37 then
            tmp[1] = 2
            tmp[2] = 7
            tmp[3] = 10
            print(2,7,10)
        elseif i == 38 then
            tmp[1] = 12
            tmp[2] = 17
            tmp[3] = 20
            print(12,17,10)
        end
        local add = true
        --print("temp1",tmp[1])
        --print("temp2",tmp[2])
        --print("temp3",tmp[3])
        for _, index in ipairs(tmp) do
            cards[index] = cards[index] + 1
            if add and cards[index] >= 3 then
                add = false
            end
        end

        if add then
            if i == 37 then
                add_huxi = 9    --大二七十
            elseif i == 38 then
                add_huxi = 6    --小二七十
            elseif i == 1 then
                add_huxi = 6  -- 大一二三
            elseif i == 9 then
                add_huxi = 3    --小一二三
            end
            --dump(cards,"-----")

            local added = add_to_table(cards, level, huxi + add_huxi, eye)
            print("added:",added)
            if not added then
                if level < 3 then
                    add_menzi(cards, level + 1, huxi + add_huxi, eye)
                end
            end
        end

        for _, index in ipairs(tmp) do
            cards[index] = cards[index] - 1
        end

    end
end
local seen = {}

function dump(t, i)
    seen[t] = true
    local s = {}
    local n = 0
    for k in pairs(t) do
        n = n + 1
        s[n] = k
    end
    table.sort(s)
    for k, v in ipairs(s) do
        print(i, v)
        v = t[v]
        if type(v) == "table" and not seen[v] then
            dump(v, i .. "\t")
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
    --for i = 1, 20 do
        cards[1] = 2
        print("eye", 1)
        add_to_table(cards, 1, 0, 1)
        add_menzi(cards, 1, 0, 1)
        cards[1] = 0
    --end
    table_mgr:dump_eye_tbl()
    print("generate end, use", os.time() - begin, "S")
end

main()
