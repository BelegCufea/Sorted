local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time
local LSM = LibStub("LibSharedMedia-3.0")

local GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem = GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem
if C_Item then
    GetItemInfoInstant, GetItemInfo, GetItemClassInfo, GetItemSubClassInfo, GetDetailedItemLevelInfo, IsEquippableItem = C_Item.GetItemInfoInstant, C_Item.GetItemInfo, C_Item.GetItemClassInfo, C_Item.GetItemSubClassInfo, C_Item.GetDetailedItemLevelInfo, C_Item.IsEquippableItem
end

Sorted_SettingsProfiles = {}
S.Settings = {}

local defaultSettings = {   -- Defaults
    ["width"] = 800,
    ["height"] = 540,
    ["scale"] = 1,
    ["iconSize"] = 19,
    ["iconSizeGrid"] = 32,
    ["iconShape"] = 1,
    ["iconShapeGrid"] = 1,
    ["iconZoom"] = 1.25,
    ["iconZoomGrid"] = 1.5,
    ["backdropAlpha"] = 1,
    ["font"] = "Bliz Quadrata",
    ["fontSizePts"] = 12,
    ["smoothScrolling"] = 0,
    ["animations"] = 0,
    ["favoritesOnTop"] = 1,
    ["newOnTop"] = 1,
    ["pinRecentlyUnequippedItems"] = 1,
    ["newItemIndicators"] = 1,
    ["protectFavorites"] = 0,
    ["combineStacks"] = 0,
    ["fontOutline"] = 0,
    ["fontShadow"] = 1,
    ["categoriesWidth"] = 160,
    ["categoriesUseIcons"] = 1,
    ["profileName"] = S.Localize("CONFIG_PROFILES_DEFAULT_NAME"),
    ["scrollSpeed"] = 5,
    ["smoothingAmount"] = 0.1,
    ["tooltipDelay"] = 0,
    ["tooltipInfo"] = 1,
    ["iconBorders"] = 1,
    ["iconBordersGrid"] = 1,
    ["iconBorderThickness"] = 2.1,
    ["iconBorderThicknessGrid"] = 2.1,
    ["padding"] = 2,
    ["paddingGrid"] = 2,
    ["onOpenSortKeepPrev"] = 1,
    ["onOpenSortMethod"] = 31,
    ["onOpenSortAscending"] = 1,
    ["onOpenFilterKeepPrev"] = 0,
    ["onOpenFilterCategory"] = 1,
    ["onOpenKeepSearch"] = 1,
    ["onOpenPinFavorites"] = 1,
    ["lastSearch"] = "",
    ["lastSort"] = 31,
    ["lastCategory"] = nil,
    ["skinning"] = 1,
    ["autoOpenClose"] = 255,
    ["grouping"] = 0,
    ["backdrop"] = "Sorted Abstract",
    ["backdropColor"] = {0.5, 0.5, 0.5, 1}, -- {r,g,b,a}
    ["desaturateCategories"] = 1,
    ["categoriesPosition"] = 0, -- 0 = top, 1 = side
    ["itemColumnSettings"] = {
        ["order"] = {
            "FAVORITES","QUANTITY", "ICON", "NAME",
            "PROFESSION_QUALITY", "ITEM_LEVEL", "TYPE_ICON", 
            "EXPANSION", "BINDING", "VALUE"
        },
        ["enabledColumns"] = {
            ["FAVORITES"] = true,
            ["QUANTITY"] = true, 
            ["ICON"] = true, 
            ["NAME"] = true,
            ["PROFESSION_QUALITY"] = true,
            ["ITEM_LEVEL"] = true, 
            ["TYPE_ICON"] = true, 
            ["EXPANSION"] = true, 
            ["BINDING"] = true, 
            ["VALUE"] = true
        },
        ["widths"] = {},
        ["selectedColumn"] = "NAME",
        ["sortMethod"] = 1,
        ["sortAsc"] = false,
        ["favoritesOnTop"] = true
    },
    ["itemGroupingSettings"] = {
        ["selectedGrouping"] = nil,
        ["collapsedGroups"] = {}
    },
    ["currencyColumnSettings"] = {
        ["order"] = {"FAVORITES", "ICON", "NAME", "QUANTITY", "MAX-QUANTITY", "TRACKED"},
        ["enabledColumns"] = {
            ["FAVORITES"] = true,
            ["QUANTITY"] = true, 
            ["MAX-QUANTITY"] = true, 
            ["ICON"] = true, 
            ["NAME"] = true,
            ["QUANTITY"] = true,
            ["TRACKED"] = true
        },
        ["widths"] = {},
        ["selectedColumn"] = "NAME",
        ["sortMethod"] = 1,
        ["sortAsc"] = false,
        ["favoritesOnTop"] = true
    },
    ["currencyGroupingSettings"] = {
        ["selectedGrouping"] = nil,
        ["collapsedGroups"] = {}
    },
}
S.Settings.defaults = defaultSettings

local defaultCategories = nil
function S.GetDefaultCategories()
    return defaultCategories
end

local armorSubclasses = {
    [Enum.ItemArmorSubclass.Cloth] = true,
    [Enum.ItemArmorSubclass.Leather] = true,
    [Enum.ItemArmorSubclass.Mail] = true,
    [Enum.ItemArmorSubclass.Plate] = true
}
local accessorySubclasses = {
    [Enum.ItemArmorSubclass.Generic] = true,
    [Enum.ItemArmorSubclass.Cosmetic] = true,
    [Enum.ItemArmorSubclass.Shield] = true,
    [Enum.ItemArmorSubclass.Libram] = true,
    [Enum.ItemArmorSubclass.Idol] = true,
    [Enum.ItemArmorSubclass.Totem] = true,
    [Enum.ItemArmorSubclass.Sigil] = true,
    [Enum.ItemArmorSubclass.Relic] = true
}

-- DEFAULT CATEGORIES
-- Retail
if S.WoWVersion() >= 8 then
    defaultCategories = {
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["INVENTORY_SLOT"] = {
                    ["03_2HWEAPON"] = true,
                    ["01_MAINHAND"] = true,
                    ["02_WEAPON"] = true,
                },
                ["TYPE"] = {
                    [2006] = true,
                    [2007] = true,
                    [2008] = true,
                    [2009] = true,
                    [2010] = true,
                    [2011] = false,
                    [2012] = false,
                    [2013] = true,
                    [2014] = true,
                    [2015] = true,
                    [2016] = true,
                    [2017] = true,
                    [2018] = true,
                    [2019] = true,
                    [2020] = true,
                    [2000] = true,
                    [2001] = true,
                    [2002] = true,
                    [2003] = true,
                    [2004] = true,
                    [2005] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_WEAPONS"),
            ["icon"] = "Garrison_BlueWeapon",
        }, -- [1]
        {
            ["version"] = "2.1",
            ["icon"] = "Garrison_PurpleArmor",
            ["attributes"] = {
                ["TYPE"] = {
                    [4002] = true,
                    [4003] = true,
                    [4004] = true,
                    [4005] = true,
                    [4000] = true,
                    [4001] = true,
                },
                ["INVENTORY_SLOT"] = {
                    ["16_HAND"] = true,
                    ["18_WAIST"] = true,
                    ["15_WRIST"] = true,
                    ["20_FEET"] = true,
                    ["19_LEGS"] = true,
                    ["13_SHOULDER"] = true,
                    ["21_FINGER"] = false,
                    ["14_CHEST"] = true,
                    ["11_HEAD"] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_ARMOR"),
        }, -- [2]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [4006] = true,
                    [4007] = false,
                    [4000] = true,
                    [4008] = false,
                    [4001] = true,
                    [4009] = false,
                    [4010] = false,
                    [4011] = false,
                    [4005] = true,
                },
                ["INVENTORY_SLOT"] = {
                    ["22_TRINKET"] = true,
                    ["25_TABARD"] = true,
                    ["24_CLOAK"] = true,
                    ["12_NECK"] = true,
                    ["23_SHIELD"] = true,
                    ["15_SHIRT"] = true,
                    ["21_FINGER"] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_ACCESSORIES"),
            ["icon"] = "INV_Epicguildtabard",
        }, -- [3]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    true, -- [1]
                    true, -- [2]
                    true, -- [3]
                    [0] = true,
                    [7] = true,
                    [8] = true,
                    [9] = true,
                    [5] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_CONSUMABLES"),
            ["icon"] = "INV_Potion_120",
        }, -- [4]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [15003] = true,
                    [15000] = true,
                    [15004] = true,
                    [15001] = true,
                    [15005] = true,
                    [15002] = true,
                    [15006] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_MISCELLANEOUS"),
            ["icon"] = "ACHIEVEMENT_GUILDPERK_HASTYHEARTH",
        }, -- [5]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [7006] = true,
                    [7007] = true,
                    [7008] = true,
                    [7009] = true,
                    [7010] = true,
                    [7011] = true,
                    [7012] = true,
                    [7016] = true,
                    [7018] = true,
                    [7004] = true,
                    [7005] = true,
                    [7001] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_TRADE_GOODS"),
            ["icon"] = "Garrison_Building_Workshop",
        }, -- [6]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [12000] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_QUEST_ITEMS"),
            ["icon"] = "INV_Scroll_11",
        }, -- [7]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [1000] = true,
                    [1002] = true,
                    [1004] = true,
                    [1006] = true,
                    [1008] = true,
                    [1010] = true,
                    [1001] = true,
                    [1003] = true,
                    [1005] = true,
                    [1007] = true,
                    [1009] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_CONTAINERS"),
            ["icon"] = "INV_Misc_Bag_19",
        }, -- [8]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [3001] = true,
                    [3009] = true,
                    [3002] = true,
                    [3010] = true,
                    [3003] = true,
                    [3011] = true,
                    [3004] = true,
                    [3005] = true,
                    [3006] = true,
                    [3007] = true,
                    [3000] = true,
                    [3008] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_GEMS"),
            ["icon"] = "INV_10_JewelCrafting_Gem3Primal_Earth_Cut_Black",
        }, -- [9]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [16005] = true,
                    [16007] = true,
                    [16009] = true,
                    [16011] = true,
                    [16002] = true,
                    [16004] = true,
                    [16006] = true,
                    [16008] = true,
                    [16010] = true,
                    [16012] = true,
                    [16001] = true,
                    [16003] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_GLYPHS"),
            ["icon"] = "INV_Inscription_MajorGlyph05",
        }, -- [10]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [8011] = true,
                    [8012] = true,
                    [8013] = true,
                    [8014] = true,
                    [8000] = true,
                    [8001] = true,
                    [8002] = true,
                    [8003] = true,
                    [8004] = true,
                    [8005] = true,
                    [8006] = true,
                    [8007] = true,
                    [8008] = true,
                    [8009] = true,
                    [8010] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_ITEM_ENHANCEMENTS"),
            ["icon"] = "Garrison_Upgrade",
        }, -- [11]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [9000] = true,
                    [9002] = true,
                    [9004] = true,
                    [9006] = true,
                    [9008] = true,
                    [9010] = true,
                    [9001] = true,
                    [9003] = true,
                    [9005] = true,
                    [9007] = true,
                    [9009] = true,
                    [9011] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_RECIPES"),
            ["icon"] = "INV_Inscription_RunescrollOfFortitude_Blue",
        }, -- [12]
        {
            ["version"] = "2.1",
            ["icon"] = "Garrison_Building_Menagerie",
            ["name"] = S.Localize("CATEGORY_BATTLE_PETS"),
            ["attributes"] = {
                ["TYPE"] = {
                    [17006] = true,
                    [17003] = true,
                    [17007] = true,
                    [17000] = true,
                    [17004] = true,
                    [17008] = true,
                    [17001] = true,
                    [17005] = true,
                    [17009] = true,
                    [17002] = true,
                },
            },
        }, -- [13]
        {
            ["version"] = "2.1",
            ["icon"] = "INV_Misc_Key_15",
            ["attributes"] = {
                ["TYPE"] = {
                    [13000] = true,
                    [13001] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_KEYS"),
        }, -- [14]
        {
            ["version"] = "2.1",
            ["name"] = "Profession Equipment",
            ["icon"] = "INV_Professions_TailoringScissors01",
            ["attributes"] = {
                ["TYPE"] = {
                    [19001] = true,
                    [19005] = true,
                    [19009] = true,
                    [19013] = true,
                    [19002] = true,
                    [19006] = true,
                    [19010] = true,
                    [19003] = true,
                    [19007] = true,
                    [19011] = true,
                    [19000] = true,
                    [19004] = true,
                    [19008] = true,
                    [19012] = true,
                },
            },
        }, -- [15]
    }
    
--WotLK / Cata
elseif S.WoWVersion() >= 3 then
    defaultCategories = {
        {
            ["version"] = "2.1",
            ["icon"] = "INV_Sword_04",
            ["name"] = S.Localize("CATEGORY_WEAPONS"),
            ["attributes"] = {
                ["INVENTORY_SLOT"] = {
                    ["02_WEAPON"] = true,
                    ["01_MAINHAND"] = true,
                    ["04_RANGED"] = true,
                    ["06_THROWN"] = true,
                    ["03_2HWEAPON"] = true,
                },
                ["TYPE"] = {
                    [2006] = true,
                    [2007] = true,
                    [2008] = true,
                    [2010] = true,
                    [2011] = true,
                    [2012] = true,
                    [2013] = true,
                    [2014] = true,
                    [2015] = true,
                    [2016] = true,
                    [2017] = true,
                    [2018] = true,
                    [2019] = true,
                    [2020] = true,
                    [2000] = true,
                    [2001] = true,
                    [2002] = true,
                    [2003] = true,
                    [2004] = true,
                    [2005] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_ARMOR"),
            ["icon"] = "Spell_Nature_EnchantArmor",
            ["attributes"] = {
                ["TYPE"] = {
                    [4002] = true,
                    [4003] = true,
                    [4004] = true,
                    [4005] = false,
                    [4000] = true,
                    [4001] = true,
                },
                ["INVENTORY_SLOT"] = {
                    ["14_CHEST"] = true,
                    ["20_FEET"] = true,
                    ["18_WAIST"] = true,
                    ["15_WRIST"] = true,
                    ["19_LEGS"] = true,
                    ["13_SHOULDER"] = true,
                    ["16_HAND"] = true,
                    ["11_HEAD"] = true,
                    ["17_SHIRT"] = false,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_ACCESSORIES"),
            ["icon"] = "INV_Misc_Cape_08",
            ["attributes"] = {
                ["INVENTORY_SLOT"] = {
                    ["22_TRINKET"] = true,
                    ["25_TABARD"] = true,
                    ["23_SHIELD"] = true,
                    ["17_SHIRT"] = true,
                    ["12_NECK"] = true,
                    ["06_RELIC"] = true,
                    ["24_CLOAK"] = true,
                    ["21_FINGER"] = true,
                },
                ["TYPE"] = {
                    [4009] = true,
                    [4010] = true,
                    [4008] = true,
                    [4005] = true,
                    [4006] = true,
                    [4000] = true,
                    [4001] = true,
                    [4007] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_CONSUMABLES"),
            ["icon"] = "INV_Misc_Food_04",
            ["attributes"] = {
                ["TYPE"] = {
                    true, -- [1]
                    true, -- [2]
                    true, -- [3]
                    true, -- [4]
                    true, -- [5]
                    true, -- [6]
                    true, -- [7]
                    true, -- [8]
                    [0] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_MISCELLANEOUS"),
            ["icon"] = "INV_MISC_QUESTIONMARK",
            ["attributes"] = {
                ["TYPE"] = {
                    [15003] = true,
                    [15000] = true,
                    [15004] = true,
                    [15001] = true,
                    [15005] = true,
                    [15002] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_CONTAINERS"),
            ["icon"] = "INV_Misc_Bag_07",
            ["attributes"] = {
                ["TYPE"] = {
                    [1000] = true,
                    [1002] = true,
                    [1004] = true,
                    [1006] = true,
                    [1008] = true,
                    [1001] = true,
                    [1003] = true,
                    [1005] = true,
                    [1007] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_GEMS"),
            ["icon"] = "INV_Misc_Gem_Variety_02",
            ["attributes"] = {
                ["TYPE"] = {
                    [3001] = true,
                    [3002] = true,
                    [3003] = true,
                    [3004] = true,
                    [3005] = true,
                    [3006] = true,
                    [3007] = true,
                    [3000] = true,
                    [3008] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = GetItemClassInfo(Enum.ItemClass.Reagent),
            ["icon"] = "INV_Misc_Orb_04",
            ["attributes"] = {
                ["TYPE"] = {
                    [5000] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = GetItemClassInfo(Enum.ItemClass.Projectile),
            ["icon"] = "INV_Ammo_Arrow_01",
            ["attributes"] = {
                ["TYPE"] = {
                    [6002] = true,
                    [6003] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_TRADE_GOODS"),
            ["icon"] = "Trade_Mining",
            ["attributes"] = {
                ["TYPE"] = {
                    [7006] = true,
                    [7007] = true,
                    [7008] = true,
                    [7009] = true,
                    [7010] = true,
                    [7011] = true,
                    [7012] = true,
                    [7013] = true,
                    [7014] = true,
                    [7000] = true,
                    [7001] = true,
                    [7002] = true,
                    [7003] = true,
                    [7004] = true,
                    [7005] = true,
                    [7015] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_RECIPES"),
            ["icon"] = "INV_Scroll_04",
            ["attributes"] = {
                ["TYPE"] = {
                    [9000] = true,
                    [9002] = true,
                    [9004] = true,
                    [9006] = true,
                    [9008] = true,
                    [9010] = true,
                    [9001] = true,
                    [9003] = true,
                    [9005] = true,
                    [9007] = true,
                    [9009] = true,
                    [9011] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_QUEST_ITEMS"),
            ["icon"] = "achievement_quests_completed_06",
            ["attributes"] = {
                ["TYPE"] = {
                    [12000] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_KEYS"),
            ["icon"] = "INV_Misc_Key_06",
            ["attributes"] = {
                ["TYPE"] = {
                    [13000] = true,
                    [13001] = true,
                },
            },
        },
        {
            ["version"] = "2.1",
            ["name"] = S.Localize("CATEGORY_GLYPHS"),
            ["icon"] = "inv_inscription_majorglyph01",
            ["attributes"] = {
                ["TYPE"] = {
                    [16005] = true,
                    [16007] = true,
                    [16009] = true,
                    [16011] = true,
                    [16002] = true,
                    [16004] = true,
                    [16006] = true,
                    [16008] = true,
                    [16001] = true,
                    [16003] = true,
                },
            },
        },
    }

 --Vanilla
else
    defaultCategories = {
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["INVENTORY_SLOT"] = {
                    ["02_WEAPON"] = true,
                    ["04_RANGED"] = true,
                    ["06_THROWN"] = false,
                    ["05_AMMO"] = false,
                    ["01_MAINHAND"] = true,
                    ["03_2HWEAPON"] = true,
                },
                ["TYPE"] = {
                    [2006] = true,
                    [2007] = true,
                    [2008] = true,
                    [2010] = true,
                    [2011] = true,
                    [2012] = true,
                    [2013] = true,
                    [2014] = true,
                    [2015] = true,
                    [2016] = true,
                    [2017] = true,
                    [2018] = true,
                    [2019] = true,
                    [2020] = true,
                    [2000] = true,
                    [2001] = true,
                    [2002] = true,
                    [2003] = true,
                    [2004] = true,
                    [2005] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_WEAPONS"),
            ["icon"] = "INV_Sword_04",
        }, -- [1]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [4002] = true,
                    [4003] = true,
                    [4004] = true,
                    [4000] = true,
                    [4001] = true,
                },
                ["INVENTORY_SLOT"] = {
                    ["18_WAIST"] = true,
                    ["16_HAND"] = true,
                    ["15_WRIST"] = true,
                    ["14_CHEST"] = true,
                    ["13_SHOULDER"] = true,
                    ["20_FEET"] = true,
                    ["19_LEGS"] = true,
                    ["11_HEAD"] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_ARMOR"),
            ["icon"] = "Spell_Nature_EnchantArmor",
        }, -- [2]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [4009] = true,
                    [4001] = true,
                    [4005] = true,
                    [4006] = true,
                    [4007] = true,
                    [4008] = true,
                    [4000] = true,
                },
                ["INVENTORY_SLOT"] = {
                    ["12_NECK"] = true,
                    ["06_RELIC"] = true,
                    ["21_FINGER"] = true,
                    ["23_SHIELD"] = true,
                    ["17_SHIRT"] = true,
                    ["22_TRINKET"] = true,
                    ["24_CLOAK"] = true,
                    ["25_TABARD"] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_ACCESSORIES"),
            ["icon"] = "INV_Misc_Cape_08",
        }, -- [3]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [0] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_CONSUMABLES"),
            ["icon"] = "INV_Misc_Food_04",
        }, -- [4]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [1001] = true,
                    [1003] = true,
                    [11003] = true,
                    [1000] = true,
                    [1002] = true,
                    [1004] = true,
                    [11002] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_CONTAINERS"),
            ["icon"] = "INV_Misc_Bag_07",
        }, -- [5]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [5000] = true,
                },
            },
            ["name"] = GetItemClassInfo(Enum.ItemClass.Reagent),
            ["icon"] = "INV_Misc_Orb_04",
        }, -- [6]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [6002] = true,
                    [6003] = true,
                },
            },
            ["name"] = GetItemClassInfo(Enum.ItemClass.Projectile),
            ["icon"] = "INV_Ammo_Arrow_01",
        }, -- [7]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [7000] = true,
                    [7001] = true,
                    [7002] = true,
                    [7003] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_TRADE_GOODS"),
            ["icon"] = "Trade_Mining",
        }, -- [8]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [9000] = true,
                    [9002] = true,
                    [9004] = true,
                    [9006] = true,
                    [9008] = true,
                    [9001] = true,
                    [9003] = true,
                    [9005] = true,
                    [9007] = true,
                    [9009] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_RECIPES"),
            ["icon"] = "INV_Scroll_04",
        }, -- [9]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [12000] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_QUEST_ITEMS"),
            ["icon"] = "WoW_Token01",
        }, -- [10]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [13000] = true,
                    [13001] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_KEYS"),
            ["icon"] = "INV_Misc_Key_04",
        }, -- [11]
        {
            ["version"] = "2.1",
            ["attributes"] = {
                ["TYPE"] = {
                    [15000] = true,
                },
            },
            ["name"] = S.Localize("CATEGORY_MISCELLANEOUS"),
            ["icon"] = "INV_MISC_QUESTIONMARK",
        }, -- [12]
    }
end
defaultSettings.categories2 = S.GetDefaultCategories()

-- Default fonts
local clientLocale = GetLocale()
local fontPath = "Fonts\\FRIZQT__.ttf"
if clientLocale == "koKR" then
  fontPath = "Fonts\\K_Pagetext.ttf"
elseif clientLocale == "zhCN" then
  fontPath = "Fonts\\ARKai_T.ttf"
elseif clientLocale == "zhTW" then
  fontPath = "Fonts\\blei00d.ttf"
elseif clientLocale == "ruRU" then
  fontPath = "Fonts\\MORPHEUS_CYR.ttf"
end
for k,v in pairs(LSM:List("font")) do
    if fontPath == LSM:Fetch("font", v) then
        defaultSettings["font"] = v
    end
end


function S.Settings.SetDefaultProfile(profileIndex)
    Sorted_DefaultSettingsProfile = profileIndex
end

function S.Settings.GetDefaultProfile()
    if Sorted_DefaultSettingsProfile and Sorted_SettingsProfiles[Sorted_DefaultSettingsProfile] then
        return Sorted_DefaultSettingsProfile
    end
    return nil
end

function S.Settings.HasProfile()
    local data = S.GetData(UnitGUID("player"))
    if not data.settingsProfile then
        return false
    elseif not Sorted_SettingsProfiles[data.settingsProfile] then
        return false
    end
    return true
end

function S.Settings.GetProfile()
    local data = S.GetData(UnitGUID("player"))
    return data.settingsProfile
end

function S.Settings.SetProfile(profileIndex)
    local data = S.GetData(UnitGUID("player"))
    data.settingsProfile = profileIndex
    S.Settings.ReloadAll()
    S.Utils.TriggerEvent("ProfileChanged")
end

function S.Settings.DeleteProfile()
    local data = S.GetData(UnitGUID("player"))
    Sorted_SettingsProfiles[data.settingsProfile] = nil
    S.Settings.SetProfile(nil)
end

local function GetSettings(guid)
    if not guid then guid = UnitGUID("player") end
    local data = S.GetData(guid)
    if not data then
        return nil
    end
    if data.settingsProfile then
        return Sorted_SettingsProfiles[data.settingsProfile]
    end
end

local function SetSettingsToDefaults(self)
    for k,v in pairs(Sorted_defaultSettings) do
        if type(v) == "table" then
            self[k] = {}
            S.Utils.CopyTable(v, self[k])
        else
            self[k] = v
        end
    end
end

local function CreateNewSettingsProfile(name)
    -- Generate a unique index. Appends a letter if a settings profile somehow shares the same number
    local index = tostring(time())
    if Sorted_SettingsProfiles[index] then
        for i = 97,122 do
            if not Sorted_SettingsProfiles[index..string.char(i)] then
                index = index..string.char(i)
                break
            end
        end
    end
    Sorted_SettingsProfiles[index] = {}
    S.Utils.CopyTable(defaultSettings, Sorted_SettingsProfiles[index])
    if not name then
        Sorted_SettingsProfiles[index].profileName = UnitName("player").." ("..GetRealmName()..")"
    else
        Sorted_SettingsProfiles[index].profileName = name
    end
    return index
end
function S.Settings.CreateNewProfile(name)
    local profile = CreateNewSettingsProfile(name)
    S.Settings.SetProfile(profile)
    return profile
end

local function CreateCopyOfSettingsProfile(origIndex)
    local newIndex = CreateNewSettingsProfile(Sorted_SettingsProfiles[origIndex].profileName.." - Copy")
    local originalSettings = Sorted_SettingsProfiles[origIndex]
    local newSettings = Sorted_SettingsProfiles[newIndex]
    for k,v in pairs(originalSettings) do
        if k ~= "profileName" then
            if type(v) == "table" then
                newSettings[k] = {}
                S.Utils.CopyTable(v, newSettings[k])
            else
                newSettings[k] = v
            end
        end
    end
    return newIndex
end
function S.Settings.CopyProfile()
    local new = CreateCopyOfSettingsProfile(S.Settings.GetProfile())
    S.Settings.SetProfile(new)
end

-- Returns value of a given setting. If player hasn't selected a settings profile then returns the default value
function S.Settings.Get(setting, guid)
    local t = GetSettings(guid)
    if not t then 
        if setting == "categories2" then
            return S.GetDefaultCategories()
        else
            return defaultSettings[setting] 
        end
    end
    if not t[setting] then
        if setting == "categories2" then
            t[setting] = {}
            S.Utils.CopyTable(S.GetDefaultCategories(), t[setting])
        else
            t[setting] = defaultSettings[setting]
        end
    end
    return t[setting]
end

function S.Settings.Set(setting, value, guid)
    local settings = GetSettings(guid)
    if settings then 
        settings[setting] = value
        S.Utils.TriggerEvent("SettingChanged-"..setting, value)
    end
end

function S.Settings.ReloadAll()
    local settings = GetSettings()
    if not settings then
        settings = defaultSettings
    end
    for k, v in pairs(settings) do
        S.Utils.TriggerEvent("SettingChanged-"..k, v)
    end
end

function S.Settings.UpdateFonts()
    local flags = ""
    local shadowX, shadowY
    if S.Settings.Get("fontOutline") > 1 then
        flags = "THICKOUTLINE"
    elseif S.Settings.Get("fontOutline") > 0 then
        flags = "OUTLINE"
    end
    local size = S.Settings.Get("fontSizePts")
    local path = S.Utils.GetFontPath(S.Settings.Get("font"))
    local shadow = S.Settings.Get("fontShadow")
    SortedFont:SetFont(path, size, flags)
    SortedFont:SetShadowColor(0, 0, 0, 1)
    SortedFont:SetShadowOffset(shadow, -shadow)
end
local function OnFontSettingChanged()
    S.Settings.UpdateFonts()
    S.Utils.TriggerEvent("FontChanged")
end
S.Utils.RunOnEvent(nil, "SettingChanged-fontOutline", OnFontSettingChanged)
S.Utils.RunOnEvent(nil, "SettingChanged-fontShadow", OnFontSettingChanged)
S.Utils.RunOnEvent(nil, "SettingChanged-fontSizePts", OnFontSettingChanged)
S.Utils.RunOnEvent(nil, "SettingChanged-font", OnFontSettingChanged)