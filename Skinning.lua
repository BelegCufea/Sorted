local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local IsAddOnLoaded = IsAddOnLoaded
if C_AddOns then
    IsAddOnLoaded = C_AddOns.IsAddOnLoaded
end

S.Skinning = {}

S.Skinning.DEFAULT = 1
S.Skinning.CLEAN = 2
S.Skinning.ADDONSKINS = 3
local hasSkinnedWithAddOnSkins = false


local canSkin = false
function S.Skinning.AddOnSkinsAvailable()
    return canSkin
end

local currentSkin = S.Skinning.DEFAULT
function S.Skinning.GetSkin()
    return currentSkin
end


local texSizeX, texSizeY = 0.296875, 0.3125
function S.Skinning.SkinDefault()
    currentSkin = S.Skinning.DEFAULT
    local f = S.primaryFrame
    f.border:Show()
    f.sideFrame.border:Show()
    f.head.bg:Show()
    f.head.characterSelectDropdown.bg:Show()
    if S.WoWVersion() >= 3 then
        f.head.equipSetDropdown.bg:Show()
    end
    f.head.characterSelectDropdown:SetPoint("TOPLEFT", 48, 0)
    f.head:SetPoint("BOTTOM", f, "TOP", 0, -60)

    f.closeButton:SetSize(34, 34)
    f.closeButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
    f.closeButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
    f.closeButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
    f.closeButton:GetHighlightTexture():SetTexCoord(texSizeX * 2, texSizeX * 2.5, 0, texSizeY)
    f.closeButton:GetHighlightTexture():SetAlpha(1)

    --[[f.minimiseButton:SetSize(29, 30)
    f.minimiseButton:SetPoint("CENTER", f, "TOPRIGHT", -42, -12)
    f.minimiseButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
    f.minimiseButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
    f.minimiseButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
    f.minimiseButton.clean = false
    f.minimiseButton:Update()]]

    f.wowButton:SetSize(29, 30)
    f.wowButton:SetPoint("CENTER", f, "TOPRIGHT", -42, -12)
    f.wowButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\wow-button")
    f.wowButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\wow-button")
    f.wowButton:GetHighlightTexture():SetTexCoord(texSizeX, texSizeX * 2, 0, texSizeY)
    f.wowButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\wow-button")

    f.settingsButton:SetSize(40, 40)
    f.settingsButton:SetPoint("CENTER", f, "TOPLEFT", 21, -6)
    f.settingsButton:GetNormalTexture():SetSize(64, 64)
    f.settingsButton:GetHighlightTexture():SetSize(64, 64)
    f.settingsButton:GetPushedTexture():SetSize(64, 64)
    f.settingsButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\BagSlots2x")
    f.settingsButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\BagSlots2x")
    f.settingsButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\BagSlots2x")
    f.settingsButton:GetNormalTexture():SetTexCoord(0, 0.375, 0, 0.375)
    f.settingsButton:GetHighlightTexture():SetTexCoord(0.375, 0.75, 0, 0.375)
    f.settingsButton:GetPushedTexture():SetTexCoord(0, 0.375, 0, 0.375)
    f.settingsButton.text:SetTexture("Interface\\Addons\\Sorted\\Textures\\Portrait-Text")

    f.sideFrame:SetPoint("RIGHT", f, "LEFT", -2, 0)
    if f.sideFrame:IsShown() then
        f.sideTabFrame:SetPoint("BOTTOMRIGHT", f.sideFrame, "BOTTOMLEFT", -1, 16)
    else
        f.sideTabFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", -1, 16)
    end
end


function S.Skinning.SkinClean()
    currentSkin = S.Skinning.CLEAN
    local f = S.primaryFrame
    f.border:Hide()
    f.sideFrame.border:Hide()
    f.head.bg:Hide()
    f.head.characterSelectDropdown.bg:Hide()
    if S.WoWVersion() >= 3 then
        f.head.equipSetDropdown.bg:Hide()
    end
    f.head.characterSelectDropdown:SetPoint("TOPLEFT", 28, 0)
    f.head:SetPoint("BOTTOM", f, "TOP", 0, -52)
    
    f.closeButton:SetSize(26, 26)
    f.closeButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
    f.closeButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
    f.closeButton:GetHighlightTexture():SetTexCoord(0.1484375, 0.296875, 0, 0.3125)
    f.closeButton:GetHighlightTexture():SetAlpha(0.6)
    f.closeButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")

    --[[f.minimiseButton:SetSize(24, 24)
    f.minimiseButton:SetPoint("CENTER", f, "TOPRIGHT", -38, -12)
    f.minimiseButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
    f.minimiseButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
    f.minimiseButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
    f.minimiseButton.clean = true
    f.minimiseButton:Update()]]

    f.wowButton:SetSize(24, 24)
    f.wowButton:SetPoint("CENTER", f, "TOPRIGHT", -38, -12)
    f.wowButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\wow-button-Clean")
    f.wowButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\wow-button-Clean")
    f.wowButton:GetHighlightTexture():SetTexCoord(0, texSizeX, 0, texSizeY)
    f.wowButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\wow-button-Clean")

    f.settingsButton:SetSize(20, 20)
    f.settingsButton:SetPoint("CENTER", f, "TOPLEFT", 12, -12)
    f.settingsButton:GetNormalTexture():SetSize(20, 20)
    f.settingsButton:GetHighlightTexture():SetSize(20, 20)
    f.settingsButton:GetPushedTexture():SetSize(20, 20)
    f.settingsButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Settings-Icon")
    f.settingsButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Settings-Icon")
    f.settingsButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Settings-Icon")
    f.settingsButton:GetNormalTexture():SetTexCoord(0,1,0,1)
    f.settingsButton:GetHighlightTexture():SetTexCoord(0,1,0,1)
    f.settingsButton:GetPushedTexture():SetTexCoord(0,1,0,1)
    f.settingsButton.text:SetTexture("")

    f.sideFrame:SetPoint("RIGHT", f, "LEFT", 0, 0)
    if f.sideFrame:IsShown() then
        f.sideTabFrame:SetPoint("BOTTOMRIGHT", f.sideFrame, "BOTTOMLEFT", 1, 16)
    else
        f.sideTabFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 1, 16)
    end
end


local function SkinCircleButton(b)
    local isShown = b:IsShown()
    b.SetNormalTexture = b.SetNormalTextureOriginal
    b.icon:SetTexCoord(0.2, 0.8, 0.2, 0.8)
    b.mask:SetTexture("Interface\\Addons\\Sorted\\Textures\\Solid")
    S.AS:SkinButton(b)
    S.AS:SetInside(b.icon)
    if b.SetCheckedTexture then
        b:SetCheckedTexture("")
        hooksecurefunc(b, "SetChecked", function(self, checked)
            if self:GetChecked() then
                self:SetBackdropBorderColor(unpack(S.ASS.Media.valueColor))
            else
                self:SetBackdropBorderColor(unpack(S.ASS.Media.borderColor))
            end
        end)
        b:HookScript("OnEnter", function(self)
            if self:GetChecked() then
                self:SetBackdropBorderColor(unpack(S.ASS.Media.valueColor))
            end
        end)
        b:HookScript("OnLeave", function(self)
            if self:GetChecked() then
                self:SetBackdropBorderColor(unpack(S.ASS.Media.valueColor))
            end
        end)
    end
    b:SetSize(28, 28)
    b:SetShown(isShown)
end

local eventHandlerFrame = CreateFrame("FRAME")
eventHandlerFrame:RegisterEvent("PLAYER_LOGIN")
eventHandlerFrame:SetScript("OnEvent", function(self)
    if IsAddOnLoaded("AddOnSkins") then
        S.AS, _, S.ASS, S.ASR = unpack(AddOnSkins)
        canSkin = true
        doSkinning = true
    end

    function S.Skinning.SkinWithAddOnSkins()
        hasSkinnedWithAddOnSkins = true
        currentSkin = S.Skinning.ADDONSKINS

        local f = S.primaryFrame
        S.AS:SkinFrame(f)
        f.border:Hide()
        f.outerShadow:Hide()
        S.AS:SkinFrame(f.sideFrame)
        f.sideFrame.border:Hide()
        S.AS:StripTextures(f.head)
        S.AS:StripTextures(f.foot.moneyFrame)
        S.AS:SkinCloseButton(f.closeButton)
        f.closeButton:GetHighlightTexture():SetAlpha(1)

        f.head:SetPoint("BOTTOM", f, "TOP", 0, -60)
        f.head.characterSelectDropdown.bg:Hide()
        if S.WoWVersion() >= 3 then
            f.head.equipSetDropdown.bg:Hide()
        end
        f.head.characterSelectDropdown:SetPoint("TOPLEFT", 68, 0)
        f.head.equipSetDropdown:SetPoint("TOPLEFT", f.head.characterSelectDropdown, "TOPRIGHT", 0, 0)
        S.AS:SkinButton(f.head.characterSelectDropdown)
        S.AS:SkinButton(f.head.equipSetDropdown)

        f.wowButton:SetSize(24, 24)
        f.wowButton:SetPoint("CENTER", f, "TOPRIGHT", -38, -12)
        f.wowButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\wow-button-Clean")
        f.wowButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\wow-button-Clean")
        f.wowButton:GetHighlightTexture():SetTexCoord(0, texSizeX, 0, texSizeY)
        f.wowButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\wow-button-Clean")

        S.AS:SkinButton(f.settingsButton)
        f.settingsButton:ClearAllPoints()
        f.settingsButton.text:SetTexture("")
        f.settingsButton.textString = f.settingsButton:CreateFontString(nil, "OVERLAY", "SortedFont")
        f.settingsButton.textString:SetPoint("CENTER")
        f.settingsButton.textString:SetText("Sorted.")
        f.settingsButton.textString:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
        f.settingsButton:HookScript("OnEnter", function(self) self.textString:SetTextColor(1, 1, 1) end)
        f.settingsButton:HookScript("OnLeave", function(self) self.textString:SetTextColor(S.Utils.GetButtonTextColor():GetRGB()) end)
        f.settingsButton:SetPoint("TOPLEFT", 0, 0)
        f.settingsButton:SetSize(64, 24)

        --[[S.AS:SkinButton(f.minimiseButton)
        f.minimiseButton.text = f.minimiseButton:CreateFontString(nil, "Overlay", "SortedFont")
        f.minimiseButton.text:SetPoint("CENTER")
        f.minimiseButton.text:SetText("-")
        f.minimiseButton:SetSize(f.closeButton.Backdrop:GetWidth(), f.closeButton.Backdrop:GetHeight())
        f.minimiseButton:SetPoint("CENTER", f, "TOPRIGHT", -36, -12)]]

        
        for _, list in pairs(S.itemLists) do
            S.AS:SkinBackdropFrame(list)
            S.AS:SkinScrollBar(list.scrollBar)
            if list.head then
                S.AS:StripTextures(list.head)
                S.AS:SkinButton(list.head.toggleGridButton, true)
                list.head.toggleGridButton:Update()
                for _, button in pairs(list.columnHeadings) do
                    button.normalTex:SetTexture("")
                    button.normalTex:ClearAllPoints()
                    button.normalTexL:SetTexture("")
                    button.normalTexL:ClearAllPoints()
                    button.normalTexR:SetTexture("")
                    button.normalTexR:ClearAllPoints()
                    S.AS:SkinButton(button)
                end
            end
            if list.containerButtons then
                for _, button in pairs(list.containerButtons) do
                    SkinCircleButton(button)
                end
            end
        end
        if S.CurrencyList then
            local list = S.CurrencyList
            S.AS:SkinBackdropFrame(list)
            S.AS:SkinScrollBar(list.scrollBar)
            if list.head then
                S.AS:StripTextures(list.head)
                S.AS:SkinButton(list.head.toggleGridButton, true)
                list.head.toggleGridButton:Update()
                for _, button in pairs(list.columnHeadings) do
                    button.normalTex:SetTexture("")
                    button.normalTex:ClearAllPoints()
                    button.normalTexL:SetTexture("")
                    button.normalTexL:ClearAllPoints()
                    button.normalTexR:SetTexture("")
                    button.normalTexR:ClearAllPoints()
                    S.AS:SkinButton(button)
                end
            end
        end
        for _, button in pairs(f.categoriesFrame.buttons) do
            SkinCircleButton(button)
        end
        --f.searchBox:SetPoint("LEFT", 8, -1)
        S.AS:SkinEditBox(f.searchBox)
        S.AS:SkinBackdropFrame(S.dropdownMenu)
        S.dropdownMenu.border:Hide()

        f.sideFrame:SetPoint("RIGHT", f, "LEFT", 0, 0)
        if f.sideFrame:IsShown() then
            f.sideTabFrame:SetPoint("BOTTOMRIGHT", f.sideFrame, "BOTTOMLEFT", 1, 16)
        else
            f.sideTabFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 1, 16)
        end
        for _, button in pairs(f.sideTabs) do
            S.AS:StripTextures(button.overlayShadowFrame)
            S.AS:SkinFrame(button, true)
            button:SetWidth(28)
            button.text:SetPoint("CENTER", -4, -4)
        end
        f.sideTabs[1]:SetPoint("BOTTOM")
        for i = 2, #f.sideTabs do
            f.sideTabs[i]:SetPoint("BOTTOM", f.sideTabs[i - 1], "TOP", 0, 2)
        end

        S.AS:SkinFrame(SortedPrimaryFrame.currencyTrackerFrame, true)
    end
end)


-- Apply skinning setting
local function OnSettingChanged(self, event, value)
    if hasSkinnedWithAddOnSkins and value ~= S.Skinning.ADDONSKINS then
        C_UI.Reload()
    end
    if value == S.Skinning.DEFAULT then
        S.Skinning.SkinDefault()
    elseif value == S.Skinning.CLEAN then
        S.Skinning.SkinClean()
    elseif value == S.Skinning.ADDONSKINS and S.Skinning.AddOnSkinsAvailable() then
        S.Skinning.SkinWithAddOnSkins()
    else
        S.Settings.Set("skinning", S.Skinning.DEFAULT)
    end
end
S.Utils.RunOnEvent(nil, "SettingChanged-skinning", OnSettingChanged)