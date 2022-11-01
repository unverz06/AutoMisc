--[[
    Variable
]]

local _, L = ...;

local player = UnitName("player")

--[[
    Messages
]]

local function selfMessage(v)
    DEFAULT_CHAT_FRAME:AddMessage(v, 0.19, 0.55, 1.0);
  end
  
  local function debugMessage(v)
    DEFAULT_CHAT_FRAME:AddMessage(v, 1.0, 1.0, 0.0);
  end

--[[
    AutoQuests
]]

local function RegisterAutoMiscellaneous()

    local function RepairItemsAndSellGrey(self, event)
        if (event == "MERCHANT_SHOW") then

            local bag, slot
            local total = 0
            for bag = 0, 5 do
                for slot = 0, GetContainerNumSlots(bag) do
                    local link = GetContainerItemLink(bag, slot)
                    if link and (select(3, GetItemInfo(link)) == 0) then
                        total = total + select(11, GetItemInfo(link))
                        UseContainerItem(bag, slot)
                    end
                end
            end

            if total > 0 then
                selfMessage(L.SELL_GREY .. GetCoinTextureString(total, " "));
            end

            if CanMerchantRepair() then
                local repairAllCost, canRepair = GetRepairAllCost()
                if canRepair then
                    if repairAllCost > GetMoney() then
                        selfMessage(L.REPAIR_MONEY)
                    else
                        RepairAllItems()
                        selfMessage(L.REPAIR_OK .. GetCoinTextureString(repairAllCost, " "));
                    end
                end
            end

        end
    end
    

    local f = CreateFrame("Frame")
    f:RegisterEvent("MERCHANT_SHOW")
    f:RegisterEvent("VARIABLES_LOADED")
    f:SetScript("OnEvent", RepairItemsAndSellGrey)
end

--[[
    Options panel
]]

local configurationPanelCreated = false

function CreateConfigurationPanel()
    if configurationPanelCreated then
        return nil
    end
    configurationPanelCreated = true

    local pre = _ .. "Config_"

    local ConfigurationPanel = CreateFrame("Frame", pre .. "MainFrame");
	ConfigurationPanel.name = _
    InterfaceOptions_AddCategory(ConfigurationPanel)

    -- Title
    local IntroMessageHeader = ConfigurationPanel:CreateFontString(nil, "ARTWORK","GameFontNormalLarge")
	IntroMessageHeader:SetPoint("TOPLEFT", 10, -10)
    IntroMessageHeader:SetText(_ .. " " .. GetAddOnMetadata(_, "Version"))

    -- Message thanks
    local MessageContent1 = ConfigurationPanel:CreateFontString(nil, "ARTWORK","GameFontNormal")
  MessageContent1:SetPoint("TOPLEFT", 10, -50)
    MessageContent1:SetText(L.OPTIONS.THANKS)
  
    -- Message ticket
    local MessageContent1 = ConfigurationPanel:CreateFontString(nil, "ARTWORK","GameFontNormal")
    MessageContent1:SetPoint("TOPLEFT", 10, -65)
      MessageContent1:SetText(L.OPTIONS.TICKET)

    -- Message support
    local MessageContent1 = ConfigurationPanel:CreateFontString(nil, "ARTWORK","GameFontNormal")
    MessageContent1:SetPoint("TOPLEFT", 10, -95)
      MessageContent1:SetText(L.OPTIONS.SUPPORT)

end

--[[
    Load 
]]

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event)
    if event == "ADDON_LOADED" then
        CreateConfigurationPanel()
    elseif event == "PLAYER_LOGIN" then
        RegisterAutoMiscellaneous()
        selfMessage(L.WELCOME.HI .. player .. L.WELCOME.LOADED);
    end
end)
