local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

S.maxILvl = 0 -- ilvl opacity is set against this

local function UpdateEntry(self)
    self:UpdateSuper()
    
    -- Mouseover highlight
    if self.list.gridView then
        self.highlight:SetTexture("")
    else
        self.highlight:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Highlight")
        self.highlight:SetVertexColor(self.data.color1:GetRGB())
    end
end

--[[local function UpdateEntry(self)
    self:UpdateSuper()
    local data = self:GetData()
    self.color1 = S.Utils.GetItemQualityColor(data.quality)
    self.color2 = S.Utils.GetItemQualityHighlightColor(data.quality)


    local iconSize
    if self.list.gridView then
        iconSize = S.Settings.Get("iconSizeGrid")
    else
        iconSize = S.Settings.Get("iconSize")
    end
    self.icon:SetTexture(data.texture)
    -- If is honor
    if ( S.WoWVersion() <= 3 and data.id == Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID ) then
        self.icon:SetTexCoord( 0.03125, 0.59375, 0.03125, 0.59375 );
    else
        self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    end
    self.icon:SetSize(iconSize, iconSize)
    self.nameString:SetText(data.name)
    if self.mouseEntered then
        self.nameString:SetTextColor(self.color2:GetRGB())
        self.iconBorder:SetVertexColor(self.color2:GetRGB())
    else
        self.nameString:SetTextColor(self.color1:GetRGB())
        self.iconBorder:SetVertexColor(self.color1:GetRGB())
    end

    self.quantityString:SetText(S.Utils.FormatBigNumber(data.count))
    if data.count == data.maxQuantity then
        self.quantityString:SetTextColor(1, 0.15, 0.17, 1)
        self.maxQuantityString:SetTextColor(1, 0.15, 0.17, 0.7)
    else
        self.quantityString:SetTextColor(0.96, 0.9, 0.82, 1)
        self.maxQuantityString:SetTextColor(0.96, 0.9, 0.82, 0.6)
    end
    if data.maxQuantity > 0 then
        self.maxQuantityString:Show()
        self.maxQuantityString:SetText(S.Utils.FormatBigNumber(data.maxQuantity))
    else
        self.maxQuantityString:Hide()
    end

    if not self.list.gridView then
        self.categoryString:SetText(data.heading)

        if data.canEarnPerWeek then
            if data.quantityEarnedThisWeek == data.maxWeeklyQuantity then
                self.weeklyQuantityString:SetTextColor(1, 0.15, 0.17, 1)
                self.maxWeeklyQuantityString:SetTextColor(1, 0.15, 0.17, 0.7)
            else
                self.weeklyQuantityString:SetTextColor(0.96, 0.9, 0.82, 1)
                self.maxWeeklyQuantityString:SetTextColor(0.96, 0.9, 0.82, 0.6)
            end

            self.weeklyQuantityString:Show()
            self.weeklyQuantityString:SetText(S.Utils.FormatBigNumber(data.quantityEarnedThisWeek))
            self.maxWeeklyQuantityString:Show()
            self.maxWeeklyQuantityString:SetText(S.Utils.FormatBigNumber(data.maxWeeklyQuantity))
        else
            self.weeklyQuantityString:Hide()
            self.maxWeeklyQuantityString:Hide()
        end

        self.highlight:SetVertexColor(self.color1:GetRGB())
        self.button:GetPushedTexture():SetVertexColor(self.color1:GetRGB())
    end
end]]

local function ShowItemTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
end

local function GetData(self)
    -- Originally obtained data from S.GetData()
    -- The List now adds the data table as an attribute when sorting, so may as well use that instead
    return self.data --S.GetData().currencies[self.currencyID]
end

local function Button_OnEnter(self)
    local parent = self.parent
    S.Tooltip.Schedule(function()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        S.Tooltip.SetCurrency(parent.currencyID)
        GameTooltip:Show()

        if S.Settings.Get("tooltipInfo") == 1 then
            if not C_CurrencyInfo.IsAccountWideCurrency or not C_CurrencyInfo.IsAccountWideCurrency(parent.currencyID) then
                S.Tooltip.ExtendedCurrency(parent.data)
            end
        end
    end)
end
local function Button_OnLeave(self)
    S.Tooltip.Cancel()
end

local function GetFavorited(self)
    return S.Data.GetCurrencyFavorited(self:GetData())
end
local function ToggleFavorited(self)
    S.Data.ToggleCurrencyFavorited(self:GetData())
    S.Utils.TriggerEvent("FavoriteChanged")
end
local function SetFavorited(self, value)
    S.Data.ToggleCurrencyFavorited(self:GetData(), value)
    S.Utils.TriggerEvent("FavoriteChanged")
end
local function ClearFavorited(self, value)
    S.Data.UnfavoriteCurrency(self:GetData())
    S.Utils.TriggerEvent("FavoriteChanged")
end

function S.CreateCurrencyEntry(parent)
    local self = S.CreateListEntry(parent)
    self.UpdateSuper = self.Update
    self.Update = UpdateEntry
    self.GetData = GetData
    self.GetFavorited = GetFavorited
    self.ToggleFavorited = ToggleFavorited
    self.ClearFavorited = ClearFavorited
    self.SetFavorited = SetFavorited

    -- Create all elements from columns table
    for k, _ in pairs(self.list.columns) do
        self:AddColumn(k)
    end

    self.button:HookScript("OnEnter", Button_OnEnter)
    self.button:HookScript("OnLeave", Button_OnLeave)

    self:Show()

    return self
end