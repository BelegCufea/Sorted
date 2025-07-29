local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

if S.WoWVersion() >= 2 then

    S.Guild = {}

    -- Side tab
    local sideTab, f = S.AddSideTab(GUILD, "GUILD")
    function sideTab:UpdateShown()
        local guild = S.GetData().guild
        S.SetSideTabShown("GUILD", guild ~= nil)
    end
    sideTab:RegisterEvent("PLAYER_GUILD_UPDATE")
    sideTab:SetScript("OnEvent", sideTab.UpdateShown)
    S.Utils.RunOnEvent(sideTab, "CharacterSelected", sideTab.UpdateShown)

    function f:GetMinWidth()
        return self.itemList:GetMinWidth()
    end


    -- Data updating is done here, so the guild bank is queried when the tab in Sorted is opened.
    -- Querying itself triggers more GUILDBANKBAGSLOTS_CHANGED events, so that event is useless.
    -- Instead, just update the guild bank constantly lmfao.
    -- Updates each tab over a second or so, then triggers a bag update
    local lastUpdateTime, nextTab = nil, 1
    local function OnUpdate(self)
        if S.IsGuildBankAvailable() and (not lastUpdateTime or GetTime() > lastUpdateTime + 0.1) then
            lastUpdateTime = GetTime()

            S.Data.UpdateGuildBank(nextTab)

            nextTab = nextTab + 1
            if nextTab > 8 then
                nextTab = 1
                S.Utils.TriggerEvent("GuildBankUpdatedFull")
            else
                S.Utils.TriggerEvent("GuildBankUpdated")
            end
        end
    end
    f:SetScript("OnUpdate", OnUpdate)


    -- Item list
    f.itemList = S.CreateGuildItemList(f)
    table.insert(S.itemLists, f.itemList)


    -- Guild bank tabs
    f.tabsFrame = CreateFrame("FRAME", nil, f)
    f.tabsFrame:SetPoint("BOTTOMLEFT", 70, 0)
    f.tabsFrame:SetSize(32 * 8, 32)
    f.tabsFrame.tabs = {}
    local selectedTab = nil

    function S.Guild.GetSelectedTab()
        return selectedTab
    end

    -- Updates tab selection, checking the selected tab and fading the rest
    local function UpdateTabs()
        local guild = S.GetData().guild
        for i = 1, 8 do
            local tab = f.tabsFrame.tabs[i]
            tab:SetChecked(i == selectedTab)
            local canView = false
            if guild then
                canView = guild.tabs[i].canView
            end
            tab.icon:SetDesaturated(not canView or (selectedTab and not (i == selectedTab) and S.Settings.Get("desaturateCategories") == 1))
        end
    end
    S.Utils.RunOnEvent(f.tabsFrame, "SettingChanged-desaturateCategories", UpdateTabs)

    local function SelectTab(tabID)
        if selectedTab == tabID then
            selectedTab = nil
        else
            local guild = S.GetData().guild
            if guild and guild.tabs[tabID].canView then
                selectedTab = tabID
                SetCurrentGuildBankTab(selectedTab)
            else
                selectedTab = nil
            end
        end
        UpdateTabs()
        S.Utils.TriggerEvent("GuildTabSelected")
    end

    -- Create the tabs
    for i = 1, 8 do
        f.tabsFrame.tabs[i] = S.FrameTools.CreateCircleButton("CheckButton", f.tabsFrame, true, nil, true)
        f.tabsFrame.tabs[i]:SetPoint("BOTTOMLEFT", (i - 1) * 32, 0)
        f.tabsFrame.tabs[i].id = i
        f.tabsFrame.tabs[i]:SetScript("OnEnter", function(self)
            S.Tooltip.CreateText(self, "ANCHOR_RIGHT", self.name)
        end)
        f.tabsFrame.tabs[i]:SetScript("OnLeave", S.Tooltip.Cancel)
        f.tabsFrame.tabs[i]:SetScript("OnClick", function(self)
            SelectTab(self.id)
        end)
    end

    -- Updates the icon and name of tabs
    function f.tabsFrame:Update()
        local guild = S.GetData().guild
        if not guild or not guild.tabs then
            for _, tab in pairs(self.tabs) do
                tab:Hide()
            end
        else
            for i = 1, 8 do
                local tab = self.tabs[i]
                local tabData = guild.tabs[i]
                if tabData and tabData.name then
                    tab:Show()
                    tab:SetIconTexture(tabData.icon)
                    tab.name = tabData.name
                else
                    tab:Hide()
                end
            end
        end
        UpdateTabs()
    end
    f.tabsFrame:SetScript("OnShow", function(self)
        S.Data.UpdateGuildBankTabs()
        self:Update()
    end)
    S.Utils.RunOnEvent(f.tabsFrame, "GuildBankTabsUpdated", f.tabsFrame.Update)
    S.Utils.RunOnEvent(f.tabsFrame, "CharacterSelected", f.tabsFrame.Update)


    -- Money
    f.moneyFrame = S.FrameTools.CreateMoneyFrame(f)
    f.moneyFrame:SetPoint("BOTTOMRIGHT", -24, 0)
    function f.moneyFrame:Update()
        local guild = S.GetData().guild
        if not guild then
            self.text:SetText("")
        else
            local money = guild.money
            if not money then money = 0 end  -- for guilds without money
            if money >= 10000000000 then -- Hide silvers/coppers when guild has >1mil gold
                money = math.floor(money / 10000) * 10000
            elseif money >= 100000000 then -- Hide coppers when guild has >10k gold
                money = math.floor(money / 100) * 100
            end
            self.text:SetText(GetMoneyString(money, true)) 
            self:SetWidth(self.text:GetWidth() + 40)
        end
    end
    f.moneyFrame:RegisterEvent("GUILDBANK_UPDATE_MONEY")
    f.moneyFrame:SetScript("OnEvent", function(self)
        S.Data.UpdateGuildMoney()
        self:Update()
    end)
    f.moneyFrame:SetScript("OnShow", function(self)
        S.Data.UpdateGuildMoney()
        self:Update()
    end)
    S.Utils.RunOnEvent(f.moneyFrame, "CharacterSelected", f.moneyFrame.Update)

end