--[[
    GameSettings.lua
    Core configuration for DeadZone game
]]

local GameSettings = {
    -- Player Settings
    Player = {
        MaxHealth = 100,
        MaxStamina = 100,
        StaminaRegenRate = 5, -- per second
        StaminaDrainRate = 15, -- per second while sprinting
        SprintMultiplier = 1.8,
        MaxHunger = 100,
        MaxThirst = 100,
        HungerDecayRate = 0.5, -- per minute
        ThirstDecayRate = 0.8, -- per minute
        WalkSpeed = 16,
        SprintSpeed = 28,
        CrouchSpeed = 8
    },

    -- Inventory Settings
    Inventory = {
        MaxSlots = 20,
        MaxWeight = 50, -- kg
        DefaultBackpackSlots = 8
    },

    -- Weapon Settings
    Weapons = {
        MaxRecoil = 10,
        AimDownSightSpeed = 0.3,
        DefaultSpreadRadius = 0.05,
        HeadshotMultiplier = 2.5,
        DurabilityEnabled = true
    },

    -- Survival Settings
    Survival = {
        DehydrationDamageRate = 2, -- per second when thirst = 0
        StarvationDamageRate = 1, -- per second when hunger = 0
        BleedingEnabled = true,
        FracturesEnabled = true
    },

    -- AI Settings
    AI = {
        ZombieSpawnRadius = 200,
        MaxZombiesPerArea = 15,
        ZombieDetectionRange = 40,
        ZombieSpeed = 14,
        ZombieDamage = 15,
        InfectionChance = 0.15
    },

    -- Extraction Settings
    Extraction = {
        ExtractionTime = 10, -- seconds
        MinPlayersForExtraction = 1,
        KeepItemsOnDeath = false,
        SafeZoneEnabled = true
    },

    -- Map Settings
    Map = {
        Size = 2048, -- studs (2048x2048 map)
        CenterPosition = Vector3.new(0, 0, 0),
        GridSize = 512 -- studs per grid cell (4x4 grid)
    },

    -- Loot Settings
    Loot = {
        RespawnTime = 300, -- 5 minutes
        RarityWeights = {
            Common = 60,
            Uncommon = 25,
            Rare = 10,
            Epic = 4,
            Legendary = 1
        }
    },

    -- Data Settings
    Data = {
        AutoSaveInterval = 60, -- seconds
        MaxStashSlots = 50
    }
}

return GameSettings
