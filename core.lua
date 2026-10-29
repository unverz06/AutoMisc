local ADDON_NAME, ns = ...
local L = ns.L

ns.settings = {}

ns.defaults = {
    enabled = true,
    messages = true,
    pauseShift = true,
    pauseCtrl = true,
    pauseAlt = true,
    sellJunk = true,
    autoRepair = true,
    repairGuild = true,
    repairPersonal = true,
    acceptSummon = false,
    acceptResurrect = false,
    declineDuels = false,
    acceptInvites = false,
}

function ns.Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. L.TITLE .. "|r |cffffff00" .. message .. "|r")
end

-- Prints only when the user kept chat messages enabled
function ns.Notify(message)
    if ns.db and ns.db.messages then
        ns.Print(message)
    end
end

function ns.FormatMoney(copper)
    copper = math.floor(copper or 0)
    if C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString then
        return C_CurrencyInfo.GetCoinTextureString(copper)
    elseif GetCoinTextureString then
        return GetCoinTextureString(copper)
    end
    return string.format("%dg %ds %dc", math.floor(copper / 10000), math.floor((copper % 10000) / 100), copper % 100)
end

--[[
    Pause: true while one of the pause keys enabled in the options is held
]]
function ns.IsPaused()
    local db = ns.db
    return (db.pauseShift and IsShiftKeyDown())
        or (db.pauseCtrl and IsControlKeyDown())
        or (db.pauseAlt and IsAltKeyDown())
        or false
end

local function InitDB()
    AutoMiscDB = AutoMiscDB or {}
    for key, value in pairs(ns.defaults) do
        if AutoMiscDB[key] == nil then
            AutoMiscDB[key] = value
        end
    end
    ns.db = AutoMiscDB
end

function ns.PrintStatus()
    ns.Print(L.STATE:format(ns.db.enabled and L.ENABLED or L.DISABLED))
end

-- Goes through the options panel when it exists so the checkbox stays in sync
function ns.SetEnabled(value)
    value = value and true or false
    local setting = ns.settings.enabled
    if setting then
        if setting:GetValue() ~= value then
            setting:SetValue(value) -- the panel callback prints the status
            return
        end
    else
        ns.db.enabled = value
    end
    ns.PrintStatus()
end

--[[
    Event dispatcher. Handlers run only when the addon is enabled and not paused,
    unless `always` is true (state tracking such as MERCHANT_CLOSED).
]]
local handlers = {}
local eventFrame = CreateFrame("Frame")

function ns.On(event, handler, always)
    local list = handlers[event]
    if not list then
        list = {}
        handlers[event] = list
        eventFrame:RegisterEvent(event)
    end
    list[#list + 1] = { fn = handler, always = always }
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    local list = handlers[event]
    if not list or not ns.db then return end
    local active = ns.db.enabled and not ns.IsPaused()
    for _, entry in ipairs(list) do
        if active or entry.always then
            entry.fn(...)
        end
    end
end)

--[[
    Slash commands
]]
SLASH_AUTOMISC1 = "/automisc"
SLASH_AUTOMISC2 = "/am"

SlashCmdList["AUTOMISC"] = function(msg)
    local command = (msg or ""):lower():match("^(%S*)")
    if command == "on" then
        ns.SetEnabled(true)
    elseif command == "off" then
        ns.SetEnabled(false)
    elseif command == "config" or command == "options" then
        ns.OpenOptions()
    elseif command == "" or command == "status" then
        ns.PrintStatus()
    else
        ns.Print(L.HELP)
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, addonName)
    if addonName ~= ADDON_NAME then return end
    self:UnregisterEvent("ADDON_LOADED")
    InitDB()
    ns.InitOptions()
end)
