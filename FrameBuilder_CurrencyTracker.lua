local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local MAX_FRAME_WIDTH = 400

-- Create the primary Currency Tracker Frame
local ctf = CreateFrame("FRAME", nil, SortedPrimaryFrame)
SortedPrimaryFrame.currencyTrackerFrame = ctf
ctf:SetScript("OnMouseDown", function(self) end)
S.FrameTools.AddBorder(ctf, "border", "Interface\\Addons\\Sorted\\Textures\\Dropdown-Border", 12, 4, true)
ctf.border.parts[1]:Hide()
ctf.border.parts[2]:Hide()
ctf.border.parts[3]:Hide()
ctf.border.parts[4]:SetPoint("TOPLEFT", ctf.border, "TOPRIGHT", -12, 0)
ctf.border.parts[8]:SetPoint("TOPLEFT", -4, 0)
ctf.border.parts[9]:SetPoint("TOPLEFT", 12, 0)
ctf:SetPoint("TOPRIGHT", SortedPrimaryFrame, "BOTTOMRIGHT", -12, 0)
ctf:SetSize(100, 50)
ctf:SetFrameLevel(SortedPrimaryFrame:GetFrameLevel() - 40)

ctf.rows = {}
ctf.currencies = {}

local function UpdateCurrencyDisplay(self, id, texture, count)
    self.icon:SetTexture(texture)
    self.iconHighlight:SetTexture(texture)
    self.count:SetText(S.Utils.FormatBigNumber(count))
    self.id = id
    self:SetWidth(32 + self.count:GetStringWidth())
end
local function CurrencyOnEnter(self)
    S.Tooltip.Schedule(function()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        S.Tooltip.SetCurrency(self.id)
        GameTooltip:Show()
    end)
    self.count:SetAlpha(1)
    self.iconHighlight:Show()
end
local function CurrencyOnLeave(self)
    S.Tooltip.Cancel()
    self.count:SetAlpha(0.9)
    self.iconHighlight:Hide()
end
local function CreateCurrencyDisplay()
    local f = CreateFrame("FRAME", nil, ctf)
    f:SetFrameLevel(ctf:GetFrameLevel() + 20)
    f:SetSize(16, 16)
    f.icon = f:CreateTexture()
    f.icon:SetPoint("LEFT", 8, 0)
    f.icon:SetSize(16, 16)
    f.iconHighlight = f:CreateTexture()
    f.iconHighlight:SetPoint("LEFT", 8, 0)
    f.iconHighlight:SetSize(16, 16)
    f.iconHighlight:SetBlendMode("ADD")
    f.iconHighlight:Hide()
    f.count = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.count:SetPoint("LEFT", f.icon, "RIGHT", 2, 0)
    f.count:SetAlpha(0.9)
    f.Update = UpdateCurrencyDisplay
    f:SetScript("OnEnter", CurrencyOnEnter)
    f:SetScript("OnLeave", CurrencyOnLeave)
    ctf.currencies[#ctf.currencies + 1] = f
end

function ctf:Update()
    local prevFrame = nil
    local x = 0
    local index = 1
    for i = 1, #self.currencies do
        self.currencies[i]:Hide()
    end
    local trackedCurrencies = S.Data.GetTrackedCurrencies() -- Get ordered table of currency IDs
    if trackedCurrencies then
        for i, curID in ipairs(trackedCurrencies) do
            local curData = S.GetData().currencies[curID]
            
            if curData and curData.count > 0 then
                if not self.currencies[index] then
                    CreateCurrencyDisplay()
                end
                local f = self.currencies[index]
                f:Update(curData.id, curData.texture, curData.count)
                x = x + f:GetWidth()
                index = index + 1
            end
        end
    end
    if index == 1 then -- No currencies to show
        self:Hide()
    else
        -- Create the rows for the currencies
        for i, row in ipairs(self.rows) do
            row:Hide()
        end
        local numRows = math.ceil(x / MAX_FRAME_WIDTH)
        for row = 1, numRows do
            if not self.rows[row] then
                self.rows[row] = CreateFrame("FRAME", nil, self)
                self.rows[row]:SetPoint("TOP", 0, -4 - (row - 1) * 22)
                self.rows[row]:SetHeight(22)
            else
                self.rows[row]:Show()
            end
        end
        -- Position the currencies
        local row, rowX = 1, 0
        local x = x / numRows
        local width = 0
        for i = 1, index - 1 do
            local f = self.currencies[i]
            f:ClearAllPoints()
            f:SetPoint("LEFT", self.rows[row], "LEFT", rowX, 0)
            f:Show()
            rowX = rowX + f:GetWidth()
            self.rows[row]:SetWidth(rowX)
            if rowX > width then
                width = rowX
            end

            if rowX > x then
                -- New row
                row = row + 1
                rowX = 0
            end
        end


        self:Show()
        self:SetWidth(width + 4)
        self:SetHeight(numRows * 22 + 8)
    end
end
ctf:SetScript("OnShow", ctf.Update)
S.Utils.RunOnEvent(ctf, "CharacterSelected", ctf.Update)
S.Utils.RunOnEvent(ctf, "CurrencyTrackingChanged", ctf.Update)
S.Utils.RunOnEvent(ctf, "CurrenciesUpdated", ctf.Update)
S.Utils.RunOnEvent(ctf, "FontChanged", ctf.Update)