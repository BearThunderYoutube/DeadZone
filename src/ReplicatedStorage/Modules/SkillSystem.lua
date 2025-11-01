--[[
    SkillSystem.lua
    Player skill progression and bonuses
]]

local SkillSystem = {}
SkillSystem.__index = SkillSystem

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Skill definitions
local Skills = {
    Strength = {
        Description = "Increases melee damage and carry weight",
        MaxLevel = 51,
        Bonuses = {
            MeleeDamage = 0.02, -- +2% per level
            CarryWeight = 0.5    -- +0.5kg per level
        }
    },
    Endurance = {
        Description = "Increases stamina and stamina regeneration",
        MaxLevel = 51,
        Bonuses = {
            MaxStamina = 2,      -- +2 per level
            StaminaRegen = 0.1   -- +0.1/s per level
        }
    },
    Vitality = {
        Description = "Increases max health and health regeneration",
        MaxLevel = 51,
        Bonuses = {
            MaxHealth = 2,       -- +2 per level
            HealthRegen = 0.05   -- +0.05/s per level
        }
    },
    Metabolism = {
        Description = "Reduces hunger and thirst decay",
        MaxLevel = 51,
        Bonuses = {
            HungerReduction = 0.01,  -- -1% decay per level
            ThirstReduction = 0.01   -- -1% decay per level
        }
    },
    Recoil = {
        Description = "Reduces weapon recoil",
        MaxLevel = 51,
        Bonuses = {
            RecoilReduction = 0.01   -- -1% per level
        }
    },
    Search = {
        Description = "Increases loot quality and find rate",
        MaxLevel = 51,
        Bonuses = {
            LootQuality = 0.02,      -- +2% rare loot per level
            SearchSpeed = 0.02       -- +2% faster per level
        }
    },
    Perception = {
        Description = "Increases awareness and detection range",
        MaxLevel = 51,
        Bonuses = {
            DetectionRange = 0.5,    -- +0.5m per level
            SoundDetection = 0.02    -- +2% per level
        }
    },
    Stealth = {
        Description = "Reduces noise and visibility",
        MaxLevel = 51,
        Bonuses = {
            NoiseReduction = 0.01,   -- -1% per level
            Visibility = 0.01        -- -1% per level
        }
    }
}

function SkillSystem.new(playerData)
    local self = setmetatable({}, SkillSystem)

    self.PlayerData = playerData
    self.Skills = playerData.Skills or {
        Strength = 1,
        Endurance = 1,
        Vitality = 1,
        Metabolism = 1,
        Recoil = 1,
        Search = 1,
        Perception = 1,
        Stealth = 1
    }
    self.SkillProgress = {}

    -- Initialize progress tracking
    for skillName, _ in pairs(Skills) do
        self.SkillProgress[skillName] = 0
    end

    return self
end

function SkillSystem:AddSkillXP(skillName, amount)
    if not Skills[skillName] then
        warn("Invalid skill:", skillName)
        return false
    end

    local currentLevel = self.Skills[skillName] or 1
    local maxLevel = Skills[skillName].MaxLevel

    if currentLevel >= maxLevel then
        return false -- Max level reached
    end

    self.SkillProgress[skillName] = (self.SkillProgress[skillName] or 0) + amount

    -- Calculate XP needed for next level
    local xpNeeded = self:GetXPForNextLevel(currentLevel)

    while self.SkillProgress[skillName] >= xpNeeded and currentLevel < maxLevel do
        self.SkillProgress[skillName] = self.SkillProgress[skillName] - xpNeeded
        currentLevel = currentLevel + 1
        self.Skills[skillName] = currentLevel

        print("Skill level up:", skillName, "->", currentLevel)

        -- Get next level XP requirement
        if currentLevel < maxLevel then
            xpNeeded = self:GetXPForNextLevel(currentLevel)
        end
    end

    return true
end

function SkillSystem:GetXPForNextLevel(currentLevel)
    -- Exponential scaling: Level * 100
    return currentLevel * 100
end

function SkillSystem:GetSkillBonus(skillName, bonusType)
    local skillData = Skills[skillName]
    if not skillData or not skillData.Bonuses[bonusType] then
        return 0
    end

    local level = self.Skills[skillName] or 1
    return (level - 1) * skillData.Bonuses[bonusType]
end

function SkillSystem:GetAllBonuses()
    local bonuses = {}

    for skillName, skillData in pairs(Skills) do
        local level = self.Skills[skillName] or 1
        bonuses[skillName] = {}

        for bonusType, bonusValue in pairs(skillData.Bonuses) do
            bonuses[skillName][bonusType] = (level - 1) * bonusValue
        end
    end

    return bonuses
end

function SkillSystem:GetSkillData()
    return {
        Skills = self.Skills,
        Progress = self.SkillProgress,
        Bonuses = self:GetAllBonuses()
    }
end

-- Skill gain actions
function SkillSystem:OnSprint(distance)
    local xp = distance * 0.1
    self:AddSkillXP("Endurance", xp)
end

function SkillSystem:OnCarryHeavyLoad(weight, duration)
    local xp = weight * duration * 0.01
    self:AddSkillXP("Strength", xp)
end

function SkillSystem:OnTakeDamage(damage)
    local xp = damage * 0.5
    self:AddSkillXP("Vitality", xp)
end

function SkillSystem:OnEatDrink()
    self:AddSkillXP("Metabolism", 5)
end

function SkillSystem:OnFireWeapon()
    self:AddSkillXP("Recoil", 1)
end

function SkillSystem:OnSearchContainer()
    self:AddSkillXP("Search", 10)
end

function SkillSystem:OnDetectEnemy()
    self:AddSkillXP("Perception", 5)
end

function SkillSystem:OnStealthKill()
    self:AddSkillXP("Stealth", 20)
end

SkillSystem.Skills = Skills

return SkillSystem
