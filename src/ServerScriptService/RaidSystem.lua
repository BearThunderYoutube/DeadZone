--[[
    RaidSystem.lua
    Manages raid instances, timers, and match making
]]

local RaidSystem = {}
RaidSystem.ActiveRaids = {}
RaidSystem.PlayerRaidData = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Raid configuration
local RaidConfig = {
    MaxDuration = 2400, -- 40 minutes
    WarningTime = 300, -- 5 minutes warning
    MinimumPlayers = 1,
    MaximumPlayers = 20,
    RaidTypes = {
        ["Scavenge Run"] = {
            Duration = 1800, -- 30 minutes
            Difficulty = "Easy",
            LootMultiplier = 1.0,
            ZombieMultiplier = 1.0
        },
        ["Military Raid"] = {
            Duration = 2400, -- 40 minutes
            Difficulty = "Hard",
            LootMultiplier = 1.5,
            ZombieMultiplier = 1.5
        },
        ["Night Ops"] = {
            Duration = 1500, -- 25 minutes
            Difficulty = "Extreme",
            LootMultiplier = 2.0,
            ZombieMultiplier = 2.0,
            IsNight = true
        }
    }
}

-- Raid class
local Raid = {}
Raid.__index = Raid

function Raid.new(raidType, players)
    local self = setmetatable({}, Raid)

    self.Type = raidType
    self.Config = RaidConfig.RaidTypes[raidType] or RaidConfig.RaidTypes["Scavenge Run"]
    self.Players = players or {}
    self.StartTime = tick()
    self.Duration = self.Config.Duration
    self.Status = "Active"
    self.TimeRemaining = self.Duration

    return self
end

function Raid:Update(dt)
    if self.Status ~= "Active" then
        return
    end

    self.TimeRemaining = self.Duration - (tick() - self.StartTime)

    -- Check for warnings
    if self.TimeRemaining <= RaidConfig.WarningTime and self.TimeRemaining > RaidConfig.WarningTime - 1 then
        self:SendWarning("5 minutes remaining!")
    elseif self.TimeRemaining <= 60 and self.TimeRemaining > 59 then
        self:SendWarning("1 minute remaining!")
    elseif self.TimeRemaining <= 30 and self.TimeRemaining > 29 then
        self:SendWarning("30 seconds remaining!")
    end

    -- Check for timeout
    if self.TimeRemaining <= 0 then
        self:EndRaid("Timeout")
    end

    return true
end

function Raid:SendWarning(message)
    for _, player in pairs(self.Players) do
        if player and player.Parent then
            local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("RaidWarning")
            if event then
                event:FireClient(player, message, self.TimeRemaining)
            end
        end
    end
end

function Raid:EndRaid(reason)
    self.Status = "Ended"
    print("Raid ended:", reason)

    for _, player in pairs(self.Players) do
        if player and player.Parent then
            local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("RaidEnded")
            if event then
                event:FireClient(player, reason, self.Type)
            end

            -- Teleport to safe zone
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local safeZone = workspace:FindFirstChild("SafeZone")
                if safeZone then
                    player.Character:SetPrimaryPartCFrame(CFrame.new(-200, 10, 0))
                end
            end
        end
    end
end

function Raid:RemovePlayer(player)
    for i, p in pairs(self.Players) do
        if p == player then
            table.remove(self.Players, i)
            break
        end
    end

    -- End raid if no players left
    if #self.Players == 0 then
        self:EndRaid("No players remaining")
    end
end

function Raid:GetRaidData()
    return {
        Type = self.Type,
        TimeRemaining = self.TimeRemaining,
        TotalDuration = self.Duration,
        PlayerCount = #self.Players,
        Status = self.Status,
        Difficulty = self.Config.Difficulty
    }
end

-- Main system functions
function RaidSystem:Initialize()
    print("RaidSystem initialized")

    -- Update raids
    task.spawn(function()
        while true do
            local dt = task.wait(1)
            self:UpdateAllRaids(dt)
        end
    end)

    -- Player handlers
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerLeftRaid(player)
    end)
end

function RaidSystem:StartRaid(raidType, players)
    -- Create new raid
    local raid = Raid.new(raidType, players)
    table.insert(self.ActiveRaids, raid)

    -- Register players
    for _, player in pairs(players) do
        self.PlayerRaidData[player] = raid
    end

    -- Notify players
    for _, player in pairs(players) do
        local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("RaidStarted")
        if event then
            event:FireClient(player, raid:GetRaidData())
        end
    end

    -- Set lighting for night raids
    if raid.Config.IsNight then
        local lighting = game:GetService("Lighting")
        lighting.ClockTime = 0
        lighting.Brightness = 0.5
    end

    print("Started raid:", raidType, "with", #players, "players")

    return raid
end

function RaidSystem:UpdateAllRaids(dt)
    for i = #self.ActiveRaids, 1, -1 do
        local raid = self.ActiveRaids[i]
        local stillActive = raid:Update(dt)

        -- Update UI for all players in raid
        for _, player in pairs(raid.Players) do
            if player and player.Parent then
                local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("UpdateRaidTimer")
                if event then
                    event:FireClient(player, raid.TimeRemaining, raid.Duration)
                end
            end
        end

        if raid.Status == "Ended" then
            table.remove(self.ActiveRaids, i)
            -- Clear player raid data
            for _, player in pairs(raid.Players) do
                self.PlayerRaidData[player] = nil
            end
        end
    end
end

function RaidSystem:PlayerExtracted(player)
    local raid = self.PlayerRaidData[player]
    if raid then
        raid:RemovePlayer(player)
        self.PlayerRaidData[player] = nil
        print(player.Name .. " extracted from raid")
    end
end

function RaidSystem:PlayerDied(player)
    local raid = self.PlayerRaidData[player]
    if raid then
        -- Don't remove from raid, just notify
        local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("RaidDeath")
        if event then
            event:FireClient(player)
        end
    end
end

function RaidSystem:PlayerLeftRaid(player)
    local raid = self.PlayerRaidData[player]
    if raid then
        raid:RemovePlayer(player)
        self.PlayerRaidData[player] = nil
    end
end

function RaidSystem:GetPlayerRaid(player)
    return self.PlayerRaidData[player]
end

function RaidSystem:GetRaidInfo(player)
    local raid = self.PlayerRaidData[player]
    if raid then
        return raid:GetRaidData()
    end
    return nil
end

-- Matchmaking
function RaidSystem:JoinQueue(player, raidType)
    -- Simple implementation - start raid immediately for now
    local players = {player}
    self:StartRaid(raidType, players)
end

return RaidSystem
