--[[
    SessionSystem.lua
    Manages player sessions in the open world (replaces RaidSystem)
]]

local SessionSystem = {}
SessionSystem.ActiveSessions = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SESSION_CONFIG = {
    StartingMoney = 500,
    DeathPenalty = 0.1, -- Lose 10% of money on death
    ExtractionReward = 100, -- Base money reward for extracting
    SaveInventoryOnDeath = false -- If true, keep items on death
}

function SessionSystem:Initialize()
    print("SessionSystem initialized - Open World Mode")

    -- Player handlers
    Players.PlayerRemoving:Connect(function(player)
        self:EndSession(player, "Disconnect")
    end)
end

function SessionSystem:StartSession(player, playerData)
    -- Create new session
    local session = {
        Player = player,
        StartTime = tick(),
        Status = "Active",
        ItemsCollected = 0,
        ZombiesKilled = 0,
        DistanceTraveled = 0
    }

    self.ActiveSessions[player] = session

    -- Spawn player in the world
    if player.Character then
        self:SpawnPlayerInWorld(player)
    end

    print(player.Name .. " started open world session")

    return session
end

function SessionSystem:SpawnPlayerInWorld(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    -- Random spawn points around the map
    local spawnPoints = {
        Vector3.new(0, 10, 0),
        Vector3.new(100, 10, 100),
        Vector3.new(-100, 10, 100),
        Vector3.new(100, 10, -100),
        Vector3.new(-100, 10, -100),
        Vector3.new(50, 10, 0),
        Vector3.new(-50, 10, 0),
        Vector3.new(0, 10, 50),
        Vector3.new(0, 10, -50)
    }

    local randomSpawn = spawnPoints[math.random(1, #spawnPoints)]
    player.Character:SetPrimaryPartCFrame(CFrame.new(randomSpawn))
end

function SessionSystem:EndSession(player, reason)
    local session = self.ActiveSessions[player]
    if not session then return end

    session.Status = "Ended"
    session.EndTime = tick()
    session.Duration = session.EndTime - session.StartTime

    print(player.Name .. " ended session - Reason:", reason)

    -- Clean up
    self.ActiveSessions[player] = nil
end

function SessionSystem:OnPlayerDeath(player, playerData)
    local session = self.ActiveSessions[player]
    if not session then return end

    print(player.Name .. " died in open world")

    -- Apply death penalty
    if playerData and playerData.Money then
        local penalty = math.floor(playerData.Money * SESSION_CONFIG.DeathPenalty)
        playerData.Money = playerData.Money - penalty
        print("Lost $" .. penalty .. " on death")
    end

    -- Drop inventory (handled by MainServer)
    -- Player will respawn normally
end

function SessionSystem:OnPlayerExtracted(player, playerData, inventory)
    local session = self.ActiveSessions[player]
    if not session then return end

    print(player.Name .. " successfully extracted!")

    -- Give rewards
    if playerData then
        local reward = SESSION_CONFIG.ExtractionReward

        -- Bonus for items collected
        if inventory and inventory.Items then
            reward = reward + (#inventory.Items * 10)
        end

        playerData.Money = (playerData.Money or 0) + reward
        print("Extraction reward: $" .. reward)
    end

    -- Update statistics (handled by MainServer)

    return true
end

function SessionSystem:GetPlayerSession(player)
    return self.ActiveSessions[player]
end

function SessionSystem:UpdateSessionStats(player, statName, value)
    local session = self.ActiveSessions[player]
    if session then
        session[statName] = (session[statName] or 0) + value
    end
end

return SessionSystem
