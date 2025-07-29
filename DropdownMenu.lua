local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

S.Dropdown = {}

local ENTRY_HEIGHT = 22
local HEADING_HEIGHT = 24
local MAX_HEIGHT = 500

-- Make a frame just below the dropdown menu that fills the screen
-- When clicked it hides the dropdown menu
-- Essentially adds GLOBAL_MOUSE_DOWN functionality to Classic
local screen = CreateFrame("FRAME", nil, UIParent)
screen:SetFrameStrata("DIALOG")
screen:SetFrameLevel(1)
screen:SetAllPoints()
screen:SetScript("OnMouseDown", function(self)
    SortedDropdownMenu:Hide()
    self:Hide()
end)
screen:Hide()

local dropdownMenu = CreateFrame("FRAME", "SortedDropdownMenu", UIParent)
S.dropdownMenu = dropdownMenu
table.insert(UISpecialFrames, "SortedDropdownMenu")
dropdownMenu:SetFrameStrata("DIALOG")
dropdownMenu:SetFrameLevel(10)
dropdownMenu:SetClampedToScreen(true)
dropdownMenu:SetScript("OnShow", function(self)
    screen:Show()
end)
dropdownMenu:SetScript("OnHide", function(self)
    screen:Hide()
end)

dropdownMenu.height = 0

function dropdownMenu:UpdateScale()
    dropdownMenu:SetScale(S.Settings.Get("scale"))
end
S.Utils.RunOnEvent(dropdownMenu, "SettingChanged-scale", dropdownMenu.UpdateScale)

dropdownMenu.scrollFrame = CreateFrame("SCROLLFRAME", nil, dropdownMenu)
dropdownMenu.scrollFrame:SetPoint("TOPLEFT")
dropdownMenu.scrollFrame:SetPoint("BOTTOM")
dropdownMenu.content = CreateFrame("FRAME", nil, dropdownMenu.scrollFrame)
dropdownMenu.scrollFrame:SetScrollChild(dropdownMenu.content)
dropdownMenu.scrollBar = CreateFrame("Slider", nil, dropdownMenu.scrollFrame, "MinimalScrollBarTemplate")
dropdownMenu.scrollBar.trackBG:Hide()
dropdownMenu.scrollBar:SetPoint("TOPLEFT", dropdownMenu.scrollFrame, "TOPRIGHT", 1, -18)
dropdownMenu.scrollBar:SetPoint("BOTTOM", 0, 16)
dropdownMenu.scrollBar:SetMinMaxValues(1, 1)
dropdownMenu.scrollBar:SetValueStep(1)
dropdownMenu.scrollBar.scrollStep = 16
dropdownMenu.scrollBar:SetValue(0)

local inset = 6
local outset = 4
dropdownMenu.bg = dropdownMenu:CreateTexture()
dropdownMenu.bg:SetPoint("TOPLEFT", inset, -inset)
dropdownMenu.bg:SetPoint("BOTTOMRIGHT", -inset, inset)
dropdownMenu.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Border")
dropdownMenu.bg:SetTexCoord(0.49,0.5,0.49,0.5)
--dropdownMenu.bg:SetColorTexture(0.04, 0.034, 0.035, 0.95)

S.FrameTools.AddBorder(dropdownMenu, "border", "Interface\\Addons\\Sorted\\Textures\\Dropdown-Border", inset, outset)
dropdownMenu.border:SetFrameLevel(dropdownMenu:GetFrameLevel() - 1)
--[[for k,v in pairs(dropdownMenu.border.parts) do
    v:SetVertexColor(S.Utils.GetButtonTextColor())
end]]

-- Original border, with textures rather than solid colour
--[[dropdownMenu.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Abstract", "REPEAT", "REPEAT")
dropdownMenu.bg:SetHorizTile(true)
dropdownMenu.bg:SetVertTile(true)
dropdownMenu.bg:SetAllPoints()
dropdownMenu:EnableMouse()
dropdownMenu:SetScript("OnEnter", function(self) end)

S.FrameTools.AddBorder(dropdownMenu, "border", "Interface\\Addons\\Sorted\\Textures\\Dropdown-Border", 10, 8)
S.FrameTools.AddInnerShadow(dropdownMenu, 16)
dropdownMenu.border:SetFrameLevel(dropdownMenu:GetFrameLevel() + 15)
S.Utils.RunOnEvent(dropdownMenu, "SettingChanged-backdrop", function(self, event, setting, value)
    if setting == "backdrop" then
        self.bg:SetTexture(S.Utils.GetBackgroundPath(value))
    elseif setting == "backdropColor" then
        self.bg:SetVertexColor(unpack(value))
    end
end)]]

local function EntryOnEnter(self)
    self:GetHighlightTexture():Show()
    self.text:SetTextColor(self.textHighlightColor:GetRGB())
    self.deleteButton:GetNormalTexture():SetTexCoord(0, 0.375, 0, 0.375)
end
local function EntryOnLeave(self)
    self:GetHighlightTexture():Hide()
    self.text:SetTextColor(self.textColor:GetRGB())
    self.deleteButton:GetNormalTexture():SetTexCoord(0, 0.375, 0.375, 0.75)
end
local function EntryOnMouseWheel(self, delta)
    dropdownMenu.scrollBar:SetValue(dropdownMenu.scrollBar:GetValue() - delta * 50)
end

dropdownMenu.entries = {}
local function CreateEntry()
    local index = #dropdownMenu.entries + 1
    local self = CreateFrame("BUTTON", nil, dropdownMenu.content)
    self:SetPoint("LEFT")
    self:SetPoint("RIGHT")
    if index == 1 then
        self:SetPoint("TOP", 0, -6)
    else
        self:SetPoint("TOP", dropdownMenu.entries[index - 1], "BOTTOM")
    end
    self:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Highlight")
    self:GetHighlightTexture():SetVertexColor(0.9, 0.7, 0.04)
    self:GetHighlightTexture():SetDrawLayer("ARTWORK")
    self:GetHighlightTexture():Hide()
    self:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Highlight")
    self:GetPushedTexture():SetVertexColor(0.9, 0.7, 0.04, 0.5)
    self:GetPushedTexture():SetBlendMode("ADD")
    self.text = self:CreateFontString(nil, "OVERLAY", "SortedFont")
    self.text:SetPoint("LEFT", 8, 0)
    self.rightText = self:CreateFontString(nil, "OVERLAY", "SortedFont")
    self.rightText:SetPoint("RIGHT", -8, 0)
    self.deleteButton = CreateFrame("BUTTON", nil, self)
    self.deleteButton:SetSize(22, 22)
    self.deleteButton:SetPoint("RIGHT", -2, 0)
    self.deleteButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Close-Button")
    self.deleteButton:GetNormalTexture():SetTexCoord(0, 0.375, 0.375, 0.75)
    self.deleteButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Close-Button-Highlight")
    self.deleteButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Close-Button")
    self.deleteButton:GetPushedTexture():SetTexCoord(0.375, 0.75, 0, 0.375)
    self.deleteButton:SetScript("OnEnter", function(self)
        S.Tooltip.CreateLocalized(self, "ANCHOR_RIGHT", self.tooltip, S.GetData(self.data1).name)
        self:GetNormalTexture():SetTexCoord(0, 0.375, 0, 0.375)
    end)
    self.deleteButton:SetScript("OnLeave", function(self)
        S.Tooltip.Cancel()
        if not self:GetParent():IsMouseOver() then
            self:GetNormalTexture():SetTexCoord(0, 0.375, 0.375, 0.75)
        end
    end)

    self.checkboxTexture = self:CreateTexture(nil, "OVERLAY")
    self.checkboxTexture:SetTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Tick")
    self.checkboxTexture:SetPoint("LEFT", 4, 0)
    self.checkboxTexture:SetSize(18, 18)
    self.radioButtonTexture = self:CreateTexture(nil, "OVERLAY")
    self.radioButtonTexture:SetTexture("Interface\\Addons\\Sorted\\Textures\\Radio-Button-Dot")
    self.radioButtonTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.radioButtonTexture:SetPoint("LEFT", 4, 0)
    self.radioButtonTexture:SetSize(18, 18)
    function self:SetChecked(checked)
        self.checked = checked
        if self.hasCheckbox then
            if checked then
                self.checkboxTexture:SetTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Tick")
            else
                self.checkboxTexture:SetTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Cross")
            end
        end
        if self.hasRadioButton then
            self.radioButtonTexture:SetShown(checked)
        end
    end

    self:SetScript("OnEnter", EntryOnEnter)
    self:SetScript("OnLeave", EntryOnLeave)
    self:SetScript("OnClick", function(self)
        if self.hasCheckbox then
            self:SetChecked(not self.checked)
        elseif self.hasRadioButton then
            if not self.checked or not self.disableTogglingOff then
                self:SetChecked(not self.checked)
                for k,v in pairs(dropdownMenu.entries) do
                    if v.hasRadioButton and v ~= self then
                        v:SetChecked(false)
                    end
                end
            end
        else
            dropdownMenu:Hide()
        end
        self.OnClick(self)
    end)
    self:SetScript("OnMouseWheel", EntryOnMouseWheel)
    dropdownMenu.entries[index] = self
    return self
end


local currentEntryIndex = 1
function S.Dropdown.Reset()
    dropdownMenu.scrollPositionBeforeReset = dropdownMenu.scrollBar:GetValue()
    currentEntryIndex = 1
    dropdownMenu.height = 0
    for i, v in ipairs(dropdownMenu.entries) do
        v:Hide()
    end
end

function S.Dropdown.AddEntry(text, OnClick, data1, data2, color)
    if not dropdownMenu.entries[currentEntryIndex] then
        CreateEntry()
    end
    local entry = dropdownMenu.entries[currentEntryIndex]
    local size = S.Settings.Get("fontSizePts")
    entry:Show()
    if currentEntryIndex == 1 then
        entry:SetPoint("TOP", 0, -6)
    end
    entry:SetHeight(size * 1.66)
    dropdownMenu.height = dropdownMenu.height + size * 1.66
    entry:SetScript("OnEnter", EntryOnEnter)
    entry:SetScript("OnLeave", EntryOnLeave)
    entry.text:ClearAllPoints()
    entry.text:SetPoint("LEFT", 8, 0)
    entry.text:SetFont(S.Utils.GetFontPath(S.Settings.Get("font")), size)
    entry.rightText:SetText("")
    entry.rightText:SetPoint("RIGHT", -8, 0)
    entry.deleteButton:Hide()
    entry.hasCheckbox = false
    entry.checkboxTexture:SetSize(size * 1.5, size * 1.5)
    entry.checkboxTexture:Hide()
    entry.hasRadioButton = false
    entry.checked = false
    entry.radioButtonTexture:SetSize(size * 1.5, size * 1.5)
    entry.radioButtonTexture:Hide()
    entry.text:SetText(text)
    entry.data1 = data1
    entry.data2 = data2
    if not OnClick then
        entry:Disable()
    else
        entry:Enable()
        entry.OnClick = OnClick
    end
    if color then
        entry:GetHighlightTexture():SetVertexColor(color:GetRGB())
        entry:GetPushedTexture():SetVertexColor(color:GetRGB())
        entry.text:SetTextColor(color:GetRGB())
        entry.textColor = color
    else
        entry:GetHighlightTexture():SetVertexColor(0.9, 0.7, 0.04)
        entry:GetPushedTexture():SetVertexColor(0.9, 0.7, 0.04)
        entry.text:SetTextColor(1, 1, 1)
        entry.textColor = CreateColor(1, 1, 1)
    end
    entry.textHighlightColor = CreateColor(entry.textColor.r + 0.4, entry.textColor.g + 0.4, entry.textColor.b + 0.4)
    currentEntryIndex = currentEntryIndex + 1
end
function S.Dropdown.AddRightText(text)
    local entry = dropdownMenu.entries[currentEntryIndex - 1]
    entry.rightText:SetText(text)
end
function S.Dropdown.AddDeleteButton(OnClick, data1, data2, tooltip)
    local entry = dropdownMenu.entries[currentEntryIndex - 1]
    entry.rightText:SetPoint("RIGHT", -24, 0)
    entry.deleteButton:Show()
    entry.deleteButton.data1 = data1
    entry.deleteButton.data2 = data2
    entry.deleteButton:SetScript("OnClick", OnClick)
    entry.deleteButton.tooltip = tooltip
end
function S.Dropdown.AddCheckbox(checked)
    local entry = dropdownMenu.entries[currentEntryIndex - 1]
    S.Dropdown.Indent()
    entry.hasCheckbox = true
    entry.checkboxTexture:Show()
    entry:SetChecked(checked)
end
function S.Dropdown.AddRadioButton(checked, disableTogglingOff)
    local entry = dropdownMenu.entries[currentEntryIndex - 1]
    S.Dropdown.Indent()
    entry.hasRadioButton = true
    entry.checked = checked
    entry.disableTogglingOff = disableTogglingOff
    entry.radioButtonTexture:SetShown(checked)
end
function S.Dropdown.Indent()
    local size = S.Settings.Get("fontSizePts")
    local entry = dropdownMenu.entries[currentEntryIndex - 1]
    entry.text:SetPoint("LEFT", size * 1.66 + 4, 0)
    entry.isIndented = true
end
function S.Dropdown.RestoreScrollPosition()
    dropdownMenu.scrollBar:SetValue(dropdownMenu.scrollPositionBeforeReset)
end
function S.Dropdown.SetFont(font)
    local entry = dropdownMenu.entries[currentEntryIndex - 1]
    entry.text:SetFont(S.Utils.GetFontPath(font), S.Settings.Get("fontSizePts"))
end
function S.Dropdown.SetHeading()
    local size = S.Settings.Get("fontSizePts")
    local entry = dropdownMenu.entries[currentEntryIndex - 1]
    entry:SetHeight(size * 2)
    if currentEntryIndex - 1 == 1 then
        entry:SetPoint("TOP", 0, 0)
        dropdownMenu.height = dropdownMenu.height - 6
    end
    dropdownMenu.height = dropdownMenu.height + size * 2 - size * 1.66
    entry.text:ClearAllPoints()
    entry.text:SetPoint("BOTTOM", 0, 2)
    entry.text:SetFont(S.Utils.GetFontPath(S.Settings.Get("font")), size * 1.1)
end
function S.Dropdown.OnEnter(func)
    local entry = dropdownMenu.entries[currentEntryIndex - 1]
    entry:HookScript("OnEnter", func)
end
function S.Dropdown.OnLeave(func)
    local entry = dropdownMenu.entries[currentEntryIndex - 1]
    entry:HookScript("OnLeave", func)
end


function S.Dropdown.Show(parent, anchor, anchorTo, offsetX, offsetY)
    local size = S.Settings.Get("fontSizePts")
    dropdownMenu:ClearAllPoints()
    dropdownMenu:SetPoint(anchor, parent, anchorTo, offsetX, offsetY)
    dropdownMenu:SetFrameStrata("DIALOG")
    dropdownMenu:SetHeight(dropdownMenu.height + 12)
    dropdownMenu.content:SetHeight(dropdownMenu.height + 12)
    local scrollBarShown = false
    if dropdownMenu:GetHeight() > MAX_HEIGHT then
        dropdownMenu.scrollBar:Show()
        dropdownMenu.scrollBar:SetMinMaxValues(0, dropdownMenu:GetHeight() - MAX_HEIGHT)
        dropdownMenu.scrollBar:SetValue(0)
        dropdownMenu:SetHeight(MAX_HEIGHT)
        scrollBarShown = true
    else
        dropdownMenu.scrollBar:SetMinMaxValues(0, 0)
        dropdownMenu.scrollBar:Hide()
    end
    local width = 0
    for i = 1,currentEntryIndex - 1 do
        local entry = dropdownMenu.entries[i]
        local entryWidth = entry.text:GetStringWidth() + entry.rightText:GetStringWidth()
        if entry.deleteButton:IsShown() then
            entryWidth = entryWidth + 24
        end
        if entry.isIndented then
            entryWidth = entryWidth + size * 1.66 + 4
        end
        if entryWidth > width then
            width = entryWidth
        end
    end
    width = width + 24
    dropdownMenu.scrollFrame:SetWidth(width)
    dropdownMenu.content:SetWidth(width)
    if scrollBarShown then
        width = width + 24
    end
    dropdownMenu:SetWidth(width)
    dropdownMenu:Show()
    --dropdownMenu.shown = true
end
function S.Dropdown.IsShown()
    return dropdownMenu:IsShown()
    --return dropdownMenu.shown
end
function S.Dropdown.Hide()
    dropdownMenu:Hide()
end
--[[dropdownMenu:SetScript("OnHide", function(self)
    -- Set result of IsShown() to false on the next frame 
    -- This prevents GLOBAL_MOUSE_DOWN from hiding the dropdown menu on the same frame as something else toggles it, making it always toggle back to shown
    C_Timer.After(0.0001, function()
        self.shown = false
    end)
end)]]
S.primaryFrame:HookScript("OnHide", function(self)
    dropdownMenu:Hide()
end)


-- Hide when user clicks outside of the dropdown menu. (Now done with a fullscreen frame for compatibility with Classic)
--[[if S.WoWVersion() >= 3 then
    dropdownMenu:RegisterEvent("GLOBAL_MOUSE_DOWN")
    dropdownMenu:SetScript("OnEvent", function(self, event)
        if S.Dropdown.IsShown() and event == "GLOBAL_MOUSE_DOWN" then
            if not self:IsMouseOver() then
                S.Dropdown.Hide()
            end
        end
    end)
end]]

S.Dropdown.Reset()


dropdownMenu:Hide()