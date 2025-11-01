--[[
    EquipmentSystem.lua
    Manages player equipment: backpacks, armor, helmets, rigs
]]

local EquipmentSystem = {}
EquipmentSystem.__index = EquipmentSystem

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Equipment Database
local EquipmentDatabase = {
    -- Backpacks
    ["ScoutBackpack"] = {
        Type = "Backpack",
        Weight = 1.0,
        Rarity = "Common",
        BonusSlots = 6,
        MaxWeight = 15,
        MovementPenalty = 0,
        Price = 500,
        Description = "Small backpack for light raids"
    },
    ["AssaultBackpack"] = {
        Type = "Backpack",
        Weight = 2.5,
        Rarity = "Uncommon",
        BonusSlots = 12,
        MaxWeight = 30,
        MovementPenalty = 0.05,
        Price = 1500,
        Description = "Standard military backpack"
    },
    ["TacticalBackpack"] = {
        Type = "Backpack",
        Weight = 3.5,
        Rarity = "Rare",
        BonusSlots = 18,
        MaxWeight = 45,
        MovementPenalty = 0.08,
        Price = 3500,
        Description = "Large tactical backpack with MOLLE"
    },
    ["MountainBackpack"] = {
        Type = "Backpack",
        Weight = 5.0,
        Rarity = "Epic",
        BonusSlots = 25,
        MaxWeight = 65,
        MovementPenalty = 0.12,
        Price = 7500,
        Description = "Massive hiking backpack for heavy loot"
    },

    -- Armor Vests
    ["LightVest"] = {
        Type = "ArmorVest",
        Weight = 3.0,
        Rarity = "Common",
        ArmorValue = 25,
        Durability = 40,
        MovementPenalty = 0.03,
        Price = 800,
        Protection = {
            Thorax = 0.25,
            Stomach = 0.20
        },
        Description = "Light protection vest"
    },
    ["TacticalVest"] = {
        Type = "ArmorVest",
        Weight = 5.5,
        Rarity = "Uncommon",
        ArmorValue = 40,
        Durability = 60,
        MovementPenalty = 0.06,
        Price = 2000,
        Protection = {
            Thorax = 0.40,
            Stomach = 0.35
        },
        Description = "Military grade tactical vest"
    },
    ["PlateCarrier"] = {
        Type = "ArmorVest",
        Weight = 8.0,
        Rarity = "Rare",
        ArmorValue = 60,
        Durability = 80,
        MovementPenalty = 0.10,
        Price = 5000,
        Protection = {
            Thorax = 0.60,
            Stomach = 0.50
        },
        Description = "Heavy plate carrier with ceramic plates"
    },
    ["JuggernautArmor"] = {
        Type = "ArmorVest",
        Weight = 12.0,
        Rarity = "Legendary",
        ArmorValue = 85,
        Durability = 120,
        MovementPenalty = 0.18,
        Price = 15000,
        Protection = {
            Thorax = 0.85,
            Stomach = 0.70,
            Arms = 0.40
        },
        Description = "Ultra-heavy military armor"
    },

    -- Helmets
    ["BaseballCap"] = {
        Type = "Helmet",
        Weight = 0.2,
        Rarity = "Common",
        ArmorValue = 5,
        Price = 100,
        Protection = {
            Head = 0.05
        },
        Description = "Provides minimal protection"
    },
    ["TacticalHelmet"] = {
        Type = "Helmet",
        Weight = 1.5,
        Rarity = "Uncommon",
        ArmorValue = 30,
        Durability = 40,
        Price = 1200,
        Protection = {
            Head = 0.30
        },
        Description = "Ballistic helmet"
    },
    ["CombatHelmet"] = {
        Type = "Helmet",
        Weight = 2.2,
        Rarity = "Rare",
        ArmorValue = 50,
        Durability = 60,
        Price = 3500,
        Protection = {
            Head = 0.50
        },
        Description = "Heavy combat helmet with face shield"
    },

    -- Tactical Rigs
    ["ChestRig"] = {
        Type = "TacticalRig",
        Weight = 1.5,
        Rarity = "Uncommon",
        BonusSlots = 6,
        Price = 600,
        Description = "Chest rig with magazine pouches"
    },
    ["MilitaryRig"] = {
        Type = "TacticalRig",
        Weight = 2.5,
        Rarity = "Rare",
        BonusSlots = 10,
        Price = 1800,
        Description = "Full military tactical rig"
    }
}

function EquipmentSystem.new(player)
    local self = setmetatable({}, EquipmentSystem)

    self.Player = player
    self.EquippedItems = {
        Backpack = nil,
        ArmorVest = nil,
        Helmet = nil,
        TacticalRig = nil
    }
    self.TotalWeight = 0
    self.TotalMovementPenalty = 0
    self.TotalBonusSlots = 0
    self.TotalMaxWeight = 0

    return self
end

function EquipmentSystem:EquipItem(itemName)
    local itemData = EquipmentDatabase[itemName]
    if not itemData then
        warn("Equipment not found:", itemName)
        return false
    end

    -- Unequip current item in slot if exists
    if self.EquippedItems[itemData.Type] then
        self:UnequipItem(itemData.Type)
    end

    -- Equip new item
    self.EquippedItems[itemData.Type] = {
        Name = itemName,
        Data = itemData,
        CurrentDurability = itemData.Durability or 100
    }

    self:RecalculateStats()
    return true
end

function EquipmentSystem:UnequipItem(slotType)
    if not self.EquippedItems[slotType] then
        return false
    end

    local item = self.EquippedItems[slotType]
    self.EquippedItems[slotType] = nil

    self:RecalculateStats()
    return item
end

function EquipmentSystem:RecalculateStats()
    self.TotalWeight = 0
    self.TotalMovementPenalty = 0
    self.TotalBonusSlots = 0
    self.TotalMaxWeight = 0

    for slotType, item in pairs(self.EquippedItems) do
        if item then
            self.TotalWeight = self.TotalWeight + item.Data.Weight

            if item.Data.MovementPenalty then
                self.TotalMovementPenalty = self.TotalMovementPenalty + item.Data.MovementPenalty
            end

            if item.Data.BonusSlots then
                self.TotalBonusSlots = self.TotalBonusSlots + item.Data.BonusSlots
            end

            if item.Data.MaxWeight then
                self.TotalMaxWeight = self.TotalMaxWeight + item.Data.MaxWeight
            end
        end
    end

    -- Apply movement penalty to player
    if self.Player.Character then
        local humanoid = self.Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local baseSpeed = require(ReplicatedStorage.Modules.GameSettings).Player.WalkSpeed
            humanoid.WalkSpeed = baseSpeed * (1 - self.TotalMovementPenalty)
        end
    end
end

function EquipmentSystem:GetProtection(bodyPart)
    local totalProtection = 0

    for slotType, item in pairs(self.EquippedItems) do
        if item and item.Data.Protection and item.Data.Protection[bodyPart] then
            totalProtection = totalProtection + item.Data.Protection[bodyPart]
        end
    end

    return math.min(totalProtection, 0.95) -- Cap at 95% protection
end

function EquipmentSystem:DamageArmor(bodyPart, damage)
    -- Find armor protecting this body part
    for slotType, item in pairs(self.EquippedItems) do
        if item and item.Data.Protection and item.Data.Protection[bodyPart] then
            if item.CurrentDurability then
                item.CurrentDurability = math.max(0, item.CurrentDurability - (damage * 0.5))

                if item.CurrentDurability <= 0 then
                    warn(item.Name .. " is broken!")
                    -- Reduce protection when broken
                    item.Data.Protection[bodyPart] = item.Data.Protection[bodyPart] * 0.1
                end
            end
        end
    end
end

function EquipmentSystem:GetEquipmentData()
    return {
        Equipped = self.EquippedItems,
        TotalWeight = self.TotalWeight,
        TotalMovementPenalty = self.TotalMovementPenalty,
        TotalBonusSlots = self.TotalBonusSlots,
        TotalMaxWeight = self.TotalMaxWeight
    }
end

function EquipmentSystem:GetAvailableBackpackSpace()
    return self.TotalBonusSlots
end

function EquipmentSystem:GetAvailableWeight()
    return self.TotalMaxWeight
end

EquipmentSystem.EquipmentDatabase = EquipmentDatabase

return EquipmentSystem
