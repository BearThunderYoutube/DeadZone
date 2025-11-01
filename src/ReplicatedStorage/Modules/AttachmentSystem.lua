--[[
    AttachmentSystem.lua
    Weapon attachment and modification system
]]

local AttachmentSystem = {}
AttachmentSystem.__index = AttachmentSystem

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Attachment slots for weapons
local AttachmentSlots = {
    ["AK47"] = {"Muzzle", "Sight", "Grip", "Magazine"},
    ["M4A1"] = {"Muzzle", "Sight", "Grip", "Magazine", "Stock"},
    ["SVD"] = {"Muzzle", "Sight", "Magazine"},
    ["Shotgun"] = {"Sight", "Magazine"},
    ["MP5"] = {"Muzzle", "Sight", "Grip", "Magazine"},
    ["Glock19"] = {"Muzzle", "Sight", "Magazine"}
}

-- Attachment effects
local Attachments = {
    -- Muzzles
    ["Suppressor"] = {
        Slot = "Muzzle",
        Effects = {
            NoiseReduction = 0.8,
            RecoilReduction = 0.1,
            RangeBonus = -0.05
        }
    },
    ["Compensator"] = {
        Slot = "Muzzle",
        Effects = {
            RecoilReduction = 0.25,
            SpreadReduction = 0.15
        }
    },
    ["FlashHider"] = {
        Slot = "Muzzle",
        Effects = {
            FlashReduction = 0.9,
            RecoilReduction = 0.08
        }
    },

    -- Sights
    ["RedDot"] = {
        Slot = "Sight",
        Effects = {
            AimSpeed = 0.1,
            AccuracyBonus = 0.15
        }
    },
    ["Holographic"] = {
        Slot = "Sight",
        Effects = {
            AimSpeed = 0.05,
            AccuracyBonus = 0.20
        }
    },
    ["ACOG"] = {
        Slot = "Sight",
        Effects = {
            Zoom = 4,
            AccuracyBonus = 0.30,
            AimSpeed = -0.15
        }
    },
    ["ThermalScope"] = {
        Slot = "Sight",
        Effects = {
            Zoom = 6,
            ThermalVision = true,
            AccuracyBonus = 0.35,
            AimSpeed = -0.25
        }
    },

    -- Grips
    ["VerticalGrip"] = {
        Slot = "Grip",
        Effects = {
            RecoilReduction = 0.15,
            AimStability = 0.20
        }
    },
    ["AngledGrip"] = {
        Slot = "Grip",
        Effects = {
            AimSpeed = 0.15,
            SpreadReduction = 0.10
        }
    },

    -- Magazines
    ["ExtendedMag"] = {
        Slot = "Magazine",
        Effects = {
            MagazineSizeMultiplier = 1.5,
            ReloadSpeed = -0.2
        }
    },
    ["FastMag"] = {
        Slot = "Magazine",
        Effects = {
            ReloadSpeed = 0.3
        }
    },
    ["DrumMag"] = {
        Slot = "Magazine",
        Effects = {
            MagazineSizeMultiplier = 2.0,
            ReloadSpeed = -0.4,
            WeightIncrease = 0.5
        }
    },

    -- Stocks
    ["LightweightStock"] = {
        Slot = "Stock",
        Effects = {
            AimSpeed = 0.20,
            SprintSpeed = 0.10,
            RecoilIncrease = 0.10
        }
    },
    ["HeavyStock"] = {
        Slot = "Stock",
        Effects = {
            RecoilReduction = 0.25,
            AimSpeed = -0.10
        }
    }
}

function AttachmentSystem.new(weaponName)
    local self = setmetatable({}, AttachmentSystem)

    self.WeaponName = weaponName
    self.AvailableSlots = AttachmentSlots[weaponName] or {}
    self.AttachedMods = {}

    return self
end

function AttachmentSystem:AttachMod(attachmentName)
    local attachment = Attachments[attachmentName]
    if not attachment then
        warn("Attachment not found:", attachmentName)
        return false
    end

    -- Check if weapon has this slot
    local hasSlot = false
    for _, slot in pairs(self.AvailableSlots) do
        if slot == attachment.Slot then
            hasSlot = true
            break
        end
    end

    if not hasSlot then
        warn("Weapon does not have", attachment.Slot, "slot")
        return false
    end

    -- Attach mod
    self.AttachedMods[attachment.Slot] = {
        Name = attachmentName,
        Data = attachment
    }

    return true
end

function AttachmentSystem:RemoveMod(slotType)
    if self.AttachedMods[slotType] then
        local removed = self.AttachedMods[slotType]
        self.AttachedMods[slotType] = nil
        return removed.Name
    end
    return nil
end

function AttachmentSystem:GetModifiedStats(baseStats)
    local modifiedStats = {}
    for key, value in pairs(baseStats) do
        modifiedStats[key] = value
    end

    for slot, mod in pairs(self.AttachedMods) do
        for effect, value in pairs(mod.Data.Effects) do
            if effect == "RecoilReduction" then
                modifiedStats.Recoil = (modifiedStats.Recoil or 1) * (1 - value)
            elseif effect == "AccuracyBonus" then
                modifiedStats.Spread = (modifiedStats.Spread or 0.05) * (1 - value)
            elseif effect == "MagazineSizeMultiplier" then
                modifiedStats.MagazineSize = math.floor(modifiedStats.MagazineSize * value)
            elseif effect == "ReloadSpeed" then
                modifiedStats.ReloadTime = modifiedStats.ReloadTime * (1 - value)
            elseif effect == "AimSpeed" then
                modifiedStats.AimDownSightTime = modifiedStats.AimDownSightTime * (1 - value)
            elseif effect == "NoiseReduction" then
                modifiedStats.NoiseLevel = (modifiedStats.NoiseLevel or 1) * (1 - value)
            elseif effect == "RangeBonus" then
                modifiedStats.Range = modifiedStats.Range * (1 + value)
            elseif effect == "Zoom" then
                modifiedStats.ZoomLevel = value
            elseif effect == "ThermalVision" then
                modifiedStats.ThermalVision = true
            end
        end
    end

    return modifiedStats
end

function AttachmentSystem:GetAttachments()
    return self.AttachedMods
end

function AttachmentSystem:CanAttach(attachmentName)
    local attachment = Attachments[attachmentName]
    if not attachment then return false end

    for _, slot in pairs(self.AvailableSlots) do
        if slot == attachment.Slot then
            return true
        end
    end

    return false
end

AttachmentSystem.Attachments = Attachments
AttachmentSystem.AttachmentSlots = AttachmentSlots

return AttachmentSystem
