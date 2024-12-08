-- Author: Fr0stwing
-- https://www.curseforge.com/members/fr0stwing/
-- https://github.com/fr0stwing
-- Note: This is a dev version of a beta. The code looks very wonky, I know. It's a draft.
--       I meant to re-do everything at some point, so I didn't do it as efficiently
--       as possible, because I didn't think I'd be releasing this draft version.
--       Right now, I'm focusing on making this version work properly in-game so that
--       it's properly usable in the meantime.          Stay tuned for v2.0.0!

-- SavedVariables
savedSet1 = {}
savedSet2 = {}
savedSet3 = {}
savedSet4 = {}
savedSet5 = {}
savedSet6 = {}
savedSet7 = {}
savedSet8 = {}
savedSet9 = {}
savedSet10 = {}
savedAmmoSlotItem = "No Ammo"

-- Default
loadSlotTitles = {"Loadout 1", "Loadout 2", "Loadout 3", "Loadout 4", "Loadout 5", "Loadout 6", "Loadout 7", "Loadout 8", "Loadout 9", "Loadout 10"}

slots = {"AmmoSlot", "HeadSlot", "NeckSlot", "ShoulderSlot", "ShirtSlot", "ChestSlot", "WaistSlot", "LegsSlot", "FeetSlot", "WristSlot", "HandsSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "BackSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot", "TabardSlot"}
slotsDisplay = {"Ammo: \n[", "Head: \n[", "Neck: \n[", "Shoulder: \n[", "Shirt: \n[", "Chest: \n[", "Waist: \n[", "Legs: \n[", "Feet: \n[", "Wrist: \n[", "Hands: \n[", "Finger 1: \n[", "Finger 2: \n[", "Trinket 1: \n[", "Trinket 2: \n[", "Back: \n[", "Main Hand: \n[", "Off Hand: \n[", "Ranged or Relic: \n[", "Tabard: \n["}

-- Data
local AmmoList = {
    [  2516 ] = true,   -- Light Shot
    [  2512 ] = true,   -- Rough Arrow
    [  4960 ] = true,   -- Flash Pellet
    [  2514 ] = true,   -- Depricated Sharp Arrow
    [  8067 ] = true,   -- Crafted Light Shot
    [  2515 ] = true,   -- Sharp Arrow
    [  2519 ] = true,   -- Heavy Shot
    [  5568 ] = true,   -- Smooth Pebble
    [  3029 ] = true,   -- Depricated Whipwood Arrow
    [  8068 ] = true,   -- Crafted Heavy Shot
    [  3030 ] = true,   -- Razor Arrow
    [  3033 ] = true,   -- Solid Shot
    [  3464 ] = true,   -- Feathered Arrow
    [  3031 ] = true,   -- Depricated Razor Arrow
    [  8069 ] = true,   -- Crafted Solid Shot
    [  3465 ] = true,   -- Exploding Shot
    [  9399 ] = true,   -- Precision Arrow
    [ 10579 ] = true,   -- Explosive Arrow
    [ 10512 ] = true,   -- Hi-Impact Mithril Slugs
    [ 11285 ] = true,   -- Jagged Arrow
    [ 11284 ] = true,   -- Accurate Slugs
    [ 10513 ] = true,   -- Mithril Gyro-Shot
    [ 11630 ] = true,   -- Rockshard Pellets
    [ 19317 ] = true,   -- Ice Threaded Bullet
    [ 19316 ] = true,   -- Ice Threaded Arrow
    [ 15997 ] = true,   -- Thorium Shells
    [ 18042 ] = true,   -- Thorium Headed Arrow
    [ 12654 ] = true,   -- Doomshot
    [ 13377 ] = true,   -- Miniature Cannon Balls
    [ 28053 ] = true,   -- Wicked Arrow
    [ 28060 ] = true,    -- Impact Shot
    [ 23772 ] = true,   -- Fel Iron Shells
    [ 24417 ] = true,   -- Scout's Arrow
    [ 30611 ] = true,   -- Halaani Razorshaft
    [ 30612 ] = true,   -- Halaani Grimshot
    [ 31949 ] = true,   -- Warden's Arrow
    [ 24412 ] = true,   -- Warden's Arrow (Different ID)
    [ 32883 ] = true,   -- Felbane SLugs
    [ 32882 ] = true,   -- Hellfire Shot
    [ 28056 ] = true,   -- Blackflight Arrow
    [ 33803 ] = true,   -- Adamantite Stinger
    [ 23773 ] = true,   -- Adamantite Shells
    [ 28061 ] = true,   -- Ironbite Shell
    [ 34581 ] = true,   -- Myseterious Arrow
    [ 34582 ] = true,   -- Mysterious Shell
    [ 31737 ] = true,   -- Timeless Arrow
    [ 32760 ] = true,   -- The Macho Gnome's Arrow
    [ 32761 ] = true,   -- The Sarge's Bullet
    [ 31735 ] = true,   -- Timeless Shell
    [ 41586 ] = true,   -- Terrorshaft Arrow
    [ 41584 ] = true,   -- Frostbite Bullets
    [ 30319 ] = true,   -- Nether Spike
    [ 41164 ] = true,   -- Mammoth Cutters
    [ 41165 ] = true,   -- Saronite Razorheads
    [ 52021 ] = true,   -- Iceblade Arrow
    [ 52020 ] = true,   -- Shatter Rounds
    [ 46854 ] = true    -- Saronite Decimators
}

-- Dump function
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function unequipWeaponsRingsAndTrinkets()
    C_Timer.After(0.1, function()
        PickupInventoryItem(11) PutItemInBackpack();
        PickupInventoryItem(12) PutItemInBackpack();
        PickupInventoryItem(13) PutItemInBackpack();
        PickupInventoryItem(14) PutItemInBackpack();
        PickupInventoryItem(16) PutItemInBackpack();
        PickupInventoryItem(17) PutItemInBackpack();
        C_Timer.After(0.1, function()
            PickupInventoryItem(11) PutItemInBag(20);
            PickupInventoryItem(12) PutItemInBag(20);
            PickupInventoryItem(13) PutItemInBag(20);
            PickupInventoryItem(14) PutItemInBag(20);
            PickupInventoryItem(16) PutItemInBag(20);
            PickupInventoryItem(17) PutItemInBag(20);
            C_Timer.After(0.1, function()
                PickupInventoryItem(11) PutItemInBag(21);
                PickupInventoryItem(12) PutItemInBag(21);
                PickupInventoryItem(13) PutItemInBag(21);
                PickupInventoryItem(14) PutItemInBag(21);
                PickupInventoryItem(16) PutItemInBag(21);
                PickupInventoryItem(17) PutItemInBag(21);
                C_Timer.After(0.1, function()
                    PickupInventoryItem(11) PutItemInBag(22);
                    PickupInventoryItem(12) PutItemInBag(22);
                    PickupInventoryItem(13) PutItemInBag(22);
                    PickupInventoryItem(14) PutItemInBag(22);
                    PickupInventoryItem(16) PutItemInBag(22);
                    PickupInventoryItem(17) PutItemInBag(22);
                    C_Timer.After(0.1, function()
                        PickupInventoryItem(11) PutItemInBag(23);
                        PickupInventoryItem(12) PutItemInBag(23);
                        PickupInventoryItem(13) PutItemInBag(23);
                        PickupInventoryItem(14) PutItemInBag(23);
                        PickupInventoryItem(16) PutItemInBag(23);
                        PickupInventoryItem(17) PutItemInBag(23);
                    end)
                end)
            end)
        end)
    end)
end

function saveTheCurrentSet(currentSetNumber)
    theCurrentSetToSave = tostring("savedSet" .. currentSetNumber)
    _G[theCurrentSetToSave] = {}
    table.insert(_G[theCurrentSetToSave], tostring(savedAmmoSlotItem))
    for x = 2, 20 do
        local slotID = GetInventorySlotInfo(slots[x])
        local itemLink = GetInventoryItemLink("player", slotID)
        if itemLink == nil then 
            table.insert(_G[theCurrentSetToSave], tostring("EMPTY SLOT"))
        else
            local name, _, _, ilvl = GetItemInfo(itemLink)
            table.insert(_G[theCurrentSetToSave], tostring(name))
        end
    end
end

function loadTheSet(currentSetNumber)
    theCurrentSavedSet = tostring("savedSet" .. currentSetNumber)
    if next(_G[theCurrentSavedSet]) == nil then
        print("You must save a set to this slot first.")
    else
        for x = 1, 20 do
            if _G[theCurrentSavedSet][x] == _G[theCurrentSavedSet][1] then -- If Ammo
                EquipItemByName(_G[theCurrentSavedSet][x]) -- Simply equip
            else
                EquipItemByName(_G[theCurrentSavedSet][x], x-1) -- Equip to specific slot
            end
        end
        -- If two weapons/trinkets/rings have the same name, re-equip the 2nd after 1 sec to the 2nd slot
        C_Timer.After(1, function()
            if tostring(_G[theCurrentSavedSet][18]) == tostring(_G[theCurrentSavedSet][17]) then
                EquipItemByName(_G[theCurrentSavedSet][18], 17)
                --print("Equipping ",_G[theCurrentSavedSet][18],"to slot 17")
            end
            if tostring(_G[theCurrentSavedSet][15]) == tostring(_G[theCurrentSavedSet][14]) then
                EquipItemByName(_G[theCurrentSavedSet][15], 14)
                --print("Equipping ",_G[theCurrentSavedSet][15],"to slot 14")
            end
            if tostring(_G[theCurrentSavedSet][13]) == tostring(_G[theCurrentSavedSet][12]) then
                EquipItemByName(_G[theCurrentSavedSet][13], 12)
                --print("Equipping ",_G[theCurrentSavedSet][13],"to slot 12")
            end
        end)
    end
    for i=0,20 do
        if tostring(_G[theCurrentSavedSet][i]) == "EMPTY SLOT" then
            C_Timer.After(0.2, function()
                PickupInventoryItem(i-1) PutItemInBackpack();
                C_Timer.After(0.2, function()
                    PickupInventoryItem(i-1) PutItemInBag(20);
                    C_Timer.After(0.2, function()
                        PickupInventoryItem(i-1) PutItemInBag(21);
                        C_Timer.After(0.2, function()
                            PickupInventoryItem(i-1) PutItemInBag(22);
                            C_Timer.After(0.2, function()
                                PickupInventoryItem(i-1) PutItemInBag(23);
                                return
                            end)
                        end)
                    end)
                end)
            end)
        end
    end
end

-- Load commands
-- [Yes, I know, this isn't efficient.
--  I should pass arguments with one command,
--  but it's a bit too late to change it now
--  since people already have those in their macros.]
SLASH_LOADSET11 = "/loadset1"
SLASH_LOADSET21 = "/loadset2"
SLASH_LOADSET31 = "/loadset3"
SLASH_LOADSET41 = "/loadset4"
SLASH_LOADSET51 = "/loadset5"
SLASH_LOADSET61 = "/loadset6"
SLASH_LOADSET71 = "/loadset7"
SLASH_LOADSET81 = "/loadset8"
SLASH_LOADSET91 = "/loadset9"
SLASH_LOADSET101 = "/loadset10"

SlashCmdList["LOADSET1"] = function(msg)
   currentSetNumber = "1"
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET2"] = function(msg)
   currentSetNumber = "2"
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET3"] = function(msg)
   currentSetNumber = "3"
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET4"] = function(msg)
   currentSetNumber = "4"
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET5"] = function(msg)
   currentSetNumber = "5"
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET6"] = function(msg)
   currentSetNumber = "6"
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET7"] = function(msg)
   currentSetNumber = "7"
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET8"] = function(msg)
   currentSetNumber = "8"
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET9"] = function(msg)
   currentSetNumber = "9"
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET10"] = function(msg)
   currentSetNumber = "10"
   loadTheSet(currentSetNumber)
end

-- UnequipAll
function unequipEverythingWorn()
    function removeToInv()
        for x=0,19 do
            PickupInventoryItem(x) PutItemInBackpack();
        end
    end
    function removeToBag1()
        for x=0,19 do
            PickupInventoryItem(x) PutItemInBag(20);
        end
    end
    function removeToBag2()
        for x=0,19 do
            PickupInventoryItem(x) PutItemInBag(21);
        end
    end
    function removeToBag3()
        for x=0,19 do
            PickupInventoryItem(x) PutItemInBag(22);
        end
    end
    function removeToBag4()
        for x=0,19 do
            PickupInventoryItem(x) PutItemInBag(23);
        end
    end
    C_Timer.After(0.2, function()
        removeToInv()
        C_Timer.After(0.2, function()
            removeToBag1()
            C_Timer.After(0.2, function()
                removeToBag2()
                C_Timer.After(0.2, function()
                    removeToBag3()
                    C_Timer.After(0.2, function()
                        removeToBag4()
                        return
                    end)
                end)
            end)
        end)
    end)
end
SLASH_UNEQUIPALL1 = "/unequipall"
SlashCmdList["UNEQUIPALL"] = function(msg)
    unequipEverythingWorn()
end

-- Dropdown menu
local favoriteNumber = "Sets"
local dropDown = CreateFrame("FRAME", "theDropDown", PaperDollFrame, "UIDropDownMenuTemplate")
dropDown:SetPoint("BOTTOMLEFT", 18, 80, 0, 0)
UIDropDownMenu_SetWidth(dropDown, 48)
--UIDropDownMenu_SetText(dropDown, "" .. favoriteNumber)
UIDropDownMenu_SetText(dropDown, "Sets")
UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    --loadSlotTitles = {"Load 1aa", "Load 2", "Load 3", "Load 4", "Load 5", "Load 6", "Load 7", "Load 8", "Load 9", "Load 10"}
    savedVars = {savedSet1, savedSet2, savedSet3, savedSet4, savedSet5, savedSet6, savedSet7, savedSet8, savedSet9, savedSet10}
    info.func = self.SetValue
    for xx=1,10 do
        info.menuList, info.hasArrow = loadSlotTitles[xx], false -- change to true to create nests
        info.text, info.arg1, info.checked = loadSlotTitles[xx], loadSlotTitles[xx], loadSlotTitles[xx] == favoriteNumber
        info.tooltipOnButton = true
        info.tooltipTitle = loadSlotTitles[xx]
        info.tooltipText = slotsDisplay[1]..tostring(savedVars[xx][1]).."]\n\n"..slotsDisplay[2]..tostring(savedVars[xx][2]).."]\n\n"..slotsDisplay[3]..tostring(savedVars[xx][3]).."]\n\n"..slotsDisplay[4]..tostring(savedVars[xx][4]).."]\n\n"..slotsDisplay[5]..tostring(savedVars[xx][5]).."]\n\n"..slotsDisplay[6]..tostring(savedVars[xx][6]).."]\n\n"..slotsDisplay[7]..tostring(savedVars[xx][7]).."]\n\n"..slotsDisplay[8]..tostring(savedVars[xx][8]).."]\n\n"..slotsDisplay[9]..tostring(savedVars[xx][9]).."]\n\n"..slotsDisplay[10]..tostring(savedVars[xx][10]).."]\n\n"..slotsDisplay[11]..tostring(savedVars[xx][11]).."]\n\n"..slotsDisplay[12]..tostring(savedVars[xx][12]).."]\n\n"..slotsDisplay[13]..tostring(savedVars[xx][13]).."]\n\n"..slotsDisplay[14]..tostring(savedVars[xx][14]).."]\n\n"..slotsDisplay[15]..tostring(savedVars[xx][15]).."]\n\n"..slotsDisplay[16]..tostring(savedVars[xx][16]).."]\n\n"..slotsDisplay[17]..tostring(savedVars[xx][17]).."]\n\n"..slotsDisplay[18]..tostring(savedVars[xx][18]).."]\n\n"..slotsDisplay[19]..tostring(savedVars[xx][19]).."]\n\n"..slotsDisplay[20]..tostring(savedVars[xx][20]).."]"
        UIDropDownMenu_AddButton(info)
    end
    info.func = self.UnequipEverything
    info.text = "# Unequip everything"
    info.tooltipOnButton = true
    info.tooltipTitle = "Unequip Everything"
    info.tooltipText = "\nSelect this to unequip everything. You can also type out the \"/unequipall\" command. You can also tie this command to a macro."
    UIDropDownMenu_AddButton(info)
end)

function dropDown:UnequipEverything()
    unequipEverythingWorn()
    CloseDropDownMenus()
end

local fSettings=CreateFrame("Frame", "TheSettingsFrame", UIParent, "BasicFrameTemplateWithInset") --Create a frame
fSettings:SetFrameStrata("TOOLTIP") --Set its strata
fSettings:SetHeight(500) --Give it height
fSettings:SetWidth(220) --and width -- old 200
fSettings:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
fSettings:Hide()
isTheSettingsFrameHidden = "1"
--fSettings:SetScript("OnHide", function(self, arg1)
    --isThePriorityFrameHidden = 1
--end)
fSettings.title = fSettings:CreateFontString(nil, "OVERLAY");
fSettings.title:SetFontObject("GameFontHighlight");
fSettings.title:SetPoint("CENTER", fSettings.TitleBg, "CENTER", 5, 0);
fSettings.title:SetText("EquipmentSets - Names");

-- Settings button
local widget = CreateFrame("Button", "TauntingButton", theDropDown, "UIPanelButtonTemplate");
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
widget:SetScript("OnClick", function (self, button, down)
    fSettings:Show()
end)

fSettings.introText = fSettings:CreateFontString(nil, "ARTWORK")
fSettings.introText:SetFont("Fonts\\FRIZQT__.TTF", 11)
fSettings.introText:SetText("\n\n\nSet 1\n\n\n\nSet 2\n\n\n\nSet 3\n\n\n\nSet 4\n\n\n\nSet 5\n\n\n\nSet 6\n\n\n\nSet 7\n\n\n\nSet 8\n\n\n\nSet 9\n\n\n\nSet 10")
fSettings.introText:SetTextColor(1, 1, 1)
fSettings.introText:SetAllPoints(true)
fSettings.introText:SetJustifyH("CENTER")
fSettings.introText:SetJustifyV("TOP")

C_Timer.After(1, function()
    local fSettingsTB1=EbT1 or CreateFrame("EditBox", "EbT1", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB1:SetSize(180,24)
    fSettingsTB1:SetPoint("TOP", 0, -47, 0, 0)
    fSettingsTB1:SetAutoFocus(false)
    fSettingsTB1:SetText(loadSlotTitles[1])

    local fSettingsTB2=EbT2 or CreateFrame("EditBox", "EbT2", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB2:SetSize(180,24)
    fSettingsTB2:SetPoint("TOP", 0, -91, 0, 0)
    fSettingsTB2:SetAutoFocus(false)
    fSettingsTB2:SetText(loadSlotTitles[2])

    local fSettingsTB3=EbT3 or CreateFrame("EditBox", "EbT3", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB3:SetSize(180,24)
    fSettingsTB3:SetPoint("TOP", 0, -135, 0, 0)
    fSettingsTB3:SetAutoFocus(false)
    fSettingsTB3:SetText(loadSlotTitles[3])

    local fSettingsTB4=EbT4 or CreateFrame("EditBox", "EbT4", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB4:SetSize(180,24)
    fSettingsTB4:SetPoint("TOP", 0, -179, 0, 0)
    fSettingsTB4:SetAutoFocus(false)
    fSettingsTB4:SetText(loadSlotTitles[4])

    local fSettingsTB5=EbT5 or CreateFrame("EditBox", "EbT5", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB5:SetSize(180,24)
    fSettingsTB5:SetPoint("TOP", 0, -223, 0, 0)
    fSettingsTB5:SetAutoFocus(false)
    fSettingsTB5:SetText(loadSlotTitles[5])

    local fSettingsTB6=EbT6 or CreateFrame("EditBox", "EbT6", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB6:SetSize(180,24)
    fSettingsTB6:SetPoint("TOP", 0, -267, 0, 0)
    fSettingsTB6:SetAutoFocus(false)
    fSettingsTB6:SetText(loadSlotTitles[6])

    local fSettingsTB7=EbT7 or CreateFrame("EditBox", "EbT7", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB7:SetSize(180,24)
    fSettingsTB7:SetPoint("TOP", 0, -311, 0, 0)
    fSettingsTB7:SetAutoFocus(false)
    fSettingsTB7:SetText(loadSlotTitles[7])

    local fSettingsTB8=EbT8 or CreateFrame("EditBox", "EbT8", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB8:SetSize(180,24)
    fSettingsTB8:SetPoint("TOP", 0, -355, 0, 0)
    fSettingsTB8:SetAutoFocus(false)
    fSettingsTB8:SetText(loadSlotTitles[8])

    local fSettingsTB9=EbT9 or CreateFrame("EditBox", "EbT9", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB9:SetSize(180,24)
    fSettingsTB9:SetPoint("TOP", 0, -399, 0, 0)
    fSettingsTB9:SetAutoFocus(false)
    fSettingsTB9:SetText(loadSlotTitles[9])

    local fSettingsTB10=EbT10 or CreateFrame("EditBox", "EbT10", TheSettingsFrame, "InputBoxTemplate")
    fSettingsTB10:SetSize(180,24)
    fSettingsTB10:SetPoint("TOP", 0, -443, 0, 0)
    fSettingsTB10:SetAutoFocus(false)
    fSettingsTB10:SetText(loadSlotTitles[10])

    local widgetConfirm = CreateFrame("Button", "TauntingButton", TheSettingsFrame, "UIPanelButtonTemplate");
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
    widgetConfirm:SetScript("OnClick", function (self, button, down)
        savedName1 = fSettingsTB1:GetText()
        savedName2 = fSettingsTB2:GetText()
        savedName3 = fSettingsTB3:GetText()
        savedName4 = fSettingsTB4:GetText()
        savedName5 = fSettingsTB5:GetText()
        savedName6 = fSettingsTB6:GetText()
        savedName7 = fSettingsTB7:GetText()
        savedName8 = fSettingsTB8:GetText()
        savedName9 = fSettingsTB9:GetText()
        savedName10 = fSettingsTB10:GetText()
        loadSlotTitles = {tostring(savedName1), tostring(savedName2), tostring(savedName3), tostring(savedName4), tostring(savedName5), tostring(savedName6), tostring(savedName7), tostring(savedName8), tostring(savedName9), tostring(savedName10)}
        fSettings:Hide()
    end)
end)

function dropDown:SetValue(newValue)
    favoriteNumber = newValue
    for nn=1,10 do
        if favoriteNumber == loadSlotTitles[nn] then
            loadTheSet(nn)
        end
    end
    CloseDropDownMenus()
end

local dropDown2 = CreateFrame("FRAME", "theDropDown2", PaperDollFrame, "UIDropDownMenuTemplate")
dropDown2:SetPoint("BOTTOMLEFT", 76, 80, 80, 80)
UIDropDownMenu_SetWidth(dropDown2, 8)
--UIDropDownMenu_SetText(dropDown2, "Load")
UIDropDownMenu_Initialize(dropDown2, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    saveSlotTitles = {"Save 1", "Save 2", "Save 3", "Save 4", "Save 5", "Save 6", "Save 7", "Save 8", "Save 9", "Save 10"}
    info.func = self.SetValue
    for xx=1,10 do
        info.menuList, info.hasArrow = saveSlotTitles[xx], false -- change to true to create nests, unstable
        info.text, info.arg1, info.checked = "Save loadout to [" .. loadSlotTitles[xx] .. "]", saveSlotTitles[xx], saveSlotTitles[xx] == favoriteNumber2
        info.tooltipOnButton = true
        info.tooltipTitle = "This will overwrite [" .. loadSlotTitles[xx] .. "]."
        --info.tooltipText = slotsDisplay[1]..tostring(savedVars[xx][1]).."]\n\n"..slotsDisplay[2]..tostring(savedVars[xx][2]).."]\n\n"..slotsDisplay[3]..tostring(savedVars[xx][3]).."]\n\n"..slotsDisplay[4]..tostring(savedVars[xx][4]).."]\n\n"..slotsDisplay[5]..tostring(savedVars[xx][5]).."]\n\n"..slotsDisplay[6]..tostring(savedVars[xx][6]).."]\n\n"..slotsDisplay[7]..tostring(savedVars[xx][7]).."]\n\n"..slotsDisplay[8]..tostring(savedVars[xx][8]).."]\n\n"..slotsDisplay[9]..tostring(savedVars[xx][9]).."]\n\n"..slotsDisplay[10]..tostring(savedVars[xx][10]).."]\n\n"..slotsDisplay[11]..tostring(savedVars[xx][11]).."]\n\n"..slotsDisplay[12]..tostring(savedVars[xx][12]).."]\n\n"..slotsDisplay[13]..tostring(savedVars[xx][13]).."]\n\n"..slotsDisplay[14]..tostring(savedVars[xx][14]).."]\n\n"..slotsDisplay[15]..tostring(savedVars[xx][15]).."]\n\n"..slotsDisplay[16]..tostring(savedVars[xx][16]).."]\n\n"..slotsDisplay[17]..tostring(savedVars[xx][17]).."]\n\n"..slotsDisplay[18]..tostring(savedVars[xx][18]).."]\n\n"..slotsDisplay[19]..tostring(savedVars[xx][19]).."]\n\n"..slotsDisplay[20]..tostring(savedVars[xx][20]).."]"
        info.tooltipText = "\nNOTE: If you have an ammo slot, you will have an additional button under your ammo slot. Click on it to select the ammo you want to save before saving your set."
        UIDropDownMenu_AddButton(info)
    end
end)

function dropDown2:SetValue(newValue)
    favoriteNumber2 = newValue
    --UIDropDownMenu_SetText(dropDown, favoriteNumber)
    for nn=1,10 do
        if favoriteNumber2 == "Save " .. tostring(nn) then
            --print("You have selected Set " .. nn)
            StaticPopupDialogs["DOYOUWANTTO_LOAD"] = {
                text = "["..loadSlotTitles[nn].."] WILL BE OVERWRITTEN. \n\n\nContinue?\n\n\nFor classes with ammo, the following will save:\n" .. "[" .. savedAmmoSlotItem .. "]",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    currentSetNumber = tostring(nn)
                    saveTheCurrentSet(currentSetNumber)
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }

            StaticPopup_Show ("DOYOUWANTTO_LOAD")
            
        end
    end
    CloseDropDownMenus()
end

-- AmmoSlotStuff
local dropDown3 = CreateFrame("FRAME", "theDropDown3", CharacterAmmoSlot, "UIDropDownMenuTemplate")
dropDown3:SetPoint("BOTTOM", 0, -28)
UIDropDownMenu_SetWidth(dropDown3, 8)
--UIDropDownMenu_SetText(dropDown3, "Ammo")
UIDropDownMenu_Initialize(dropDown3, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    --ammoSlotTitles = {"ammo 1", "ammo 2", "ammo 3", "ammo 4", "ammo 5", "ammo 6", "ammo 7", "ammo 8", "ammo 9", "ammo 10"}
    info.func = self.SetValue
    info.text, info.arg1, info.checked = "Current selection: [" .. savedAmmoSlotItem .. "] (click here to reset)", "No Ammo", "No Ammo" == favoriteNumber3
    info.tooltipOnButton = true
    info.tooltipTitle = "Currently selected: [" .. savedAmmoSlotItem .. "]"
    info.tooltipText = "\nThis is the ammo you currently are saving along with your equipment sets.\n\nIf you want to save another type of ammo, please select one below.\n\nIMPORTANT: The ammo you will select will be remembered permanently (and used to save a set) until you change it again.\n\nNOTE: Seeing duplicates means you have multiple stacks of that certain ammo in your inventory. It doesn't matter which one you pick, what's important is the name.\n\nSelecting this will revert the saved ammo to \"No Ammo\"."
    UIDropDownMenu_AddButton(info)
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID and AmmoList[itemID] then
                info.func = self.SetValue
                local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(itemID);
                --print(("Found! [ID: %s] [Name: " .. sName .. "] [Stack count: ".. GetItemCount(itemID) .."] [bag ID: %s] [slot ID: %s]"):format(itemID, bag, slot))
                info.text, info.arg1, info.checked = sName, sName, sName == favoriteNumber3
                info.tooltipOnButton = true
                info.tooltipTitle = sName
                info.tooltipText = "\nSelect [".. sName .."] to be saved.\n\nIMPORTANT: The ammo you will select will be remembered permanently (and used to save a set) until you change it again.\n\nNOTE: Seeing duplicates means you have multiple stacks of that certain ammo in your inventory. It doesn't matter which one you pick, what's important is the name."
                UIDropDownMenu_AddButton(info)
            end
        end
    end
end)

function dropDown3:SetValue(newValue)
    favoriteNumber3 = newValue
    savedAmmoSlotItem = favoriteNumber3
    CloseDropDownMenus()
end