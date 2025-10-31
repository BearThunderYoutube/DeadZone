--[[
    InventorySystem.lua
    Manages player inventory, weight, and item management
]]

local InventorySystem = {}
InventorySystem.__index = InventorySystem

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameSettings = require(script.Parent.GameSettings)

-- Item definitions
local ItemDatabase = {
    -- Weapons
    ["AK47"] = {
        Type = "Weapon",
        Weight = 3.5,
        Rarity = "Uncommon",
        Damage = 35,
        FireRate = 600,
        MagazineSize = 30,
        Ammo = "7.62x39mm"
    },
    ["M4A1"] = {
        Type = "Weapon",
        Weight = 3.2,
        Rarity = "Rare",
        Damage = 32,
        FireRate = 750,
        MagazineSize = 30,
        Ammo = "5.56x45mm"
    },
    ["Glock19"] = {
        Type = "Weapon",
        Weight = 0.9,
        Rarity = "Common",
        Damage = 22,
        FireRate = 400,
        MagazineSize = 17,
        Ammo = "9mm"
    },

    -- Ammo
    ["7.62x39mm"] = {
        Type = "Ammo",
        Weight = 0.016,
        Rarity = "Common",
        StackSize = 60
    },
    ["5.56x45mm"] = {
        Type = "Ammo",
        Weight = 0.012,
        Rarity = "Common",
        StackSize = 60
    },
    ["9mm"] = {
        Type = "Ammo",
        Weight = 0.008,
        Rarity = "Common",
        StackSize = 50
    },

    -- Medical
    ["Bandage"] = {
        Type = "Medical",
        Weight = 0.1,
        Rarity = "Common",
        HealAmount = 15,
        UseTime = 3
    },
    ["Medkit"] = {
        Type = "Medical",
        Weight = 0.5,
        Rarity = "Rare",
        HealAmount = 50,
        UseTime = 5
    },
    ["Painkillers"] = {
        Type = "Medical",
        Weight = 0.05,
        Rarity = "Uncommon",
        Effect = "PainRelief",
        Duration = 120
    },

    -- Food & Water
    ["WaterBottle"] = {
        Type = "Consumable",
        Weight = 0.5,
        Rarity = "Common",
        ThirstRestore = 40
    },
    ["CannedFood"] = {
        Type = "Consumable",
        Weight = 0.4,
        Rarity = "Common",
        HungerRestore = 35
    },
    ["EnergyDrink"] = {
        Type = "Consumable",
        Weight = 0.3,
        Rarity = "Uncommon",
        ThirstRestore = 25,
        StaminaBoost = 20
    },

    -- Equipment
    ["Backpack"] = {
        Type = "Equipment",
        Weight = 1.5,
        Rarity = "Uncommon",
        BonusSlots = 8
    },
    ["ArmorVest"] = {
        Type = "Equipment",
        Weight = 5.0,
        Rarity = "Rare",
        ArmorValue = 50
    }
}

function InventorySystem.new(player)
    local self = setmetatable({}, InventorySystem)

    self.Player = player
    self.Items = {}
    self.MaxSlots = GameSettings.Inventory.MaxSlots
    self.MaxWeight = GameSettings.Inventory.MaxWeight
    self.CurrentWeight = 0
    self.EquippedWeapon = nil
    self.EquippedArmor = nil

    return self
end

function InventorySystem:AddItem(itemName, quantity)
    quantity = quantity or 1

    local itemData = ItemDatabase[itemName]
    if not itemData then
        warn("Item not found:", itemName)
        return false
    end

    -- Check weight
    local totalWeight = itemData.Weight * quantity
    if self.CurrentWeight + totalWeight > self.MaxWeight then
        warn("Inventory too heavy!")
        return false
    end

    -- Check if item exists and is stackable
    if itemData.StackSize then
        for i, item in ipairs(self.Items) do
            if item.Name == itemName and item.Quantity < itemData.StackSize then
                local spaceLeft = itemData.StackSize - item.Quantity
                local toAdd = math.min(quantity, spaceLeft)
                item.Quantity = item.Quantity + toAdd
                self.CurrentWeight = self.CurrentWeight + (itemData.Weight * toAdd)
                quantity = quantity - toAdd

                if quantity <= 0 then
                    return true
                end
            end
        end
    end

    -- Check slots
    if #self.Items >= self.MaxSlots then
        warn("Inventory full!")
        return false
    end

    -- Add new item
    table.insert(self.Items, {
        Name = itemName,
        Data = itemData,
        Quantity = quantity
    })

    self.CurrentWeight = self.CurrentWeight + totalWeight
    return true
end

function InventorySystem:RemoveItem(itemName, quantity)
    quantity = quantity or 1

    for i = #self.Items, 1, -1 do
        local item = self.Items[i]
        if item.Name == itemName then
            if item.Quantity <= quantity then
                self.CurrentWeight = self.CurrentWeight - (item.Data.Weight * item.Quantity)
                table.remove(self.Items, i)
                quantity = quantity - item.Quantity
            else
                item.Quantity = item.Quantity - quantity
                self.CurrentWeight = self.CurrentWeight - (item.Data.Weight * quantity)
                quantity = 0
            end

            if quantity <= 0 then
                return true
            end
        end
    end

    return quantity == 0
end

function InventorySystem:GetItem(itemName)
    for _, item in ipairs(self.Items) do
        if item.Name == itemName then
            return item
        end
    end
    return nil
end

function InventorySystem:UseItem(itemName)
    local item = self:GetItem(itemName)
    if not item then return false end

    if item.Data.Type == "Medical" then
        -- Heal player
        return true
    elseif item.Data.Type == "Consumable" then
        -- Restore hunger/thirst
        return true
    end

    return false
end

function InventorySystem:GetInventoryData()
    return {
        Items = self.Items,
        CurrentWeight = self.CurrentWeight,
        MaxWeight = self.MaxWeight,
        MaxSlots = self.MaxSlots
    }
end

InventorySystem.ItemDatabase = ItemDatabase

return InventorySystem
