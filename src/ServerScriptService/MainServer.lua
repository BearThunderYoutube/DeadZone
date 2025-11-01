--[[
    MainServer.lua
    Main server initialization script - UPDATED with all systems
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

print("=== DeadZone Server Starting ===")

-- Load modules
local GameSettings = require(ReplicatedStorage.Modules.GameSettings)
local InventorySystem = require(ReplicatedStorage.Modules.InventorySystem)
local SurvivalSystem = require(ReplicatedStorage.Modules.SurvivalSystem)
local EquipmentSystem = require(ReplicatedStorage.Modules.EquipmentSystem)
local SkillSystem = require(ReplicatedStorage.Modules.SkillSystem)

local AISystem = require(ServerScriptService.AISystem)
local ExtractionSystem = require(ServerScriptService.ExtractionSystem)
local DataService = require(ServerScriptService.DataService)
local LootSystem = require(ServerScriptService.LootSystem)
local TradingSystem = require(ServerScriptService.TradingSystem)
local SessionSystem = require(ServerScriptService.SessionSystem)

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
    -- Player
    OnAim = createEvent("OnAim"),
    UpdateStamina = createEvent("UpdateStamina"),

    -- Inventory
    RequestInventory = createEvent("RequestInventory"),
    UseItem = createEvent("UseItem"),
    DropItem = createEvent("DropItem"),
    PickupItem = createEvent("PickupItem"),

    -- Equipment
    EquipItem = createEvent("EquipItem"),
    UnequipItem = createEvent("UnequipItem"),

    -- Extraction
    ExtractionStarted = createEvent("ExtractionStarted"),
    ExtractionCancelled = createEvent("ExtractionCancelled"),
    ExtractionComplete = createEvent("ExtractionComplete"),

    -- Progression
    LevelUp = createEvent("LevelUp"),
    SkillUp = createEvent("SkillUp"),

    -- UI Updates
    UpdateHealth = createEvent("UpdateHealth"),
    UpdateSurvival = createEvent("UpdateSurvival"),
    UpdateWeapon = createEvent("UpdateWeapon"),
    UpdateStatusEffects = createEvent("UpdateStatusEffects"),
    UpdateRaidTimer = createEvent("UpdateRaidTimer"),

    -- Loot
    ShowLootContainer = createEvent("ShowLootContainer"),
    LootItem = createEvent("LootItem"),

    -- Trading
    OpenVendor = createEvent("OpenVendor"),
    BuyItem = createEvent("BuyItem"),
    SellItem = createEvent("SellItem"),

    -- Session (Open World)
    SessionStarted = createEvent("SessionStarted"),
    Respawn = createEvent("Respawn"),

    -- Effects
    ShowHitMarker = createEvent("ShowHitMarker"),
    ScreenShake = createEvent("ScreenShake"),

    -- Settings
    SaveSettings = createEvent("SaveSettings"),
    LoadSettings = createEvent("LoadSettings")
}

-- Initialize systems
DataService:Initialize()
AISystem:Initialize()
ExtractionSystem:Initialize()
LootSystem:Initialize()
TradingSystem:Initialize()
SessionSystem:Initialize()

print("All systems initialized - Open World Mode")

-- Player joined
Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " joined the game")

    -- Load player data first
    local playerData = DataService:LoadPlayerData(player)

    -- Create player systems
    local playerSystems = {
        Inventory = InventorySystem.new(player),
        Equipment = EquipmentSystem.new(player),
        Survival = SurvivalSystem.new(player),
        Skills = SkillSystem.new(playerData),
        Data = playerData
    }

    PlayerSystems[player] = playerSystems

    -- Give starter items (only for new players)
    if not playerData.HasPlayedBefore then
        playerSystems.Inventory:AddItem("Bandage", 2)
        playerSystems.Inventory:AddItem("WaterBottle", 1)
        playerSystems.Inventory:AddItem("CannedFood", 1)
        playerSystems.Inventory:AddItem("Glock19", 1)
        playerSystems.Inventory:AddItem("9mm", 30)
        playerSystems.Inventory:AddItem("ScoutBackpack", 1)

        playerData.HasPlayedBefore = true
        playerData.Money = 1000
    end

    -- Start open world session
    SessionSystem:StartSession(player, playerData)

    -- Character setup
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")

        -- Apply skill bonuses
        local bonuses = playerSystems.Skills:GetAllBonuses()
        local maxHealth = GameSettings.Player.MaxHealth + (bonuses.Vitality and bonuses.Vitality.MaxHealth or 0)

        humanoid.MaxHealth = maxHealth
        humanoid.Health = maxHealth
        humanoid.WalkSpeed = GameSettings.Player.WalkSpeed

        -- Update loop for this player
        task.spawn(function()
            local lastSprinting = false
            local lastPosition = character.HumanoidRootPart.Position

            while character.Parent do
                local dt = task.wait(1)

                if PlayerSystems[player] then
                    -- Update survival
                    PlayerSystems[player].Survival:Update(dt)

                    -- Track sprinting for skills
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.WalkSpeed > GameSettings.Player.WalkSpeed then
                        if not lastSprinting then
                            lastSprinting = true
                        end

                        -- Calculate distance traveled
                        local currentPos = character.HumanoidRootPart.Position
                        local distance = (currentPos - lastPosition).Magnitude
                        PlayerSystems[player].Skills:OnSprint(distance)
                        lastPosition = currentPos
                    else
                        lastSprinting = false
                        lastPosition = character.HumanoidRootPart.Position
                    end

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

        -- Death handler
        humanoid.Died:Connect(function()
            -- Update statistics
            if playerData then
                DataService:UpdatePlayerStat(player, "KilledInAction", 1)
            end

            -- Handle death penalty
            SessionSystem:OnPlayerDeath(player, playerData)

            -- Drop all items (no keep on death in open world)
            if character:FindFirstChild("HumanoidRootPart") then
                local dropPosition = character.HumanoidRootPart.Position

                -- Drop all inventory items
                for _, item in pairs(PlayerSystems[player].Inventory.Items) do
                    LootSystem:CreateWorldDrop(dropPosition, item.Name, item.Quantity)
                end

                -- Clear inventory
                PlayerSystems[player].Inventory.Items = {}
            end

            -- Respawn player after delay
            task.wait(5)
            if player and player.Parent then
                player:LoadCharacter()
            end
        end)
    end)
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
    print(player.Name .. " left the game")

    -- End session
    SessionSystem:EndSession(player, "Disconnect")

    if PlayerSystems[player] then
        PlayerSystems[player] = nil
    end
end)

-- Inventory event handlers
events.RequestInventory.OnServerEvent:Connect(function(player)
    if PlayerSystems[player] then
        local inventoryData = PlayerSystems[player].Inventory:GetInventoryData()
        local equipmentData = PlayerSystems[player].Equipment:GetEquipmentData()

        -- Merge data
        inventoryData.Equipment = equipmentData

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
                PlayerSystems[player].Skills:OnEatDrink()
            elseif item.Data.Type == "Consumable" then
                if item.Data.HungerRestore then
                    PlayerSystems[player].Survival:EatFood(item.Data.HungerRestore)
                end
                if item.Data.ThirstRestore then
                    PlayerSystems[player].Survival:DrinkWater(item.Data.ThirstRestore)
                end
                PlayerSystems[player].Inventory:RemoveItem(itemName, 1)
                PlayerSystems[player].Skills:OnEatDrink()
            elseif item.Data.Type == "Weapon" then
                print(player.Name .. " equipped " .. itemName)
                -- Weapon equip logic would go here
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
            -- Use LootSystem to create drop
            LootSystem:CreateWorldDrop(
                player.Character.HumanoidRootPart.Position,
                itemName,
                1
            )

            -- Remove from inventory
            PlayerSystems[player].Inventory:RemoveItem(itemName, 1)

            -- Send updated inventory
            local inventoryData = PlayerSystems[player].Inventory:GetInventoryData()
            events.RequestInventory:FireClient(player, inventoryData)
        end
    end
end)

-- Equipment event handlers
events.EquipItem.OnServerEvent:Connect(function(player, itemName)
    if PlayerSystems[player] then
        local success = PlayerSystems[player].Equipment:EquipItem(itemName)

        if success then
            -- Remove from inventory
            PlayerSystems[player].Inventory:RemoveItem(itemName, 1)

            -- Update inventory and equipment display
            local inventoryData = PlayerSystems[player].Inventory:GetInventoryData()
            events.RequestInventory:FireClient(player, inventoryData)
        end
    end
end)

events.UnequipItem.OnServerEvent:Connect(function(player, slotType)
    if PlayerSystems[player] then
        local item = PlayerSystems[player].Equipment:UnequipItem(slotType)

        if item then
            -- Add back to inventory
            PlayerSystems[player].Inventory:AddItem(item.Name, 1)

            -- Update displays
            local inventoryData = PlayerSystems[player].Inventory:GetInventoryData()
            events.RequestInventory:FireClient(player, inventoryData)
        end
    end
end)

-- Loot event handlers
events.LootItem.OnServerEvent:Connect(function(player, containerPosition, itemIndex)
    local container = LootSystem:GetContainer(containerPosition)

    if container and PlayerSystems[player] then
        local item = container:TakeItem(itemIndex, player)

        if item then
            -- Add to inventory
            local success = PlayerSystems[player].Inventory:AddItem(item.Name, item.Quantity)

            if success then
                -- Update stats
                DataService:UpdatePlayerStat(player, "ItemsLooted", item.Quantity)
                PlayerSystems[player].Skills:OnSearchContainer()

                -- Update inventory display
                local inventoryData = PlayerSystems[player].Inventory:GetInventoryData()
                events.RequestInventory:FireClient(player, inventoryData)
            end
        end
    end
end)

-- Trading event handlers
events.BuyItem.OnServerEvent:Connect(function(player, vendorName, itemName, quantity)
    local vendor = TradingSystem:GetVendor(vendorName)

    if vendor and PlayerSystems[player] then
        local success, message = vendor:PurchaseItem(
            player,
            itemName,
            quantity,
            PlayerSystems[player].Data
        )

        if success then
            -- Add to inventory
            PlayerSystems[player].Inventory:AddItem(itemName, quantity)

            -- Save data
            DataService:SavePlayerData(player)
        end

        -- Send result to client
        print(message)
    end
end)

events.SellItem.OnServerEvent:Connect(function(player, vendorName, itemName, quantity)
    local vendor = TradingSystem:GetVendor(vendorName)

    if vendor and PlayerSystems[player] then
        -- Check if player has item
        local item = PlayerSystems[player].Inventory:GetItem(itemName)

        if item and item.Quantity >= quantity then
            local success, message = vendor:SellItem(
                player,
                itemName,
                quantity,
                PlayerSystems[player].Data
            )

            if success then
                -- Remove from inventory
                PlayerSystems[player].Inventory:RemoveItem(itemName, quantity)

                -- Save data
                DataService:SavePlayerData(player)
            end

            print(message)
        end
    end
end)

-- Extraction handlers
ExtractionSystem.OnPlayerExtracted = function(player, extractionName)
    if not PlayerSystems[player] then return end

    -- Update statistics
    DataService:UpdatePlayerStat(player, "SuccessfulExtractions", 1)
    DataService:AddExperience(player, 500) -- Bonus XP for extracting

    -- Notify session system
    SessionSystem:OnPlayerExtracted(
        player,
        PlayerSystems[player].Data,
        PlayerSystems[player].Inventory
    )

    -- Save inventory to stash
    for _, item in pairs(PlayerSystems[player].Inventory.Items) do
        DataService:AddToStash(player, item)
    end

    -- Clear field inventory (items now in stash)
    PlayerSystems[player].Inventory.Items = {}

    -- Give starter items for next run
    PlayerSystems[player].Inventory:AddItem("Bandage", 1)
    PlayerSystems[player].Inventory:AddItem("WaterBottle", 1)

    -- Save data
    DataService:SavePlayerData(player)

    print(player.Name .. " extracted successfully - Items moved to stash")
end

-- Settings handler
events.SaveSettings.OnServerEvent:Connect(function(player, settings)
    if PlayerSystems[player] and PlayerSystems[player].Data then
        PlayerSystems[player].Data.Settings = settings
        DataService:SavePlayerData(player)
    end
end)

print("=== DeadZone Server Ready ===")
print("Game Mode: Open World Survival")
print("Active Systems:", "AI, Extraction, Loot, Trading, Sessions, Skills, Data")
