local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local f = S.categoriesSettingsFrame

local GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem = GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem
if C_Item then
    GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem = C_Item.GetItemInfoInstant, C_Item.GetItemInfo, C_Item.GetItemClassInfo, C_Item.GetItemSubClassInfo, C_Item.GetDetailedItemLevelInfo, C_Item.IsEquippableItem
end

-- Initialise the category import and export frames
local importFrame = CreateFrame("FRAME", nil, UIParent)
local exportFrame = CreateFrame("FRAME", nil, UIParent)



-- Title
f.title = f:CreateFontString(nil, "OVERLAY", "SortedFont")
f.title:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
f.title:SetPoint("TOPLEFT", f, 20, -28)
f.title:SetText(S.Localize("GROUPING_CATEGORY"))
f.title:SetTextScale(1.2)


-- Category buttons
f.selectedCategory = 1
f.categoryButtons = {}

local dragging = nil

local function CategoryButtonOnMouseDown(self)
    dragging = self:GetID()
end
local function CategoryButtonOnMouseUp(self)
    dragging = nil
end
local function CategoryButtonOnEnter(self)
    if dragging then
        local data = S.Settings.Get("categories2")
        local category1 = data[dragging]
        local category2 = data[self:GetID()]
        data[self:GetID()] = category1
        data[dragging] = category2
        dragging = self:GetID()
        S.Utils.TriggerEvent("SettingChanged-categories2")
    end
    self.icon:SetDesaturated(false)
    if self.name then
        S.Tooltip.Schedule(function()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self.name)
            GameTooltip:Show()
        end)
    end
end
local function CategoryButtonOnLeave(self)
    if not self:GetChecked() then
        self.icon:SetDesaturated(true)
    end
    S.Tooltip.Cancel()
end
local function CategoryButtonUpdate(self)
    local id = self:GetID()
    if id == f.selectedCategory then
        self:SetChecked(true)
        self.icon:SetDesaturated(false)
    else
        self:SetChecked(false)
        self.icon:SetDesaturated(true)
    end
end
local function CategoryButtonOnClick(self)
    f.selectedCategory = self:GetID()
    for _, button in pairs(f.categoryButtons) do
        CategoryButtonUpdate(button)
    end
    S.Utils.TriggerEvent("SettingsFrame-CategorySelected")
end

for i = 1, S.Utils.GetMaxNumCategories() do
    local b = S.FrameTools.CreateCircleButton("CheckButton", f, false, "", true)
    b:SetID(i)
    b.icon:SetDesaturated(true)
    b:HookScript("OnMouseDown", CategoryButtonOnMouseDown)
    b:HookScript("OnMouseUp", CategoryButtonOnMouseUp)
    b:HookScript("OnEnter", CategoryButtonOnEnter)
    b:HookScript("OnLeave", CategoryButtonOnLeave)
    b:SetScript("OnClick", CategoryButtonOnClick)
    b:SetSize(32, 32)
    local x = (i - 1) % 18 * 31
    local y = 31 * (math.floor((i - 1) / 18) + 1)
    b:SetPoint("TOPLEFT", x + 44, -y - 16)
    table.insert(f.categoryButtons, b)
    b:SetScript("OnShow", function(self)
        self:SetChecked(self:GetID() == f.selectedCategory)
    end)
end

function f:UpdateCategoryButtons()
    local data = S.Settings.Get("categories2")
    if f.selectedCategory > #data then
        f.selectedCategory = 1
    end
    for _, button in pairs(self.categoryButtons) do
        local id = button:GetID()
        if data[id] then
            button:SetAlpha(1)
            button:Enable()
            button.name = data[id].name
            button:SetIconTexture(S.Category.GetIconTexture(id))
            if f.selectedCategory == id then
                CategoryButtonUpdate(button)
            end
        else
            button:SetAlpha(0.2)
            button:Disable()
            button:SetIconTexture("")
        end
    end
end
S.Utils.RunOnEvent(f, "SettingChanged-categories2", f.UpdateCategoryButtons)
f:HookScript("OnShow", f.UpdateCategoryButtons)
f:HookScript("OnHide", function(self)
    importFrame:Hide()
    exportFrame:Hide()
end)

-- Add category button
f.addButton = CreateFrame("BUTTON", nil, f)
f.addButton:SetPoint("TOPLEFT", 10, -48)
f.addButton:SetSize(30, 30)
f.addButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Expand-Button")
f.addButton:GetNormalTexture():SetTexCoord(0, 0.375, 0, 0.375)
f.addButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Close-Button-Highlight")
f.addButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Expand-Button")
f.addButton:GetPushedTexture():SetTexCoord(0.375, 0.75, 0, 0.375)
function f.addButton:Update()
    local data = S.Settings.Get("categories2")
    if #data >= S.Utils.GetMaxNumCategories() then
        self:Disable()
        self:GetNormalTexture():SetDesaturated(true)
    else
        self:Enable()
        self:GetNormalTexture():SetDesaturated(false)
    end
end
S.Utils.RunOnEvent(f.addButton, "SettingChanged-categories2", f.addButton.Update)

f.addButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(S.Localize("CONFIG_CATEGORIES_ADD"))
    GameTooltip:Show()
end)
f.addButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
f.addButton:SetScript("OnClick", function(self)
    S.Category.AddNew()
    
    local data = S.Settings.Get("categories2")
    CategoryButtonOnClick(f.categoryButtons[#data])
end)


-- Delete category button
f.deleteButton = CreateFrame("BUTTON", nil, f)
f.deleteButton:SetPoint("TOPLEFT", 10, -78)
f.deleteButton:SetSize(30, 30)
f.deleteButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Expand-Button")
f.deleteButton:GetNormalTexture():SetTexCoord(0, 0.375, 0.375, 0.75)
f.deleteButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Close-Button-Highlight")
f.deleteButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Expand-Button")
f.deleteButton:GetPushedTexture():SetTexCoord(0.375, 0.75, 0.375, 0.75)
f.deleteButton:SetScript("OnClick", function(self)
    if f.selectedCategory > 1 then
        f.selectedCategory = f.selectedCategory - 1
        S.Category.Delete(f.selectedCategory + 1)
    elseif #S.Settings.Get("categories2") > 1 then
        S.Category.Delete(f.selectedCategory)
    end
    S.Utils.TriggerEvent("SettingsFrame-CategorySelected")
    for _, button in pairs(f.categoryButtons) do
        CategoryButtonUpdate(button)
    end
end)
f.deleteButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(DELETE.. " \""..S.Category.GetName(f.selectedCategory).."\"")
    GameTooltip:Show()
end)
f.deleteButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)


-- Spacer
f.spacer = f:CreateTexture()
f.spacer:SetPoint("LEFT", 2, 0)
f.spacer:SetPoint("RIGHT")
f.spacer:SetHeight(16)
f.spacer:SetPoint("TOP", 0, -120)
f.spacer:SetTexture("Interface\\Addons\\Sorted\\Textures\\Spacer")
f.spacer:SetTexCoord(0.1, 0.9, 0, 1)


-- Name
f.nameEditBox = S.FrameTools.CreateEditBox(f, S.Localize("CONFIG_CATEGORIES_NAME"), S.Localize("CONFIG_PROFILES_CHANGE_NAME_INSTRUCTION"))
f.nameEditBox:SetPoint("TOPLEFT", 140, -128)
f.nameEditBox.editBox:SetSize(320, 16)
function f.nameEditBox:Update()
    self.editBox:SetText(S.Category.GetName(f.selectedCategory))
end
S.Utils.RunOnEvent(f.nameEditBox, "SettingsFrame-CategorySelected", f.nameEditBox.Update)
S.Utils.RunOnEvent(f.nameEditBox, "SettingChanged-categories2", f.nameEditBox.Update)
f.nameEditBox:HookScript("OnShow", f.nameEditBox.Update)
f.nameEditBox.editBox:HookScript("OnTextChanged", function(self)
    S.Category.SetName(f.selectedCategory, self:GetText())
end)
f.nameEditBox.editBox:HookScript("OnEnterPressed", f.nameEditBox.editBox.ClearFocus)
f.nameEditBox.editBox:HookScript("OnEscapePressed", f.nameEditBox.editBox.ClearFocus)
f.nameEditBox.editBox:SetAutoFocus(false)

-- Icon
f.iconText = f:CreateFontString(nil, "OVERLAY", "SortedFont")
f.iconText:SetText(S.Localize("CONFIG_CATEGORIES_ICON"))
f.iconText:SetPoint("TOPLEFT", 500, -140)
f.iconText:SetTextColor(S.Utils.GetButtonTextColor():GetRGB())
f.iconText:SetTextScale(1.2)
f.icon = S.FrameTools.CreateCircleButton("Button", f, true, "", true)
f.icon:SetPoint("TOPLEFT", 500, -158)
f.icon:SetSize(48, 48)
function f.icon:Update()
    self:SetIconTexture(S.Category.GetIconTexture(f.selectedCategory))
end
S.Utils.RunOnEvent(f.icon, "SettingsFrame-CategorySelected", f.icon.Update)
S.Utils.RunOnEvent(f.icon, "SettingChanged-categories2", f.icon.Update)
f.icon:SetScript("OnShow", f.icon.Update)
local function OnIconPicked(icon)
    S.Category.SetIcon(f.selectedCategory, icon)
end
f.icon:SetScript("OnClick", function(self, button, down)
    S.IconPicker.Show(self, OnIconPicked)
end)


-- Spacer
f.spacer = f:CreateTexture()
f.spacer:SetPoint("LEFT", 2, 0)
f.spacer:SetPoint("RIGHT")
f.spacer:SetHeight(16)
f.spacer:SetPoint("TOP", 0, -212)
f.spacer:SetTexture("Interface\\Addons\\Sorted\\Textures\\Spacer")
f.spacer:SetTexCoord(0.1, 0.9, 0, 1)



-- ATTRIBUTES

-- Attributes dropdown
f.selectedAttribute = "TYPE"
local function OnAttributesEntryClick(self)
    f.selectedAttribute = self.data1
    S.Utils.TriggerEvent("SettingsFrame-CategoryAttributeSelected")
    S.Dropdown.Hide()
end
local function SortAttributesDropdownEntries(a, b)
    if a.type ~= b.type then
        return a.type < b.type
    else
        return a.name < b.name
    end
end
local TYPE_NAMES = {
    ["SPECIFIC_ITEMS"] = S.Localize("FILTER_SPECIFIC_ITEMS"),
    ["STRINGS"] = SEARCH,
    ["VALUES"] = S.Localize("FILTER_VALUES")
}
local function BuildAttributesDropdown()
    local data = S.Settings.Get("categories2")[f.selectedCategory]

    local t = {}
    for k, v in pairs(S.Category.attributesTable) do
        table.insert(t, {["name"] = v.name, ["key"] = k, ["type"] = v.type})
    end
    table.sort(t, SortAttributesDropdownEntries)

    local lastType
    for i, v in ipairs(t) do
        if v.type ~= lastType then
            S.Dropdown.AddEntry(TYPE_NAMES[v.type], nil, nil, nil, S.Utils.GetButtonTextColor())
            S.Dropdown.SetHeading()
            lastType = v.type
        end
        S.Dropdown.AddEntry(v.name, OnAttributesEntryClick, v.key)
        S.Dropdown.AddRadioButton(data.attributes[v.key])
    end
end
f.attributes = S.FrameTools.CreateDropdown(f, STAT_CATEGORY_ATTRIBUTES, BuildAttributesDropdown)
f.attributes:SetPoint("TOP", 0, -232)
f.attributes.radio = f.attributes.border:CreateTexture(nil, "OVERLAY", nil, 2)
f.attributes.radio:SetTexture("Interface\\Addons\\Sorted\\Textures\\Radio-Button-Dot")
f.attributes.radio:SetTexCoord(0.1, 0.9, 0.1, 0.9)
f.attributes.radio:SetPoint("RIGHT", f.attributes.button.text, "LEFT", -4, 0)
f.attributes.radio:SetSize(18, 18)

function f.attributes:Update()
    self.button.text:SetText(S.Category.attributesTable[f.selectedAttribute].name)
    f.attributes.radio:SetShown(S.Settings.Get("categories2")[f.selectedCategory].attributes[f.selectedAttribute])
end
f.attributes:SetScript("OnShow", f.attributes.Update)
S.Utils.RunOnEvent(f.attributes, "SettingsFrame-CategoryAttributeSelected", f.attributes.Update)

function f.attributes:OnCategoryChanged()
    local data = S.Settings.Get("categories2")[f.selectedCategory]
    local attributeIsModified = data.attributes[f.selectedAttribute]
    if not attributeIsModified then
        -- Find an attribute that is modified
        for k,v in pairs(S.Category.attributesTable) do
            attributeIsModified = data.attributes[k]
            if attributeIsModified then
                f.selectedAttribute = k
                S.Utils.TriggerEvent("SettingsFrame-CategoryAttributeSelected")
                break
            end
        end
    end
    f.attributes:Update()
end
S.Utils.RunOnEvent(f.attributes, "SettingsFrame-CategorySelected", f.attributes.OnCategoryChanged)



-- ATTRIBUTE SETTINGS
-- Make one frame to contain all the attribute settings
f.attributesFrame = CreateFrame("FRAME", nil, f)
local af = f.attributesFrame
af:SetPoint("TOPLEFT", 0, -320)
af:SetPoint("BOTTOMRIGHT")
af:SetScript("OnMouseDown", function() return end)



local function UpdateIncludeButtonTooltip(self)
    if self:GetTicked() then
        S.Tooltip.CreateText(self, "ANCHOR_TOPRIGHT", "|cff33ee22"..S.Localize("CONFIG_CATEGORIES_INCLUDE"))
    else
        S.Tooltip.CreateText(self, "ANCHOR_TOPRIGHT", "|cffff1133"..S.Localize("CONFIG_CATEGORIES_EXCLUDE"))
    end
end


-- Values (checkbuttons in a dropdown menu)
local function OnValuesEntryClick(self)
    local data = S.Category.ToggleAttributeValue(f.selectedCategory, f.selectedAttribute, self.data1)
end
local function SortValuesTable(v1, v2)
    return v1.key < v2.key
end
local function BuildValuesDropdown(data1)
    local data = S.Category.GetAttribute(f.selectedCategory, f.selectedAttribute)
    local valuesSorted = {}
    for k,v in pairs(data1) do
        table.insert(valuesSorted, {
            ["key"] = k, 
            ["value"] = v
        })
    end
    table.sort(valuesSorted, SortValuesTable)

    local heading = nil
    for i,v in ipairs(valuesSorted) do
        if v.value.heading ~= heading then
            S.Dropdown.AddEntry(v.value.heading, nil, nil, nil, S.Utils.GetButtonTextColor())
            heading = v.value.heading
        end
        S.Dropdown.AddEntry(v.value.name, OnValuesEntryClick, v.key)
        if data then
            S.Dropdown.AddCheckbox(data[v.key])
        else
            S.Dropdown.AddCheckbox(false)
        end
    end
end
local function CreateValues(parent, key, name, values)
    local f = S.FrameTools.CreateDropdown(parent, name, BuildValuesDropdown, values)
    f:SetPoint("TOP", 0, -64)
    f:SetWidth(384)
    f.button.text:SetText(S.Localize("DROPDOWN_MENU_INSTRUCTION_SELECT"))
    return f
end

-- Strings (list of edit boxes)
local function OnStringsEditBoxTextChanged(self)
    S.Category.SetAttributeString(f.selectedCategory, f.selectedAttribute, self.index, self:GetText())
    if #self:GetText() > 0 then
        self.parent:GetStringsEditBox(self.index + 1)
    end
    self.parent:UpdateStrings()
    S.Utils.TriggerEvent("SettingsFrame-CategoryAttributeSelected")
    S.Utils.TriggerEvent("CategorySelected")
end
local function Strings_OnTickButtonClick(self)
    UpdateIncludeButtonTooltip(self)
    S.Category.SetAttributeStringIncluded(f.selectedCategory, f.selectedAttribute, self.index, self:GetTicked())
    S.Utils.TriggerEvent("SettingsFrame-CategoryAttributeSelected")
    S.Utils.TriggerEvent("CategorySelected")
end
local function CreateStringsEditBox(self, index)
    self.editBoxes[index] = S.FrameTools.CreateEditBox(self, "", SEARCH)
    self.editBoxes[index]:SetPoint("TOPLEFT", 64, -index * 40 + 80)
    self.editBoxes[index].editBox:SetWidth(480)
    self.editBoxes[index].editBox:HookScript("OnTextChanged", OnStringsEditBoxTextChanged)
    self.editBoxes[index].editBox.parent = self
    self.editBoxes[index].editBox.index = index

    local include = S.FrameTools.CreateTickButton(self.editBoxes[index])
    include:SetPoint("RIGHT", self.editBoxes[index].editBox, "LEFT", -8, 0)
    include:HookScript("OnEnter", UpdateIncludeButtonTooltip)
    include:HookScript("OnLeave", S.Tooltip.Cancel)
    include:HookScript("OnClick", Strings_OnTickButtonClick)
    include.parent = self
    include.index = index
    self.editBoxes[index].include = include
end
local function GetStringsEditBox(self, index)
    if not self.editBoxes[index] then
        CreateStringsEditBox(self, index)
    end
    self.editBoxes[index]:Show()
    return self.editBoxes[index]
end
local function UpdateStrings(self)
    local data = S.Category.GetAttribute(f.selectedCategory, f.selectedAttribute)
    if data then
        local i = 1
        while i <= #data do
            GetStringsEditBox(self, i).editBox:SetText(data[i].str)
            GetStringsEditBox(self, i).include:Show()
            GetStringsEditBox(self, i).include:SetTicked(not data[i].exclude)
            i = i + 1
        end
        -- Add one more empty edit box
        GetStringsEditBox(self, i).editBox:SetText("")
        GetStringsEditBox(self, i).include:Hide()
        self.parent.scrollBar:SetMinMaxValues(0, i * 40 - 40)
        i = i + 1
        while i <= #self.editBoxes do
            self.editBoxes[i]:Hide()
            i = i + 1
        end
    else
        for i,v in ipairs(self.editBoxes) do
            v:SetShown(i == 1)
            v.editBox:SetText("")
            v.include:Hide()
            self.parent.scrollBar:SetMinMaxValues(0, 0)
        end
    end
end
local function CreateStrings(parent, key, name)
    local f = CreateFrame("SCROLLFRAME", nil, parent)
    f:SetAllPoints()

    f.scrollBar = CreateFrame("SLIDER", "", f, "MinimalScrollBarTemplate")
    f.scrollBar.trackBG:Hide()
    f.scrollBar:SetPoint("TOPRIGHT")
    f.scrollBar:SetPoint("BOTTOM", 0, 16)
    f.scrollBar:SetMinMaxValues(0, 200)
    f.scrollBar:SetValue(0)
    f.scrollBar.Update = function(self)
        f:SetVerticalScroll(f.scrollBar:GetValue())
    end
    f.scrollBar:SetScript("OnValueChanged", f.scrollBar.Update)
    f:SetScript("OnMouseWheel", function(self, delta)
        f.scrollBar:SetValue(f.scrollBar:GetValue() - delta * 32)
        f.scrollBar:Update()
    end)

    f.scrollChild = CreateFrame("FRAME", nil, f)
    f.scrollChild:SetSize(f:GetWidth(), 200)
    f:SetScrollChild(f.scrollChild)

    f.scrollChild.editBoxes = {}
    CreateStringsEditBox(f.scrollChild, 1)

    f.scrollChild.UpdateStrings = UpdateStrings
    f.scrollChild.GetStringsEditBox = GetStringsEditBox
    f.scrollChild.parent = f
    f.scrollChild:SetScript("OnShow", UpdateStrings)
    S.Utils.RunOnEvent(f.scrollChild, "SettingsFrame-CategorySelected", function(self)
        if S.categoriesSettingsFrame.selectedAttribute == key then
            UpdateStrings(self)
        end
    end)
end

-- Specific items (list of edit boxes for Item ID and Item Name, with an icon, for each specific item)
local function OnItemIDEditBoxTextChanged(self, userInput)
    if userInput then
        self:SetText(self:GetText():gsub("[^%d]", ""))
        local itemID = tonumber(self:GetText())
        if itemID then
            local name, _, quality = GetItemInfo(itemID)
            if name then
                self.itemName:SetText(name)
            else
                self.itemName:SetText("")
            end
        else
            self.itemName:SetText("")
        end
        S.Category.SetAttributeSpecificItem(f.selectedCategory, f.selectedAttribute, self.index, itemID, self.itemName:GetText())
        if #self:GetText() > 0 then
            self.parent:GetSpecificItem(self.index + 1)
        end
        self.parent:UpdateSpecificItems()
        S.Utils.TriggerEvent("SettingsFrame-CategoryAttributeSelected")
        S.Utils.TriggerEvent("CategorySelected")
    end
end
local function OnItemNameEditBoxTextChanged(self, userInput)
    if userInput then
        local itemID = GetItemInfoInstant(self:GetText())
        if itemID then
            self.itemID:SetText(itemID)
        else
            self.itemID:SetText("")
        end
        S.Category.SetAttributeSpecificItem(f.selectedCategory, f.selectedAttribute, self.index, tonumber(self.itemID:GetText()), self:GetText())
        if #self:GetText() > 0 then
            self.parent:GetSpecificItem(self.index + 1)
        end
        self.parent:UpdateSpecificItems()
        S.Utils.TriggerEvent("SettingsFrame-CategoryAttributeSelected")
        S.Utils.TriggerEvent("CategorySelected")
    end
end
local function SpecificItem_OnTickButtonClick(self)
    UpdateIncludeButtonTooltip(self)
    S.Category.SetAttributeSpecificItemIncluded(f.selectedCategory, f.selectedAttribute, self.index, self:GetTicked())
    S.Utils.TriggerEvent("SettingsFrame-CategoryAttributeSelected")
    S.Utils.TriggerEvent("CategorySelected")
end
local function CreateSpecificItem(self, index)
    self.specificItems[index] = CreateFrame("FRAME", "", self)
    self.specificItems[index]:SetAllPoints()

    local itemID = S.FrameTools.CreateEditBox(self.specificItems[index], "", "ID")
    itemID:SetPoint("TOPLEFT", 60 + 48, -index * 40 + 80)
    itemID.editBox:SetWidth(128)
    itemID.editBox:HookScript("OnTextChanged", OnItemIDEditBoxTextChanged)
    itemID.editBox.parent = self
    itemID.editBox.index = index
    self.specificItems[index].itemID = itemID

    local icon = itemID:CreateTexture()
    icon:SetPoint("RIGHT", itemID.editBox, "LEFT", -8, 0)
    icon:SetSize(32, 32)
    icon:SetTexture("Interface\\Addons\\Sorted\\Textures\\Portrait")
    self.specificItems[index].icon = icon

    local itemName = S.FrameTools.CreateEditBox(self.specificItems[index], "", NAME)
    itemName:SetPoint("TOPLEFT", 48 + 64 + 140, -index * 40 + 80)
    itemName.editBox:SetWidth(310)
    itemName.editBox:HookScript("OnTextChanged", OnItemNameEditBoxTextChanged)
    itemName.editBox.parent = self
    itemName.editBox.index = index
    self.specificItems[index].itemName = itemName

    itemID.editBox.itemName = itemName.editBox
    itemID.editBox.icon = icon
    itemName.editBox.itemID = itemID.editBox
    itemName.editBox.icon = icon

    local include = S.FrameTools.CreateTickButton(self.specificItems[index])
    include:SetPoint("RIGHT", icon, "LEFT", -4, 0)
    include:HookScript("OnEnter", UpdateIncludeButtonTooltip)
    include:HookScript("OnLeave", S.Tooltip.Cancel)
    include:HookScript("OnClick", SpecificItem_OnTickButtonClick)
    include.parent = self
    include.index = index
    self.specificItems[index].include = include
end
local function GetSpecificItem(self, index)
    if not self.specificItems[index] then
        CreateSpecificItem(self, index)
    end
    self.specificItems[index]:Show()
    return self.specificItems[index]
end
local function UpdateSpecificItems(self)
    local data = S.Category.GetAttribute(f.selectedCategory, f.selectedAttribute)
    if data then
        local i = 1
        while i <= #data do
            local specificItem = GetSpecificItem(self, i)
            local icon
            if data[i].itemID then
                icon = GetItemIcon(data[i].itemID)
                specificItem.itemID.editBox:SetText(data[i].itemID)
            end

            if data[i].itemName then
                if not icon then
                    icon = GetItemIcon(data[i].itemName)
                end
                specificItem.itemName.editBox:SetText(data[i].itemName)

                local name, _, quality = GetItemInfo(data[i].itemName)
                if quality then
                    specificItem.itemName.editBox:SetTextColor(S.Utils.GetItemQualityColor(quality):GetRGB())
                else
                    specificItem.itemName.editBox:SetTextColor(S.Color.WHITE:GetRGB())
                end
            end

            if icon then
                specificItem.icon:SetTexture(icon)
            else
                specificItem.icon:SetTexture("")
            end

            specificItem.include:Show()
            specificItem.include:SetTicked(not data[i].exclude)

            i = i + 1
        end
        -- Add one more empty edit box
        GetSpecificItem(self, i).itemID.editBox:SetText("")
        GetSpecificItem(self, i).itemName.editBox:SetText("")
        GetSpecificItem(self, i).icon:SetTexture("")
        GetSpecificItem(self, i).include:Hide()
        self.parent.scrollBar:SetMinMaxValues(0, i * 40 - 40)
        i = i + 1
        while i <= #self.specificItems do
            self.specificItems[i]:Hide()
            i = i + 1
        end
    else
        for i,v in ipairs(self.specificItems) do
            v:SetShown(i == 1)
            v.itemID.editBox:SetText("")
            v.itemName.editBox:SetText("")
            v.icon:SetTexture("")
            v.include:Hide()
            self.parent.scrollBar:SetMinMaxValues(0, 0)
        end
    end
end
local function CreateSpecificItems(parent, key, name)
    local f = CreateFrame("SCROLLFRAME", nil, parent)
    f:SetAllPoints()

    f.scrollBar = CreateFrame("SLIDER", "", f, "MinimalScrollBarTemplate")
    f.scrollBar.trackBG:Hide()
    f.scrollBar:SetPoint("TOPRIGHT")
    f.scrollBar:SetPoint("BOTTOM", 0, 16)
    f.scrollBar:SetMinMaxValues(0, 200)
    f.scrollBar:SetValue(0)
    f.scrollBar.Update = function(self)
        f:SetVerticalScroll(f.scrollBar:GetValue())
    end
    f.scrollBar:SetScript("OnValueChanged", f.scrollBar.Update)
    f:SetScript("OnMouseWheel", function(self, delta)
        f.scrollBar:SetValue(f.scrollBar:GetValue() - delta * 32)
        f.scrollBar:Update()
    end)

    f.scrollChild = CreateFrame("FRAME", nil, f)
    f.scrollChild:SetSize(f:GetWidth(), 200)
    f:SetScrollChild(f.scrollChild)

    f.scrollChild.specificItems = {}
    CreateSpecificItem(f.scrollChild, 1)

    f.scrollChild.UpdateSpecificItems = UpdateSpecificItems
    f.scrollChild.GetSpecificItem = GetSpecificItem
    f.scrollChild.parent = f
    f.scrollChild:SetScript("OnShow", UpdateSpecificItems)
    S.Utils.RunOnEvent(f.scrollChild, "SettingsFrame-CategorySelected", function(self)
        if S.categoriesSettingsFrame.selectedAttribute == key then
            UpdateSpecificItems(self)
        end
    end)
end


-- Build a settings frame for each attribute
local attributeFrames = {}
for k, v in pairs(S.Category.attributesTable) do
    local frame = CreateFrame("FRAME", nil, f.attributesFrame)
    frame:SetAllPoints()
    attributeFrames[k] = frame

    if v.type == "VALUES" then
        CreateValues(frame, k, v.name, v.values)
    elseif v.type == "STRINGS" then
        CreateStrings(frame, k, v.name)
    elseif v.type == "SPECIFIC_ITEMS" then
        CreateSpecificItems(frame, k, v.name)
    end

    frame:Hide()
end
local function UpdateAttributeFrames()
    for k,v in pairs(attributeFrames) do
        if f.selectedAttribute == k then
            v:Show()
        else
            v:Hide()
        end
    end
end
S.Utils.RunOnEvent(nil, "SettingsFrame-CategoryAttributeSelected", UpdateAttributeFrames)
f.attributesFrame:SetScript("OnShow", UpdateAttributeFrames)






-- IMPORTING
-- Window
local function CreateImportFrame()
    if not importFrame.created then
        importFrame.created = true
        importFrame:SetFrameStrata("DIALOG")
        importFrame:SetFrameLevel(2935)
        importFrame:SetPoint("CENTER")
        importFrame:SetSize(440, 280)
        importFrame:SetClampedToScreen(true)
        importFrame:SetMovable(true)
        importFrame:SetScript("OnMouseDown", importFrame.StartMoving)
        importFrame:SetScript("OnMouseUp", importFrame.StopMovingOrSizing)
        importFrame:SetScript("OnShow", function(self) 
            exportFrame:Hide() 
            self:ClearAllPoints()
            self:SetPoint("CENTER")
            self:SetSize(440, 280)
        end)
        exportFrame:Hide()

        S.FrameTools.AddOuterShadow(importFrame, 100)

        importFrame.bg = importFrame:CreateTexture()
        importFrame.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Abstract", "REPEAT", "REPEAT")
        importFrame.bg:SetVertexColor(0.6, 0.6, 0.6)
        importFrame.bg:SetDrawLayer("BACKGROUND")
        importFrame.bg:SetAllPoints()
        importFrame.bg:SetVertTile(true)
        importFrame.bg:SetHorizTile(true)

        S.FrameTools.AddBorder(importFrame, "border", "Interface\\Addons\\Sorted\\Textures\\settings-border", 3, 0)

        importFrame.closeButton = S.FrameTools.CreateCloseButton(importFrame)
        importFrame.closeButton:SetSize(32, 32)
        importFrame.closeButton:SetPoint("TOPRIGHT", -4, -4)
        importFrame.closeButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
        importFrame.closeButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
        importFrame.closeButton:GetHighlightTexture():SetTexCoord(0.1484375, 0.296875, 0, 0.3125)
        importFrame.closeButton:GetHighlightTexture():SetAlpha(0.6)
        importFrame.closeButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")

        importFrame.tip = importFrame:CreateFontString(nil, "OVERLAY", "SortedFont")
        importFrame.tip:SetPoint("TOP", 0, -20)
        importFrame.tip:SetTextScale(1.3)
        importFrame.tip:SetTextColor(1, 0.9, 0)
        importFrame.tip:SetText(S.Localize("CONFIG_CATEGORIES_IMPORT_TIP"))

        importFrame.scrollFrame = CreateFrame("ScrollFrame", nil, importFrame, "UIPanelScrollFrameTemplate")
        importFrame.scrollFrame:SetFrameLevel(importFrame:GetFrameLevel() + 10)
        importFrame.scrollFrame:SetSize(336, 120)
        importFrame.scrollFrame:SetPoint("TOP", -11, -56)
        S.FrameTools.AddBorder(importFrame.scrollFrame, "border", "Interface\\Addons\\Sorted\\Textures\\Rounded-Border", -2, 8, true)
        importFrame.scrollFrame.border:ClearAllPoints()
        importFrame.scrollFrame.border:SetPoint("TOPLEFT")
        importFrame.scrollFrame.border:SetPoint("BOTTOMRIGHT", 22, 0)
        importFrame.scrollFrame.border:SetFrameLevel(importFrame.scrollFrame:GetFrameLevel() - 1)
        for k,v in pairs(importFrame.scrollFrame.border.parts) do
            v:SetVertexColor(0.8, 0.8, 0.8)
        end
        importFrame.scrollFrame:SetScript("OnMouseDown", function(self)
            importFrame.editBox:SetFocus()
        end)

        importFrame.editBox = CreateFrame("EditBox", nil, importFrame.scrollFrame)
        importFrame.editBox:SetFrameLevel(importFrame.scrollFrame:GetFrameLevel() + 2)
        importFrame.editBox:SetFontObject("SortedFont")
        importFrame.editBox:SetAutoFocus(false)
        importFrame.editBox:SetMultiLine(true)
        importFrame.editBox:SetWidth(336)
        importFrame.scrollFrame:SetScrollChild(importFrame.editBox)

        importFrame.editBox.instruction = importFrame.editBox:CreateFontString(nil, "OVERLAY", "SortedFont")
        importFrame.editBox.instruction:SetPoint("TOPLEFT")
        importFrame.editBox.instruction:SetText(S.Localize("CONFIG_CATEGORIES_IMPORT_INSTRUCTION"))
        importFrame.editBox.instruction:SetTextColor(0.5, 0.5, 0.5)
        importFrame.editBox.instruction:Show()

        importFrame.nameString = importFrame:CreateFontString(nil, "OVERLAY", "SortedFont")
        importFrame.nameString:SetPoint("TOPLEFT", 90, -204)
        importFrame.nameString:SetPoint("RIGHT", -160, 0)
        importFrame.nameString:SetHeight(20)
        importFrame.nameString:SetTextScale(1.4)
        importFrame.nameString:SetMaxLines(1)
        importFrame.nameString:SetJustifyH("LEFT")
        importFrame.icon = S.FrameTools.CreateCircleButton("BUTTON", importFrame, false, nil, true)
        importFrame.icon:SetPoint("RIGHT", importFrame.nameString, "LEFT", -4, -6)
        importFrame.icon:SetSize(40, 40)
        importFrame.icon:Disable()
        importFrame.icon:Hide()

        importFrame.attributesString = importFrame:CreateFontString(nil, "OVERLAY", "SortedFont")
        importFrame.attributesString:SetPoint("TOPLEFT", importFrame.nameString, "BOTTOMLEFT", 0, -4)
        importFrame.attributesString:SetTextColor(0.7, 0.7, 0.7)
        importFrame.valuesString = importFrame:CreateFontString(nil, "OVERLAY", "SortedFont")
        importFrame.valuesString:SetPoint("TOPLEFT", importFrame.attributesString, "BOTTOMLEFT", 0, -4)
        importFrame.valuesString:SetTextColor(0.6, 0.6, 0.6)

        importFrame.editBox:SetScript("OnShow", function(self) 
            self:SetText("")
            self:SetFocus()
        end)
        importFrame.editBox:SetScript("OnHide", function(self) 
            self:SetText("")
        end)
        importFrame.editBox:SetScript("OnTextChanged", function(self) 
            importFrame.isValid = false
            importFrame.nameString:SetText("")
            importFrame.button:Hide()
            importFrame.icon:Hide()
            importFrame.attributesString:Hide()
            importFrame.valuesString:Hide()
            if #self:GetText() == 0 then
                self.instruction:SetShown(true)
            else
                self.instruction:SetShown(false)
                local t = S.Utils.StringToTable(self:GetText())
                local attrCount, valuesCount = 0, 0
                if t and type(t) == "table" and t.name and t.icon and t.version and t.attributes and type(t.attributes) == "table" then
                    attrCount = S.Utils.GetNumKeysInTable(t.attributes)
                    -- Check validity of imported data
                    local isValid = true
                    for key, attr in pairs(t.attributes) do
                        if type(attr) ~= "table" then
                            isValid = false
                        else
                            valuesCount = valuesCount + S.Utils.GetNumKeysInTable(attr)
                            if S.Category.attributesTable[key].type == "STRINGS" then
                                for _, str in pairs(attr) do
                                    if type(str) ~= "table" or not str.str or type(str.str) ~= "string" then
                                        isValid = false
                                    end
                                end
                            elseif S.Category.attributesTable[key].type == "SPECIFIC_ITEMS" then
                                for _, item in pairs(attr) do
                                    if type(item) ~= "table" or not item.itemID then
                                        isValid = false
                                    end
                                end
                            elseif S.Category.attributesTable[key].type == "VALUES" then
                                for _, v in pairs(attr) do
                                    if type(v) ~= "boolean" then
                                        isValid = false
                                    end
                                end
                            end
                        end
                    end
                    if t.version > S.Category.VERSION then
                        isValid = false
                        importFrame.nameString:SetText("|cffff1133Sorted is outdated")
                        importFrame.nameString:Show()
                    elseif not isValid then
                        importFrame.nameString:SetText("|cffff1133Invalid")
                        importFrame.nameString:Show()
                    end
                    if isValid then
                        importFrame.isValid = true
                        importFrame.nameString:SetText(t.name)
                        importFrame.button:Show()
                        local x = importFrame.nameString:GetStringWidth()
                        if x > 250 then x = 250 end
                        importFrame.button:SetPoint("LEFT", importFrame.nameString, "LEFT", x + 16, -4)
                        importFrame.icon:Show()
                        importFrame.icon:SetIconTexture("Interface\\Icons\\"..t.icon)
                        if attrCount == 1 then importFrame.attributesString:SetText("1 attribute")
                        else importFrame.attributesString:SetText(attrCount.." attributes") end
                        importFrame.attributesString:Show()
                        if valuesCount == 1 then importFrame.valuesString:SetText("1 value")
                        else importFrame.valuesString:SetText(valuesCount.." values") end
                        importFrame.valuesString:Show()
                    end
                else
                    importFrame.nameString:SetText("|cffff1133Invalid")
                    importFrame.nameString:Show()
                end
            end
        end)
        -- Test data:  {["name"]="Hello world",["icon"]="INV_Epicguildtabard",["attributes"]={[1]={[1]=1,[2]=2},[2]={[1]=1,[2]=2,[3]=3}}}
        S.Utils.RunOnEvent(importFrame, "SettingsFrame-CategorySelected", importFrame.Hide)
        importFrame.editBox:SetScript("OnEscapePressed", function(self) 
            importFrame:Hide()
        end)
        importFrame.editBox:SetScript("OnEnterPressed", function(self)
            if importFrame.isValid then
                S.Settings.Get("categories2")[f.selectedCategory] = S.Utils.StringToTable(self:GetText())
                importFrame:Hide()
                S.Utils.TriggerEvent("CategorySelected")
                S.Utils.TriggerEvent("SettingsFrame-CategorySelected")
                S.Category.CheckOutdated()
            end
        end)
        importFrame.button = S.FrameTools.CreateBasicTextButton(importFrame, S.Localize("CONFIG_CATEGORIES_IMPORT"), function(self)
            if importFrame.isValid then
                S.Settings.Get("categories2")[f.selectedCategory] = S.Utils.StringToTable(importFrame.editBox:GetText())
                importFrame:Hide()
                S.Utils.TriggerEvent("CategorySelected")
                S.Utils.TriggerEvent("SettingsFrame-CategorySelected")
                S.Category.CheckOutdated()
            end
        end)
        importFrame.button:Hide()
    end
end

-- Import button
--[[local function Import()
    local catTable = S.Settings.Get("categories2")[f.selectedCategory]
    local catString = S.Utils.TableToString(catTable)
    S.Utils.StringToTable(catString)
end]]
local function Import()
    CreateImportFrame()
    importFrame:Show()
end
f.importButton = S.FrameTools.CreateBasicTextButton(f, S.Localize("CONFIG_CATEGORIES_IMPORT"), Import)
f.importButton:SetPoint("TOPLEFT", 16, -144)



-- EXPORTING
-- Window
local function CreateExportFrame()
    if not exportFrame.created then
        exportFrame.created = true
        exportFrame:SetFrameStrata("DIALOG")
        exportFrame:SetFrameLevel(2935)
        exportFrame:SetPoint("CENTER")
        exportFrame:SetSize(440, 280)
        exportFrame:SetClampedToScreen(true)
        exportFrame:SetMovable(true)
        exportFrame:SetScript("OnMouseDown", exportFrame.StartMoving)
        exportFrame:SetScript("OnMouseUp", exportFrame.StopMovingOrSizing)
        exportFrame:SetScript("OnShow", function(self) 
            importFrame:Hide()
            self:ClearAllPoints()
            self:SetPoint("CENTER")
            self:SetSize(440, 280)
        end)
        importFrame:Hide()

        S.FrameTools.AddOuterShadow(exportFrame, 100)

        exportFrame.bg = exportFrame:CreateTexture()
        exportFrame.bg:SetTexture("Interface\\Addons\\Sorted\\Textures\\Abstract", "REPEAT", "REPEAT")
        exportFrame.bg:SetVertexColor(0.6, 0.6, 0.6)
        exportFrame.bg:SetDrawLayer("BACKGROUND")
        exportFrame.bg:SetAllPoints()
        exportFrame.bg:SetVertTile(true)
        exportFrame.bg:SetHorizTile(true)

        S.FrameTools.AddBorder(exportFrame, "border", "Interface\\Addons\\Sorted\\Textures\\settings-border", 3, 0)

        exportFrame.closeButton = S.FrameTools.CreateCloseButton(exportFrame)
        exportFrame.closeButton:SetSize(32, 32)
        exportFrame.closeButton:SetPoint("TOPRIGHT", -4, -4)
        exportFrame.closeButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
        exportFrame.closeButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")
        exportFrame.closeButton:GetHighlightTexture():SetTexCoord(0.1484375, 0.296875, 0, 0.3125)
        exportFrame.closeButton:GetHighlightTexture():SetAlpha(0.6)
        exportFrame.closeButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\redbutton2x-Clean")

        exportFrame.tip = exportFrame:CreateFontString(nil, "OVERLAY", "SortedFont")
        exportFrame.tip:SetPoint("TOP", 0, -20)
        exportFrame.tip:SetTextScale(1.3)
        exportFrame.tip:SetTextColor(1, 0.9, 0)
        exportFrame.tip:SetText(S.Localize("CONFIG_CATEGORIES_EXPORT_TIP"))

        exportFrame.scrollFrame = CreateFrame("ScrollFrame", nil, exportFrame, "UIPanelScrollFrameTemplate")
        exportFrame.scrollFrame:SetFrameLevel(exportFrame:GetFrameLevel() + 10)
        exportFrame.scrollFrame:SetSize(336, 120)
        exportFrame.scrollFrame:SetPoint("TOP", -11, -56)
        S.FrameTools.AddBorder(exportFrame.scrollFrame, "border", "Interface\\Addons\\Sorted\\Textures\\Rounded-Border", -2, 8, true)
        exportFrame.scrollFrame.border:ClearAllPoints()
        exportFrame.scrollFrame.border:SetPoint("TOPLEFT")
        exportFrame.scrollFrame.border:SetPoint("BOTTOMRIGHT", 22, 0)
        exportFrame.scrollFrame.border:SetFrameLevel(exportFrame.scrollFrame:GetFrameLevel() - 1)
        for k,v in pairs(exportFrame.scrollFrame.border.parts) do
            v:SetVertexColor(0.8, 0.8, 0.8)
        end
        exportFrame.scrollFrame:SetScript("OnMouseDown", function(self)
            exportFrame.editBox:SetFocus()
        end)

        exportFrame.editBox = CreateFrame("EditBox", nil, exportFrame.scrollFrame)
        exportFrame.editBox:SetFrameLevel(exportFrame.scrollFrame:GetFrameLevel() + 2)
        exportFrame.editBox:SetFontObject("SortedFont")
        exportFrame.editBox:SetAutoFocus(false)
        exportFrame.editBox:SetMultiLine(true)
        exportFrame.editBox:SetWidth(336)
        exportFrame.scrollFrame:SetScrollChild(exportFrame.editBox)

        exportFrame.inputBlocker = CreateFrame("FRAME", nil, exportFrame.scrollFrame)
        exportFrame.inputBlocker:SetFrameLevel(exportFrame.scrollFrame:GetFrameLevel() + 10)
        exportFrame.inputBlocker:SetAllPoints()
        exportFrame.inputBlocker:SetScript("OnMouseDown", function(self) end)

        exportFrame.nameString = exportFrame:CreateFontString(nil, "OVERLAY", "SortedFont")
        exportFrame.nameString:SetPoint("TOPLEFT", 90, -204)
        exportFrame.nameString:SetPoint("RIGHT", -160, 0)
        exportFrame.nameString:SetHeight(20)
        exportFrame.nameString:SetTextScale(1.4)
        exportFrame.nameString:SetMaxLines(1)
        exportFrame.nameString:SetJustifyH("LEFT")
        exportFrame.icon = S.FrameTools.CreateCircleButton("BUTTON", exportFrame, false, nil, true)
        exportFrame.icon:SetPoint("RIGHT", exportFrame.nameString, "LEFT", -4, -6)
        exportFrame.icon:SetSize(40, 40)
        exportFrame.icon:Disable()
        exportFrame.icon:Hide()

        exportFrame.attributesString = exportFrame:CreateFontString(nil, "OVERLAY", "SortedFont")
        exportFrame.attributesString:SetPoint("TOPLEFT", exportFrame.nameString, "BOTTOMLEFT", 0, -4)
        exportFrame.attributesString:SetTextColor(0.7, 0.7, 0.7)
        exportFrame.valuesString = exportFrame:CreateFontString(nil, "OVERLAY", "SortedFont")
        exportFrame.valuesString:SetPoint("TOPLEFT", exportFrame.attributesString, "BOTTOMLEFT", 0, -4)
        exportFrame.valuesString:SetTextColor(0.6, 0.6, 0.6)

        function exportFrame.editBox:SetCategory(categoryTable)
            local t = categoryTable
            self.text = S.Utils.TableToString(t)
            self:SetText(self.text)
            self:SetFocus()
            self:HighlightText(0)

            local attrCount, valuesCount = 0, 0
            for _, attr in pairs(t.attributes) do
                attrCount = attrCount + 1
                for k, v in pairs(attr) do
                    valuesCount = valuesCount + 1
                end
            end
            exportFrame.nameString:SetText(t.name)
            exportFrame.icon:Show()
            exportFrame.icon:SetIconTexture("Interface\\Icons\\"..t.icon)
            if attrCount == 1 then exportFrame.attributesString:SetText("1 attribute")
            else exportFrame.attributesString:SetText(attrCount.." attributes") end
            exportFrame.attributesString:Show()
            if valuesCount == 1 then exportFrame.valuesString:SetText("1 value")
            else exportFrame.valuesString:SetText(valuesCount.." values") end
            exportFrame.valuesString:Show()
        end
        function exportFrame.editBox:ResetText() 
            self:SetText(self.text) 
            self:SetFocus()
            self:HighlightText(0)
            self:SetCursorPosition(0)
        end
        exportFrame.editBox:SetScript("OnUpdate", exportFrame.editBox.ResetText)

        S.Utils.RunOnEvent(exportFrame, "SettingsFrame-CategorySelected", exportFrame.Hide)
        exportFrame.editBox:SetScript("OnEscapePressed", function(self) 
            exportFrame:Hide()
        end)
        exportFrame.editBox:SetScript("OnEnterPressed", function(self) 
            exportFrame:Hide()
        end)
        exportFrame.editBox:SetScript("OnHide", function(self) 
            self:SetText("")
        end)
        -- Test data:  {["name"]="Hello world",["icon"]="INV_Epicguildtabard",["attributes"]={[1]={[1]=1,[2]=2},[2]={[1]=1,[2]=2,[3]=3}}}
    end
end


local function Export()
    CreateExportFrame()
    exportFrame:Show()
    exportFrame.editBox:SetCategory(S.Settings.Get("categories2")[f.selectedCategory])
end
f.exportButton = S.FrameTools.CreateBasicTextButton(f, S.Localize("CONFIG_CATEGORIES_EXPORT"), Export)
f.exportButton:SetPoint("TOP", f.importButton, "BOTTOM")