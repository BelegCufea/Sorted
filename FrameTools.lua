local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time
local LSM = LibStub("LibSharedMedia-3.0")

S.FrameTools = {}

function S.FrameTools.CreateCloseButton(parent)
    local b = CreateFrame("BUTTON", nil, parent)
    b.parent = parent
    b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
    b:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x")
    b:GetNormalTexture():SetTexCoord(0.1484375, 0.296875, 0, 0.3125)
    b:GetHighlightTexture():SetTexCoord(0.59375, 0.7421875, 0, 0.3125)
    b:GetPushedTexture():SetTexCoord(0.1484375, 0.296875, 0.625, 0.9375)
    b:SetSize(34, 34)
    b:SetPoint("CENTER", parent, "TOPRIGHT", -13, -12)
    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", function(self)
        self.parent:Hide()
    end)
    return b
end

function S.FrameTools.AddInnerShadow(frame, inset)
    frame.innerShadow = CreateFrame("FRAME", nil, frame)
    frame.innerShadow:SetFrameLevel(frame:GetFrameLevel() + 10)
    frame.innerShadow:SetAllPoints()

    frame.innerShadow.tl = frame.innerShadow:CreateTexture()
    frame.innerShadow.tl:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Inner")
    frame.innerShadow.tl:SetTexCoord(0, 0.25, 0, 0.25)
    frame.innerShadow.tl:SetPoint("TOPLEFT", 0, 0)
    frame.innerShadow.tl:SetPoint("BOTTOMRIGHT", frame.innerShadow, "TOPLEFT", inset, -inset)
    frame.innerShadow.tl:SetBlendMode("MOD")

    frame.innerShadow.t = frame.innerShadow:CreateTexture()
    frame.innerShadow.t:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Inner")
    frame.innerShadow.t:SetTexCoord(0.25, 0.75, 0, 0.25)
    frame.innerShadow.t:SetPoint("TOPLEFT", inset, 0)
    frame.innerShadow.t:SetPoint("BOTTOMRIGHT", frame.innerShadow, "TOPRIGHT", -inset, -inset)
    frame.innerShadow.t:SetBlendMode("MOD")
    
    frame.innerShadow.tr = frame.innerShadow:CreateTexture()
    frame.innerShadow.tr:SetDrawLayer("OVERLAY")
    frame.innerShadow.tr:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Inner")
    frame.innerShadow.tr:SetTexCoord(0.75, 1, 0, 0.25)
    frame.innerShadow.tr:SetPoint("TOPLEFT", frame.innerShadow, "TOPRIGHT", -inset, 0)
    frame.innerShadow.tr:SetPoint("BOTTOMRIGHT", frame.innerShadow, "TOPRIGHT", 0, -inset)
    frame.innerShadow.tr:SetBlendMode("MOD")
    
    frame.innerShadow.r = frame.innerShadow:CreateTexture()
    frame.innerShadow.r:SetDrawLayer("OVERLAY")
    frame.innerShadow.r:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Inner")
    frame.innerShadow.r:SetTexCoord(0.75, 1, 0.25, 0.75)
    frame.innerShadow.r:SetPoint("TOPLEFT", frame.innerShadow, "TOPRIGHT", -inset, -inset)
    frame.innerShadow.r:SetPoint("BOTTOMRIGHT", 0, inset)
    frame.innerShadow.r:SetBlendMode("MOD")
    
    frame.innerShadow.br = frame.innerShadow:CreateTexture()
    frame.innerShadow.br:SetDrawLayer("OVERLAY")
    frame.innerShadow.br:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Inner")
    frame.innerShadow.br:SetTexCoord(0.75, 1, 0.75, 1)
    frame.innerShadow.br:SetPoint("TOPLEFT", frame.innerShadow, "BOTTOMRIGHT", -inset, inset)
    frame.innerShadow.br:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.innerShadow.br:SetBlendMode("MOD")
    
    frame.innerShadow.b = frame.innerShadow:CreateTexture()
    frame.innerShadow.b:SetDrawLayer("OVERLAY")
    frame.innerShadow.b:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Inner")
    frame.innerShadow.b:SetTexCoord(0.25, 0.75, 0.75, 1)
    frame.innerShadow.b:SetPoint("TOPLEFT", frame.innerShadow, "BOTTOMLEFT", inset, inset)
    frame.innerShadow.b:SetPoint("BOTTOMRIGHT", -inset, 0)
    frame.innerShadow.b:SetBlendMode("MOD")
    
    frame.innerShadow.bl = frame.innerShadow:CreateTexture()
    frame.innerShadow.bl:SetDrawLayer("OVERLAY")
    frame.innerShadow.bl:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Inner")
    frame.innerShadow.bl:SetTexCoord(0, 0.25, 0.75, 1)
    frame.innerShadow.bl:SetPoint("TOPLEFT", frame.innerShadow, "BOTTOMLEFT", 0, inset)
    frame.innerShadow.bl:SetPoint("BOTTOMRIGHT", frame.innerShadow, "BOTTOMLEFT", inset, 0)
    frame.innerShadow.bl:SetBlendMode("MOD")
    
    frame.innerShadow.l = frame.innerShadow:CreateTexture()
    frame.innerShadow.l:SetDrawLayer("OVERLAY")
    frame.innerShadow.l:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Inner")
    frame.innerShadow.l:SetTexCoord(0, 0.25, 0.25, 0.75)
    frame.innerShadow.l:SetPoint("TOPLEFT", 0, -inset)
    frame.innerShadow.l:SetPoint("BOTTOMRIGHT", frame.innerShadow, "BOTTOMLEFT", inset, inset)
    frame.innerShadow.l:SetBlendMode("MOD")
end

function S.FrameTools.AddOuterShadow(frame, outset)
    local inset = 2
    frame.outerShadow = CreateFrame("FRAME", nil, frame)
    frame.outerShadow:SetFrameLevel(frame:GetFrameLevel() - 10)
    frame.outerShadow:SetAllPoints()

    frame.outerShadow.tl = frame.outerShadow:CreateTexture()
    frame.outerShadow.tl:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Outer")
    frame.outerShadow.tl:SetTexCoord(0, 0.333, 0, 0.333)
    frame.outerShadow.tl:SetPoint("TOPLEFT", -outset, outset)
    frame.outerShadow.tl:SetPoint("BOTTOMRIGHT", frame.outerShadow, "TOPLEFT", inset, -inset)
    frame.outerShadow.tl:SetBlendMode("MOD")

    frame.outerShadow.t = frame.outerShadow:CreateTexture()
    frame.outerShadow.t:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Outer")
    frame.outerShadow.t:SetTexCoord(0.333, 0.666, 0, 0.333)
    frame.outerShadow.t:SetPoint("TOPLEFT", inset, outset)
    frame.outerShadow.t:SetPoint("BOTTOMRIGHT", frame.outerShadow, "TOPRIGHT", -inset, -inset)
    frame.outerShadow.t:SetBlendMode("MOD")
    
    frame.outerShadow.tr = frame.outerShadow:CreateTexture()
    frame.outerShadow.tr:SetDrawLayer("OVERLAY")
    frame.outerShadow.tr:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Outer")
    frame.outerShadow.tr:SetTexCoord(0.666, 1, 0, 0.333)
    frame.outerShadow.tr:SetPoint("TOPLEFT", frame.outerShadow, "TOPRIGHT", -inset, outset)
    frame.outerShadow.tr:SetPoint("BOTTOMRIGHT", frame.outerShadow, "TOPRIGHT", outset, -inset)
    frame.outerShadow.tr:SetBlendMode("MOD")
    
    frame.outerShadow.r = frame.outerShadow:CreateTexture()
    frame.outerShadow.r:SetDrawLayer("OVERLAY")
    frame.outerShadow.r:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Outer")
    frame.outerShadow.r:SetTexCoord(0.666, 1, 0.333, 0.666)
    frame.outerShadow.r:SetPoint("TOPLEFT", frame.outerShadow, "TOPRIGHT", -inset, -inset)
    frame.outerShadow.r:SetPoint("BOTTOMRIGHT", outset, inset)
    frame.outerShadow.r:SetBlendMode("MOD")
    
    frame.outerShadow.br = frame.outerShadow:CreateTexture()
    frame.outerShadow.br:SetDrawLayer("OVERLAY")
    frame.outerShadow.br:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Outer")
    frame.outerShadow.br:SetTexCoord(0.666, 1, 0.666, 1)
    frame.outerShadow.br:SetPoint("TOPLEFT", frame.outerShadow, "BOTTOMRIGHT", -inset, inset)
    frame.outerShadow.br:SetPoint("BOTTOMRIGHT", outset, -outset)
    frame.outerShadow.br:SetBlendMode("MOD")
    
    frame.outerShadow.b = frame.outerShadow:CreateTexture()
    frame.outerShadow.b:SetDrawLayer("OVERLAY")
    frame.outerShadow.b:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Outer")
    frame.outerShadow.b:SetTexCoord(0.333, 0.666, 0.666, 1)
    frame.outerShadow.b:SetPoint("TOPLEFT", frame.outerShadow, "BOTTOMLEFT", inset, inset)
    frame.outerShadow.b:SetPoint("BOTTOMRIGHT", -inset, -outset)
    frame.outerShadow.b:SetBlendMode("MOD")
    
    frame.outerShadow.bl = frame.outerShadow:CreateTexture()
    frame.outerShadow.bl:SetDrawLayer("OVERLAY")
    frame.outerShadow.bl:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Outer")
    frame.outerShadow.bl:SetTexCoord(0, 0.333, 0.666, 1)
    frame.outerShadow.bl:SetPoint("TOPLEFT", frame.outerShadow, "BOTTOMLEFT", -outset, inset)
    frame.outerShadow.bl:SetPoint("BOTTOMRIGHT", frame.outerShadow, "BOTTOMLEFT", inset, -outset)
    frame.outerShadow.bl:SetBlendMode("MOD")
    
    frame.outerShadow.l = frame.outerShadow:CreateTexture()
    frame.outerShadow.l:SetDrawLayer("OVERLAY")
    frame.outerShadow.l:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Shadow-Outer")
    frame.outerShadow.l:SetTexCoord(0, 0.333, 0.333, 0.666)
    frame.outerShadow.l:SetPoint("TOPLEFT", -outset, -inset)
    frame.outerShadow.l:SetPoint("BOTTOMRIGHT", frame.outerShadow, "BOTTOMLEFT", inset, inset)
    frame.outerShadow.l:SetBlendMode("MOD")
end

function S.FrameTools.AddBorder(frame, key, texture, inset, outset, includeMiddle)
    frame[key] = CreateFrame("FRAME", nil, frame)
    frame[key]:SetAllPoints()
    frame[key]:SetFrameLevel(frame:GetFrameLevel() + 10)

    frame[key].parts = {}
    local parts = frame[key].parts

    parts[1] = frame[key]:CreateTexture()
    parts[1]:SetTexture(texture)
    parts[1]:SetTexCoord(0, 0.33, 0, 0.33)
    parts[1]:SetPoint("TOPLEFT", -outset, outset)
    parts[1]:SetPoint("BOTTOMRIGHT", frame[key], "TOPLEFT", inset, -inset)

    parts[2] = frame[key]:CreateTexture()
    parts[2]:SetTexture(texture)
    parts[2]:SetTexCoord(0.33, 0.66, 0, 0.33)
    parts[2]:SetPoint("TOPLEFT", inset, outset)
    parts[2]:SetPoint("BOTTOMRIGHT", frame[key], "TOPRIGHT", -inset, -inset)
    
    parts[3] = frame[key]:CreateTexture()
    parts[3]:SetDrawLayer("OVERLAY")
    parts[3]:SetTexture(texture)
    parts[3]:SetTexCoord(0.66, 1, 0, 0.33)
    parts[3]:SetPoint("TOPLEFT", frame[key], "TOPRIGHT", -inset, outset)
    parts[3]:SetPoint("BOTTOMRIGHT", frame[key], "TOPRIGHT", outset, -inset)
    
    parts[4] = frame[key]:CreateTexture()
    parts[4]:SetDrawLayer("OVERLAY")
    parts[4]:SetTexture(texture)
    parts[4]:SetTexCoord(0.66, 1, 0.33, 0.66)
    parts[4]:SetPoint("TOPLEFT", frame[key], "TOPRIGHT", -inset, -inset)
    parts[4]:SetPoint("BOTTOMRIGHT", outset, inset)
    
    parts[5] = frame[key]:CreateTexture()
    parts[5]:SetDrawLayer("OVERLAY")
    parts[5]:SetTexture(texture)
    parts[5]:SetTexCoord(0.66, 1, 0.66, 1)
    parts[5]:SetPoint("TOPLEFT", frame[key], "BOTTOMRIGHT", -inset, inset)
    parts[5]:SetPoint("BOTTOMRIGHT", outset, -outset)
    
    parts[6] = frame[key]:CreateTexture()
    parts[6]:SetDrawLayer("OVERLAY")
    parts[6]:SetTexture(texture)
    parts[6]:SetTexCoord(0.33, 0.66, 0.66, 1)
    parts[6]:SetPoint("TOPLEFT", frame[key], "BOTTOMLEFT", inset, inset)
    parts[6]:SetPoint("BOTTOMRIGHT", -inset, -outset)
    
    parts[7] = frame[key]:CreateTexture()
    parts[7]:SetDrawLayer("OVERLAY")
    parts[7]:SetTexture(texture)
    parts[7]:SetTexCoord(0, 0.33, 0.66, 1)
    parts[7]:SetPoint("TOPLEFT", frame[key], "BOTTOMLEFT", -outset, inset)
    parts[7]:SetPoint("BOTTOMRIGHT", frame[key], "BOTTOMLEFT", inset, -outset)
    
    parts[8] = frame[key]:CreateTexture()
    parts[8]:SetDrawLayer("OVERLAY")
    parts[8]:SetTexture(texture)
    parts[8]:SetTexCoord(0, 0.33, 0.33, 0.66)
    parts[8]:SetPoint("TOPLEFT", -outset, -inset)
    parts[8]:SetPoint("BOTTOMRIGHT", frame[key], "BOTTOMLEFT", inset, inset)

    if includeMiddle then
        parts[9] = frame[key]:CreateTexture()
        parts[9]:SetDrawLayer("OVERLAY")
        parts[9]:SetTexture(texture)
        parts[9]:SetTexCoord(0.33, 0.33, 0.66, 0.66)
        parts[9]:SetPoint("TOPLEFT", inset, -inset)
        parts[9]:SetPoint("BOTTOMRIGHT", -inset, inset)
    end
end

function S.FrameTools.AddMetalBorder(frame)
    S.FrameTools.AddBorder(frame, "border", "Interface\\Addons\\Sorted\\Textures\\UI-Frame", 88, 8)
    frame.border:SetFrameLevel(frame:GetFrameLevel() + 10)
end

-- UNUSED
-- Frame used to have a different border when minimised, but no longer
local function SwitchMetalBorder(frame, minimised)
    --[[if minimised then
        for i,v in ipairs(frame.border.parts) do
            v:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Frame-Minimise")
        end
    else
        for i,v in ipairs(frame.border.parts) do
            v:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Frame")
        end
    end]]
end

local function SetCircleButtonIconTexture(self, texture)
    self.icon:SetTexture(texture)
    if normalTex then
        normalTex:AddMaskTexture(self.mask)
    end
end
function S.FrameTools.CreateCircleButton(frameType, parent, gold, iconTexture, useLargeNormalMask, template)
    local b = CreateFrame(frameType, nil, parent, template)
    if template then -- Only want to inherit methods, not any textures or children
        b:ClearAllPoints()
        for k,v in pairs(b) do
            if type(v) == "table" and v.Hide then
                v:Hide()
                v:ClearAllPoints()
            end
        end
    end
    b:SetSize(32, 32)

    b.icon = b:CreateTexture()
    b.icon:SetAllPoints()
    b.icon:SetDrawLayer("ARTWORK")
    b.SetIconTexture = SetCircleButtonIconTexture

    b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button")
    if gold then
        b:GetNormalTexture():SetTexCoord(0, 0.25, 0, 0.25)
    else
        b:GetNormalTexture():SetTexCoord(0.25, 0.5, 0, 0.25)
    end
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button")
    b:GetHighlightTexture():SetTexCoord(0.75, 1, 0.25, 0.5)
    if frameType == "CheckButton" then
        b:SetCheckedTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button")
        b:GetCheckedTexture():SetTexCoord(0, 0.25, 0.25, 0.5)
    end
    b.mask = b:CreateMaskTexture()
    if useLargeNormalMask then
        b.mask:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button-Mask-Large")
    else
        b.mask:SetTexture("Interface\\Addons\\Sorted\\Textures\\Circle-Button-Mask-Small")
    end
    b.mask:SetAllPoints()
    if iconTexture then
        b.icon:SetTexture(iconTexture)
    else
        b.icon:SetTexture("Interface\\Addons\\Sorted\\Textures\\Transparent") -- Set a texture anyway so the mask can be applied
    end
    if useLargeNormalMask then -- Zoom normal texture out, zoom out further for the smaller mask
        b.icon:SetTexCoord(-0.13, 1.13, -0.13, 1.13)
    else
        b.icon:SetTexCoord(-0.2, 1.2, -0.2, 1.2)
    end
    b.icon:AddMaskTexture(b.mask)
    return b
end

function S.FrameTools.CreateMoneyFrame(parent)
    local f = CreateFrame("FRAME", nil, parent)
    f:SetSize(128, 30)

    f.bgLeft = f:CreateTexture()
    f.bgLeft:SetTexture("Interface\\Addons\\Sorted\\Textures\\Money-Border")
    f.bgLeft:SetTexCoord(0, 0.25, 0, 1)
    f.bgLeft:SetPoint("TOPLEFT")
    f.bgLeft:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 16, 0)
    f.bgRight = f:CreateTexture()
    f.bgRight:SetTexture("Interface\\Addons\\Sorted\\Textures\\Money-Border")
    f.bgRight:SetTexCoord(0.75, 1, 0, 1)
    f.bgRight:SetPoint("TOPLEFT", f, "TOPRIGHT", -16, 0)
    f.bgRight:SetPoint("BOTTOMRIGHT")
    f.bgCenter = f:CreateTexture()
    f.bgCenter:SetTexture("Interface\\Addons\\Sorted\\Textures\\Money-Border")
    f.bgCenter:SetTexCoord(0.25, 0.75, 0, 1)
    f.bgCenter:SetPoint("TOPLEFT", 16, 0)
    f.bgCenter:SetPoint("BOTTOMRIGHT", -16, 0)

    f.highlightLeft = f:CreateTexture()
    f.highlightLeft:SetTexture("Interface\\Addons\\Sorted\\Textures\\Money-Border")
    f.highlightLeft:SetTexCoord(0, 0.25, 0, 1)
    f.highlightLeft:SetPoint("TOPLEFT")
    f.highlightLeft:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 16, 0)
    f.highlightLeft:SetBlendMode("ADD")
    f.highlightLeft:Hide()
    f.highlightRight = f:CreateTexture()
    f.highlightRight:SetTexture("Interface\\Addons\\Sorted\\Textures\\Money-Border")
    f.highlightRight:SetTexCoord(0.75, 1, 0, 1)
    f.highlightRight:SetPoint("TOPLEFT", f, "TOPRIGHT", -16, 0)
    f.highlightRight:SetPoint("BOTTOMRIGHT")
    f.highlightRight:SetBlendMode("ADD")
    f.highlightRight:Hide()
    f.highlightCenter = f:CreateTexture()
    f.highlightCenter:SetTexture("Interface\\Addons\\Sorted\\Textures\\Money-Border")
    f.highlightCenter:SetTexCoord(0.25, 0.75, 0, 1)
    f.highlightCenter:SetPoint("TOPLEFT", 16, 0)
    f.highlightCenter:SetPoint("BOTTOMRIGHT", -16, 0)
    f.highlightCenter:SetBlendMode("ADD")
    f.highlightCenter:Hide()
    f:HookScript("OnEnter", function(self)
        self.highlightLeft:Show()
        self.highlightCenter:Show()
        self.highlightRight:Show()
    end)
    f:HookScript("OnLeave", function(self)
        self.highlightLeft:Hide()
        self.highlightCenter:Hide()
        self.highlightRight:Hide()
    end)

    f.text = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.text:SetPoint("CENTER", 0, 1)

    return f
end


-- Used in the settings frame
local buttonTexHeight = 0.1875
function S.FrameTools.CreateBasicTextButton(parent, name, OnClick)
    local b = CreateFrame("BUTTON", nil, parent)
    b:SetSize(96, 32)
    b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Buttons")
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Buttons")
    b:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Buttons")
    b:GetNormalTexture():SetTexCoord(0, 1, 0, buttonTexHeight)
    b:GetHighlightTexture():SetTexCoord(0, 1, buttonTexHeight, buttonTexHeight * 2)
    b:GetPushedTexture():SetTexCoord(0, 1, buttonTexHeight * 3, buttonTexHeight * 4)
    b.text = b:CreateFontString(nil, "OVERLAY", "SortedFont")
    b.text:SetText(name)
    b.text:SetPoint("CENTER", 0, 2)
    b.text:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
    b:SetScript("OnClick", OnClick)
    return b
end

local function UpdateInstruction(self)
    self.instruction:SetShown(#self:GetText() == 0)
end
function S.FrameTools.CreateEditBox(parent, name, instruction)
    local f = CreateFrame("FRAME", nil, parent)
    f:SetSize(224, 72)

    f.nameString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.nameString:SetText(name)
    f.nameString:SetPoint("TOPLEFT", 0, -16)
    f.nameString:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
    f.nameString:SetTextScale(1.2)

    local eb = CreateFrame("EditBox", nil, f)
    eb:SetFontObject("SortedFont")
    eb:SetSize(224, 16)
    eb:SetPoint("TOPLEFT", 0, -48)
    eb:SetAutoFocus(false)
    eb:SetFrameLevel(parent:GetFrameLevel() + 2)
    S.FrameTools.AddBorder(eb, "border", "Interface\\Addons\\Sorted\\Textures\\Rounded-Border", 2, 8, true)
    eb.border:SetFrameLevel(parent:GetFrameLevel() + 1)
    for k,v in pairs(eb.border.parts) do
        v:SetVertexColor(0.8, 0.8, 0.8)
    end

    eb.instruction = eb:CreateFontString(nil, "OVERLAY", "SortedFont")
    eb.instruction:SetText(instruction)
    eb.instruction:SetPoint("LEFT", 2, 0)
    eb.instruction:SetTextColor(0.5, 0.5, 0.5)
    eb.instruction:SetTextScale(1.1)
    eb:SetScript("OnShow", UpdateInstruction)
    eb:SetScript("OnTextChanged", UpdateInstruction)

    f.editBox = eb
    return f
end

local function OnDropdownButtonClick(self)
    S.Dropdown.Reset()
    self.BuildDropdown(self.data1, self.data2)
    S.Dropdown.Show(self, "TOPRIGHT", "BOTTOM")
end
-- Creates a dropdown menu button, to be used with DropdownMenu.lua
-- When clicked, BuildDropdown is called, with data1 and data2 passed
function S.FrameTools.CreateDropdown(parent, name, BuildDropdown, data1, data2)
    local f = CreateFrame("FRAME", nil, parent)
    f:SetSize(224, 72)
    f.nameString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.nameString:SetText(name)
    f.nameString:SetPoint("TOP", 0, -8)
    f.nameString:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
    f.nameString:SetTextScale(1.3)

    S.FrameTools.AddBorder(f, "border", "Interface\\Addons\\Sorted\\Textures\\Rounded-Border", 16, 4, true)
    f.border:ClearAllPoints()
    f.border:SetPoint("TOPLEFT", 0, -32)
    f.border:SetPoint("BOTTOMRIGHT", 0, 8)
    for k,v in pairs(f.border.parts) do
        v:SetVertexColor(0.5, 0.5, 0.5)
        v:SetAlpha(0.6)
    end

    local b = CreateFrame("BUTTON", nil, f.border)
    b:SetSize(24, 24)
    b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
    b:GetNormalTexture():SetDesaturated(true)
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button")
    b:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Button-Pushed")
    b:SetPoint("RIGHT", -6, 0)
    b:SetScript("OnClick", OnDropdownButtonClick)
    b.text = b:CreateFontString(nil, "OVERLAY", "SortedFont")
    b.text:SetPoint("CENTER", f.border, -6, 0)
    b.text:SetWordWrap(false)
    b.text:SetTextColor(1, 1, 1)
    b.text:SetTextScale(1.2)
    b.BuildDropdown = BuildDropdown
    b.data1 = data1
    b.data2 = data2
    f.button = b
    return f
end



-- Add Sorted's customisable backdrop to frames, and keep a record of them to update them when the backdrop is changed
local framesWithBackdrops = {}
function S.FrameTools.AddSortedBackdrop(frame)
    framesWithBackdrops[#framesWithBackdrops + 1] = frame
    frame.sortedBackdrop = frame:CreateTexture()
    frame.sortedBackdrop:SetTexture("Interface\\Addons\\Sorted\\Textures\\Abstract", "REPEAT", "REPEAT")
    frame.sortedBackdrop:SetVertexColor(0.6, 0.6, 0.6)
    frame.sortedBackdrop:SetDrawLayer("BACKGROUND")
    frame.sortedBackdrop:SetAllPoints()
    frame.sortedBackdrop:SetVertTile(true)
    frame.sortedBackdrop:SetHorizTile(true)
end
function S.FrameTools.UpdateBackdrops(backdrop)
    if S.Skinning.GetSkin() == S.Skinning.ADDONSKINS then
        for k,v in pairs(framesWithBackdrops) do
            v.sortedBackdrop:Hide()
        end
    else
        if not backdrop then
            backdrop = S.Utils.GetBackgroundPath(S.Settings.Get("backdrop"))
        else
            backdrop = S.Utils.GetBackgroundPath(backdrop)
        end
        local backdropColor = S.Settings.Get("backdropColor")
        for k,v in pairs(framesWithBackdrops) do
            v.sortedBackdrop:SetTexture(backdrop, "REPEAT", "REPEAT")
            v.sortedBackdrop:SetVertexColor(unpack(backdropColor))
        end
    end
end
S.Utils.RunOnEvent(nil, "SettingChanged-backdrop", S.FrameTools.UpdateBackdrops)
S.Utils.RunOnEvent(nil, "SettingChanged-backdropColor", S.FrameTools.UpdateBackdrops)



local function TickButton_Update(self)
    if self.toggled then
        self.tick:SetTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Cross")
    else
        self.tick:SetTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Tick-Green")
    end
end
local function TickButton_GetTicked(self)
    return not self.toggled
end
local function TickButton_SetTicked(self, ticked)
    self.toggled = not ticked
    self:Update()
end
local function TickButton_ToggleTicked(self)
    if self.toggled then
        self.toggled = nil
    else
        self.toggled = true
    end
    self:Update()
end
function S.FrameTools.CreateTickButton(parent)
    local b = CreateFrame("BUTTON", nil, parent)
    b:SetSize(28, 28)
    b:RegisterForClicks("LeftButtonUp")
    b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox")
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Highlight")
    b:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Highlight")
    b:GetPushedTexture():SetBlendMode("ADD")
    b.tick = b:CreateTexture(nil, "OVERLAY")
    b.tick:SetAllPoints()
    b.tick:SetTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Tick-Green")
    b.Update = TickButton_Update
    b.GetTicked = TickButton_GetTicked
    b.SetTicked = TickButton_SetTicked
    b:SetScript("OnClick", TickButton_ToggleTicked)
    return b
end