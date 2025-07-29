local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

-- The War Within 11.2 Bank
if S.WoWVersion() >= 11 and S.UseNewBank() then
    -- Side tab
    local sideTab, f = S.AddSideTab(BANK, "BANK", BankFrame.TabSystem:GetTabButton(BankFrame.characterBankTabID))

    -- Item list
    f.itemList = S.CreateItemList(f, "BANK", 500, "ContainerFrameItemButtonTemplate")
    table.insert(S.itemLists, f.itemList)
    function f:GetMinWidth()
        return self.itemList:GetMinWidth()
    end

    -- Tabs
    f.tabsFrame = CreateFrame("FRAME", nil, f)
    f.tabsFrame:SetPoint("LEFT", f.itemList.freeSpace, "RIGHT")
    f.tabsFrame:SetSize(32, 32)

    function S.GetBankSelectedTab()
        return f.selectedTab
    end

    f.tabsSettingsMenu = CreateFrame("FRAME", nil, f, "BankPanelTabSettingsMenuTemplate")
    f.tabsSettingsMenu:SetFrameStrata("DIALOG")
    f.tabsSettingsMenu:SetFrameLevel(50)
    f.tabsSettingsMenu.BorderBox:SetFrameLevel(55)
    f.tabsSettingsMenu.BorderBox.OkayButton:SetFrameLevel(60)
    f.tabsSettingsMenu.BorderBox.CancelButton:SetFrameLevel(60)
    f.tabsSettingsMenu:Hide()
    S.Utils.RunOnEvent(f.tabsSettingsMenu, "BankClosed", f.tabsSettingsMenu.Hide)

    -- Override blizz functions
    function f.tabsSettingsMenu:GetSelectedTabData()
        return S.GetData(UnitGUID("player")).bankTabData[f.selectedTabSettings]
    end
    function f.tabsSettingsMenu:GetBankFrame()
        return f
    end
    f.selectedTabSettings = 1
    function f:GetTabData(selectedTabID)
        return S.GetData(UnitGUID("player")).bankTabData[f.selectedTabSettings]
    end


    f.tabs = {}
    for i = 1, 6 do
        f.tabs[i] = S.FrameTools.CreateCircleButton("CheckButton", f.tabsFrame, true, nil, false)
        f.tabs[i].tabID = i
        f.tabs[i]:SetPoint("LEFT", (i - 1) * 32, 0)
        f.tabs[i]:SetScript("OnEnter", function(self)
            local tabData = S.GetData().bankTabData[self.tabID]
            if tabData then
                S.Tooltip.Schedule(function()
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    GameTooltip:ClearLines()
                    GameTooltip_SetTitle(GameTooltip, tabData.name, NORMAL_FONT_COLOR)

                    if FlagsUtil.IsSet(tabData.depositFlags, Enum.BagSlotFlags.ExpansionCurrent) then
                        GameTooltip:AddLine(BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_CURRENT))
                    elseif FlagsUtil.IsSet(tabData.depositFlags, Enum.BagSlotFlags.ExpansionLegacy) then
                        GameTooltip:AddLine(BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_LEGACY))
                    end
                    
                    local filterList = ContainerFrameUtil_ConvertFilterFlagsToList(tabData.depositFlags)
                    if filterList then
                        local wrapText = true;
                        GameTooltip_AddNormalLine(GameTooltip, BANK_TAB_DEPOSIT_ASSIGNMENTS:format(filterList), wrapText);
                    end

                    if C_Bank.CanViewBank(Enum.BankType.Character) then
                        GameTooltip:AddLine(BANK_TAB_TOOLTIP_CLICK_INSTRUCTION, 0, 1, 0)
                    end
                    GameTooltip:Show()
                end)
            end
        end)
        f.tabs[i]:SetScript("OnLeave", function(self)
            S.Tooltip.Cancel()
        end)
        f.tabs[i]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        f.tabs[i]:SetScript("OnClick", function(self, button, down)
            if button == "RightButton" then
                self:SetChecked(true)
                if S.IsPlayingCharacterSelected() and S.IsBankOpened() then
                    local bankTabID = self.tabID + Enum.BagIndex.CharacterBankTab_1 - 1
                    if f.tabsSettingsMenu:GetSelectedTabID() == bankTabID then
                        self:SetChecked(false)
                        f.tabsSettingsMenu:Hide()
                    else
                        BankPanel:SelectTab(bankTabID)
                        f.selectedTabSettings = self.tabID
                        if not f.tabsSettingsMenu:IsShown() then
                            f.tabsSettingsMenu:TriggerEvent(BankPanelTabSettingsMenuMixin.Event.OpenTabSettingsRequested, bankTabID)
                            f.tabsSettingsMenu:ClearAllPoints()
                        end
                        f.tabsSettingsMenu:SetSelectedTab(bankTabID)
                        f.tabsSettingsMenu:SetPoint("BOTTOM", self, "TOP")
                    end
                end
            elseif button == "LeftButton" then
            end
            if self:GetChecked() then
                f.selectedTab = self.tabID
                for i = 1, 6 do
                    if i ~= self.tabID then
                        f.tabs[i]:SetChecked(false)
                        f.tabs[i].icon:SetDesaturated(true)
                        f.tabs[i]:GetNormalTexture():SetDesaturated(true)
                    else
                        f.tabs[i].icon:SetDesaturated(false)
                        f.tabs[i]:GetNormalTexture():SetDesaturated(false)
                    end
                end
            else
                f.selectedTab = nil
                for i = 1, 6 do
                    f.tabs[i].icon:SetDesaturated(false)
                    f.tabs[i]:GetNormalTexture():SetDesaturated(false)
                end
            end
            S.Utils.TriggerEvent("SearchChanged")
        end)
    end
    function f.tabsFrame:Update()
        local numTabs = S.GetData().numBankTabs
        local tabData = S.GetData().bankTabData
        if numTabs and tabData then
            for i = 1, 6 do
                if numTabs and i <= numTabs and tabData[i] then
                    f.tabs[i]:Show()
                    f.tabs[i]:SetIconTexture(tabData[i].icon)
                else
                    f.tabs[i]:Hide()
                end
            end
            if numTabs == 0 then
                self:SetWidth(1)
            else
                self:SetWidth(numTabs * 32)
            end
            if not S.IsPlayingCharacterSelected() or C_Bank.HasMaxBankTabs(Enum.BankType.Character) or not S.IsBankOpened() then
                self.buyTabButton:Hide()
                f.middleFrame:SetPoint("LEFT", f.tabsFrame, "RIGHT")
            else
                self.buyTabButton:Show()
                self.buyTabButton.text:SetText(S.Utils.FormatValueString(S.Utils.FetchNextPurchasableBankTabData(Enum.BankType.Character).tabCost))
                f.middleFrame:SetPoint("LEFT", self.buyTabButton.text, "RIGHT")
            end
        else
            for i = 1, 6 do
                f.tabs[i]:Hide()
            end
        end
    end
    f.tabsFrame:SetScript("OnShow", f.tabsFrame.Update)
    S.Utils.RunOnEvent(f.tabsFrame, "BankTabsUpdated", f.tabsFrame.Update)
    S.Utils.RunOnEvent(f.tabsFrame, "CharacterSelected", f.tabsFrame.Update)
    f.tabsFrame:RegisterEvent("BANK_TABS_CHANGED")
    f.tabsFrame:SetScript("OnEvent", f.tabsFrame.Update)

    local b = CreateFrame("BUTTON", nil, f.tabsFrame, "BankPanelPurchaseButtonScriptTemplate")
    b:SetAttribute("overrideBankType", Enum.BankType.Character)
    f.tabsFrame.buyTabButton = b
    b:SetParent(f.tabsFrame)
    b:SetPoint("LEFT", f.tabsFrame, "RIGHT")
    b:SetSize(28, 28)
    b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\CommonButtonsDropdown")
    b:GetNormalTexture():SetTexCoord(0, 0.375, 0, 0.375)
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Close-Button-Highlight")
    b:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
    b:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\CommonButtonsDropdown")
    b:GetPushedTexture():SetTexCoord(0.375, 0.75, 0, 0.375)
    b:SetText("")
    b.text = b:CreateFontString(nil, "OVERLAY", "SortedFont")
    b.text:SetPoint("LEFT", b, "RIGHT")
    b.text:SetTextColor(1, 0.92, 0.8)
    b:HookScript("OnEnter", function(self)
        S.Tooltip.CreateText(self, "ANCHOR_TOP", BANKSLOTPURCHASE)
    end)
    b:HookScript("OnLeave", S.Tooltip.Cancel)


    -- Deposit reagents
    f.middleFrame = CreateFrame("FRAME", nil, f)
    f.middleFrame:SetPoint("LEFT", f.tabsFrame, "RIGHT")
    f.middleFrame:SetPoint("RIGHT")
    f.middleFrame:SetHeight(32)
    f.middleFrame.depositItemsButton = CreateFrame("BUTTON", nil, f.middleFrame)
    b = f.middleFrame.depositItemsButton
    b:SetPoint("CENTER", -20, 0)
    b:SetSize(39.4, 32)
    b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Reagents-Button-New")
    b:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.8125)
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Reagents-Button-New")
    b:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 0.8125)
    b:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Reagents-Button-New")
    b:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.8125)
    b:SetScript("OnMouseDown", function(self)
        b:SetPoint("CENTER", -19, -1)
    end)
    b:SetScript("OnMouseUp", function(self)
        b:SetPoint("CENTER", -20, 0)
    end)
    b:SetScript("OnEnter", function(self)
        S.Tooltip.CreateText(self, "ANCHOR_TOP", REAGENTBANK_DEPOSIT)
    end)
    b:SetScript("OnLeave", function(self)
        S.Tooltip.Cancel()
    end)
    b:SetScript("OnClick", function(self)
        C_Bank.AutoDepositItemsIntoBank(Enum.BankType.Character)
    end)

    --[[f.middleFrame.includeReagentsCheckbox = CreateFrame("CheckButton", nil, f.middleFrame)
    local cb = f.middleFrame.includeReagentsCheckbox
    cb:SetSize(24, 24)
    cb:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox")
    cb:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Highlight")
    cb:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox")
    cb:SetCheckedTexture("Interface\\Addons\\Sorted\\Textures\\Checkbox-Tick")
    cb:SetPoint("CENTER", 16, -2)
    cb:SetScript("OnEnter", function(self)
        S.Tooltip.CreateText(self, "ANCHOR_TOP", BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL)
    end)
    cb:SetScript("OnLeave", function(self)
        S.Tooltip.Cancel()
    end)
    cb:SetScript("OnShow", function(self)
        self:SetChecked(GetCVarBool("bankAutoDepositReagents"))
    end)
    cb:SetScript("OnClick", function(self)
        SetCVar("bankAutoDepositReagents", self:GetChecked())
    end)]]




    -- Hide controls when player isn't at a bank
    S.Utils.RunOnEvent(f, "BankOpened", function(self)
        self.middleFrame:Show()
    end)
    S.Utils.RunOnEvent(f, "BankClosed", function(self)
        self.middleFrame:Hide()
    end)
    f.middleFrame:Hide()
end