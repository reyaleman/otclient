-- @docclass Player
PlayerStates = {
    None = 0,
    Poison = 1,
    Burn = 2,
    Energy = 4,
    Drunk = 8,
    ManaShield = 16,
    Paralyze = 32,
    Haste = 64,
    Swords = 128,
    Drowning = 256,
    Freezing = 512,
    Dazzled = 1024,
    Cursed = 2048,
    PartyBuff = 4096,
    PzBlock = 8192,
    Pz = 16384,
    Bleeding = 32768,
    Hungry = 65536
}

Icons = {}
Icons[PlayerStates.Poison] = { tooltip = tr('You are poisoned'), path = '/images/game/states/poisoned', id = 'condition_poisoned' }
Icons[PlayerStates.Burn] = { tooltip = tr('You are burning'), path = '/images/game/states/burning', id = 'condition_burning' }
Icons[PlayerStates.Energy] = { tooltip = tr('You are electrified'), path = '/images/game/states/electrified', id = 'condition_electrified' }
Icons[PlayerStates.Drunk] = { tooltip = tr('You are drunk'), path = '/images/game/states/drunk', id = 'condition_drunk' }
Icons[PlayerStates.ManaShield] = { tooltip = tr('You are protected by a magic shield'), path = '/images/game/states/magic_shield', id = 'condition_magic_shield' }
Icons[PlayerStates.Paralyze] = { tooltip = tr('You are paralysed'), path = '/images/game/states/slowed', id = 'condition_slowed' }
Icons[PlayerStates.Haste] = { tooltip = tr('You are hasted'), path = '/images/game/states/haste', id = 'condition_haste' }
Icons[PlayerStates.Swords] = { tooltip = tr('You may not logout during a fight'), path = '/images/game/states/logout_block', id = 'condition_logout_block' }
Icons[PlayerStates.Drowning] = { tooltip = tr('You are drowning'), path = '/images/game/states/drowning', id = 'condition_drowning' }
Icons[PlayerStates.Freezing] = { tooltip = tr('You are freezing'), path = '/images/game/states/freezing', id = 'condition_freezing' }
Icons[PlayerStates.Dazzled] = { tooltip = tr('You are dazzled'), path = '/images/game/states/dazzled', id = 'condition_dazzled' }
Icons[PlayerStates.Cursed] = { tooltip = tr('You are cursed'), path = '/images/game/states/cursed', id = 'condition_cursed' }
Icons[PlayerStates.PartyBuff] = { tooltip = tr('You are strengthened'), path = '/images/game/states/strengthened', id = 'condition_strengthened' }
Icons[PlayerStates.PzBlock] = { tooltip = tr('You may not logout or enter a protection zone'), path = '/images/game/states/protection_zone_block', id = 'condition_protection_zone_block' }
Icons[PlayerStates.Pz] = { tooltip = tr('You are within a protection zone'), path = '/images/game/states/protection_zone', id = 'condition_protection_zone' }
Icons[PlayerStates.Bleeding] = { tooltip = tr('You are bleeding'), path = '/images/game/states/bleeding', id = 'condition_bleeding' }
Icons[PlayerStates.Hungry] = { tooltip = tr('You are hungry'), path = '/images/game/states/hungry', id = 'condition_hungry' }

InventorySlotOther = 0
InventorySlotHead = 1
InventorySlotNeck = 2
InventorySlotBack = 3
InventorySlotBody = 4
InventorySlotRight = 5
InventorySlotLeft = 6
InventorySlotLeg = 7
InventorySlotFeet = 8
InventorySlotFinger = 9
InventorySlotAmmo = 10
InventorySlotPurse = 11

InventorySlotFirst = 1
InventorySlotLast = 10

vocationNamesByClientId = {
    [0] = "No Vocation",
    [1] = "Knight",
    [2] = "Paladin",
    [3] = "Sorcerer",
    [4] = "Druid",
    [11]= "Elite Knight",
    [12] = "Royal Paladin",
    [13] = "Master Sorcerer",
    [14] = "Elder Druid"
}

function Player:isPartyLeader()
    local shield = self:getShield()
    return (shield == ShieldWhiteYellow or shield == ShieldYellow or shield == ShieldYellowSharedExp or shield ==
               ShieldYellowNoSharedExpBlink or shield == ShieldYellowNoSharedExp)
end

function Player:isPartyMember()
    local shield = self:getShield()
    return (shield == ShieldWhiteYellow or shield == ShieldYellow or shield == ShieldYellowSharedExp or shield ==
               ShieldYellowNoSharedExpBlink or shield == ShieldYellowNoSharedExp or shield == ShieldBlueSharedExp or
               shield == ShieldBlueNoSharedExpBlink or shield == ShieldBlueNoSharedExp or shield == ShieldBlue)
end

function Player:isPartySharedExperienceActive()
    local shield = self:getShield()
    return (shield == ShieldYellowSharedExp or shield == ShieldYellowNoSharedExpBlink or shield ==
               ShieldYellowNoSharedExp or shield == ShieldBlueSharedExp or shield == ShieldBlueNoSharedExpBlink or
               shield == ShieldBlueNoSharedExp)
end

function Player:hasVip(creatureName)
    for id, vip in pairs(g_game.getVips()) do
        if (vip[1] == creatureName) then
            return true
        end
    end
    return false
end

function Player:isMounted()
    local outfit = self:getOutfit()
    return outfit.mount ~= nil and outfit.mount > 0
end

function Player:toggleMount()
    if g_game.getFeature(GamePlayerMounts) then
        g_game.mount(not self:isMounted())
    end
end

function Player:mount()
    if g_game.getFeature(GamePlayerMounts) then
        g_game.mount(true)
    end
end

function Player:dismount()
    if g_game.getFeature(GamePlayerMounts) then
        g_game.mount(false)
    end
end

function Player:getItem(itemId, subType)
    return g_game.findPlayerItem(itemId, subType or -1)
end

function Player:getItems(itemId, subType)
    local subType = subType or -1

    local items = {}
    for i = InventorySlotFirst, InventorySlotLast do
        local item = self:getInventoryItem(i)
        if item and item:getId() == itemId and (subType == -1 or item:getSubType() == subType) then
            table.insert(items, item)
        end
    end

    for i, container in pairs(g_game.getContainers()) do
        for j, item in pairs(container:getItems()) do
            if item:getId() == itemId and (subType == -1 or item:getSubType() == subType) then
                item.container = container
                table.insert(items, item)
            end
        end
    end
    return items
end

function Player:getItemsCount(itemId)
    local items, count = self:getItems(itemId), 0
    for i = 1, #items do
        count = count + items[i]:getCount()
    end
    return count
end

function Player:hasState(state, states)
    if not states then
        states = self:getStates()
    end

    for i = 1, 32 do
        local pow = math.pow(2, i - 1)
        if pow > states then
            break
        end

        local states = bit.band(states, pow)
        if states == state then
            return true
        end
    end
    return false
end

function Player:getVocationNameByClientId()
    return vocationNamesByClientId[self:getVocation()] or "Unknown Vocation"
end
