-- Author: Fr0stwing
-- https://www.curseforge.com/members/fr0stwing/
-- https://github.com/fr0stwing
-- Note: This is a dev version of a beta. The code looks very wonky, I know. It's a draft.
--       I meant to re-do everything at some point, so I didn't do it as efficiently
--       as possible, because I didn't think I'd be releasing this draft version.
--       Right now, I'm focusing on making this version work properly in-game so that
--       it's properly usable in the meantime.          Stay tuned for v2.0.0!

local addonName, EquipmentSets = ...
local frame = CreateFrame("FRAME");

local MAX_SET_COUNT = 10
local MAX_SLOT_NUMBER = 20

if not table.removemulti then
    table.removemulti = function(self, pos, cnt)
        for i = 1, cnt do
            table.remove(self, pos, 1)
        end
    end
end

function pattern_split(str, wordPattern)
    local tbl = {}
    for v in string.gmatch(str, wordPattern) do
        table.insert(tbl, v)
    end

    return tbl
end

function EquipmentSets:HasSet(setId)
    return SavedSets[setId] ~= nil
end

function EquipmentSets:RemoveSet(setId)
    SavedSets[setId] = nil
end

function EquipmentSets:Log(msg)
    DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE .. '<es>: ' .. msg);
end

function EquipmentSets:LogError(msg)
    self:Log("|c" .. RED_FONT_COLOR:GenerateHexColor() .. msg)
end

function EquipmentSets:EquipItemFromSet(setId, slot, dstSlot)
    local name = self:GetPositionName(setId, slot)
    if name ~= nil then
        self:EquipItemByName(name, dstSlot)
    else
        self:UneqipSlot(slot)
    end
end

function EquipmentSets:GetPositionName(setId, slot)
    if not self:HasSet(setId) then
        return nil
    end

    return SavedSets[setId].items[slot]
end

function EquipmentSets:EquipItemByName(name, slot)
    if self:IsEmptyName(name) then
        return
    end

    if self:GetEquippedName(slot + 1) == name then
        return
    end

    local result = self:SearchItems(name)
    if #result > 0 then
        if slot == 0 then
            C_Item.EquipItemByName(name)
        else
            self:EquipItemFromBag(result[1][1], result[1][2], slot)
        end
    end

    -- C_Item.EquipItemByName(name, slot)
end

function EquipmentSets:EquipItemFromBag(bagId, bagSlot, slot)
    C_Container.PickupContainerItem(bagId, bagSlot)
    PickupInventoryItem(slot)
end

function EquipmentSets:IsEmptyName(name)
    return name == nil or name == "" or name == "EMPTY SLOT"
end

function EquipmentSets:IsEmptyPosition(setId, slot)
    local name = self:GetPositionName(setId, slot)

    return name == nil or name == "" or name == "EMPTY SLOT"
end

function EquipmentSets:PutItemInBag(bagId)
    if bagId == 0 then
        PutItemInBackpack()
    else
        PutItemInBag(C_Container.ContainerIDToInventoryID(bagId));
    end
end

function EquipmentSets:UneqipSlot(slot, bagId)
    if slot == 1 then
        return true
    end

    local name = self:GetEquippedName(slot)
    if name == nil then
        return false
    end

    -- self:Log("Unequipping " .. name)

    if bagId ~= nil then
        PickupInventoryItem(slot - 1)
        self:PutItemInBag(bagId);
        return true
    end

    for i = 0, NUM_BAG_SLOTS do
        if C_Container.GetContainerNumFreeSlots(i) > 0 then
            -- self:Log("Unequipping " .. slot .. ' to ' .. i)
            PickupInventoryItem(slot - 1)
            self:PutItemInBag(i);
            return true
        end
    end

    self:LogError("Failed to unequip items, no free space in bags.")

    return false
end

function EquipmentSets:UneqipSlots(slots)
    local freeSlots = {}
    for i = 0, NUM_BAG_SLOTS do
        freeSlots[i] = C_Container.GetContainerNumFreeSlots(i)
    end

    local spaceError = false
    for _, slot in pairs(slots) do
        if slot ~= 1 and self:GetEquippedName(slot) then
            local foundSpace = false
            for bagId, num in pairs(freeSlots) do
                if num > 0 then
                    if self:UneqipSlot(slot, bagId) then
                        freeSlots[bagId] = num - 1
                        foundSpace = true
                        break
                    end
                end
            end
            if not foundSpace then
                spaceError = true
            end
        end
    end

    if spaceError then
        self:LogError("Not enough free space in bags, not all items were unequipped.")
    end
end

function EquipmentSets:ResetSet(setId, name)
    SavedSets[setId] = {
        ["name"] = name,
        ["items"] = {}
    }
end

function EquipmentSets:SaveItem(setId, slot, name)
    if not self:HasSet(setId) then
        return
    end

    SavedSets[setId].items[slot] = name
end

function EquipmentSets:HasItem(setId, name)
    if not self:HasSet(setId) then
        return false
    end

    for i = 1, MAX_SLOT_NUMBER do
        if self:GetPositionName(setId, i) == name then
            return true
        end
    end

    return false
end

function EquipmentSets:GetName(setId)
    if self:HasSet(setId) then
        return SavedSets[setId].name
    end

    return nil
end

function EquipmentSets:DefaultName(setId)
    return "Loadout " .. setId
end

function EquipmentSets:SetName(setId, name)
    if not self:HasSet(setId) then
        return
    end

    SavedSets[setId].name = name
end

function EquipmentSets:IsSetEquipped(setId)
    if not self:HasSet(setId) then
        return false
    end

    for i = 1, MAX_SLOT_NUMBER do
        if self:GetPositionName(setId, i) ~= self:GetEquippedName(i) then
            return false
        end
    end

    return true
end

function EquipmentSets:GetEquippedName(slotId)
    local equipmentSlotId = GetInventorySlotInfo(self.SlotCodes[slotId])
    if equipmentSlotId == 0 then
        local itemId = GetInventoryItemID("player", equipmentSlotId)
        if itemId then
            return C_Item.GetItemInfo(itemId)
        end
    else
        local itemLink = GetInventoryItemLink("player", equipmentSlotId)
        if itemLink then
            return C_Item.GetItemInfo(itemLink)
        end
    end

    return nil
end

function EquipmentSets:SearchItems(name)
    local result = {}
    for i = 0, NUM_BANKGENERIC_SLOTS do
        local info = C_Container.GetContainerItemInfo(BANK_CONTAINER, i)
        if info and info.itemName then
            if info.itemName == name then
                table.insert(result, { BANK_CONTAINER, i })
            end
        end
    end

    for bagId = 0, NUM_BAG_SLOTS + GetNumBankSlots() do
        for i = 1, C_Container.GetContainerNumSlots(bagId) do
            local info = C_Container.GetContainerItemInfo(bagId, i)
            if info and info.itemName then
                if info.itemName == name then
                    table.insert(result, { bagId, i })
                end
            end
        end
    end

    return result
end

function EquipmentSets:IsValidBag(bagid)
    if bagid == 0 or bagid == -1 then
        return true
    else
        local _, bagFamily = C_Container.GetContainerNumFreeSlots(bagid)
        if bagFamily == 0 then
            return true
        end
    end

    return false
end

function EquipmentSets:SearchFreeSpace()
    for i = 0, NUM_BAG_SLOTS do
        if self:IsValidBag(i) then
            for j = 1, C_Container.GetContainerNumFreeSlots(i) do
                if not C_Container.GetContainerItemLink(i, j) and not self.LockList[i][j] then
                    self.LockList[i][j] = 1
                    return i, j
                end
            end
        end
    end

    return nil
end

function EquipmentSets:SearchFreeBankSpace()
    local bankBags = { -1 }
    for i = NUM_BAG_SLOTS + 1, GetNumBankSlots do
        table.insert(bankBags, i)
    end

    for _, i in pairs(bankBags) do
        if self:IsValidBag(i) then
            for j = 1, C_Container.GetContainerNumFreeSlots(i) do
                if not C_Container.GetContainerItemLink(i, j) and not self.LockList[i][j] then
                    self.LockList[i][j] = 1
                    return i, j
                end
            end
        end
    end

    return nil
end

function EquipmentSets:IsArrowsOrBullets(itemId)
    local _, _, _, _, _, classID, subClassID = C_Item.GetItemInfoInstant(itemId)

    return classID == 6 and (subClassID == 2 or subClassID == 3)
end

-- SavedVariables
savedAmmoSlotItem = nil

EquipmentSets.SlotNames = { "Ammo", "Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist",
    "Legs", "Feet", "Wrist", "Hands", "Finger 1", "Finger 2", "Trinket 1",
    "Trinket 2", "Back", "Main Hand", "Off Hand", "Ranged or Relic", "Tabard" }

EquipmentSets.SlotCodes = { "AmmoSlot", "HeadSlot", "NeckSlot", "ShoulderSlot", "ShirtSlot", "ChestSlot", "WaistSlot",
    "LegsSlot",
    "FeetSlot", "WristSlot", "HandsSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "BackSlot",
    "MainHandSlot", "SecondaryHandSlot", "RangedSlot", "TabardSlot" }

-- Dump function
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function EquipmentSets:UnequipWeaponsRingsAndTrinkets()
    self:UneqipSlots({ 11, 12, 13, 14, 16, 17 })
end

function EquipmentSets:SaveCurrentSet(currentSetNumber)
    local currentName = self:GetName(currentSetNumber)
    if (currentName == nil or currentName == "") then
        currentName = self:DefaultName(currentSetNumber)
    end

    self:ResetSet(currentSetNumber, currentName)
    self:SaveItem(currentSetNumber, 1, savedAmmoSlotItem)
    for x = 2, MAX_SLOT_NUMBER do
        local name = self:GetEquippedName(x)
        if x == 1 then
            name = savedAmmoSlotItem
        end
        self:SaveItem(currentSetNumber, x, name)
    end
end

function EquipmentSets:LoadSet(setId)
    if not self:HasSet(setId) then
        EquipmentSets:Log("You must save a set to this slot first.")
        return
    end

    local toUnequip = {}
    local usedSlots = {}
    for x = 1, MAX_SLOT_NUMBER do
        local name = self:GetPositionName(setId, x)
        if name == nil then
            table.insert(toUnequip, x)
        else
            -- self:Log("Equipped at " .. x .. ': ' .. tostring(self:GetEquippedName(x)))
            if self:GetEquippedName(x) ~= name then
                local result = self:SearchItems(name)
                if #result == 0 then
                    self:LogError("Item [" .. name .. '] not found.')
                end

                -- self:Log("Equipping " .. name .. ' to ' .. x)

                for _, data in pairs(result) do
                    local bagId, bagSlot = data[1], data[2]

                    if (not usedSlots[bagId] or usedSlots[bagId] and not usedSlots[bagId][bagSlot]) then
                        -- self:Log("Equipping " .. name .. ' from ' .. bagId .. ' ' .. bagSlot .. ' to ' .. (x - 1))
                        if x - 1 == 0 then
                            C_Item.EquipItemByName(name)
                        else
                            self:EquipItemFromBag(bagId, bagSlot, x - 1)
                        end
                        if not usedSlots[bagId] then
                            usedSlots[bagId] = {}
                        end
                        usedSlots[bagId][bagSlot] = true
                        break
                    end
                end
            end
        end
    end

    if #toUnequip > 0 then
        self:UneqipSlots(toUnequip)
    end
end

for i = 1, MAX_SET_COUNT do
    _G["SLASH_LOADSET" .. i .. '1'] = "/loadset" .. 1
    SlashCmdList["LOADSET" .. i] = function(msg)
        EquipmentSets:LoadSet(i)
    end
end

local commands = {
    ["load"] = {
        ["handler"] = function(args)
            local setId = tonumber(args[1])
            if setId == nil then
                EquipmentSets:LogError("Set id must be a number")
                return
            end
            if not EquipmentSets:HasSet(setId) then
                EquipmentSets:LogError("Set id " .. setId .. " is not stored")
                return
            end
            EquipmentSets:Log("Loading set #" .. setId .. " \"" .. EquipmentSets:GetName(setId) .. "\"")
            EquipmentSets:LoadSet(setId)
        end,
    },
    ["save"] = {
        ["handler"] = function(args)
            local setId = tonumber(args[1])
            if setId == nil then
                EquipmentSets:LogError("Set id must be a number")
                return
            end
            if setId < 1 or setId > MAX_SET_COUNT then
                EquipmentSets:LogError("Bad set number")
                return
            end

            local name = args[2] or ""
            EquipmentSets:Log("Saving current equpment to set #" ..
                setId ..
                " \"" ..
                (#name > 0 and name or EquipmentSets:GetName(setId) or EquipmentSets:DefaultName(setId)) .. "\"")
            EquipmentSets:SaveCurrentSet(setId)
            if #name > 0 then
                EquipmentSets:SetName(setId, name)
            end
        end
    },
    ["unequip"] = {
        ["handler"] = function(args)
            EquipmentSets:Log("Unequipping all items")
            EquipmentSets:UnequipEverything()
        end
    },
    ["rename"] = {
        ["handler"] = function(args)
            local setId = tonumber(args[1])
            if setId == nil then
                EquipmentSets:LogError("Set id must be a number")
                return
            end
            if not EquipmentSets:HasSet(setId) then
                EquipmentSets:LogError("Set id " .. setId .. " is not stored")
                return
            end
            local name = args[2] or ""
            if #name == 0 then
                EquipmentSets:LogError("Name not provided")
                return
            end

            EquipmentSets:Log("Renaming equpment set #" .. setId .. " to \"" .. name .. "\"")
            EquipmentSets:SetName(setId, name)
        end
    },
    ["remove"] = {
        ["handler"] = function(args)
            local setId = tonumber(args[1])
            if setId == nil then
                EquipmentSets:LogError("Set id must be a number")
                return
            end
            if not EquipmentSets:HasSet(setId) then
                EquipmentSets:LogError("Set id " .. setId .. " is not stored")
                return
            end

            EquipmentSets:Log("Removing equipment set #" .. setId .. " \"" .. EquipmentSets:GetName(setId) .. "\"")
            EquipmentSets:RemoveSet(setId)
        end
    },
    ["list"] = {
        ["handler"] = function(args)
            local cnt = 0
            for i = 1, MAX_SET_COUNT do
                if EquipmentSets:HasSet(i) then
                    cnt = cnt + 1
                    local totalItems = 0
                    local hasItems = 0
                    local equippedItems = 0

                    for j = 1, MAX_SLOT_NUMBER do
                        local positionName = EquipmentSets:GetPositionName(i, j)
                        if positionName then
                            totalItems = totalItems + 1
                            if EquipmentSets:GetEquippedName(j) == positionName then
                                hasItems = hasItems + 1
                                equippedItems = equippedItems + 1
                            elseif #EquipmentSets:SearchItems(positionName) > 0 then
                                hasItems = hasItems + 1
                            end
                        end
                    end

                    EquipmentSets:Log("#" ..
                        i ..
                        ' "' ..
                        EquipmentSets:GetName(i) ..
                        '" (' .. equippedItems .. '/' .. hasItems .. '/' .. totalItems .. ')')
                end
            end

            EquipmentSets:Log("Total sets stored: " .. cnt .. ", legend: equipped/available/total")
        end
    },
    ["setposition"] = {
        ["handler"] = function(args)
            local setId = tonumber(args[1])
            if setId == nil then
                EquipmentSets:LogError("Set id must be a number")
                return
            end
            if not EquipmentSets:HasSet(setId) then
                EquipmentSets:LogError("Set id " .. setId .. " is not stored")
                return
            end

            local positionId = tonumber(args[2])
            if positionId == nil then
                EquipmentSets:LogError("Position id not provided")
                return
            end

            if positionId < 1 or positionId > MAX_SLOT_NUMBER then
                EquipmentSets:LogError("Bad position id provided")
                return
            end

            table.removemulti(args, 1, 2)
            local positionName = table.concat(args, " ") or ""
            if #positionName > 0 then
                EquipmentSets:Log('Saving position ' ..
                    positionId ..
                    ' "' .. positionName .. '" to set #' .. setId .. ' "' .. EquipmentSets:GetName(setId) .. '"')
                EquipmentSets:SaveItem(setId, positionId, positionName)
            else
                EquipmentSets:Log('Removing position ' ..
                    positionId .. ' from set #' .. setId .. ' "' .. EquipmentSets:GetName(setId) .. '"')
                EquipmentSets:SaveItem(setId, positionId, nil)
            end
        end
    },
    ["reset"] = {
        ["handler"] = function(args)
            SavedSets = {}
            savedAmmoSlotItem = nil
        end
    },
    ["test"] = {
        ["handler"] = function(args)
            EquipmentSets:Log("Main handler, args: " .. dump(args))
        end,
        ["commandTable"] = {
            ["a"] = {
                ["handler"] = function(args)
                    EquipmentSets:Log("Command a, args: " .. dump(args))
                end
            },
            ["b"] = {
                ["handler"] = function(args)
                    EquipmentSets:Log("Command b, args: " .. dump(args))
                end
            },
            ["c"] = {
                ["handler"] = function(args)
                    EquipmentSets:Log("Command c, args: " .. dump(args))
                end
            },
        }
    }
}

function CollectUsages(dataTable)
    local usages = {}
    if not dataTable then
        return {}
    end

    for subCommand, subData in pairs(dataTable) do
        if not subData.commandTable then
            table.insert(usages, subCommand)
        else
            if subData.handler then
                table.insert(usages, subCommand)
            end

            for _, subUsage in pairs(CollectUsages(subData.commandTable)) do
                table.insert(usages, subCommand .. ' ' .. subUsage)
            end
        end
    end

    return usages
end

function ExecuteCommand(commandName, commandTable, args)
    for command, data in pairs(commandTable) do
        if command == commandName then
            if data.commandTable and args[1] then
                commandName = args[1]
                table.remove(args, 1)
                if ExecuteCommand(commandName, data.commandTable, args) then
                    return true
                end
            end
            
            if data.handler then
                data.handler(args)
                return true
            end

            return false
        end
    end

    return false
end

SLASH_EQ1 = "/equipmentsets"
SLASH_EQ2 = "/es"
SlashCmdList["EQ"] = function(msg)
    local args = pattern_split(msg, "[^ ]+")

    if args[1] ~= nil then
        local command = args[1]
        table.remove(args, 1)
        if not ExecuteCommand(command, commands, args) then
            EquipmentSets:LogError('Unknown command "' .. command .. '"')
        end
        return
    end

    EquipmentSets:Log("Available commands:")
    local usages = CollectUsages(commands)
    for _, usage in pairs(usages) do
        EquipmentSets:Log("/es " .. usage)
    end
end

function EquipmentSets:UnequipEverything()
    local slots = {}
    for x = 1, MAX_SLOT_NUMBER do
        table.insert(slots, x)
    end
    self:UneqipSlots(slots)
end

SLASH_UNEQUIPALL1 = "/unequipall"
SlashCmdList["UNEQUIPALL"] = function(msg)
    EquipmentSets:UnequipEverything()
end

function EquipmentSets:InitLockList()
    EquipmentSets.LockList = {}
    for i = -1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        EquipmentSets.LockList[i] = {}
        for j = 0, 64 do
            EquipmentSets.LockList[i][j] = false
        end
    end
end

function EquipmentSets:Initialize1()
    EquipmentSets['NameInputs'] = {}

    EquipmentSets:InitLockList()

    -- Dropdown menu
    local setListDropdown = CreateFrame("FRAME", nil, PaperDollFrame, "UIDropDownMenuTemplate")
    setListDropdown:SetPoint("BOTTOMLEFT", 18, 80, 0, 0)
    UIDropDownMenu_SetWidth(setListDropdown, 48)
    --UIDropDownMenu_SetText(dropDown, "" .. favoriteNumber)
    UIDropDownMenu_SetText(setListDropdown, "Sets")
    UIDropDownMenu_Initialize(setListDropdown, function(self, level, menuList)
        for xx = 1, MAX_SET_COUNT do
            local info = UIDropDownMenu_CreateInfo()
            info.func = function(self, arg)
                if EquipmentSets:HasSet(arg) then
                    EquipmentSets:Log("Loading set #" .. arg .. " [" .. EquipmentSets:GetName(arg) .. "]")
                end
                EquipmentSets:LoadSet(arg)
                CloseDropDownMenus()
            end
            -- info.menuList, info.hasArrow = EquipmentSets:GetName(xx), false -- change to true to create nests
            info.text, info.arg1, info.checked = EquipmentSets:GetName(xx) or "Empty set " .. xx, xx,
                EquipmentSets:IsSetEquipped(xx)
            info.tooltipOnButton = true
            info.disabled = not EquipmentSets:HasSet(xx)
            local tooltipTexts = {}
            local totalCnt = 0
            local equippedCnt = 0
            local hasMissing = false
            for i = 1, MAX_SLOT_NUMBER do
                local item = EquipmentSets:GetPositionName(xx, i)
                if item then
                    totalCnt = totalCnt + 1
                    local text = EquipmentSets.SlotNames[i] .. ':\n'
                    if EquipmentSets:GetEquippedName(i) == item then
                        equippedCnt = equippedCnt + 1
                        text = text .. GREEN_FONT_COLOR:WrapTextInColorCode(item)
                    elseif #EquipmentSets:SearchItems(item) > 0 then
                        text = text .. YELLOW_FONT_COLOR:WrapTextInColorCode(item)
                    else
                        hasMissing = true
                        text = text .. RED_FONT_COLOR:WrapTextInColorCode(item)
                    end
                    table.insert(tooltipTexts, text)
                end
            end

            local cntText = "(" .. equippedCnt .. '/' .. totalCnt .. ')'
            if equippedCnt == totalCnt then
                cntText = GREEN_FONT_COLOR:WrapTextInColorCode(cntText)
            elseif hasMissing then
                cntText = RED_FONT_COLOR:WrapTextInColorCode(cntText)
            else
                cntText = YELLOW_FONT_COLOR:WrapTextInColorCode(cntText)
            end

            if EquipmentSets:HasSet(xx) then
                info.tooltipTitle = EquipmentSets:GetName(xx) .. ' ' .. cntText
            end

            info.tooltipText = table.concat(tooltipTexts, '\n\n')
            UIDropDownMenu_AddButton(info)
        end
        local info = UIDropDownMenu_CreateInfo()
        info.func = function()
            EquipmentSets:Log("Unequipping everything")
            EquipmentSets:UnequipEverything()
            CloseDropDownMenus()
        end
        info.text = "# Unequip everything"
        info.tooltipOnButton = true
        info.tooltipTitle = "Unequip Everything"
        info.tooltipText =
        "\nSelect this to unequip everything. You can also type out the \"/unequipall\" command. You can also tie this command to a macro."
        UIDropDownMenu_AddButton(info)
    end)

    local fSettings = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset") --Create a frame
    fSettings:SetFrameStrata("TOOLTIP")                                                  --Set its strata
    fSettings:SetHeight(500)                                                             --Give it height
    fSettings:SetWidth(220)                                                              --and width -- old 200
    fSettings:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    fSettings:Hide()
    --fSettings:SetScript("OnHide", function(self, arg1)
    --isThePriorityFrameHidden = 1
    --end)
    fSettings.title = fSettings:CreateFontString(nil, "OVERLAY");
    fSettings.title:SetFontObject("GameFontHighlight");
    fSettings.title:SetPoint("CENTER", fSettings.TitleBg, "CENTER", 5, 0);
    fSettings.title:SetText("EquipmentSets - Names");

    -- Settings button
    local widget = CreateFrame("Button", nil, setListDropdown, "UIPanelButtonTemplate");
    widget:SetWidth(19);
    widget:SetHeight(19);
    widget:SetPoint("LEFT", 0, 2, 0, 0);
    widget:SetNormalTexture("Interface\\Icons\\trade_engineering")
    widget:SetScript("OnMouseDown", function(self, arg1)
        widget:SetSize(18.5, 18.5)
    end)
    widget:SetScript("OnMouseUp", function(self, arg1)
        widget:SetSize(19, 19)
    end)
    widget:SetScript("OnClick", function(self, button, down)
        local j = 1
        local text = "\n\n\n"
        for i = 1, MAX_SET_COUNT do
            if EquipmentSets:HasSet(i) then
                text = text .. "Set " .. i .. "\n\n\n\n";
                local input = EquipmentSets.NameInputs[i] or CreateFrame("EditBox", nil, fSettings, "InputBoxTemplate")
                input:SetSize(180, 24)
                input:SetPoint("TOP", 0, -47 - (j - 1) * 44, 0, 0)
                input:SetAutoFocus(false)
                input:SetText(EquipmentSets:GetName(i))

                EquipmentSets.NameInputs[i] = input
                j = j + 1
            elseif EquipmentSets.NameInputs[i] then
                EquipmentSets.NameInputs[i]:Hide()
            end
        end

        fSettings.introText:SetText(text)

        fSettings:Show()
    end)

    fSettings.introText = fSettings:CreateFontString(nil, "ARTWORK")
    fSettings.introText:SetFont("Fonts\\FRIZQT__.TTF", 11)
    fSettings.introText:SetTextColor(1, 1, 1)
    fSettings.introText:SetAllPoints(true)
    fSettings.introText:SetJustifyH("CENTER")
    fSettings.introText:SetJustifyV("TOP")

    C_Timer.After(1, function()
        local widgetConfirm = CreateFrame("Button", nil, fSettings, "UIPanelButtonTemplate");
        widgetConfirm:SetWidth(150);
        widgetConfirm:SetHeight(19);
        widgetConfirm:SetPoint("BOTTOM", 0, 9, 0, 0);
        widgetConfirm:SetText("Confirm");

        --widgetConfirm:SetNormalTexture("Interface\\Icons\\trade_engineering")
        widgetConfirm:SetScript("OnMouseDown", function(self, arg1)
            --widgetConfirm:SetSize(18.5, 18.5)
        end)
        widgetConfirm:SetScript("OnMouseUp", function(self, arg1)
            --widgetConfirm:SetSize(19, 19)
        end)
        widgetConfirm:SetScript("OnClick", function(self, button, down)
            for i = 1, MAX_SET_COUNT do
                local text = EquipmentSets.NameInputs[i] and EquipmentSets.NameInputs[i]:GetText()
                if text == '' then
                    EquipmentSets:RemoveSet(i)
                elseif EquipmentSets:HasSet(i) then
                    EquipmentSets:SetName(i, text)
                end
            end
            fSettings:Hide()
        end)
    end)

    local dropDown2 = CreateFrame("FRAME", nil, PaperDollFrame, "UIDropDownMenuTemplate")
    dropDown2:SetPoint("BOTTOMLEFT", 76, 80, 80, 80)
    UIDropDownMenu_SetWidth(dropDown2, 8)
    --UIDropDownMenu_SetText(dropDown2, "Load")
    UIDropDownMenu_Initialize(dropDown2, function(self, level, menuList)
        for xx = 1, MAX_SET_COUNT do
            local info = UIDropDownMenu_CreateInfo()
            info.func = function(self, arg)
                if not EquipmentSets:HasSet(xx) then
                    EquipmentSets:SaveCurrentSet(xx)
                    return
                end

                local text = "[" ..
                    EquipmentSets:GetName(arg) ..
                    "] WILL BE OVERWRITTEN. \n\n\nContinue?"

                if savedAmmoSlotItem then
                    text = text .. "\n\n\nFor classes with ammo, the following will save:\n" ..
                        "[" .. savedAmmoSlotItem .. "]"
                end

                StaticPopupDialogs["DOYOUWANTTO_SAVE"] = {
                    text = text,
                    button1 = "Yes",
                    button2 = "No",
                    OnAccept = function()
                        EquipmentSets:SaveCurrentSet(arg)
                    end,
                    timeout = 0,
                    whileDead = true,
                    hideOnEscape = true,
                    preferredIndex = 3,
                }

                StaticPopup_Show("DOYOUWANTTO_SAVE")
                CloseDropDownMenus()
            end

            -- info.menuList, info.hasArrow = saveSlotTitles[xx], false -- change to true to create nests, unstable
            info.text, info.arg1, info.checked =
                EquipmentSets:HasSet(xx) and "Save loadout to [" .. EquipmentSets:GetName(xx) .. "]" or
                "Create loadout " .. xx, xx,
                false
            info.notCheckable = true
            info.tooltipOnButton = true
            info.tooltipTitle = not EquipmentSets:HasSet(xx) and "This will create a new loadout" or
                "This will overwrite [" .. EquipmentSets:GetName(xx) .. "]."
            info.tooltipText =
            "\nNOTE: If you have an ammo slot, you will have an additional button under your ammo slot. Click on it to select the ammo you want to save before saving your set."
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- AmmoSlotStuff
    local dropDown3 = CreateFrame("FRAME", nil, CharacterAmmoSlot, "UIDropDownMenuTemplate")
    dropDown3:SetPoint("BOTTOM", 0, -28)
    UIDropDownMenu_SetWidth(dropDown3, 8)
    UIDropDownMenu_Initialize(dropDown3, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(self, arg)
            savedAmmoSlotItem = arg
            CloseDropDownMenus()
        end
        info.text, info.arg1, info.checked =
            "Current selection: [" .. (savedAmmoSlotItem or 'Empty Ammo') .. "] (click here to reset)",
            nil, nil == savedAmmoSlotItem
        info.tooltipOnButton = true
        info.tooltipTitle = "Currently selected: [" .. (savedAmmoSlotItem or 'Empty Ammo') .. "]"
        info.tooltipText =
        "\nThis is the ammo you currently are saving along with your equipment sets.\n\nIf you want to save another type of ammo, please select one below.\n\nIMPORTANT: The ammo you will select will be remembered permanently (and used to save a set) until you change it again."
        UIDropDownMenu_AddButton(info)
        local ammoList = {}
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemID = C_Container.GetContainerItemID(bag, slot)
                if itemID then
                    if EquipmentSets:IsArrowsOrBullets(itemID) then
                        local sName = C_Item.GetItemInfo(itemID)
                        ammoList[sName] = true
                    end
                end
            end
        end

        for sName in pairs(ammoList) do
            local info = UIDropDownMenu_CreateInfo()
            info.func = function(self, arg)
                savedAmmoSlotItem = arg
                CloseDropDownMenus()
            end

            info.text, info.arg1, info.checked = sName, sName, sName == savedAmmoSlotItem
            info.tooltipOnButton = true
            info.tooltipTitle = sName
            info.tooltipText = "\nSelect [" ..
                sName ..
                "] to be saved.\n\nIMPORTANT: The ammo you will select will be remembered permanently (and used to save a set) until you change it again."
            UIDropDownMenu_AddButton(info)
        end
    end)

    for _, frame in pairs { UIParent:GetChildren() } do
        if not frame:IsForbidden() and frame:GetObjectType() == 'GameTooltip' then
            frame:HookScript('OnTooltipCleared', EquipmentSets.OnClear)
            frame:HookScript('OnTooltipSetItem', EquipmentSets.OnItem)
        end
    end
end

function EquipmentSets.OnClear(tip)
    tip._hasSets = false
end

function EquipmentSets.OnItem(tip)
    local name, link = (tip.GetItem or TooltipUtil.GetDisplayedItem)(tip)
    if name ~= '' then
        if not tip._hasSets then
            local sets = {}
            for i = 1, MAX_SET_COUNT do
                if EquipmentSets:HasItem(i, name) then
                    table.insert(sets, EquipmentSets:GetName(i))
                end
            end

            if #sets > 0 then
                tip:AddDoubleLine('|cFFFFFFFFSets:|r', table.concat(sets, ', '))
                tip:Show()
            end

            tip._hasSets = true
        end
    end
end

function EquipmentSets:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        if not SavedSets then
            SavedSets = {}
        end

        EquipmentSets:Initialize1()
    end
end

frame:SetScript("OnEvent", EquipmentSets.OnEvent);
frame:RegisterEvent("ADDON_LOADED");
