local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

if S.WoWVersion() >= 4 and CanUseVoidStorage then

    --S.VoidStorage = {}

    -- Side tab
    local sideTab, f = S.AddSideTab(VOID_STORAGE, "VOID_STORAGE")
    function sideTab:UpdateShown()
        local void = S.GetData().voidStorage
        if S.IsVoidStorageOpened() and S.IsPlayingCharacterSelected() then
            S.ShowSideTab("VOID_STORAGE")
        elseif not void then
            S.HideSideTab("VOID_STORAGE")
        else
            local foundItem
            for tab = 1, 2 do
                for slot = 1, 80 do
                    if void.tabs[tab].slots[slot].link then
                        foundItem = true
                        break
                    end
                end
            end
            S.SetSideTabShown("VOID_STORAGE", foundItem)
        end
    end
    sideTab:RegisterEvent("VOID_STORAGE_UPDATE")
    sideTab:SetScript("OnEvent", sideTab.UpdateShown)
    S.Utils.RunOnEvent(sideTab, "VoidStorageUpdated", sideTab.UpdateShown)
    S.Utils.RunOnEvent(sideTab, "CharacterSelected", sideTab.UpdateShown)
    S.Utils.RunOnEvent(sideTab, "VoidStorageOpened", sideTab.UpdateShown)
    S.Utils.RunOnEvent(sideTab, "VoidStorageClosed", sideTab.UpdateShown)
    S.Utils.RunOnEvent(sideTab, "EnteredWorld", sideTab.UpdateShown)

    f:HookScript("OnHide", function() StaticPopup_Hide("SORTED_VOID_STORAGE_DEPOSIT") end)

    S.Utils.RunOnEvent(nil, "VoidStorageOpened", function()
        S.primaryFrame.SelectSideTab("VOID_STORAGE", true)
    end)

    function f:GetMinWidth()
        return self.itemList:GetMinWidth()
    end

    -- Item list
    f.itemList = S.CreateVoidStorageItemList(f)
    table.insert(S.itemLists, f.itemList)



    -- "Unlock Void Storage" frame
    f.warning = CreateFrame("FRAME", nil, f)
    f.warning:SetAllPoints()
    f.warning:SetFrameLevel(f:GetFrameLevel() + 100)
    f.warning.bg = f.warning:CreateTexture()
    f.warning.bg:SetColorTexture(0, 0, 0, 0.4)
    f.warning.bg:SetAllPoints()

    f.warning.text1 = f.warning:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.warning.text1:SetText(VOID_STORAGE_WELCOME)
    f.warning.text1:SetTextColor(1, 0.8, 0)
    f.warning.text1:SetTextScale(1.3)
    f.warning.text2 = f.warning:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.warning.text2:SetText(VOID_STORAGE_WELCOME_TEXT)
    f.warning.text2:SetTextScale(1.05)
    f.warning.text3 = f.warning:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.warning.text3:SetText(COSTS_LABEL)
    f.warning.text3:SetTextColor(1, 0.8, 0)
    f.warning.text3:SetTextScale(1.2)
    f.warning.text4 = f.warning:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.warning.text4:SetTextScale(1.2)

    f.warning.text2:SetPoint("CENTER", 0, 20)
    f.warning.text1:SetPoint("BOTTOM", f.warning.text2, "TOP", 0, 20)
    f.warning.text3:SetPoint("TOPRIGHT", f.warning.text2, "BOTTOM", -4, -20)
    f.warning.text4:SetPoint("TOPLEFT", f.warning.text2, "BOTTOM", 4, -20)

    f.warning.unlockButton = CreateFrame("BUTTON", nil, f.warning, "UIPanelButtonTemplate")
    f.warning.unlockButton:SetSize(204, 24)
    f.warning.unlockButton:SetText(UNLOCK_VOID_STORAGE)
    f.warning.unlockButton:SetPoint("TOP", f.warning.text2, "BOTTOM", 0, -56)
    f.warning.unlockButton:SetScript("OnClick", function(self)
        UnlockVoidStorage()
    end)

    function f.warning:Update()
        if S.IsPlayingCharacterSelected() and not CanUseVoidStorage() then
            self.text4:SetText(GetMoneyString(GetVoidUnlockCost()))
            local voidStorageUnlockCost = GetVoidUnlockCost()
            if voidStorageUnlockCost > GetMoney() then
                self.unlockButton:Disable()
                self.text4:SetTextColor(1, 0, 0.05)
            else
                self.unlockButton:Enable()
                self.text4:SetTextColor(1, 1, 1)
            end
            self:Show()
        else
            self:Hide()
        end
    end
    f.itemList:HookScript("OnShow", function() f.warning:Update() end)
    S.Utils.RunOnEvent(f.warning, "CharacterSelected", f.warning.Update)
    f.warning:RegisterEvent("VOID_STORAGE_UPDATE")
    f.warning:HookScript("OnEvent", f.warning.Update)


    -- Automate deposit/withdraw
    local function AutoVoidTransfer()
        if S.primaryFrame:IsShown() then
            -- Check if an item is waiting to be deposited/withdrawn
            local foundDepositItem, foundWithdrawItem = false, false
            local prevItem = nil
            for i = 1, 9 do
                if GetVoidTransferWithdrawalInfo(i) then
                    if not foundWithdrawItem then
                        foundWithdrawItem = true
                    end
                end
                if GetVoidTransferDepositInfo(i) then
                    if not foundDepositItem then
                        foundDepositItem = true
                    else
                        ClearVoidTransferDepositSlot(prevItem) -- Deposit only one item at a time
                        ClickVoidTransferDepositSlot(i)
                        ClickVoidTransferDepositSlot(1)
                    end
                    prevItem = i
                end
            end
            if not foundDepositItem and not foundWithdrawItem then
                return
            end
            if foundWithdrawItem and foundDepositItem then
                for i = 1, 9 do
                    ClearVoidTransferDepositSlot(i)
                end
            end
            -- Don't continue if the 'depositing will remove all modifications' warning is shown
            if not StaticPopup_FindVisible("VOID_DEPOSIT_CONFIRM") then
                -- If this is the first time depositing an item, show a warning about the cost
                if foundDepositItem and not S.Settings.Get("hasDepositedVoidStorage") then
                    if not StaticPopup_FindVisible("SORTED_VOID_STORAGE_DEPOSIT") then
                        StaticPopupDialogs["SORTED_VOID_STORAGE_DEPOSIT"] = {
                            text = S.Localize("DIALOG_VOID_STORAGE_DEPOSIT", GetMoneyString(GetVoidTransferCost())),
                            StartDelay = function() return 3 end,
                            delayText = ACCEPT,
                            button1 = ACCEPT,
                            button2 = CANCEL,
                            OnAccept = function()
                                ExecuteVoidTransfer()
                                S.Settings.Set("hasDepositedVoidStorage", true)
                            end,
                            OnCancel = function()
                                for i = 1, 9 do
                                    if GetVoidTransferDepositInfo(i) then
                                        ClearVoidTransferDepositSlot(i)
                                    end
                                end
                            end,
                            timeout = 0,
                            whileDead = true,
                            hideOnEscape = true,
                        }
                        StaticPopup_Show("SORTED_VOID_STORAGE_DEPOSIT")
                    end
                else
                    ExecuteVoidTransfer()
                end
            end
        end
    end
    local automator = CreateFrame("FRAME", nil, f)
    automator:RegisterEvent("VOID_STORAGE_DEPOSIT_UPDATE")
    automator:RegisterEvent("VOID_STORAGE_CONTENTS_UPDATE")
    automator:RegisterEvent("ADDON_LOADED")
    automator:SetScript("OnEvent", function(self, event, a, b, c)
        if event == "VOID_STORAGE_DEPOSIT_UPDATE" or event == "VOID_STORAGE_CONTENTS_UPDATE" then
            C_Timer.After(0.01, AutoVoidTransfer)
        elseif event == "ADDON_LOADED" and a == "Blizzard_VoidStorageUI" then
            hooksecurefunc("VoidStorage_UpdateTransferButton", function(hasWarningDialog)
                C_Timer.After(0.01, AutoVoidTransfer)
            end)
        end
    end)
    


    -- GetCursorInfo() doesn't work when item is picked up from Void Storage
    -- Figure out when the cursor has dropped the item by checking for
    -- any locked items
    -- Re-uses the automator frame for this
    local function CheckForCursorItem()
        local data = S.GetData()
        local itemFound = false
        if data.voidStorage then
            for tab = 1, 2 do
                for k, v in pairs(data.voidStorage.tabs[tab].slots) do
                    local _, _, locked = GetVoidItemInfo(tab, v.slot)
                    if locked then
                        itemFound = true
                        break
                    end
                end
            end
        end
        if not itemFound then
            S.cursorIsHoldingVoidStorageItem = false
            S.cursorItemLink = nil
            automator:SetScript("OnUpdate", nil)
        end
    end
    S.Utils.RunOnEvent(automator, "VoidStorageItemClicked", function(self)
        automator:SetScript("OnUpdate", CheckForCursorItem)
    end)


    
    -- VOID_STORAGE_DEPOSIT_UPDATE
end