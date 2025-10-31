--[[
    WeaponSystem.lua
    Realistic weapon mechanics including recoil, ballistics, and weapon handling
]]

local WeaponSystem = {}
WeaponSystem.__index = WeaponSystem

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GameSettings = require(script.Parent.GameSettings)

-- Weapon configurations
local WeaponConfigs = {
    ["AK47"] = {
        Damage = 35,
        FireRate = 600, -- rounds per minute
        MuzzleVelocity = 715, -- m/s
        RecoilPattern = {
            Vertical = {0.5, 0.7, 0.9, 0.8, 0.7, 0.6, 0.5},
            Horizontal = {0.1, -0.2, 0.3, -0.1, 0.2, -0.3, 0.1}
        },
        MagazineSize = 30,
        ReloadTime = 2.5,
        AimDownSightTime = 0.35,
        FireMode = {"Auto", "Semi"},
        Spread = 0.06,
        Range = 400
    },
    ["M4A1"] = {
        Damage = 32,
        FireRate = 750,
        MuzzleVelocity = 910,
        RecoilPattern = {
            Vertical = {0.4, 0.5, 0.6, 0.5, 0.4, 0.3, 0.3},
            Horizontal = {0.05, -0.1, 0.15, -0.05, 0.1, -0.15, 0.05}
        },
        MagazineSize = 30,
        ReloadTime = 2.2,
        AimDownSightTime = 0.3,
        FireMode = {"Auto", "Semi", "Burst"},
        Spread = 0.04,
        Range = 500
    },
    ["Glock19"] = {
        Damage = 22,
        FireRate = 400,
        MuzzleVelocity = 375,
        RecoilPattern = {
            Vertical = {0.3, 0.3, 0.3},
            Horizontal = {0.05, -0.05, 0.05}
        },
        MagazineSize = 17,
        ReloadTime = 1.5,
        AimDownSightTime = 0.2,
        FireMode = {"Semi"},
        Spread = 0.08,
        Range = 50
    }
}

function WeaponSystem.new(weaponName, owner)
    local self = setmetatable({}, WeaponSystem)

    self.WeaponName = weaponName
    self.Config = WeaponConfigs[weaponName]
    self.Owner = owner

    self.CurrentAmmo = self.Config.MagazineSize
    self.ReserveAmmo = 0
    self.IsReloading = false
    self.IsFiring = false
    self.CurrentFireMode = 1
    self.RecoilIndex = 1
    self.LastFireTime = 0
    self.Durability = 100

    return self
end

function WeaponSystem:Fire(origin, direction, isAiming)
    if self.IsReloading or self.CurrentAmmo <= 0 then
        return false
    end

    -- Check fire rate
    local currentTime = tick()
    local timeBetweenShots = 60 / self.Config.FireRate

    if currentTime - self.LastFireTime < timeBetweenShots then
        return false
    end

    self.LastFireTime = currentTime
    self.CurrentAmmo = self.CurrentAmmo - 1

    -- Calculate spread
    local spread = self.Config.Spread
    if isAiming then
        spread = spread * 0.5
    end

    -- Apply recoil pattern
    local recoilV = self.Config.RecoilPattern.Vertical[self.RecoilIndex] or 0.5
    local recoilH = self.Config.RecoilPattern.Horizontal[self.RecoilIndex] or 0

    self.RecoilIndex = self.RecoilIndex + 1
    if self.RecoilIndex > #self.Config.RecoilPattern.Vertical then
        self.RecoilIndex = 1
    end

    -- Calculate bullet direction with spread and recoil
    local randomSpread = Vector3.new(
        (math.random() - 0.5) * spread,
        (math.random() - 0.5) * spread + recoilV * 0.1,
        0
    )

    local finalDirection = (direction + randomSpread).Unit

    -- Raycast for hit detection
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {self.Owner.Character}

    local raycastResult = workspace:Raycast(origin, finalDirection * self.Config.Range, raycastParams)

    if raycastResult then
        local hitPart = raycastResult.Instance
        local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")

        if humanoid then
            local damage = self.Config.Damage

            -- Headshot detection
            if hitPart.Name == "Head" then
                damage = damage * GameSettings.Weapons.HeadshotMultiplier
            end

            -- Distance falloff
            local distance = (origin - raycastResult.Position).Magnitude
            local falloff = 1 - (distance / self.Config.Range) * 0.3
            damage = damage * falloff

            return {
                Hit = true,
                Target = humanoid,
                Damage = damage,
                Position = raycastResult.Position,
                IsHeadshot = hitPart.Name == "Head"
            }
        end
    end

    return {
        Hit = false,
        Position = raycastResult and raycastResult.Position or (origin + finalDirection * self.Config.Range)
    }
end

function WeaponSystem:Reload()
    if self.IsReloading or self.CurrentAmmo == self.Config.MagazineSize or self.ReserveAmmo <= 0 then
        return false
    end

    self.IsReloading = true
    self.RecoilIndex = 1

    task.wait(self.Config.ReloadTime)

    local ammoNeeded = self.Config.MagazineSize - self.CurrentAmmo
    local ammoToReload = math.min(ammoNeeded, self.ReserveAmmo)

    self.CurrentAmmo = self.CurrentAmmo + ammoToReload
    self.ReserveAmmo = self.ReserveAmmo - ammoToReload
    self.IsReloading = false

    return true
end

function WeaponSystem:SwitchFireMode()
    self.CurrentFireMode = self.CurrentFireMode + 1
    if self.CurrentFireMode > #self.Config.FireMode then
        self.CurrentFireMode = 1
    end
    return self.Config.FireMode[self.CurrentFireMode]
end

function WeaponSystem:GetWeaponInfo()
    return {
        Name = self.WeaponName,
        CurrentAmmo = self.CurrentAmmo,
        ReserveAmmo = self.ReserveAmmo,
        MagazineSize = self.Config.MagazineSize,
        FireMode = self.Config.FireMode[self.CurrentFireMode],
        Durability = self.Durability,
        IsReloading = self.IsReloading
    }
end

function WeaponSystem:ResetRecoil()
    self.RecoilIndex = 1
end

WeaponSystem.WeaponConfigs = WeaponConfigs

return WeaponSystem
