local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem = GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem
if C_Item then
    GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem = C_Item.GetItemInfoInstant, C_Item.GetItemInfo, C_Item.GetItemClassInfo, C_Item.GetItemSubClassInfo, C_Item.GetDetailedItemLevelInfo, C_Item.IsEquippableItem
end

S.Category = {}

-- Update outdated categories
S.Category.VERSION = "2.3.5"
local function UpdateCategory(cat)
    if not cat.version then
        cat.version = "2.0"
    end
    -- Version 2.1 replaced EQUIP_LOCATION with INVENTORY_SLOT
    if cat.version < "2.1" then
        local inventorySlotTable = nil

        for attrKey, attr in pairs(cat.attributes) do
            if attrKey == "EQUIP_LOCATION" then
                -- Fill the new table to put into cat.attributes["INVENTORY_SLOT"]
                inventorySlotTable = {}

                for valueKey, v in pairs(attr) do
                    if v then
                        -- Find the INVENTORY_SLOT value corresponding to the old EQUIP_LOCATION value
                        for newValueKey, equipLocTable in pairs(S.Category.newEquipLocations) do
                            local oldValueKey = equipLocTable[3]

                            if oldValueKey == valueKey then
                                -- Found it, so set it in the new table
                                inventorySlotTable[newValueKey] = true
                            end
                        end
                    end
                end
            end
        end
        cat.attributes["INVENTORY_SLOT"] = inventorySlotTable
        cat.attributes["EQUIP_LOCATION"] = nil

        cat.version = "2.1"
    end
    -- Version 2.3.5 added the option to exclude searches. This requires moving the string values into tables
    if cat.version < "2.3.5" then
        local inventorySlotTable = nil

        for attrKey, attr in pairs(cat.attributes) do
            if S.Category.attributesTable[attrKey].type == "STRINGS" then
                for i = 1, #attr do
                    if type(attr[i]) == "string" then
                        attr[i] = { ["str"] = attr[i] }
                    end
                end
            end
        end

        cat.version = "2.3.5"
    end

end
function S.Category.CheckOutdated()
    if S.Settings.GetProfile() then
        local data = S.Settings.Get("categories2")
        for _, cat in pairs(data) do
            UpdateCategory(cat)
        end
    end
end
S.Utils.RunOnEvent(nil, "EnteredWorld", S.Category.CheckOutdated)
S.Utils.RunOnEvent(nil, "ProfileChanged", S.Category.CheckOutdated)


-- Table of attributes and their filter methods
S.Category.attributesTable = {
    ["SPECIFIC_ITEMS"] = {
        ["name"] = ID,
        ["type"] = "SPECIFIC_ITEMS",
        ["func"] = function(value, itemData)
            return itemData.itemID == value.itemID or itemData.name == value.itemName
        end
    },
    ["NAME"] = {
        ["name"] = S.Localize("FILTER_NAME_SEARCH"),
        ["attribute"] = "name",
        ["type"] = "STRINGS",
        ["func"] = function(value, itemData)
            if itemData.name then
                return S.Utils.BasicTextSearch(value.str, itemData.name)
            end
        end
    },
    ["TOOLTIP"] = {
        ["name"] = S.Localize("FILTER_TOOLTIP_SEARCH"),
        ["attribute"] = "tooltip",
        ["type"] = "STRINGS",
        ["func"] = function(value, itemData)
            if itemData.tooltip then
                for side, lines in pairs(itemData.tooltip) do
                    for i, line in pairs(lines) do
                        if S.Utils.BasicTextSearch(value.str, line) then
                            return true
                        end
                    end
                end
                return false
            end
        end
    },
    ["TYPE"] = {
        ["name"] = TYPE,
        ["type"] = "VALUES",
        ["values"] = {
            -- Table is built later, scroll down
        },
        ["func"] = function(value, itemData)
            return itemData.classID == value[1] and itemData.subClassID == value[2]
        end
    },
    ["INVENTORY_SLOT"] = {
        ["name"] = S.Localize("COLUMN_EQUIP_LOCATION"),
        ["type"] = "VALUES",
        ["values"] = {
            -- Table is built later, scroll down
        },
        ["func"] = function(value, itemData)
            for _, invSlotID in pairs(value) do
                if itemData.invSlotID == invSlotID then
                    return true
                end
            end
            return false
        end
    },
    --[[
    ["STATS"] = {
        ["name"] = S.Localize("FILTER_STATS"),
        ["type"] = "RANGES",
        ["ranges"] = {

        }
    },
    ]]
    ["QUALITY"] = {
        ["name"] = S.Localize("FILTER_QUALITY"),
        ["type"] = "VALUES",
        ["values"] = {
            -- Table is built later, scroll down
        },
        ["func"] = function(value, itemData)
            return itemData.quality == value
        end
    },
    --[[
    ["TIME_ADDED"] = {
        ["name"] = S.Localize("FILTER_TIME_ADDED"),
        ["type"] = "RANGES"
    },]]
    ["BINDING"] = {
        ["name"] = S.Localize("FILTER_BINDING"),
        ["type"] = "VALUES",
        ["values"] = {
            {
                ["name"] = S.Localize("SUBFILTER_BINDING_NONE"),
                ["value"] = nil
            },
            {
                ["name"] = S.Localize("SUBFILTER_BINDING_ON_EQUIP"),
                ["value"] = {2, false}
            },
            {
                ["name"] = S.Localize("SUBFILTER_BINDING_ON_USE"),
                ["value"] = {3, false}
            },
            {
                ["name"] = S.Localize("SUBFILTER_BINDING_ON_PICKUP"),
                ["value"] = {1, true}
            },
            {
                ["name"] = S.Localize("SUBFILTER_BINDING_ON_EQUIP").." ("..S.Localize("SUBFILTER_BINDING_SOULBOUND")..")",
                ["value"] = {2, true}
            },
            {
                ["name"] = S.Localize("SUBFILTER_BINDING_ON_USE").." ("..S.Localize("SUBFILTER_BINDING_SOULBOUND")..")",
                ["value"] = {3, true}
            }
        },
        ["func"] = function(value, itemData)
            if not itemData.bindType or itemData.bindType == 0 then
                return not value
            elseif itemData.bindType == 4 then  -- Treat quest items as BoP
                itemData.bindType = 1
            end
            return itemData.bindType == value[1] and itemData.bound == value[2]
        end
    },
    ["EXPANSION"] = {
        ["name"] = S.Localize("FILTER_EXPANSION"),
        ["type"] = "VALUES",
        ["values"] = {
            {
                ["name"] = "World of Warcraft",
                ["value"] = 0
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_TBC"),
                ["value"] = 1
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_WOTLK"),
                ["value"] = 2
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_CATA"),
                ["value"] = 3
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_MOP"),
                ["value"] = 4
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_WOD"),
                ["value"] = 5
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_LEGION"),
                ["value"] = 6
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_BFA"),
                ["value"] = 7
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_SHADOW"),
                ["value"] = 8
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_DRAGONFLIGHT"),
                ["value"] = 9
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_WAR_WITHIN"),
                ["value"] = 10
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_MIDNIGHT"),
                ["value"] = 11
            },
            {
                ["name"] = S.Localize("SUBFILTER_EXPANSION_LAST_TITAN"),
                ["value"] = 12
            },
        },
        ["func"] = function(value, itemData)
            if not itemData.expacID then
                return value == 0
            end
            return itemData.expacID == value
        end
    },
    --[[
    ["LEVEL"] = {
        ["name"] = S.Localize("FILTER_LEVEL"),
        ["type"] = "RANGES"
    },
    ]]
    ["MARKER_ICON"] = {
        ["name"] = S.Localize("FILTER_MARKER_ICON"),
        ["type"] = "VALUES",
        ["values"] = {
            {
                ["name"] = S.Localize("SUBFILTER_MARKER_ICON_NONE"),
                ["value"] = 0
            },
            {
                ["name"] = S.Utils.FormatMarkerIcon(1),
                ["value"] = 1
            },
            {
                ["name"] = S.Utils.FormatMarkerIcon(2),
                ["value"] = 2
            },
            {
                ["name"] = S.Utils.FormatMarkerIcon(3),
                ["value"] = 3
            },
            {
                ["name"] = S.Utils.FormatMarkerIcon(4),
                ["value"] = 4
            },
            {
                ["name"] = S.Utils.FormatMarkerIcon(5),
                ["value"] = 5
            },
            {
                ["name"] = S.Utils.FormatMarkerIcon(6),
                ["value"] = 6
            },
            {
                ["name"] = S.Utils.FormatMarkerIcon(7),
                ["value"] = 7
            },
            {
                ["name"] = S.Utils.FormatMarkerIcon(8),
                ["value"] = 8
            },
        },
        ["func"] = function(value, itemData)
            local favorited = S.Data.GetFavorited(itemData)
            if not favorited then
                return value == 0
            end
            return favorited == value
        end
    },
}
-- Build the value table for item types
for classKey, classID in pairs(Enum.ItemClass) do
    local className = GetItemClassInfo(classID)
    if className and not string.find(string.lower(className), "obsolete") then
        --local foundLast = false
        local subClassID = 0
        while --[[not foundLast]] subClassID < 100 do
            local subClassName = GetItemSubClassInfo(classID, subClassID)
            if type(subClassName) == "string" and #subClassName > 0 then
                if not string.find(string.lower(subClassName), "obsolete") then
                    S.Category.attributesTable["TYPE"].values[classID * 1000 + subClassID] = {
                        ["heading"] = className,
                        ["name"] = subClassName,
                        ["value"] = {classID, subClassID}
                    }
                end
            --[[elseif subClassID >= 1 then
                foundLast = true]]
            end
            subClassID = subClassID + 1
        end
    end
end

--[[

Build the value table for item equip locations, from this table:

equipLocs[key] = {name, InventoryType key, pre-2.1 EQUIP_LOCATION value}
                             OR
equipLocs[key] = {name, {InventoryType keys}, pre-2.1 EQUIP_LOCATION value}

Keys are numbered for sorting                                                       ]]
local equipLocs = {
    ["01_MAINHAND"]    =      {INVTYPE_WEAPONMAINHAND, Enum.InventoryType.IndexWeaponmainhandType},
    ["02_WEAPON"]      =      {INVTYPE_WEAPON,         Enum.InventoryType.IndexWeaponType},
    ["03_2HWEAPON"]    =      {INVTYPE_2HWEAPON,       Enum.InventoryType.Index2HweaponType},

    ["11_HEAD"]        =      {INVTYPE_HEAD,           Enum.InventoryType.IndexHeadType, 1},
    ["12_NECK"]        =      {INVTYPE_NECK,           Enum.InventoryType.IndexNeckType, 2},
    ["13_SHOULDER"]    =      {INVTYPE_SHOULDER,       Enum.InventoryType.IndexShoulderType, 3},
    ["14_CHEST"]       =      {INVTYPE_CHEST, {
                                                    Enum.InventoryType.IndexChestType,
                                                    Enum.InventoryType.IndexRobeType,
                              }, 5},
    ["15_WRIST"]       =      {INVTYPE_WRIST,          Enum.InventoryType.IndexWristType, 8},
    ["16_HAND"]        =      {INVTYPE_HAND,           Enum.InventoryType.IndexHandType, 9},
    ["17_SHIRT"]       =      {INVTYPE_BODY,           Enum.InventoryType.IndexBodyType, 6},
    ["18_WAIST"]       =      {INVTYPE_WAIST,          Enum.InventoryType.IndexWaistType, 10},
    ["19_LEGS"]        =      {INVTYPE_LEGS,           Enum.InventoryType.IndexLegsType, 11},
    ["20_FEET"]        =      {INVTYPE_FEET,           Enum.InventoryType.IndexFeetType, 12},
    ["21_FINGER"]      =      {INVTYPE_FINGER,         Enum.InventoryType.IndexFingerType, 13},
    ["22_TRINKET"]     =      {INVTYPE_TRINKET,        Enum.InventoryType.IndexTrinketType, 14},
    ["23_SHIELD"]      =      {S.Localize("SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_SHIELD_OFF_HAND"), {
                                                    Enum.InventoryType.IndexShieldType,
                                                    Enum.InventoryType.IndexWeaponoffhandType,
                                                    Enum.InventoryType.IndexHoldableType,
                              }, 15},
    ["24_CLOAK"]       =      {INVTYPE_CLOAK,          Enum.InventoryType.IndexCloakType, 4},
    ["25_TABARD"]      =      {INVTYPE_TABARD,         Enum.InventoryType.IndexTabardType, 7},
}
if S.WoWVersion() < 4 then
    -- Add the Classic equip locations, for the slot next to the main hand
    equipLocs["04_RANGED"] = {INVTYPE_RANGED, {
                                Enum.InventoryType.IndexRangedType,
                                Enum.InventoryType.IndexRangedrightType,
                                Enum.InventoryType.IndexThrownType
                             }}
    equipLocs["05_AMMO"] =   {INVTYPE_AMMO,   Enum.InventoryType.IndexAmmoType}
    equipLocs["06_RELIC"] =  {INVTYPE_RELIC,  Enum.InventoryType.IndexRelicType, 16}
elseif S.WoWVersion() < 5 then
    -- Add the Cataclysm equip locations, for the slot next to the main hand, not including ammo
    equipLocs["04_RANGED"] = {INVTYPE_RANGED, {
        Enum.InventoryType.IndexRangedType,
        Enum.InventoryType.IndexRangedrightType,
        Enum.InventoryType.IndexThrownType
     }}
    equipLocs["06_RELIC"] =  {INVTYPE_RELIC,  Enum.InventoryType.IndexRelicType, 16}
else
    -- After Classic, add ranged weapons to Two-Handed
    equipLocs["03_2HWEAPON"] = {INVTYPE_2HWEAPON, {
                                Enum.InventoryType.Index2HweaponType,
                                Enum.InventoryType.IndexRangedType,
                                Enum.InventoryType.IndexRangedrightType
                             }}
end
-- Profession tools
if S.WoWVersion() >= 10 then
    equipLocs["30_PROFESSION_TOOL"] = {INVTYPE_PROFESSION_TOOL, Enum.InventoryType.IndexProfessionToolType}
    equipLocs["31_PROFESSION_GEAR"] = {INVTYPE_PROFESSION_GEAR, Enum.InventoryType.IndexProfessionGearType}
end
for key, v in pairs(equipLocs) do
    if type(v[2]) == "table" then
        S.Category.attributesTable["INVENTORY_SLOT"].values[key] = {
            ["name"] = v[1],
            ["value"] = v[2]
        }
    else
        S.Category.attributesTable["INVENTORY_SLOT"].values[key] = {
            ["name"] = v[1],
            ["value"] = {v[2]}
        }
    end
end
S.Category.newEquipLocations = equipLocs

-- Build the table for item qualities
local qualityID = 0
local qualityName = S.Utils.GetItemQualityName(qualityID)
while qualityName do
    S.Category.attributesTable["QUALITY"].values[qualityID] = {
        ["name"] = qualityName,
        ["value"] = qualityID
    }

    qualityID = qualityID + 1
    qualityName = S.Utils.GetItemQualityName(qualityID)
end


local function Data(id, guid)
    return S.Settings.Get("categories2", guid)[id]
end

function S.Category.GetName(id, guid)
    return Data(id, guid).name
end
function S.Category.SetName(id, name, guid)
    Data(id, guid).name = name
    S.Utils.TriggerEvent("SettingChanged-categories2")
end
function S.Category.GetIconTexture(id, guid)
    return "INTERFACE\\ICONS\\"..Data(id, guid).icon
end
function S.Category.SetIcon(id, icon, guid)
    Data(id, guid).icon = icon
    S.Utils.TriggerEvent("SettingChanged-categories2")
end

function S.Category.AddNew()
    local data = S.Settings.Get("categories2", guid)
    local id = #data + 1
    if id <= S.Utils.GetMaxNumCategories() then
        data[id] = {
            ["name"] = S.Localize("CONFIG_CATEGORIES_DEFAULT_NAME"),
            ["icon"] = "INV_MISC_QUESTIONMARK",
            ["attributes"] = {}
        }
        S.Utils.TriggerEvent("SettingChanged-categories2")
    end
end

function S.Category.Delete(id)
    local data = S.Settings.Get("categories2", guid)
    for i = id, #data do
        data[i] = data[i + 1]
    end
    S.Utils.TriggerEvent("SettingChanged-categories2")
end

function S.Category.GetAttribute(id, attributeKey, guid)
    local data = Data(id, guid).attributes[attributeKey]
    if data then 
        return data
    else
        return nil
    end
end

-- Deletes an attribute table if all values are empty
local function DeleteEmptyAttributeTable(id, attributeKey, guid)
    local data = Data(id, guid).attributes
    local attributeHasData = false
    for k,v in pairs(data[attributeKey]) do
        if v then
            attributeHasData = true
        end
    end
    if not attributeHasData then
        data[attributeKey] = nil
    end
end

function S.Category.ToggleAttributeValue(id, attributeKey, valueKey, guid)
    local data = Data(id, guid).attributes
    if not data[attributeKey] then
        data[attributeKey] = {}
    end
    if data[attributeKey][valueKey] then
        data[attributeKey][valueKey] = nil
    else
        data[attributeKey][valueKey] = true
    end
    
    -- Delete the table if all values are false
    DeleteEmptyAttributeTable(id, attributeKey)

    S.Utils.TriggerEvent("SettingChanged-categories2")
    S.Utils.TriggerEvent("CategorySelected")
end

function S.Category.SetAttributeString(id, attributeKey, stringIndex, stringText, guid)
    local data = Data(id, guid).attributes
    if not data[attributeKey] then
        data[attributeKey] = {}
    end
    if #stringText == 0 then
        -- It's empty, so if it exists in the table, delete it, shuffling up all the later strings
        local numStrings = #data[attributeKey]
        if stringIndex <= numStrings then
            for i = stringIndex, numStrings - 1 do
                data[attributeKey][i] = data[attributeKey][i + 1]
            end
            data[attributeKey][numStrings] = nil
        end
    else
        if not data[attributeKey][stringIndex] then
            data[attributeKey][stringIndex] = {["str"] = stringText}
        else
            data[attributeKey][stringIndex].str = stringText
        end
    end

    DeleteEmptyAttributeTable(id, attributeKey)
end
function S.Category.SetAttributeStringIncluded(id, attributeKey, index, include)
    local data = Data(id, guid).attributes
    if not data[attributeKey] or not data[attributeKey][index] then
        return
    end
    if include then
        data[attributeKey][index].exclude = nil
    else
        data[attributeKey][index].exclude = true
    end

    DeleteEmptyAttributeTable(id, attributeKey)
end

function S.Category.SetAttributeSpecificItem(id, attributeKey, index, itemID, itemName, guid)
    local data = Data(id, guid).attributes
    if not data[attributeKey] then
        data[attributeKey] = {}
    end
    if (not itemID) and (not itemName or #itemName == 0) then
        -- It's empty, so if it exists in the table, delete it, shuffling up all the later strings
        local numStrings = #data[attributeKey]
        if index <= numStrings then
            for i = index, numStrings - 1 do
                data[attributeKey][i] = data[attributeKey][i + 1]
            end
            data[attributeKey][numStrings] = nil
        end
    else
        data[attributeKey][index] = {
            ["itemID"] = itemID,
            ["itemName"] = itemName
        }
    end

    DeleteEmptyAttributeTable(id, attributeKey)
end
function S.Category.SetAttributeSpecificItemIncluded(id, attributeKey, index, include)
    local data = Data(id, guid).attributes
    if not data[attributeKey] or not data[attributeKey][index] then
        return
    end
    if include then
        data[attributeKey][index].exclude = nil
    else
        data[attributeKey][index].exclude = true
    end

    DeleteEmptyAttributeTable(id, attributeKey)
end

function S.Category.AddSpecificItem(categoryID, itemID, itemName)
    local attributeKey = "SPECIFIC_ITEMS"
    local data = Data(categoryID, nil).attributes
    local index = 1
    if data[attributeKey] then
        -- If item already exists in table, cancel
        for _, v in pairs(data[attributeKey]) do
            if v.itemID == itemID then
                return
            end
        end
        -- Set index to next entry in the table
        index = #data[attributeKey] + 1
    else
        data[attributeKey] = {}
    end
    data[attributeKey][index] = {
        ["itemID"] = itemID,
        ["itemName"] = itemName
    }
end

function S.Category.Filter(id, itemData, guid)
    local data = Data(id, guid).attributes
    local hasSpecificItems = false
    local hasFilters = false
    local filteredOut = false
    local doInclude, included = false, false

    for attributeKey, attributeData in pairs(data) do
        local attribute = S.Category.attributesTable[attributeKey]
        local useDropdownValue = S.Category.AttributeModifiedInDropdown(id, attributeKey)
        
        if attribute then
            if S.Category.attributesTable[attributeKey].type == "VALUES" then
                hasFilters = true
                local filtered = false
                local func = S.Category.attributesTable[attributeKey].func
                local values = S.Category.attributesTable[attributeKey].values

                for valueKey, enabled in pairs(attributeData) do
                    if enabled and (not useDropdownValue or S.Category.EnabledInDropdown(id, attributeKey, valueKey)) then
                        if values[valueKey] and func(values[valueKey].value, itemData) then
                            filtered = true
                        end
                    end
                end

                if not filtered then
                    filteredOut = true
                end

            elseif S.Category.attributesTable[attributeKey].type == "STRINGS" then
                hasFilters = true
                local func = S.Category.attributesTable[attributeKey].func
                local filtered = false
                for valueKey, str in pairs(attributeData) do
                    if not useDropdownValue or not S.Category.EnabledInDropdown(id, attributeKey, valueKey) then
                        if not str.exclude then
                            doInclude = true
                        end
                        if func(str, itemData) then
                            if str.exclude then
                                return true
                            else
                                included = true
                            end
                        end
                    end
                end

            -- 'Specific item' overrides other filters and forces the category to contain that item
            elseif S.Category.attributesTable[attributeKey].type == "SPECIFIC_ITEMS" then
                hasSpecificItems = true
                local func = S.Category.attributesTable[attributeKey].func
                local filtered = false
                for valueKey, str in pairs(attributeData) do
                    if not useDropdownValue or not S.Category.EnabledInDropdown(id, attributeKey, valueKey) then
                        if func(str, itemData) then
                            if str.exclude then
                                return true
                            else
                                return false
                            end
                        end
                    end
                end


            end
        end
    end

    if hasSpecificItems and not hasFilters then
        return true
    elseif doInclude then
        return not (included and not filteredOut)
    else
        return filteredOut
    end
end


-- Category right-click dropdown menu
S.Category.DropdownValues = {}
function S.Category.EnabledInDropdown(categoryID, attributeKey, valueKey)
    local t = S.Category.DropdownValues
    if t[categoryID] and t[categoryID][attributeKey] and t[categoryID][attributeKey][valueKey] then
        return true
    end
    return false
end
function S.Category.AttributeModifiedInDropdown(categoryID, attributeKey)
    local t = S.Category.DropdownValues
    if t[categoryID] and t[categoryID][attributeKey] then
        return true
    end
    return false
end
function S.Category.CategoryModifiedInDropdown(categoryID)
    local t = S.Category.DropdownValues
    if t[categoryID] then
        return true
    end
    return false
end
function S.Category.ResetDropdown(categoryID)
    S.Dropdown.Reset()
    t[categoryID] = nil
    S.Utils.TriggerEvent("CategorySelected")
    S.Utils.TriggerEvent("CategoryDropdownModified")
end

local function EntryOnClick(self)
    S.Settings.Set("categorySettingsHaveChanged", true)
    local button, categoryID, attributeKey, valueKey = unpack(self.data1)
    local t = S.Category.DropdownValues
    if not t[categoryID] then
        t[categoryID] = {}
    end
    t = t[categoryID]
    if not t[attributeKey] then
        t[attributeKey] = {}
    end
    t = t[attributeKey]
    if t[valueKey] then
        t[valueKey] = nil
    else
        t[valueKey] = true
    end
    -- Clear empty tables
    local valueFound = false
    for key, value in pairs(t) do
        if value then
            valueFound = true
        end
    end
    if not valueFound then
        S.Category.DropdownValues[categoryID][attributeKey] = nil
    end
    local valueFound = false
    for key, value in pairs(S.Category.DropdownValues[categoryID]) do
        if value then
            valueFound = true
        end
    end
    if not valueFound then
        S.Category.DropdownValues[categoryID] = nil
    end
    -- Rebuild the dropdown menu, since checkboxes may need adding/removing
    S.Category.CreateAttributesDropdown(button, categoryID)
    S.Dropdown.RestoreScrollPosition()

    S.Utils.TriggerEvent("CategorySelected")
    S.Utils.TriggerEvent("CategoryDropdownModified")
end

local function DropdownEntrySortMethod(entry1, entry2)
    if entry1.attr ~= entry2.attr then
        local type1, type2 = S.Category.attributesTable[entry1.attr].type, S.Category.attributesTable[entry2.attr].type
        if type1 ~= type2 then
            return type1 < type2
        end
        return entry1.attr < entry2.attr
    end
    return entry1.value < entry2.value
end
function S.Category.CreateAttributesDropdown(button, categoryID)
    S.Dropdown.Reset()

    local entriesToAdd = {}

    -- Build entriesToAdd table
    local attributes = Data(categoryID).attributes
    for attributeKey, attributeData in pairs(attributes) do
        -- Heading
        local attribute = S.Category.attributesTable[attributeKey]

        if attribute then
            -- Add heading
            --[[if attributeKey == "SPECIFIC_ITEMS" then
                table.insert(entriesToAdd, {
                    ["attr"] = attributeKey,
                    ["heading"] = true,
                    ["name"] = S.Localize("FILTER_SPECIFIC_ITEMS"),
                    ["isSpecificItems"] = true
                })
            else
                table.insert(entriesToAdd, {
                    ["attr"] = attributeKey,
                    ["heading"] = true,
                    ["name"] = attribute.name
                })
            end]]

            local addCheckboxes = S.Category.AttributeModifiedInDropdown(categoryID, attributeKey)

            -- Values
            if attribute.type == "VALUES" then
                for valueKey, v in pairs(attributeData) do
                    if v and attribute.values[valueKey] then
                        local data1 = {button, categoryID, attributeKey, valueKey}
                        local entry = {
                            ["attr"] = attributeKey,
                            ["value"] = valueKey,
                            ["name"] = attribute.values[valueKey].name,
                            ["data1"] = data1
                        }
                        if addCheckboxes then
                            if S.Category.EnabledInDropdown(categoryID, attributeKey, valueKey) then
                                entry.checkbox = 2
                            else
                                entry.checkbox = 1
                            end
                        end
                        table.insert(entriesToAdd, entry)
                    end
                end

            -- Strings
            elseif attribute.type == "STRINGS" then
                for valueKey, v in pairs(attributeData) do
                    local data1 = {button, categoryID, attributeKey, valueKey}
                    local entry = {
                        ["attr"] = attributeKey,
                        ["value"] = valueKey,
                        ["data1"] = data1
                    }
                    if v.exclude then
                        entry.name = "|cffff1133"..S.Localize("CONFIG_CATEGORIES_EXCLUDE")..": |cffffffff"..v.str
                    else
                        entry.name = "|cff33ee22"..S.Localize("CONFIG_CATEGORIES_INCLUDE")..": |cffffffff"..v.str
                    end
                    --if addCheckboxes then
                        if S.Category.EnabledInDropdown(categoryID, attributeKey, valueKey) then
                            entry.checkbox = 1
                        else
                            entry.checkbox = 2
                        end
                    --end
                    table.insert(entriesToAdd, entry)
                end

            -- Specific Items
            elseif attribute.type == "SPECIFIC_ITEMS" then
                for valueKey, v in pairs(attributeData) do
                    local data1 = {button, categoryID, attributeKey, valueKey}
                    local entry = {
                        ["attr"] = attributeKey,
                        ["value"] = valueKey,
                        ["data1"] = data1,
                        ["isSpecificItems"] = true
                    }
                    if v.exclude then
                        entry.name = "|cffff1133"..S.Localize("CONFIG_CATEGORIES_EXCLUDE")..": |cffffffff"
                    else
                        entry.name = "|cff33ee22"..S.Localize("CONFIG_CATEGORIES_INCLUDE")..": |cffffffff"
                    end
                    if not v.itemName or #v.itemName == 0 then
                        entry.name = entry.name.."[ID:" .. v.itemID.."]"
                    else
                        entry.name = entry.name..v.itemName
                    end
                    --if addCheckboxes then
                        if S.Category.EnabledInDropdown(categoryID, attributeKey, valueKey) then
                            entry.checkbox = 1
                        else
                            entry.checkbox = 2
                        end
                    --end
                    table.insert(entriesToAdd, entry)
                end
            end
        end
    end

    -- Sort entriesToAdd table
    table.sort(entriesToAdd, DropdownEntrySortMethod)

    -- Build the dropdown menu
    local lastHeading = nil
    for _, v in pairs(entriesToAdd) do
        if lastHeading ~= v.attr then
            S.Dropdown.AddEntry(S.Category.attributesTable[v.attr].name, nil, nil, nil, S.Utils.GetButtonTextColor())
            S.Dropdown.SetHeading()
            lastHeading = v.attr
        end
        S.Dropdown.AddEntry(v.name, EntryOnClick, v.data1, nil, S.Color.WHITE)
        if v.checkbox == 1 then
            S.Dropdown.AddCheckbox(false)
        elseif v.checkbox == 2 then
            S.Dropdown.AddCheckbox(true)
        else
            S.Dropdown.Indent()
        end
    end

    S.Dropdown.Show(button, "TOPLEFT", "BOTTOM")
end