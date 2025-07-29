local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

S.Sort = {}



-- Sorts two entries by two supplied values, resorting to DefaultSort if they are identical
-- If inverse is 'true' then the keys are sorted ascending instead of descending
--
-- Returns:
-- value1 < value2  = -1
-- value1 == value2 = 0
-- value1 > value2  = 1
function S.Sort.ByValue(inverse, value1, value2, entry1, entry2)
    -- Put items with a nil value last
    if not value1 then
        if not value2 then
            return 0
        else
            return 1 -- Only value1 is nil
        end
    elseif not value2 then
        return -1 -- Only value2 is nil
    end
    -- Values are identical, resort to a default sorting method
    if value1 == value2 then
        return 0
    end

    -- Something's gone wrong. Values aren't comparable
    --if type(value1) ~= type(value2) then
    --    return 0
    --end

    -- Sort by the value
    if value1 < value2 then
        return inverse and 1 or -1
    else
        return inverse and -1 or 1
    end
end

-- Sorts two entries by their 'key', resorting to DefaultSort if they are identical
-- If inverse is 'true' then the keys are sorted ascending instead of descending
function S.Sort.ByKey(inverse, entry1, entry2, key)
    return S.Sort.ByValue(inverse, entry1[key], entry2[key], entry1, entry2)
end