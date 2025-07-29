local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time



local f = CreateFrame("FRAME", "SortedSettingsProfilesFrame", UIParent)
table.insert(UISpecialFrames, "SortedSettingsProfilesFrame")
S.settingsProfilesFrame = f
f:SetSize(500, 330)
f:SetPoint("CENTER")
f:SetClampedToScreen(true)
f:EnableMouse()
f:SetFrameStrata("HIGH")
f:SetFrameLevel(632)
S.FrameTools.AddOuterShadow(f, 100)
S.FrameTools.AddSortedBackdrop(f)

-- If a default profile is set, select that profile and hide this frame
f:SetScript("OnShow", function(self)
    local profile = S.Settings.GetDefaultProfile()
    if profile then
        S.Settings.SetProfile(profile)
        self:Hide()
        if self.source == "bags" then
            S.primaryFrame:Show()
        elseif self.source == "settings" then
            S.settingsFrame:Show()
        end
    end
end)

f.closeButton = S.FrameTools.CreateCloseButton(f)
f.closeButton:SetSize(24, 24)
f.closeButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
f.closeButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
f.closeButton:GetHighlightTexture():SetTexCoord(0.1484375, 0.296875, 0, 0.3125)
f.closeButton:GetHighlightTexture():SetAlpha(0.6)
f.closeButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
f:SetScript("OnMouseDown", function(self) end) -- Prevent click-through

f.portrait = f:CreateTexture(nil, "OVERLAY")
f.portrait:SetTexture("Interface\\Addons\\Sorted\\Textures\\Title")
f.portrait:SetPoint("TOPLEFT", 16, -8)
f.portrait:SetSize(160, 40)

f.titleBar = f:CreateTexture(nil, "ARTWORK")
f.titleBar:SetColorTexture(0, 0, 0, 0.4)
f.titleBar:SetPoint("TOPLEFT")
f.titleBar:SetPoint("RIGHT")
f.titleBar:SetHeight(56)

f.separator = f:CreateTexture(nil, "ARTWORK")
f.separator:SetTexture("Interface\\Addons\\Sorted\\Textures\\Settings-Separator-Horiz")
f.separator:SetPoint("TOPLEFT", 0, -56)
f.separator:SetPoint("RIGHT")
f.separator:SetHeight(2)

f.text1 = f:CreateFontString(nil, "OVERLAY", "SortedFont")
f.text1:SetText(string.format(S.Localize("PROFILE_SELECTION_HEADER"), UnitName("player")))
f.text1:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
f.text1:SetTextScale(1.5)
f.text1:SetPoint("TOP", 0, -76)

local function OnExistingProfileEntryClick(self)
    S.Settings.SetProfile(self.data1)
    if f.makeDefault:GetChecked() then
        S.Settings.SetDefaultProfile(self.data1)
    end
    S.settingsProfilesFrame:Hide()
    if S.settingsProfilesFrame.source == "bags" then
        S.primaryFrame:Show()
    elseif S.settingsProfilesFrame.source == "settings" then
        S.settingsFrame:Show()
    end
    S.settingsProfilesFrame.source = nil
end
local function BuildExistingProfilesDropdown()
    S.Dropdown.Reset()
    for key, profile in pairs(Sorted_SettingsProfiles) do
        S.Dropdown.AddEntry(profile.profileName, OnExistingProfileEntryClick, key, profile)
    end
    S.Dropdown.Show(f.dropdownButton, "TOPRIGHT", "BOTTOM")
end
f.dropdown = S.FrameTools.CreateDropdown(f, S.Localize("PROFILE_SELECTION_EXISTING"), BuildExistingProfilesDropdown)
f.dropdown:SetPoint("TOPLEFT", 34, -125)
f.dropdown:SetScale(0.9)
f.dropdown.nameString:ClearAllPoints()
f.dropdown.nameString:SetPoint("TOPLEFT", 0, -6)
f.dropdown.button.text:SetText(S.Localize("PROFILE_SELECTION_CHOOSE"))

--[[f.text2 = f:CreateFontString(nil, "OVERLAY", "SortedFont")
f.text2:SetText(string.format(S.Localize("PROFILE_SELECTION_CHOOSE_EXISTING"), UnitName("player")))
f.text2:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
f.text2:SetTextScale(1.2)
f.text2:SetPoint("TOPLEFT", 32, -110)

f.dropdownButton = CreateFrame("BUTTON", nil, f)
f.dropdownButton:SetSize(20, 20)
f.dropdownButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
f.dropdownButton:GetNormalTexture():SetDesaturated(true)
f.dropdownButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
f.dropdownButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Pushed")
f.dropdownButton:SetPoint("LEFT", f.text2, "RIGHT", 16, 1)
local function OnDropdownEntryClick(self)
    S.Settings.SetProfile(self.data1)
    S.settingsProfilesFrame:Hide()
    if S.settingsProfilesFrame.source == "bags" then
        S.primaryFrame:Show()
    elseif S.settingsProfilesFrame.source == "settings" then
        S.settingsFrame:Show()
    end
    S.settingsProfilesFrame.source = nil
end
f.dropdownButton:SetScript("OnClick", function(self)
    S.Dropdown.Reset()
    for key, profile in pairs(Sorted_SettingsProfiles) do
        S.Dropdown.AddEntry(profile.profileName, OnDropdownEntryClick, key, profile)
    end
    S.Dropdown.Show(f.dropdownButton, "TOPRIGHT", "BOTTOM")
end)]]


f.text3 = f:CreateFontString(nil, "OVERLAY", "SortedFont")
f.text3:SetText(string.format(S.Localize("PROFILE_SELECTION_NEW"), UnitName("player")))
f.text3:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
f.text3:SetTextScale(1.2)
f.text3:SetPoint("TOPLEFT", 32, -190)

f.editBox = CreateFrame("EditBox", nil, f)
f.editBox:SetFontObject("SortedFont")
f.editBox:SetPoint("TOPLEFT", 32, -216)
f.editBox:SetSize(256, 20)
f.editBox:SetAutoFocus(false)
f.editBox:SetFrameLevel(f:GetFrameLevel() + 2)
S.FrameTools.AddBorder(f.editBox, "border", "Interface\\Addons\\Sorted\\Textures\\Rounded-Border", 4, 4, true)
f.editBox.border:SetFrameLevel(f:GetFrameLevel() + 1)
for k,v in pairs(f.editBox.border.parts) do
    v:SetVertexColor(0.8, 0.8, 0.8)
end
f.editBox:SetScript("OnShow", function(self)
    self:SetText(UnitName("player").." ("..GetRealmName()..")")
end)

local function CreateButtonOnClick(self)
    if #f.editBox:GetText() > 0 then
        local profile = S.Settings.CreateNewProfile(f.editBox:GetText())
        if f.makeDefault:GetChecked() then
            S.Settings.SetDefaultProfile(profile)
        end
        S.settingsProfilesFrame:Hide()
        if S.settingsProfilesFrame.source == "bags" then
            S.primaryFrame:Show()
        elseif S.settingsProfilesFrame.source == "settings" then
            S.settingsFrame:Show()
        end
        S.settingsProfilesFrame.source = nil
    end
end
f.button = S.FrameTools.CreateBasicTextButton(f, S.Localize("PROFILE_SELECTION_CREATE"), CreateButtonOnClick)
f.button:SetSize(64, 32)
f.button:SetPoint("LEFT", f.editBox, "RIGHT", 8, -2)
--f.button.text = f.button:CreateFontString(nil, "OVERLAY", "SortedFont")
--f.button:SetFontString(f.button.text)
--f.button.text:SetText(S.Localize("PROFILE_SELECTION_CREATE"))


-- "Make this the default for all characters" checkbox
local cb = CreateFrame("CheckButton", nil, f)
cb:SetSize(24, 24)
cb:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox")
cb:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Highlight")
cb:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox")
cb:SetCheckedTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Tick")
cb:SetPoint("BOTTOMLEFT", f, 32, 32)
cb.nameString = cb:CreateFontString(nil, "OVERLAY", "SortedFont")
cb.nameString:SetText(S.Localize("PROFILE_SELECTION_SET_DEFAULT"))
cb.nameString:SetPoint("LEFT", cb, "RIGHT", 8, 0)
cb.nameString:SetTextColor(1, 1, 1)
cb.nameString:SetTextScale(1.1)
f.makeDefault = cb