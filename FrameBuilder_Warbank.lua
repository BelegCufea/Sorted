local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

if S.WoWVersion() >= 11 then
    -- Side tab
    local sideTab, f
    if S.UseNewBank() then
        sideTab, f = S.AddSideTab(REPUTATION_SORT_TYPE_ACCOUNT, "WARBANK", BankFrame.TabSystem:GetTabButton(BankFrame.accountBankTabID))
    else
        sideTab, f = S.AddSideTab(REPUTATION_SORT_TYPE_ACCOUNT, "WARBANK")
    end

    -- Item list
    f.itemList = S.CreateItemList(f, "ACCOUNT", 500, "ContainerFrameItemButtonTemplate")
    table.insert(S.itemLists, f.itemList)
    function f:GetMinWidth()
        return self.itemList:GetMinWidth()
    end

    -- Tabs
    f.tabsFrame = CreateFrame("FRAME", nil, f)
    f.tabsFrame:SetPoint("LEFT", f.itemList.freeSpace, "RIGHT")
    f.tabsFrame:SetSize(32, 32)

    function S.GetAccountBankSelectedTab()
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
    function f.tabsSettingsMenu.GetBankPanel()
        return {
            GetTabData = function(tabID)
                return Sorted_AccountData.bankTabData[f.selectedTabSettings]
            end
        }
    end
    function f.tabsSettingsMenu:GetSelectedTabData()
        return Sorted_AccountData.bankTabData[f.selectedTabSettings]
    end
    function f.tabsSettingsMenu:GetBankFrame()
        return f
    end
    f.selectedTabSettings = 1
    function f:GetTabData(selectedTabID)
        return Sorted_AccountData.bankTabData[f.selectedTabSettings]
    end


    f.tabs = {}
    for i = 1, 5 do
        f.tabs[i] = S.FrameTools.CreateCircleButton("CheckButton", f.tabsFrame, true, nil, false)
        f.tabs[i].tabID = i
        f.tabs[i]:SetPoint("LEFT", (i - 1) * 32, 0)
        f.tabs[i]:SetScript("OnEnter", function(self)
            local tabData = Sorted_AccountData.bankTabData[self.tabID]
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

                if C_Bank.CanViewBank(2) then
                    GameTooltip:AddLine(BANK_TAB_TOOLTIP_CLICK_INSTRUCTION, 0, 1, 0)
                end
                GameTooltip:Show()
            end)
        end)
        f.tabs[i]:SetScript("OnLeave", function(self)
            S.Tooltip.Cancel()
        end)
        f.tabs[i]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        f.tabs[i]:SetScript("OnClick", function(self, button, down)
            if button == "RightButton" then
                self:SetChecked(not self:GetChecked())
                if S.IsBankOpened() then
                    local accountBankTabID = self.tabID + Enum.BagIndex.AccountBankTab_1 - 1
                    if f.tabsSettingsMenu:GetSelectedTabID() == accountBankTabID then
                        self:SetChecked(false)
                        f.tabsSettingsMenu:Hide()
                    else
                        if AccountBankPanel then
                            AccountBankPanel:SelectTab(accountBankTabID)
                        else
                            BankPanel:SelectTab(accountBankTabID)
                        end
                        f.selectedTabSettings = self.tabID
                        if not f.tabsSettingsMenu:IsShown() then
                            f.tabsSettingsMenu:TriggerEvent(BankPanelTabSettingsMenuMixin.Event.OpenTabSettingsRequested, accountBankTabID)
                            f.tabsSettingsMenu:ClearAllPoints()
                        else
                            f.tabsSettingsMenu:SetSelectedTab(accountBankTabID)
                        end
                        f.tabsSettingsMenu:SetPoint("BOTTOM", self, "TOP")
                    end
                end
            elseif button == "LeftButton" then
            end
            if self:GetChecked() then
                f.selectedTab = self.tabID
                for i = 1, 5 do
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
                for i = 1, 5 do
                    f.tabs[i].icon:SetDesaturated(false)
                    f.tabs[i]:GetNormalTexture():SetDesaturated(false)
                end
            end
            S.Utils.TriggerEvent("SearchChanged")
        end)
    end
    function f.tabsFrame:Update()
        local numTabs = C_Bank.FetchNumPurchasedBankTabs(2)
        local tabData = Sorted_AccountData.bankTabData
        for i = 1, 5 do
            if i <= numTabs and tabData[i] then
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
        if C_Bank.HasMaxBankTabs(2) or not S.IsBankOpened() then
            self.buyTabButton:Hide()
            f.middleFrame:SetPoint("LEFT", f.tabsFrame, "RIGHT")
        else
            self.buyTabButton:Show()
            self.buyTabButton.text:SetText(S.Utils.FormatValueString(S.Utils.FetchNextPurchasableBankTabData(2).tabCost))
            f.middleFrame:SetPoint("LEFT", self.buyTabButton.text, "RIGHT")
        end
    end
    f.tabsFrame:SetScript("OnShow", f.tabsFrame.Update)
    S.Utils.RunOnEvent(f.tabsFrame, "BankTabsUpdated", f.tabsFrame.Update)
    f.tabsFrame:RegisterEvent("PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED")
    f.tabsFrame:SetScript("OnEvent", f.tabsFrame.Update)

    local b
    if S.UseNewBank() then
        b = CreateFrame("BUTTON", nil, f.tabsFrame, "BankPanelPurchaseButtonScriptTemplate")
        b:SetAttribute("overrideBankType", Enum.BankType.Account)
    else
        b = AccountBankPanel.PurchasePrompt.TabCostFrame.PurchaseButton
        for k,v in pairs(b) do
            if type(v) == "table" and v.Hide then
                v:Hide()
                v:ClearAllPoints()
            end
        end
    end
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

    
    -- Money
    f.moneyFrame = S.FrameTools.CreateMoneyFrame(f)
    f.moneyFrame:SetPoint("BOTTOMRIGHT", -32, 0)
    function f.moneyFrame:Update()
        local data = Sorted_AccountData
        data.money = C_Bank.FetchDepositedMoney(2)

        local money = data.money
        if not money then money = 0 end  -- for guilds without money
        if money >= 10000000000 then -- Hide silvers/coppers when guild has >1mil gold
            money = math.floor(money / 10000) * 10000
        elseif money >= 100000000 then -- Hide coppers when guild has >10k gold
            money = math.floor(money / 100) * 100
        end
        self.text:SetText(GetMoneyString(money, true)) 
        self:SetWidth(self.text:GetWidth() + 40)
    end
    f.moneyFrame:RegisterEvent("ACCOUNT_MONEY")
    f.moneyFrame:SetScript("OnEvent", function(self)
        self:Update()
    end)
    f.moneyFrame:SetScript("OnShow", function(self)
        self:Update()
    end)

    f.depositButton = CreateFrame("BUTTON", nil, f)
    f.depositButton:SetPoint("LEFT", f.moneyFrame, "RIGHT", 0, 1)
    f.depositButton:SetSize(28, 28)
    f.depositButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Withdraw")
    f.depositButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
    f.depositButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Button-Highlight")
    f.depositButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Withdraw")
    f.depositButton:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.5)
    f.depositButton:SetScript("OnEnter", function(self)
        S.Tooltip.CreateText(self, "ANCHOR_TOP", BANK_DEPOSIT_MONEY_BUTTON_LABEL )
    end)
    f.depositButton:SetScript("OnLeave", function(self)
        S.Tooltip.Cancel()
    end)
    f.depositButton:SetScript("OnClick", function(self)
        StaticPopup_Show("BANK_MONEY_DEPOSIT", nil, nil, { bankType = 2 })
    end)

    f.withdrawButton = CreateFrame("BUTTON", nil, f)
    f.withdrawButton:SetPoint("RIGHT", f.moneyFrame, "LEFT", 0, 1)
    f.withdrawButton:SetSize(28, 28)
    f.withdrawButton:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Withdraw")
    f.withdrawButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
    f.withdrawButton:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Button-Highlight")
    f.withdrawButton:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Withdraw")
    f.withdrawButton:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
    f.withdrawButton:SetScript("OnEnter", function(self)
        S.Tooltip.CreateText(self, "ANCHOR_TOP", BANK_WITHDRAW_MONEY_BUTTON_LABEL )
    end)
    f.withdrawButton:SetScript("OnLeave", function(self)
        S.Tooltip.Cancel()
    end)
    f.withdrawButton:SetScript("OnClick", function(self)
        StaticPopup_Show("BANK_MONEY_WITHDRAW", nil, nil, { bankType = 2 })
    end)

    -- Deposit warbound items
    f.middleFrame = CreateFrame("FRAME", nil, f)
    f.middleFrame:SetPoint("LEFT", f.tabsFrame, "RIGHT")
    f.middleFrame:SetPoint("RIGHT", f.withdrawButton, "LEFT")
    f.middleFrame:SetHeight(32)
    f.middleFrame.depositWarboundItemsButton = CreateFrame("BUTTON", nil, f.middleFrame)
    b = f.middleFrame.depositWarboundItemsButton
    b:SetPoint("CENTER", -20, 0)
    b:SetSize(39.4, 32)
    b:SetNormalTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Warband-Button")
    b:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.8125)
    b:SetHighlightTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Warband-Button")
    b:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 0.8125)
    b:SetPushedTexture("Interface\\Addons\\Sorted\\Textures\\Deposit-Warband-Button")
    b:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.8125)
    b:SetScript("OnMouseDown", function(self)
        b:SetPoint("CENTER", -19, -1)
    end)
    b:SetScript("OnMouseUp", function(self)
        b:SetPoint("CENTER", -20, 0)
    end)
    b:SetScript("OnEnter", function(self)
        S.Tooltip.CreateText(self, "ANCHOR_TOP", ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL)
    end)
    b:SetScript("OnLeave", function(self)
        S.Tooltip.Cancel()
    end)
    b:SetScript("OnClick", function(self)
        C_Bank.AutoDepositItemsIntoBank(2)
    end)

    f.middleFrame.includeReagentsCheckbox = CreateFrame("CheckButton", nil, f.middleFrame)
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
    end)


    -- Account bank locked warning
    f.lockPrompt = CreateFrame("FRAME", nil, f)
    f.lockPrompt:SetAllPoints()
    f.lockPrompt:SetFrameLevel(f:GetFrameLevel() + 100)
    f.lockPrompt:SetScript("OnMouseDown", function() end)
    f.lockPrompt.bg = f.lockPrompt:CreateTexture()
    f.lockPrompt.bg:SetColorTexture(0, 0, 0, 0.4)
    f.lockPrompt.bg:SetAllPoints()
    f.lockPrompt.text = f.lockPrompt:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.lockPrompt.text:SetPoint("TOPLEFT", 50, -50)
    f.lockPrompt.text:SetPoint("BOTTOMRIGHT", -50, 50)
    f.lockPrompt.text:SetWordWrap(true)
    f.lockPrompt.text:SetJustifyH("CENTER")
    f.lockPrompt.text:SetJustifyV("MIDDLE")
    f.lockPrompt.text:SetText(ACCOUNT_BANK_LOCKED_PROMPT)
    f.lockPrompt.text:SetTextScale(1.5)



    -- Hide controls when player isn't at a bank
    S.Utils.RunOnEvent(f, "BankOpened", function(self)
        self.depositButton:Show()
        self.withdrawButton:Show()
        self.middleFrame:Show()
        if not C_PlayerInfo.HasAccountInventoryLock() then
            self.lockPrompt:Show()
        else
            self.lockPrompt:Hide()
        end
    end)
    S.Utils.RunOnEvent(f, "BankClosed", function(self)
        self.depositButton:Hide()
        self.withdrawButton:Hide()
        self.middleFrame:Hide()
        self.lockPrompt:Hide()
    end)
    f.depositButton:Hide()
    f.withdrawButton:Hide()
    f.middleFrame:Hide()
    f.lockPrompt:Hide()
end