local _, ns = ...
local L = ns.L

local function HidePopups(...)
    if StaticPopup_Hide then
        for i = 1, select("#", ...) do
            StaticPopup_Hide((select(i, ...)))
        end
    end
end

ns.On("CONFIRM_SUMMON", function()
    if not ns.db.acceptSummon or InCombatLockdown() then return end
    local confirm = (C_SummonInfo and C_SummonInfo.ConfirmSummon) or ConfirmSummon
    if not confirm then return end
    confirm()
    HidePopups("CONFIRM_SUMMON")
    ns.Notify(L.MSG_SUMMON)
end)

ns.On("RESURRECT_REQUEST", function(inviter)
    if not ns.db.acceptResurrect then return end
    AcceptResurrect()
    HidePopups("RESURRECT", "RESURRECT_NO_SICKNESS", "RESURRECT_NO_TIMER")
    ns.Notify(L.MSG_RESURRECT:format(inviter or "?"))
end)

ns.On("DUEL_REQUESTED", function(challenger)
    if not ns.db.declineDuels then return end
    CancelDuel()
    HidePopups("DUEL_REQUESTED")
    ns.Notify(L.MSG_DUEL:format(challenger or "?"))
end)

--[[
    Group invites: only people you know (friend, Battle.net friend, guild member).
    The popup is hidden once the roster changes (the wiki warns that hiding it
    earlier can run before Blizzard has shown it).
]]
local function IsKnownPlayer(guid)
    if not guid then return false end
    if C_FriendList and C_FriendList.IsFriend and C_FriendList.IsFriend(guid) then return true end
    if C_BattleNet and C_BattleNet.GetAccountInfoByGUID and C_BattleNet.GetAccountInfoByGUID(guid) then return true end
    if IsGuildMember and IsGuildMember(guid) then return true end
    return false
end

local pendingInvitePopup = false

ns.On("PARTY_INVITE_REQUEST", function(name, _, _, _, _, _, inviterGUID)
    if not ns.db.acceptInvites or IsInGroup() or not IsKnownPlayer(inviterGUID) then return end
    AcceptGroup()
    pendingInvitePopup = true
    C_Timer.After(1, function()
        pendingInvitePopup = false
        HidePopups("PARTY_INVITE")
    end)
    ns.Notify(L.MSG_INVITE:format(name or "?"))
end)

ns.On("GROUP_ROSTER_UPDATE", function()
    if pendingInvitePopup then
        pendingInvitePopup = false
        HidePopups("PARTY_INVITE")
    end
end, true)
