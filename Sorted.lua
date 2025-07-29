local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local GetContainerItemInfo = GetContainerItemInfo
local useNewContainerInfo
if C_Container then
    if C_Container.GetContainerItemInfo then 
        GetContainerItemInfo = C_Container.GetContainerItemInfo 
        useNewContainerInfo = true
    end
end


-- Slash command
SLASH_SORTED1 = "/sorted"
SlashCmdList.SORTED = function(msg)
	S.settingsFrame:Show()
end


-- EVENT HANDLING
local eventHandlerFrame = CreateFrame("FRAME")
eventHandlerFrame:RegisterEvent("BANKFRAME_OPENED")
eventHandlerFrame:RegisterEvent("BANKFRAME_CLOSED")
eventHandlerFrame:SetScript("OnEvent", function(self, event, param1, param2, param3)
    if event == "BANKFRAME_OPENED" then
        S.OpenBag()
        S.SelectCharacter(UnitGUID("player"))
    elseif event == "BANKFRAME_CLOSED" then
        S.CloseBag()
    end
end)



-- BAG OPENING / CLOSING
local enabled = true
function S.Enable()
    enabled = true
end
function S.Disable()
    enabled = false
end
local lastToggledTime = 0
local lastShownTime = 0
local lastHiddenTime = 0
local TOGGLE_TIMEOUT = 0.01

local newItemsToRemove = {}
local isNewItemsToRemove = false
function S.ScheduleNewItemToRemove(bag, slot)
    if C_NewItems.IsNewItem(bag, slot) then
        isNewItemsToRemove = true
        if useNewContainerInfo then
            local t = GetContainerItemInfo(bag, slot)
            if t then
                newItemsToRemove[t.itemID] = true
            end
        else
            local itemID = GetContainerItemInfo(bag, slot)
            newItemsToRemove[itemID] = true
        end
    end
end
-- Function naming at its best
function S.IsItemScheduledToBeNotNew(bag, slot)
    local itemID
    if useNewContainerInfo then
        local t = GetContainerItemInfo(bag, slot)
        if t then
            itemID = t.itemID
        end
    else
        itemID = GetContainerItemInfo(bag, slot)
    end
    if itemID then
        return newItemsToRemove[itemID]
    end
end

S.primaryFrame:SetScript("OnShow", function(self)
    S.Utils.TriggerEvent("PrimaryFrameOpened")
end)

S.primaryFrame:SetScript("OnHide", function(self)
    -- Remove new items that have been hovered over
    if isNewItemsToRemove then
        local removedANewItem = false
        for _, bag in pairs(S.Utils.ContainersOfType("BAGS")) do
            for slot = 1, S.Utils.MaxBagSlots() do
                if C_NewItems.IsNewItem(bag, slot) then
                    if S.IsItemScheduledToBeNotNew(bag, slot) then
                        C_NewItems.RemoveNewItem(bag, slot)
                        removedANewItem = true
                    end
                end
            end
        end
        if removedANewItem then
            S.Utils.TriggerEvent("NewItemsChanged")
        end
        newItemsToRemove = {}
        isNewItemsToRemove = false
    end
    -- Reset recently unequipped items
    S.Data.ResetRecentlyUnequippedItems()

    --[[if C_Bank then
        C_Bank.CloseBankFrame()
    else
        CloseBankFrame()
    end]]
    if S.IsBankOpened() or S.IsGuildBankOpened() or S.IsVoidStorageOpened() then
        C_PlayerInteractionManager.ClearInteraction()
    end

    S.Utils.TriggerEvent("PrimaryFrameClosed")
end)

function S.OpenBag(bag)
    if enabled then
        if (force or lastToggledTime < GetTime() - TOGGLE_TIMEOUT) and not S.primaryFrame:IsShown() then
            -- Make player select a settings profile before using Sorted.
            if not S.Settings.HasProfile() then
                S.settingsProfilesFrame:Show()
                S.settingsProfilesFrame.source = "bags"

            else
                PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
    
                --local startTime = debugprofilestop()
    
                S.primaryFrame:Show()
                
                S.SelectCharacter(UnitGUID("player"))
    
                --print(debugprofilestop() - startTime)
    
                lastToggledTime = GetTime()
                lastShownTime = GetTime()
            end
        end
        --[[if bag == KEYRING_CONTAINER then
            _G["SortedBag-2Frame"]:Show()
        end]]
    end
end
function S.CloseBag(bag)
    if (force or lastToggledTime < GetTime() - TOGGLE_TIMEOUT) and S.primaryFrame:IsShown() then
        PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
        S.primaryFrame:Hide()
        lastToggledTime = GetTime()
        lastHiddenTime = GetTime()

        --[[for k,v in pairs(S.bagFrames) do
            v:Hide()
        end]]
    end
end
function S.ToggleBag(bag)
    if S.primaryFrame:IsShown() then
        S.CloseBag(bag)
    else
        S.OpenBag(bag)
        if S.WoWVersion() == 1 and bag == KEYRING_CONTAINER then
            S.primaryFrame.SelectSideTab(1, true)
        elseif S.WoWVersion() <= 3 and bag == KEYRING_CONTAINER then
            S.primaryFrame.SelectSideTab(3, true)
        else
            S.primaryFrame.SelectSideTab(nil)
        end
    end
end
hooksecurefunc('OpenBackpack', S.ToggleBag)
hooksecurefunc('CloseBackpack', S.CloseBag)
hooksecurefunc('ToggleBackpack', S.ToggleBag)
hooksecurefunc('OpenBag', S.ToggleBag)
hooksecurefunc('ToggleBag', S.ToggleBag)