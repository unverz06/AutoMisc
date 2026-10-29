--[[
    Options panel (Options > AddOns > AutoMisc), built from the registry below.

    key       : key in AutoMiscDB (default value in ns.defaults)
    label     : locale key of the label
    tooltip   : locale key of the tooltip
    section   : locale key of a section header shown before the option
    parent    : key of the option this one depends on (greyed when the parent is unchecked)
    onChange  : called when the value changes from the panel
]]
local _, ns = ...
local L = ns.L

local features = {
    { key = "enabled", label = "OPT_ENABLE", tooltip = "OPT_ENABLE_TIP", onChange = function() ns.PrintStatus() end },
    { key = "messages", label = "OPT_MESSAGES", tooltip = "OPT_MESSAGES_TIP" },

    { key = "pauseShift", label = "OPT_PAUSE_SHIFT", tooltip = "OPT_PAUSE_SHIFT_TIP", section = "OPT_PAUSE_SECTION" },
    { key = "pauseCtrl", label = "OPT_PAUSE_CTRL", tooltip = "OPT_PAUSE_CTRL_TIP" },
    { key = "pauseAlt", label = "OPT_PAUSE_ALT", tooltip = "OPT_PAUSE_ALT_TIP" },

    { key = "sellJunk", label = "OPT_SELL_JUNK", tooltip = "OPT_SELL_JUNK_TIP", section = "OPT_VENDOR_SECTION" },
    { key = "autoRepair", label = "OPT_REPAIR", tooltip = "OPT_REPAIR_TIP" },
    { key = "repairGuild", label = "OPT_REPAIR_GUILD", tooltip = "OPT_REPAIR_GUILD_TIP", parent = "autoRepair" },
    { key = "repairPersonal", label = "OPT_REPAIR_PERSONAL", tooltip = "OPT_REPAIR_PERSONAL_TIP", parent = "autoRepair" },

    { key = "acceptSummon", label = "OPT_ACCEPT_SUMMON", tooltip = "OPT_ACCEPT_SUMMON_TIP", section = "OPT_SOCIAL_SECTION" },
    { key = "acceptResurrect", label = "OPT_ACCEPT_RESURRECT", tooltip = "OPT_ACCEPT_RESURRECT_TIP" },
    { key = "declineDuels", label = "OPT_DECLINE_DUELS", tooltip = "OPT_DECLINE_DUELS_TIP" },
    { key = "acceptInvites", label = "OPT_ACCEPT_INVITES", tooltip = "OPT_ACCEPT_INVITES_TIP" },
}

function ns.InitOptions()
    if not (Settings and Settings.RegisterVerticalLayoutCategory and Settings.RegisterAddOnSetting) then
        return
    end

    local category = Settings.RegisterVerticalLayoutCategory("AutoMisc")
    ns.category = category
    local initializers = {}

    for _, feature in ipairs(features) do
        if feature.section and CreateSettingsListSectionHeaderInitializer and SettingsPanel then
            SettingsPanel:GetLayout(category):AddInitializer(
                CreateSettingsListSectionHeaderInitializer(L[feature.section]))
        end

        local setting = Settings.RegisterAddOnSetting(
            category,
            "AUTOMISC_" .. feature.key:upper(),
            feature.key,
            ns.db,
            Settings.VarType.Boolean,
            L[feature.label],
            ns.defaults[feature.key]
        )
        ns.settings[feature.key] = setting

        if feature.onChange then
            setting:SetValueChangedCallback(function(_, value) feature.onChange(value) end)
        end

        local initializer = Settings.CreateCheckbox(category, setting, L[feature.tooltip])
        initializers[feature.key] = initializer

        local parent = feature.parent and initializers[feature.parent]
        if initializer and parent and initializer.SetParentInitializer then
            initializer:SetParentInitializer(parent, function() return ns.db[feature.parent] end)
        end
    end

    Settings.RegisterAddOnCategory(category)
end

function ns.OpenOptions()
    if ns.category then
        Settings.OpenToCategory(ns.category:GetID())
    else
        ns.Print(L.OPT_UNAVAILABLE)
    end
end
