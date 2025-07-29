local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

SORTED_ARMOR_SUBCLASSES = {
    [Enum.ItemArmorSubclass.Cloth] = true,
    [Enum.ItemArmorSubclass.Leather] = true,
    [Enum.ItemArmorSubclass.Mail] = true,
    [Enum.ItemArmorSubclass.Plate] = true
}
SORTED_ACCESSORY_SUBCLASSES = {
    [Enum.ItemArmorSubclass.Generic] = true,
    [Enum.ItemArmorSubclass.Cosmetic] = true,
    [Enum.ItemArmorSubclass.Shield] = true,
    [Enum.ItemArmorSubclass.Libram] = true,
    [Enum.ItemArmorSubclass.Idol] = true,
    [Enum.ItemArmorSubclass.Totem] = true,
    [Enum.ItemArmorSubclass.Sigil] = true,
    [Enum.ItemArmorSubclass.Relic] = true
}

-- TODO: Allow custom code for filtering
--[[local filterFunctions = {}
local function UpdateFilterFunctions()
    filterFunctions = {}
    local categories = S.Settings.Get("categories2")
    for k,v in pairs(categories) do
        RunScript("function SortedTempFilterFunc(itemData) "..v.script.." end")
        filterFunctions[k] = SortedTempFilterFunc
    end
    SortedTempFilterFunc = nil
end
function S.GetFilterFunction(categoryIndex)
    return filterFunctions[categoryIndex]
end
S.Utils.RunOnEvent(nil, "SettingChanged-categories2", UpdateFilterFunctions)
S.Utils.RunOnEvent(nil, "CharacterSelected", UpdateFilterFunctions)]]


local selectedCategory = nil
function S.GetSelectedCategory()
    return selectedCategory
end

function S.SelectCategory(categoryID)
    selectedCategory = categoryID
    S.Utils.TriggerEvent("CategorySelected")
end

function S.ToggleCategory(categoryID)
    if selectedCategory == categoryID then
        selectedCategory = nil
    else
        selectedCategory = categoryID
    end
    S.Utils.TriggerEvent("CategorySelected")
end

function S.DeselectCategory()
    selectedCategory = nil
    S.Utils.TriggerEvent("CategorySelected")
end

function S.FilterItem(itemData)
    -- Filter by equipment set
    local selectedEquipSet = S.GetSelectedEquipmentSet()
    if selectedEquipSet >= 0 then
        local data = S.GetData().equipSets
        local found = false
        if data and data[selectedEquipSet] then
            for _, location in pairs(data[selectedEquipSet].locations) do
                if itemData.bag == location.bag and itemData.slot == location.slot then
                    found = true
                end
            end
            if not found then
                return true
            end
        end
    elseif selectedEquipSet == -2 then
        local data = S.GetData().equipSets
        if data then
            for _, equipSet in pairs(data) do
                for _, location in pairs(equipSet.locations) do
                    if itemData.bag == location.bag and itemData.slot == location.slot then
                        return true
                    end
                end
            end
        end
    end

    -- Filter by category
    local categories = S.Settings.Get("categories2")
    local selectedCategory = S.GetSelectedCategory()
    if not selectedCategory or not categories[selectedCategory] then
        return false
    else
        return S.Category.Filter(selectedCategory, itemData, guid)
    end
end