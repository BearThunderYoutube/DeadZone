--[[
    LootSystem.lua
    Manages loot spawning, containers, and item drops
]]

local LootSystem = {}
LootSystem.LootContainers = {}
LootSystem.LootPoints = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local InventorySystem = require(ReplicatedStorage.Modules.InventorySystem)
local EquipmentSystem = require(ReplicatedStorage.Modules.EquipmentSystem)

-- Loot tables by location type
local LootTables = {
    Residential = {
        ["WaterBottle"] = 15,
        ["CannedFood"] = 15,
        ["Bandage"] = 10,
        ["Painkillers"] = 5,
        ["BaseballCap"] = 5,
        ["ScoutBackpack"] = 3,
        ["Glock19"] = 2,
        ["9mm"] = 8
    },
    Military = {
        ["AK47"] = 8,
        ["M4A1"] = 6,
        ["5.56x45mm"] = 12,
        ["7.62x39mm"] = 12,
        ["Medkit"] = 8,
        ["TacticalHelmet"] = 5,
        ["TacticalVest"] = 5,
        ["AssaultBackpack"] = 4,
        ["TacticalBackpack"] = 2,
        ["Painkillers"] = 6
    },
    Medical = {
        ["Bandage"] = 20,
        ["Medkit"] = 15,
        ["Painkillers"] = 12,
        ["EnergyDrink"] = 8,
        ["Antibiotics"] = 5,
        ["Defibrillator"] = 2
    },
    Industrial = {
        ["Wrench"] = 10,
        ["Screwdriver"] = 10,
        ["DuctTape"] = 8,
        ["ScrapMetal"] = 15,
        ["Electronics"] = 6,
        ["ChestRig"] = 4,
        ["GasMask"] = 3
    },
    Police = {
        ["Glock19"] = 15,
        ["9mm"] = 20,
        ["Shotgun"] = 8,
        ["Buckshot"] = 12,
        ["LightVest"] = 10,
        ["TacticalHelmet"] = 6,
        ["Handcuffs"] = 5
    },
    Rare = {
        ["M4A1"] = 10,
        ["SVD"] = 5,
        ["PlateCarrier"] = 8,
        ["CombatHelmet"] = 8,
        ["TacticalBackpack"] = 10,
        ["MountainBackpack"] = 4,
        ["NightVision"] = 3,
        ["ThermalScope"] = 2
    }
}

-- Container class
local LootContainer = {}
LootContainer.__index = LootContainer

function LootContainer.new(position, containerType, size)
    local self = setmetatable({}, LootContainer)

    self.Position = position
    self.Type = containerType or "Generic"
    self.Size = size or "Medium" -- Small, Medium, Large
    self.Contents = {}
    self.IsLooted = false
    self.RespawnTime = 300 -- 5 minutes
    self.LastLootTime = 0

    -- Create physical container
    self:CreateContainer()
    self:GenerateLoot()

    return self
end

function LootContainer:CreateContainer()
    local container = Instance.new("Part")
    container.Name = "LootContainer_" .. self.Type
    container.Size = Vector3.new(3, 2, 2)
    container.Position = self.Position
    container.Anchored = true
    container.BrickColor = BrickColor.new("Dark stone grey")
    container.Material = Enum.Material.Metal

    -- Add label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = false
    billboard.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = self.Type .. " Container"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Parent = billboard

    -- Add click detector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 8
    clickDetector.Parent = container

    clickDetector.MouseClick:Connect(function(player)
        self:OnLoot(player)
    end)

    container.Parent = workspace:FindFirstChild("Loot") or workspace
    self.Part = container
end

function LootContainer:GenerateLoot()
    self.Contents = {}

    local lootTable = LootTables[self.Type] or LootTables.Residential
    local itemCount = math.random(2, 6)

    -- Size modifiers
    local sizeMultiplier = 1
    if self.Size == "Small" then
        sizeMultiplier = 0.6
    elseif self.Size == "Large" then
        sizeMultiplier = 1.5
    end

    itemCount = math.floor(itemCount * sizeMultiplier)

    -- Generate items
    for i = 1, itemCount do
        local selectedItem = self:RollLoot(lootTable)
        if selectedItem then
            -- Get item data
            local itemData = InventorySystem.ItemDatabase[selectedItem] or
                            EquipmentSystem.EquipmentDatabase[selectedItem]

            if itemData then
                local quantity = 1
                if itemData.StackSize then
                    quantity = math.random(1, math.min(10, itemData.StackSize))
                end

                table.insert(self.Contents, {
                    Name = selectedItem,
                    Quantity = quantity
                })
            end
        end
    end

    self.IsLooted = false
end

function LootContainer:RollLoot(lootTable)
    local totalWeight = 0
    for item, weight in pairs(lootTable) do
        totalWeight = totalWeight + weight
    end

    local roll = math.random() * totalWeight

    local currentWeight = 0
    for item, weight in pairs(lootTable) do
        currentWeight = currentWeight + weight
        if roll <= currentWeight then
            return item
        end
    end

    return nil
end

function LootContainer:OnLoot(player)
    if self.IsLooted then
        warn("Container already looted!")
        return
    end

    -- Send contents to player
    local event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowLootContainer")
    if event then
        event:FireClient(player, self.Contents, self.Position)
    end

    print(player.Name .. " opened " .. self.Type .. " container")
end

function LootContainer:TakeItem(itemIndex, player)
    if itemIndex <= #self.Contents then
        local item = table.remove(self.Contents, itemIndex)

        if #self.Contents == 0 then
            self.IsLooted = true
            self.LastLootTime = tick()

            -- Change container appearance
            if self.Part then
                self.Part.BrickColor = BrickColor.new("Really black")
            end

            -- Schedule respawn
            task.delay(self.RespawnTime, function()
                self:GenerateLoot()
                if self.Part then
                    self.Part.BrickColor = BrickColor.new("Dark stone grey")
                end
            end)
        end

        return item
    end

    return nil
end

-- Main system functions
function LootSystem:Initialize()
    -- Create loot folder
    if not workspace:FindFirstChild("Loot") then
        local lootFolder = Instance.new("Folder")
        lootFolder.Name = "Loot"
        lootFolder.Parent = workspace
    end

    -- Spawn initial containers
    self:SpawnContainersInMap()

    print("LootSystem initialized")
end

function LootSystem:SpawnContainersInMap()
    -- Spawn containers at predefined locations
    local containerLocations = {
        {Position = Vector3.new(50, 5, 50), Type = "Residential", Size = "Medium"},
        {Position = Vector3.new(-50, 5, 50), Type = "Military", Size = "Large"},
        {Position = Vector3.new(50, 5, -50), Type = "Medical", Size = "Medium"},
        {Position = Vector3.new(-50, 5, -50), Type = "Industrial", Size = "Large"},
        {Position = Vector3.new(0, 5, 75), Type = "Police", Size = "Medium"},
        {Position = Vector3.new(75, 5, 0), Type = "Rare", Size = "Small"},
        {Position = Vector3.new(-75, 5, 0), Type = "Residential", Size = "Small"},
        {Position = Vector3.new(0, 5, -75), Type = "Military", Size = "Medium"},
    }

    for _, location in pairs(containerLocations) do
        local container = LootContainer.new(
            location.Position,
            location.Type,
            location.Size
        )
        table.insert(self.LootContainers, container)
    end

    print("Spawned " .. #self.LootContainers .. " loot containers")
end

function LootSystem:CreateWorldDrop(position, itemName, quantity)
    local lootDrop = Instance.new("Part")
    lootDrop.Name = "LootDrop"
    lootDrop.Size = Vector3.new(1.5, 0.5, 1.5)
    lootDrop.Position = position + Vector3.new(0, 1, 0)
    lootDrop.Anchored = true
    lootDrop.BrickColor = BrickColor.new("Bright yellow")
    lootDrop.Material = Enum.Material.Neon
    lootDrop:SetAttribute("ItemName", itemName)
    lootDrop:SetAttribute("Quantity", quantity or 1)

    -- Add click detector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 5
    clickDetector.Parent = lootDrop

    clickDetector.MouseClick:Connect(function(player)
        self:PickupWorldDrop(player, lootDrop)
    end)

    lootDrop.Parent = workspace:FindFirstChild("Loot") or workspace

    -- Auto-despawn after 5 minutes
    task.delay(300, function()
        if lootDrop.Parent then
            lootDrop:Destroy()
        end
    end)

    return lootDrop
end

function LootSystem:PickupWorldDrop(player, lootDrop)
    local itemName = lootDrop:GetAttribute("ItemName")
    local quantity = lootDrop:GetAttribute("Quantity") or 1

    -- Fire event to add to player inventory
    local event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PickupItem")
    if event then
        event:FireClient(player, itemName, quantity)
    end

    lootDrop:Destroy()
end

function LootSystem:GetContainer(position)
    for _, container in pairs(self.LootContainers) do
        if (container.Position - position).Magnitude < 5 then
            return container
        end
    end
    return nil
end

return LootSystem
