--[[
    SurvivalSystem.lua
    Manages player survival mechanics: hunger, thirst, health, bleeding, infections
]]

local SurvivalSystem = {}
SurvivalSystem.__index = SurvivalSystem

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GameSettings = require(script.Parent.GameSettings)

function SurvivalSystem.new(player)
    local self = setmetatable({}, SurvivalSystem)

    self.Player = player
    self.Health = GameSettings.Player.MaxHealth
    self.Hunger = GameSettings.Player.MaxHunger
    self.Thirst = GameSettings.Player.MaxThirst

    -- Status effects
    self.IsBleeding = false
    self.IsInfected = false
    self.IsFractured = false
    self.PainLevel = 0

    -- Timers
    self.BleedingTimer = 0
    self.InfectionTimer = 0
    self.LastHungerUpdate = tick()
    self.LastThirstUpdate = tick()

    return self
end

function SurvivalSystem:Update(dt)
    local currentTime = tick()

    -- Update hunger
    if currentTime - self.LastHungerUpdate >= 60 then
        self.Hunger = math.max(0, self.Hunger - GameSettings.Player.HungerDecayRate)
        self.LastHungerUpdate = currentTime

        if self.Hunger <= 0 then
            self:TakeDamage(GameSettings.Survival.StarvationDamageRate, "Starvation")
        end
    end

    -- Update thirst
    if currentTime - self.LastThirstUpdate >= 60 then
        self.Thirst = math.max(0, self.Thirst - GameSettings.Player.ThirstDecayRate)
        self.LastThirstUpdate = currentTime

        if self.Thirst <= 0 then
            self:TakeDamage(GameSettings.Survival.DehydrationDamageRate, "Dehydration")
        end
    end

    -- Update bleeding
    if self.IsBleeding then
        self.BleedingTimer = self.BleedingTimer + dt
        if self.BleedingTimer >= 2 then -- Damage every 2 seconds
            self:TakeDamage(5, "Bleeding")
            self.BleedingTimer = 0
        end
    end

    -- Update infection
    if self.IsInfected then
        self.InfectionTimer = self.InfectionTimer + dt
        if self.InfectionTimer >= 10 then -- Damage every 10 seconds
            self:TakeDamage(3, "Infection")
            self.InfectionTimer = 0
        end
    end

    -- Update pain effects
    if self.PainLevel > 0 then
        self.PainLevel = math.max(0, self.PainLevel - dt * 0.5)
    end
end

function SurvivalSystem:TakeDamage(amount, source)
    self.Health = math.max(0, self.Health - amount)

    -- Increase pain
    self.PainLevel = math.min(100, self.PainLevel + amount * 0.5)

    -- Chance to start bleeding on damage
    if source == "Bullet" or source == "Melee" then
        if math.random() < 0.3 and not self.IsBleeding then
            self:ApplyBleeding()
        end
    end

    -- Check for death
    if self.Health <= 0 then
        self:OnDeath()
    end

    return self.Health
end

function SurvivalSystem:Heal(amount)
    self.Health = math.min(GameSettings.Player.MaxHealth, self.Health + amount)
    return self.Health
end

function SurvivalSystem:EatFood(hungerRestore)
    self.Hunger = math.min(GameSettings.Player.MaxHunger, self.Hunger + hungerRestore)
end

function SurvivalSystem:DrinkWater(thirstRestore)
    self.Thirst = math.min(GameSettings.Player.MaxThirst, self.Thirst + thirstRestore)
end

function SurvivalSystem:ApplyBleeding()
    self.IsBleeding = true
    self.BleedingTimer = 0
    print(self.Player.Name .. " is bleeding!")
end

function SurvivalSystem:StopBleeding()
    self.IsBleeding = false
    self.BleedingTimer = 0
end

function SurvivalSystem:ApplyInfection()
    self.IsInfected = true
    self.InfectionTimer = 0
    print(self.Player.Name .. " is infected!")
end

function SurvivalSystem:CureInfection()
    self.IsInfected = false
    self.InfectionTimer = 0
end

function SurvivalSystem:ApplyFracture(boneName)
    self.IsFractured = true
    self.FracturedBone = boneName

    -- Reduce movement speed
    if self.Player.Character then
        local humanoid = self.Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = humanoid.WalkSpeed * 0.5
        end
    end
end

function SurvivalSystem:HealFracture()
    self.IsFractured = false
    self.FracturedBone = nil

    -- Restore movement speed
    if self.Player.Character then
        local humanoid = self.Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = GameSettings.Player.WalkSpeed
        end
    end
end

function SurvivalSystem:UseMedical(itemType, itemData)
    if itemType == "Bandage" then
        if self.IsBleeding then
            self:StopBleeding()
            self:Heal(itemData.HealAmount)
            return true
        else
            self:Heal(itemData.HealAmount)
            return true
        end
    elseif itemType == "Medkit" then
        self:StopBleeding()
        self:Heal(itemData.HealAmount)
        return true
    elseif itemType == "Painkillers" then
        self.PainLevel = 0
        return true
    elseif itemType == "Antibiotics" then
        self:CureInfection()
        return true
    elseif itemType == "Splint" then
        self:HealFracture()
        return true
    end

    return false
end

function SurvivalSystem:GetStatusEffects()
    local effects = {}

    if self.IsBleeding then table.insert(effects, "Bleeding") end
    if self.IsInfected then table.insert(effects, "Infected") end
    if self.IsFractured then table.insert(effects, "Fractured") end
    if self.PainLevel > 50 then table.insert(effects, "In Pain") end
    if self.Hunger < 20 then table.insert(effects, "Starving") end
    if self.Thirst < 20 then table.insert(effects, "Dehydrated") end

    return effects
end

function SurvivalSystem:GetSurvivalData()
    return {
        Health = self.Health,
        MaxHealth = GameSettings.Player.MaxHealth,
        Hunger = self.Hunger,
        MaxHunger = GameSettings.Player.MaxHunger,
        Thirst = self.Thirst,
        MaxThirst = GameSettings.Player.MaxThirst,
        StatusEffects = self:GetStatusEffects(),
        PainLevel = self.PainLevel
    }
end

function SurvivalSystem:OnDeath()
    print(self.Player.Name .. " has died!")

    -- Drop all items (integrate with InventorySystem)
    if not GameSettings.Extraction.KeepItemsOnDeath then
        -- Drop inventory
    end

    -- Respawn logic
    task.wait(5)
    if self.Player.Character then
        self.Player:LoadCharacter()
    end

    -- Reset survival stats
    self.Health = GameSettings.Player.MaxHealth
    self.Hunger = GameSettings.Player.MaxHunger
    self.Thirst = GameSettings.Player.MaxThirst
    self.IsBleeding = false
    self.IsInfected = false
    self.IsFractured = false
    self.PainLevel = 0
end

return SurvivalSystem
