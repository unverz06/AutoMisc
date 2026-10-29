local _, ns = ...
local L = ns.L

local merchantOpen = false
local POOR = (Enum and Enum.ItemQuality and Enum.ItemQuality.Poor) or 0

local function GetSellPrice(link)
    local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    return link and getInfo and select(11, getInfo(link))
end

local function LastBagIndex()
    return NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4
end

--[[
    Sells every grey item. Returns the number of items sold (stacks count as one)
    and the estimated gain in copper.
]]
local function SellJunk()
    local sold, gain = 0, 0
    local unknownPrice = false

    for bag = 0, LastBagIndex() do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.quality == POOR and not info.hasNoValue and not info.isLocked then
                local price = GetSellPrice(info.hyperlink)
                if price then
                    gain = gain + price * (info.stackCount or 1)
                else
                    unknownPrice = true
                end
                C_Container.UseContainerItem(bag, slot)
                sold = sold + 1
            end
        end
    end

    if sold > 0 then
        if unknownPrice then
            ns.Notify(L.MSG_SOLD_UNKNOWN:format(sold))
        else
            ns.Notify(L.MSG_SOLD:format(sold, ns.FormatMoney(gain)))
        end
    end
    return sold
end

--[[
    Repair. Order: guild funds (if allowed and affordable), then personal gold.
    After a guild repair the cost is checked again: if the guild bank refused,
    the personal fallback takes over.
]]
local function RepairCost()
    if not (CanMerchantRepair and CanMerchantRepair()) then return 0 end
    local cost, canRepair = GetRepairAllCost()
    if not canRepair or not cost or cost <= 0 then return 0 end
    return cost
end

local function GuildCanPay(cost)
    if not (IsInGuild() and CanGuildBankRepair and CanGuildBankRepair()) then
        return false
    end
    local allowance = GetGuildBankWithdrawMoney()
    return not allowance or allowance < 0 or allowance >= cost
end

local function RepairPersonal(cost, canRetry)
    if GetMoney() >= cost then
        RepairAllItems()
        ns.Notify(L.MSG_REPAIRED_PERSONAL:format(ns.FormatMoney(cost)))
    elseif canRetry then
        -- gold from the junk sale may not have reached the client yet
        C_Timer.After(0.5, function()
            local remaining = merchantOpen and ns.db.autoRepair and ns.db.repairPersonal and RepairCost()
            if remaining and remaining > 0 then RepairPersonal(remaining, false) end
        end)
    else
        ns.Notify(L.MSG_REPAIR_NO_GOLD:format(ns.FormatMoney(cost)))
    end
end

local function RepairGuild(cost)
    RepairAllItems(true)
    -- the server answers asynchronously: look again before announcing anything
    C_Timer.After(0.5, function()
        local remaining = merchantOpen and RepairCost() or 0
        if remaining == 0 then
            ns.Notify(L.MSG_REPAIRED_GUILD:format(ns.FormatMoney(cost)))
        elseif ns.db.autoRepair and ns.db.repairPersonal then
            RepairPersonal(remaining, false)
        end
    end)
end

local function Repair(soldSomething)
    local cost = RepairCost()
    if cost == 0 then return end
    local db = ns.db

    if db.repairGuild and GuildCanPay(cost) then
        RepairGuild(cost)
    elseif db.repairPersonal then
        RepairPersonal(cost, soldSomething)
    end
end

ns.On("MERCHANT_SHOW", function()
    merchantOpen = true
    local sold = 0
    if ns.db.sellJunk then
        sold = SellJunk()
    end
    if ns.db.autoRepair then
        Repair(sold > 0)
    end
end)

ns.On("MERCHANT_CLOSED", function()
    merchantOpen = false
end, true)
