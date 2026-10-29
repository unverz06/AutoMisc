local _, ns = ...

-- English is the fallback: a missing key in another locale shows the English text,
-- a missing key everywhere shows the key itself.
local L = setmetatable({}, { __index = function(_, key) return key end })
ns.L = L

L.TITLE = "AutoMisc"
L.ENABLED = "Enabled"
L.DISABLED = "Disabled"
L.STATE = "State is %s"
L.PAUSED_HINT = "Hold %s to pause it."
L.OPT_UNAVAILABLE = "The options panel is not available on this client."
L.HELP = "Usage: /am [on|off|config]"

L.OPT_ENABLE = "Enable AutoMisc"
L.OPT_ENABLE_TIP = "Master switch for every feature of AutoMisc."
L.OPT_MESSAGES = "Chat messages"
L.OPT_MESSAGES_TIP = "Prints a short summary in the chat each time AutoMisc does something."

L.OPT_PAUSE_SECTION = "Pause keys"
L.OPT_PAUSE_SHIFT = "Pause while Shift is held"
L.OPT_PAUSE_SHIFT_TIP = "AutoMisc does nothing while you hold Shift."
L.OPT_PAUSE_CTRL = "Pause while Ctrl is held"
L.OPT_PAUSE_CTRL_TIP = "AutoMisc does nothing while you hold Ctrl."
L.OPT_PAUSE_ALT = "Pause while Alt is held"
L.OPT_PAUSE_ALT_TIP = "AutoMisc does nothing while you hold Alt."

L.OPT_VENDOR_SECTION = "Vendors"
L.OPT_SELL_JUNK = "Sell grey items"
L.OPT_SELL_JUNK_TIP = "Sells every poor-quality (grey) item in your bags when you open a vendor."
L.OPT_REPAIR = "Repair automatically"
L.OPT_REPAIR_TIP = "Repairs all your gear when you open a vendor that can repair."
L.OPT_REPAIR_GUILD = "Use guild funds first"
L.OPT_REPAIR_GUILD_TIP = "Uses the guild bank when you are in a guild that allows it and the daily allowance covers the cost."
L.OPT_REPAIR_PERSONAL = "Pay yourself otherwise"
L.OPT_REPAIR_PERSONAL_TIP = "Uses your own gold when you have no guild, guild repairs are not possible any more, or the guild bank refuses."

L.OPT_SOCIAL_SECTION = "Social"
L.OPT_ACCEPT_SUMMON = "Accept summons"
L.OPT_ACCEPT_SUMMON_TIP = "Accepts warlock and meeting-stone summons (never while in combat)."
L.OPT_ACCEPT_RESURRECT = "Accept resurrections"
L.OPT_ACCEPT_RESURRECT_TIP = "Accepts resurrection offers from other players."
L.OPT_DECLINE_DUELS = "Decline duels"
L.OPT_DECLINE_DUELS_TIP = "Declines every duel request."
L.OPT_ACCEPT_INVITES = "Accept invites from friends and guild"
L.OPT_ACCEPT_INVITES_TIP = "Accepts group invites from friends, Battle.net friends and guild members. Ignored when you are already in a group."

L.MSG_SOLD = "Sold %d grey item(s) for %s."
L.MSG_SOLD_UNKNOWN = "Sold %d grey item(s)."
L.MSG_REPAIRED_GUILD = "Repaired for %s (guild funds)."
L.MSG_REPAIRED_PERSONAL = "Repaired for %s."
L.MSG_REPAIR_NO_GOLD = "Not enough gold to repair (%s needed)."
L.MSG_SUMMON = "Summon accepted."
L.MSG_RESURRECT = "Resurrection from %s accepted."
L.MSG_DUEL = "Duel from %s declined."
L.MSG_INVITE = "Group invite from %s accepted."
