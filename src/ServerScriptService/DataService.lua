--[[
    DataService.lua
    Handles player data persistence using DataStoreService
]]

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameSettings = require(ReplicatedStorage.Modules.GameSettings)

local DataService = {}
DataService.PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
DataService.PlayerData = {}

local DEFAULT_DATA = {
    Level = 1,
    Experience = 0,
    Money = 500,
    Stash = {}, -- Items stored in safe zone
    Skills = {
        Strength = 1,
        Endurance = 1,
        Vitality = 1,
        Metabolism = 1,
        Recoil = 1,
        Search = 1
    },
    Statistics = {
        TotalRaids = 0,
        SuccessfulExtractions = 0,
        KilledInAction = 0,
        ZombiesKilled = 0,
        PlayersKilled = 0,
        ItemsLooted = 0,
        DistanceTraveled = 0
    },
    Achievements = {},
    Settings = {
        MusicVolume = 0.5,
        SFXVolume = 0.8,
        FOV = 80,
        MouseSensitivity = 0.5
    }
}

function DataService:LoadPlayerData(player)
    local success, data = pcall(function()
        return self.PlayerDataStore:GetAsync("Player_" .. player.UserId)
    end)

    if success and data then
        print("Loaded data for " .. player.Name)
        self.PlayerData[player] = data
    else
        print("Creating new data for " .. player.Name)
        -- Create new player data
        local newData = {}
        for key, value in pairs(DEFAULT_DATA) do
            if type(value) == "table" then
                newData[key] = {}
                for k, v in pairs(value) do
                    newData[key][k] = v
                end
            else
                newData[key] = value
            end
        end
        self.PlayerData[player] = newData
    end

    return self.PlayerData[player]
end

function DataService:SavePlayerData(player)
    local data = self.PlayerData[player]
    if not data then
        warn("No data found for " .. player.Name)
        return false
    end

    local success, errorMsg = pcall(function()
        self.PlayerDataStore:SetAsync("Player_" .. player.UserId, data)
    end)

    if success then
        print("Saved data for " .. player.Name)
        return true
    else
        warn("Failed to save data for " .. player.Name .. ": " .. errorMsg)
        return false
    end
end

function DataService:GetPlayerData(player)
    return self.PlayerData[player]
end

function DataService:UpdatePlayerStat(player, statName, value)
    local data = self.PlayerData[player]
    if data and data.Statistics[statName] then
        data.Statistics[statName] = data.Statistics[statName] + value
    end
end

function DataService:AddToStash(player, item)
    local data = self.PlayerData[player]
    if data then
        table.insert(data.Stash, item)
        return true
    end
    return false
end

function DataService:RemoveFromStash(player, itemIndex)
    local data = self.PlayerData[player]
    if data and data.Stash[itemIndex] then
        table.remove(data.Stash, itemIndex)
        return true
    end
    return false
end

function DataService:AddExperience(player, amount)
    local data = self.PlayerData[player]
    if not data then return end

    data.Experience = data.Experience + amount

    -- Level up calculation
    local requiredXP = data.Level * 1000
    if data.Experience >= requiredXP then
        data.Experience = data.Experience - requiredXP
        data.Level = data.Level + 1

        -- Notify player
        local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("LevelUp")
        if event then
            event:FireClient(player, data.Level)
        end

        print(player.Name .. " leveled up to level " .. data.Level)
    end
end

function DataService:AddMoney(player, amount)
    local data = self.PlayerData[player]
    if data then
        data.Money = data.Money + amount
        return true
    end
    return false
end

function DataService:RemoveMoney(player, amount)
    local data = self.PlayerData[player]
    if data and data.Money >= amount then
        data.Money = data.Money - amount
        return true
    end
    return false
end

function DataService:Initialize()
    -- Auto-save every interval
    task.spawn(function()
        while true do
            task.wait(GameSettings.Data.AutoSaveInterval)

            for _, player in pairs(Players:GetPlayers()) do
                self:SavePlayerData(player)
            end

            print("Auto-save completed")
        end
    end)

    -- Player joining
    Players.PlayerAdded:Connect(function(player)
        self:LoadPlayerData(player)
    end)

    -- Player leaving
    Players.PlayerRemoving:Connect(function(player)
        self:SavePlayerData(player)
        self.PlayerData[player] = nil
    end)

    -- Save all data on server shutdown
    game:BindToClose(function()
        for _, player in pairs(Players:GetPlayers()) do
            self:SavePlayerData(player)
        end
        task.wait(2) -- Give time for saves to complete
    end)
end

return DataService
