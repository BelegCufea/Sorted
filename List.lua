local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local COLUMN_HEADING_HEIGHT = 24
local numFilteredItems = 0
local COLUMN_HISTORY_STATES = 10

local function GetSortArrow(ascending)
    local s = "|TInterface\\Addons\\Sorted\\Textures\\Sort-Arrow"
    if S.Settings.Get("fontOutline") > 0 then
        s = s.."-Outline"
        if S.Settings.Get("fontOutline") > 1 then
            s = s..":0:0:-5"
        else
            s = s..":0:0:-2"
        end
    else
        s = s..":0:0:-1"
    end
    if not ascending then
        s = s..":-1:16:16:0:16:0:16|t"
    else
        s = s..":0:16:16:0:16:16:0|t"
    end
    return s
end

local function GetSortMethod(self)
    local columnSettings = self:GetColumnSettings()
    if not self.columns[columnSettings.selectedColumn] then
        columnSettings.selectedColumn = S.Settings.defaults[self.columnSettingsKey].selectedColumn
    end
    return self.columns[columnSettings.selectedColumn].sortMethods[columnSettings["sortMethod"]], columnSettings["sortAsc"]
end
local function GetSortMethodHistory(self)
    return self:GetColumnSettings().historyStates
end
local function ToggleSortMethod(self, columnKey)
    local cs = self:GetColumnSettings()
    local col = self.columns[columnKey]
    if col.sortMethods then
        -- Toggle asc/desc, or switch to next sort method
        if cs.selectedColumn == columnKey then
            if not cs.sortAsc then
                cs.sortAsc = true
            else
                cs.sortAsc = false
                cs.sortMethod = cs.sortMethod + 1
                if not col.sortMethods[cs.sortMethod] then
                    cs.sortMethod = 1
                end
                -- Remember the last used sort method
                if not cs.lastSortMethod then
                    cs.lastSortMethod = {}
                end
                cs.lastSortMethod[columnKey] = cs.sortMethod
            end
            -- Update history
            if not cs.historyStates then cs.historyStates = {} end
            cs.historyStates[1] = {
                ["key"] = columnKey,
                ["sortMethod"] = cs.sortMethod,
                ["asc"] = cs.sortAsc
            }

        -- Switch to a different column, and add to history
        else
            if not cs.historyStates then
                cs.historyStates = {}
            end
            table.insert(cs.historyStates, 1, {
                ["key"] = columnKey,
                ["sortMethod"] = 1,
                ["asc"] = false
            })
            if #cs.historyStates > COLUMN_HISTORY_STATES then -- Cap the number of history states
                table.remove(cs.historyStates, COLUMN_HISTORY_STATES + 1)
            end

            cs.selectedColumn = columnKey
            cs.sortAsc = false
            -- Restore the previous sort method
            if cs.lastSortMethod and cs.lastSortMethod[columnKey] then
                cs.sortMethod = cs.lastSortMethod[columnKey]
            else
                cs.sortMethod = 1
            end
        end
    elseif columnKey == "FAVORITES" then
        cs.favoritesOnTop = not cs.favoritesOnTop
        S.Utils.TriggerEvent("SortingChanged")
        S.Utils.TriggerEvent("ColumnsChanged")
    end
    S.Utils.TriggerEvent("SortingChanged")
end


local function FilterEntries(self)
    return
end

-- God I wish I had better names for these functions, but here goes...
-- EntryHasData returns true when the entry refers to an object that exists
-- For example, a currency with 0 quantity, or an empty item slot in a bag, should return false
local function EntryHasData(self, entry)
    return true
end
-- GetDataForEntry returns the data referenced by the entry
-- For example, an item entry doesn't store all the data about an item, but has the attributes 'bag' and 'slot'
-- This function should pass those attributes to S.Data.GetItem to get the actual data
local function GetDataForEntry(self, entry)
    return {}
end

-- For each entry in .entryData, adds attributes:
--   .data referencing the data from GetDataForEntry
--   .hasData, a boolean indicating whether the entry should be displayed
local function UpdateEntryData(self)
    for k,v in pairs(self.entryData) do
        v.data = self:GetDataForEntry(v)
        v.hasData = self:EntryHasData(v)
    end
end

-- Creates a table which can be iterated through in order to produce the displayed list
-- Copied from .entryData, but also:
-- Is sorted
-- Includes group headings
-- Doesn't include empty item slots
-- Filters items
-- Combine item stacks
local function UpdateDisplayedEntryData(self)
    local entryDataTable = self.entryData

    -- Reset entry data
    for k,v in pairs(self.entryData) do
        v.isCombined = nil
        v.otherLocations = nil
    end
    for k,v in pairs(self.entryButtons) do
        v.isCombined = nil
        v.otherLocations = nil
    end

    -- Load up each entry with its data
    self:UpdateEntryData()

    -- Filter items
    if self.FilterEntries then
        self:FilterEntries()
    end

    -- Combine stacks in a new entryDataTable
    -- Makes a table 'items' which is indexed by item key
    -- Then adds them to entryDataTable indexed by number
    local doCombineStacks = self.canCombineStacks and S.Settings.Get("combineStacks") == 1
    if doCombineStacks then
        entryDataTable = {}
        local unfilteredItems, filteredItems = {}, {}
        for _, entry in pairs(self.entryData) do
            if entry.hasData then
                local key = entry.data.key

                local items
                if entry.filtered then
                    items = filteredItems
                else
                    items = unfilteredItems
                end

                if items[key] then
                    -- Combine entry with the existing entry
                    items[key].data.combinedCount = items[key].data.combinedCount + entry.data.count
                    items[key].isCombined = true
                    if not items[key].otherLocations then
                        items[key].otherLocations = {}
                    end
                    local t = {}
                    for k,v in pairs(entry) do
                        t[k] = v
                    end
                    t.isCombined = false
                    t.data.combinedCount = t.data.count
                    table.insert(items[key].otherLocations, t)
                else
                    local t = {}
                    for k,v in pairs(entry) do
                        t[k] = v
                    end
                    t.data.combinedCount = entry.data.count
                    t.isCombined = false
                    items[key] = t
                end
            end
        end
        local i = 1
        for _, item in pairs(unfilteredItems) do
            entryDataTable[i] = item
            i = i + 1
        end
        for _, item in pairs(filteredItems) do
            entryDataTable[i] = item
            i = i + 1
        end
    else
        for _, entry in pairs(self.entryData) do
            entry.data.combinedCount = entry.data.count
        end
    end

    -- Sort .entryData
    self:SortTable(entryDataTable)

    --Insert extra entries from combined stacks that the user has expanded
    if doCombineStacks then
        local i = 1
        while i <= #entryDataTable do
            local entry = entryDataTable[i]
            if entry.isCombined then
                if self.expandedCombinedItems[entry.data.key] then
                    entry.data.combinedCount = entry.data.count
                    for k,v in pairs(entry.otherLocations) do
                        i = i + 1
                        table.insert(entryDataTable, i, v)
                    end
                end
            end
            i = i + 1
        end
    end

    -- Create .displayedEntryData
    self.displayedEntryData = {}

    -- Iterate over entryData and build displayedEntryData
    -- i is the current index of entryData
    -- j is the current index of displayedEntryData
    local i,j = 1,1
    local grouping = self:GetGrouping()
    local heading, headingCollapsed, foundFilteredItem = nil, nil, nil
    local groupName, groupOrder = nil, nil
    local groupEntriesCount, lastGroupHeadingIndex = 0, nil
    local entryData = nil
    numFilteredItems = 0
    
    while i <= #entryDataTable do
        entryData = entryDataTable[i]

        if not entryData.hasData then
            i = i + 1

        elseif entryData.filtered then
            -- Add a heading for greyed out filtered items
            if not foundFilteredItem and entryData.filtered then
                foundFilteredItem = true
                -- Add line break
                if j > 1 then
                    if self.gridView then
                        -- Get to the next row
                        while j % self.numEntriesAcross ~= 1 do
                            self.displayedEntryData[j] = {
                                ["isEmpty"] = true
                            }
                            j = j + 1
                        end
                    else
                        self.displayedEntryData[j] = {
                            ["isEmpty"] = true
                        }
                        j = j + 1
                    end
                end
                self.displayedEntryData[j] = {
                    ["isFilteredHeading"] = true
                }
                j = j + 1
                if self.gridView then
                    -- Get to the next row
                    while j % self.numEntriesAcross ~= 1 do
                        self.displayedEntryData[j] = {
                            ["isEmpty"] = true
                        }
                        j = j + 1
                    end
                end
            else
                if not S.Settings.Get("filteredCollapsed") then
                    self.displayedEntryData[j] = entryData
                    j = j + 1
                end
                numFilteredItems = numFilteredItems + 1
                i = i + 1
            end

        else--[[if grouping then]]
            local prevGroupOrder = groupOrder
            groupName, groupOrder = self:GetEntryGroup(entryData)--self.groups[grouping].func(entryData.data)

            -- Add a new group heading if this entry is in a new group
            -- Don't add a heading for greyed out, filtered items at the bottom of the list
            -- Also don't add a heading for OTHER items, if it's the only group
            if not entryData.filtered and heading ~= groupName and not (groupOrder == 0 and not heading) then

                if lastGroupHeadingIndex then
                    self.displayedEntryData[lastGroupHeadingIndex].numEntries = groupEntriesCount -- Count the number of entries in the previous group
                end
                groupEntriesCount = 0
                lastGroupHeadingIndex = j

                if self.gridView then
                    -- Get to the next row
                    while j % self.numEntriesAcross ~= 1 do
                        self.displayedEntryData[j] = {
                            ["isEmpty"] = true
                        }
                        j = j + 1
                    end
                end

                -- Add a blank row below new/recently unequippd items
                if (prevGroupOrder and type(prevGroupOrder) == "number" and prevGroupOrder < 0) and (type(groupOrder) ~= "number" or groupOrder >= 0) then
                    if self.gridView then
                        -- Get to the next row
                        while j % self.numEntriesAcross ~= 1 do
                            self.displayedEntryData[j] = {
                                ["isEmpty"] = true
                            }
                            j = j + 1
                        end
                    else
                        self.displayedEntryData[j] = {
                            ["isEmpty"] = true
                        }
                        j = j + 1
                    end
                end
                
                heading = groupName
                headingCollapsed = self:GetGroupHeadingCollapsed(groupName)
                if groupOrder ~= 0 then
                    self.displayedEntryData[j] = {
                        ["isGroupHeading"] = true,
                        ["group"] = groupName,
                        ["groupOrder"] = groupOrder
                    }
                    j = j + 1
                end
                
                if self.gridView then
                    -- Get to the next row
                    while j % self.numEntriesAcross ~= 1 do
                        self.displayedEntryData[j] = {
                            ["isEmpty"] = true
                        }
                        j = j + 1
                    end
                end

            else
                if not headingCollapsed then
                    self.displayedEntryData[j] = entryData
                    j = j + 1
                end
                groupEntriesCount = groupEntriesCount + 1
                i = i + 1
            end
        --[[else
            self.displayedEntryData[j] = entryData
            i = i + 1
            j = j + 1]]
        end
    end

    if lastGroupHeadingIndex then
        self.displayedEntryData[lastGroupHeadingIndex].numEntries = groupEntriesCount -- Count the number of entries in the last group
    end
end


local sortingArgs = {}
local function SortFunction(entry1, entry2)
    if not entry1.hasData then
        return false
    elseif not entry2.hasData then
        return true
    end
    if entry1.filtered and not entry2.filtered then
        return false
    elseif not entry1.filtered and entry2.filtered then
        return true
    end
    --[[if sortingArgs.pinNew then             -- new items are now assigned a group with order -100, so they can be sorted by that instead
        if entry1.isNew ~= entry2.isNew then
            return entry1.isNew == true
        end
    end]]
    if not entry1.filtered then
        if entry1.group ~= entry2.group then
            return entry1.group < entry2.group
        end
    end
    if sortingArgs.favoriting then
        if entry1.favorited ~= entry2.favorited then
            if not entry1.favorited then return false elseif not entry2.favorited then return true end
            return entry1.favorited < entry2.favorited
        end
    end
    -- Use column sorting
    local result = sortingArgs.sortMethod.func(sortingArgs.asc, entry1.data, entry2.data)
    if result == 0 and sortingArgs.historyStates then -- Still identical, go through the historical columns
        local i = 2
        while i <= #sortingArgs.historyStates and result == 0 do
            if sortingArgs.historyFuncs[i] then
                result = sortingArgs.historyFuncs[i].func(sortingArgs.historyStates[i].asc, entry1.data, entry2.data)
            end
            i = i + 1
        end
    end
    -- Legacy support for outdated plugins that return true/false instead of 1/0/-1
    if type(result) == "boolean" then
        return result
    end

    if result == 0 then -- Still identical, use default function
        return sortingArgs.defaultFunc(entry1.data, entry2.data)
    end
    return result < 0
end

-- Sorts table 't' using SortFunction
local function SortTable(self, t)
    -- Load up the sortingArgs table
    sortingArgs.defaultFunc = self.DefaultSortFunc
    --sortingArgs.grouping = self:GetGrouping()
    sortingArgs.favoriting = self:GetColumnSettings().favoritesOnTop
    sortingArgs.sortMethod, sortingArgs.asc = self:GetSortMethod()
    sortingArgs.pinNew = S.Settings.Get("newOnTop") == 1
    -- Add grouping and favoriting information
    for k,v in pairs(t) do
        _, v.group = self:GetEntryGroup(v)
        if sortingArgs.favoriting then
            v.favorited = self:GetEntryFavorited(v.data)
        end
        if S.IsPlayingCharacterSelected() then
            if sortingArgs.pinNew then
                v.isNew = self:GetEntryNew(v.data)
            end
        else
            v.new = false
        end
    end
    -- Add historical sort methods
    sortingArgs.historyStates = self:GetSortMethodHistory()
    sortingArgs.historyFuncs = {}
    if sortingArgs.historyStates then
        for i, v in ipairs(sortingArgs.historyStates) do
            if self.columns[v.key] then -- Check column still exists, in case it was provided by a plugin which has since been disabled
                sortingArgs.historyFuncs[i] = self.columns[v.key].sortMethods[v.sortMethod]
            else
                sortingArgs.historyFuncs[i] = nil
            end
        end
    end
    
    table.sort(t, SortFunction)
end

local function AddEntry(self, listEntry)
    table.insert(self.entryData, listEntry)
end

local function EntryExists(self, entryDataIndex)
    if self.entryData[entryDataIndex] and self:EntryHasData(self.entryData[entryDataIndex]) then
        return true
    end
    return false
end

--[[
-- Make sure to only run UpdateGroups after sorting!
local function UpdateGroups(self)
    self.groupHeadings = {}
    self.entriesWithGroupHeadings = {}
    local grouping = self:GetGrouping()
    local currentGroup = nil
    -- i iterates through the original entryData table
    -- j counts the number of entries in the new table, which includes group headings
    local i, j = 1, 1
    while i <= #self.entryData do
        local entry = self.entryData[i]
        local groupName, _ = self.groups[grouping].func(self:GetDataForEntry(entry))
        
        if not self:EntryHasData(entry) then
            i = i + 1
        elseif entry.filtered then
            self.entriesWithGroupHeadings[j] = entry
            j = j + 1
            i = i + 1
        elseif currentGroup ~= groupName then
            self.groupHeadings[#self.groupHeadings + 1] = groupName
            self.entriesWithGroupHeadings[j] = {
                ["isGroupHeading"] = true,
                ["group"] = groupName,
                ["groupHeadingIndex"] = j
            }
            j = j + 1
            currentGroup = groupName
        else
            entry.group = groupName
            if not self:GetGroupHeadingCollapsed(groupName) then
                self.entriesWithGroupHeadings[j] = entry
                j = j + 1
            end
            i = i + 1
        end
    end
end
local function UpdateGroupsGrid(self)
    self.groupHeadings = {}
    self.entriesWithGroupHeadings = {}
    local grouping = self:GetGrouping()
    local currentGroup = nil
    local foundFilteredItem = false
    -- i iterates through the original entryData table
    -- j counts the number of entries in the new table, which includes group headings
    local i, j = 1, 1
    while i <= #self.entryData do
        local entry = self.entryData[i]
        local groupName, _ = self.groups[grouping].func(self:GetDataForEntry(entry))
        
        if not self:EntryHasData(entry) then
            i = i + 1
        elseif entry.filtered then
            if not foundFilteredItem then
                foundFilteredItem = true
                while j % self.numEntriesAcross ~= 1 do
                    self.entriesWithGroupHeadings[j] = {
                        ["empty"] = true
                    }
                    j = j + 1
                end
            end
            self.entriesWithGroupHeadings[j] = entry
            j = j + 1
            i = i + 1
        elseif currentGroup ~= groupName then
            while j % self.numEntriesAcross ~= 1 do
                self.entriesWithGroupHeadings[j] = {
                    ["empty"] = true
                }
                j = j + 1
            end
            self.groupHeadings[#self.groupHeadings + 1] = groupName
            self.entriesWithGroupHeadings[j] = {
                ["isGroupHeading"] = true,
                ["group"] = groupName,
                ["groupHeadingIndex"] = math.floor(j / self.numEntriesAcross) + 1
            }
            j = j + 1
            while j % self.numEntriesAcross ~= 1 do
                self.entriesWithGroupHeadings[j] = {
                    ["empty"] = true
                }
                j = j + 1
            end
            currentGroup = groupName
        else
            entry.group = groupName
            if not self:GetGroupHeadingCollapsed(groupName) then
                self.entriesWithGroupHeadings[j] = entry
                j = j + 1
            end
            i = i + 1
        end
    end
end
local function UpdateEntryButtonsWithGrouping(self)

    UpdateGroups(self)

    local isAvailable = self:IsAvailable()
    local topEntryIndex = floor(self.scrollPos)
    local i = 1
    while i <= self:GetNumVisibleEntries() do
        local entryButton = self.entryButtons[i]
        local headingButton = self.headingButtons[i]
        if not self.entriesWithGroupHeadings[topEntryIndex + i] then
            entryButton:Hide()
            headingButton:Hide()
        else
            local entryData = self.entriesWithGroupHeadings[topEntryIndex + i]
            if entryData.empty then
                entryButton:Hide()
                headingButton:Hide()
            elseif entryData.isGroupHeading then
                headingButton.group = entryData.group
                headingButton.nameString:SetText(entryData.group)
                headingButton:Show()
                headingButton:SetCollapsed(self:GetGroupHeadingCollapsed(entryData.group))
                entryButton:Hide()
            elseif entryData and self:EntryHasData(entryData) then
                -- Add keys from the entryData table to the entry object before updating it
                for k,w in pairs(entryData) do
                    entryButton[k] = w
                end
                entryButton:Show()
                entryButton:Update()
                if isAvailable then
                    --entryButton:SetAlpha(1)
                    entryButton:Enable()
                else
                    --entryButton:SetAlpha(0.8)
                    entryButton:Disable()
                end
                headingButton:Hide()
            else
                entryButton:Hide()
                headingButton:Hide()
            end
        end
        i = i + 1
    end
end
local function UpdateEntryButtonsWithGroupingGrid(self)
    UpdateGroupsGrid(self)
    local isAvailable = self:IsAvailable()
    local topEntryIndex = floor(self.scrollPos) * self.numEntriesAcross
    for k,v in pairs(self.headingButtons) do
        v:Hide()
    end
    local i = 1
    while i <= self:GetNumVisibleEntries() do
        local entryButton = self.entryButtons[i]
        if not self.entriesWithGroupHeadings[topEntryIndex + i] then
            entryButton:Hide()
        else
            local entryData = self.entriesWithGroupHeadings[topEntryIndex + i]
            if entryData.empty then
                entryButton:Hide()
            elseif entryData.isGroupHeading then
                local headingButton = self.headingButtons[entryData.groupHeadingIndex - floor(self.scrollPos)]
                if headingButton then
                    headingButton.group = entryData.group
                    headingButton.nameString:SetText(entryData.group)
                    headingButton:Show()
                    headingButton:SetCollapsed(self:GetGroupHeadingCollapsed(entryData.group))
                end
                entryButton:Hide()
            elseif entryData and self:EntryHasData(entryData) then
                -- Add keys from the entryData table to the entry object before updating it
                for k,w in pairs(entryData) do
                    entryButton[k] = w
                end
                entryButton:Show()
                entryButton:Update()
                if isAvailable then
                    --entryButton:SetAlpha(1)
                    entryButton:Enable()
                else
                    --entryButton:SetAlpha(0.8)
                    entryButton:Disable()
                end
            else
                entryButton:Hide()
            end
        end
        i = i + 1
    end
end
local function UpdateEntryButtons(self)
    if self:GetGrouping() then
        if self.gridView then
            UpdateEntryButtonsWithGroupingGrid(self)
        else
            UpdateEntryButtonsWithGrouping(self)
        end
        return
    end
    local isAvailable = self:IsAvailable()
    local entryIndex
    if self.gridView then
        entryIndex = floor(self.scrollPos) * self.numEntriesAcross + 1
    else
        entryIndex = floor(self.scrollPos) + 1
    end
    for i = 1, self:GetNumVisibleEntries() do
        self.headingButtons[i]:Hide()
        local entry = self.entryButtons[i]
        local entryData = self.entryData[entryIndex]
        if entryData and self:EntryHasData(entryData) then
            -- Add keys from the entryData table to the button before updating it
            for k,w in pairs(entryData) do
                entry[k] = w
            end
            entry:Show()
            entry:Update()
            if isAvailable then
                --v:SetAlpha(1)
                entry:Enable()
            else
                --v:SetAlpha(0.8)
                entry:Disable()
            end
            entryIndex = entryIndex + 1
        else
            entry:Hide()
            entryIndex = entryIndex + 1
        end
    end
end]]

local function UpdateEntryButtonIcons(self)
    local iconSize, borderThickness, iconShape, iconBorders
    if self.gridView then
        iconSize = S.Settings.Get("iconSizeGrid")
        borderThickness = S.Settings.Get("iconBorderThicknessGrid")
        iconShape = S.Settings.Get("iconShapeGrid")
        iconBorders = S.Settings.Get("iconBordersGrid")
    else
        iconSize = S.Settings.Get("iconSize")
        borderThickness = S.Settings.Get("iconBorderThickness")
        iconShape = S.Settings.Get("iconShape")
        iconBorders = S.Settings.Get("iconBorders")
    end
    for _, v in pairs(self.entryButtons) do
        v:UpdateIcons(iconSize, borderThickness, iconShape, iconBorders)
    end
end

local function UpdateEntryButtons(self)
    local isAvailable = self:IsAvailable()
    local eb, ed, hb -- entryButton, entryData, headingButton
    -- Iterate over the tables
    local bi = 1 -- index in entryButtons
    local di -- index in displayedEntryData
    if self.gridView then
        di = floor(self.scrollPos) * self.numEntriesAcross + 1
    else
        di = floor(self.scrollPos) + 1
    end

    for _, hb in pairs(self.headingButtons) do
        hb:Hide()
    end
    for _, eb in pairs(self.entryButtons) do
        eb:Hide()
    end

    while bi <= self:GetNumVisibleEntries() do

        eb = self.entryButtons[bi]
        if self.gridView then
            hb = self.headingButtons[floor(bi / self.numEntriesAcross) + 1]
        else
            hb = self.headingButtons[bi]
        end

        if di > #self.displayedEntryData then

        else
            ed = self.displayedEntryData[di]

            if ed then
                if ed.isEmpty then

                elseif ed.isGroupHeading then
                    if ed.group then
                        -- Display the group heading
                        hb.group = ed.group
                        hb.isForFilteredItems = false

                        if ed.numEntries then
                            hb.nameString:SetText(ed.group.. " |cff555555(|cffbbbbbb"..ed.numEntries.."|cff555555)")
                        else
                            hb.nameString:SetText(ed.group.. " |cff555555(|cffbbbbbb0|cff555555)")
                        end

                        if type(ed.groupOrder) == "number" and ed.groupOrder <= 0 then
                            hb:SetCollapsed(false)
                            hb:SetCollapsible(false)
                        else
                            hb:SetCollapsed(self:GetGroupHeadingCollapsed(ed.group))
                            hb:SetCollapsible(true)
                        end
                        hb.button:GetNormalTexture():SetVertexColor(1, 1, 1)
                        hb.button:GetNormalTexture():SetDesaturated(false)
                        hb.button:GetHighlightTexture():SetDesaturated(false)
                        hb.button:GetPushedTexture():SetDesaturated(false)
                        hb:Show()
                    end

                elseif ed.isFilteredHeading then
                    -- Display the filtered heading
                    hb.nameString:SetText("|cff666666"..S.Localize("FILTERED_ITEMS").." |cff444444(|cff666666"..numFilteredItems.."|cff444444)")
                    hb.isForFilteredItems = true
                    hb:SetCollapsed(S.Settings.Get("filteredCollapsed"))
                    hb.button:GetNormalTexture():SetDesaturated(true)
                    hb.button:GetNormalTexture():SetVertexColor(0.6, 0.6, 0.6)
                    hb.button:GetHighlightTexture():SetDesaturated(true)
                    hb.button:GetPushedTexture():SetDesaturated(true)
                    hb:Show()
                    
                else
                    --hb:Hide()
                    -- Add keys from the entry data table to the button before updating it
                    -- ed.data points to a data table in Sorted_Data. DON'T use this. 
                    -- Instead, point back to the entry button's data table and populate it
                    -- This table will be getting extra data that shouldn't be saved between sessions
                    local ebData = eb.data
                    for k,v in pairs(ed) do
                        eb[k] = v
                    end
                    --eb.data = ebData
                    eb.data = {}
                    for k,v in pairs(ed.data) do
                        eb.data[k] = v
                    end
                    eb:Show()
                    eb:Update()
                    --eb.button:SetEnabled(isAvailable)
                end
            end
        end

        bi = bi + 1
        di = di + 1
    end
end

local function CreateGroupHeading(list)
    local self = CreateFrame("FRAME", nil, list.listFrame)
    self:ClearAllPoints()
    self.list = list
    self:SetPoint("LEFT")
    self:SetPoint("RIGHT")
    self:SetHeight(20)
    self.nameString = self:CreateFontString(nil, "OVERLAY", "SortedFont")
    self.nameString:SetTextScale(1.1)
    self.nameString:SetPoint("LEFT", 28, 0)
    self.nameString:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
    self.button = CreateFrame("BUTTON", nil, self)
    self.button.parent = self
    self.button:SetAllPoints()
    self.button:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Expand-Button")
    self.button:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Close-Button-Highlight")
    self.button:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Expand-Button")
    self.button:GetNormalTexture():ClearAllPoints()
    self.button:GetNormalTexture():SetPoint("LEFT", 2, 0)
    self.button:GetNormalTexture():SetSize(22, 22)
    self.button:GetHighlightTexture():ClearAllPoints()
    self.button:GetHighlightTexture():SetPoint("LEFT", 2, 0)
    self.button:GetHighlightTexture():SetSize(22, 22)
    self.button:GetPushedTexture():ClearAllPoints()
    self.button:GetPushedTexture():SetPoint("LEFT", 2, 0)
    self.button:GetPushedTexture():SetSize(22, 22)
    function self:SetCollapsed(collapsed)
        self.collapsed = collapsed
        if collapsed then
            self.button:GetNormalTexture():SetTexCoord(0, 0.375, 0, 0.375)
            self.button:GetPushedTexture():SetTexCoord(0.375, 0.75, 0, 0.375)
        else
            self.button:GetNormalTexture():SetTexCoord(0, 0.375, 0.375, 0.75)
            self.button:GetPushedTexture():SetTexCoord(0.375, 0.75, 0.375, 0.75)
        end
    end
    function self:SetCollapsible(collapsible)
        self.button:SetEnabled(collapsible)
        if collapsible then
            --self.button:GetNormalTexture():SetDesaturated(false)
            self.button:SetAlpha(1)
        else
            --self.button:GetNormalTexture():SetDesaturated(true)
            self.button:SetAlpha(0.3)
        end
    end
    self.button:SetScript("OnClick", function(self)
        if self.parent.isForFilteredItems then
            S.Settings.Set("filteredCollapsed", not S.Settings.Get("filteredCollapsed"))
            S.Utils.TriggerEvent("GroupingChanged")
        else
            self.parent.list:ToggleGroupHeading(self.parent.group)
        end
    end)
    self:SetCollapsed(false)
    return self
end

local function GetNumVisibleEntries(self)
    return self.numVisibleEntries
end
local function OnResize(self)
    local entryHeight = S.Settings.Get("iconSize") + S.Settings.Get("padding") * 2
    local y = 0

    -- Create entries to fill frame
    local i = 0
    while y < self.listFrame:GetHeight() + entryHeight do
        i = i + 1
        if not self.entryButtons[i] then
            self.entryButtons[i] = self.CreateEntry(self, self.listFrame)
            self.headingButtons[i] = CreateGroupHeading(self)
        end
        self.entryButtons[i]:SetParent(self.entryButtons[i].parentFrame)
        if not self.entryButtons[i]:IsShown() then
            self.entryButtons[i]:Show()
        end
        y = y + entryHeight
    end
    self.numVisibleEntries = i
    -- Hide entries below bottom of frame
    i = i + 1
    while i <= #self.entryButtons do
        self.entryButtons[i]:Hide()
        self.entryButtons[i]:ClearAllPoints()
        self.entryButtons[i]:SetParent(nil)
        self.headingButtons[i]:Hide()
        i = i + 1
    end
    self:PositionEntryButtons()
    self:UpdateEntryButtonIcons()
    self:UpdateEntryButtons()
end
local function OnResizeGrid(self)
    local size = S.Settings.Get("iconSizeGrid") + S.Settings.Get("paddingGrid") * 2
    local x,y = 0,0
    local listWidth = self:GetWidth() - self.scrollBar:GetWidth()
    self.numEntriesAcross = math.floor(listWidth / size)

    -- Create entries to fill frame
    local i = 1
    while y < self.listFrame:GetHeight() + size do
        if not self.entryButtons[i] then
            self.entryButtons[i] = self.CreateEntry(self, self.listFrame)
            self.headingButtons[i] = CreateGroupHeading(self)
        end
        self.entryButtons[i]:SetParent(self.entryButtons[i].parentFrame)
        if not self.entryButtons[i]:IsShown() then
            self.entryButtons[i]:Show()
        end
        x = x + size
        if x > listWidth - size then
            x = 0
            y = y + size
        end
        i = i + 1
    end
    self.numVisibleEntries = i - 1
    -- Hide entries below bottom of frame
    while i <= #self.entryButtons do
        self.entryButtons[i]:Hide()
        self.entryButtons[i]:ClearAllPoints()
        self.entryButtons[i]:SetParent(nil)
        self.headingButtons[i]:Hide()
        i = i + 1
    end
    self:PositionEntryButtons()
    self:UpdateEntryButtonIcons()
end

local function ScrollToTop(self)
    if S.Settings.Get("smoothingAmount") == 0 then
        self.scrollPos = 0
        self:UpdateEntryButtons()
        self:PositionEntryButtons()
    else
        self.scrollBar.doSmoothing = true
        self.scrollBar.smoothOppositeCurve = false
        self.scrollBar.smoothStart = self.scrollPos
        self.scrollBar.smoothTime = GetTime() - GetTickTime()
        self.scrollBar.smoothTarget = 0
    end
end
local function UpdateScrollBarMax(self)
    local entryHeight
    if self.gridView then
        entryHeight = S.Settings.Get("iconSizeGrid") + S.Settings.Get("paddingGrid") * 2
    else
        entryHeight = S.Settings.Get("iconSize") + S.Settings.Get("padding") * 2
    end
    local numEntries = #self.displayedEntryData
    local max
    if self.gridView then
        max = (math.floor(numEntries / self.numEntriesAcross) + 2) - self.listFrame:GetHeight() / entryHeight
    else
        max = numEntries - self.listFrame:GetHeight() / entryHeight
    end
    if max > 0 then
        self.scrollBar:SetMinMaxValues(0, max)
        self.scrollBar.ThumbTexture:Show()
        self.scrollBar.ScrollUpButton:Enable()
        self.scrollBar.ScrollDownButton:Enable()
    else
        max = 0
        self.scrollBar:SetMinMaxValues(0, 0)
        self.scrollBar.ThumbTexture:Hide()
        self.scrollBar.ScrollUpButton:Disable()
        self.scrollBar.ScrollDownButton:Disable()
    end
    if self.scrollPos > max then
        if S.Settings.Get("smoothingAmount") == 0 then
            self.scrollPos = max
            self:UpdateEntryButtons()
            self:PositionEntryButtons()
        elseif not self.scrollBar.doSmoothing or self.scrollBar.smoothTarget > max then
            self.scrollBar.doSmoothing = true
            self.scrollBar.smoothOppositeCurve = true
            self.scrollBar.smoothStart = self.scrollPos
            self.scrollBar.smoothTime = GetTime() - GetTickTime()
            self.scrollBar.smoothTarget = max
        end
    end
end

local entryButtonHeightCached
local function PositionEntryButtons(self)
    local entryHeight = S.Settings.Get("iconSize") + S.Settings.Get("padding") * 2
    entryButtonHeightCached = entryHeight
    local y = -(self.scrollPos - floor(self.scrollPos)) * entryHeight

    for i = 1, self:GetNumVisibleEntries() do
        self.entryButtons[i]:SetHeight(entryHeight)
        self.entryButtons[i]:SetPoint("LEFT")
        self.entryButtons[i]:SetPoint("RIGHT")
        self.entryButtons[i]:SetPoint("TOP", self.listFrame, "TOP", 0, -y)
        self.headingButtons[i]:SetHeight(entryHeight)
        self.headingButtons[i]:SetPoint("LEFT")
        self.headingButtons[i]:SetPoint("RIGHT")
        self.headingButtons[i]:SetPoint("TOP", self.listFrame, "TOP", 0, -y)
        y = y + entryHeight
    end
end
-- Doesn't change the size of the buttons, just quickly repositions them. For use with smooth scrolling
local function PositionEntryButtonsFast(self)
    local y = -(self.scrollPos - floor(self.scrollPos)) * entryButtonHeightCached

    for i = 1, self:GetNumVisibleEntries() do
        self.entryButtons[i]:SetPoint("TOP", self.listFrame, "TOP", 0, -y)
        self.headingButtons[i]:SetPoint("TOP", self.listFrame, "TOP", 0, -y)
        y = y + entryButtonHeightCached
    end
end
local function PositionEntryButtonsGrid(self)
    local size = S.Settings.Get("iconSizeGrid") + S.Settings.Get("paddingGrid") * 2
    local x, y = 0, 0
    local scrollOffset = (self.scrollPos - floor(self.scrollPos)) * size
    local listWidth = self:GetWidth() - self.scrollBar:GetWidth()
    for i = 1, #self.headingButtons do
        self.headingButtons[i]:SetHeight(size)
        self.headingButtons[i]:SetPoint("LEFT")
        self.headingButtons[i]:SetPoint("RIGHT")
        self.headingButtons[i]:SetPoint("TOP", self.listFrame, "TOP", 0, -i * size + size + scrollOffset)
    end
    for i = 1, self:GetNumVisibleEntries() do
        self.entryButtons[i]:ClearAllPoints()
        self.entryButtons[i]:SetSize(size, size)
        self.entryButtons[i]:SetPoint("TOPLEFT", x, -y + scrollOffset)
        x = x + size
        if x > listWidth - size then
            x = 0
            y = y + size
        end
    end
end

local function GetGroupingSettings(self)
    return S.Settings.Get(self.groupingSettings)
end
local function SelectGrouping(self, key)
    local settings = GetGroupingSettings(self)
    settings.selectedGrouping = key
    --settings.collapsedGroups = {} -- Collapsed groups used to be tied to settings, now they're tied to the list object and aren't saved between sessions
    self.collapsedGroups = {}

    S.Utils.TriggerEvent("GroupingChanged")
end
local function DeselectGrouping(self)
    GetGroupingSettings(self).selectedGrouping = nil
    S.Utils.TriggerEvent("GroupingChanged")
end
local function GetGrouping(self)
    return GetGroupingSettings(self).selectedGrouping
end
local function GetEntryGroup(self, entryData)
    if S.Settings.Get("newOnTop") == 1 and self:GetEntryNew(entryData) then
        return "|cff99ff00"..NEW, -100
    end
    local grouping = self:GetGrouping()
    if grouping then
        return self.groups[self:GetGrouping()].func(entryData.data)
    else
        return OTHER, 0
    end
end
local function ToggleGroupHeading(self, group)
    --local settings = GetGroupingSettings(self)
    if self.collapsedGroups[group] then
        self.collapsedGroups[group] = nil
    else
        self.collapsedGroups[group] = true
    end
    S.Utils.TriggerEvent("GroupingChanged")
end
local function GetGroupHeadingCollapsed(self, group)
    return self.collapsedGroups[group]
end

-- Returns the width of a column, either using the column's own function, 
-- or the width set by the user
local function GetColumnWidth(self, key)
    if self.columns[key].GetWidth then
        return self.columns[key]:GetWidth()
    end

    local settings = self:GetColumnSettings()
    if settings.widths and settings.widths[key] then
        return settings.widths[key]
    end
    return self.columns[key].width
end

local function UpdateColumnsSortArrows(self)
    local cs = self:GetColumnSettings()
    for k,v in pairs(self.columnHeadings) do
        local col = self.columns[k]
        if k == cs.selectedColumn then
            local sortMethod = col.sortMethods[cs.sortMethod]
            if sortMethod.inverse then
                v.nameString:SetText(sortMethod.title..GetSortArrow(not cs.sortAsc))
            else
                v.nameString:SetText(sortMethod.title..GetSortArrow(cs.sortAsc))
            end
        else
            if col.sortMethods then
                if cs.lastSortMethod and cs.lastSortMethod[v.key] then
                    v.nameString:SetText(col.sortMethods[cs.lastSortMethod[v.key]].title)
                else
                    v.nameString:SetText(col.sortMethods[1].title)
                end
            end
        end
    end
end


local function PositionColumns(self)
    local nameColumnIndex = 0
    local nameColumnButton = nil
    local doCombineStacks = self.canCombineStacks and S.Settings.Get("combineStacks") == 1
    -- Find the middle 'name' column which expands to fill the remaining space
    for i,v in ipairs(self:GetColumnOrder()) do
        local key = self:GetColumnOrder()[i]
        if key == "NAME" then
            nameColumnIndex = i
            nameColumnButton = self.columnHeadings[v]
            nameColumnButton:SetPoint("TOP")
            nameColumnButton:SetPoint("BOTTOM")
        end
    end
    local lastEnabledColumnButton = nil
    for i = 1, nameColumnIndex - 1, 1 do
        local key = self:GetColumnOrder()[i]
        if self:ColumnEnabled(key) then
            local button = self.columnHeadings[key]
            local column = self.columns[key]
            button:ClearAllPoints()
            button:SetPoint("TOP", self.head)
            button:SetPoint("BOTTOM", self.head)

            -- Resize handle goes on the right
            if button.resizeButton then
                button.resizeButton:SetPoint("LEFT", button, "RIGHT", -3, 0)
                button.resizeButton.invert = false
            end

            if lastEnabledColumnButton then
                button:SetPoint("LEFT", lastEnabledColumnButton, "RIGHT")
            else
                if doCombineStacks then
                    button:SetPoint("LEFT", self.head, 20, 0)
                else
                    button:SetPoint("LEFT", self.head)
                end
            end
            button:SetWidth(self:GetColumnWidth(key))
            lastEnabledColumnButton = button
        end
    end
    if lastEnabledColumnButton then
        nameColumnButton:SetPoint("LEFT", lastEnabledColumnButton, "RIGHT")
    else
        nameColumnButton:SetPoint("LEFT")
    end
    lastEnabledColumnButton = nil
    for i = #self:GetColumnOrder(), nameColumnIndex + 1, -1 do
        local key = self:GetColumnOrder()[i]
        if self:ColumnEnabled(key) then
            local button = self.columnHeadings[key]
            local column = self.columns[key]
            button:ClearAllPoints()
            button:SetPoint("TOP", self.head)
            button:SetPoint("BOTTOM", self.head)

            -- Resize handle goes on the left
            if button.resizeButton then
                button.resizeButton:SetPoint("LEFT", -3, 0)
                button.resizeButton.invert = true
            end

            if lastEnabledColumnButton then
                button:SetPoint("RIGHT", lastEnabledColumnButton, "LEFT")
            else
                button:SetPoint("RIGHT", self.head)
            end
            button:SetWidth(self:GetColumnWidth(key))
            lastEnabledColumnButton = button
        end
    end
    if lastEnabledColumnButton then
        nameColumnButton:SetPoint("RIGHT", lastEnabledColumnButton, "LEFT")
    else
        nameColumnButton:SetPoint("RIGHT")
    end
end
local function UpdateColumns(self)
    for k,v in pairs(self.columns) do
        if not self.gridView then
            for i = 1, self:GetNumVisibleEntries() do
                local entry = self.entryButtons[i]
                if entry.columnElements[k] then
                    entry.columnElements[k]:SetShown(self:ColumnEnabled(k))
                end
            end
        end
        self.columnHeadings[k]:SetShown(self:ColumnEnabled(k))
    end
    if self:GetColumnSettings().favoritesOnTop then
        self.columnHeadings["FAVORITES"].favoriteIcon:SetTexCoord(0, 0.21875, 0, 0.21875)
    else
        self.columnHeadings["FAVORITES"].favoriteIcon:SetTexCoord(0, 0.21875, 0.21875 * 2, 0.21875 * 3)
    end
    self:PositionColumns()
end


local function EnableColumn(self, columnKey)
    self:GetColumnSettings().enabledColumns[columnKey] = true
    -- Add column to the columnOrder only if it isn't there already
    for i, v in ipairs(self:GetColumnOrder()) do
        if v == columnKey then
            S.Utils.TriggerEvent("MinSizeChanged")
            S.Utils.TriggerEvent("ColumnsChanged")
            return
        end
    end
    table.insert(self:GetColumnOrder(), columnKey)
    S.Utils.TriggerEvent("MinSizeChanged")
    S.Utils.TriggerEvent("ColumnsChanged")
end
local function DisableColumn(self, columnKey)
    self:GetColumnSettings().enabledColumns[columnKey] = false
    S.Utils.TriggerEvent("MinSizeChanged")
    S.Utils.TriggerEvent("ColumnsChanged")
end
local function ColumnEnabled(self, columnKey)
    return self.columns[columnKey] and self:GetColumnSettings().enabledColumns[columnKey]
end
local function OnDropdownColumnEntryClick(self)
    S.Settings.Set("columnSettingsHaveChanged", true)
    if self.checked then
        EnableColumn(self.data1, self.data2)
    else
        DisableColumn(self.data1, self.data2)
    end
end
local function OnDropdownGroupingEntryClick(self)
    S.Settings.Set("columnSettingsHaveChanged", true)
    if self.checked then
        SelectGrouping(self.data1, self.data2)
    else
        DeselectGrouping(self.data1, self.data2)
    end
end
local function ColumnOnClick(self, button, down)
    -- Don't trigger a click if the column has been dragged around
    if not self.list.movedColumn then

        if button == "LeftButton" then
            ToggleSortMethod(self.list, self.key)

        elseif button == "RightButton" then
            -- Dropdown menu
            if S.Dropdown.IsShown() then
                S.Dropdown.Hide()
            else
                S.Dropdown.Reset()

                S.Dropdown.AddEntry(S.Localize("CONFIG_GROUPING"), nil, nil, nil, S.Utils.GetButtonTextColor())
                S.Dropdown.SetHeading()
                local dropdownEntries = {}
                for k,v in pairs(self.list.groups) do
                    table.insert(dropdownEntries, {
                        ["key"] = k,
                        ["name"] = v.name
                    })
                end
                table.sort(dropdownEntries, function(a,b) return a.name < b.name end)
                for i,v in ipairs(dropdownEntries) do
                    S.Dropdown.AddEntry(v.name, OnDropdownGroupingEntryClick, self.list, v.key)
                    S.Dropdown.AddRadioButton(self.list:GetGrouping() == v.key)
                end

                S.Dropdown.AddEntry(S.Localize("CONFIG_COLUMNS"), nil, nil, nil, S.Utils.GetButtonTextColor())
                S.Dropdown.SetHeading()
                dropdownEntries = {}
                for k,v in pairs(self.list.columns) do
                    if k ~= "NAME" then -- Don't allow the name column to be disabled
                        local name = v.name
                        if v.sortMethods then
                            if v.sortMethods[1].title ~= name and #v.sortMethods[1].title > 0 then
                                name = name.." ("..v.sortMethods[1].title..")"
                            end
                        end
                        table.insert(dropdownEntries, {
                            ["key"] = k,
                            ["name"] = name
                        })
                    end
                end
                table.sort(dropdownEntries, function(a,b) return a.name < b.name end)
                for i,v in ipairs(dropdownEntries) do
                    S.Dropdown.AddEntry(v.name, OnDropdownColumnEntryClick, self.list, v.key)
                    S.Dropdown.AddCheckbox(self.list:ColumnEnabled(v.key))
                end

                local x,y = GetCursorPosition()
                x,y = x / S.dropdownMenu:GetEffectiveScale(), y / S.dropdownMenu:GetEffectiveScale()
                S.Dropdown.Show(UIParent, "TOPLEFT", "BOTTOMLEFT", x, y)
            end
        end
    end
end

local function GetColumnSettings(self)
    return S.Settings.Get(self.columnSettingsKey)
end
local function GetColumnOrder(self)
    return GetColumnSettings(self).order
end

local function GetEntryFavorited(self, entryData)
    return false
end

local function GetEntryNew(self, entryData)
    return false
end

local function GetMinWidth(self)
    local width = 100 -- Effectively the minimum width of the name column
    for key, col in pairs(self.columns) do
        if self:ColumnEnabled(key) then
            local colWidth = self:GetColumnWidth(key)
            if colWidth then
                width = width + colWidth
            end
        end
    end
    if width > self.minWidth then
        return width
    else
        return self.minWidth
    end
end

local function SetMinimised(self, minimised)
    
end

local function IsAvailable(self)
    return S.IsPlayingCharacterSelected()
end

local function ToggleGridView(self)
    self.gridView = not self.gridView
    if self.gridView then
        self.OnResize = OnResizeGrid
        self:OnResize()
        self.PositionEntryButtons = PositionEntryButtonsGrid
        self.PositionEntryButtonsFast = PositionEntryButtonsGrid
        for k,v in pairs(self.entryButtons) do
            v:DetachFramesFromColumns()
            v.columnElements["ICON"]:SetAllPoints()
            v.columnElements["ICON"]:Show()
            v.columnElements["QUANTITY"]:SetParent(v.columnElements["ICON"])
            v.columnElements["QUANTITY"]:SetPoint("BOTTOMRIGHT")
            v.columnElements["QUANTITY"]:SetPoint("TOPLEFT", v, "RIGHT")
            v.columnElements["QUANTITY"]:Show()
            v.button:SetPushedTexture("")
        end
    else
        self.OnResize = OnResize
        self:OnResize()
        self.PositionEntryButtons = PositionEntryButtons
        self.PositionEntryButtonsFast = PositionEntryButtonsFast
        for k,v in pairs(self.entryButtons) do
            v:ClearAllPoints()
            v:SetPoint("LEFT")
            v:SetPoint("RIGHT")
            v.columnElements["QUANTITY"]:SetParent(v)
            v.columnElements["ICON"]:ClearAllPoints()
            v.columnElements["QUANTITY"]:ClearAllPoints()
            v:AttachFramesToColumns()
            v.button:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\UI-Highlight")
            if k > self:GetNumVisibleEntries() then
                v:Hide()
            end
        end
    end
    self:PositionEntryButtons()
    self:UpdateEntryButtonIcons()
    self:ScheduleUpdate(true, true)
    S.Utils.TriggerEvent("LayoutChanged")
end

local function CreateColumnButton(self, key)
    local b = CreateFrame("BUTTON", "", self.head)
    b.normalTex = b:CreateTexture(nil, "BACKGROUND")
    b.normalTex:SetTexture("Interface\\Addons\\Sorted\\Textures\\Column-Heading")
    b.normalTex:SetTexCoord(0.2, 0.8, 0, 1)
    b.normalTex:SetPoint("TOPLEFT", 4, 0)
    b.normalTex:SetPoint("BOTTOMRIGHT", -4, 0)
    b.normalTexL = b:CreateTexture(nil, "BACKGROUND")
    b.normalTexL:SetTexture("Interface\\Addons\\Sorted\\Textures\\Column-Heading")
    b.normalTexL:SetTexCoord(0, 0.2, 0, 1)
    b.normalTexL:SetPoint("TOPLEFT")
    b.normalTexL:SetPoint("BOTTOMRIGHT", b, "BOTTOMLEFT", 4, 0)
    b.normalTexR = b:CreateTexture(nil, "BACKGROUND")
    b.normalTexR:SetTexture("Interface\\Addons\\Sorted\\Textures\\Column-Heading")
    b.normalTexR:SetTexCoord(0.8, 1, 0, 1)
    b.normalTexR:SetPoint("TOPLEFT", b, "TOPRIGHT", -4, 0)
    b.normalTexR:SetPoint("BOTTOMRIGHT")
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Column-Heading-Highlight")
    b:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Column-Heading-Highlight")
    b.nameString = b:CreateFontString(nil, "OVERLAY", "SortedFont")
    b.nameString:SetPoint("CENTER")
    b.nameString:SetHeight(1)

    if self.columns[key].width then
        b.resizeButton = CreateFrame("BUTTON", "", b)
        b.resizeButton:SetPoint("TOP")
        b.resizeButton:SetPoint("BOTTOM")
        b.resizeButton:SetWidth(6)
        b.resizeButton:SetFrameLevel(b:GetFrameLevel() + 10)
        b.resizeButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Close-Button-Highlight")
        b.resizeButton:GetHighlightTexture():SetTexCoord(0, 1, 0.3, 0.7)
        b.resizeButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Close-Button-Highlight")
        b.resizeButton:GetPushedTexture():SetBlendMode("ADD")
        b.resizeButton:GetPushedTexture():SetTexCoord(0, 1, 0.3, 0.7)
        b.resizeButton.key = key
        b.resizeButton.list = self
        b.resizeButton:SetScript("OnMouseDown", function(self)
            local settings = self.list:GetColumnSettings()
            if not settings.widths then
                settings.widths = {}
            end
            if not settings.widths[self.key] then
                settings.widths[self.key] = self.list.columns[self.key].width
            end
            self.x, self.y = GetCursorPosition()
            self.x = self.x / self:GetEffectiveScale()
            self.y = self.y / self:GetEffectiveScale()
            self.startWidth = settings.widths[self.key]

            self:SetScript("OnUpdate", function(self)
                local x, y = GetCursorPosition()
                x = x / self:GetEffectiveScale()
                y = y / self:GetEffectiveScale()
                if self.invert then
                    settings.widths[self.key] = self.startWidth - (x - self.x)
                else
                    settings.widths[self.key] = self.startWidth + (x - self.x)
                end
                if settings.widths[self.key] < 16 then
                    settings.widths[self.key] = 16
                end
                self.list:PositionColumns()
            end)
        end)
        b.resizeButton:SetScript("OnMouseUp", function(self)
            self:SetScript("OnUpdate", nil)
            S.primaryFrame:UpdateMinSize()
            S.primaryFrame.sideFrame:UpdateMinSize()
            S.Utils.TriggerEvent("ColumnResized")
        end)

        if key == "FAVORITES" then
            b.favoriteIcon = b:CreateTexture(nil, "OVERLAY")
            b.favoriteIcon:SetTexture("Interface\\Addons\\Sorted\\Textures\\Favorite-Icons")
            b.favoriteIcon:SetPoint("CENTER")
            b.favoriteIcon:SetSize(20, 20)
        end
    end

    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    --b:RegisterForDrag("LeftButton")

    -- Column dragging
    b:SetScript("OnClick", ColumnOnClick)
    b:SetScript("OnMouseDown", function(self)
        self.list.dragging = self.key
        self.list.movedColumn = false
    end)
    b:SetScript("OnMouseUp", function(self)
        self.list.dragging = nil
    end)
    b:SetScript("OnEnter", function(self)
        if self.list.dragging then
            self.list.movedColumn = true
            for i,v in ipairs(self.list:GetColumnOrder()) do
                if v == self.key then
                    self.list:GetColumnOrder()[i] = self.list.dragging
                elseif v == self.list.dragging then
                    self.list:GetColumnOrder()[i] = self.key
                end
            end
            self.list:UpdateColumns()
        else
            -- "Pin favorites" tooltip
            if self.key == "FAVORITES" then
                S.Tooltip.CreateLocalized(self, "ANCHOR_TOPLEFT", "CONFIG_BEHAVIOR_ON_OPEN_PIN_FAVORITES")
            else
                -- "Sort by" tooltip. Don't show after player knows how to change column settings
                if not S.Settings.Get("columnSettingsHaveChanged") then
                    S.Tooltip.Schedule(function()
                        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                        GameTooltip:ClearLines()
                        GameTooltip:AddLine(S.Localize("TOOLTIP_SORT_BY", self.list.columns[self.key].name))
                        if BANK_TAB_TOOLTIP_CLICK_INSTRUCTION then
                            GameTooltip:AddLine(BANK_TAB_TOOLTIP_CLICK_INSTRUCTION, 0, 1, 0)
                        else
                            GameTooltip:AddLine(S.Localize("TOOLTIP_CLICK_INSTRUCTION_SETTINGS"), 0, 1, 0)
                        end
                        GameTooltip:Show()
                    end)
                end
            end
        end
    end)
    b:SetScript("OnLeave", S.Tooltip.Cancel)

    self.columnHeadings[key] = b

    b.key = key
    b.list = self
    return b
end

local lastUpdateTime = 0
local function ScheduleUpdate(self, resize, sort)
    if resize then
        -- Resize is no longer scheduled with other updates. Instead it's done the same way as Sorted tooltips
        -- This is due to ScheduledUpdates only happening when the list is shown.
        -- By performing the resize when the list is hidden, it doesn't need to run OnShow, causing noticeable lag when opening bags

        --self.resizeScheduled = true
        if not self.lastResizeID then
            self.lastResizeID = 0
        else
            self.lastResizeID = self.lastResizeID + 1
        end
        local thisID = self.lastResizeID
        C_Timer.After(0.01, function()
            if self.lastResizeID == thisID then
                self:OnResize()
                self:ScheduleUpdate(false, false)
            end
        end)
    end
    if sort then
        self.sortingScheduled = true
    end
    self.updateScheduled = true
end
local function OnUpdate(self)
    if self.updateScheduled and GetTime() > lastUpdateTime + 0.1 then
        --[[if self.resizeScheduled then
            self:OnResize()
            self:UpdateEntryButtonIcons()
        end]]
        if self.sortingScheduled then
            self:UpdateDisplayedEntryData()
            --return
            --self:Sort()
        end
        self:UpdateColumnsSortArrows()
        self:UpdateColumns()
        self:UpdateEntryButtons()
        self:UpdateScrollBarMax()

        self.updateScheduled = false
        self.resizeScheduled = false
        self.sortingScheduled = false
        self.dontFilter = false

        lastUpdateTime = GetTime()
    end
end

local function AddColumn(self, key)
    CreateColumnButton(self, key)
    self:UpdateColumns()
    for _, entryButton in pairs(self.entryButtons) do
        entryButton:AddColumn(key)
    end
end

local smoothingAmount
local function SmoothScrollFrame_OnUpdate(self)
    local f = self:GetParent()
    local smoothingAmount = smoothingAmount
    if self.smoothOppositeCurve then
        smoothingAmount = smoothingAmount + 0.1
    end

    if self.doSmoothing then
        local progress = (GetTime() - GetTickTime() - self.smoothTime) / smoothingAmount
        if progress > 1 then
            progress = 1
        else
            -- Curve it
            if not self.smoothOppositeCurve then
                progress = 1 - progress
                progress = progress * progress
                progress = 1 - progress
            else
                progress = (math.cos((1 - progress) * math.pi) + 1) / 2
            end
        end

        local smoothTarget = self.smoothTarget
        local _, max = self:GetMinMaxValues()
        -- Allow scrolling a bit past the end of the list
        if smoothTarget > max then
            smoothTarget = max + math.pow((smoothTarget - max) * smoothingAmount * 0.4, 0.3)
        elseif smoothTarget < 0 then
            smoothTarget = -math.pow(math.abs(smoothTarget) * smoothingAmount * 0.4, 0.3)
        end

        local distance = smoothTarget - self.smoothStart
        f.scrollPos = self.smoothStart + distance * progress
        self:SetValue(f.scrollPos)
        if f.lastScrollPosInteger ~= floor(f.scrollPos) then
            f.lastScrollPosInteger = floor(f.scrollPos)
            f:UpdateEntryButtons()
        end
        f:PositionEntryButtonsFast() 

        -- At end of animation, stop or go back to min/max value
        if progress == 1 then
            if self.smoothTarget > max then
                self.smoothTime = GetTime() - GetTickTime()
                self.smoothStart = smoothTarget
                self.smoothTarget = max
                self.smoothOppositeCurve = true
            elseif self.smoothTarget < 0 then
                self.smoothTime = GetTime() - GetTickTime()
                self.smoothStart = smoothTarget
                self.smoothTarget = 0
                self.smoothOppositeCurve = true
            else
                self.doSmoothing = false
            end
        end
    end
end

function S.CreateList(parent, entryConstructor, minWidth, tColumns, sColumnSettings, bColumnHeadings, tGroups, groupingSettings)
    local self = CreateFrame("SCROLLFRAME", "", parent)
    
    self.gridView = false
    self.ToggleGridView = ToggleGridView

    self.entryButtons = {}
    self.entryData = {}
    self.EntryExists = EntryExists
    self.EntryHasData = EntryHasData
    self.GetDataForEntry = GetDataForEntry
    self.UpdateEntryData = UpdateEntryData
    self.UpdateDisplayedEntryData = UpdateDisplayedEntryData
    self.scrollPos = 0
    self.lastScrollPosInteger = 0
    self.hasColumnHeadings = bColumnHeadings
    self.columns = tColumns
    self.AddColumn = AddColumn
    self.columnSettingsKey = sColumnSettings
    self.GetColumnWidth = GetColumnWidth
    self.ColumnEnabled = ColumnEnabled
    self.GetColumnSettings = GetColumnSettings
    self.GetColumnOrder = GetColumnOrder
    self.UpdateColumns = UpdateColumns
    self.PositionColumns = PositionColumns
    self.AddEntry = AddEntry
    self.ScheduleUpdate = ScheduleUpdate
    self:SetScript("OnUpdate", OnUpdate)
    self.UpdateEntryButtons = UpdateEntryButtons
    self.UpdateEntryButtonIcons = UpdateEntryButtonIcons
    self.PositionEntryButtons = PositionEntryButtons
    self.PositionEntryButtonsFast = PositionEntryButtonsFast
    self.CreateEntry = entryConstructor
    self.OnResize = OnResize
    self.SortTable = SortTable
    self.FilterEntries = FilterEntries
    self.GetSortMethod = GetSortMethod
    self.GetSortMethodHistory = GetSortMethodHistory
    self.UpdateColumnsSortArrows = UpdateColumnsSortArrows
    self.UpdateScrollBarMax = UpdateScrollBarMax
    self.ScrollToTop = ScrollToTop
    self.minWidth = minWidth
    self.GetMinWidth = GetMinWidth
    self.groups = tGroups
    self.groupHeadings = {}
    self.collapsedGroups = {}
    self.headingButtons = {}
    self.groupingSettings = groupingSettings
    self.SelectGrouping = SelectGrouping
    self.GetGrouping = GetGrouping
    self.GetEntryGroup = GetEntryGroup
    self.ToggleGroupHeading = ToggleGroupHeading
    self.GetGroupHeadingCollapsed = GetGroupHeadingCollapsed
    self.GetEntryFavorited = GetEntryFavorited
    self.GetEntryNew = GetEntryNew
    self.SetMinimised = SetMinimised
    self.IsAvailable = IsAvailable
    self.GetNumVisibleEntries = GetNumVisibleEntries
    self.numVisibleEntries = 0

    local f = self
    f:SetAllPoints()

    f.scrollBar = CreateFrame("SLIDER", "", f, "MinimalScrollBarTemplate")
    f.scrollBar.trackBG:Hide()
    f.scrollBar:SetPoint("BOTTOM", 0, 16)
    f.scrollBar:SetMinMaxValues(0, 200)
    f.scrollBar:SetValue(0)
    f.scrollPos = 0
    f.scrollBar.Update = function(self)
        f.scrollPos = self:GetValue()
        if f.lastScrollPosInteger ~= floor(f.scrollPos) then
            f.lastScrollPosInteger = floor(f.scrollPos)
            f:UpdateEntryButtons()
        end
        f:PositionEntryButtonsFast()
    end
    
    f.scrollBar:SetScript("OnMouseDown", function(self) 
        self.doSmoothing = false
        self:SetScript("OnUpdate", f.scrollBar.Update)
    end)
    f.scrollBar:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", SmoothScrollFrame_OnUpdate) end)
    f.scrollBar.ScrollUpButton:SetScript("OnClick", function(self) 
        self:GetParent().doSmoothing = false
        f.scrollBar:SetValue(f.scrollBar:GetValue() - S.Settings.Get("scrollSpeed"))
        f.scrollBar:Update() 
    end)
    f.scrollBar.ScrollDownButton:SetScript("OnClick", function(self) 
        self:GetParent().doSmoothing = false
        f.scrollBar:SetValue(f.scrollBar:GetValue() + S.Settings.Get("scrollSpeed"))
        f.scrollBar:Update() 
    end)

    f:SetScript("OnMouseWheel", function(self, delta)
        local _, max = f.scrollBar:GetMinMaxValues()
        if max == 0 then return end
        
        local scrollSpeed = S.Settings.Get("scrollSpeed")
        if IsAltKeyDown() then
            scrollSpeed = scrollSpeed * 3
        end
        if S.Settings.Get("smoothingAmount") == 0 then
            f.scrollBar:SetValue(f.scrollBar:GetValue() - delta * scrollSpeed)
            f.scrollBar:Update()
        else
            f.scrollBar.doSmoothing = true
            f.scrollBar.smoothOppositeCurve = false
            f.scrollBar.smoothStart = f.scrollPos
            f.scrollBar.smoothTime = GetTime() - GetTickTime()
            if f.scrollBar.smoothTarget and ((f.scrollBar.smoothDirection and delta > 0) or (not f.scrollBar.smoothDirection and delta < 0)) then
                local prevSmoothTarget = f.scrollBar.smoothTarget

                f.scrollBar.smoothTarget = f.scrollBar.smoothTarget - delta * scrollSpeed
            else
                f.scrollBar.smoothTarget = f.scrollPos - delta * scrollSpeed
            end
            if delta > 0 then
                f.scrollBar.smoothDirection = true
            else
                f.scrollBar.smoothDirection = false
            end
        end
    end)

    local function OnSmoothAmountChanged(self)

        smoothingAmount = S.Settings.Get("smoothingAmount")
        if smoothingAmount and smoothingAmount > 0 then
            if not self.doOnUpdate then
                self.doOnUpdate = true

                -- Perform smooth scrolling
                self:SetScript("OnUpdate", SmoothScrollFrame_OnUpdate)

            end
        else
            if self.doOnUpdate then
                self.doOnUpdate = false
                self:SetScript("OnUpdate", nil)
            end
        end
    end
    S.Utils.RunOnEvent(f.scrollBar, "SettingChanged-smoothingAmount", OnSmoothAmountChanged)

    function f.scrollBar.UpdateScrollStep(self)
        self.scrollStep = S.Settings.Get("scrollSpeed")
    end
    S.Utils.RunOnEvent(f.scrollBar, "SettingChanged-scrollSpeed", f.scrollBar.UpdateScrollStep)

    f.listFrame = CreateFrame("FRAME", "", self)
    f.listFrame:SetClipsChildren(true)
    f.listFrame:SetPoint("BOTTOM")
    f.listFrame:SetPoint("RIGHT", f.scrollBar, "LEFT", 0, 0)
    if not bColumnHeadings then
        f.listFrame:SetPoint("TOPLEFT", 0, 0)
        f.scrollBar:SetPoint("TOPRIGHT", 0, -18)
    else
        f.listFrame:SetPoint("TOPLEFT", 0, -COLUMN_HEADING_HEIGHT)
        f.scrollBar:SetPoint("TOPRIGHT", 0, -18 - COLUMN_HEADING_HEIGHT)
        f.head = CreateFrame("FRAME", "", f)
        f.head:SetPoint("TOPLEFT")
        f.head:SetPoint("BOTTOM", f, "TOP", 0, -COLUMN_HEADING_HEIGHT)
        f.head:SetPoint("RIGHT", f.scrollBar, "LEFT", 0, 0)

        f.head.combinedStackSpacer = f.head:CreateTexture("")
        f.head.combinedStackSpacer:SetTexture("Interface\\Addons\\Sorted\\Textures\\Column-Heading-Gap")
        f.head.combinedStackSpacer:SetPoint("TOPLEFT")
        f.head.combinedStackSpacer:SetSize(20, 24)

        f.head.toggleGridButton = CreateFrame("BUTTON", nil, f.head)
        f.head.toggleGridButton.bg = f.head.toggleGridButton:CreateTexture(nil, "BACKGROUND")
        f.head.toggleGridButton.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Column-Heading-Gap")
        f.head.toggleGridButton.bg:SetAllPoints()
        f.head.toggleGridButton:SetPoint("TOPLEFT", f.head, "TOPRIGHT")
        f.head.toggleGridButton:SetSize(f.scrollBar:GetWidth(), COLUMN_HEADING_HEIGHT)
        f.head.toggleGridButton.list = self
        function f.head.toggleGridButton:Update()
            if self.list.gridView then
                self.tooltipText = "TOOLTIP_LAYOUT_LIST"
                self:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Layout-List-Up")
                self:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Layout-List-Up")
                self:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Layout-List-Down")
            else
                self.tooltipText = "TOOLTIP_LAYOUT_GRID"
                self:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Layout-Grid-Up")
                self:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Layout-Grid-Up")
                self:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Layout-Grid-Down")
            end
        end
        function f.head.toggleGridButton:UpdatePushed()
            if self.list.gridView then
                self:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Layout-List-Down")
            else
                self:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Layout-Grid-Down")
            end
        end
        f.head.toggleGridButton:Update()
        f.head.toggleGridButton:SetScript("OnMouseDown", f.head.toggleGridButton.UpdatePushed)
        f.head.toggleGridButton:SetScript("OnMouseUp", f.head.toggleGridButton.Update)
        f.head.toggleGridButton:SetScript("OnClick", function(self)
            self.list:ToggleGridView()
            self:Update()
            S.Tooltip.CreateLocalized(self, "ANCHOR_LEFT", self.tooltipText)
        end)
        f.head.toggleGridButton:SetScript("OnEnter", function(self)
            S.Tooltip.CreateLocalized(self, "ANCHOR_LEFT", self.tooltipText)
        end)
        f.head.toggleGridButton:SetScript("OnLeave", S.Tooltip.Cancel)

        f.columnHeadings = {}
        for k, v in pairs(tColumns) do
            local b = CreateColumnButton(self, k)
        end
    end

    S.Utils.RunOnEvent(self, "SettingChanged-padding", function(self)
        self:ScheduleUpdate(true, false)
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-iconSize", function(self)
        self:ScheduleUpdate(true, false)
        self:UpdateColumns()
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-iconShape", function(self)
        self:ScheduleUpdate(true, false)
        self:UpdateColumns()
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-iconBorderThickness", function(self)
        self:ScheduleUpdate(true, false)
        self:UpdateColumns()
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-paddingGrid", function(self)
        self:ScheduleUpdate(true, false)
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-iconSizeGrid", function(self)
        self:ScheduleUpdate(true, false)
        self:UpdateColumns()
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-iconShapeGrid", function(self)
        self:ScheduleUpdate(true, false)
        self:UpdateColumns()
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-iconBorderThicknessGrid", function(self)
        self:ScheduleUpdate(true, false)
        self:UpdateColumns()
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-iconBorders", function(self)
        self:ScheduleUpdate(true, false)
        self:UpdateColumns()
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-iconBordersGrid", function(self)
        self:ScheduleUpdate(false, false)
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-combineStacks", function(self)
        self:ScheduleUpdate(true, true)
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-newOnTop", function(self)
        self:ScheduleUpdate(false, true)
    end)
    S.Utils.RunOnEvent(self, "SettingChanged-pinRecentlyUnequippedItems", function(self)
        self:ScheduleUpdate(false, true)
    end)
    S.Utils.RunOnEvent(self, "ProfileChanged", function(self)
        self:ScheduleUpdate(false, true)
    end)

    S.Utils.RunOnEvent(self, "ColumnsChanged", function(self)
        self:UpdateColumns()
        self:ScheduleUpdate(true, false)
    end)

    S.Utils.RunOnEvent(self, "GroupingChanged", function(self)
        self:ScheduleUpdate(false, true)
    end)

    S.Utils.RunOnEvent(self, "FavoriteChanged", function(self)
        self:ScheduleUpdate(false, true)
    end)

    S.Utils.RunOnEvent(self, "SortingChanged", function(self)
        self:ScheduleUpdate(false, true)
        --self:ScrollToTop()
    end)

    S.Utils.RunOnEvent(self, "Resized", function(self)
        self:ScheduleUpdate(true, false)
    end)

    S.Utils.RunOnEvent(self, "ColumnResized", function(self)
        self:ScheduleUpdate(false, false)
    end)

    S.Utils.RunOnEvent(self, "EnteredWorld", function(self)
        self:UpdateDisplayedEntryData()
        self:UpdateColumnsSortArrows()
        self:UpdateColumns()
        self:UpdateEntryButtons()
        self:UpdateScrollBarMax()
    end)


    --      This is now handled by OnUpdate, seeing as OnUpdate only runs when its shown anyway

    -- Update everything on show, since updates are disabled when the frame is hidden for performance
    --[[self.OnShow = function(self)
        self:ScheduleUpdate(false, true)
        --self:ScrollToTop()
    end
    self:SetScript("OnShow", self.OnShow)]]
    
   

    return self
end