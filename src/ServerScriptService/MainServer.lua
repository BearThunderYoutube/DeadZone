--[[
    MainServer.lua
    Main server initialization script
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

print("=== DeadZone Server Starting ===")

-- Load modules
local GameSettings = require(ReplicatedStorage.Modules.GameSettings)
local InventorySystem = require(ReplicatedStorage.Modules.InventorySystem)
local SurvivalSystem = require(ReplicatedStorage.Modules.SurvivalSystem)

local AISystem = require(ServerScriptService.AISystem)
local ExtractionSystem = require(ServerScriptService.ExtractionSystem)
local DataService = require(ServerScriptService.DataService)

-- Player systems
local PlayerSystems = {}

-- Create remote events folder
local eventsFolder = Instance.new("Folder")
eventsFolder.Name = "Events"
eventsFolder.Parent = ReplicatedStorage

-- Create events
local function createEvent(name)
    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = eventsFolder
    return event
end

local events = {
    OnAim = createEvent("OnAim"),
    UpdateStamina = createEvent("UpdateStamina"),
    RequestInventory = createEvent("RequestInventory"),
    UseItem = createEvent("UseItem"),
    DropItem = createEvent("DropItem"),
    ExtractionStarted = createEvent("ExtractionStarted"),
    ExtractionCancelled = createEvent("ExtractionCancelled"),
    ExtractionComplete = createEvent("ExtractionComplete"),
    LevelUp = createEvent("LevelUp"),
    UpdateHealth = createEvent("UpdateHealth"),
    UpdateSurvival = createEvent("UpdateSurvival"),
    UpdateWeapon = createEvent("UpdateWeapon"),
    UpdateStatusEffects = createEvent("UpdateStatusEffects")
}

-- Initialize systems
DataService:Initialize()
AISystem:Initialize()
ExtractionSystem:Initialize()

print("Core systems initialized")

-- Player joined
Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " joined the game")

    -- Create player systems
    local playerData = {
        Inventory = InventorySystem.new(player),
        Survival = SurvivalSystem.new(player),
        Data = DataService:LoadPlayerData(player)
    }

    PlayerSystems[player] = playerData

    -- Give starter items
    playerData.Inventory:AddItem("Bandage", 2)
    playerData.Inventory:AddItem("WaterBottle", 1)
    playerData.Inventory:AddItem("Glock19", 1)
    playerData.Inventory:AddItem("9mm", 30)

    -- Character setup
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")

        -- Set initial values
        humanoid.MaxHealth = GameSettings.Player.MaxHealth
        humanoid.Health = GameSettings.Player.MaxHealth
        humanoid.WalkSpeed = GameSettings.Player.WalkSpeed

        -- Update loop for this player
        task.spawn(function()
            while character.Parent do
                local dt = task.wait(1)

                if PlayerSystems[player] then
                    -- Update survival
                    PlayerSystems[player].Survival:Update(dt)

                    -- Send updates to client
                    local survivalData = PlayerSystems[player].Survival:GetSurvivalData()
                    events.UpdateHealth:FireClient(player, survivalData.Health, survivalData.MaxHealth)
                    events.UpdateSurvival:FireClient(player,
                        survivalData.Hunger, survivalData.Thirst,
                        survivalData.MaxHunger, survivalData.MaxThirst)
                    events.UpdateStatusEffects:FireClient(player, survivalData.StatusEffects)
                end
            end
        end)
    end)
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
    print(player.Name .. " left the game")

    if PlayerSystems[player] then
        PlayerSystems[player] = nil
    end
end)

-- Event handlers
events.RequestInventory.OnServerEvent:Connect(function(player)
    if PlayerSystems[player] then
        local inventoryData = PlayerSystems[player].Inventory:GetInventoryData()
        events.RequestInventory:FireClient(player, inventoryData)
    end
end)

events.UseItem.OnServerEvent:Connect(function(player, itemName, itemIndex)
    if PlayerSystems[player] then
        local item = PlayerSystems[player].Inventory:GetItem(itemName)

        if item then
            if item.Data.Type == "Medical" then
                PlayerSystems[player].Survival:UseMedical(itemName, item.Data)
                PlayerSystems[player].Inventory:RemoveItem(itemName, 1)
            elseif item.Data.Type == "Consumable" then
                if item.Data.HungerRestore then
                    PlayerSystems[player].Survival:EatFood(item.Data.HungerRestore)
                end
                if item.Data.ThirstRestore then
                    PlayerSystems[player].Survival:DrinkWater(item.Data.ThirstRestore)
                end
                PlayerSystems[player].Inventory:RemoveItem(itemName, 1)
            elseif item.Data.Type == "Weapon" then
                -- Equip weapon logic here
                print(player.Name .. " equipped " .. itemName)
            end

            -- Send updated inventory
            local inventoryData = PlayerSystems[player].Inventory:GetInventoryData()
            events.RequestInventory:FireClient(player, inventoryData)
        end
    end
end)

events.DropItem.OnServerEvent:Connect(function(player, itemName, itemIndex)
    if PlayerSystems[player] then
        local item = PlayerSystems[player].Inventory:GetItem(itemName)

        if item and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Create loot drop in world
            local lootDrop = Instance.new("Part")
            lootDrop.Name = "LootDrop"
            lootDrop.Size = Vector3.new(2, 0.5, 2)
            lootDrop.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
            lootDrop.Anchored = true
            lootDrop.Parent = workspace:FindFirstChild("Loot") or workspace
            lootDrop:SetAttribute("ItemName", itemName)
            lootDrop:SetAttribute("Quantity", 1)

            -- Remove from inventory
            PlayerSystems[player].Inventory:RemoveItem(itemName, 1)

            -- Send updated inventory
            local inventoryData = PlayerSystems[player].Inventory:GetInventoryData()
            events.RequestInventory:FireClient(player, inventoryData)
        end
    end
end)

print("=== DeadZone Server Ready ===")
