local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local DROPDOWN_WIDTH, DROPDOWN_HEIGHT = 108, 128
local ICONS_POS_Y = 48
local ICON_SIZE = 24
local ICON_PADDING = 4

-- It's the SortedMarkerIconsDropdownFrame. Smooth.
local dropD = CreateFrame("FRAME", "SortedMarkerIconsDropdownFrame", UIParent)
table.insert(UISpecialFrames, "SortedMarkerIconsDropdownFrame")
S.FrameTools.AddBorder(dropD, "border", "Interface\\Addons\\Sorted\\Textures\\Rounded-Border", 0, 10)
dropD:SetSize(DROPDOWN_WIDTH, DROPDOWN_HEIGHT)
dropD:SetPoint("TOPLEFT", UIParent, "CENTER")
dropD:EnableMouse()
dropD:SetScript("OnMouseDown", function(self) end)
dropD:Hide()
dropD.bg = dropD:CreateTexture()
dropD.bg:SetAllPoints()
dropD.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Rounded-Border")
dropD.bg:SetTexCoord(0.49,0.5,0.49,0.5)

dropD.icon = dropD:CreateTexture(nil, "OVERLAY")
dropD.icon:SetPoint("TOP")
dropD.icon:SetSize(40, 40)
dropD.iconMask = dropD:CreateMaskTexture()
dropD.iconMask:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle_Mask_Smaller")
dropD.iconMask:SetPoint("TOP")
dropD.iconMask:SetSize(40, 40)
dropD.icon:AddMaskTexture(dropD.iconMask)
dropD.iconBorder = dropD:CreateTexture(nil, "OVERLAY")
dropD.iconBorder:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle_Mask")
dropD.iconBorder:SetPoint("TOP")
dropD.iconBorder:SetSize(40, 40)

if S.WoWVersion() >= 3 then
    dropD:RegisterEvent("GLOBAL_MOUSE_DOWN")
    dropD:HookScript("OnEvent", function(self, event)
        if self:IsShown() and event == "GLOBAL_MOUSE_DOWN" then
            if not self:IsMouseOver() then
                self:Hide()
            end
        end
    end)
end

local favoriteButtonTexSize = 0.21875
for i = 1,8 do
    local x,y = (i-1)%4, floor((i-1)/4)
    local b = CreateFrame("BUTTON", nil, dropD)
    b:SetPoint("TOPLEFT", (ICON_SIZE + ICON_PADDING) * x, -ICONS_POS_Y - (ICON_SIZE + ICON_PADDING) * y)
    b:SetSize(ICON_SIZE, ICON_SIZE)
    b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Favorite-Icons")
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Favorite-Icons")
    b:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Favorite-Icons")
    b:GetNormalTexture():SetTexCoord(x * favoriteButtonTexSize, (x + 1) * favoriteButtonTexSize, y * favoriteButtonTexSize, (y + 1) * favoriteButtonTexSize)
    b:GetHighlightTexture():SetTexCoord(x * favoriteButtonTexSize, (x + 1) * favoriteButtonTexSize, y * favoriteButtonTexSize, (y + 1) * favoriteButtonTexSize)
    b:GetPushedTexture():SetTexCoord(x * favoriteButtonTexSize, (x + 1) * favoriteButtonTexSize, y * favoriteButtonTexSize, (y + 1) * favoriteButtonTexSize)
    b:SetID(i)
    b:SetScript("OnClick", function(self)
        dropD.OnClick(dropD.onClickSelf, self:GetID())
        dropD:Hide()
    end)
end
local clearButton = CreateFrame("BUTTON", nil, dropD)
clearButton:SetPoint("TOP", dropD, "TOP", 0, -ICONS_POS_Y - (ICON_SIZE + ICON_PADDING) * 2)
clearButton:SetSize(DROPDOWN_WIDTH - ICON_PADDING * 2, ICON_SIZE)
clearButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Highlight")
clearButton:GetHighlightTexture():SetVertexColor(0.6, 0.5, 0)
clearButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Highlight")
clearButton:GetPushedTexture():SetVertexColor(0.6, 0.5, 0)
clearButton.text = clearButton:CreateFontString(nil, "OVERLAY", "SortedFont")
clearButton.text:SetPoint("CENTER")
clearButton.text:SetText(S.Localize("DROPDOWN_MENU_CLEAR"))
clearButton:SetScript("OnClick", function(self)
    dropD.Clear(dropD.onClickSelf)
    dropD:Hide()
end)


S.MarkerIconMenu = {}
function S.MarkerIconMenu.Show(parent, quality, icon, OnClick, onClickSelf, Clear)
    dropD.OnClick = OnClick
    dropD.Clear = Clear
    dropD.onClickSelf = onClickSelf
    dropD:ClearAllPoints()
    dropD.icon:SetTexture(icon)
    if quality then
        local color = S.Utils.GetItemQualityColor(quality)
        dropD.iconBorder:SetVertexColor(color:GetRGB())
        dropD.bg:SetVertexColor(color:GetRGB())
        for k,v in pairs(dropD.border.parts) do
            v:SetVertexColor(color:GetRGB())
        end
    end
    dropD:SetPoint("CENTER", parent, "CENTER")
    dropD:SetSize(DROPDOWN_WIDTH, DROPDOWN_HEIGHT)
    dropD:SetFrameStrata("DIALOG")
    dropD:Show()
end