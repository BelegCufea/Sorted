local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

-- Settings frame is built using data from this table
local settingsTable = {
    [1] = {
        ["name"] = S.Localize("CONFIG_APPEARANCE_SKINNING"),
        ["left"] = {
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_SKINNING"),
                ["type"] = "RADIO",
                ["setting"] = "skinning",
                ["buttons"] = {
                    {
                        ["name"] = S.Localize("CONFIG_APPEARANCE_SKINNING_DEFAULT"),
                        ["value"] = S.Skinning.DEFAULT
                    },
                    {
                        ["name"] = S.Localize("CONFIG_APPEARANCE_SKINNING_CLEAN"),
                        ["value"] = S.Skinning.CLEAN
                    },
                    {
                        ["name"] = S.Localize("CONFIG_APPEARANCE_SKINNING_ADDONSKINS"),
                        ["value"] = S.Skinning.ADDONSKINS,
                        ["Enabled"] = function() return S.Skinning.AddOnSkinsAvailable() end
                    }
                }
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_SCALE"),
                ["type"] = "SLIDER",
                ["setting"] = "scale",
                ["min"] = 0.5,
                ["max"] = 1.5,
                ["precision"] = 2,
            },
            {
                ["type"] = "SPACER"
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_BACKDROP"),
                ["type"] = "DROPDOWN",
                ["setting"] = "backdrop",
                ["BuildDropdown"] = function()
                    local function OnClick(self)
                        S.Settings.Set("backdrop", self.data1)
                    end
                    local function OnEnter(self)
                        S.FrameTools.UpdateBackdrops(self.data1)
                    end
                    local function OnLeave(self)
                        S.FrameTools.UpdateBackdrops()
                    end
                    local backdrops = S.Utils.GetBackgrounds()
                    for k, backdrop in pairs(backdrops) do
                        S.Dropdown.AddEntry(backdrop, OnClick, backdrop)
                        S.Dropdown.OnEnter(OnEnter)
                        S.Dropdown.OnLeave(OnLeave)
                    end
                end
            },
            {
                ["name"] = COLOR,
                ["type"] = "COLOR",
                ["setting"] = "backdropColor",
            },
            {
                ["name"] = S.Localize("CONFIG_CATEGORIES"),
                ["type"] = "DROPDOWN",
                ["setting"] = "categoriesPosition",
                ["BuildDropdown"] = function()
                    local function OnClick(self)
                        S.Settings.Set("categoriesPosition", self.data1)
                    end
                    S.Dropdown.AddEntry(S.Localize("CONFIG_SKIN_CATEGORIES_POSITION_TOP"), OnClick, 0)
                    S.Dropdown.AddEntry(S.Localize("CONFIG_SKIN_CATEGORIES_POSITION_SIDE"), OnClick, 1)
                    S.Dropdown.AddEntry(S.Localize("CONFIG_SKIN_CATEGORIES_POSITION_SIDE").." ("..LOCALE_TEXT_LABEL..")", OnClick, 2)
                end,
                ["GetTextFromValue"] = function(self, value)
                    local positions = {
                        [0] = S.Localize("CONFIG_SKIN_CATEGORIES_POSITION_TOP"),
                        [1] = S.Localize("CONFIG_SKIN_CATEGORIES_POSITION_SIDE"),
                        [2] = S.Localize("CONFIG_SKIN_CATEGORIES_POSITION_SIDE").." ("..LOCALE_TEXT_LABEL..")"
                    }
                    return positions[value]
                end
            },
            {
                ["name"] = S.Localize("CONFIG_SKIN_DESATURATE_CATEGORIES"),
                ["type"] = "CHECKBOX",
                ["setting"] = "desaturateCategories"
            },
        },
        ["right"] = {
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_FONT"),
                ["type"] = "DROPDOWN",
                ["setting"] = "font",
                ["BuildDropdown"] = function()
                    local function OnClick(self)
                        S.Settings.Set("font", self.data1)
                    end
                    local fonts = S.Utils.GetFonts()
                    for k, font in pairs(fonts) do
                        S.Dropdown.AddEntry(font, OnClick, font)
                        S.Dropdown.SetFont(font)
                    end
                end
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_FONT_SIZE"),
                ["type"] = "SLIDER",
                ["setting"] = "fontSizePts",
                ["min"] = 6,
                ["max"] = 18,
                ["precision"] = 1,
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_FONT_OUTLINE"),
                ["type"] = "SLIDER",
                ["setting"] = "fontOutline",
                ["min"] = 0,
                ["max"] = 2,
                ["precision"] = 0,
                ["values"] = {
                    [0] = S.Localize("CONFIG_APPEARANCE_FONT_OUTLINE_1"),
                    [1] = S.Localize("CONFIG_APPEARANCE_FONT_OUTLINE_2"),
                    [2] = S.Localize("CONFIG_APPEARANCE_FONT_OUTLINE_3")
                }
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_FONT_SHADOW"),
                ["type"] = "SLIDER",
                ["setting"] = "fontShadow",
                ["min"] = 0,
                ["max"] = 4,
                ["precision"] = 0
            },
        }
    },
    [2] = {
        ["name"] = S.Localize("CONFIG_FEATURES"),
        ["left"] = {
            {
                ["name"] = S.Localize("CONFIG_FEATURES_PIN_NEW_ITEMS"),
                ["type"] = "CHECKBOX",
                ["setting"] = "newOnTop"
            },
            {
                ["name"] = S.Localize("CONFIG_FEATURES_PIN_RECENTLY_UNEQUIPPED_ITEMS"),
                ["type"] = "CHECKBOX",
                ["setting"] = "pinRecentlyUnequippedItems"
            },
            {
                ["name"] = S.Localize("CONFIG_FEATURES_PROTECT_FAVORITES"),
                ["type"] = "CHECKBOX",
                ["setting"] = "protectFavorites"
            },
            {
                ["name"] = USE_UBERTOOLTIPS,
                ["type"] = "CHECKBOX",
                ["setting"] = "tooltipInfo"
            },
            {
                ["name"] = S.Localize("CONFIG_BEHAVIOR_COMBINE_STACKS"),
                ["type"] = "CHECKBOX",
                ["setting"] = "combineStacks",
                ["tooltipKey"] = "TOOLTIP_CONFIG_COMBINE_STACKS"
            },
            {
                ["name"] = S.Localize("CONFIG_BEHAVIOR_SCROLL_WHEEL_SPEED"),
                ["type"] = "SLIDER",
                ["setting"] = "scrollSpeed",
                ["min"] = 1,
                ["max"] = 20,
                ["precision"] = 1,
                ["curve"] = true,
                ["tooltipKey"] = "TOOLTIP_CONFIG_SCROLL_WHEEL_SPEED"
            },
            {
                ["name"] = S.Localize("CONFIG_BEHAVIOR_SMOOTH_SCROLLING_POWER"),
                ["type"] = "SLIDER",
                ["setting"] = "smoothingAmount",
                ["min"] = 0,
                ["max"] = 1,
                ["precision"] = 2,
                ["curve"] = true,
                ["tooltipKey"] = "TOOLTIP_CONFIG_SMOOTH_SCROLLING"
            },
        },
        ["right"] = {
            
        }
    },
    [3] = {
        ["name"] = S.Localize("CONFIG_LIST"),
        ["left"] = {
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_SIZE"),
                ["type"] = "SLIDER",
                ["setting"] = "iconSize",
                ["min"] = 10,
                ["max"] = 50,
                ["precision"] = 1,
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_PADDING"),
                ["type"] = "SLIDER",
                ["setting"] = "padding",
                ["min"] = 0,
                ["max"] = 20,
                ["precision"] = 1,
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_BORDERS"),
                ["type"] = "CHECKBOX",
                ["setting"] = "iconBorders"
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_BORDER_THICKNESS"),
                ["type"] = "SLIDER",
                ["setting"] = "iconBorderThickness",
                ["min"] = 0,
                ["max"] = 10,
                ["precision"] = 2,
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_SHAPE"),
                ["type"] = "CHECKBOX",
                ["setting"] = "iconShape"
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_ZOOM"),
                ["type"] = "SLIDER",
                ["setting"] = "iconZoom",
                ["min"] = 1,
                ["max"] = 2,
                ["precision"] = 2,
            },
        },
        ["right"] = {
            
        }
    },
    [4] = {
        ["name"] = S.Localize("CONFIG_GRID"),
        ["left"] = {
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_SIZE"),
                ["type"] = "SLIDER",
                ["setting"] = "iconSizeGrid",
                ["min"] = 25,
                ["max"] = 50,
                ["precision"] = 1,
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_PADDING"),
                ["type"] = "SLIDER",
                ["setting"] = "paddingGrid",
                ["min"] = 0,
                ["max"] = 20,
                ["precision"] = 1,
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_BORDERS"),
                ["type"] = "CHECKBOX",
                ["setting"] = "iconBordersGrid"
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_BORDER_THICKNESS"),
                ["type"] = "SLIDER",
                ["setting"] = "iconBorderThicknessGrid",
                ["min"] = 0,
                ["max"] = 10,
                ["precision"] = 2,
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_SHAPE"),
                ["type"] = "CHECKBOX",
                ["setting"] = "iconShapeGrid"
            },
            {
                ["name"] = S.Localize("CONFIG_APPEARANCE_ICON_ZOOM"),
                ["type"] = "SLIDER",
                ["setting"] = "iconZoomGrid",
                ["min"] = 1,
                ["max"] = 2,
                ["precision"] = 2,
            },
        },
        ["right"] = {
            
        }
    },
    --[[[5] = {
        ["name"] = S.Localize("CONFIG_AUTOMATION"),
        ["left"] = {
            {
                ["name"] = "|cffff0522NOT YET IMPLEMENTED",
                ["type"] = "SPACER"
            },
        },
        ["right"] = {
            
        }
    },
    [6] = {
        ["name"] = S.Localize("CONFIG_CATEGORIES"),
        ["left"] = {
            {
                ["name"] = "|cffff0522NOT YET IMPLEMENTED",
                ["type"] = "SPACER"
            },
        },
        ["right"] = {
            
        }
    },]]
    --[[[7] = {
        ["name"] = S.Localize("CONFIG_PROFILES"),
        ["left"] = {

        },
        ["right"] = {
            
        }
    }]]
}


-- Slider
local function RoundToDecimalPlaces(value, numPlaces)
    return math.floor(value * 10^numPlaces) / 10^numPlaces
end
local function SetSliderText(self)
    if self.values then
        self.valueString:SetText(self.values[self:GetValue()])
    else
        local value = self:GetValue()
        if self.curve then
            local min, max = self:GetMinMaxValues()
            value = (value - min) / (max - min)
            value = value * value
            value = value * (max - min) + min
        end
        self.valueString:SetText(string.format("%."..self.precision.."f", value))
    end
end
local function SliderOnSettingChanged(self, event, value)
    SetSliderText(self)
end
local function OnSliderValueChanged(self)
    SetSliderText(self)
    --S.Settings.Set(self.setting, self:GetValue())
end
local function OnSliderMouseUp(self)
    if self.values then
        self:SetValue(math.floor(self:GetValue() + 0.5))
    end
    local value = self:GetValue()
    if self.curve then
        local min, max = self:GetMinMaxValues()
        value = (value - min) / (max - min)
        value = value * value
        value = value * (max - min) + min
    end
    S.Settings.Set(self.setting, value)
end
local function OnSliderShow(self)
    local value = S.Settings.Get(self.setting)
    if self.curve then
        local min, max = self:GetMinMaxValues()
        value = (value - min) / (max - min)
        value = math.sqrt(value)
        value = value * (max - min) + min
    end
    self:SetValue(value)
end
local function CreateSlider(parent, name, setting, min, max, precision, values, curve)
    local f = CreateFrame("FRAME", nil, parent)
    f:SetSize(224, 64)

    local slider = CreateFrame("SLIDER", nil, f)
    f.tooltipParent = slider
    slider.setting = setting
    slider.precision = precision
    slider.curve = curve
    slider:SetValueStep(10^(-precision))
    slider:SetObeyStepOnDrag(true)
    slider:SetSize(208, 56)
    slider:SetPoint("BOTTOM", -16, -8)
    slider:SetOrientation("HORIZONTAL")
    slider:SetScript("OnValueChanged", OnSliderValueChanged)
    slider:SetScript("OnMouseUp", OnSliderMouseUp)
    slider:SetMinMaxValues(min, max)
    S.Utils.RunOnEvent(slider, "SettingChanged-"..setting, SliderOnSettingChanged)

    if values then
        slider.values = values
    end

    slider:SetThumbTexture("Interface\\Addons\\Sorted\\Textures\\Slider-Thumb")
    slider:GetThumbTexture():SetSize(40, 40)

    slider.rail = slider:CreateTexture(nil, "BACKGROUND")
    slider.rail:SetAllPoints()
    slider.rail:SetTexture("Interface\\Addons\\Sorted\\Textures\\Slider-Rail")

    slider.nameString = slider:CreateFontString(nil, "OVERLAY", "SortedFont")
    slider.nameString:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
    slider.nameString:SetPoint("BOTTOM", slider, "TOP", 16, -16)
    slider.nameString:SetText(name)
    slider.nameString:SetTextScale(1.2)

    slider.valueString = slider:CreateFontString(nil, "OVERLAY", "SortedFont")
    slider.valueString:SetTextColor(1, 1, 1)
    slider.valueString:SetPoint("LEFT", slider, "RIGHT", -4, 0)

    slider:SetScript("OnShow", OnSliderShow)
    return f
end


-- Checkbox
local function CheckboxOnSettingChanged(self, event, value)
    self:SetChecked(value == 1)
end
local function OnCheckboxClicked(self)
    if self:GetChecked() then
        S.Settings.Set(self.setting, 1)
    else
        S.Settings.Set(self.setting, 0)
    end
end
local function CreateCheckbox(parent, name, setting)
    local f = CreateFrame("FRAME", nil, parent)
    f:SetSize(224, 64)
    local cb = CreateFrame("CheckButton", nil, f)
    cb.setting = setting
    cb:SetSize(32, 32)
    cb:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox")
    cb:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Highlight")
    cb:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox")
    cb:SetCheckedTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Tick")
    cb:SetPoint("LEFT", f, 2, 0)
    cb:SetScript("OnClick", OnCheckboxClicked)
    S.Utils.RunOnEvent(cb, "SettingChanged-"..setting, CheckboxOnSettingChanged)
    f.tooltipParent = cb
    f.checkButton = cb
    f.nameString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.nameString:SetText(name)
    f.nameString:SetPoint("LEFT", cb, "RIGHT", 8, 0)
    f.nameString:SetTextColor(1, 1, 1)
    f.nameString:SetTextScale(1.2)

    cb:SetScript("OnShow", function(self) cb:SetChecked(S.Settings.Get(self.setting) == 1) end)
    return f
end


-- Radio buttons
local function RadioButtonOnSettingChanged(self, event, value)
    self:SetChecked(value == self.value)
end
local function OnRadioButtonClicked(self)
    for k,v in pairs(self.parent.buttons) do
        v:SetChecked(v == self)
    end
    S.Settings.Set(self.setting, self.value)
end
local function CreateRadio(parent, name, setting, buttons)
    local f = CreateFrame("FRAME", nil, parent)
    f:SetSize(224, 24 + 40 * #buttons)
    f.nameString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.nameString:SetText(name)
    f.nameString:SetPoint("TOP", 0, -4)
    f.nameString:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
    f.nameString:SetTextScale(1.3)
    f.buttons = {}
    for i,v in ipairs(buttons) do
        local cb = CreateFrame("CheckButton", nil, f)
        cb:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Radio-Button")
        cb:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Radio-Button-Highlight")
        cb:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Radio-Button")
        cb:SetCheckedTexture("Interface\\Addons\\Sorted\\Textures\\Radio-Button-Dot")
        cb:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -24 - 40 * (i - 1))
        cb:SetSize(32, 32)
        cb.parent = f
        cb.setting = setting
        cb.value = v.value
        if v.Enabled then
            cb.ShouldEnable = v.Enabled
            cb:SetScript("OnShow", function(self)
                if self.ShouldEnable() then
                    self.nameString:SetTextColor(1, 1, 1)
                    self:Enable()
                else
                    self.nameString:SetTextColor(0.5, 0.5, 0.5)
                    self:Disable()
                end
            end)
        end
        cb:SetScript("OnClick", OnRadioButtonClicked)
        S.Utils.RunOnEvent(cb, "SettingChanged-"..setting, RadioButtonOnSettingChanged)
        cb.nameString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
        cb.nameString:SetText(v.name)
        cb.nameString:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        cb.nameString:SetTextColor(1, 1, 1)
        cb.nameString:SetTextScale(1.2)
        f.buttons[i] = cb
        cb:HookScript("OnShow", function(self) 
            self:SetChecked(S.Settings.Get(self.setting) == self.value) 
        end)
    end
    return f
end


-- Dropdown

-- Override GetTextFromValue for settings that use values different from the names of the entries
local function GetTextFromValue(self, value)
    return value
end
local function DropdownOnSettingChanged(self, event, value)
    self.text:SetText(self:GetTextFromValue(value))
end
local function CreateDropdown(parent, name, setting, BuildDropdown, GetTextFromValueOverride)
    local f = S.FrameTools.CreateDropdown(parent, name, BuildDropdown)
    f.tooltipParent = f.button
    if GetTextFromValueOverride then
        f.button.GetTextFromValue = GetTextFromValueOverride
    else
        f.button.GetTextFromValue = GetTextFromValue
    end
    f.button.setting = setting
    f.button:SetScript("OnShow", function(self)
        self.text:SetText(self:GetTextFromValue(S.Settings.Get(self.setting)))
    end)
    S.Utils.RunOnEvent(f.button, "SettingChanged-"..setting, DropdownOnSettingChanged)
    return f
end


-- Color
local function ColorButtonOnSettingChanged(self, event, value)
    self:GetNormalTexture():SetVertexColor(unpack(S.Settings.Get(self.setting)))
end
local function ColorButtonCancelCallback()
    S.Settings.Set(ColorPickerFrame.setting, ColorPickerFrame.previousColor)
end
local function ColorButtonCallback(restore)
    local r,g,b,a
    if restore then
        r,g,b,a = unpack(restore)
    else
        r,g,b = ColorPickerFrame:GetColorRGB()
        a = 1 - OpacitySliderFrame:GetValue()
    end
    S.Settings.Set(ColorPickerFrame.setting, {r,g,b,a})
end
local function OnColorButtonClick(self)
    local color = S.Settings.Get(self.setting)
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = color[1],
            g = color[2],
            b = color[3],
            opacity = color[4],
            hasOpacity = true,
            swatchFunc = function()
                local r,g,b = ColorPickerFrame:GetColorRGB()
                S.Settings.Set(self.setting, {r,g,b,ColorPickerFrame:GetColorAlpha()})
            end,
            cancelFunc = function()
                S.Settings.Set(self.setting, {ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g,
                ColorPickerFrame.previousValues.b, ColorPickerFrame.previousValues.a})
            end
        })
    else
        ColorPickerFrame:SetColorRGB(unpack(color))
        ColorPickerFrame.opacity = 1 - color[4]
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.previousColor = color
        ColorPickerFrame.func = ColorButtonCallback
        ColorPickerFrame.opacityFunc = ColorButtonCallback
        ColorPickerFrame.cancelFunc = ColorButtonCancelCallback
        ColorPickerFrame.setting = self.setting
        ColorPickerFrame:Show()
    end
end
local function CreateColor(parent, name, setting)
    local f = CreateFrame("FRAME", nil, parent)
    f:SetSize(224, 64)

    f.colorButton = CreateFrame("BUTTON", nil, f)
    f.tooltipParent = f.colorButton
    f.colorButton:SetSize(32, 32)
    f.colorButton:SetPoint("LEFT", 16, 0)
    f.colorButton.bg = f.colorButton:CreateTexture(nil, "BACKGROUND")
    f.colorButton.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Radio-Button")
    f.colorButton.bg:SetAllPoints()
    f.colorButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Radio-Button-Color-Dot")
    f.colorButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Radio-Button-Highlight")
    f.colorButton:SetScript("OnClick", OnColorButtonClick)
    f.colorButton.setting = setting
    S.Utils.RunOnEvent(f.colorButton, "SettingChanged-"..setting, ColorButtonOnSettingChanged)

    f.nameString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.nameString:SetText(name)
    f.nameString:SetPoint("LEFT", f.colorButton, "RIGHT", 4, 0)
    f.nameString:SetTextColor(1, 1, 1)
    f.nameString:SetTextScale(1.2)

    return f
end


-- EditBox
local function EditBoxOnSettingChanged(self, event, value)
    self:SetText(value)
end
local function OnEditBoxTextChanged(self)
    S.Settings.Set(self.setting, self:GetText())
end
local function CreateEditBox(parent, name, setting, instruction)
    local f = S.FrameTools.CreateEditBox(parent, name, instruction)
    f.tooltipParent = f.editBox
    f.editBox.setting = setting
    f.editBox:HookScript("OnTextChanged", OnEditBoxTextChanged)
    f.editBox:SetScript("OnEnterPressed", f.editBox.ClearFocus)
    f.editBox:HookScript("OnShow", function(self)
        self:SetText(S.Settings.Get(self.setting))
    end)
    S.Utils.RunOnEvent(f.editBox, "SettingChanged-"..setting, EditBoxOnSettingChanged)
    return f
end


-- Spacer
local function CreateSpacer(parent, name)
    local f = CreateFrame("FRAME", nil, parent)
    f:SetSize(224, 48)
    if name then
        f.nameString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
        f.nameString:SetText(name)
        f.nameString:SetPoint("CENTER", 0, -16)
        f.nameString:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
        f.nameString:SetTextScale(1.2)
    end
    return f
end



-- BUILD SETTINGS FROM TABLE
local function CreateSettingWidget(parent, widgetData)
    local widget
    if not parent.y then
        parent.y = -16
    end
    if widgetData.type == "SLIDER" then
        widget = CreateSlider(parent, widgetData.name, widgetData.setting, widgetData.min, widgetData.max, widgetData.precision, widgetData.values, widgetData.curve)
    elseif widgetData.type == "CHECKBOX" then
        widget = CreateCheckbox(parent, widgetData.name, widgetData.setting)
    elseif widgetData.type == "RADIO" then
        widget = CreateRadio(parent, widgetData.name, widgetData.setting, widgetData.buttons)
    elseif widgetData.type == "DROPDOWN" then
        widget = CreateDropdown(parent, widgetData.name, widgetData.setting, widgetData.BuildDropdown, widgetData.GetTextFromValue)
    elseif widgetData.type == "COLOR" then
        widget = CreateColor(parent, widgetData.name, widgetData.setting)
    elseif widgetData.type == "SPACER" then
        widget = CreateSpacer(parent, widgetData.name)
    end
    widget:SetPoint("TOP", parent, "TOP", 0, parent.y)
    parent.y = parent.y - widget:GetHeight()

    if widgetData.tooltipKey and widget.tooltipParent then
        widget.tooltipParent.tooltipKey = widgetData.tooltipKey
        widget.tooltipParent:HookScript("OnEnter", function(self)
            S.Tooltip.CreateLocalized(self, "ANCHOR_RIGHT", self.tooltipKey)
        end)
        widget.tooltipParent:HookScript("OnLeave", S.Tooltip.Cancel)
    end
end

local settingsFrames = {}
for k,v in pairs(settingsTable) do
    local f = CreateFrame("FRAME")
    settingsFrames[k] = f
    f.name = settingsTable[k].name
    
    f.left = CreateFrame("FRAME", nil, f)
    f.left:SetPoint("TOPLEFT")
    f.left:SetPoint("BOTTOMRIGHT", f, "BOTTOM", -16, 0)
    for i, widget in ipairs(v.left) do
        CreateSettingWidget(f.left, widget)
    end
    
    f.right = CreateFrame("FRAME", nil, f)
    f.right:SetPoint("TOPLEFT", f, "TOP", -16, 0)
    f.right:SetPoint("BOTTOMRIGHT", -32, 0)
    for i, widget in ipairs(v.right) do
        CreateSettingWidget(f.right, widget)
    end
end






-- CREATE CATEGORIES FRAME (to be built by SettingsFrame_Categories.lua)
local f = CreateFrame("FRAME")
settingsFrames[#settingsFrames + 1] = f
f.name = S.Localize("CONFIG_CATEGORIES")
S.categoriesSettingsFrame = f









-- BUILD PROFILES FRAME
local f = CreateFrame("FRAME")
settingsFrames[#settingsFrames + 1] = f
f.name = S.Localize("CONFIG_PROFILES")
local function ProfileDropdownEntryOnClick(self)
    S.Settings.SetProfile(self.data1)
end
f.dropdown = CreateDropdown(f, S.Localize("CONFIG_PROFILES_PROFILE"), "profileName", function()
    local profile = S.Settings.GetProfile()
    for k, settingsProfile in pairs(Sorted_SettingsProfiles) do
        S.Dropdown.AddEntry(settingsProfile.profileName, ProfileDropdownEntryOnClick, k)
        S.Dropdown.AddRadioButton(profile == k, true)
    end
end)
f.dropdown:SetPoint("TOPLEFT", 64, -32)
f.dropdown:SetWidth(448)
f.buttonNew = S.FrameTools.CreateBasicTextButton(f, S.Localize("CONFIG_PROFILES_NEW"), function(self)
    local profile = S.Settings.CreateNewProfile(S.Localize("CONFIG_PROFILES_DEFAULT_NAME"))
end)
f.buttonCopy = S.FrameTools.CreateBasicTextButton(f, S.Localize("CONFIG_PROFILES_COPY"), S.Settings.CopyProfile)
f.buttonDelete = S.FrameTools.CreateBasicTextButton(f, S.Localize("CONFIG_PROFILES_DELETE"), function(self)
    S.Settings.DeleteProfile()
    if next(Sorted_SettingsProfiles) then
        S.Settings.SetProfile(next(Sorted_SettingsProfiles))
    else
        S.primaryFrame:Hide()
        S.settingsFrame:Hide()
        S.settingsProfilesFrame:Show()
        S.settingsProfilesFrame.source = "settings"
    end
end)
f.buttonCopy:SetPoint("TOP", f.dropdown, "BOTTOM")
f.buttonNew:SetPoint("RIGHT", f.buttonCopy, "LEFT")
f.buttonDelete:SetPoint("LEFT", f.buttonCopy, "RIGHT")

f.editBox = CreateEditBox(f, S.Localize("CONFIG_PROFILES_CHANGE_NAME"), "profileName", S.Localize("CONFIG_PROFILES_CHANGE_NAME_INSTRUCTION"))
f.editBox:SetPoint("TOPLEFT", f.dropdown, "BOTTOMLEFT", 0, -32)
f.editBox.editBox:SetSize(384, 16)

local defaultProfileDropdown
local function DefaultProfileDropdownEntryOnClick(self)
    S.Settings.SetDefaultProfile(self.data1)
    defaultProfileDropdown:UpdateText()
end
f.defaultDropdown = S.FrameTools.CreateDropdown(f, S.Localize("CONFIG_PROFILES_DEFAULT_PROFILE"), function()
    local profile = S.Settings.GetDefaultProfile()
    S.Dropdown.AddEntry("|cffdddddd"..S.Localize("CONFIG_PROFILES_DEFAULT_PROFILE_UNSET"), DefaultProfileDropdownEntryOnClick, nil)
    S.Dropdown.AddRadioButton(not profile, true)
    S.Dropdown.AddEntry(S.Localize("CONFIG_PROFILES_DEFAULT_PROFILE_USE_EXISTING"), nil, nil, nil, S.Color.YELLOW)
    for k, settingsProfile in pairs(Sorted_SettingsProfiles) do
        S.Dropdown.AddEntry(settingsProfile.profileName, DefaultProfileDropdownEntryOnClick, k)
        S.Dropdown.AddRadioButton(profile == k, true)
    end
end)
f.defaultDropdown:SetPoint("TOPLEFT", 64, -320)
function f.defaultDropdown:UpdateText()
    local profile = S.Settings.GetDefaultProfile()
    if not profile then
        self.button.text:SetText("|cffdddddd"..S.Localize("CONFIG_PROFILES_DEFAULT_PROFILE_UNSET"))
    else
        self.button.text:SetText(Sorted_SettingsProfiles[profile].profileName)
    end
end
f.defaultDropdown:SetScript("OnShow", f.defaultDropdown.UpdateText)
defaultProfileDropdown = f.defaultDropdown

-- "Clear all settings" button
f.buttonClearData = S.FrameTools.CreateBasicTextButton(f, S.Localize("CONFIG_PROFILES_CLEAR_DATA"), function(self)
    StaticPopupDialogs["SORTED_CLEAR_DATA"] = {
        text = S.Localize("CONFIG_PROFILES_CLEAR_DATA_DIALOG"),
        StartDelay = function() return 3 end,
        delayText = ACCEPT,
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept = function()
           Sorted_Data = nil
           Sorted_SettingsProfiles = nil
           Sorted_DefaultSettingsProfile = nil
           ReloadUI()
         end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("SORTED_CLEAR_DATA")
end)
f.buttonClearData:SetPoint("BOTTOMLEFT", 64, 32)
f.buttonClearData:SetWidth(128)




-- BUILD MAIN SETTINGS FRAME
f = CreateFrame("FRAME", "SortedSettingsFrame", UIParent)
S.settingsFrame = f
table.insert(UISpecialFrames, "SortedSettingsFrame")
function Sorted_OpenSettings()
    S.settingsFrame:Show()
end
f:SetPoint("CENTER")
f:SetSize(800, 576)
f:SetClampedToScreen(true)
f:EnableMouse()
f:SetMovable(true)
f:SetFrameStrata("HIGH")
f:SetFrameLevel(632)
S.FrameTools.AddOuterShadow(f, 100)

function f:UpdateScale()
    f:SetScale(S.Settings.Get("scale"))
end
S.Utils.RunOnEvent(f, "SettingChanged-scale", f.UpdateScale)

--S.FrameTools.AddSortedBackdrop(f)
f.bg = f:CreateTexture()
f.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Abstract", "REPEAT", "REPEAT")
f.bg:SetVertexColor(0.6, 0.6, 0.6)
f.bg:SetDrawLayer("BACKGROUND")
f.bg:SetAllPoints()
f.bg:SetVertTile(true)
f.bg:SetHorizTile(true)
f.closeButton = S.FrameTools.CreateCloseButton(f)
f.closeButton:SetSize(24, 24)
f.closeButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
f.closeButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
f.closeButton:GetHighlightTexture():SetTexCoord(0.1484375, 0.296875, 0, 0.3125)
f.closeButton:GetHighlightTexture():SetAlpha(0.6)
f.closeButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
 -- Prevent click-through and do dragging
f:SetScript("OnMouseDown", function(self) 
    self:StartMoving()
end)
f:SetScript("OnMouseUp", function(self) 
    self:StopMovingOrSizing()
end)
f:Hide()
f:SetScript("OnShow", function(self)
    if not S.Settings.HasProfile() then
        self:Hide()
        S.settingsProfilesFrame:Show()
        S.settingsProfilesFrame.source = "settings"
    end
end)

f.left = CreateFrame("FRAME", nil, f)
f.left:SetPoint("TOPLEFT")
f.left:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 192, 0)
f.left.bg = f.left:CreateTexture(nil, "BACKGROUND")
f.left.bg:SetColorTexture(0, 0, 0, 0.4)
f.left.bg:SetAllPoints()
f.left.title = f.left:CreateTexture(nil, "ARTWORK")
f.left.title:SetTexture("Interface\\Addons\\Sorted\\Textures\\Title")
f.left.title:SetPoint("TOPLEFT", 8, -8)
f.left.title:SetSize(192, 48)
f.left.buttons = {}
local selectedTab = 1
function f.left.UpdateButtons()
    for index, b in pairs(f.left.buttons) do
        if index == selectedTab then
            b.frame:Show()
            b.text:SetTextColor(1, 1, 1)
            b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Highlight")
            b:GetNormalTexture():SetVertexColor(0.9, 0.7, 0.04)
            b:GetNormalTexture():SetTexCoord(0, 1, 0.02, 0.98)
            b:GetNormalTexture():SetBlendMode("ADD")
        else
            b.frame:Hide()
            b.text:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
            b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Transparent")
        end
    end
end
local function OnButtonClick(self)
    selectedTab = self:GetID()
    f.left.UpdateButtons()
end
function f.left.AddButton(index, name)
    local b = CreateFrame("BUTTON", nil, f.left)
    b:SetSize(160, 40)
    b:SetPoint("TOP", 0, -64 - index * 48)
    b:SetID(index)
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Dropdown-Highlight")
    b:GetHighlightTexture():SetVertexColor(0.3, 0.5, 0.8)
    b:GetHighlightTexture():SetTexCoord(0, 1, 0.1, 0.9)
    b.text = b:CreateFontString(nil, "OVERLAY", "SortedFont")
    b.text:SetText(name)
    b.text:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
    b.text:SetTextScale(1.3)
    b.text:SetPoint("CENTER")
    b:RegisterForClicks("LeftButtonDown")
    b:SetScript("OnClick", OnButtonClick)
    f.left.buttons[index] = b
end

f.separator = f:CreateTexture(nil, "ARTWORK")
f.separator:SetTexture("Interface\\Addons\\Sorted\\Textures\\Settings-Separator")
f.separator:SetPoint("TOPLEFT", f.left, "TOPRIGHT")
f.separator:SetPoint("BOTTOM")
f.separator:SetWidth(2)

-- ADD SETTINGS TO FRAME
f.right = CreateFrame("FRAME", nil, f)
f.right:SetPoint("TOPLEFT", f.left, "TOPRIGHT")
f.right:SetPoint("BOTTOMRIGHT")

for i,v in ipairs(settingsFrames) do
    f.left.AddButton(i, v.name)
    v:SetParent(f.right)
    v:SetAllPoints()
    v:SetShown(i == selectedTab)
    f.left.buttons[i].frame = v
end
f.left.UpdateButtons()




-- Support
local urlFrame = CreateFrame("FRAME", nil, UIParent)
urlFrame:SetFrameStrata("DIALOG")
urlFrame:SetFrameLevel(1000)
urlFrame:SetPoint("CENTER")
urlFrame:SetSize(500, 220)
urlFrame:Hide()
urlFrame:SetScript("OnMouseDown", function(self) end)

S.FrameTools.AddBorder(urlFrame, "border", "Interface\\Addons\\Sorted\\Textures\\settings-border", 3, 0)
S.FrameTools.AddOuterShadow(urlFrame, 128)

urlFrame.bg = urlFrame:CreateTexture()
urlFrame.bg:SetAllPoints()
urlFrame.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Abstract", "REPEAT", "REPEAT")
urlFrame.bg:SetVertexColor(0.6, 0.6, 0.6)
urlFrame.bg:SetDrawLayer("BACKGROUND")
urlFrame.bg:SetVertTile(true)
urlFrame.bg:SetHorizTile(true)

urlFrame.closeButton = S.FrameTools.CreateCloseButton(urlFrame)
urlFrame.closeButton:SetSize(24, 24)
urlFrame.closeButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
urlFrame.closeButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
urlFrame.closeButton:GetHighlightTexture():SetTexCoord(0.1484375, 0.296875, 0, 0.3125)
urlFrame.closeButton:GetHighlightTexture():SetAlpha(0.6)
urlFrame.closeButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")

urlFrame.eb = S.FrameTools.CreateEditBox(urlFrame, "Thank you for supporting Sorted!", "")
urlFrame.eb:SetPoint("BOTTOM", 0, 40)

urlFrame.eb.nameString:ClearAllPoints()
urlFrame.eb.nameString:SetTextScale(1.4)
urlFrame.eb.nameString:SetPoint("TOP", urlFrame, 0, -20)

urlFrame.eb.message = urlFrame.eb:CreateFontString(nil, "OVERLAY", "SortedFont")
urlFrame.eb.message:SetPoint("TOP", urlFrame.eb.nameString, "BOTTOM", 0, -10)
urlFrame.eb.message:SetTextColor(0.9, 0.88, 0.82)
urlFrame.eb.message:SetText(
[[Sorted. is a huge addon, created and maintained by one person. 
It's taken many hours of development to get to this point 
and continues to take effort to keep it maintained.

Your donations mean a lot and allow me to put more 
time into working on and improving Sorted.]]
)
function urlFrame:UpdateSize()
    local width = urlFrame.eb.message:GetStringWidth() + 32
    if width < 450 then
        width = 450
    end
    local height = urlFrame.eb.nameString:GetHeight() + urlFrame.eb.message:GetHeight() + urlFrame.instruction:GetHeight() + 110
    self:SetSize(width, height)
end
urlFrame:HookScript("OnShow", urlFrame.UpdateSize)
S.Utils.RunOnEvent(urlFrame, "SettingChanged-font", urlFrame.UpdateSize)
S.Utils.RunOnEvent(urlFrame, "SettingChanged-fontSizePts", urlFrame.UpdateSize)

urlFrame.eb.editBox.url = ""
urlFrame.eb.editBox:SetAutoFocus(true)
urlFrame.eb.editBox:ClearAllPoints()
urlFrame.eb.editBox:SetPoint("CENTER", 64, -16)
urlFrame.eb.editBox:SetSize(280, 16)

urlFrame.icon = urlFrame:CreateTexture()
urlFrame.icon:SetPoint("RIGHT", urlFrame.eb.editBox, "LEFT", -25 , 0)
urlFrame.icon:SetSize(96, 24)

function urlFrame:ShowUrl(url, icon)
    self.icon:SetTexture(icon)
    self:Show()
    self.eb.editBox:SetText(url)
    self.eb.editBox:HighlightText(0)
    self.eb.editBox.url = url
end
urlFrame.eb.editBox:SetScript("OnUpdate", function(self)
    self:SetText(self.url)
    self:HighlightText(0)
end)
urlFrame.eb.editBox:SetScript("OnEscapePressed", function(self)
    urlFrame:Hide()
end)
urlFrame.eb.editBox:SetScript("OnEnterPressed", function(self)
    urlFrame:Hide()
end)

urlFrame.inputBlocker = CreateFrame("FRAME", nil, urlFrame)
urlFrame.inputBlocker:SetFrameLevel(urlFrame:GetFrameLevel() + 10)
urlFrame.closeButton:SetFrameLevel(urlFrame:GetFrameLevel() + 20)
urlFrame.inputBlocker:SetAllPoints()
urlFrame.inputBlocker:SetScript("OnMouseDown", function(self) end)

urlFrame.instruction = urlFrame:CreateFontString(nil, "OVERLAY", "SortedFont")
urlFrame.instruction:SetText("Copy URL with Ctrl + C and paste into a web browser")
urlFrame.instruction:SetPoint("BOTTOM", 0, 20)

--[[local patreonIcon = "Interface\\Addons\\Sorted\\Textures\\Patreon"
f.patreon = CreateFrame("BUTTON", nil, f.left)
f.patreon:SetPoint("BOTTOM", 0, 32)
f.patreon:SetSize(96, 24)
f.patreon:SetNormalTexture(patreonIcon)
f.patreon:SetHighlightTexture(patreonIcon)
f.patreon:SetPushedTexture(patreonIcon)
f.patreon:SetScript("OnMouseDown", function(self)
    self:SetPoint("BOTTOM", 1, 31)
end)
f.patreon:SetScript("OnMouseUp", function(self)
    self:SetPoint("BOTTOM", 0, 32)
end)
f.patreon:SetScript("OnClick", function(self)
    urlFrame:ShowUrl("https://www.patreon.com/sorted", patreonIcon)
end)
f.patreon:SetScript("OnEnter", function(self)
    S.Tooltip.CreateText(f.patreon, "LEFT", "Donate to support\n   the developer")
end)
f.patreon:SetScript("OnLeave", function(self)
    S.Tooltip.Cancel()
end)]]

local paypalIcon = "Interface\\Addons\\Sorted\\Textures\\Paypal"
f.paypal = CreateFrame("BUTTON", nil, f.left)
f.paypal:SetPoint("BOTTOM", 0, 32)
f.paypal:SetSize(96, 24)
f.paypal:SetNormalTexture(paypalIcon)
f.paypal:SetHighlightTexture(paypalIcon)
f.paypal:SetPushedTexture(paypalIcon)
f.paypal:SetScript("OnMouseDown", function(self)
    self:SetPoint("BOTTOM", 1, 31)
end)
f.paypal:SetScript("OnMouseUp", function(self)
    self:SetPoint("BOTTOM", 0, 32)
end)
f.paypal:SetScript("OnClick", function(self)
    urlFrame:ShowUrl("https://www.paypal.com/donate/?hosted_button_id=DT3CRNZLMNYFG", paypalIcon)
end)
f.paypal:SetScript("OnEnter", function(self)
    S.Tooltip.CreateText(f.paypal, "LEFT", "Donate to support\n   the developer")
end)
f.paypal:SetScript("OnLeave", function(self)
    S.Tooltip.Cancel()
end)