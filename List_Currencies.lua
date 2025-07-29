local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

-- Default currency sort
local function DefaultSort(entry1, entry2)
    return entry1.name < entry2.name
end


--[[S.currencyGroupingSettings = {
    ["selectedGrouping"] = "CATEGORY",
    ["collapsedGroups"] = {}
}]]
-- Moved to Settings

-- CURRENCY GROUPS
S.CurrencyGroups = {
    ["CATEGORY"] = {
        ["name"] = S.Localize("GROUPING_CATEGORY"),
        ["func"] = function(currency)
            return currency.heading, currency.heading
        end
    },
    ["QUALITY"] = {
        ["name"] = S.Localize("FILTER_QUALITY"),
        ["func"] = function(currency)
            if currency.quality then
                return _G["ITEM_QUALITY"..currency.quality.."_DESC"], -currency.quality
            else
                return NONE, 100
            end
        end
    },
    ["FAVORITES"] = {
        ["name"] = S.Localize("FILTER_MARKER_ICON"),
        ["func"] = function(currency)
            local markerIcon = S.Data.GetCurrencyFavorited(currency)
            if not markerIcon then
                markerIcon = 100
            end
            return S.Utils.FormatMarkerIcon(markerIcon), markerIcon
        end
    },
    ["TRACKED"] = {
        ["name"] = SHOW_ON_BACKPACK,
        ["func"] = function(currency)
            if S.Data.GetCurrencyTracked(currency) then
                return S.Localize("GROUPING_TRACKED_CHECKED"), 1
            else
                return S.Localize("GROUPING_TRACKED_UNCHECKED"), 2
            end
        end
    }
}


-- Currency Columns
local function GetColumnWidth(self, key)
    local settings = S.Settings.Get("currencyColumnSettings")
    if settings.widths and settings.widths[key] then
        return settings.widths[key]
    end
    return self.width
end
local function GetIconSize(self)
    return S.Settings.Get("iconSize") + 4
end
S.CurrencyColumns = {
    ["FAVORITES"] = {
        ["name"] = S.Localize("COLUMN_FAVORITES"),
        ["width"] = 24,
        ["GetWidth"] = GetColumnWidth,
        ["align"] = "CENTER",
        ["CreateElement"] = function(self)
            self.favoriteButton = CreateFrame("BUTTON", nil, self)
            self.favoriteButton:SetPoint("CENTER")
            self.favoriteButton:SetSize(18, 18)
            self.favoriteButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Favorite-Icons")
            self.favoriteButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Favorite-Icons")
            self.favoriteButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Favorite-Icons")
            self.favoriteButton.backdrop = self.favoriteButton:CreateTexture(nil, "BACKGROUND")
            self.favoriteButton.backdrop:SetTexture("Interface\\Addons\\Sorted\\Textures\\Favorite-Icons")
            self.favoriteButton.backdrop:SetAllPoints()
            self.favoriteButton.parent = self.parent
            self.favoriteButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            self.favoriteButton:SetScript("OnClick", function(self, button, down)
                if button == "LeftButton" then
                    self.parent:ToggleFavorited()
                elseif button == "RightButton" then
                    S.MarkerIconMenu.Show(self, self.parent:GetData().quality, self.parent:GetData().texture, self.parent.SetFavorited, self.parent, self.parent.ClearFavorited)
                end
            end)
        end,
        ["UpdateElement"] = function(self, data)
            local favorited = self.parent:GetFavorited()
            local favoriteButtonTexSize = 0.21875
            local x,y
            if not favorited or favorited == 0 then
                self.favoriteButton:GetNormalTexture():SetTexCoord(1,1,1,1)
                x = 0
                y = 0
                self.favoriteButton:GetHighlightTexture():SetTexCoord(
                    x * favoriteButtonTexSize, 
                    (x+1) * favoriteButtonTexSize,
                    y * favoriteButtonTexSize, 
                    (y+1) * favoriteButtonTexSize
                )
                self.favoriteButton:GetPushedTexture():SetTexCoord(
                    x * favoriteButtonTexSize, 
                    (x+1) * favoriteButtonTexSize,
                    y * favoriteButtonTexSize, 
                    (y+1) * favoriteButtonTexSize
                )
                if self.mouseEntered then
                    self.favoriteButton.backdrop:SetTexCoord(0,favoriteButtonTexSize,favoriteButtonTexSize*2,favoriteButtonTexSize*3)
                else
                    self.favoriteButton.backdrop:SetTexCoord(1,1,1,1)
                end
            else
                x,y = (favorited - 1) % 4, floor((favorited - 1) / 4)
                self.favoriteButton:GetNormalTexture():SetTexCoord(
                    x * favoriteButtonTexSize, 
                    (x+1) * favoriteButtonTexSize,
                    y * favoriteButtonTexSize, 
                    (y+1) * favoriteButtonTexSize
                )
                self.favoriteButton:GetHighlightTexture():SetTexCoord(
                    x * favoriteButtonTexSize, 
                    (x+1) * favoriteButtonTexSize,
                    y * favoriteButtonTexSize, 
                    (y+1) * favoriteButtonTexSize
                )
                self.favoriteButton:GetPushedTexture():SetTexCoord(
                    x * favoriteButtonTexSize, 
                    (x+1) * favoriteButtonTexSize,
                    y * favoriteButtonTexSize, 
                    (y+1) * favoriteButtonTexSize
                )
                self.favoriteButton.backdrop:SetTexCoord(1,1,1,1)
            end

            if data.filtered then
                self.favoriteButton:GetNormalTexture():SetDesaturated(true)
                self.favoriteButton:GetNormalTexture():SetVertexColor(S.Color.LIGHT_GREY:GetRGB())
            else
                self.favoriteButton:GetNormalTexture():SetDesaturated(false)
                self.favoriteButton:GetNormalTexture():SetVertexColor(S.Color.WHITE:GetRGB())
            end
        end
    },
    ["QUANTITY"] = {
        ["name"] = S.Localize("COLUMN_QUANTITY"),
        ["width"] = 42,
        ["GetWidth"] = GetColumnWidth,
        ["align"] = "RIGHT",
        ["sortMethods"] = {
            {
                ["title"] = "#",
                ["func"] = function(asc, slot1, slot2)
                    return S.Sort.ByKey(not asc, slot1, slot2, "count")
                end
            }
        },
        ["CreateElement"] = function(f)
            f.quantityString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
            f.quantityString:SetPoint("RIGHT", -2, 0)
            f.quantityString:SetTextColor(S.Color.YELLOWISH_TEXT:GetRGB())
        end,
        ["UpdateElement"] = function(self, data)
            self.quantityString:SetText(S.Utils.FormatBigNumber(data.count))

            if data.count == data.maxQuantity then
                if data.filtered then
                    self.quantityString:SetTextColor(0.2, 0.14, 0.15)
                else
                    self.quantityString:SetTextColor(S.Color.RED:GetRGB())
                end
            else
                if data.filtered then
                    self.quantityString:SetTextColor(S.Color.GREY:GetRGB())
                else
                    self.quantityString:SetTextColor(S.Color.YELLOWISH_TEXT:GetRGB())
                end
            end
        end
    },
    ["ICON"] = {
        ["name"] = S.Localize("COLUMN_ICON"),
        ["GetWidth"] = GetIconSize,
        ["align"] = "CENTER",
        ["sortMethods"] = {
            {
                ["title"] = "",
                ["func"] = function(asc, slot1, slot2)
                    return S.Sort.ByKey(not asc, slot1, slot2, "quality")
                end
            }
        },
        ["CreateElement"] = function(self)
            self.icon = self:CreateTexture(nil, "ARTWORK")
            self.icon:SetPoint("CENTER")
            self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            self.iconMask = self:CreateMaskTexture()
            self.iconMask:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle_Mask")
            self.iconMask:SetPoint("CENTER")
            self.iconBorder = self:CreateTexture(nil, "BORDER")
            self.iconBorder:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle_Mask")
            self.iconBorder:SetPoint("CENTER")
        end,
        ["UpdateElement"] = function(self, data)
            self.icon:SetTexture(data.texture)
            -- If is honor
            if ( S.WoWVersion() <= 3 and data.id == Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID ) then
                self.icon:SetTexCoord( 0.03125, 0.59375, 0.03125, 0.59375 );
            else
                self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
            end

            if data.filtered then
                self.icon:SetDesaturated(true)
                self.icon:SetVertexColor(S.Color.LIGHT_GREY:GetRGB())
                self.iconBorder:SetVertexColor(data.tinted:GetRGB())
            else
                self.icon:SetDesaturated(false)
                self.icon:SetVertexColor(S.Color.WHITE:GetRGB())
                if self.mouseEntered then
                    self.iconBorder:SetVertexColor(data.color2:GetRGB())
                else
                    self.iconBorder:SetVertexColor(data.color1:GetRGB())
                end
            end
        end,
        ["UpdateIcon"] = function(self, iconSize, borderThickness, iconShape, iconBorders)
            self.icon:SetSize(iconSize, iconSize)
            self.iconMask:SetSize(iconSize, iconSize)
            if iconShape == 0 then
                self.icon:RemoveMaskTexture(self.iconMask)
                self.iconBorder:SetTexture("Interface\\Addons\\Sorted\\Textures\\Item_Glow")
            elseif iconShape == 1 then
                self.icon:AddMaskTexture(self.iconMask)
                self.iconBorder:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle_Mask")
            end
            self.iconBorder:SetSize(iconSize + borderThickness, iconSize + borderThickness)
            self.iconBorder:SetShown(iconBorders == 1)
        end
    },
    ["NAME"] = {
        ["name"] = S.Localize("COLUMN_NAME"),
        ["GetWidth"] = function(self) return nil end,
        ["align"] = "CENTER",
        ["sortMethods"] = {
            {
                ["title"] = S.Localize("COLUMN_RARITY_SHORT"),
                ["func"] = function(asc, slot1, slot2) 
                    return S.Sort.ByKey(not asc, slot1, slot2, "quality")
                end
            },
            {
                ["title"] = S.Localize("COLUMN_NAME_SHORT"),
                ["func"] = function(asc, slot1, slot2) 
                    return S.Sort.ByKey(asc, slot1, slot2, "name")
                end,
                ["inverse"] = true
            }
        },
        ["CreateElement"] = function(self)
            self.nameString = self:CreateFontString(nil, "OVERLAY", "SortedFont")
            self.nameString:SetPoint("TOP", 0, -2)
            self.nameString:SetPoint("BOTTOM", 0, 2)
            self.nameString:SetPoint("LEFT", 2, 0)
            self.nameString:SetPoint("RIGHT", -2, 0)
            self.nameString:SetJustifyH("LEFT")
            self.nameString:SetJustifyV("MIDDLE")
        end,
        ["UpdateElement"] = function(self, data)
            self.nameString:SetText(data.name)

            if data.filtered then
                self.nameString:SetTextColor(data.tinted:GetRGB())
            else
                if self.mouseEntered then
                    self.nameString:SetTextColor(data.color2:GetRGB())
                else
                    self.nameString:SetTextColor(data.color1:GetRGB())
                end
            end
        end
    },
    ["CATEGORY"] = {
        ["name"] = S.Localize("GROUPING_CATEGORY"),
        ["width"] = 120,
        ["GetWidth"] = GetColumnWidth,
        ["align"] = "LEFT",
        ["sortMethods"] = {
            {
                ["title"] = S.Localize("GROUPING_CATEGORY"),
                ["func"] = function(asc, slot1, slot2) 
                    return S.Sort.ByKey(asc, slot1, slot2, "heading")
                end,
                ["inverse"] = true
            }
        },
        ["CreateElement"] = function(self)
            self.categoryString = self:CreateFontString(nil, "OVERLAY", "SortedFont")
            self.categoryString:SetPoint("TOPLEFT", 2, -4)
            self.categoryString:SetPoint("BOTTOMRIGHT", -2, 4)
            self.categoryString:SetJustifyH("LEFT")
            self.categoryString:SetJustifyV("MIDDLE")
        end,
        ["UpdateElement"] = function(self, data)
            self.categoryString:SetText(data.heading)

            if data.filtered then
                self.categoryString:SetTextColor(S.Color.GREY:GetRGB())
            else
                self.categoryString:SetTextColor(S.Color.YELLOWISH_TEXT:GetRGB())
            end
        end
    },
    ["MAX-QUANTITY"] = {
        ["name"] = S.Localize("COLUMN_MAX_QUANTITY"),
        ["width"] = 42,
        ["GetWidth"] = GetColumnWidth,
        ["align"] = "LEFT",
        ["sortMethods"] = {
            {
                ["title"] = S.Localize("COLUMN_MAX_QUANTITY"),
                ["func"] = function(asc, slot1, slot2)
                    return S.Sort.ByKey(not asc, slot1, slot2, "maxQuantity")
                end
            }
        },
        ["CreateElement"] = function(self)
            self.maxQuantityString = self:CreateFontString(nil, "OVERLAY", "SortedFont")
            self.maxQuantityString:SetPoint("TOPLEFT", 2, -4)
            self.maxQuantityString:SetPoint("BOTTOMRIGHT", -2, 4)
            self.maxQuantityString:SetJustifyH("LEFT")
            self.maxQuantityString:SetJustifyV("MIDDLE")
            self.maxQuantityString:SetTextScale(0.9)
        end,
        ["UpdateElement"] = function(self, data)
            if data.maxQuantity > 0 then
                self.maxQuantityString:Show()
                self.maxQuantityString:SetText(S.Utils.FormatBigNumber(data.maxQuantity))
                if data.count == data.maxQuantity then
                    if data.filtered then
                        self.maxQuantityString:SetTextColor(0.2, 0.14, 0.15)
                        self.maxQuantityString:SetAlpha(0.6)
                    else
                        self.maxQuantityString:SetTextColor(S.Color.RED:GetRGB())
                        self.maxQuantityString:SetAlpha(0.7)
                    end
                else
                    if data.filtered then
                        self.maxQuantityString:SetTextColor(S.Color.GREY:GetRGB())
                    else
                        self.maxQuantityString:SetTextColor(S.Color.YELLOWISH_TEXT:GetRGB())
                    end
                    self.maxQuantityString:SetAlpha(0.6)
                end
            else
                self.maxQuantityString:Hide()
            end
        end
    },
    ["WEEKLY-QUANTITY"] = {
        ["name"] = S.Localize("COLUMN_WEEKLY_QUANTITY"),
        ["width"] = 60,
        ["GetWidth"] = GetColumnWidth,
        ["align"] = "RIGHT",
        ["sortMethods"] = {
            {
                ["title"] = S.Localize("COLUMN_WEEKLY_QUANTITY_SHORT"),
                ["func"] = function(asc, slot1, slot2)
                    return S.Sort.ByKey(not asc, slot1, slot2, "quantityEarnedThisWeek")
                end
            }
        },
        ["CreateElement"] = function(self)
            self.weeklyQuantityString = self:CreateFontString(nil, "OVERLAY", "SortedFont")
            self.weeklyQuantityString:SetPoint("TOPLEFT", 2, -4)
            self.weeklyQuantityString:SetPoint("BOTTOMRIGHT", -2, 4)
            self.weeklyQuantityString:SetJustifyH("RIGHT")
            self.weeklyQuantityString:SetJustifyV("MIDDLE")
            self.weeklyQuantityString:SetTextColor(0.96, 0.9, 0.82, 1)
        end,
        ["UpdateElement"] = function(self, data)
            if data.canEarnPerWeek then
                if data.quantityEarnedThisWeek == data.maxWeeklyQuantity then
                    if data.filtered then
                        self.weeklyQuantityString:SetTextColor(0.2, 0.14, 0.15)
                    else
                        self.weeklyQuantityString:SetTextColor(S.Color.RED:GetRGB())
                    end
                else
                    if data.filtered then
                        self.weeklyQuantityString:SetTextColor(S.Color.GREY:GetRGB())
                    else
                        self.weeklyQuantityString:SetTextColor(S.Color.YELLOWISH_TEXT:GetRGB())
                    end
                end
    
                self.weeklyQuantityString:Show()
                self.weeklyQuantityString:SetText(S.Utils.FormatBigNumber(data.quantityEarnedThisWeek))
            else
                self.weeklyQuantityString:Hide()
            end
        end
    },
    ["MAX-WEEKLY-QUANTITY"] = {
        ["name"] = S.Localize("COLUMN_MAX_WEEKLY_QUANTITY"),
        ["width"] = 60,
        ["GetWidth"] = GetColumnWidth,
        ["align"] = "LEFT",
        ["sortMethods"] = {
            {
                ["title"] = S.Localize("COLUMN_MAX_WEEKLY_QUANTITY_SHORT"),
                ["func"] = function(asc, slot1, slot2)
                    return S.Sort.ByKey(not asc, slot1, slot2, "maxWeeklyQuantity")
                end
            }
        },
        ["CreateElement"] = function(self)
            self.maxWeeklyQuantityString = self:CreateFontString(nil, "OVERLAY", "SortedFont")
            self.maxWeeklyQuantityString:SetPoint("TOPLEFT", 2, -4)
            self.maxWeeklyQuantityString:SetPoint("BOTTOMRIGHT", -2, 4)
            self.maxWeeklyQuantityString:SetJustifyH("LEFT")
            self.maxWeeklyQuantityString:SetJustifyV("MIDDLE")
            self.maxWeeklyQuantityString:SetTextColor(0.96, 0.9, 0.82, 1)
            self.maxWeeklyQuantityString:SetTextScale(0.9)
        end,
        ["UpdateElement"] = function(self, data)
            if data.canEarnPerWeek then
                if data.quantityEarnedThisWeek == data.maxWeeklyQuantity then
                    if data.filtered then
                        self.maxWeeklyQuantityString:SetTextColor(0.2, 0.14, 0.15)
                        self.maxWeeklyQuantityString:SetAlpha(0.6)
                    else
                        self.maxWeeklyQuantityString:SetTextColor(S.Color.RED:GetRGB())
                        self.maxWeeklyQuantityString:SetAlpha(0.7)
                    end
                else
                    if data.filtered then
                        self.maxWeeklyQuantityString:SetTextColor(S.Color.GREY:GetRGB())
                    else
                        self.maxWeeklyQuantityString:SetTextColor(S.Color.YELLOWISH_TEXT:GetRGB())
                    end
                    self.maxWeeklyQuantityString:SetAlpha(0.6)
                end
    
                self.maxWeeklyQuantityString:Show()
                self.maxWeeklyQuantityString:SetText(S.Utils.FormatBigNumber(data.maxWeeklyQuantity))
            else
                self.maxWeeklyQuantityString:Hide()
            end
        end
    },
    ["TRACKED"] = {
        ["name"] = TRACKING,
        ["width"] = 28,
        ["align"] = "CENTER",
        ["sortMethods"] = {
            {
                ["title"] = "|TInterface\\Addons\\Sorted\\Textures\\Checkbox-Tick:0:0:0:0:256:256:0:256:0:256|t", --S.Localize("COLUMN_BINDING_SHORT"),
                ["func"] = function(asc, slot1, slot2)
                    local track1, track2 = S.Data.GetCurrencyTracked(slot1), S.Data.GetCurrencyTracked(slot2)
                    return S.Sort.ByValue(asc, trash1, trash2, slot1, slot2)
                end
            }
        },
        ["CreateElement"] = function(f)
            f.trackButton = CreateFrame("CheckButton", nil, f)
            f.trackButton:SetPoint("CENTER")
            f.trackButton:SetSize(24, 24)
            f.trackButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox")
            f.trackButton:GetNormalTexture():Hide()
            f.trackButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Highlight")
            f.trackButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox")
            f.trackButton:SetCheckedTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Tick")

            f.trackButton.parent = f.parent
            f.trackButton:SetScript("OnClick", function(self)
                S.Data.ToggleCurrencyTracked(self.parent:GetData())
                S.Utils.TriggerEvent("CurrencyTrackingChanged")
            end)
            f.trackButton:SetScript("OnEnter", function(self)
                self:GetNormalTexture():Show()
                S.Tooltip.CreateText(self, "ANCHOR_RIGHT", TRACK_ACHIEVEMENT)
            end)
            f.trackButton:SetScript("OnLeave", function(self)
                self:GetNormalTexture():Hide()
                S.Tooltip.Cancel()
            end)
        end,
        ["UpdateElement"] = function(self, data)
            if S.Data.GetCurrencyTracked(data) then
                self.trackButton:SetChecked(true)
            else
                self.trackButton:SetChecked(false)
            end

            if data.filtered then
                self.trackButton:GetNormalTexture():SetDesaturated(true)
                self.trackButton:GetNormalTexture():SetAlpha(0.5)
                self.trackButton:GetCheckedTexture():SetDesaturated(true)
                self.trackButton:GetCheckedTexture():SetVertexColor(S.Color.LIGHT_GREY:GetRGB())
            else
                self.trackButton:GetNormalTexture():SetDesaturated(false)
                self.trackButton:GetNormalTexture():SetAlpha(1)
                self.trackButton:GetCheckedTexture():SetDesaturated(false)
                self.trackButton:GetCheckedTexture():SetVertexColor(S.Color.WHITE:GetRGB())
            end
        end,
        ["UpdateIcon"] = function(self, iconSize, borderThickness, iconShape)
            self.trackButton:SetSize(iconSize * 1.1, iconSize * 1.1)
        end
    }
}


local function UpdateEntryDataTable(self)
    self.entryData = {}
    local data = S.GetData()
    if data.currencies then
        for k,v in pairs(data.currencies) do
            table.insert(self.entryData, {
                ["currencyID"] = k
            })
        end
    end
end

local function EntryHasData(self, entry)
    local data = self:GetDataForEntry(entry)
    return data and data.count > 0
end
local function GetDataForEntry(self, entry)
    local data = S.GetData()
    if data.currencies and entry then
        return data.currencies[entry.currencyID]
    end
end



local function GetEntryFavorited(self, entryData)
    return S.Data.GetCurrencyFavorited(entryData)
end

-- Filter currencies. Currenctly currencies are only affected by Search
local function FilterEntries(self)
    local searchText = S.primaryFrame.searchBox:GetText():lower()
    if #searchText > 0 then
        for _, entry in ipairs(self.entryData) do
            entry.filtered = false
            local searchFiltered = true
            -- Name search
            if S.Utils.BasicTextSearch(searchText, entry.data.name) then
                searchFiltered = false

            -- Tooltip search
            elseif entry.data.tooltip then
                for side, lines in pairs(entry.data.tooltip) do
                    for i, line in pairs(lines) do
                        if S.Utils.BasicTextSearch(searchText, line) then
                            searchFiltered = false
                            break
                        end
                    end
                end
            end
            if searchFiltered then
                entry.filtered = true
            end
        end
    else
        for _, entry in ipairs(self.entryData) do
            entry.filtered = false
        end
    end
end

function S.CreateCurrencyList(parent)
    local self =  S.CreateList(parent, S.CreateCurrencyEntry, 200, S.CurrencyColumns, "currencyColumnSettings", true, S.CurrencyGroups, "currencyGroupingSettings")
    self.DefaultSortFunc = DefaultSort
    self.AddCurrencies = AddCurrencies
    self.EntryHasData = EntryHasData
    self.GetDataForEntry = GetDataForEntry
    self.UpdateEntryDataTable = UpdateEntryDataTable
    self.GetEntryFavorited = GetEntryFavorited
    self.FilterEntries = FilterEntries
    
    S.Utils.RunOnEvent(self, "EnteredWorld", UpdateEntryDataTable)
    S.Utils.RunOnEvent(self, "CurrenciesUpdated", function(self)
        self:UpdateEntryDataTable()
        self:ScheduleUpdate(false, true)
    end)
    S.Utils.RunOnEvent(self, "CurrencyTrackingChanged", function(self)
        self:ScheduleUpdate(false, true)
    end)
    S.Utils.RunOnEvent(self, "CharacterSelected", function(self)
        self.columnSettings = S.Settings.Get(self.columnSettingsKey)
        self:UpdateEntryDataTable()
        self:ScheduleUpdate(false, true)
    end)
    S.Utils.RunOnEvent(self, "SearchChanged", function(self)
        self:ScheduleUpdate(false, true)
        if #S.primaryFrame.searchBox:GetText() > 0 then
            self:ScrollToTop()
        end
    end)

    return self
end