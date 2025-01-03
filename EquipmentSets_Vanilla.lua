-- Author: Fr0stwing
-- https://www.curseforge.com/members/fr0stwing/
-- https://github.com/fr0stwing
-- Note: This is a dev version of a beta. The code looks very wonky, I know. It's a draft.
--       I meant to re-do everything at some point, so I didn't do it as efficiently
--       as possible, because I didn't think I'd be releasing this draft version.
--       Right now, I'm focusing on making this version work properly in-game so that
--       it's properly usable in the meantime.          Stay tuned for v2.0.0!

local addonName, EquipmentSets = ...
local es = EquipmentSets
local frame = CreateFrame("FRAME");

local MAX_SLOT_NUMBER = 20

local Colors = {
    GREEN = GREEN_FONT_COLOR,
    RED = RED_FONT_COLOR,
    YELLOW = YELLOW_FONT_COLOR,
    LIGHT_YELLOW = LIGHTYELLOW_FONT_COLOR,
    GRAY = GRAY_FONT_COLOR,
    ORANGE = ORANGE_FONT_COLOR,
}

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

function es:Each(func)
    for i, set in pairs(SavedSets) do
        if set ~= nil then
            func(i, set)
        end
    end
end

function es:HasSet(setId)
    return SavedSets[setId] ~= nil
end

function es:RemoveSet(setId)
    table.remove(SavedSets, setId)
end

function es:GetSetByName(name)
    for i, set in pairs(SavedSets) do
        if set.name == name then
            return i
        end
    end

    return nil
end

function es:Log(msg)
    DEFAULT_CHAT_FRAME:AddMessage(self:Colorize(Colors.LIGHT_YELLOW, '<es>: ' .. msg))
end

function es:Colorize(color, msg)
    if color == nil then
        return msg
    end

    return '|c' .. color:GenerateHexColor() .. msg .. '|r'
end

function es:LogError(msg)
    self:Log(self:Colorize(Colors.RED, msg))
end

function es:GetPositionName(setId, slot)
    if not self:HasSet(setId) then
        return nil
    end

    return SavedSets[setId].items[slot]
end

function es:IsDoubleSlot(slot)
    -- 14 15 trinket
    -- 12 13 finger
    -- 17 18 main hand off hand

    for _, value in pairs({ 12, 13, 14, 15, 17, 18 }) do
        if value == slot then
            return true
        end
    end

    return false
end

function es:GetOtherSlot(slot)
    local p = {
        [12] = 13,
        [13] = 12,
        [14] = 15,
        [15] = 14,
        [17] = 18,
        [18] = 17,
    }

    return p[slot]
end

function es:EquipItemByName(name, slot)
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

function es:EquipItemFromBag(bagId, bagSlot, slot)
    C_Container.PickupContainerItem(bagId, bagSlot)
    PickupInventoryItem(slot)
end

function es:IsEmptyName(name)
    return name == nil or name == "" or name == "EMPTY SLOT"
end

function es:IsEmptyPosition(setId, slot)
    local name = self:GetPositionName(setId, slot)

    return name == nil or name == "" or name == "EMPTY SLOT"
end

function es:PutItemInBag(bagId)
    if bagId == 0 then
        PutItemInBackpack()
    else
        PutItemInBag(C_Container.ContainerIDToInventoryID(bagId));
    end
end

function es:UneqipSlot(slot, bagId)
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

    local freeSlots = self:GetFreeSlots()
    for i in pairs(freeSlots) do
        PickupInventoryItem(slot - 1)
        self:PutItemInBag(i);
        -- self:Log("Unequipping " .. slot .. ' to ' .. i)
        return true
    end

    self:LogError("Failed to unequip items, no free space in bags.")

    return false
end

function es:GetFreeSlots()
    local freeSlots = {}
    local numFreeSlots = 0
    for i = 0, NUM_BAG_SLOTS do
        local freeNum = C_Container.GetContainerNumFreeSlots(i)
        if freeNum > 0 then
            freeSlots[i] = freeNum
            numFreeSlots = numFreeSlots + 1
        end
    end

    return freeSlots, numFreeSlots
end

function es:UneqipSlots(slots)
    local freeSlots = es:GetFreeSlots()

    local spaceError = false
    for _, slot in pairs(slots) do
        -- for ammo slot space is not needed
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
        return false
    end

    return true
end

function es:ResetSet(setId, name)
    SavedSets[setId] = {
        ["name"] = name,
        ["items"] = {}
    }
end

function es:SaveItem(setId, slot, name)
    if not self:HasSet(setId) then
        return
    end

    SavedSets[setId].items[slot] = name
end

function es:HasItem(setId, name)
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

function es:GetName(setId, color)
    if self:HasSet(setId) then
        return self:Colorize(color, SavedSets[setId].name)
    end

    return nil
end

function es:DefaultName(setId)
    return "Loadout " .. setId
end

function es:SetName(setId, name)
    if not self:HasSet(setId) then
        return
    end

    SavedSets[setId].name = name
end

function es:IsSetEquipped(setId)
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

function es:GetEquippedName(slotId)
    local equipmentSlotId = GetInventorySlotInfo(self.SlotInfo[slotId].code)

    -- special ammo handling
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

function es:SearchItems(name)
    local result = {}

    -- first return bags, then bank
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

    for i = 0, NUM_BANKGENERIC_SLOTS do
        local info = C_Container.GetContainerItemInfo(BANK_CONTAINER, i)
        if info and info.itemName then
            if info.itemName == name then
                table.insert(result, { BANK_CONTAINER, i })
            end
        end
    end

    return result
end

function es:IsBankBagId(bagId)
    return bagId == -1 or bagId > NUM_BAG_SLOTS
end

function es:ShowConfirmation(text, func)
    StaticPopupDialogs['CONFIRMATION_POPUP'] = {
        text = text,
        button1 = "Yes",
        button2 = "No",
        OnAccept = func,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("CONFIRMATION_POPUP")
end

es.SlotInfo = {
    [1] = {
        ['name'] = 'Ammo',
        ['code'] = 'AmmoSlot',
    },
    [2] = {
        ['name'] = 'Head',
        ['code'] = 'HeadSlot',
    },
    [3] = {
        ['name'] = 'Neck',
        ['code'] = 'NeckSlot',
    },
    [4] = {
        ['name'] = 'Shoulder',
        ['code'] = 'ShoulderSlot',
    },
    [5] = {
        ['name'] = 'Shirt',
        ['code'] = 'ShirtSlot',
    },
    [6] = {
        ['name'] = 'Chest',
        ['code'] = 'ChestSlot',
    },
    [7] = {
        ['name'] = 'Waist',
        ['code'] = 'WaistSlot',
    },
    [8] = {
        ['name'] = 'Legs',
        ['code'] = 'LegsSlot',
    },
    [9] = {
        ['name'] = 'Feet',
        ['code'] = 'FeetSlot',
    },
    [10] = {
        ['name'] = 'Wrist',
        ['code'] = 'WristSlot',
    },
    [11] = {
        ['name'] = 'Hands',
        ['code'] = 'HandsSlot',
    },
    [12] = {
        ['name'] = 'Finger 1',
        ['code'] = 'Finger0Slot',
    },
    [13] = {
        ['name'] = 'Finger 2',
        ['code'] = 'Finger1Slot',
    },
    [14] = {
        ['name'] = 'Trinket 1',
        ['code'] = 'Trinket0Slot',
    },
    [15] = {
        ['name'] = 'Trinket 2',
        ['code'] = 'Trinket1Slot',
    },
    [16] = {
        ['name'] = 'Back',
        ['code'] = 'BackSlot',
    },
    [17] = {
        ['name'] = 'Main Hand',
        ['code'] = 'MainHandSlot',
    },
    [18] = {
        ['name'] = 'Off Hand',
        ['code'] = 'SecondaryHandSlot',
    },
    [19] = {
        ['name'] = 'Ranged or Relic',
        ['code'] = 'RangedSlot',
    },
    [20] = {
        ['name'] = 'Tabard',
        ['code'] = 'TabardSlot',
    },
}

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

function es:SaveCurrentSet(setId)
    local currentName = self:GetName(setId)
    if (currentName == nil or currentName == "") then
        currentName = self:DefaultName(setId)
    end

    self:ResetSet(setId, currentName)
    for x = 1, MAX_SLOT_NUMBER do
        self:SaveItem(setId, x, self:GetEquippedName(x))
    end
end

function es:EquipSet(setId)
    if not self:HasSet(setId) then
        self:Log("You must save a set to this slot first.")
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
            if x == 1 or self:GetEquippedName(x) ~= name then
                local result = self:SearchItems(name)
                if #result == 0 then
                    if self:IsDoubleSlot(x) and self:GetEquippedName(self:GetOtherSlot(x)) then
                        PickupInventoryItem(self:GetOtherSlot(x) - 1)
                        PickupInventoryItem(x - 1)
                    else
                        self:LogError("Item " ..
                            self:Colorize(Colors.YELLOW, name) .. ' for ' .. self:Colorize(Colors.ORANGE, self.SlotInfo[x].name) .. ' slot not found.')
                    end
                end

                -- self:Log("Equipping " .. name .. ' to ' .. x)

                for _, data in pairs(result) do
                    local bagId, bagSlot = data[1], data[2]

                    if (not usedSlots[bagId] or usedSlots[bagId] and not usedSlots[bagId][bagSlot]) then
                        -- self:Log("Equipping " .. name .. ' from ' .. bagId .. ' ' .. bagSlot .. ' to ' .. (x - 1))
                        -- special ammo handling

                        if x == 1 then
                            if self.isBankOpen then
                                if self:GetEquippedName(x) ~= name then
                                    -- only works when bank is open
                                    self:EquipItemFromBag(bagId, bagSlot, x - 1)
                                end

                                -- if ammo in bank - move to inventory
                                if self:IsBankBagId(bagId) then
                                    local _, numFreeSlots = self:GetFreeSlots()
                                    if numFreeSlots == 0 then
                                        self:LogError('Not enough inventory space to equip ammo')
                                    else
                                        C_Container.UseContainerItem(bagId, bagSlot)
                                    end
                                end
                            else
                                -- only works when bank is not open
                                C_Item.EquipItemByName(name)
                            end
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

for i = 1, 10 do
    _G["SLASH_LOADSET" .. i .. '1'] = "/loadset" .. 1
    SlashCmdList["LOADSET" .. i] = function(msg)
        es:EquipSet(i)
    end
end

local commands = {
    equip = {
        handler = function(args)
            local setId = tonumber(args[1])
            if setId == nil then
                local setName = table.concat(args, ' ') or ''
                if setName ~= '' then
                    setId = es:GetSetByName(setName)
                    if not setId then
                        es:LogError("Set " .. es:Colorize(Colors.ORANGE, setName) .. ' not found')
                        return
                    end
                end
            end

            if not setId then
                es:LogError("Set id or name must be specified")
                return
            end

            if not es:HasSet(setId) then
                es:LogError("Set id " .. setId .. " is not stored")
                return
            end
            es:Log("Equipping set №" .. setId .. " " .. es:GetName(setId, Colors.ORANGE))
            es:EquipSet(setId)
        end,
    },
    save = {
        handler = function(args)
            local setId, name
            if args[1] == nil then
                setId = #SavedSets + 1
                name = es:DefaultName(setId)
            elseif tonumber(args[1]) ~= nil then
                setId = tonumber(args[1])

                table.removemulti(args, 1, 1)
                name = table.concat(args, ' ') or ''

                if setId > #SavedSets then
                    setId = #SavedSets + 1
                    if name == '' then
                        name = es:DefaultName(setId)
                    end
                elseif name == '' then
                    name = es:GetName(setId)
                end
            elseif (args[1] or '') ~= '' then
                name = table.concat(args, ' ')
                setId = es:GetSetByName(name)
                if setId == nil then
                    setId = #SavedSets + 1
                end
            else
                setId = #SavedSets + 1
                name = es:DefaultName(setId)
            end

            if setId < 1 then
                es:LogError("Bad set number")
                return
            end

            if name == nil or name == '' then
                es:LogError("Bad equipment set name")
                return
            end

            es:Log("Saved current equpment to set №" ..
                setId ..
                " " .. es:Colorize(Colors.ORANGE, #name > 0 and name or es:GetName(setId) or es:DefaultName(setId)))
            es:SaveCurrentSet(setId)
            if #name > 0 then
                es:SetName(setId, name)
            end
        end
    },
    unequip = {
        handler = function(args)
            if es:UnequipEverything() then
                es:Log("Unequipped all items")
            end
        end
    },
    rename = {
        handler = function(args)
            local setId = tonumber(args[1])
            if setId == nil then
                es:LogError("Set id must be a number")
                return
            end
            if not es:HasSet(setId) then
                es:LogError("Set id " .. setId .. " is not stored")
                return
            end

            table.removemulti(args, 1, 1)
            local name = table.concat(args, " ") or ""
            if #name == 0 then
                es:LogError("Name not provided")
                return
            end

            es:Log("Renaming equpment set №" .. setId .. " to \"" .. name .. "\"")
            es:SetName(setId, name)
        end
    },
    remove = {
        handler = function(args)
            local setId = tonumber(args[1])
            if setId == nil then
                local setName = table.concat(args, ' ') or ''
                if setName ~= '' then
                    setId = es:GetSetByName(setName)
                    if not setId then
                        es:LogError("Set " .. es:Colorize(Colors.ORANGE, setName) .. ' not found')
                        return
                    end
                end
            end

            if not setId then
                es:LogError("Set id or name must be specified")
                return
            end

            if not es:HasSet(setId) then
                es:LogError("Set id " .. setId .. " is not stored")
                return
            end

            es:Log("Removed equipment set №" .. setId .. " " .. es:GetName(setId, Colors.ORANGE))
            es:RemoveSet(setId)
        end
    },
    list = {
        handler = function(args)
            local cnt = 0
            es:Each(function(i)
                cnt = cnt + 1
                local totalItems = 0
                local hasItems = 0
                local equippedItems = 0

                for j = 1, MAX_SLOT_NUMBER do
                    local positionName = es:GetPositionName(i, j)
                    if positionName then
                        totalItems = totalItems + 1
                        if es:GetEquippedName(j) == positionName then
                            hasItems = hasItems + 1
                            equippedItems = equippedItems + 1
                        elseif #es:SearchItems(positionName) > 0 then
                            hasItems = hasItems + 1
                        end
                    end
                end

                es:Log("№" .. i .. ' ' ..
                    es:GetName(i, Colors.ORANGE) .. ' (' .. equippedItems .. '/' .. hasItems .. '/' .. totalItems .. ')')
            end)
            es:Log("Total sets stored: " .. es:Colorize(Colors.ORANGE, cnt) .. ", legend: equipped/available/total")
        end
    },
    setposition = {
        handler = function(args)
            local setId = tonumber(args[1])
            if setId == nil then
                es:LogError("Set id must be a number")
                return
            end
            if not es:HasSet(setId) then
                es:LogError("Set id " .. setId .. " is not stored")
                return
            end

            local positionId = tonumber(args[2])
            if positionId == nil then
                es:LogError("Position id not provided")
                return
            end

            if positionId < 1 or positionId > MAX_SLOT_NUMBER then
                es:LogError("Bad position id provided")
                return
            end

            table.removemulti(args, 1, 2)
            local positionName = table.concat(args, " ") or ""
            if #positionName > 0 then
                es:Log('Saved position ' ..
                    positionId ..
                    ' "' .. positionName .. '" to set №' .. setId .. ' ' .. es:GetName(setId, Colors.ORANGE))
                es:SaveItem(setId, positionId, positionName)
            else
                es:Log('Removed position ' ..
                    positionId .. ' from set №' .. setId .. ' ' .. es:GetName(setId, Colors.ORANGE))
                es:SaveItem(setId, positionId, nil)
            end
        end
    },
    reset = {
        handler = function(args)
            es:ShowConfirmation("Wipe " .. es:Colorize(Colors.RED, 'ALL') .. ' stored equipments sets?', function()
                SavedSets = {}
            end)
        end
    },
    test = {
        handler = function(args)
            es:Log("Main handler, args: " .. dump(args))
        end,
        commandTable = {
            a = {
                handler = function(args)
                    es:Log("Command a, args: " .. dump(args))
                end
            },
            b = {
                handler = function(args)
                    es:Log("Command b, args: " .. dump(args))
                end
            },
            c = {
                handler = function(args)
                    es:Log("Command c, args: " .. dump(args))
                end
            },
        }
    }
}

commands['load'] = commands['equip']

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
            es:LogError('Unknown command "' .. command .. '"')
        end
        return
    end

    es:Log("Available commands:")
    local usages = CollectUsages(commands)
    for _, usage in pairs(usages) do
        es:Log("/es " .. usage)
    end
end

function es:UnequipEverything()
    local slots = {}
    for x = 1, MAX_SLOT_NUMBER do
        table.insert(slots, x)
    end
    return self:UneqipSlots(slots)
end

SLASH_UNEQUIPALL1 = "/unequipall"
SlashCmdList["UNEQUIPALL"] = function(msg)
    if es:UnequipEverything() then
        es:Log("Unequipped all items")
    end
end

function es:Initialize1()
    self.NameInputs = {}
    self.isBankOpen = false

    local fSettings = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset") --Create a frame
    fSettings:SetFrameStrata("TOOLTIP")                                                  --Set its strata
    fSettings:SetHeight(150)                                                             --Give it height
    fSettings:SetWidth(220)                                                              --and width -- old 200
    fSettings:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    fSettings:Hide()

    fSettings.title = fSettings:CreateFontString(nil, "OVERLAY");
    fSettings.title:SetFontObject("GameFontHighlight");
    fSettings.title:SetPoint("CENTER", fSettings.TitleBg, "CENTER", 5, 0);
    fSettings.title:SetText("Rename equipment set");

    fSettings.nameInput = CreateFrame("EditBox", nil, fSettings, "InputBoxTemplate")
    fSettings.nameInput:SetSize(180, 24)
    fSettings.nameInput:SetPoint("TOP", 0, -47, 0, 0)
    fSettings.nameInput:SetAutoFocus(false)
    fSettings.nameInput:SetText("")

    function fSettings:SetAction(action, setId, setName)
        self.action = action
        self.setId = setId
        self.nameInput:SetText(setName)

        if action == 'create' then
            self.title:SetText("Create equipment set")
        elseif action == 'rename' then
            self.title:SetText("Rename equipment set")
        end
    end

    function fSettings:OnConfirm()
        if not self.setId then
            return true
        end

        local name = self.nameInput:GetText() or ''
        if name == '' then
            return false
        end

        if self.action == 'create' then
            es:SaveCurrentSet(self.setId)
            es:SetName(self.setId, name)
        elseif self.action == 'rename' then
            es:SetName(self.setId, name)
        end

        return true
    end

    -- Dropdown menu
    local setListDropdown = CreateFrame("FRAME", nil, PaperDollFrame, "UIDropDownMenuTemplate")
    setListDropdown:SetPoint("BOTTOMLEFT", 0, 80, 0, 0)
    UIDropDownMenu_SetWidth(setListDropdown, 80)
    --UIDropDownMenu_SetText(dropDown, "" .. favoriteNumber)
    UIDropDownMenu_SetText(setListDropdown, "Sets")
    UIDropDownMenu_Initialize(setListDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()

        es:Each(function(xx)
            if (level or 1) == 1 then
                info.func = function(self, arg)
                    if es:HasSet(arg) then
                        es:Log("Equipped set №" .. arg .. " " .. es:GetName(arg, Colors.ORANGE))
                    end
                    es:EquipSet(arg)
                    CloseDropDownMenus()
                end

                info.text, info.arg1, info.checked = es:GetName(xx), xx,
                    es:IsSetEquipped(xx)
                info.tooltipOnButton = true
                info.disabled = false
                info.menuList, info.hasArrow = xx, true
                local tooltipTexts = {}
                local totalCnt = 0
                local equippedCnt = 0
                local hasMissing = false
                for i = 1, MAX_SLOT_NUMBER do
                    local item = es:GetPositionName(xx, i)
                    if item then
                        local equipped = es:GetEquippedName(i)
                        totalCnt = totalCnt + 1
                        local text = es.SlotInfo[i].name .. ':\n'
                        if equipped == item then
                            equippedCnt = equippedCnt + 1
                            text = text .. es:Colorize(Colors.GREEN, item)
                        elseif #es:SearchItems(item) > 0 then
                            text = text .. es:Colorize(Colors.YELLOW, item)
                            if equipped ~= nil then
                                text = text .. '\n' .. es:Colorize(Colors.GRAY, equipped)
                            end
                        else
                            hasMissing = true
                            text = text .. es:Colorize(Colors.RED, item)
                            if equipped ~= nil then
                                text = text .. '\n' .. es:Colorize(Colors.GRAY, equipped)
                            end
                        end
                        table.insert(tooltipTexts, text)
                    end
                end

                local cntText = "(" .. equippedCnt .. '/' .. totalCnt .. ')'
                if equippedCnt == totalCnt then
                    cntText = es:Colorize(Colors.GREEN, cntText)
                elseif hasMissing then
                    cntText = es:Colorize(Colors.RED, cntText)
                else
                    cntText = es:Colorize(Colors.YELLOW, cntText)
                end

                info.tooltipTitle = es:GetName(xx) .. ' ' .. cntText
                info.tooltipText = table.concat(tooltipTexts, '\n\n')
                UIDropDownMenu_AddButton(info)
            end
        end)

        if (level or 1) == 1 then
            -- local info = UIDropDownMenu_CreateInfo()
            info.func = function()
                fSettings:SetAction('create', #SavedSets + 1, es:DefaultName(#SavedSets + 1))
                fSettings:Show()
                CloseDropDownMenus()
            end
            info.text = "Create new Set"
            info.notCheckable = true
            info.tooltipOnButton, info.checked, info.disabled = true, false, false
            info.tooltipTitle = "Create new set"
            info.tooltipText = "Create new loadout from currently equipped items"
            info.hasArrow = false
            UIDropDownMenu_AddButton(info)

            -- local info = UIDropDownMenu_CreateInfo()
            info.func = function()
                if es:UnequipEverything() then
                    es:Log("Unequipped all items")
                end
                CloseDropDownMenus()
            end

            info.text = "Unequip everything"
            info.notCheckable = true
            info.tooltipOnButton, info.checked, info.disabled = true, false, false
            info.tooltipTitle = "Unequip Everything"
            info.tooltipText = "Click this to unequip everything"
            info.hasArrow = false
            UIDropDownMenu_AddButton(info)
        else
            info.func = function(self, arg1, arg2)
                local text, OnAccept
                if arg2 == 'save' then
                    text = "Overwrite equipment set " .. es:GetName(arg1, Colors.ORANGE) .. " ?"
                    OnAccept = function()
                        es:SaveCurrentSet(arg1)
                    end
                elseif arg2 == 'rename' then
                    fSettings:SetAction('rename', arg1, es:GetName(arg1))
                    fSettings:Show()
                    CloseDropDownMenus()
                    return
                elseif arg2 == 'delete' then
                    text = self:Colorize("Delete", Colors.RED) .. " equipment set " .. es:GetName(arg1, Colors.ORANGE) .. " ?"
                    OnAccept = function()
                        es:RemoveSet(arg1)
                    end
                else
                    CloseDropDownMenus()
                    return
                end

                es:ShowConfirmation(text, OnAccept)
                CloseDropDownMenus()
            end
            -- local info = UIDropDownMenu_CreateInfo()
            info.notCheckable = true
            info.checked = false
            info.disabled = false
            info.arg1 = menuList
            info.tooltipOnButton = true

            info.text, info.arg2 = "Save", 'save'
            info.tooltipTitle = "Save set"
            info.tooltipText = "Overwrite equipment set " ..
                es:GetName(menuList, Colors.ORANGE) .. " with currently equipped items."
            UIDropDownMenu_AddButton(info, level)

            -- local info = UIDropDownMenu_CreateInfo()
            info.text, info.arg2 = "Rename", 'rename'
            info.tooltipTitle = "Rename set"
            info.tooltipText = "Rename equipment set " .. es:GetName(menuList, Colors.ORANGE)
            UIDropDownMenu_AddButton(info, level)

            -- local info = UIDropDownMenu_CreateInfo()
            info.text, info.arg2 = "Delete", 'delete'
            info.tooltipTitle = "Delete set"
            info.tooltipText = "Delete equipment set " .. es:GetName(menuList, Colors.ORANGE)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local widgetConfirm = CreateFrame("Button", nil, fSettings, "UIPanelButtonTemplate");
    widgetConfirm:SetWidth(150);
    widgetConfirm:SetHeight(19);
    widgetConfirm:SetPoint("BOTTOM", 0, 9, 0, 0);
    widgetConfirm:SetText("Confirm");
    widgetConfirm:SetScript("OnClick", function(self, button, down)
        if fSettings:OnConfirm() then
            fSettings:Hide()
        end
    end)

    for _, frame in pairs { UIParent:GetChildren() } do
        if not frame:IsForbidden() and frame:GetObjectType() == 'GameTooltip' then
            frame:HookScript('OnTooltipCleared', es.OnClear)
            frame:HookScript('OnTooltipSetItem', es.OnItem)
        end
    end
end

function es.OnClear(tip)
    tip._hasSets = false
end

function es.OnItem(tip)
    local name = (tip.GetItem or TooltipUtil.GetDisplayedItem)(tip)
    if name ~= '' then
        if not tip._hasSets then
            local sets = {}
            es:Each(function(i)
                if es:HasItem(i, name) then
                    table.insert(sets, es:GetName(i))
                end
            end)

            if #sets > 0 then
                tip:AddDoubleLine('|cFFFFFFFFSets:|r', table.concat(sets, ', '))
                tip:Show()
            end

            tip._hasSets = true
        end
    end
end

function es:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        if not SavedSets then
            SavedSets = {}
        end

        es:Initialize1()
    elseif event == "BANKFRAME_OPENED" then
        es.isBankOpen = true
    elseif event == "BANKFRAME_CLOSED" then
        es.isBankOpen = false
    end
end

frame:SetScript("OnEvent", es.OnEvent);
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("BANKFRAME_OPENED");
frame:RegisterEvent("BANKFRAME_CLOSED");
