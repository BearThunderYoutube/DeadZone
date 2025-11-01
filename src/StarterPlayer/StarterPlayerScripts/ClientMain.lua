--[[
    ClientMain.lua
    Main client initialization script
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

print("=== DeadZone Client Starting ===")

-- Wait for events
local events = ReplicatedStorage:WaitForChild("Events")

-- Load HUD
local HUD = require(StarterGui:WaitForChild("HUD"))
local InventoryGUI = require(StarterGui:WaitForChild("InventoryGUI"))
local MapUI = require(StarterGui:WaitForChild("MapUI"))

print("UI modules loaded")

-- Event handlers
events.UpdateHealth:OnClientEvent:Connect(function(health, maxHealth)
    HUD:UpdateHealth(health, maxHealth)
end)

events.UpdateStamina:OnClientEvent:Connect(function(stamina, maxStamina)
    HUD:UpdateStamina(stamina, maxStamina or 100)
end)

events.UpdateSurvival:OnClientEvent:Connect(function(hunger, thirst, maxHunger, maxThirst)
    HUD:UpdateSurvival(hunger, thirst, maxHunger, maxThirst)
end)

events.UpdateWeapon:OnClientEvent:Connect(function(weaponName, currentAmmo, reserveAmmo)
    HUD:UpdateWeapon(weaponName, currentAmmo, reserveAmmo)
end)

events.UpdateStatusEffects:OnClientEvent:Connect(function(statusEffects)
    HUD:UpdateStatusEffects(statusEffects)
end)

events.RequestInventory:OnClientEvent:Connect(function(inventoryData)
    InventoryGUI:UpdateInventory(inventoryData)
end)

events.ExtractionStarted:OnClientEvent:Connect(function(extractionName, time)
    print("Extracting at " .. extractionName .. " - " .. time .. " seconds remaining")
    -- Show extraction UI
end)

events.ExtractionCancelled:OnClientEvent:Connect(function()
    print("Extraction cancelled")
    -- Hide extraction UI
end)

events.ExtractionComplete:OnClientEvent:Connect(function()
    print("Successfully extracted!")
    -- Show success screen
end)

events.LevelUp:OnClientEvent:Connect(function(newLevel)
    print("Level up! You are now level " .. newLevel)
    -- Show level up notification
end)

print("=== DeadZone Client Ready ===")
