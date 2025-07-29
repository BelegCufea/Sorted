local _, S = ...
local pairs, ipairs, string, type, time, GetTime = pairs, ipairs, string, type, time, GetTime

local useNewContainerAPI = false
local GetContainerItemCooldown, ShowContainerSellCursor, GetContainerItemInfo = GetContainerItemCooldown, ShowContainerSellCursor, GetContainerItemInfo
if C_Container then
    if C_Container.GetContainerItemCooldown then GetContainerItemCooldown = C_Container.GetContainerItemCooldown end
    if C_Container.ShowContainerSellCursor then ShowContainerSellCursor = C_Container.ShowContainerSellCursor end
    if C_Container.GetContainerItemInfo then useNewContainerAPI = true; GetContainerItemInfo = C_Container.GetContainerItemInfo end
end

local WHITE = CreateColor(1, 1, 1)
local GREY = CreateColor(0.2, 0.2, 0.2)
local LIGHT_GREY = CreateColor(0.4, 0.4, 0.4)

S.maxILvl = 0 -- ilvl opacity is set against this

local function UpdateLocked(self)
    if self.bag and self.slot then
        local itemInfo, _, locked = GetContainerItemInfo(self.bag, self.slot)
        if useNewContainerAPI and itemInfo then
            locked = itemInfo.isLocked
        end
        -- Fade item if it's locked
        if S.IsPlayingCharacterSelected() and locked then
            self:SetAlpha(0.6)
        else
            self:SetAlpha(1)
        end
    end
end

local function UpdateEntry(self)
    self:UpdateSuper()

    if self.bag and self.slot then
        UpdateLocked(self)

        self:UpdateIsCoolingDown()
        self.button:GetParent():SetID(self.bag)
        self.button:SetID(self.slot)
        self.button.bag = self.bag
        self.button.slot = self.slot

        -- Combined stack expand/collapse button
        if self.list.gridView then
            self.expandCombinedStackButton:Hide()
        else
            if self.isCombined then
                self.expandCombinedStackButton:SetShown(self.isCombined)
                self.expandCombinedStackButton:SetCombinedStackButtonCollapsed(not self.list.expandedCombinedItems[self.data.key])
                self.expandCombinedStackButton:GetNormalTexture():SetDesaturated(self.filtered)
                if self.filtered then
                    self.expandCombinedStackButton:GetNormalTexture():SetVertexColor(S.Color.GRAY:GetRGB())
                else
                    self.expandCombinedStackButton:GetNormalTexture():SetVertexColor(S.Color.WHITE:GetRGB())
                end
            else
                self.expandCombinedStackButton:Hide()
            end
        end
        
        -- New item highlight
        if S.IsPlayingCharacterSelected() then
            if C_NewItems.IsNewItem(self.bag, self.slot) and not S.IsItemScheduledToBeNotNew(self.bag, self.slot) then
                self.newItem:Show()
                self.newItem:SetAlpha(1)
            else
                self.newItem:Hide()
            end
        else
            self.newItem:Hide()
        end
    
        -- Mouseover highlight
        if self.list.gridView then
            self.highlight:SetTexture("")
        else
            self.highlight:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Highlight")
            if self.filtered then
                self.highlight:SetVertexColor(GREY:GetRGB())
            else
                self.highlight:SetVertexColor(self.data.color1:GetRGB())
            end
        end

    else
        self:Hide()
    end
end

local function GetFavorited(self)
    if self.bag and self.slot then
        return S.Data.GetFavorited(self:GetData())
    else
        return false
    end
end
local function ToggleFavorited(self)
    S.Data.ToggleFavorited(self:GetData())
    S.Utils.TriggerEvent("FavoriteChanged")
end
local function SetFavorited(self, value)
    S.Data.ToggleFavorited(self:GetData(), value)
    S.Utils.TriggerEvent("FavoriteChanged")
end
local function ClearFavorited(self)
    S.Data.Unfavorite(self:GetData())
    S.Utils.TriggerEvent("FavoriteChanged")
end

local function SetFiltered(self, filtered)
    self.filtered = filtered
    UpdateEntry(self)
end

local function GetData(self)
    -- Originally obtained data from S.GetData()
    -- The List now adds data as an attribute when sorting, so may as well use that instead
    return self.data --S.Data.GetItem(self.bag, self.slot, S.GetSelectedCharacter())
end

-- Based on Blizzard's Update function for ContainerFrameItemButtons
-- Works for items in the bank container too
local function ButtonScheduledUpdate(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE");

    if not S.IsPlayingCharacterSelected() or not S.IsBankOpened() and (S.Utils.ContainerIsType(self.bag, "BANK") or S.Utils.ContainerIsType(self.bag, "REAGENT") or S.Utils.ContainerIsType(self.bag, "ACCOUNT")) then
        local link = self.parent.data.link
        if link then
            GameTooltip:SetHyperlink(link)
        end
        ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip)

    else
        S.ScheduleNewItemToRemove(self.bag, self.slot)

        --C_NewItems.RemoveNewItem(self:GetBagID(), self:GetID());

        --[[self.NewItemTexture:Hide();
        self.BattlepayItemTexture:Hide();

        if ( self.flashAnim:IsPlaying() or self.newitemglowAnim:IsPlaying() ) then
            self.flashAnim:Stop();
            self.newitemglowAnim:Stop();
        end]]

        local showSell = nil;

        ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip)

        if self.bag == BANK_CONTAINER then
            GameTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(self:GetID(),self.isBag))
        elseif self.bag == KEYRING_CONTAINER then
            GameTooltip:SetInventoryItem("player", KeyRingButtonIDToInvSlotID(self:GetID()))
        else
            GameTooltip:SetBagItem(self.bag, self.slot)
        end

        if ( IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") ) then
            GameTooltip_ShowCompareItem(GameTooltip);
        end

        if ( InRepairMode() and (repairCost and repairCost > 0) ) then
            GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true);
            SetTooltipMoney(GameTooltip, repairCost);
            GameTooltip:Show();
        elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 ) then
            showSell = 1;
        end

        if ( not SpellIsTargeting() ) then
            if ( IsModifiedClick("DRESSUP") --[[and self:HasItem()]] ) then
                ShowInspectCursor();
            elseif ( showSell ) then
                ShowContainerSellCursor(self.bag, self.slot);
            elseif ( self:IsReadable() ) then
                ShowInspectCursor();
            else
                ResetCursor();
            end
        end

        if S.WoWVersion() >= 7 then
            if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_MOUNT_EQUIPMENT_SLOT_FRAME) ) then
                local itemLocation = ItemLocation:CreateFromBagAndSlot(self.bag, self.slot);
                if ( itemLocation and itemLocation:IsValid() and C_PlayerInfo.CanPlayerUseMountEquipment() and (not CollectionsJournal or not CollectionsJournal:IsShown()) ) then
                    local tabIndex = 1;
                    CollectionsMicroButton_SetAlertShown(tabIndex);
                end
            end

            if ArtifactFrame --[[and self:HasItem()]] then
                ArtifactFrame:OnInventoryItemMouseEnter(self.bag, self.slot);
            end

            local itemLocation = ItemLocation:CreateFromBagAndSlot(self.bag, self.slot);
            if itemLocation and itemLocation:IsValid() then
                local itemLocationValid = itemLocation:IsValid();
                SetCursorHoveredItem(itemLocation);
            end
        end
    end
end
local function Button_OnUpdate(self)
	S.Tooltip.Schedule(ButtonScheduledUpdate, self, true)
end
local function Button_OnEnter(self)
	S.Tooltip.Schedule(function() 
        ButtonScheduledUpdate(self)
        
        if S.Settings.Get("tooltipInfo") == 1 then
            S.Tooltip.Extended(self.bag, self.slot)
        end
    end, self)
end

-- Blizz item button functions
local function Button_GetBagID(self)
    return self.parent:GetID()
end
local function Button_IsReadable(self)
    return self.readable
end
local function Button_HasItem(self)
    -- Sorted only shows buttons with items, so this can always return true
	return true --self.hasItem
end



local function UpdateIsCoolingDown(self)
    if self.list:IsAvailable() and self.bag and self.slot then
        self.cooldownStart, self.cooldownDuration = GetContainerItemCooldown(self.bag, self.slot)
        self.coolingDown = self.cooldownDuration > 2
        if self.coolingDown then
            self:SetScript("OnUpdate", self.UpdateCooldown)
        else
            self:SetScript("OnUpdate", nil)
        end
        self.cooldownBar:SetShown(self.coolingDown)
    else
        self:SetScript("OnUpdate", nil)
        self.cooldownBar:Hide()
    end
end
local function UpdateCooldown(self)
    local time = GetTime()
    if time > self.cooldownStart + self.cooldownDuration then
        self.cooldownBar:Hide()
        self:SetScript("OnUpdate", nil)
    else
        local x = 0.5 - (GetTime() - self.cooldownStart) / self.cooldownDuration * 0.5
        self.cooldownBar.tex:SetTexCoord(x, x + 0.5, 0, 1)
    end
end

local containerHighlightColor = CreateColor(0.2, 0.7, 1)
local cooldownColor = CreateColor(0.15, 0.14, 0.12)

function SetCombinedStackButtonCollapsed(self, collapsed)
    self.collapsed = collapsed
    if collapsed then
        self:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
        self:GetHighlightTexture():SetTexCoord(0.5, 1, 0, 0.5)
        self:GetPushedTexture():SetTexCoord(0, 0.5, 0, 0.5)
    else
        self:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
        self:GetHighlightTexture():SetTexCoord(0.5, 1, 0.5, 1)
        self:GetPushedTexture():SetTexCoord(0, 0.5, 0.5, 1)
    end
end
function ExpandCombinedStackButtonOnClick(self)
    local expandedCombinedItems = self.entryButton.list.expandedCombinedItems
    local key = self.entryButton.data.key
    if expandedCombinedItems[key] then
        expandedCombinedItems[key] = nil
    else
        expandedCombinedItems[key] = true
    end
    self.entryButton.list:ScheduleUpdate(false, true)
end

function S.CreateItemEntry(list, template)
    local self = S.CreateListEntry(list, list.itemButtonTemplate)
    self.UpdateSuper = self.Update
    self.Update = UpdateEntry
    self.UpdateLocked = UpdateLocked
    self.SetFiltered = SetFiltered
    self.GetFavorited = GetFavorited
    self.ToggleFavorited = ToggleFavorited
    self.ClearFavorited = ClearFavorited
    self.SetFavorited = SetFavorited
    self.GetData = GetData
    self.UpdateCooldown = UpdateCooldown
    self.UpdateIsCoolingDown = UpdateIsCoolingDown
    --self.OnIconChangedSuper = self.OnIconChanged
    --self.OnIconChanged = OnIconChanged

    -- Replace Blizz methods
    self.OnUpdate = Button_OnUpdate
    self.button.UpdateTooltip = Button_OnUpdate
    self.button.OnItemEntryButtonEnter = Button_OnEnter
    if S.WoWVersion() <= 4 then 
        self.button.GetBagID = Button_GetBagID -- Replacing this in Retail seems to cause the "Sorted was blocked from an action only available to the Blizzard UI" error
    end
    if list.type == "REAGENT" then
        self.button.SetBagID = ContainerFrameItemButtonMixin.SetBagID
        self.button.GetBagID = ContainerFrameItemButtonMixin.GetBagID
    end
    self.button.IsReadable = Button_IsReadable
    self.button.HasItem = Button_HasItem
    
    self.button:SetScript("OnLeave", function(self)
        if S.WoWVersion() < 10 then
            GameTooltip_Hide()
            ResetCursor()
            if ArtifactFrame then
                ArtifactFrame:OnInventoryItemMouseLeave(self:GetParent():GetID(), self:GetID());
            end
        else
            if ( not SpellIsTargeting() ) then
                ResetCursor()
            end
            if ( ArtifactFrame and self:HasItem() ) then
                ArtifactFrame:OnInventoryItemMouseLeave(self:GetBagID(), self:GetID())
            end
            ClearCursorHoveredItem()
        end
    end)
    self.button:SetScript("OnEnter", function(self)
        self:OnEntryButtonEnter()
        self:OnItemEntryButtonEnter()

        -- Protect favourited items from being sold to vendors
        -- Also prevent accidentally using this character's items when viewing a different character
        if not S.IsPlayingCharacterSelected() or (S.Settings.Get("protectFavorites") == 1 and self.parent:GetFavorited() and MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1) then
            self.onClickFunc = self:GetScript("OnClick")
            self:SetScript("OnClick", nil)
        end
    end)
    self.button:HookScript("OnLeave", function(self)
        S.Tooltip.Cancel()
        if self.onClickFunc then
            self:SetScript("OnClick", self.onClickFunc)
        end
    end)
    self.button:HookScript("OnLeave", self.button.OnEntryButtonLeave)

    self.newItem = CreateFrame("Frame", nil, self)
    self.newItem:SetAllPoints()
    self.newItem:SetFrameLevel(self:GetFrameLevel() + 4)
    self.newItemHighlight = self.newItem:CreateTexture(nil, "OVERLAY")
    self.newItemHighlight:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Higherlight")
    self.newItemHighlight:SetAllPoints()
    self.newItemHighlight:SetBlendMode("ADD")
    self.newItemHighlight:SetVertexColor(0.5, 0.45, 0.3)
    self.newItem.anim = self.newItem:CreateAnimationGroup()
    self.newItem.anim:SetLooping("REPEAT")
    local anim = self.newItem.anim:CreateAnimation("Alpha")
    anim:SetDuration(1)
    anim:SetFromAlpha(0.3)
    anim:SetToAlpha(0.6)
    anim:SetSmoothing("IN_OUT")
    anim:SetOrder(1)
    anim = self.newItem.anim:CreateAnimation("Alpha")
    anim:SetDuration(1)
    anim:SetFromAlpha(0.6)
    anim:SetToAlpha(0.3)
    anim:SetSmoothing("IN_OUT")
    anim:SetOrder(2)
    self.newItem:HookScript("OnShow", function(self)
        self.anim:Play()
    end)
    self.newItem:HookScript("OnEnter", function(self)
        self:Hide()
        self.anim:Stop()
    end)
    self.newItem:HookScript("OnHide", function(self)
        self.anim:Stop()
    end)

    self.cooldownBar = CreateFrame("Frame", nil, self)
    self.cooldownBar:SetAllPoints()
    --[[self.cooldownBar:SetStatusBarTexture("Interface\\Addons\\Sorted\\Textures\\UI-Higherlight")
    self.cooldownBar:SetStatusBarColor(1, 0.92, 0.75, 0.3)
    self.cooldownBar:SetOrientation("HORIZONTAL")]]
    self.cooldownBar:SetFrameLevel(self:GetFrameLevel() + 6)
    self.cooldownBar.tex = self.cooldownBar:CreateTexture(nil, "OVERLAY")
    self.cooldownBar.tex:SetTexture("Interface\\Addons\\Sorted\\Textures\\Status-Bar")
    self.cooldownBar.tex:SetAllPoints()
    self.cooldownBar.tex:SetBlendMode("ADD")
    self.cooldownBar.tex:SetVertexColor(cooldownColor:GetRGB())
    self.cooldownBar.bg = self.cooldownBar:CreateTexture(nil, "BACKGROUND")
    self.cooldownBar.bg:SetColorTexture(0.02, 0.02, 0.02, 0.7)
    self.cooldownBar.bg:SetAllPoints()
    self.cooldownBar:Hide()
    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
    self:SetScript("OnEvent", self.UpdateIsCoolingDown)

    self.containerHighlightParent = CreateFrame("FRAME", nil, self)
    self.containerHighlightParent:SetAllPoints()
    self.containerHighlightParent:SetFrameLevel(self:GetFrameLevel() + 5)
    self.containerHighlight = self.containerHighlightParent:CreateTexture(nil, "OVERLAY")
    self.containerHighlight:SetAllPoints()
    self.containerHighlight:SetTexture("Interface\\Addons\\Sorted\\Textures\\UI-Highlight")
    self.containerHighlight:SetVertexColor(containerHighlightColor:GetRGB())
    self.containerHighlight:SetTexCoord(0.3, 0.8, 0.4, 0.6)
    self.containerHighlight:SetBlendMode("ADD")
    self.containerHighlight:Hide()

    local f = CreateFrame("BUTTON", nil, self)
    f:SetFrameLevel(self.button:GetFrameLevel() + 1)
    f:SetPoint("LEFT", 2, 0)
    f:SetSize(16, 16)
    f:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Expand-Button-Clean")
    f:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Expand-Button-Clean")
    f:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Expand-Button-Clean")
    f.SetCombinedStackButtonCollapsed = SetCombinedStackButtonCollapsed
    f:SetScript("OnClick", ExpandCombinedStackButtonOnClick)
    f:RegisterForClicks("LeftButtonDown")
    f.entryButton = self
    self.expandCombinedStackButton = f

    -- Create all elements from columns table
    for k, _ in pairs(self.list.columns) do
        self:AddColumn(k)
    end

    return self
end