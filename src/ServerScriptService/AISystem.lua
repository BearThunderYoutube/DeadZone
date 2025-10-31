--[[
    AISystem.lua
    Zombie and NPC AI system with pathfinding and behavior states
]]

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameSettings = require(ReplicatedStorage.Modules.GameSettings)

local AISystem = {}
AISystem.ActiveZombies = {}
AISystem.SpawnPoints = {}

-- Zombie behavior states
local BehaviorState = {
    IDLE = "Idle",
    WANDER = "Wander",
    CHASE = "Chase",
    ATTACK = "Attack"
}

local ZombieClass = {}
ZombieClass.__index = ZombieClass

function ZombieClass.new(spawnPosition)
    local self = setmetatable({}, ZombieClass)

    -- Create zombie model
    self.Model = game:GetService("ServerStorage"):FindFirstChild("ZombieModel"):Clone()
    self.Model.Parent = workspace.Zombies
    self.Model:SetPrimaryPartCFrame(CFrame.new(spawnPosition))

    self.Humanoid = self.Model:FindFirstChildOfClass("Humanoid")
    self.Humanoid.WalkSpeed = GameSettings.AI.ZombieSpeed
    self.Humanoid.Health = 100
    self.Humanoid.MaxHealth = 100

    self.State = BehaviorState.WANDER
    self.Target = nil
    self.Path = nil
    self.LastPathUpdate = 0
    self.AttackCooldown = 0
    self.DetectionRange = GameSettings.AI.ZombieDetectionRange

    return self
end

function ZombieClass:FindNearestPlayer()
    local nearestPlayer = nil
    local nearestDistance = self.DetectionRange

    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = player.Character.HumanoidRootPart.Position
            local distance = (playerPos - self.Model.PrimaryPart.Position).Magnitude

            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end

    return nearestPlayer, nearestDistance
end

function ZombieClass:UpdatePath(targetPosition)
    local currentTime = tick()
    if currentTime - self.LastPathUpdate < 0.5 then
        return -- Don't update path too frequently
    end

    self.LastPathUpdate = currentTime
    self.Path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4
    })

    local success, errorMsg = pcall(function()
        self.Path:ComputeAsync(self.Model.PrimaryPart.Position, targetPosition)
    end)

    if success and self.Path.Status == Enum.PathStatus.Success then
        local waypoints = self.Path:GetWaypoints()

        for i, waypoint in ipairs(waypoints) do
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                self.Humanoid.Jump = true
            end
            self.Humanoid:MoveTo(waypoint.Position)

            local timeout = self.Humanoid.MoveToFinished:Wait(1)
            if not timeout then break end
        end
    end
end

function ZombieClass:Attack(target)
    if not target or not target.Character then
        self.State = BehaviorState.WANDER
        return
    end

    local targetHumanoid = target.Character:FindFirstChildOfClass("Humanoid")
    if targetHumanoid and targetHumanoid.Health > 0 then
        local distance = (target.Character.PrimaryPart.Position - self.Model.PrimaryPart.Position).Magnitude

        if distance < 4 and self.AttackCooldown <= 0 then
            -- Attack
            targetHumanoid:TakeDamage(GameSettings.AI.ZombieDamage)
            self.AttackCooldown = 1.5

            -- Infection chance
            if math.random() < GameSettings.AI.InfectionChance then
                -- Apply infection status effect
                target:SetAttribute("Infected", true)
            end
        elseif distance > self.DetectionRange * 1.5 then
            -- Lost target
            self.State = BehaviorState.WANDER
            self.Target = nil
        else
            -- Chase target
            self:UpdatePath(target.Character.PrimaryPart.Position)
        end
    else
        self.State = BehaviorState.WANDER
        self.Target = nil
    end
end

function ZombieClass:Update(dt)
    if not self.Model or not self.Model.Parent then
        return false -- Zombie destroyed
    end

    if self.Humanoid.Health <= 0 then
        self:Destroy()
        return false
    end

    self.AttackCooldown = math.max(0, self.AttackCooldown - dt)

    -- Find nearest player
    local nearestPlayer, distance = self:FindNearestPlayer()

    if nearestPlayer then
        self.State = BehaviorState.CHASE
        self.Target = nearestPlayer
        self:Attack(nearestPlayer)
    else
        -- Wander behavior
        if self.State ~= BehaviorState.WANDER then
            self.State = BehaviorState.WANDER
        end

        if tick() % 5 < dt then -- Wander every 5 seconds
            local randomOffset = Vector3.new(
                math.random(-30, 30),
                0,
                math.random(-30, 30)
            )
            local wanderPos = self.Model.PrimaryPart.Position + randomOffset
            self.Humanoid:MoveTo(wanderPos)
        end
    end

    return true
end

function ZombieClass:Destroy()
    if self.Model then
        -- Drop loot
        AISystem:SpawnLoot(self.Model.PrimaryPart.Position)
        self.Model:Destroy()
    end
end

-- Main AI System functions
function AISystem:Initialize()
    -- Create zombie folder
    if not workspace:FindFirstChild("Zombies") then
        local zombieFolder = Instance.new("Folder")
        zombieFolder.Name = "Zombies"
        zombieFolder.Parent = workspace
    end

    -- Start update loop
    RunService.Heartbeat:Connect(function(dt)
        self:UpdateAllZombies(dt)
    end)

    -- Spawn zombies periodically
    task.spawn(function()
        while true do
            self:SpawnZombiesInArea()
            task.wait(10)
        end
    end)
end

function AISystem:SpawnZombiesInArea()
    local players = game.Players:GetPlayers()
    if #players == 0 then return end

    for _, player in pairs(players) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = player.Character.HumanoidRootPart.Position

            -- Count nearby zombies
            local nearbyCount = 0
            for _, zombie in pairs(self.ActiveZombies) do
                local distance = (zombie.Model.PrimaryPart.Position - playerPos).Magnitude
                if distance < GameSettings.AI.ZombieSpawnRadius then
                    nearbyCount = nearbyCount + 1
                end
            end

            -- Spawn zombies if needed
            if nearbyCount < GameSettings.AI.MaxZombiesPerArea then
                local spawnOffset = Vector3.new(
                    math.random(-GameSettings.AI.ZombieSpawnRadius, GameSettings.AI.ZombieSpawnRadius),
                    0,
                    math.random(-GameSettings.AI.ZombieSpawnRadius, GameSettings.AI.ZombieSpawnRadius)
                )

                local spawnPos = playerPos + spawnOffset
                local zombie = ZombieClass.new(spawnPos)
                table.insert(self.ActiveZombies, zombie)
            end
        end
    end
end

function AISystem:UpdateAllZombies(dt)
    for i = #self.ActiveZombies, 1, -1 do
        local zombie = self.ActiveZombies[i]
        local isAlive = zombie:Update(dt)

        if not isAlive then
            table.remove(self.ActiveZombies, i)
        end
    end
end

function AISystem:SpawnLoot(position)
    -- Spawn random loot at position
    local lootItems = {"Bandage", "9mm", "CannedFood", "WaterBottle"}
    local selectedItem = lootItems[math.random(1, #lootItems)]

    -- Create loot drop (this would integrate with LootSystem)
    local lootDrop = Instance.new("Part")
    lootDrop.Name = "LootDrop"
    lootDrop.Size = Vector3.new(2, 0.5, 2)
    lootDrop.Position = position + Vector3.new(0, 1, 0)
    lootDrop.Anchored = true
    lootDrop.Parent = workspace.Loot
    lootDrop:SetAttribute("ItemName", selectedItem)
end

return AISystem
