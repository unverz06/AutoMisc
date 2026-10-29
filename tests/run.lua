-- Mock test harness: lua tests/run.lua (from the addon folder)
-- Simulates the small part of the WoW API that AutoMisc uses.

local failures, passed = 0, 0
local function check(cond, name)
    if cond then passed = passed + 1 else failures = failures + 1; print("FAIL: " .. name) end
end

local function readToc()
    local files = {}
    for line in io.lines("AutoMisc.toc") do
        if not line:match("^#") and line:match("%.lua%s*$") then files[#files + 1] = line:match("^%s*(.-)%s*$") end
    end
    return files
end

-- Builds a fresh simulated client and loads the addon through the TOC
local function newWorld(locale)
    local W = { chat = {}, timers = {}, frames = {}, keys = {}, calls = {}, popupsHidden = {} }
    local env = setmetatable({}, { __index = _G })
    env._G = env
    W.env = env

    env.GetLocale = function() return locale or "enUS" end
    env.DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) W.chat[#W.chat + 1] = m end }
    env.CreateFrame = function()
        local f = { events = {} }
        function f:RegisterEvent(e) self.events[e] = true end
        function f:UnregisterEvent(e) self.events[e] = nil end
        function f:SetScript(_, fn) self.onEvent = fn end
        W.frames[#W.frames + 1] = f
        return f
    end
    env.C_Timer = { After = function(_, fn) W.timers[#W.timers + 1] = fn end }
    env.IsShiftKeyDown = function() return W.keys.shift or false end
    env.IsControlKeyDown = function() return W.keys.ctrl or false end
    env.IsAltKeyDown = function() return W.keys.alt or false end
    env.InCombatLockdown = function() return W.combat or false end
    env.SlashCmdList = {}
    env.StaticPopup_Hide = function(n) W.popupsHidden[#W.popupsHidden + 1] = n end
    env.GetCoinTextureString = function(c) return c .. "c" end

    -- vendor / bags
    W.bags = {}
    W.money = 0
    W.repair = { can = false, cost = 0, guild = false, inGuild = false, allowance = 0, guildWorks = true }
    W.sold = {}
    env.NUM_BAG_SLOTS = 4
    env.Enum = { ItemQuality = { Poor = 0 } }
    env.C_Container = {
        GetContainerNumSlots = function(bag) return W.bags[bag] and W.bags[bag].n or 0 end,
        GetContainerItemInfo = function(bag, slot) return W.bags[bag] and W.bags[bag][slot] end,
        UseContainerItem = function(bag, slot) W.sold[#W.sold + 1] = bag .. ":" .. slot end,
    }
    env.C_Item = { GetItemInfo = function(link) return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, W.prices and W.prices[link] end }
    env.GetMoney = function() return W.money end
    env.CanMerchantRepair = function() return W.repair.can end
    env.GetRepairAllCost = function() return W.repair.cost, W.repair.can and W.repair.cost > 0 or nil end
    env.IsInGuild = function() return W.repair.inGuild end
    env.CanGuildBankRepair = function() return W.repair.guild end
    env.GetGuildBankWithdrawMoney = function() return W.repair.allowance end
    env.RepairAllItems = function(useGuild)
        W.calls[#W.calls + 1] = useGuild and "repair:guild" or "repair:personal"
        if useGuild and not W.repair.guildWorks then return end
        if not useGuild then W.money = W.money - W.repair.cost end
        W.repair.cost = 0
    end

    -- social
    env.ConfirmSummon = function() W.calls[#W.calls + 1] = "summon" end
    env.AcceptResurrect = function() W.calls[#W.calls + 1] = "res" end
    env.CancelDuel = function() W.calls[#W.calls + 1] = "duel" end
    env.AcceptGroup = function() W.calls[#W.calls + 1] = "group" end
    env.IsInGroup = function() return W.inGroup or false end
    env.C_FriendList = { IsFriend = function(g) return W.friends and W.friends[g] or false end }
    env.IsGuildMember = function(g) return W.guildies and W.guildies[g] or false end

    -- settings panel recorder
    W.registered = {}
    W.initializers = {}
    env.Settings = {
        VarType = { Boolean = "Boolean" },
        RegisterVerticalLayoutCategory = function() return { GetID = function() return 1 end } end,
        RegisterAddOnSetting = function(_, var, key, tbl, _, _, default)
            local s = { var = var }
            function s:GetValue() return tbl[key] end
            function s:SetValue(v) tbl[key] = v; if self.cb then self.cb(self, v) end end
            function s:SetValueChangedCallback(fn) self.cb = fn end
            W.registered[key] = { setting = s, default = default }
            return s
        end,
        CreateCheckbox = function(_, setting)
            local i = { setting = setting }
            function i:SetParentInitializer(p) self.parent = p end
            W.initializers[#W.initializers + 1] = i
            return i
        end,
        RegisterAddOnCategory = function() W.registeredCategory = true end,
        OpenToCategory = function(id) W.opened = id end,
    }

    local ns = {}
    local before = {}
    for k in pairs(env) do before[k] = true end
    for _, file in ipairs(readToc()) do
        local chunk = assert(loadfile(file, "t", env)) -- Lua 5.2+ signature
        chunk("AutoMisc", ns)
    end
    W.leaks = {}
    for k in pairs(env) do
        if not before[k] and k ~= "SLASH_AUTOMISC1" and k ~= "SLASH_AUTOMISC2" then W.leaks[#W.leaks + 1] = k end
    end
    W.ns = ns

    function W.fire(event, ...)
        for _, f in ipairs(W.frames) do
            if f.events[event] and f.onEvent then f:onEvent(event, ...) end
        end
    end
    function W.flush()
        local t = W.timers; W.timers = {}
        for _, fn in ipairs(t) do fn() end
    end
    function W.load(db)
        env.AutoMiscDB = db
        W.fire("ADDON_LOADED", "AutoMisc")
    end
    function W.chatHas(text)
        for _, m in ipairs(W.chat) do if m:find(text, 1, true) then return true end end
        return false
    end
    function W.called(name)
        for _, c in ipairs(W.calls) do if c == name then return true end end
        return false
    end
    return W
end

local function gray(link, n) return { quality = 0, hyperlink = link, stackCount = n or 1, hasNoValue = false, isLocked = false } end
local function white(link) return { quality = 1, hyperlink = link, stackCount = 1 } end

-- 1. defaults + DB merge keep user values
do
    local W = newWorld()
    W.load({ sellJunk = false })
    check(W.env.AutoMiscDB.sellJunk == false, "DB keeps user value")
    check(W.env.AutoMiscDB.autoRepair == true, "DB gets missing defaults")
    check(W.env.AutoMiscDB.acceptSummon == false, "social features off by default")
    check(#W.leaks == 0, "no accidental globals: " .. table.concat(W.leaks, ","))
end

-- 2. sell junk
do
    local W = newWorld()
    W.load({})
    W.bags[0] = { n = 5, gray("g1", 2), white("w1"), gray("g2"), { quality = 0, hyperlink = "nv", hasNoValue = true }, { quality = 0, hyperlink = "lk", isLocked = true } }
    W.bags[2] = { n = 1, gray("g3") }
    W.prices = { g1 = 10, g2 = 5, g3 = 1 }
    W.fire("MERCHANT_SHOW")
    check(#W.sold == 3 and W.sold[1] == "0:1" and W.sold[2] == "0:3" and W.sold[3] == "2:1", "sells only sellable grey items")
    check(W.chatHas("Sold 3 grey item(s) for 26c."), "sold summary with total (10*2+5+1)")
end

-- 3. pause keys
do
    local W = newWorld()
    W.load({})
    W.bags[0] = { n = 1, gray("g1") }
    W.keys.shift = true
    W.fire("MERCHANT_SHOW")
    check(#W.sold == 0, "Shift pauses the addon")
    W.keys.shift = false; W.keys.ctrl = true
    W.fire("MERCHANT_SHOW")
    check(#W.sold == 0, "Ctrl pauses the addon")
    W.keys.ctrl = false; W.keys.alt = true
    W.fire("MERCHANT_SHOW")
    check(#W.sold == 0, "Alt pauses the addon")
    W.env.AutoMiscDB.pauseAlt = false
    W.fire("MERCHANT_SHOW")
    check(#W.sold == 1, "pause key can be disabled in options")
    W.keys.alt = false
    W.env.AutoMiscDB.enabled = false
    W.fire("MERCHANT_SHOW")
    check(#W.sold == 1, "disabled addon does nothing")
end

-- 4. repair: guild works
do
    local W = newWorld()
    W.load({})
    W.money = 1000
    W.repair = { can = true, cost = 500, guild = true, inGuild = true, allowance = 800, guildWorks = true }
    W.fire("MERCHANT_SHOW")
    check(W.called("repair:guild") and not W.called("repair:personal"), "guild repair used first")
    check(not W.chatHas("Repaired"), "no message before the server answered")
    W.flush()
    check(W.chatHas("Repaired for 500c (guild funds)."), "guild repair announced after verification")
    check(W.money == 1000, "personal gold untouched")
end

-- 5. guild refuses -> personal fallback
do
    local W = newWorld()
    W.load({})
    W.money = 1000
    W.repair = { can = true, cost = 500, guild = true, inGuild = true, allowance = -1, guildWorks = false }
    W.fire("MERCHANT_SHOW")
    W.flush()
    check(W.called("repair:guild") and W.called("repair:personal"), "falls back to personal gold when guild refuses")
    check(W.money == 500 and W.chatHas("Repaired for 500c."), "personal repair paid and announced")
    check(not W.chatHas("guild funds"), "no false guild announcement")
end

-- 6. no guild / allowance too small / guild option off
for _, case in ipairs({
    { "no guild", { can = true, cost = 500, guild = false, inGuild = false, allowance = 0 }, {} },
    { "allowance too small", { can = true, cost = 500, guild = true, inGuild = true, allowance = 100 }, {} },
    { "guild option off", { can = true, cost = 500, guild = true, inGuild = true, allowance = 9999 }, { repairGuild = false } },
}) do
    local W = newWorld()
    W.load(case[3])
    W.money = 1000
    W.repair = case[2]; W.repair.guildWorks = true
    W.fire("MERCHANT_SHOW")
    check(W.called("repair:personal") and not W.called("repair:guild"), "personal repair: " .. case[1])
end

-- 7. not enough gold / personal disabled / nothing to repair
do
    local W = newWorld()
    W.load({})
    W.money = 100
    W.repair = { can = true, cost = 500 }
    W.fire("MERCHANT_SHOW")
    check(#W.calls == 0 and W.chatHas("Not enough gold to repair (500c needed)."), "not enough gold")

    W = newWorld(); W.load({ repairPersonal = false })
    W.money = 1000; W.repair = { can = true, cost = 500 }
    W.fire("MERCHANT_SHOW")
    check(#W.calls == 0, "personal repair disabled")

    W = newWorld(); W.load({})
    W.money = 1000; W.repair = { can = false, cost = 0 }
    W.fire("MERCHANT_SHOW")
    check(#W.calls == 0, "non-repair vendor ignored")

    W = newWorld(); W.load({ autoRepair = false })
    W.money = 1000; W.repair = { can = true, cost = 500 }
    W.fire("MERCHANT_SHOW")
    check(#W.calls == 0, "auto repair off")
end

-- 8. gold from junk sale lets the retry repair personally
do
    local W = newWorld()
    W.load({})
    W.money = 100
    W.bags[0] = { n = 1, gray("g1") }
    W.repair = { can = true, cost = 500 }
    W.fire("MERCHANT_SHOW")
    check(not W.called("repair:personal"), "cannot pay yet")
    W.money = 700 -- sale reached the client
    W.flush()
    check(W.called("repair:personal"), "retry repairs after the sale")
end

-- 9. social features
do
    local W = newWorld()
    W.load({})
    W.fire("CONFIRM_SUMMON"); W.fire("RESURRECT_REQUEST", "Bob"); W.fire("DUEL_REQUESTED", "Eve")
    W.fire("PARTY_INVITE_REQUEST", "Ann", false, false, false, true, false, "Player-1")
    check(#W.calls == 0, "social features do nothing by default")

    W = newWorld()
    W.load({ acceptSummon = true, acceptResurrect = true, declineDuels = true, acceptInvites = true })
    W.fire("CONFIRM_SUMMON")
    check(W.called("summon"), "summon accepted")
    W.combat = true; W.calls = {}
    W.fire("CONFIRM_SUMMON")
    check(#W.calls == 0, "summon not accepted in combat")
    W.combat = false
    W.fire("RESURRECT_REQUEST", "Bob")
    check(W.called("res") and W.chatHas("Resurrection from Bob accepted."), "resurrection accepted")
    W.fire("DUEL_REQUESTED", "Eve")
    check(W.called("duel") and W.chatHas("Duel from Eve declined."), "duel declined")

    W.calls = {}
    W.fire("PARTY_INVITE_REQUEST", "Stranger", false, false, false, true, false, "Player-9")
    check(#W.calls == 0, "stranger invite ignored")
    W.friends = { ["Player-1"] = true }; W.guildies = { ["Player-2"] = true }
    W.fire("PARTY_INVITE_REQUEST", "Ann", false, false, false, true, false, "Player-1")
    W.fire("PARTY_INVITE_REQUEST", "Gil", false, false, false, true, false, "Player-2")
    check(#W.calls == 2, "friend and guild invites accepted")
    W.fire("GROUP_ROSTER_UPDATE")
    check(W.popupsHidden[#W.popupsHidden] == "PARTY_INVITE", "invite popup hidden on roster update")
    W.calls = {}; W.inGroup = true
    W.fire("PARTY_INVITE_REQUEST", "Ann", false, false, false, true, false, "Player-1")
    check(#W.calls == 0, "invite ignored when already grouped")
    W.keys.shift = true; W.inGroup = false
    W.fire("DUEL_REQUESTED", "Eve")
    check(#W.calls == 0, "social features also respect the pause key")
end

-- 10. slash commands and options panel
do
    local W = newWorld()
    W.load({})
    local slash = W.env.SlashCmdList["AUTOMISC"]
    check(W.env.SLASH_AUTOMISC1 == "/automisc" and W.env.SLASH_AUTOMISC2 == "/am", "slash aliases")
    check(W.registeredCategory and #W.initializers == 13, "options: 13 checkboxes registered")
    local ok = true
    for key in pairs(W.ns.defaults) do if not W.registered[key] then ok = false end end
    check(ok, "every default has an option")
    check(W.registered.repairGuild.setting and W.initializers[8].parent == W.initializers[7], "repair sub-options depend on auto repair")

    slash("off")
    check(W.env.AutoMiscDB.enabled == false and W.chatHas("State is Disabled"), "/am off")
    slash("on")
    check(W.env.AutoMiscDB.enabled == true and W.chatHas("State is Enabled"), "/am on")
    slash("config")
    check(W.opened == 1, "/am config opens panel")
    slash("nonsense")
    check(W.chatHas("Usage: /am"), "/am help")
end

-- 11. messages option and frFR locale
do
    local W = newWorld()
    W.load({ messages = false })
    W.bags[0] = { n = 1, gray("g1") }
    W.fire("MERCHANT_SHOW")
    check(#W.sold == 1 and #W.chat == 0, "messages option silences the chat")

    W = newWorld("frFR")
    W.load({})
    W.env.SlashCmdList["AUTOMISC"]("on")
    check(W.chatHas("Le statut est : Activé"), "frFR locale")
    check(W.ns.L.MSG_SOLD ~= nil and W.ns.L.NOT_A_KEY == "NOT_A_KEY", "missing key falls back to its name")
end

print(string.format("%d passed, %d failed", passed, failures))
os.exit(failures == 0 and 0 or 1)
