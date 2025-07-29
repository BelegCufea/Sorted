local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local IsUsableSpell = IsUsableSpell
if C_Spell then
    if C_Spell.IsSpellUsable then
        IsUsableSpell = C_Spell.IsSpellUsable
    end
end
local GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem = GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem
if C_Item then
    GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem = C_Item.GetItemInfoInstant, C_Item.GetItemInfo, C_Item.GetItemClassInfo, C_Item.GetItemSubClassInfo, C_Item.GetDetailedItemLevelInfo, C_Item.IsEquippableItem
end

S.itemLists = {}
local MIN_HEIGHT = 400

-- Create the primary frame, and give it a global name to allow its position and size to be saved between sessions
local f = CreateFrame("FRAME", "SortedPrimaryFrame", UIParent)
table.insert(UISpecialFrames, "SortedPrimaryFrame")
S.primaryFrame = f
f:SetPoint("BOTTOMRIGHT", -64, 128)
f:SetSize(800, 600)
f:SetClampedToScreen(true)
f:EnableMouse()
f:SetResizable(true)
f:SetMovable(true)
f:SetDontSavePosition(true)
function f:SavePosition()
    local points = {}
    for i = 1, f:GetNumPoints() do
        local point, relativeTo, relativePoint, offsetX, offsetY = f:GetPoint(i)
        points[i] = {point, relativeTo, relativePoint, offsetX, offsetY}
    end
    S.Settings.Set("windowPosition", {points, {f:GetWidth(), f:GetHeight()}})
end
function f:RestorePosition()
    self:ClearAllPoints()
    local position = S.Settings.Get("windowPosition")
    if position and position[1] and #position[1] > 0 then
        for k, point in pairs(position[1]) do
            self:SetPoint(point[1], point[2], point[3], point[4], point[5])
        end
        local width, height = position[2][1], position[2][2]
        local minWidth, minHeight = self:GetResizeBounds()
        if width < 0 then width = 800 elseif width < minWidth then width = minWidth end
        if height < 0 then height = 600 elseif height < minHeight then height = minHeight end
        self:SetSize(width, height)
    else
        self:SetPoint("BOTTOMRIGHT", -64, 128)
        self:SetSize(800, 600)
    end
end
S.Utils.RunOnEvent(f, "SettingChanged-windowPosition", f.RestorePosition)
S.Utils.RunOnEvent(f, "ProfileChanged", f.RestorePosition)
f:SetFrameStrata("HIGH")
f:SetFrameLevel(572)
S.FrameTools.AddMetalBorder(f)
S.FrameTools.AddOuterShadow(f, 100)
S.FrameTools.AddSortedBackdrop(f)
f:Hide()
f:SetScript("OnMouseDown", function(self) end) -- Prevent click-through
function f:UpdateMinSize()
    local minWidth = S.primaryItemList:GetMinWidth()
    if self.SetMinResize then
        self:SetMinResize(minWidth, MIN_HEIGHT)
    elseif self.SetResizeBounds then
        self:SetResizeBounds(minWidth, MIN_HEIGHT)
    end
    if self:GetWidth() < minWidth then
        self:SetWidth(minWidth)
    end
end
S.Utils.RunOnEvent(f, "EnteredWorld", f.UpdateMinSize)
S.Utils.RunOnEvent(f, "EnteredWorld", f.RestorePosition)
S.Utils.RunOnEvent(f, "MinSizeChanged", f.UpdateMinSize)

f:SetScript("OnSizeChanged", function(self)
    S.Utils.TriggerEvent("Resizing")
end)
S.Utils.RunOnEvent(f, "SettingChanged-scale", function(self, event, value)
    self:SetScale(value)
end)

f.closeButton = S.FrameTools.CreateCloseButton(f)
f.closeButton:SetFrameLevel(600)

--[[function f:SetMinimised(minimised)
    if minimised then
        self.minimised = true
        self.searchBox:SetText("")
        self.searchBox:Hide()
        self.categoriesFrame:Hide()
        self.head:SetPoint("BOTTOM", self, "TOP", 0, -24)
        f.main:SetPoint("BOTTOMRIGHT")
        self.foot:Hide()
        --self.main:SetPoint("BOTTOMRIGHT")
        self.minimiseButton:GetNormalTexture():SetTexCoord(0, 0.1484375, 0, 0.3125)
        self.minimiseButton:GetHighlightTexture():SetTexCoord(0.59375, 0.7421875, 0, 0.3125)
        self.minimiseButton:GetPushedTexture():SetTexCoord(0, 0.1484375, 0.625, 0.9375)
        S.primaryItemList.scrollBar:SetPoint("BOTTOM", 0, 18 + 20)
    else
        self.minimised = false
        self.searchBox:Show()
        self.categoriesFrame:Show()
        if S.Skinning.GetSkin() == S.Skinning.CLEAN then
            self.head:SetPoint("BOTTOM", f, "TOP", 0, -52)
        else
            self.head:SetPoint("BOTTOM", f, "TOP", 0, -60)
        end
        self.categoriesFrame:UpdatePosition()
        self.foot:Show()
        --self.main:SetPoint("BOTTOMRIGHT", self.foot, "TOPRIGHT")
        self.minimiseButton:GetNormalTexture():SetTexCoord(0.1484375 * 2, 0.1484375 * 3, 0, 0.3125)
        self.minimiseButton:GetHighlightTexture():SetTexCoord(0.59375, 0.7421875, 0, 0.3125)
        self.minimiseButton:GetPushedTexture():SetTexCoord(0.1484375 * 2, 0.1484375 * 3, 0.625, 0.9375)
        
        S.primaryItemList.scrollBar:SetPoint("BOTTOM", 0, 18)
    end
    S.primaryItemList:SetMinimised(minimised)
    if S.WoWVersion() > 1 then
        S.CurrencyList:SetMinimised(minimised)
    end
    S.BankItemList:SetMinimised(minimised)
    if S.WoWVersion() >= 6 then
        S.ReagentItemList:SetMinimised(minimised)
    elseif S.WoWVersion() <= 3 then
        S.KeyringItemList:SetMinimised(minimised)
    end
    S.Utils.TriggerEvent("Resized")
end
function f:ToggleMinimised()
    self:SetMinimised(not self.minimised)
    f.minimiseButton:Update()
end
function f:GetMinimised()
    return self.minimised
end]]

f.minimised = false
--[[local texSizeX, texSizeY = 0.296875, 0.3125
f.minimiseButton = CreateFrame("BUTTON", nil, f)
f.minimiseButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
f.minimiseButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
f.minimiseButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
f.minimiseButton:GetHighlightTexture():SetTexCoord(texSizeX * 2, texSizeX * 2.5, 0, texSizeY)
f.minimiseButton:SetSize(29, 30)
f.minimiseButton:SetPoint("CENTER", f, "TOPRIGHT", -42, -12)
f.minimiseButton:SetFrameLevel(600)
function f.minimiseButton:Update()
    if f.minimised then
        self:GetNormalTexture():SetTexCoord(0, texSizeX * 0.5, 0, texSizeY)
        self:GetPushedTexture():SetTexCoord(0, texSizeX * 0.5, texSizeY * 2, texSizeY * 3)
        if self.clean then
            self:GetHighlightTexture():SetTexCoord(0, texSizeX * 0.5, 0, texSizeY)
        else
            self:GetHighlightTexture():SetTexCoord(texSizeX * 2, texSizeX * 2.5, 0, texSizeY)
        end
    else
        self:GetNormalTexture():SetTexCoord(texSizeX, texSizeX * 1.5, 0, texSizeY)
        self:GetPushedTexture():SetTexCoord(texSizeX, texSizeX * 1.5, texSizeY * 2, texSizeY * 3)
        if self.clean then
            self:GetHighlightTexture():SetTexCoord(texSizeX, texSizeX * 1.5, 0, texSizeY)
        else
            self:GetHighlightTexture():SetTexCoord(texSizeX * 2, texSizeX * 2.5, 0, texSizeY)
        end
    end
end
f.minimiseButton:SetScript("OnClick", function(self, button, down)
    if button == "LeftButton" then
        f:ToggleMinimised()
    end
end)
f.minimiseButton:Update()]]


local texSizeX, texSizeY = 0.296875, 0.3125
--[[f.wowButton = CreateFrame("BUTTON", nil, f)
f.wowButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\wow-button")
f.wowButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\wow-button")
f.wowButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\wow-button")
f.wowButton:GetNormalTexture():SetTexCoord(0, texSizeX, 0, texSizeY)
f.wowButton:GetHighlightTexture():SetTexCoord(texSizeX, texSizeX * 2, 0, texSizeY)
f.wowButton:GetPushedTexture():SetTexCoord(0, texSizeX, texSizeY * 2, texSizeY * 3)
f.wowButton:SetSize(29, 30)
f.wowButton:SetPoint("CENTER", f, "TOPRIGHT", -42, -12)
f.wowButton:SetFrameLevel(600)
f.wowButton:SetScript("OnClick", function(self, button, down)
    S.Utils.ResurrectBlizzBags()
    CloseAllBags()
    OpenAllBags()
end)]]




-- SIDE FRAME (Banks, reagents, currency)
f.sideFrame = CreateFrame("FRAME", nil, f)
f.sideFrame:SetFrameLevel(f:GetFrameLevel() - 20)
f.sideFrame:SetPoint("RIGHT", f, "LEFT", -2, 0)
f.sideFrame:SetPoint("BOTTOM", 0, 16)
f.sideFrame:SetWidth(500)
S.FrameTools.AddBorder(f.sideFrame, "border", "Interface\\Addons\\Sorted\\Textures\\Side-Frame-Border", 13, 7)
S.FrameTools.AddSortedBackdrop(f.sideFrame)
f.sideFrame:Hide()
f.sideFrame:EnableMouse()
f.sideFrame:SetScript("OnMouseDown", function(self) end) -- Prevent click-through
-- Give the side frame the same width as the main frame
--[[function f.sideFrame:Resize()
    f.sideFrame:SetWidth(f:GetWidth())
end
S.Utils.RunOnEvent(f.sideFrame, "Resizing", f.sideFrame.Resize)]]
f.sideFrame.content = CreateFrame("FRAME", nil, f.sideFrame)
f.sideFrame.content:SetPoint("TOPLEFT", 1, -1)
f.sideFrame.content:SetPoint("BOTTOMRIGHT", -1, 1)
function f.sideFrame:UpdateMinSize()
    if f.selectedSideTab then
        local minWidth = S.GetSelectedSideTab().itemList:GetMinWidth()
        if self:GetWidth() < minWidth then
            self:SetWidth(minWidth)
        end
        self.minWidth = minWidth
    end
end
S.Utils.RunOnEvent(f.sideFrame, "MinSizeChanged", f.sideFrame.UpdateMinSize)

--[[if S.WoWVersion() >= 10 then
    S.ReagentBagList = S.CreateItemList(f.sideFrame.content, "REAGENT_BAGS", "ContainerFrameItemButtonTemplate")
    table.insert(S.itemLists, S.ReagentBagList)
    for _, containerID in pairs(S.Utils.ContainersOfType("REAGENT_BAGS")) do
        S.ReagentBagList:AddContainerButton(containerID, true) -- reagent bag, make it grey
    end
end]]
if S.WoWVersion() > 1 then
    S.CurrencyList = S.CreateCurrencyList(f.sideFrame.content)
end
if not S.UseNewBank() then
    S.BankItemList = S.CreateItemList(f.sideFrame.content, "BANK", 400, "ContainerFrameItemButtonTemplate")
    table.insert(S.itemLists, S.BankItemList)
    for _, containerID in pairs(S.Utils.ContainersOfType("BANK")) do
        if containerID ~= BANK_CONTAINER then
            S.BankItemList:AddContainerButton(containerID)
        end
    end
end
if S.WoWVersion() >= 6 and not S.UseNewBank() then
    S.ReagentItemList = S.CreateItemList(f.sideFrame.content, "REAGENT", 400, "ReagentBankItemButtonGenericTemplate")
    table.insert(S.itemLists, S.ReagentItemList)
elseif S.WoWVersion() <= 3 then
    S.KeyringItemList = S.CreateItemList(f.sideFrame.content, "KEYRING", 400, "ContainerFrameItemButtonTemplate")
    table.insert(S.itemLists, S.KeyringItemList)
end

-- SIDE TABS (Bank, reagents, currency)
f.sideTabs = {}
f.selectedSideTab = nil
local function GetSelectedSideTab()
    for i,v in ipairs(f.sideTabs) do
        if v.key == f.selectedSideTab then
            return v
        end
    end
end
S.GetSelectedSideTab = GetSelectedSideTab
local function PositionSideTabFrame()
    local currentSkin = S.Skinning.GetSkin()
    f.sideTabFrame:ClearAllPoints()
    if f.selectedSideTab then
        if currentSkin == S.Skinning.ADDONSKINS or currentSkin == S.Skinning.CLEAN then
            f.sideTabFrame:SetPoint("BOTTOMRIGHT", f.sideFrame, "BOTTOMLEFT", 2, 16)
        elseif currentSkin == S.Skinning.DEFAULT then
            f.sideTabFrame:SetPoint("BOTTOMRIGHT", f.sideFrame, "BOTTOMLEFT", -1, 16)
        end
    else
        if currentSkin == S.Skinning.ADDONSKINS or currentSkin == S.Skinning.CLEAN then
            f.sideTabFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 1, 16)
        elseif currentSkin == S.Skinning.DEFAULT then
            f.sideTabFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", -1, 16)
        end
    end
    f.sideTabFrame:SetSize(1,1) 
end
local function SelectSideTab(key, dontToggle)
    if f.selectedSideTab == key and not dontToggle or key == nil then
        f.selectedSideTab = nil
        f.sideFrame:Hide()
    else
        f.selectedSideTab = key
        f.sideFrame:Show()
    end
    PositionSideTabFrame()
    for i,v in ipairs(f.sideTabs) do
        v:Update(f.selectedSideTab == v.key)
    end
    if f.selectedSideTab then
        f.sideFrame.minWidth = GetSelectedSideTab().itemList:GetMinWidth()
        f.sideFrame:SetWidth(f.sideFrame.minWidth + 80)
    end
end
S.primaryFrame.SelectSideTab = SelectSideTab
local function UpdateSideTabHeight(self)
    self:SetHeight(self.text:GetStringWidth() + 28)
    --self.text:SetSize(self.text:GetStringWidth() + 8, self.text:GetStringWidth() + 8)
end
local function UpdateSideTab(self, selected)
    local skin = S.Skinning.GetSkin()
    if selected then
        self.itemList:Show()
        self.text:SetTextColor(1, 0.975, 0.85)
        if skin == S.Skinning.ADDONSKINS then
            self:SetBackdropBorderColor(unpack(S.ASS.Media.valueColor))
        else
            self.text:SetPoint("CENTER", -4, -4)
            self.normalTexTop:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Selected")
            self.normalTexCen:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Selected")
            self.normalTexBot:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Selected")
            self.highlightTexTop:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Selected-Highlight")
            self.highlightTexCen:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Selected-Highlight")
            self.highlightTexBot:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Selected-Highlight")
        end
    else
        self.itemList:Hide()
        self.text:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
        if skin == S.Skinning.ADDONSKINS then
            self:SetBackdropBorderColor(unpack(S.ASS.Media.borderColor))
        else
            self.text:SetPoint("CENTER", 0.5, -4)
            self.normalTexTop:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab")
            self.normalTexCen:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab")
            self.normalTexBot:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab")
            self.highlightTexTop:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Highlight")
            self.highlightTexCen:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Highlight")
            self.highlightTexBot:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Highlight")
        end
    end
end
local function CreateSideTab(parent, text, key, itemList, button)
    local b = button
    if b then
        -- Use an existing tab button, e.g. the bank/warbank tabs
        -- Those ones disable themselves when selected, we need to prevent that
        b.SetEnabled = b.Enable
        b.Disable = b.Enable
    else
        b = CreateFrame("BUTTON", nil, parent)
    end

    b:ClearAllPoints()
    b:SetPoint("RIGHT", parent, "LEFT")
    b:SetSize(34, 100)
    b.key = key
    b.Update = UpdateSideTab
    b.itemList = itemList
    
    b.normalTexTop = b:CreateTexture()
    b.normalTexCen = b:CreateTexture()
    b.normalTexBot = b:CreateTexture()
    b.normalTexTop:SetPoint("TOPLEFT")
    b.normalTexTop:SetPoint("BOTTOMRIGHT", b, "TOPRIGHT", 0, -14)
    b.normalTexTop:SetTexCoord(0.375, 1, 0, 0.25)
    b.normalTexCen:SetPoint("TOPLEFT", 0, -14)
    b.normalTexCen:SetPoint("BOTTOMRIGHT", 0, 14)
    b.normalTexCen:SetTexCoord(0.375, 1, 0.25, 0.75)
    b.normalTexBot:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, 14)
    b.normalTexBot:SetPoint("BOTTOMRIGHT")
    b.normalTexBot:SetTexCoord(0.375, 1, 0.75, 1)

    b.highlightTexTop = b:CreateTexture(nil, "HIGHLIGHT")
    b.highlightTexCen = b:CreateTexture(nil, "HIGHLIGHT")
    b.highlightTexBot = b:CreateTexture(nil, "HIGHLIGHT")
    b.highlightTexTop:SetBlendMode("ADD")
    b.highlightTexCen:SetBlendMode("ADD")
    b.highlightTexBot:SetBlendMode("ADD")
    b.highlightTexTop:SetPoint("TOPLEFT")
    b.highlightTexTop:SetPoint("BOTTOMRIGHT", b, "TOPRIGHT", 0, -14)
    b.highlightTexTop:SetTexCoord(0.375, 1, 0, 0.25)
    b.highlightTexCen:SetPoint("TOPLEFT", 0, -14)
    b.highlightTexCen:SetPoint("BOTTOMRIGHT", 0, 14)
    b.highlightTexCen:SetTexCoord(0.375, 1, 0.25, 0.75)
    b.highlightTexBot:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, 14)
    b.highlightTexBot:SetPoint("BOTTOMRIGHT")
    b.highlightTexBot:SetTexCoord(0.375, 1, 0.75, 1)

    b.overlayShadowFrame = CreateFrame("FRAME", nil, b)
    b.overlayShadowFrame:SetAllPoints()
    b.overlayShadowFrame:SetFrameLevel(b:GetFrameLevel() + 1)
    b.overlayShadowTop = b.overlayShadowFrame:CreateTexture()
    b.overlayShadowCen = b.overlayShadowFrame:CreateTexture()
    b.overlayShadowBot = b.overlayShadowFrame:CreateTexture()
    b.overlayShadowTop:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Shadow")
    b.overlayShadowCen:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Shadow")
    b.overlayShadowBot:SetTexture("Interface\\Addons\\Sorted\\Textures\\Side-Tab-Shadow")
    b.overlayShadowTop:SetBlendMode("MOD")
    b.overlayShadowCen:SetBlendMode("MOD")
    b.overlayShadowBot:SetBlendMode("MOD")
    b.overlayShadowTop:SetPoint("TOPLEFT")
    b.overlayShadowTop:SetPoint("BOTTOMRIGHT", b.overlayShadowFrame, "TOPRIGHT", 0, -14)
    b.overlayShadowTop:SetTexCoord(0, 1, 0, 0.25)
    b.overlayShadowCen:SetPoint("TOPLEFT", 0, -14)
    b.overlayShadowCen:SetPoint("BOTTOMRIGHT", 0, 14)
    b.overlayShadowCen:SetTexCoord(0, 1, 0.25, 0.75)
    b.overlayShadowBot:SetPoint("TOPLEFT", b.overlayShadowFrame, "BOTTOMLEFT", 0, 14)
    b.overlayShadowBot:SetPoint("BOTTOMRIGHT")
    b.overlayShadowBot:SetTexCoord(0, 1, 0.75, 1)

    b.text = b:CreateFontString(nil, "OVERLAY", "SortedFont")
    b.text:SetText(text)
    local ag = b:CreateAnimationGroup()
    local a = ag:CreateAnimation("Rotation", nil)
    a:SetDuration(0)
    a:SetDegrees(90)
    a:SetChildKey("text")
    ag:SetLooping("REPEAT")
    ag:Play()

    b:RegisterForClicks("LeftButtonUp")
    b:RegisterForDrag("LeftButton")

    b:HookScript("OnClick", function(self)
        SelectSideTab(self.key)
    end)
    b:HookScript("OnEnter", function(self)
        self:Enable()
    end)

    -- Resizing
    local function OnUpdate(self)
        local x, _ = GetCursorPosition()
        local width = (self.mouseStartX - x) / self.scale + self.startWidth
        if width < f.sideFrame.minWidth then
            width = f.sideFrame.minWidth
        end
        f.sideFrame:SetWidth(width)
    end
    b:HookScript("OnMouseDown", function(self)
        self.mouseStartX, _ = GetCursorPosition()
        self.scale = self:GetEffectiveScale()
        self.startWidth = f.sideFrame:GetWidth()
    end)
    b:HookScript("OnDragStart", function(self)
        if f.sideFrame:IsShown() then
            self:SetScript("OnUpdate", OnUpdate)
            OnUpdate(self)
        end
    end)
    b:HookScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    b:HookScript("OnEnter", function(self) 
        self.text:SetTextColor(0.95, 0.875, 0.7)
        if S.Skinning.GetSkin() == S.Skinning.ADDONSKINS then
            if f.selectedSideTab == self.key then
                self:SetBackdropBorderColor(unpack(S.ASS.Media.valueColor))
            else
                self:SetBackdropBorderColor(unpack(S.ASS.Media.borderColor))
            end
        end
    end)
    b:HookScript("OnLeave", function(self) 
        if f.selectedSideTab == self.key then
            self.text:SetTextColor(1, 0.975, 0.85)
        else
            self.text:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
        end
        if S.Skinning.GetSkin() == S.Skinning.ADDONSKINS then
            if f.selectedSideTab == self.key then
                self:SetBackdropBorderColor(unpack(S.ASS.Media.valueColor))
            else
                self:SetBackdropBorderColor(unpack(S.ASS.Media.borderColor))
            end
        end
    end)

    S.Utils.RunOnEvent(b, "FontChanged", UpdateSideTabHeight)
    b:Update()
    table.insert(f.sideTabs, b)
    return b
end
-- Create a point for the tabs to attach to. Move all the tabs by moving this one frame
if S.UseNewBank() then
    -- Hijack the default bank frame tab system
    f.sideTabFrame = BankFrame.TabSystem
    BankFrame:SetParent(f)
    S.Utils.KillFrame(BankFrame)
    S.Utils.KillFrame(BankPanel)
    S.Utils.KillFrame(BankFrame.TabSystem)
    S.Utils.KillFrame(BankFrame.TabSystem:GetTabButton(BankFrame.characterBankTabID))
    S.Utils.KillFrame(BankFrame.TabSystem:GetTabButton(BankFrame.accountBankTabID))
    BankFrame.SetShown = BankFrame.Show
    BankFrame.Hide = BankFrame.Show
    BankFrame:Show()
    BankFrame.TabSystem.LayoutChildren = function(self) return 1, 1, false end
else
    f.sideTabFrame = CreateFrame("FRAME", nil, f)
end
f.sideTabFrame:SetFrameLevel(f:GetFrameLevel() - 10)
-- Create the tabs
if S.WoWVersion() == 1 then
    CreateSideTab(f.sideTabFrame, S.Localize("TAB_BANK"), "BANK", S.BankItemList)
    CreateSideTab(f.sideTabFrame, KEYRING, "KEYRING", S.KeyringItemList)
    SelectSideTab(nil)
    S.Utils.RunOnEvent(nil, "BankOpened", function()
        SelectSideTab("BANK", true)
    end)
else
    CreateSideTab(f.sideTabFrame, S.Localize("TAB_CURRENCY"), "CURRENCY", S.CurrencyList)
    if not S.UseNewBank() then
        CreateSideTab(f.sideTabFrame, S.Localize("TAB_BANK"), "BANK", S.BankItemList)
    end

    if S.WoWVersion() >= 6 and not S.UseNewBank() then
        CreateSideTab(f.sideTabFrame, S.Localize("TAB_REAGENTS"), "REAGENTS", S.ReagentItemList)
    elseif S.WoWVersion() <= 3 then
        CreateSideTab(f.sideTabFrame, KEYRING, "KEYRING", S.KeyringItemList)
    end
    SelectSideTab(nil)
    S.Utils.RunOnEvent(nil, "BankOpened", function()
        SelectSideTab("BANK", true)
    end)
end
S.Utils.RunOnEvent(nil, "BankClosed", function()
    SelectSideTab(nil, true)
end)

function S.AddSideTab(text, key, button)
    local f = CreateFrame("FRAME", nil, S.primaryFrame.sideFrame.content)
    f:SetAllPoints()
    local tab = CreateSideTab(S.primaryFrame.sideTabFrame, text, key, f, button)
    return tab, f
end

-- Showing and hiding of side tabs
local function UpdateSideTabPositions()
    local lastVisibleTabIndex

    for i,v in ipairs(f.sideTabs) do
        if v:IsShown() then
            v:ClearAllPoints()
            if not lastVisibleTabIndex then
                v:SetPoint("BOTTOMRIGHT")
            else
                if S.Skinning.GetSkin() == S.Skinning.ADDONSKINS then
                    v:SetPoint("BOTTOMRIGHT", f.sideTabs[lastVisibleTabIndex], "TOPRIGHT", 0, 2)
                else
                    v:SetPoint("BOTTOMRIGHT", f.sideTabs[lastVisibleTabIndex], "TOPRIGHT", 0, -6)
                end
            end
            v:SetWidth(34)
            UpdateSideTabHeight(v)
            lastVisibleTabIndex = i
        end
    end
end
function S.SetSideTabShown(key, shown)
    for i,v in ipairs(f.sideTabs) do
        if v.key == key then
            v:SetShown(shown)
            if not shown and f.selectedSideTab == key then
                SelectSideTab(nil)
            end
            UpdateSideTabPositions()
            return
        end
    end
end
function S.ShowSideTab(key)
    for i,v in ipairs(f.sideTabs) do
        if v.key == key then
            v:Show()
            UpdateSideTabPositions()
            return
        end
    end
end
function S.HideSideTab(key)
    for i,v in ipairs(f.sideTabs) do
        if v.key == key then
            v:Hide()
            if f.selectedSideTab == key then
                SelectSideTab(nil)
            end
            UpdateSideTabPositions()
            return
        end
    end
end
UpdateSideTabPositions()
S.Utils.RunOnEvent(nil, "SettingChanged-skinning", UpdateSideTabPositions)
f.sideTabFrame:HookScript("OnShow", UpdateSideTabPositions)



-- HEADER  (Title bar, searchbox, category buttons)
f.head = CreateFrame("FRAME", nil, f)
f.sideFrame:SetPoint("TOP", f.head, "BOTTOM", 0, 1)
f.head:SetPoint("TOPLEFT")
f.head:SetPoint("BOTTOM", f, "TOP", 0, -60)
f.head:SetPoint("RIGHT")
f.head:EnableMouse()
f.head:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        f:StartMoving()
    end
end)
f.head:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        f:StopMovingOrSizing()
        S.Utils.TriggerEvent("Moved")
        f:SavePosition()
    end
end)
f.head.bg = f.head:CreateTexture(nil, "ARTWORK")
f.head.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Background-Rock", "REPEAT", "REPEAT")
f.head.bg:SetPoint("TOPLEFT")
f.head.bg:SetPoint("BOTTOMRIGHT", f.head, "TOPRIGHT", 0, -24)
f.head.bg:SetVertTile(true)
f.head.bg:SetHorizTile(true)

f.head.bgLower = f.head:CreateTexture(nil, "BACKGROUND")
f.head.bgLower:SetTexture("Interface\\Addons\\Sorted\\Textures\\Head-Background", "REPEAT", "REPEAT")
f.head.bgLower:SetPoint("TOPLEFT", 0, 0)
f.head.bgLower:SetPoint("BOTTOMRIGHT")
f.head.bgLower:SetHorizTile(true)

--[[f.head.bg = f.head:CreateTexture()
f.head.bg:SetColorTexture(0, 0, 0, 1)
f.head.bg:SetAllPoints()]]

f.head.characterSelectDropdown = CreateFrame("BUTTON", nil, f.head)
local dropdown = f.head.characterSelectDropdown
dropdown:SetPoint("TOPLEFT", 48, 0)
dropdown:SetHeight(22)
dropdown.text = dropdown:CreateFontString(nil, "OVERLAY", "SortedFont")
dropdown.text:SetPoint("LEFT", 6, 0)
dropdown.text:SetTextScale(1.1)
dropdown.arrow = dropdown:CreateTexture()
dropdown.arrow:SetPoint("RIGHT", -4, 0)
dropdown.arrow:SetSize(14, 14)
dropdown.arrow:SetDrawLayer("OVERLAY")
dropdown.arrow:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
dropdown.arrowHighlight = dropdown:CreateTexture()
dropdown.arrowHighlight:SetPoint("RIGHT", -4, 0)
dropdown.arrowHighlight:SetSize(14, 14)
dropdown.arrowHighlight:SetDrawLayer("HIGHLIGHT")
dropdown.arrowHighlight:SetBlendMode("ADD")
dropdown.arrowHighlight:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
dropdown.bg = dropdown:CreateTexture()
dropdown.bg:SetPoint("TOPLEFT", dropdown, -16, 0)
dropdown.bg:SetPoint("BOTTOMRIGHT", dropdown, 4, 0)
dropdown.bg:SetDrawLayer("BACKGROUND")
dropdown.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Background")
dropdown.separator = f.border:CreateTexture()
dropdown.separator:SetPoint("LEFT", dropdown, "RIGHT", -4, 0.75)
dropdown.separator:SetSize(18, 35)
dropdown.separator:SetDrawLayer("OVERLAY")
dropdown.separator:SetTexture("Interface\\Addons\\Sorted\\Textures\\Titlebar-Separator")
dropdown.warning = dropdown:CreateTexture()
dropdown.warning:SetPoint("LEFT")
dropdown.warning:SetTexture("Interface\\Addons\\Sorted\\Textures\\Type-Icons")
dropdown.warning:SetTexCoord(0.5, 0.625, 0.125, 0.25)
dropdown.warning:SetSize(20, 20)
dropdown.warning.anim = dropdown.warning:CreateAnimationGroup()
dropdown.warning.anim:SetLooping("REPEAT")
local anim = dropdown.warning.anim:CreateAnimation("Scale")
anim:SetDuration(0.5)
anim:SetScaleFrom(1, 1)
anim:SetScaleTo(0.75, 0.75)
anim:SetSmoothing("IN_OUT")
anim:SetOrder(1)
anim = dropdown.warning.anim:CreateAnimation("Scale")
anim:SetDuration(0.5)
anim:SetScaleFrom(1, 1)
anim:SetScaleTo(1.33333333, 1.33333333)
anim:SetSmoothing("IN_OUT")
anim:SetOrder(2)
dropdown.warningHighlight = dropdown:CreateTexture()
dropdown.warningHighlight:SetPoint("TOPLEFT", dropdown.text, "TOPLEFT", -26, 8)
dropdown.warningHighlight:SetPoint("BOTTOMRIGHT", dropdown.text, "BOTTOMRIGHT", 36, -8)
dropdown.warningHighlight:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Glow-Yellow")
dropdown.warningHighlight:SetBlendMode("ADD")
dropdown.warningHighlight.anim = dropdown.warningHighlight:CreateAnimationGroup()
dropdown.warningHighlight.anim:SetLooping("REPEAT")
anim = dropdown.warningHighlight.anim:CreateAnimation("Alpha")
anim:SetDuration(0.4)
anim:SetFromAlpha(0.3)
anim:SetToAlpha(0.6)
anim:SetSmoothing("IN_OUT")
anim:SetOrder(1)
anim = dropdown.warningHighlight.anim:CreateAnimation("Alpha")
anim:SetDuration(0.4)
anim:SetFromAlpha(0.6)
anim:SetToAlpha(0.3)
anim:SetSmoothing("IN_OUT")
anim:SetOrder(2)
function dropdown:Update()
    self.text:SetText(S.GetData().name)
    self.text:SetTextColor(S.Utils.GetClassColor(S.GetData().class):GetRGB())
    if S.IsPlayingCharacterSelected() then
        self.warning:Hide()
        self.warning.anim:Stop()
        self.warningHighlight:Hide()
        self.warningHighlight.anim:Stop()
        self.text:SetPoint("LEFT", self, "LEFT", 6, 0)
        self:SetWidth(self.text:GetStringWidth() + 30)
    else
        self.warning:Show()
        self.warning.anim:Play()
        self.warningHighlight:Show()
        self.warningHighlight.anim:Play()
        self.text:SetPoint("LEFT", self.warning, "RIGHT", -4, 0)
        self:SetWidth(24 + self.text:GetStringWidth() + 20)
    end
end
S.Utils.RunOnEvent(dropdown, "CharacterSelected", dropdown.Update)
S.Utils.RunOnEvent(dropdown, "SettingChanged-fontOutline", dropdown.Update)
S.Utils.RunOnEvent(dropdown, "SettingChanged-fontShadow", dropdown.Update)
S.Utils.RunOnEvent(dropdown, "SettingChanged-fontSizePts", dropdown.Update)
S.Utils.RunOnEvent(dropdown, "SettingChanged-font", dropdown.Update)
dropdown:SetScript("OnShow", dropdown.Update)
function dropdown:OnEnter()
    self.arrowHighlight:Show()
    local color = S.Utils.GetClassColor(S.GetData().class)
    color = CreateColor(color.r, color.g, color.b)
    color.r = color.r + 0.2
    color.g = color.g + 0.2
    color.b = color.b + 0.2
    self.text:SetTextColor(color:GetRGB())
end
function dropdown:OnLeave()
    self.arrowHighlight:Hide()
    self.text:SetTextColor(S.Utils.GetClassColor(S.GetData().class):GetRGB())
end
local function CharacterSelectDropdownEntryClick(self)
    local selectedChar = S.GetSelectedCharacter()
    S.SelectCharacter(self.data1)
    if S.GetSelectedCharacter() ~= selectedChar then -- Hide dropdown if a new character has been selected
        S.Dropdown.Hide()
    end
end
local function SortCharacters(char1, char2)
    -- Put current character at the top
    if char1 == UnitGUID("player") then
        return true
    elseif char2 == UnitGUID("player") then
        return false
    end
    -- Realms are the same, sort by name
    if Sorted_Data[char1].realm == Sorted_Data[char2].realm then
        return Sorted_Data[char1].name < Sorted_Data[char2].name
    end
    -- Sort current realm to the top
    if Sorted_Data[char1].realm == GetRealmName() then
        return true
    elseif Sorted_Data[char2].realm == GetRealmName() then
        return false
    end
    -- Sort by realm
    return Sorted_Data[char1].realm < Sorted_Data[char2].realm
end
local function DeleteCharacter(self)
    S.Data.DeleteCharacter(self.data1)
    S.primaryFrame.head.characterSelectDropdown:ShowDropdown()
end
function dropdown:ShowDropdown()
    local characters = {}
    for k, v in pairs(Sorted_Data) do
        --if v.realm == GetRealmName() then
            table.insert(characters, k)
        --end
    end
    table.sort(characters, SortCharacters)
    S.Dropdown.Reset()
    local realm = nil
    for i, v in ipairs(characters) do
        -- New realm, add a realm heading
        if Sorted_Data[v].realm ~= realm then
            realm = Sorted_Data[v].realm
            S.Dropdown.AddEntry(realm, nil, nil, nil, S.Utils.GetButtonTextColor())
            S.Dropdown.SetHeading()
        end
        -- Create the entry
        S.Dropdown.AddEntry(S.Utils.FormatFaction(Sorted_Data[v].faction, S.Settings.Get("fontSizePts") * 1.4).." "..Sorted_Data[v].name, CharacterSelectDropdownEntryClick, v, nil, S.Utils.GetClassColor(Sorted_Data[v].class))
        S.Dropdown.AddRightText(Sorted_Data[v].level.." "..S.Utils.GetRaceName(Sorted_Data[v].race))
        if i > 1 then
            S.Dropdown.AddDeleteButton(DeleteCharacter, v, nil, "TOOLTIP_FORGET_CHARACTER")
        end
        S.Dropdown.AddRadioButton(S.GetSelectedCharacter() == v, true)
    end
    S.Dropdown.Show(self, "TOP", "BOTTOM")
end
function dropdown:OnMouseDown()
    self.arrowHighlight:Hide()
    self.arrow:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Pushed")
    if S.Dropdown.IsShown() then
        S.Dropdown:Hide()
    else
        self:ShowDropdown()
    end
end
function dropdown:OnMouseUp()
    self.arrow:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
    if self:IsMouseOver() then
        self.arrowHighlight:Show()
    end
end
dropdown:SetScript("OnEnter", dropdown.OnEnter)
dropdown:SetScript("OnLeave", dropdown.OnLeave)
dropdown:SetScript("OnMouseDown", dropdown.OnMouseDown)
dropdown:SetScript("OnMouseUp", dropdown.OnMouseUp)

if S.WoWVersion() >= 3 then
    f.head.equipSetDropdown = CreateFrame("BUTTON", nil, f.head)
    dropdown = f.head.equipSetDropdown
    dropdown:SetPoint("TOPLEFT", f.head.characterSelectDropdown, "TOPRIGHT", 12, 0)
    dropdown:SetHeight(22)
    dropdown.text = dropdown:CreateFontString(nil, "OVERLAY", "SortedFont")
    dropdown.text:SetPoint("LEFT", 4, 0.25)
    dropdown.text:SetTextScale(1.1)
    dropdown.arrow = dropdown:CreateTexture()
    dropdown.arrow:SetPoint("RIGHT", -4, 0)
    dropdown.arrow:SetSize(14, 14)
    dropdown.arrow:SetDrawLayer("OVERLAY")
    dropdown.arrow:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
    dropdown.arrowHighlight = dropdown:CreateTexture()
    dropdown.arrowHighlight:SetPoint("RIGHT", -4, 0)
    dropdown.arrowHighlight:SetSize(14, 14)
    dropdown.arrowHighlight:SetDrawLayer("HIGHLIGHT")
    dropdown.arrowHighlight:SetBlendMode("ADD")
    dropdown.arrowHighlight:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
    dropdown.bg = dropdown:CreateTexture()
    dropdown.bg:SetPoint("TOPLEFT", dropdown, -8, 0)
    dropdown.bg:SetPoint("BOTTOMRIGHT", dropdown, 4, 0)
    dropdown.bg:SetDrawLayer("BACKGROUND")
    dropdown.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Background")
    dropdown.separator = f.border:CreateTexture()
    dropdown.separator:SetPoint("LEFT", dropdown, "RIGHT", -4, 0.75)
    dropdown.separator:SetSize(18, 36)
    dropdown.separator:SetDrawLayer("OVERLAY")
    dropdown.separator:SetTexture("Interface\\Addons\\Sorted\\Textures\\Titlebar-Separator")
    function dropdown:Update()
        local equipSetID = S.GetSelectedEquipmentSet()
        local data = S.GetData().equipSets
        if equipSetID == -1 then
            if S.WoWVersion() < 6 then
                self.text:SetText("|TInterface\\PaperDollInfoFrame\\UI-GearManager-Button:16:13:0:0:64:64:11:50:8:56|t")
            else
                self.text:SetText("|TInterface\\Icons\\Garrison_Building_Armory:16:16:-2:0:64:64:4:60:4:60|t")
            end
        elseif equipSetID == -2 then
            self.text:SetText("|cfffa373b "..S.Localize("DROPDOWN_MENU_EQUIPMENT_SET_NONE"))
        elseif data[equipSetID] then
            self.text:SetText("|T"..data[equipSetID].icon..":16:16:-2:0:64:64:4:60:4:60|t |cffeee2cf"..data[equipSetID].name)
        else
            self.text:SetText()
        end
        self:SetWidth(self.text:GetStringWidth() + 24)
    end
    S.Utils.RunOnEvent(dropdown, "EquipmentSetsUpdated", dropdown.Update)
    S.Utils.RunOnEvent(dropdown, "CharacterSelected", dropdown.Update)
    S.Utils.RunOnEvent(dropdown, "EquipmentSetSelected", dropdown.Update)
    function dropdown:OnEnter()
        self.arrowHighlight:Show()
    end
    function dropdown:OnLeave()
        self.arrowHighlight:Hide()
    end
    local function EquipSetDropdownEntryClick(self)
        local selectedEquipSet = S.GetSelectedEquipmentSet()
        if selectedEquipSet == self.data1 then
            S.SelectEquipmentSet(-1)
        else
            S.SelectEquipmentSet(self.data1)
        end
        S.Dropdown.Hide()
    end
    function dropdown:ShowDropdown()
        local data = S.GetData().equipSets
        local selectedEquipSet = S.GetSelectedEquipmentSet()
        S.Dropdown.Reset()
        S.Dropdown.AddEntry(S.Localize("DROPDOWN_MENU_EQUIPMENT_SET"), nil, nil, nil, S.Utils.GetButtonTextColor())
        for k,v in pairs(data) do
            S.Dropdown.AddEntry("|T"..v.icon..":16:16:-2:0:64:64:4:60:4:60|t |cffffffff"..v.name, EquipSetDropdownEntryClick, k)
            S.Dropdown.AddRadioButton(selectedEquipSet == k, true)
        end
        S.Dropdown.AddEntry("|cfffa373b "..S.Localize("DROPDOWN_MENU_EQUIPMENT_SET_NONE"), EquipSetDropdownEntryClick, -2)
        S.Dropdown.AddRadioButton(selectedEquipSet == -2, true)
        S.Dropdown.AddEntry("|cffaaaaaa "..S.Localize("DROPDOWN_MENU_CLEAR"), EquipSetDropdownEntryClick, -1)
        S.Dropdown.Show(self, "TOP", "BOTTOM")
    end
    function dropdown:OnMouseDown()
        self.arrowHighlight:Hide()
        self.arrow:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Pushed")
        if S.Dropdown.IsShown() then
            S.Dropdown:Hide()
        else
            self:ShowDropdown()
        end
    end
    function dropdown:OnMouseUp()
        self.arrow:SetTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
        if self:IsMouseOver() then
            self.arrowHighlight:Show()
        end
    end
    dropdown:SetScript("OnEnter", dropdown.OnEnter)
    dropdown:SetScript("OnLeave", dropdown.OnLeave)
    dropdown:SetScript("OnMouseDown", dropdown.OnMouseDown)
    dropdown:SetScript("OnMouseUp", dropdown.OnMouseUp)
end


f.head.searchBoxFrame = CreateFrame("FRAME", nil, f.head)
f.head.searchBoxFrame:SetPoint("TOPLEFT", 0, -24)
f.head.searchBoxFrame:SetPoint("BOTTOM")
f.head.searchBoxFrame:SetWidth(200)
f.searchBox = CreateFrame("EditBox", nil, f.head.searchBoxFrame, "BagSearchBoxTemplate")
f.searchBox:SetPoint("LEFT", 12, 0)
f.searchBox:SetSize(160, 24)
f.searchBox.minWidth = 140 -- Used by the categories frame when it resizes
f.searchBox.Left:Hide()
f.searchBox.Middle:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button")
f.searchBox.Middle:SetTexCoord(0.125, 0.375, 0.5, 0.75)
f.searchBox.Middle:ClearAllPoints()
f.searchBox.Middle:SetPoint("TOP", 0, 4)
f.searchBox.Middle:SetPoint("LEFT", f)
f.searchBox.Middle:SetPoint("BOTTOMRIGHT", -12, -4)
f.searchBox.Right:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button")
f.searchBox.Right:SetTexCoord(0.375, 0.5, 0.5, 0.75)
f.searchBox.Right:ClearAllPoints()
f.searchBox.Right:SetPoint("TOPLEFT", f.searchBox, "TOPRIGHT", -12, 4)
f.searchBox.Right:SetPoint("BOTTOMRIGHT", 4, -4)
function f.searchBox:Update()
    if self:HasFocus() then
        self.Middle:SetTexCoord(0.625, 0.875, 0.5, 0.75)
        self.Right:SetTexCoord(0.875, 1, 0.5, 0.75)
    else
        self.Middle:SetTexCoord(0.125, 0.375, 0.5, 0.75)
        self.Right:SetTexCoord(0.375, 0.5, 0.5, 0.75)
    end
end
f.searchBox:HookScript("OnEditFocusGained", function(self)
    self:Update()
    self:ClearAllPoints()
    self:SetPoint("LEFT", 12, 0)
    self:SetPoint("RIGHT", f.head)
    self.Middle:SetPoint("BOTTOMRIGHT", 0, -4)
    self.Right:Hide()
    if S.Settings.Get("categoriesPosition") == 0 then
        f.categoriesFrame:Hide()
    end
end)
function f.searchBox:OnEditFocusLost()
    self:SetCursorPosition(0)
    self:Update()
    self:ClearAllPoints()
    self:SetPoint("LEFT", 12, 0)
    self:SetSize(160, 24)
    self.Middle:SetPoint("BOTTOMRIGHT", -12, -4)
    self.Right:Show()
    f.categoriesFrame:Show()
    f.categoriesFrame:OnResize()
end
f.searchBox:HookScript("OnEditFocusLost", function(self)
    if not SortedPrimaryFrameClearButton:IsMouseOver() or #self:GetText() == 0 then
        self:OnEditFocusLost()
    end
end)
SortedPrimaryFrameClearButton:HookScript("OnClick", function(self) 
    f.searchBox:OnEditFocusLost()
end)
f.searchBox:SetScript("OnHide", nil)
f.searchBox:SetScript("OnTextChanged", function(self)
	SearchBoxTemplate_OnTextChanged(self)
    S.Utils.TriggerEvent("SearchChanged")
end)
f.searchBox.Instructions:SetFontObject("SortedFont")
f.searchBox:SetFontObject("SortedFont")
--[[f.searchBox:SetScript("OnHide", function(self)
    self:SetText("")
    S.Utils.TriggerEvent("SearchChanged")
end)]]


f.categoriesFrame = CreateFrame("FRAME", nil, f.head)
f.categoriesFrame:SetPoint("TOP", f.head.searchBoxFrame)
f.categoriesFrame:SetPoint("BOTTOMRIGHT")
f.categoriesFrame:SetWidth(200)
f.categoriesFrame.buttons = {}
f.categoriesFrame.dropdownButton = CreateFrame("BUTTON", nil, f.categoriesFrame)
f.categoriesFrame.dropdownButton:SetPoint("RIGHT", -5, 0)
f.categoriesFrame.dropdownButton:SetSize(16, 16)
f.categoriesFrame.dropdownButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
f.categoriesFrame.dropdownButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
f.categoriesFrame.dropdownButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Pushed")
f.categoriesFrame.dropdownButton:GetNormalTexture():SetDesaturated(true)
f.categoriesFrame.dropdownButton:Hide()
f.categoriesFrame.dropdownButton:RegisterForClicks("LeftButtonDown")

local function OnCategoriesDropdownDisableButtonClick(self)
    S.DeselectCategory()
    S.Dropdown.Hide()
end
local function OnCategoriesDropdownButtonClick(self)
    S.ToggleCategory(self.data1)
    S.Dropdown.Hide()
end
f.categoriesFrame.dropdownButton:SetScript("OnEnter", function(self)
    S.Tooltip.CreateText(self, "ANCHOR_RIGHT", LFG_LIST_MORE)
end)
f.categoriesFrame.dropdownButton:SetScript("OnLeave", function(self)
    S.Tooltip.Cancel()
end)
f.categoriesFrame.dropdownButton:SetScript("OnClick", function(self)
    local categories = S.Settings.Get("categories2")
    if S.Dropdown.IsShown() then
        S.Dropdown.Hide()
    else
        S.Dropdown.Reset()
        --S.Dropdown.AddEntry(S.Localize("CONFIG_CATEGORIES"), nil, nil, nil, {S.Utils.GetButtonTextColor()})
        for i = f.categoriesFrame.numShownCategories + 1, #categories do
            local cat = categories[i]
            if S.Category.CategoryModifiedInDropdown(i) then
                S.Dropdown.AddEntry("|cffffdd00* |cffffffff"..cat.name, OnCategoriesDropdownButtonClick, i, nil)
            else
                S.Dropdown.AddEntry(cat.name, OnCategoriesDropdownButtonClick, i, nil)
            end
            S.Dropdown.AddRadioButton(S.GetSelectedCategory() == i)
        end
        if S.Settings.Get("categoriesPosition") == 0 then
            S.Dropdown.Show(self, "TOPRIGHT", "BOTTOMRIGHT")
        else
            S.Dropdown.Show(self, "BOTTOMRIGHT", "BOTTOMLEFT", -6, 6)
        end
    end
end)
local function ShowCategoryTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(self.tooltipText)
    -- Add "Right-click for settings" to the tooltip. Don't show after player knows how to change the settings
    if not S.Settings.Get("categorySettingsHaveChanged") then
        if BANK_TAB_TOOLTIP_CLICK_INSTRUCTION then
            GameTooltip:AddLine(BANK_TAB_TOOLTIP_CLICK_INSTRUCTION, 0, 1, 0)
        else
            GameTooltip:AddLine(S.Localize("TOOLTIP_CLICK_INSTRUCTION_SETTINGS"), 0, 1, 0)
        end
    end
    GameTooltip:Show()
end
-- Create category buttons
local function CategoryButtonOnCategoryDropdownModified(self)
    self.asterix:SetShown(S.Category.CategoryModifiedInDropdown(self:GetID()))
end
for i = 1, S.Utils.GetMaxNumCategories() do
    local b = S.FrameTools.CreateCircleButton("CheckButton", f.categoriesFrame, false, "", true)
    b:SetID(i)
    b.icon:SetDesaturated(S.GetSelectedCategory() and S.Settings.Get("desaturateCategories") == 1)

    b.asterix = b:CreateFontString(nil, "OVERLAY", "SortedFont")
    b.asterix:SetText("*")
    b.asterix:SetTextScale(1.6)
    b.asterix:SetTextColor(1, 0.9, 0.1)
    b.asterix:SetPoint("TOPRIGHT")
    b.asterix:Hide()
    S.Utils.RunOnEvent(b, "CategoryDropdownModified", CategoryButtonOnCategoryDropdownModified)

    b:HookScript("OnEnter", function(self)
        self.icon:SetDesaturated(false)
        if self.tooltipText and S.Settings.Get("categoriesPosition") ~= 2 then
            S.Tooltip.Schedule(function()
                ShowCategoryTooltip(self)
            end)
        end
    end)
    b:HookScript("OnLeave", function(self)
        if not self:GetChecked() then
            self.icon:SetDesaturated(S.GetSelectedCategory() and S.Settings.Get("desaturateCategories") == 1)
        end
        S.Tooltip.Cancel()
    end)
    b:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    -- On category button click
    b:HookScript("OnClick", function(self, button, down)
        if button == "LeftButton" then
            local infoType, itemID, itemLink = GetCursorInfo()
            -- Add item to category
            if infoType == "item" then
                local itemName = GetItemInfo(itemLink)
                S.Category.AddSpecificItem(self:GetID(), itemID, itemName)
                ClearCursor()
                S.Utils.TriggerEvent("CategorySelected")
                S.Utils.TriggerEvent("SettingsFrame-CategorySelected")
                f.categoriesFrame:Update()
            -- Select category
            else
                if self:GetChecked() then
                    S.SelectCategory(self:GetID())
                else
                    S.SelectCategory(nil)
                end
            end
        else
            S.Category.CreateAttributesDropdown(self, self:GetID())
            f.categoriesFrame:Update()
        end
    end)
    b:SetPoint("LEFT", i * 30 - 14, 0)
    b:SetSize(32, 32)
    f.categoriesFrame.buttons[i] = b
    b:Hide()
end
function f.categoriesFrame:OnResize()
    local categories = S.Settings.Get("categories2")
    -- TOP
    if S.Settings.Get("categoriesPosition") == 0 then
        self.numShownCategories = floor((self:GetParent():GetWidth() - f.searchBox.minWidth) / 32)
        local width = 0
        self.dropdownButton:Hide()
        if self.numShownCategories > #categories then
            self.numShownCategories = #categories
        elseif self.numShownCategories < #categories then
            self.dropdownButton:Show()
            width = width + 20
        end
        width = width + self.numShownCategories * 30 + 20
        if width < 40 then
            width = 60
        end
        self:SetWidth(width)
        if S.Skinning.GetSkin() == S.Skinning.ADDONSKINS then
            f.searchBox:SetWidth((self:GetParent():GetWidth() - self:GetWidth()))
        else
            f.searchBox:SetWidth((self:GetParent():GetWidth() - self:GetWidth()) + 2)
        end
        for i,v in ipairs(self.buttons) do
            v:SetShown(i <= self.numShownCategories)
        end
    --SIDE
    else
        -- Calculate the number of category buttons which will be visible. If there's enough room for all of them, the dropdown button won't be needed, so it doesn't need quite as much space
        if self:GetHeight() > #categories * 30 then
            self.numShownCategories = #categories
        else
            self.numShownCategories = floor((self:GetHeight() - 16) / 30)
        end
        local height = 0
        self.dropdownButton:Hide()
        if self.numShownCategories > #categories then
            self.numShownCategories = #categories
        elseif self.numShownCategories < #categories then
            self.dropdownButton:Show()
            if S.Settings.Get("categoriesPosition") == 1 then
                self.dropdownButton:SetPoint("TOP", 0, -self.numShownCategories * 30 -2)
            else
                self.dropdownButton:SetPoint("TOP", 0, -self.numShownCategories * 30 + 2)
            end
            height = height + 20
        end
        height = height + self.numShownCategories * 30 + 20
        if height < 40 then
            height = 60
        end
        --self:SetWidth(width)
        f.searchBox:SetWidth(self:GetParent():GetWidth() - 24)
        for i,v in ipairs(self.buttons) do
            v:SetShown(i <= self.numShownCategories)
        end
    end
end
function f.categoriesFrame:UpdatePosition()
    for i, b in ipairs(f.categoriesFrame.buttons) do
        -- TOP
        if S.Settings.Get("categoriesPosition") == 0 then
            if f.categoriesFrame.bg then
                f.categoriesFrame.bg:Hide()
                f.categoriesFrame.cleanBorder:Hide()
                f.categoriesFrame.bgLeft:Hide()
                f.categoriesFrame.bgCorner:Hide()
                f.categoriesFrame.bgBottom:Hide()
            end
            f.categoriesFrame:ClearAllPoints()
            f.categoriesFrame:SetParent(f.head)
            f.categoriesFrame:SetPoint("TOP", f.head.searchBoxFrame)
            f.categoriesFrame:SetPoint("BOTTOMRIGHT")
            f.categoriesFrame:SetWidth(200)
            f.main:SetPoint("BOTTOMRIGHT")

            b:ClearAllPoints()
            b:SetPoint("LEFT", i * 30 - 14, 0)
            --b:SetSize(32, 32)
            f.categoriesFrame.dropdownButton:ClearAllPoints()
            f.categoriesFrame.dropdownButton:SetPoint("RIGHT", -4, 0)
            f.categoriesFrame.dropdownButton:SetSize(16, 16)
            f.categoriesFrame.dropdownButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
            f.categoriesFrame.dropdownButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
            f.categoriesFrame.dropdownButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Pushed")
        -- SIDE
        elseif S.Settings.Get("categoriesPosition") == 1 then
            if f.categoriesFrame.bg then
                f.categoriesFrame.bg:Hide()
                f.categoriesFrame.cleanBorder:Hide()
                f.categoriesFrame.bgLeft:Hide()
                f.categoriesFrame.bgCorner:Hide()
                f.categoriesFrame.bgBottom:Hide()
            end
            f.categoriesFrame:ClearAllPoints()
            f.categoriesFrame:SetParent(f.head)
            f.categoriesFrame:SetPoint("TOP", f.head, "BOTTOM")
            f.categoriesFrame:SetPoint("LEFT", f, "RIGHT", -32, 0)
            f.categoriesFrame:SetPoint("RIGHT", f, -4, 0)
            f.categoriesFrame:SetPoint("BOTTOM", f.foot, "TOP")
            f.main:SetPoint("BOTTOMRIGHT", -34, 0)
            --[[if not f:GetMinimised() then
            end]]
        
            b:ClearAllPoints()
            b:SetPoint("TOP", 0, -i * 30 + 30)
            --b:SetSize(32, 32)
            f.categoriesFrame.dropdownButton:ClearAllPoints()
            f.categoriesFrame.dropdownButton:SetSize(16, 16)
            f.categoriesFrame.dropdownButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Left")
            f.categoriesFrame.dropdownButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Left")
            f.categoriesFrame.dropdownButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Left-Pushed")
        -- SIDE TEXT
        else
            if not f.categoriesFrame.bg then
                f.categoriesFrame.bg = f.categoriesFrame:CreateTexture()
                f.categoriesFrame.bg:SetColorTexture(0.07, 0.06, 0.05)
                f.categoriesFrame.cleanBorder = f.categoriesFrame:CreateTexture()
                f.categoriesFrame.cleanBorder:SetColorTexture(1, 0.8, 0)
                f.categoriesFrame.bgLeft = f.categoriesFrame:CreateTexture(nil, "OVERLAY", nil, 1)
                f.categoriesFrame.bgLeft:SetTexture("Interface\\Addons\\Sorted\\Textures\\Categories-Border")
                f.categoriesFrame.bgLeft:SetTexCoord(0, 1, 0, 0.1)
                f.categoriesFrame.bgCorner = f.categoriesFrame:CreateTexture(nil, "OVERLAY", nil, 1)
                f.categoriesFrame.bgCorner:SetTexture("Interface\\Addons\\Sorted\\Textures\\Categories-Border")
                f.categoriesFrame.bgCorner:SetTexCoord(0, 1, 0, 1)
                f.categoriesFrame.bgBottom = f.categoriesFrame:CreateTexture(nil, "OVERLAY", nil, 1)
                f.categoriesFrame.bgBottom:SetTexture("Interface\\Addons\\Sorted\\Textures\\Categories-Border")
                f.categoriesFrame.bgBottom:SetTexCoord(0.9, 1, 0, 1)

                f.categoriesFrame.bg:SetAllPoints()
                f.categoriesFrame.cleanBorder:SetPoint("TOPLEFT")
                f.categoriesFrame.cleanBorder:SetPoint("BOTTOMRIGHT", f.categoriesFrame, "BOTTOMLEFT", 1, 0)
                f.categoriesFrame.bgLeft:SetPoint("TOPLEFT")
                f.categoriesFrame.bgLeft:SetPoint("BOTTOMRIGHT", f.categoriesFrame, "BOTTOMLEFT", 3, 3)
                f.categoriesFrame.bgCorner:SetPoint("TOPLEFT", f.categoriesFrame, "BOTTOMLEFT", 0, 3)
                f.categoriesFrame.bgCorner:SetPoint("BOTTOMRIGHT", f.categoriesFrame, "BOTTOMLEFT", 3, 0)
                f.categoriesFrame.bgBottom:SetPoint("TOPLEFT", f.categoriesFrame, "BOTTOMLEFT", 3, 3)
                f.categoriesFrame.bgBottom:SetPoint("BOTTOMRIGHT")
            end
            if S.Settings.Get("skinning") == S.Skinning.DEFAULT then
                f.categoriesFrame.bg:SetColorTexture(0.07, 0.06, 0.05)
                f.categoriesFrame.bg:Show()
                f.categoriesFrame.cleanBorder:Hide()
                f.categoriesFrame.bgLeft:Show()
                f.categoriesFrame.bgCorner:Show()
                f.categoriesFrame.bgBottom:Show()
            elseif S.Settings.Get("skinning") == S.Skinning.CLEAN then
                f.categoriesFrame.bg:SetColorTexture(0, 0, 0, 0.2)
                f.categoriesFrame.bg:Show()
                f.categoriesFrame.cleanBorder:Show()
                f.categoriesFrame.bgLeft:Hide()
                f.categoriesFrame.bgCorner:Hide()
                f.categoriesFrame.bgBottom:Hide()
            else
                f.categoriesFrame.bg:Hide()
                f.categoriesFrame.cleanBorder:Hide()
                f.categoriesFrame.bgLeft:Hide()
                f.categoriesFrame.bgCorner:Hide()
                f.categoriesFrame.bgBottom:Hide()
            end
            
            f.categoriesFrame:ClearAllPoints()
            f.categoriesFrame:SetParent(f.head)
            f.categoriesFrame:SetPoint("TOP", f.head, "BOTTOM")
            f.categoriesFrame:SetPoint("LEFT", f, "RIGHT", -154, 0)
            f.categoriesFrame:SetPoint("RIGHT", f, 0, 0)
            f.categoriesFrame:SetPoint("BOTTOM", f.foot, "TOP")
            f.main:SetPoint("BOTTOMRIGHT", -154, 0)
            b:ClearAllPoints()
            b:SetPoint("TOP", 0, -i * 30 + 30)
            f.categoriesFrame.dropdownButton:ClearAllPoints()
            f.categoriesFrame.dropdownButton:SetSize(24, 24)
            f.categoriesFrame.dropdownButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
            f.categoriesFrame.dropdownButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
            f.categoriesFrame.dropdownButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Pushed")
        end
    end
    S.Utils.TriggerEvent("Resized")
    f.categoriesFrame:OnResize()
    f.categoriesFrame:Update()
end
function f.categoriesFrame:Update()
    local categories = S.Settings.Get("categories2")
    local selectedCategory = S.GetSelectedCategory()

    for i = 1, #categories do
        local button = self.buttons[i]
        button:SetID(i)
        button.icon:SetTexture("Interface\\Icons\\"..categories[i].icon)
        button.tooltipText = categories[i].name
        if button:GetID() == selectedCategory then
            button:SetChecked(true)
            button.icon:SetDesaturated(false)
        else
            button:SetChecked(false)
            button.icon:SetDesaturated(selectedCategory and S.Settings.Get("desaturateCategories") == 1)
        end
        -- Text button Categories
        if S.Settings.Get("categoriesPosition") == 2 then
            button:SetSize(154, 30)
            if not button.text then
                button.text = button:CreateFontString(nil, "OVERLAY", "SortedFont")
                button.text:SetWidth(140)
                button.text:SetWordWrap(false)
                button.textShadow = button:CreateTexture(nil, "OVERLAY", nil, 5)
                button.textShadow:SetTexture("Interface\\Addons\\Sorted\\Textures\\Shadow-Mod")
                button.textShadow:SetBlendMode("MOD")
                button.textShadow:SetPoint("CENTER")
                button.textShadow:SetHeight(30)
            end
            button.text:SetText(categories[i].name)
            button.text:Show()
            button.mask:SetTexture("Interface\\Addons\\Sorted\\Textures\\Button-Mask")
            button.icon:SetTexCoord(0.03, 0.98, 0.25, 0.6)
            if button:GetID() == selectedCategory then
                button.icon:SetAlpha(0.9)
                button.text:SetTextColor(1, 1, 1, 1)
                button.text:SetTextScale(1.1)
                button.text:SetPoint("CENTER", 0, 1)
                button.textShadow:SetWidth(button.text:GetStringWidth() * 1.5 + 10)
                button.textShadow:Show()
            elseif not selectedCategory then
                button.icon:SetAlpha(0.1)
                button.text:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
                button.text:SetAlpha(1)
                button.text:SetTextScale(1)
                button.text:SetPoint("CENTER", 0, 0.5)
                button.textShadow:Hide()
            else
                button.icon:SetAlpha(0.05)
                button.text:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
                button.text:SetAlpha(0.5)
                button.text:SetTextScale(1)
                button.text:SetPoint("CENTER", 0, 0.5)
                button.textShadow:Hide()
            end
            if S.Settings.Get("skinning") == S.Skinning.DEFAULT then
                if S.WoWVersion() < 10 then -- Classic doesn't like the semi-transparent icon overlay
                    button.icon:SetAlpha(0)
                    button.textShadow:Hide()
                end
                button:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Buttons")
                button:GetNormalTexture():SetTexCoord(0.0, 0.98, 0, 0.17)
                button:GetNormalTexture():SetAllPoints()
                button:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Buttons")
                button:GetHighlightTexture():SetTexCoord(0.0, 0.98, 0.5675, 0.7375)
                button:GetHighlightTexture():SetAllPoints()
                button:GetCheckedTexture():ClearAllPoints()
            else
                button.icon:SetAlpha(0)
                button:GetNormalTexture():ClearAllPoints()
                if S.Settings.Get("skinning") == S.Skinning.CLEAN then
                    button:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Highlight")
                    button:GetHighlightTexture():SetTexCoord(0.0, 1.0, 0.0, 1.0)
                    button:GetHighlightTexture():SetVertexColor(0.3, 0.5, 0.8)
                    button:GetHighlightTexture():SetAllPoints()
                    button:SetCheckedTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Highlight")
                    button:GetCheckedTexture():SetTexCoord(0.0, 1.0, 0.0, 1.0)
                    button:GetCheckedTexture():SetVertexColor(1, 0.8, 0)
                    button:GetCheckedTexture():SetBlendMode("ADD")
                    button:GetCheckedTexture():SetAllPoints()
                else
                    button:GetHighlightTexture():ClearAllPoints()
                    button:GetCheckedTexture():ClearAllPoints()
                end
                button.textShadow:Hide()
            end
        -- Round icon Categories
        else
            if button.text then
                button.text:Hide()
                button.textShadow:Hide()
            end
            button.icon:AddMaskTexture(button.mask)
            if button.squareMask then
                button.icon:RemoveMaskTexture(button.squareMask)
            end
            if S.Settings.Get("skinning") ~= S.Skinning.ADDONSKINS then
                button:SetSize(32, 32)
                button.icon:SetTexCoord(-0.13, 1.13, -0.13, 1.13)
                button.icon:SetAlpha(1)
                button.icon:AddMaskTexture(button.mask)
                button.mask:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button-Mask-Large")
                button:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button")
                button:GetNormalTexture():SetTexCoord(0.25, 0.5, 0, 0.25)
                button:GetNormalTexture():SetAllPoints()
                button:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button")
                button:GetHighlightTexture():SetTexCoord(0.75, 1, 0.25, 0.5)
                button:GetHighlightTexture():SetVertexColor(1, 1, 1)
                button:GetHighlightTexture():SetAllPoints()
                button:SetCheckedTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button")
                button:GetCheckedTexture():SetTexCoord(0, 0.25, 0.25, 0.5)
                button:GetCheckedTexture():SetVertexColor(1, 1, 1)
                button:GetCheckedTexture():SetAllPoints()
                button:GetCheckedTexture():SetBlendMode("BLEND")
            else
                button:SetSize(29, 29)
                button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                button.icon:SetAlpha(1)
                button.icon:RemoveMaskTexture(button.mask)
                button:GetCheckedTexture():ClearAllPoints()
            end
        end
    end
    if selectedCategory and self.numShownCategories < selectedCategory then
        f.categoriesFrame.dropdownButton:GetNormalTexture():SetDesaturated(false)
    else
        f.categoriesFrame.dropdownButton:GetNormalTexture():SetDesaturated(true)
    end
end
S.Utils.RunOnEvent(f.categoriesFrame, "SettingChanged-categories2", function(self)
    f.categoriesFrame:OnResize()
    f.categoriesFrame:Update()
end)
--S.Utils.RunOnEvent(f.categoriesFrame, "Resizing", f.categoriesFrame.OnResize)
S.Utils.RunOnEvent(f.categoriesFrame, "Resized", f.categoriesFrame.OnResize)
S.Utils.RunOnEvent(f.categoriesFrame, "CategorySelected", f.categoriesFrame.Update)
S.Utils.RunOnEvent(f.categoriesFrame, "SettingChanged-desaturateCategories", f.categoriesFrame.Update)
S.Utils.RunOnEvent(f.categoriesFrame, "SettingChanged-categoriesPosition", f.categoriesFrame.UpdatePosition)
S.Utils.RunOnEvent(f.categoriesFrame, "CharacterSelected", function(self)
    f.categoriesFrame:OnResize()
    f.categoriesFrame:Update()
end)
--[[f.categoriesFrame:SetScript("OnHide", function(self)
    S.SelectCategory(nil)
end)]]
S.Utils.RunOnEvent(f.categoriesFrame, "SettingChanged-skinning", f.categoriesFrame.UpdatePosition)


f.settingsButton = CreateFrame("BUTTON", nil, f)
f.settingsButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\BagSlots2x")
f.settingsButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\BagSlots2x")
f.settingsButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\BagSlots2x")
f.settingsButton:GetNormalTexture():SetTexCoord(0, 0.375, 0, 0.375)
f.settingsButton:GetHighlightTexture():SetTexCoord(0.375, 0.75, 0, 0.375)
f.settingsButton:GetPushedTexture():SetTexCoord(0, 0.375, 0, 0.375)
f.settingsButton:SetPoint("CENTER", f, "TOPLEFT", 20, -4)
f.settingsButton:SetSize(40, 40)
f.settingsButton:GetNormalTexture():ClearAllPoints()
f.settingsButton:GetNormalTexture():SetPoint("CENTER")
f.settingsButton:GetNormalTexture():SetSize(64, 64)
f.settingsButton:GetHighlightTexture():ClearAllPoints()
f.settingsButton:GetHighlightTexture():SetPoint("CENTER")
f.settingsButton:GetHighlightTexture():SetSize(64, 64)
f.settingsButton:GetPushedTexture():ClearAllPoints()
f.settingsButton:GetPushedTexture():SetPoint("CENTER")
f.settingsButton:GetPushedTexture():SetSize(64, 64)
f.settingsButton:SetFrameLevel(600)
f.settingsButton.textFrame = CreateFrame("FRAME", nil, f.settingsButton)
f.settingsButton.textFrame:SetAllPoints()
f.settingsButton.textFrame:SetFrameLevel(605)
f.settingsButton.text = f.settingsButton.textFrame:CreateTexture()
f.settingsButton.text:SetTexture("Interface\\Addons\\Sorted\\Textures\\Portrait-Text")
f.settingsButton.text:SetPoint("CENTER")
f.settingsButton.text:SetSize(64, 64)
f.settingsButton.text:SetDrawLayer("OVERLAY")
f.settingsButton.text:Hide()
f.settingsButton:HookScript("OnEnter", function(self)
    self.text:Show()
    S.Tooltip.CreateLocalized(self, "ANCHOR_RIGHT", "TOOLTIP_CONFIG")
end)
f.settingsButton:HookScript("OnLeave", function(self)
    self.text:Hide()
    S.Tooltip.Cancel()
end)
f.settingsButton:HookScript("OnClick", function(self)
    S.settingsFrame:Show()
end)




f.foot = CreateFrame("FRAME", nil, f)
f.foot:SetPoint("LEFT")
f.foot:SetPoint("BOTTOMRIGHT")
f.foot:SetHeight(32)
f.foot.resizeButtonFrame = CreateFrame("FRAME", nil, f)
f.foot.resizeButtonFrame:SetPoint("BOTTOMRIGHT")
f.foot.resizeButtonFrame:SetSize(24, 24)
f.foot.resizeButton = CreateFrame("BUTTON", nil, f.foot.resizeButtonFrame)
f.foot.resizeButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\UI-Resize-Button-Highlight")
f.foot.resizeButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\UI-Resize-Button-Highlight")
f.foot.resizeButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\UI-Resize-Button-Highlight")
f.foot.resizeButton:GetNormalTexture():SetTexCoord(0, 1, 0.1, 0.6)
f.foot.resizeButton:GetHighlightTexture():SetTexCoord(0, 1, 0.1, 0.6)
f.foot.resizeButton:GetPushedTexture():SetTexCoord(0, 1, 0.1, 0.6)
f.foot.resizeButton:SetPoint("TOPLEFT")
f.foot.resizeButton:SetPoint("BOTTOMRIGHT")

local resizingFrame = CreateFrame("FRAME")
resizingFrame:SetResizable(true)
S.FrameTools.AddBorder(resizingFrame, "highlight", "Interface\\Addons\\Sorted\\Textures\\Place-Item-Highlight", 8, 2, true)
for k,v in pairs(resizingFrame.highlight.parts) do
    v:SetBlendMode("ADD")
end
resizingFrame.highlight:SetFrameStrata("FULLSCREEN")

f.foot.resizeButton:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        if f:GetNumPoints() > 0 then
            resizingFrame:SetScale(f:GetScale())
            resizingFrame:SetParent(f:GetParent())
            resizingFrame:ClearAllPoints()
            for i = 1, f:GetNumPoints() do
                local point, relativeTo, relativePoint, offsetX, offsetY = f:GetPoint(i)
                resizingFrame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
            end
            resizingFrame:SetWidth(f:GetWidth())
            resizingFrame:SetHeight(f:GetHeight())
        else
            -- Frame hasn't been positioned yet, so use defaults
            resizingFrame:SetParent(UIParent)
            resizingFrame:SetPoint("BOTTOMRIGHT", -64, 128)
            resizingFrame:SetSize(800, 600)
        end
        resizingFrame:SetResizeBounds(f:GetResizeBounds())
        resizingFrame:Show()
        resizingFrame:StartSizing()
        --[[f.categoriesFrame:Hide()
        f.head.searchBoxFrame:Hide()]]
    end
end)
f.foot.resizeButton:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        resizingFrame:StopMovingOrSizing()

        f:ClearAllPoints()
        for i = 1, resizingFrame:GetNumPoints() do
            local point, relativeTo, relativePoint, offsetX, offsetY = resizingFrame:GetPoint(i)
            f:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
        end
        f:SetWidth(resizingFrame:GetWidth())
        f:SetHeight(resizingFrame:GetHeight())
        resizingFrame:Hide()

        S.Utils.TriggerEvent("Resized")
        f:SavePosition()
        --[[if not f.minimised then
            f.categoriesFrame:Show()
        end
        f.head.searchBoxFrame:Show()]]
    end
end)
f.foot.resizeButton:SetScript("OnEnter", function(self)
    SetCursor("Interface\\CURSOR\\UI-Cursor-SizeRight")
end)
f.foot.resizeButton:SetScript("OnLeave", function(self)
    ResetCursor()
end)

f.foot.moneyFrame = S.FrameTools.CreateMoneyFrame(f.foot)
f.foot.moneyFrame:SetPoint("BOTTOMRIGHT", -24, 0)
f.foot.moneyFrame:HookScript("OnEnter", function(self)
    S.Tooltip.Schedule(function()
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:ClearLines()

        local totalMoney = S.Data.GetTotalMoney()
        local orderedKeys = {}
        for realm, v in pairs(totalMoney) do
            table.insert(orderedKeys, realm)
        end
        table.sort(orderedKeys)

        GameTooltip:AddLine(S.Localize("TOOLTIP_TITLE_ACCOUNT_GOLD"), 1, 1, 1)

        for i, realm in ipairs(orderedKeys) do
            local v = totalMoney[realm]
            local allianceMoney = v.alliance
            local hordeMoney = v.horde
            if realm == GetRealmName() then
                if UnitFactionGroup("player") == "Alliance" then
                    allianceMoney = allianceMoney + GetMoney()
                else
                    hordeMoney = hordeMoney + GetMoney()
                end
            end
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(" "..realm)
            GameTooltip:AddLine("|TInterface\\WORLDSTATEFRAME\\AllianceIcon:18|t "..GetMoneyString(allianceMoney, true).. " ", 1, 1, 1)
            GameTooltip:AddLine("|TInterface\\PVPFrame\\PVP-Currency-Horde:18|t "..GetMoneyString(hordeMoney, true).." ", 1, 1, 1)
        end
        GameTooltip:Show()
    end)
end)
f.foot.moneyFrame:HookScript("OnLeave", function(self)
    S.Tooltip.Cancel()
end)
function f.foot.moneyFrame.Update(self)
    S.GetData(UnitGUID("player")).money = GetMoney()
    local money = S.GetData().money
    if not money then money = 0 end  -- for new characters without money
    if money >= 10000000000 then -- Hide silvers/coppers when player has >1mil gold
        money = math.floor(money / 10000) * 10000
    elseif money >= 100000000 then -- Hide coppers when player has >10k gold
        money = math.floor(money / 100) * 100
    end
    self.text:SetText(GetMoneyString(money, true)) 
    self:SetWidth(self.text:GetWidth() + 40)
end
S.Utils.RunOnEvent(f.foot.moneyFrame, "FontChanged", function(self, event, setting, value)
    self:Update()
end)
S.Utils.RunOnEvent(f.foot.moneyFrame, "CharacterSelected", f.foot.moneyFrame.Update)
f.foot.moneyFrame:SetScript("OnShow", f.foot.moneyFrame.Update)
--f.foot.moneyFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
f.foot.moneyFrame:RegisterEvent("PLAYER_MONEY")
f.foot.moneyFrame:SetScript("OnEvent", f.foot.moneyFrame.Update)


f.foot.sellTrashButton = CreateFrame("BUTTON", nil, f.foot)
local stb = f.foot.sellTrashButton
stb:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Sell-Trash-Button")
stb:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Sell-Trash-Button")
stb:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Sell-Trash-Button")
stb:GetNormalTexture():SetTexCoord(0, 0.25, 0.25, 0.75)
stb:GetHighlightTexture():SetTexCoord(0, 0.25, 0.25, 0.75)
stb:GetPushedTexture():SetTexCoord(0.25, 0.5, 0.25, 0.75)
stb:SetPoint("RIGHT", f.foot.moneyFrame, "LEFT")
stb:SetSize(64, 32)
S.Utils.RunOnEvent(stb, "CharacterSelected", function(self) self:SetShown(S.IsPlayingCharacterSelected()) end)
stb:SetScript("OnEnter", function(self)
    --S.Tooltip.CreateLocalized(self, "ANCHOR_TOP", "BUTTON_SELL_TRASH")
    S.Tooltip.Schedule(function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:ClearLines()

        local value = 0
        
        local trashItems = {}
        local data = S.GetData(UnitGUID("player"))
        for _, bag in pairs(S.Utils.ContainersOfType("BAGS")) do
            for _, item in pairs(data.containers[bag]) do
                if item.itemID and S.Data.GetTrash(item) <= 1 then
                    value = value + item.value * item.count
                    if trashItems[item.key] then
                        trashItems[item.key].count = trashItems[item.key].count + item.count
                        trashItems[item.key].value = trashItems[item.key].value + item.value * item.count
                    else
                        trashItems[item.key] = {}
                        trashItems[item.key].count = item.count
                        trashItems[item.key].quality = item.quality
                        trashItems[item.key].name = item.name
                        trashItems[item.key].lvl = item.effectiveILvl
                        trashItems[item.key].value = item.value * item.count
                    end
                end
            end
        end
        local trashItemsSorted = {}
        for _,v in pairs(trashItems) do
            table.insert(trashItemsSorted, v)
        end
        table.sort(trashItemsSorted, function(a,b) --[[if a.quality == b.quality then]] return a.value > b.value end --[[return a.quality > b.quality end]])

        GameTooltip_SetTitle(GameTooltip, S.Localize("BUTTON_SELL_TRASH"), NORMAL_FONT_COLOR)
        for i,v in ipairs(trashItemsSorted) do
            local c = S.Utils.GetItemQualityColor(v.quality)
            local c2 = S.Utils.GetValueColor(v.value)
            local s = v.name
            --if #s > 20 then s = s:sub(1, 18).."..." end
            --s = "["..s.."]"
            local s2 = "["
            if v.count > 1 then
                s2 = CreateColor(1, 1, 1):WrapTextInColorCode(v.count.."x")..s2
            end
            GameTooltip:AddDoubleLine(s2..s.."]", S.Utils.FormatValueString(v.value), c.r, c.g, c.b, c2.r, c2.g, c2.b)
            while _G["GameTooltipTextLeft"..i+1]:GetStringWidth() > 200 do
                s = s:sub(1, -2)
                _G["GameTooltipTextLeft"..i+1]:SetText(s2..s.."...]")
            end
        end
        local c = S.Utils.GetValueColor(value)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(TOTAL, GetMoneyString(value), 1, 1, 1, 1, 1, 1)
        GameTooltip:Show()
    end, self)
end)
stb:SetScript("OnLeave", function(self)
    S.Tooltip.Cancel()
end)
stb:SetScript("OnClick", function(self)
    if MerchantFrame:IsShown() then
        S.Utils.VendorTrash()
    end
end)
stb:SetScript("OnMouseDown", function(self)
    stb:GetHighlightTexture():SetTexCoord(0.25, 0.5, 0.25, 0.75)
end)
stb:SetScript("OnMouseUp", function(self)
    stb:GetHighlightTexture():SetTexCoord(0, 0.25, 0.25, 0.75)
end)
stb:RegisterEvent("MERCHANT_SHOW")
stb:RegisterEvent("MERCHANT_CLOSED")
stb:SetScript("OnEvent", function(self, event)
    if event == "MERCHANT_SHOW" then
        self:GetNormalTexture():SetDesaturated(false)
        self:GetNormalTexture():SetAlpha(1)
        self:GetHighlightTexture():SetDesaturated(false)
        self:GetPushedTexture():SetDesaturated(false)
    else
        self:GetNormalTexture():SetDesaturated(true)
        self:GetNormalTexture():SetAlpha(0.5)
        self:GetHighlightTexture():SetDesaturated(true)
        self:GetPushedTexture():SetDesaturated(true)
    end
end)
stb:GetNormalTexture():SetDesaturated(true)
stb:GetNormalTexture():SetAlpha(0.5)
stb:GetHighlightTexture():SetDesaturated(true)
stb:GetPushedTexture():SetDesaturated(true)


--[[f.foot.bagsFrame = CreateFrame("FRAME", nil, f.foot)
f.foot.bagsFrame:SetPoint("LEFT", f.foot.freeSpace, "RIGHT")
f.foot.bagsFrame:SetPoint("BOTTOM")
f.foot.bagsFrame:SetPoint("TOP")
f.foot.bagsFrame.bags = {}
for i = 1, S.Utils.GetMaxNumBags() do
    local button = S.FrameTools.CreateCircleButton(f.foot.bagsFrame, true)
    button:SetPoint("CENTER", f.foot.bagsFrame, "LEFT", -16 + i * 32, 0)
    f.foot.bagsFrame.bags[i] = button
end]]

f.main = CreateFrame("FRAME", nil, f)
f.main:SetPoint("TOP", f.head, "BOTTOM")
f.main:SetPoint("LEFT", 1, 0)
f.main:SetPoint("BOTTOMRIGHT")

-- PRIMARY ITEM LIST
S.primaryItemList = S.CreateItemList(S.primaryFrame.main, "BAGS", 400, "ContainerFrameItemButtonTemplate")
table.insert(S.itemLists, S.primaryItemList)
for _, containerID in pairs(S.Utils.ContainersOfType("BAGS")) do
    if containerID ~= BACKPACK_CONTAINER then
        S.primaryItemList:AddContainerButton(containerID, containerID > NUM_BAG_SLOTS) -- If reagent bag, make it grey
    end
end

-- Disenchant button
f.deButton = CreateFrame("BUTTON", nil, f, "InsecureActionButtonTemplate")
f.deButton:RegisterForClicks("AnyUp", "AnyDown")
f.deButton:SetAttribute("type", "macro")
f.deButton:SetAttribute("macrotext", "/cast Disenchant")
f.deButton:SetSize(30, 30)
f.deButton:SetPoint("RIGHT", f.foot.sellTrashButton, "LEFT")
f.deButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-DE-Up")
f.deButton:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-DE-Highlight")
f.deButton:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-DE-Down")
f:HookScript("OnShow", function(self)
    self.deButton:SetShown(IsUsableSpell("Disenchant"))
end)
f.deButton:HookScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:ClearLines()
	GameTooltip:SetSpellByID(13262)
    GameTooltip:Show()
end)
f.deButton:HookScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
f.deButton:RegisterEvent("SPELLS_CHANGED")
f.deButton:HookScript("OnEvent", function(self, event)
    if event == "SPELLS_CHANGED" then
        self:SetShown(IsUsableSpell("Disenchant"))
    end
end)
f.deButton:SetScript("OnUpdate", function(self, event)
    self:GetNormalTexture():SetDesaturated(InCombatLockdown())
    self:GetHighlightTexture():SetDesaturated(InCombatLockdown())
    self:GetPushedTexture():SetDesaturated(InCombatLockdown())
end)