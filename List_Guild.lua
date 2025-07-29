local _, S = ...
local pairs, ipairs, string, type, time, GetTime = pairs, ipairs, string, type, time, GetTime



-- Default item sort
local function DefaultSort(entry1, entry2)
    if entry1.quality == entry2.quality then
        if entry1.effectiveILvl == entry2.effectiveILvl then
            if entry1.name == entry2.name then
                if entry1.combinedCount == entry2.combinedCount then
                    return entry1.bag * 98 + entry1.slot > entry2.bag * 98 + entry2.slot
                end
                return entry1.combinedCount > entry2.combinedCount
            end
            return entry1.name < entry2.name
        end
        return entry1.effectiveILvl > entry2.effectiveILvl
    end
    return entry1.quality > entry2.quality
end


local function EntryExists(self, entryDataIndex)
    if self.entryData[entryDataIndex] then
        local entryData = self.entryData[entryDataIndex]
        local itemData = S.Data.GetGuildItem(entryData.tab, entryData.slot, S.GetSelectedCharacter())
        if itemData and itemData.link then
            return true
        end
    end
    return false
end
local function GetDataForEntry(self, entry)
    return S.Data.GetGuildItem(entry.tab, entry.slot, S.GetSelectedCharacter())
end
local function EntryHasData(self, entry)
    local data = S.Data.GetGuildItem(entry.tab, entry.slot, S.GetSelectedCharacter())
    if data and data.link then
        return true
    end
    return false
end

local function GetEntryFavorited(self, entryData)
    return S.Data.GetFavorited(entryData)
end

local function GetEntryNew(self, entryData)
    return false
end



-- Replaces the OnUpdate of List. Adds filtering.
-- Only update when some time has passed since the last update
local lastUpdateTime = 0
local function OnUpdate3(self)
    if self.updateScheduled and GetTime() > lastUpdateTime + 0.05 then
        --[[if self.resizeScheduled then
            self:OnResize()
            self:UpdateEntryButtonIcons()
        end]]
        if self.sortingScheduled then
            self:UpdateDisplayedEntryData()
        end
        self:UpdateColumnsSortArrows()
        self:UpdateColumns()
        self:UpdateEntryButtons()
        self:UpdateScrollBarMax()

        self.updateScheduled = false
        self.resizeScheduled = false
        self.sortingScheduled = false
        
        lastUpdateTime = GetTime()
    end
end
-- The OnUpdate function when the "Place item in here" overlay is showing
local function OnUpdate2(self)
    OnUpdate3(self)
    local infoType = GetCursorInfo()
    if not self:IsMouseOver() or not (infoType == "item") then
        self.placeItem:Hide()
        self:SetScript("OnUpdate", self.OnUpdate)
    end
end
-- The OnUpdate function when the "Place item in here" overlay isn't showing
-- Checks if the mouse is over and whether the overlay should be shown
local function OnUpdate(self)
    OnUpdate3(self)
    if self:IsAvailable() and self:IsMouseOver() then
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" then
            self.placeItem:Show()
            self.placeItem.text:SetText(string.format(S.Localize("BUTTON_PLACE_ITEM"), itemLink, GUILD_BANK))
            self:SetScript("OnUpdate", self.OnUpdate2)
        end
    end
end

local function IsAvailable()
    if not S.IsPlayingCharacterSelected() then
        return false
    end
    return true
end

local function UpdateEntryButtonGuildBankTabHighlights(self)
    -- TODO
end

local function UpdateEntryButtons(self)
    self:UpdateEntryButtonsSuper()
    self:UpdateEntryButtonGuildBankTabHighlights()
end


-- Filtering copied from List_Items, with the addition of filtering by tab
--local LIS = LibStub("LibItemSearch-1.2")
-- Item search is slow, only perform it occasionally while player is typing
--[[local lastTimeSearched = GetTime()
local searchScheduled = false
local i = 1]]
local function DelayedFilter(self)
    local guildTab = S.Guild.GetSelectedTab()
    --lastTimeSearched = GetTime()
    local searchText = S.primaryFrame.searchBox:GetText()
    --searchScheduled = false

    -- Apply the -learnable tag to show battle pets with fewer than 3 collected
    local learnable = false
    if searchText:find("-learnable") then
        learnable = true
        if searchText == "-learnable" then
            searchText = ""
        else
            searchText = searchText:gsub("-learnable", "")
        end
    end

    for _, entry in ipairs(self.entryData) do
        if entry.hasData then
            if guildTab and entry.tab ~= guildTab then
                entry.filtered = true
            else
                entry.filtered = false
                if learnable then
                    if entry.data.speciesID then
                        entry.filtered = C_PetJournal.GetNumCollectedInfo(entry.data.speciesID) >= 3
                    else
                        entry.filtered = true
                    end
                end
                if not entry.filtered and #searchText > 0 then
                    if not --[[LIS:Matches(entry.data.link, searchText)]] S.Utils.BasicTextSearch(searchText, entry.data.name) then
                        entry.filtered = true
                    end
                end
                if not entry.filtered then
                    entry.filtered = S.FilterItem(entry.data)
                end
            end
        end
    end
end
local function FilterEntries(self)
    DelayedFilter(self)
    --[[local searchText = S.primaryFrame.searchBox:GetText()
    if #searchText > 0 and lastTimeSearched > GetTime() - 0.3 then
        if not searchScheduled then
            searchScheduled = true
            C_Timer.After(0.5, function() DelayedFilter(self) end)
        end
    else
        DelayedFilter(self)
        self:ScheduleUpdate(false, true)
    end]]
end



local freeSpaceColor, freeSpaceColorHighlight = S.Color.YELLOWISH_TEXT, S.Color.WHITE
local freeSpaceLowColor, freeSpaceLowColorHighlight = S.Color.YELLOW, S.Color.YELLOW_HIGHLIGHT
local freeSpaceZeroColor, freeSpaceZeroColorHighlight = S.Color.RED, S.Color.RED_HIGHLIGHT
local freeSpaceMaxColor, freeSpaceMaxColorHighlight = CreateColor(0.96, 0.9, 0.82, 0.6), CreateColor(0.96, 0.9, 0.82, 0.9)
local function FreeSpaceUpdateColors(self)
    if self.mouseOver then
        if self.numFreeSlots == 0 then
            self.text:SetTextColor(freeSpaceZeroColorHighlight:GetRGBA())
        elseif self.numFreeSlots <= self.numSlots * 0.05 then
            self.text:SetTextColor(freeSpaceLowColorHighlight:GetRGBA())
        else
            self.text:SetTextColor(freeSpaceColorHighlight:GetRGBA())
        end
        self.maxText:SetTextColor(freeSpaceMaxColorHighlight:GetRGBA())
    else
        if self.numFreeSlots == 0 then
            self.text:SetTextColor(freeSpaceZeroColor:GetRGBA())
        elseif self.numFreeSlots <= self.numSlots * 0.05 then
            self.text:SetTextColor(freeSpaceLowColor:GetRGBA())
        else
            self.text:SetTextColor(freeSpaceColor:GetRGBA())
        end
        self.maxText:SetTextColor(freeSpaceMaxColor:GetRGBA())
    end
end
local function FreeSpaceTooltip(self)
    local data = S.GetData().guild
    if data then
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()

        GameTooltip:AddLine(GUILD_BANK, 1, 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1, 1)

        local r, g, b = S.Utils.GetButtonTextColor():GetRGB()
        for i = 1, 8 do
            local name = data.tabs[i].name
            local count = data.tabs[i].count
            if name and count then
                GameTooltip:AddDoubleLine(name, data.tabs[i].count.."|cFFD1C9BF/90", r, g, b, 1, 1, 1)
            end
        end

        GameTooltip:Show()
    end
end
local function FreeSpaceOnEnter(self)
    self.mouseOver = true
    FreeSpaceUpdateColors(self)
    S.Tooltip.Schedule(function() FreeSpaceTooltip(self) end)
end
local function FreeSpaceOnLeave(self)
    self.mouseOver = false
    FreeSpaceUpdateColors(self)
    S.Tooltip.Cancel()
end

-- Based on Blizzard's Update function for ContainerFrameItemButtons
-- Modified for the guild bank
local function Button_OnUpdate(self)
    local link, itemID = self.parent.data.link, self.parent.data.itemID
    if not link then
        return
    end

	GameTooltip:SetOwner(self, "ANCHOR_NONE");

	ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip);
    
    GameTooltip:SetGuildBankItem(self.bag, self.slot)

	if ( IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") ) then
		GameTooltip_ShowCompareItem(GameTooltip);
	end

    -- TODO
    --[[if S.Settings.Get("tooltipInfo") == 1 then
        S.Tooltip.Extended(self.bag, self.slot)
    end]]
end



-- ITEM BUTTON
local ItemButtonMixin = {}

function ItemButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	self.SplitStack = function(button, split)
		SplitGuildBankItem(self.bag, self.slot, split);
	end
	self.UpdateTooltip = self.OnEnter;
end

function ItemButtonMixin:OnClick(button)
	if ( HandleModifiedItemClick(GetGuildBankItemLink(self.bag, self.slot)) ) then
		return;
	end
	if ( IsModifiedClick("SPLITSTACK") ) then
		if ( not CursorHasItem() ) then
			local texture, count, locked = GetGuildBankItemInfo(self.bag, self.slot);
			if ( not locked and count and count > 1) then
				StackSplitFrame:OpenStackSplitFrame(count, self, "BOTTOMLEFT", "TOPLEFT");
			end
		end
		return;
	end
	local type, money = GetCursorInfo();
	if ( type == "money" ) then
		DepositGuildBankMoney(money);
		ClearCursor();
	elseif ( type == "guildbankmoney" ) then
		DropCursorMoney();
		ClearCursor();
	else
		if ( button == "RightButton" ) then
			AutoStoreGuildBankItem(self.bag, self.slot);
			self:OnLeave();
		else
			PickupGuildBankItem(self.bag, self.slot);
		end
	end
end

function ItemButtonMixin:OnLeave()
	self.updateTooltipTimer = nil;
	GameTooltip_Hide();
	ResetCursor();
end

function ItemButtonMixin:OnHide()
	if ( self.hasStackSplit and (self.hasStackSplit == 1) ) then
		StackSplitFrame:Hide();
	end
end

function ItemButtonMixin:OnDragStart()
	PickupGuildBankItem(self.bag, self.slot);
end

function ItemButtonMixin:OnReceiveDrag()
	PickupGuildBankItem(self.bag, self.slot);
end

function ItemButtonMixin:OnEvent()
	if ( GameTooltip:IsOwned(self) ) then
		self:OnEnter();
	end
end


-- CreateEntry makes an EntryButton_Item then makes some modifications
local function CreateEntry(list)
    local self = S.CreateItemEntry(list)

    Mixin(self.button, ItemButtonMixin)
    self.button:OnLoad()
    self.button:HookScript("OnClick", self.button.OnClick)
    self.button:HookScript("OnLeave", self.button.OnLeave)
    self.button:HookScript("OnHide", self.button.OnHide)
    self.button:HookScript("OnDragStart", self.button.OnDragStart)
    self.button:HookScript("OnReceiveDrag", self.button.OnReceiveDrag)
    self.button:HookScript("OnEvent", self.button.OnEvent)

    self.OnUpdate = Button_OnUpdate
    self.button.UpdateTooltip = Button_OnUpdate
    self.button:HookScript("OnLeave", S.Tooltip.Cancel)

    self.expandCombinedStackButton:SetFrameLevel(self.button:GetFrameLevel() + 5)

    return self
end


function S.CreateGuildItemList(parent)
    local list =  S.CreateList(parent, CreateEntry, 400, S.ItemColumns, "itemColumnSettings", true, S.ItemGroups, "itemGroupingSettings")
    list:ClearAllPoints()
    list:SetPoint("TOPLEFT")
    list:SetPoint("BOTTOMRIGHT", 0, 32)

    list.DefaultSortFunc = DefaultSort

    list.canCombineStacks = true
    list.expandedCombinedItems = {}
    
    list.FilterEntries = FilterEntries
    list.EntryExists = EntryExists
    list.EntryHasData = EntryHasData
    list.GetDataForEntry = GetDataForEntry
    list.GetEntryFavorited = GetEntryFavorited
    list.GetEntryNew = GetEntryNew
    list.SetMinimised = SetMinimised
    list.IsAvailable = IsAvailable
    list.OnUpdate = OnUpdate
    list.OnUpdate2 = OnUpdate2
    list:SetScript("OnUpdate", OnUpdate)
    list.UpdateEntryButtonsSuper = list.UpdateEntryButtons
    list.UpdateEntryButtons = UpdateEntryButtons
    list.UpdateEntryButtonGuildBankTabHighlights = UpdateEntryButtonGuildBankTabHighlights

    list.type = "GUILD_BANK"

    -- Add entries
    for tab = 1, 8 do
        for slot = 1, 98 do
            list:AddEntry({
                ["bag"] = tab,
                ["tab"] = tab,
                ["slot"] = slot
            })
        end
    end

    S.Utils.RunOnEvent(list, "GuildBankUpdated", function(self)
        self:UpdateEntryButtons()
    end)
    S.Utils.RunOnEvent(list, "GuildBankUpdatedFull", function(self)
        self:ScheduleUpdate(false, true)
    end)
    S.Utils.RunOnEvent(list, "GuildTabSelected", function(self)
        self:ScheduleUpdate(false, true)
        self:ScrollToTop()
    end)

    S.Utils.RunOnEvent(list, "LayoutChanged", function(self)
        self:UpdateEntryButtonGuildBankTabHighlights()
    end)
    S.Utils.RunOnEvent(list, "SearchChanged", function(self)
        self:ScheduleUpdate(false, true)
        if #S.primaryFrame.searchBox:GetText() > 0 then
            self:ScrollToTop()
        end
    end)
    S.Utils.RunOnEvent(list, "CategorySelected", function(self)
        self:ScheduleUpdate(false, true)
        self:ScrollToTop()
    end)
    S.Utils.RunOnEvent(list, "CharacterSelected", function(self)
        self.columnSettings = S.Settings.Get(self.columnSettingsKey)
        self:ScheduleUpdate(false, true)
        self:ScrollToTop()
    end)
    S.Utils.RunOnEvent(list, "EquipmentSetSelected", function(self)
        self:ScheduleUpdate(false, true)
        self:ScrollToTop()
    end)
    S.Utils.RunOnEvent(list, "FavoriteChanged", function(self)
        self:ScheduleUpdate(false, true)
    end)


    list.placeItem = CreateFrame("BUTTON", nil, list)
    list.placeItem:SetPoint("TOPLEFT", list.head, "BOTTOMLEFT")
    list.placeItem:SetPoint("BOTTOMRIGHT")
    list.placeItem:SetFrameLevel(list:GetFrameLevel() + 100)
    list.placeItem:Hide()
    list.placeItem.bg = list.placeItem:CreateTexture(nil, "BACKGROUND")
    list.placeItem.bg:SetAllPoints()
    list.placeItem.bg:SetColorTexture(0, 0, 0, 0.5)
    S.FrameTools.AddBorder(list.placeItem, "highlight", "Interface\\Addons\\Sorted\\Textures\\Place-Item-Highlight", 8, 2, true)
    for k,v in pairs(list.placeItem.highlight.parts) do
        v:SetBlendMode("ADD")
    end
    list.placeItem.text = list.placeItem:CreateFontString(nil, "OVERLAY", "SortedFont")
    list.placeItem.text:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
    list.placeItem.text:SetPoint("TOPLEFT", 16, -16)
    list.placeItem.text:SetPoint("BOTTOMRIGHT", -16, 16)
    list.placeItem.text:SetTextScale(1.5)
    list.placeItem.list = list
    list.placeItem:SetScript("OnMouseDown", function(self)
        S.Utils.PlaceCursorItemInContainerType("GUILD_BANK", S.Guild.GetSelectedTab())
    end)

    
    list.freeSpace = CreateFrame("BUTTON", nil, list)
    list.freeSpace:SetPoint("TOPLEFT", list, "BOTTOMLEFT")
    list.freeSpace:SetSize(70, 32)
    list.freeSpace.text = list.freeSpace:CreateFontString(nil, "OVERLAY", "SortedFont")
    list.freeSpace.text:SetPoint("RIGHT", list.freeSpace, "CENTER", 0, 0)
    list.freeSpace.text:SetTextColor(freeSpaceColor:GetRGBA())
    list.freeSpace.text:SetTextScale(1.2)
    list.freeSpace.maxText = list.freeSpace:CreateFontString(nil, "OVERLAY", "SortedFont")
    list.freeSpace.maxText:SetPoint("BOTTOMLEFT", list.freeSpace.text, "BOTTOMRIGHT", 2, 0)
    list.freeSpace.maxText:SetTextColor(freeSpaceMaxColor:GetRGBA())
    list.freeSpace.parent = list
    list.freeSpace.type = type
    function list.freeSpace:Update()
        local data = S.GetData()
        if data.guild then
            local guildTab = S.Guild.GetSelectedTab()
            local count = 0
            local max = 0
            if guildTab then
                if data.guild.tabs and data.guild.tabs[guildTab].canView and data.guild.tabs[guildTab].count then
                    count = count + data.guild.tabs[guildTab].count
                    max = 98
                end
            else
                for i = 1, 8 do
                    if data.guild.tabs[i].name and data.guild.tabs[i].canView and data.guild.tabs[i].count then
                        count = count + data.guild.tabs[i].count
                        max = max + 98
                    end
                end
            end
            self.numSlots = max
            self.numFreeSlots = max - count
            self.text:Show()
            self.text:SetText(count)
            self.maxText:Show()
            self.maxText:SetText(max)
            FreeSpaceUpdateColors(self)
        else
            self.text:Hide()
            self.maxText:Hide()
        end
    end
    S.Utils.RunOnEvent(list.freeSpace, "GuildBankUpdated", list.freeSpace.Update)
    S.Utils.RunOnEvent(list.freeSpace, "GuildTabSelected", list.freeSpace.Update)
    S.Utils.RunOnEvent(list.freeSpace, "CharacterSelected", list.freeSpace.Update)
    list.freeSpace:SetScript("OnEnter", FreeSpaceOnEnter)
    list.freeSpace:SetScript("OnLeave", FreeSpaceOnLeave)
    list.freeSpace:SetScript("OnClick", FreeSpaceOnClick)



    return list
end