local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local TOOLTIP_DELAY = 0.075
local TOOLTIP_DELAY_UPDATES = 0.2

S.Tooltip = {}
local extraTooltip = CreateFrame("GameTooltip", "SortedExtendedTooltip", GameTooltip, "GameTooltipTemplate")



local i = 0
local currentlyShownIndex = 0
local lastTime, lastUpdateTime = GetTime(), GetTime()

-- For performance, limits the rate that tooltips are displayed.
-- If enough time has passed since the last tooltip, the tooltip is displayed instantly. Otherwise, it's shown after a delay, unless another tooltip is scheduled in that time.
-- 'func' is the function which sets up the GameTooltip
-- 'self' is passed to the function
-- 'update' is set to true for item button updates. It prevents lastTime from resetting when the button updates, which would prevent the next tooltip from showing instantly
function S.Tooltip.Schedule(func, self, update)
    --local tooltipDelay = S.Settings.Get("tooltipDelay")
    local tooltipDelay = TOOLTIP_DELAY
    if update then
        tooltipDelay = TOOLTIP_DELAY_UPDATES
    end
    local time = GetTime()
    i = i + 1

    local lastTooltipTime
    if update then
        lastTooltipTime = lastUpdateTime
    else
        lastTooltipTime = lastTime
    end
    if lastTooltipTime < time - tooltipDelay then
        func(self)
    else
        local id = i
        local delay = tooltipDelay - (time - lastTime)
        if delay < 0 then
            delay = 0
        end
        C_Timer.After(delay, function()
            if i == id then
                func(self)

                lastUpdateTime = time
                if not update then
                    lastTime = lastUpdateTime
                end
            end
        end)
    end
    lastUpdateTime = time
    if not update then
        lastTime = lastUpdateTime
    end
end
-- Hides the tooltip after a delay, unless a tooltip is shown first
-- Currently broken. Use S.Tooltip.Cancel() instead
function S.Tooltip.ScheduledCancel()
    local tooltipDelay = TOOLTIP_DELAY
    local id = currentlyShownIndex
    C_Timer.After(tooltipDelay, function()
        if id == currentlyShownIndex then
            GameTooltip:Hide()
            extraTooltip:Hide()
            if S.WoWVersion() >= 5 then
                BattlePetTooltip:Hide()
            end
        end
    end)
end
-- Hides the tooltip and interrupts any scheduled tooltip
function S.Tooltip.Cancel()
    GameTooltip:Hide()
    extraTooltip:Hide()
    if S.WoWVersion() >= 5 then
        BattlePetTooltip:Hide()
    end
    i = i + 1
end


local function Create()
    GameTooltip:SetOwner(S.Tooltip.parent, S.Tooltip.anchor)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(S.Tooltip.text)
    GameTooltip:Show()
end
function S.Tooltip.CreateText(parent, anchor, text)
    S.Tooltip.parent = parent
    S.Tooltip.anchor = anchor
    S.Tooltip.text = text
    S.Tooltip.Schedule(Create)
end
function S.Tooltip.CreateLocalized(parent, anchor, key, arg1, arg2, arg3)
    S.Tooltip.CreateText(parent, anchor, S.Localize(key, arg1, arg2, arg3))
end


-- Sets GameTooltip to a currency. Works in Classic and Retail
function S.Tooltip.SetCurrency(currencyID)
    if GameTooltip.SetCurrencyByID then
        GameTooltip:SetCurrencyByID(currencyID)
    -- Classic Honor and Arena Points tooltips are handled differently
    elseif ( currencyID == Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID ) then
        GameTooltip:SetText(HONOR_POINTS, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
        GameTooltip:AddLine(TOOLTIP_HONOR_POINTS, nil, nil, nil, 1);
        GameTooltip:Show();
    elseif ( currencyID == Constants.CurrencyConsts.CLASSIC_ARENA_POINTS_CURRENCY_ID ) then
            GameTooltip:SetText(ARENA_POINTS, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
            GameTooltip:AddLine(TOOLTIP_ARENA_POINTS, nil, nil, nil, 1);
            GameTooltip:Show();
    elseif GameTooltip.SetCurrencyToken then
        GameTooltip:SetCurrencyToken(currencyID)
    end
end



extraTooltip:SetClampedToScreen(false)

local extraTooltipLines = {}
extraTooltip.logo = extraTooltip:CreateTexture("")
extraTooltip.logo:SetTexture("Interface\\Addons\\Sorted\\Textures\\Portrait-Text")
extraTooltip.logo:SetTexCoord(0, 1, 0.25, 0.75)
extraTooltip.logo:SetPoint("TOPLEFT", 10, -6)
extraTooltip.logo:SetSize(64, 32)
extraTooltip.bagIcon = extraTooltip:CreateTexture("")
extraTooltip.bagIcon:SetTexture("Interface\\Addons\\Sorted\\Textures\\Tooltip-Icons")
extraTooltip.bagIcon:SetTexCoord(0, 0.25, 0, 1)
extraTooltip.bagIcon:SetPoint("TOPRIGHT", -116, -12)
extraTooltip.bagIcon:SetSize(20, 20)
extraTooltip.bankIcon = extraTooltip:CreateTexture("")
extraTooltip.bankIcon:SetTexture("Interface\\Addons\\Sorted\\Textures\\Tooltip-Icons")
extraTooltip.bankIcon:SetTexCoord(0.25, 0.5, 0, 1)
extraTooltip.bankIcon:SetPoint("TOPRIGHT", -68, -12)
extraTooltip.bankIcon:SetSize(20, 20)
extraTooltip.reagentIcon = extraTooltip:CreateTexture("")
extraTooltip.reagentIcon:SetTexture("Interface\\Addons\\Sorted\\Textures\\Tooltip-Icons")
extraTooltip.reagentIcon:SetTexCoord(0.5, 0.75, 0, 1)
extraTooltip.reagentIcon:SetPoint("TOPRIGHT", -20, -12)
extraTooltip.reagentIcon:SetSize(20, 20)
local function GetLine(index)
    if extraTooltipLines[index] then return extraTooltipLines[index] end
    local line = {}
    line.nameString = extraTooltip:CreateFontString(nil)
    line.nameString:SetFontObject("SortedFont")
    line.nameString:SetPoint("LEFT", extraTooltip, "TOPLEFT", 8, -index * 22 - 22)
    line.bagString = extraTooltip:CreateFontString(nil)
    line.bagString:SetFontObject("SortedFont")
    line.bagString:SetPoint("CENTER", extraTooltip.bagIcon, "CENTER", 0, -index * 22)
    line.bankString = extraTooltip:CreateFontString(nil)
    line.bankString:SetFontObject("SortedFont")
    line.bankString:SetPoint("CENTER", extraTooltip.bankIcon, "CENTER", 0, -index * 22)
    line.reagentString = extraTooltip:CreateFontString(nil)
    line.reagentString:SetFontObject("SortedFont")
    line.reagentString:SetPoint("CENTER", extraTooltip.reagentIcon, "CENTER", 0, -index * 22)
    extraTooltipLines[index] = line
    return extraTooltipLines[index]
end

local textColor = {["r"] = 1, ["g"] = 1, ["b"] = 1}
local grayedTextColor = {["r"] = 0.6, ["g"] = 0.61, ["b"] = 0.65}
local extendedTooltipID = 0
local function QueryItemCounts(i, itemID, GUIDs, tooltipID)
    if tooltipID ~= extendedTooltipID then
        return
    end
    local GUID = GUIDs[1]
    local data = Sorted_Data[GUID]
    local bagCount = 0
    for _, bag in pairs(S.Utils.ContainersOfType(S.CONTAINER_TYPES.BAGS)) do
        for _, itemData in pairs(data.containers[bag]) do
            if itemData.itemID == itemID and itemData.count then
                bagCount = bagCount + itemData.count
            end
        end
    end

    local bankCount = 0
    for _, bag in pairs(S.Utils.ContainersOfType(S.CONTAINER_TYPES.BANK)) do
        for _, itemData in pairs(data.containers[bag]) do
            if itemData.itemID == itemID and itemData.count then
                bagCount = bagCount + itemData.count
            end
        end
    end

    local reagentCount = 0
    if S.WoWVersion() >= 6 and not S.UseNewBank() then
        for _, itemData in pairs(data.containers[REAGENTBANK_CONTAINER]) do
            if itemData.itemID == itemID and itemData.count then
                bagCount = bagCount + itemData.count
            end
        end
    end

    if bagCount > 0 or bankCount > 0 or reagentCount > 0 then
        i = i + 1
        extraTooltip:SetHeight(i * 22 + 40)
        local line = GetLine(i)
        line.nameString:SetText(S.Utils.FormatFaction(data.faction)..S.Utils.GetClassHexColor(data.class)..data.name)
        line.bagString:SetText(S.Utils.FormatNumber(bagCount))
        if bagCount > 0 then line.bagString:SetTextColor(textColor.r, textColor.g, textColor.b) else line.bagString:SetTextColor(grayedTextColor.r, grayedTextColor.g, grayedTextColor.b) end
        line.bankString:SetText(S.Utils.FormatNumber(bankCount))
        if bankCount > 0 then line.bankString:SetTextColor(textColor.r, textColor.g, textColor.b) else line.bankString:SetTextColor(grayedTextColor.r, grayedTextColor.g, grayedTextColor.b) end
        line.nameString:Show()
        line.bagString:Show()
        line.bankString:Show()
        if S.WoWVersion() >= 6 then
            line.reagentString:SetText(S.Utils.FormatNumber(reagentCount))
            if reagentCount > 0 then line.reagentString:SetTextColor(textColor.r, textColor.g, textColor.b) else line.reagentString:SetTextColor(grayedTextColor.r, grayedTextColor.g, grayedTextColor.b) end
            line.reagentString:Show()
        end
        --[[local left = Sorted_FormatFaction(data.faction)..Sorted_GetClassColor(data.class):GenerateHexColorMarkup()..data.name
        local right
        local bagColor, bankColor, reagentColor
        if bagCount > 0 then bagColor = textColor else bagColor = grayedTextColor end
        if bankCount > 0 then bankColor = textColor else bankColor = grayedTextColor end
        if not Sorted_IsClassic() then
            if reagentCount > 0 then reagentColor = textColor else reagentColor = grayedTextColor end
            right = string.format("%s%6d |TInterface\\Addons\\Sorted\\Textures\\Tooltip-Icons:20:20:0:0:128:32:0:32:0:32|t %s%6d |TInterface\\Addons\\Sorted\\Textures\\Tooltip-Icons:20:20:0:0:128:32:32:64:0:32|t %s%6d |TInterface\\Addons\\Sorted\\Textures\\Tooltip-Icons:20:20:0:0:128:32:64:96:0:32|t", bagColor, bagCount, bankColor, bankCount, reagentColor, reagentCount)
        else
            right = string.format("%s%6d |TInterface\\Addons\\Sorted\\Textures\\Tooltip-Icons:20:20:0:0:128:32:0:32:0:32|t %s%6d |TInterface\\Addons\\Sorted\\Textures\\Tooltip-Icons:20:20:0:0:128:32:32:64:0:32|t", bagColor, bagCount, bankColor, bankCount)
        end
        extraTooltip:AddDoubleLine(left, right)]]
    end
    table.remove(GUIDs, 1)
    if #GUIDs > 0 then
        if #GUIDs % 3 == 0 then  -- Spread the processing over multiple frames, otherwise it can be slow with many characters. This checks three characters per frame
            C_Timer.After(0.0001, function() QueryItemCounts(i, itemID, GUIDs, tooltipID) end)
        else
            QueryItemCounts(i, itemID, GUIDs, tooltipID)
        end
    end
end
function S.Tooltip.Extended(bag, slot)
    local self = S.Data.GetItem(bag, slot)
    local i = 0
    if self.classID == LE_ITEM_CLASS_BATTLEPET then return end

    extraTooltip.reagentIcon:SetTexture("Interface\\Addons\\Sorted\\Textures\\Tooltip-Icons")
    extraTooltip.reagentIcon:SetTexCoord(0.5, 0.75, 0, 1)
    extraTooltip.bagIcon:Show()
    extraTooltip.bankIcon:Show()
    extraTooltip.reagentIcon:Show()

    -- Add Sorted's tooltip info
    extraTooltip:SetOwner(GameTooltip, "ANCHOR_BOTTOM")
    extraTooltip:ClearLines()
    --extraTooltip:AddLine("|TInterface\\Addons\\Sorted\\Textures\\Title:24:96:-6:4|t")
    extraTooltip:AddLine(" ")
    for _, line in pairs(extraTooltipLines) do
        line.nameString:Hide()
        line.bagString:Hide()
        line.bankString:Hide()
        line.reagentString:Hide()
    end
    extraTooltip:Show()
    extraTooltip:SetHeight(30)
    extraTooltip:SetPoint("LEFT", GameTooltip, "RIGHT", -288, 0)
    extraTooltip:SetPoint("RIGHT", GameTooltip)

    local GUIDs = {UnitGUID("player")}
    for GUID, data in pairs(Sorted_Data) do
        if data.realm == GetRealmName() and GUID ~= UnitGUID("player") then
            table.insert(GUIDs, GUID)
        end
    end
    extendedTooltipID = extendedTooltipID + 1
    C_Timer.After(0.0001, function() QueryItemCounts(i, self.itemID, GUIDs, extendedTooltipID) end)
end

function S.Tooltip.ExtendedCurrency(currency)
    extendedTooltipID = extendedTooltipID + 1

    extraTooltip.bagIcon:Hide()
    extraTooltip.bankIcon:Hide()
    extraTooltip.reagentIcon:SetTexture(currency.texture)
    extraTooltip.reagentIcon:SetTexCoord(0, 1, 0, 1)
    extraTooltip.reagentIcon:Show()

    -- Add Sorted's tooltip info
    extraTooltip:SetOwner(GameTooltip, "ANCHOR_BOTTOM")
    extraTooltip:ClearLines()
    --extraTooltip:AddLine("|TInterface\\Addons\\Sorted\\Textures\\Title:24:96:-6:4|t")
    extraTooltip:AddLine(" ")
    for _, line in pairs(extraTooltipLines) do
        line.nameString:Hide()
        line.bagString:Hide()
        line.bankString:Hide()
        line.reagentString:Hide()
    end
    local t = {}
    local max = 0
    for GUID, data in pairs(Sorted_Data) do
        if data.realm == GetRealmName() then
            if data.currencies[currency.id] then
                local count = data.currencies[currency.id].count
                if count > max then
                    max = count
                end
                table.insert(t, {data, count})
            end
        end
    end
    table.sort(t, function(a, b) return a[2] > b[2] end)
    for i = 1, #t do
        local line = GetLine(i)
        local data = t[i][1]
        line.nameString:SetText(S.Utils.FormatFaction(data.faction)..S.Utils.GetClassHexColor(data.class)..data.name)
        line.reagentString:SetText(S.Utils.FormatNumber(t[i][2]))
        line.nameString:Show()
        line.reagentString:Show()
        local color = (t[i][2] / max) * 0.5 + 0.5
        line.reagentString:SetTextColor(
            textColor.r * color + grayedTextColor.r * (1 - color), 
            textColor.g * color + grayedTextColor.g * (1 - color), 
            textColor.b * color + grayedTextColor.b * (1 - color)
        )
    end

    extraTooltip:Show()
    local width = GameTooltip:GetWidth()
    if width < 256 then
        GameTooltip:SetWidth(256)
        width = 256
    end
    extraTooltip:SetPoint("LEFT", GameTooltip, "RIGHT", -200, 0)
    extraTooltip:SetPoint("RIGHT", GameTooltip)
    extraTooltip:SetHeight(#t * 22 + 40)
end

GameTooltip:HookScript("OnShow", function(self) extraTooltip:Hide() end)