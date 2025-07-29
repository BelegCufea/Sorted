local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

S.API = LibStub:NewLibrary("Sorted.", 1)

S.API.Color = S.Color
S.API.IsPlayingCharacterSelected = S.IsPlayingCharacterSelected
S.API.PrintTable = S.Utils.PrintTable


-- Utilities
S.API.GetValueIcon = S.Utils.GetValueIcon
S.API.FormatValueStringNoIcon = S.Utils.FormatValueStringNoIcon
S.API.GetValueColor = S.Utils.GetValueColor

-- Updates the data of all items and all their displayed info
function S.API.TriggerFullUpdate()
    S.Data.UpdateBagContents()
end
-- Updates the data and display of one column
function S.API.UpdateColumn(columnKey)
    S.Data.UpdateColumn(columnKey)
    for _, itemList in pairs(S.itemLists) do
        for _, entryButton in pairs(itemList.entryButtons) do
            if entryButton.data.bag then
                itemList.columns[columnKey].UpdateElement(entryButton.columnElements[columnKey], entryButton.data)
            end
        end
    end
    S.Utils.TriggerEvent("BagsUpdated")
end

function S.API.DefaultItemSort(itemData1, itemData2)
    if itemData1.quality == itemData2.quality then
        if itemData1.effectiveILvl == itemData2.effectiveILvl then
            if itemData1.name == itemData2.name then
                if itemData1.combinedCount == itemData2.combinedCount then
                    return itemData1.bag * 36 + itemData1.slot > itemData2.bag * 36 + itemData2.slot
                end
                return itemData1.combinedCount > itemData2.combinedCount
            end
            return itemData1.name < itemData2.name
        end
        return itemData1.effectiveILvl > itemData2.effectiveILvl
    end
    return itemData1.quality > itemData2.quality
end

-- Sorts itemData1 and itemData2 by the supplied values, value1 and value2. Resorts to DefaultItemSort if identical.
function S.API.Sort(inverse, value1, value2, itemData1, itemData2)
    return S.Sort.ByValue(inverse, value1, value2, itemData1, itemData2, S.API.DefaultItemSort)
end

--[[
    Adds a new column, attaching a new element to every row in the table.
    Provide methods for creating these elements, and updating them when the item changes.

    Parameters:
    key - STRING - Unique identifier of the column.
    name - STRING - Name of the column displayed in the right-click dropdown menu.
    width - NUMBER - Default width, can be resized by user.

    CreateElement(frame) - FUNCTION
        Creates the displayed fontstring, or texture, or button, etc. for a single item.
        Parameters:
        frame - FRAME - The region of the intersection between column and row, in which to place widgets.

    UpdateElement(self, itemData) - FUNCTION
        Updates the element of a single item.
        Parameters:
        self - FRAME - The frame created by CreateElement.
        itemData - TABLE - Contains the following data about the item, plus anything added by S.API.AddDataToItem():
        {
            ["filtered"] = Whether the item should be greyed out (because it doesn't fit the selected category, or doesn't match the search)
            ["bag"] = Container ID of the containing bag
            ["slot"] = Slot ID of the item in the bag
            ["name"] = Item's name
            ["link"] = Item link
            ["texture"] = Numberic ID of the item's icon
            ["itemID"] = Item ID
            ["classID"] = ID of the item's type
            ["subClassID"] = ID of the item's subtype
            ["expacID"] = Expansion number
            ["hasNoValue"] = Whether the item can't be sold
            ["count"] = SHOULDN'T BE USED. Quantity items in this stack.
            ["combinedCount"] = Quantity, including any combined stacks.
            ["equipLoc"] = ItemEquipLoc, e.g. "INVTYPE_TABARD"
            ["effectiveILvl"] = Item level, corrected for any scaling
            ["bindType"] = 0: No binding, 1: BoP, 2: BoE, 3: BoU
            ["bound"] = Whether the item is soulbound
            ["key"] = The item link with some unnecessary portions removed. Used to identify if two items are equivalent
            ["value"] = The value, in copper, of ONE item sold to a vendor. Multiply by combinedCount for the total value.
            ["minLevel"] = Character level required to use the item
            ["quality"] = Enum.ItemQuality, e.g. 0 for Poor, 1 for Common, etc. Sorted uses 8 for WoWTokens and Mythic Keystones
            ["color1"] = ColorMixin. Color of the item's quality.
            ["color2"] = ColorMixin. Brightened color1 for highlighting.
            ["tinted"] = ColorMixin. Grayed out color1 for filtering.
        }

    UpdateIcon(self, iconSize, borderThickness, iconShape) - Optional 
        If the element is an icon, consider using this to apply skinning settings
        Parameters:
        self - FRAME - The frame created by CreateElement.
        iconSize - NUMBER - Value of the Icon Size setting.
        borderThickness - NUMBER - Value of the Border Thickness setting.
        iconShape - NUMBER - 0: Square, 1: Round
]]
function S.API:AddItemColumn(key, name, width, CreateElement, UpdateElement, UpdateIcon)
    S.ItemColumns[key] = {
        ["name"] = name,
        ["width"] = width,
        ["CreateElement"] = CreateElement,
        ["UpdateElement"] = UpdateElement,
        ["UpdateIcon"] = UpdateIcon,
        ["sortMethods"] = {}
    }
    for _, itemList in pairs(S.itemLists) do
        itemList:AddColumn(key)
    end
end

--[[
    Adds a sort method to a column.
    If more than one is added, then repeatedly clicking the column heading cycles through the sort methods.

    Parameters:
    columnKey - STRING - Key of the column to add the sort method to.
    title - STRING - Text to display on the column heading.

    Sort(asc, itemData1, itemData2) - FUNCTION
        Returns 1 if itemData1 comes before itemData2, -1 if it comes after, or 0 if they are the same

        Parameters:
        asc - BOOLEAN - Whether the user has sorted by ascending
        itemData1 - TABLE - Data table of the first item
        itemData2 - TABLE - Data table of the second item
    
    inverse - BOOLEAN - Optional - Set to true if sorting should start ascending instead of descending.
]]
function S.API:AddSortMethod(columnKey, title, Sort, inverse)
    table.insert(S.ItemColumns[columnKey].sortMethods, {
        ["title"] = title,
        ["func"] = Sort,
        ["inverse"] = inverse
    })
end

--[[
    For performance, loads an item's table with any extra data needed for sorting, or for UpdateElement(self, ITEMDATA).
    Be careful not to add too much, since this table is saved between sessions.
    This also allows the data to be accessed on other characters.

    Parameters:
    columnKey - STRING - Key of the column to add the method to. (UNUSED)
    func(itemData) - FUNCTION
        Using the data in itemData, add any extra values necessary for sorting to the table.
        Parameters:
        itemData - TABLE
]]
function S.API:AddDataToItem(columnKey, func)
    S.Data.AddDataToItem(func, columnKey)
end


--[[

-- EXAMPLE 
-- Remove the double square brackets, before and after, to test.

local Sorted = LibStub("Sorted.")

-- Adds a new column that displays the bag and slot ID
local CreateElement = function(f)
    f.text = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.text:SetAllPoints()
    f.text:SetJustifyH("CENTER")
    f.text:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
end
local UpdateElement = function(f, data)
    f.text:SetText(data.bag..", "..data.slot)
end
Sorted:AddItemColumn("BAGSLOT", "Bag and Slot", 48, CreateElement, UpdateElement)

-- Add a sort method that sorts first by bag, then by slot
local Sort = function(asc, data1, data2)
    local sort = Sorted.Sort(not asc, data1.bag, data2.bag)
    if sort == 0 then
        return S.Sort.ByKey(not asc, data1.slot, data2.slot)
    end
    return sort
end
Sorted:AddSortMethod("BAGSLOT", "Bag", Sort, false)

-- Add a secondary sort method that ignores the bag and only sorts by slot
Sort = function(asc, data1, data2)
    if data1.slot == data2.slot then
        return Sorted.DefaultItemSort(data1, data2)
    end
    if asc then
        return data1.slot < data2.slot
    else
        return data1.slot > data2.slot
    end
end
Sorted:AddSortMethod("BAGSLOT", "Slot", Sort, false)

]]