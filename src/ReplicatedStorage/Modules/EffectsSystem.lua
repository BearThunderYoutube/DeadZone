--[[
    EffectsSystem.lua
    Visual and sound effects for game events
]]

local EffectsSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Sound effects (placeholder IDs - replace with actual sound IDs)
local Sounds = {
    Gunshot = {
        AK47 = "rbxassetid://1234567890",
        M4A1 = "rbxassetid://1234567891",
        Glock19 = "rbxassetid://1234567892",
        Shotgun = "rbxassetid://1234567893",
        SVD = "rbxassetid://1234567894"
    },
    Impact = {
        Flesh = "rbxassetid://1234567895",
        Metal = "rbxassetid://1234567896",
        Concrete = "rbxassetid://1234567897",
        Wood = "rbxassetid://1234567898"
    },
    UI = {
        ItemPickup = "rbxassetid://1234567899",
        ItemDrop = "rbxassetid://1234567900",
        MenuClick = "rbxassetid://1234567901",
        LevelUp = "rbxassetid://1234567902"
    },
    Ambient = {
        Footsteps = "rbxassetid://1234567903",
        Reload = "rbxassetid://1234567904",
        Healing = "rbxassetid://1234567905",
        ZombieGrowl = "rbxassetid://1234567906"
    }
}

function EffectsSystem:PlaySound(soundType, soundName, position, parent)
    local soundId = nil

    if Sounds[soundType] and Sounds[soundType][soundName] then
        soundId = Sounds[soundType][soundName]
    end

    if not soundId then
        warn("Sound not found:", soundType, soundName)
        return nil
    end

    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.5

    if position then
        -- 3D sound
        local soundPart = Instance.new("Part")
        soundPart.Transparency = 1
        soundPart.CanCollide = false
        soundPart.Anchored = true
        soundPart.Size = Vector3.new(1, 1, 1)
        soundPart.Position = position
        soundPart.Parent = workspace

        sound.Parent = soundPart
        sound:Play()

        Debris:AddItem(soundPart, sound.TimeLength + 0.5)
    else
        -- 2D sound
        sound.Parent = parent or workspace
        sound:Play()

        Debris:AddItem(sound, sound.TimeLength + 0.5)
    end

    return sound
end

function EffectsSystem:CreateMuzzleFlash(position, direction)
    -- Simplified muzzle flash (Apoc style)
    local flash = Instance.new("Part")
    flash.Name = "MuzzleFlash"
    flash.Size = Vector3.new(0.3, 0.3, 1)
    flash.CFrame = CFrame.new(position, position + direction)
    flash.Anchored = true
    flash.CanCollide = false
    flash.Material = Enum.Material.Neon
    flash.BrickColor = BrickColor.new("Bright yellow")
    flash.Transparency = 0.5
    flash.Parent = workspace

    Debris:AddItem(flash, 0.05)

    return flash
end

function EffectsSystem:CreateBulletTracer(startPos, endPos, color)
    -- Simplified tracer (Apoc style - very minimal)
    local distance = (startPos - endPos).Magnitude

    -- Only show tracers for long shots
    if distance < 50 then return nil end

    local beam = Instance.new("Part")
    beam.Name = "BulletTracer"
    beam.Size = Vector3.new(0.05, 0.05, distance)
    beam.CFrame = CFrame.new((startPos + endPos) / 2, endPos)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Material = Enum.Material.Neon
    beam.BrickColor = color or BrickColor.new("White")
    beam.Transparency = 0.7
    beam.Parent = workspace

    Debris:AddItem(beam, 0.05)

    return beam
end

function EffectsSystem:CreateImpactEffect(position, surfaceType)
    -- Create spark particles
    local attachment = Instance.new("Attachment")
    attachment.Position = position
    attachment.Parent = workspace.Terrain

    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
    particles.Rate = 100
    particles.Lifetime = NumberRange.new(0.2, 0.5)
    particles.Speed = NumberRange.new(5, 10)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Enabled = false
    particles.Parent = attachment

    -- Emit burst
    particles:Emit(10)

    Debris:AddItem(attachment, 1)

    return particles
end

function EffectsSystem:CreateBloodEffect(position)
    -- Simplified blood (Apoc style - just a red decal)
    local blood = Instance.new("Part")
    blood.Name = "Blood"
    blood.Size = Vector3.new(1, 0.1, 1)
    blood.Position = position
    blood.Anchored = true
    blood.CanCollide = false
    blood.BrickColor = BrickColor.new("Bright red")
    blood.Material = Enum.Material.SmoothPlastic
    blood.Transparency = 0.5
    blood.Parent = workspace

    Debris:AddItem(blood, 10) -- Clean up after 10 seconds

    return blood
end

function EffectsSystem:CreateHitMarker(player, isHeadshot)
    -- Fire to client
    local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("ShowHitMarker")
    if event then
        event:FireClient(player, isHeadshot)
    end
end

function EffectsSystem:CreateDamageNumber(position, damage, isHeadshot)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = workspace

    -- Create part to attach to
    local part = Instance.new("Part")
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.Size = Vector3.new(1, 1, 1)
    part.Position = position
    part.Parent = workspace

    billboard.Adornee = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "-" .. math.floor(damage)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard

    if isHeadshot then
        label.TextColor3 = Color3.fromRGB(255, 50, 50)
        label.Text = label.Text .. " [HS]"
    else
        label.TextColor3 = Color3.new(1, 1, 1)
    end

    -- Animate upwards
    local moveTween = TweenService:Create(billboard, TweenInfo.new(1), {
        StudsOffset = Vector3.new(0, 5, 0)
    })
    moveTween:Play()

    -- Fade out
    local fadeTween = TweenService:Create(label, TweenInfo.new(1), {
        TextTransparency = 1
    })
    fadeTween:Play()

    Debris:AddItem(part, 1.2)

    return billboard
end

function EffectsSystem:CreateExplosion(position, radius, damage)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = radius
    explosion.BlastPressure = 500000
    explosion.Parent = workspace

    -- Deal damage to players in radius
    local hitPlayers = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - position).Magnitude
            if distance <= radius then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local damageAmount = damage * (1 - (distance / radius))
                    humanoid:TakeDamage(damageAmount)
                    table.insert(hitPlayers, player)
                end
            end
        end
    end

    return explosion, hitPlayers
end

function EffectsSystem:CreateScreenShake(player, intensity, duration)
    local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("ScreenShake")
    if event then
        event:FireClient(player, intensity, duration)
    end
end

function EffectsSystem:CreateLootBeam(position, rarity)
    local beam = Instance.new("Part")
    beam.Name = "LootBeam"
    beam.Size = Vector3.new(0.5, 100, 0.5)
    beam.Position = position + Vector3.new(0, 50, 0)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Material = Enum.Material.Neon
    beam.Transparency = 0.6

    -- Color based on rarity
    local colors = {
        Common = Color3.fromRGB(150, 150, 150),
        Uncommon = Color3.fromRGB(100, 200, 100),
        Rare = Color3.fromRGB(100, 100, 255),
        Epic = Color3.fromRGB(200, 100, 255),
        Legendary = Color3.fromRGB(255, 150, 50)
    }
    beam.Color = colors[rarity] or colors.Common

    beam.Parent = workspace

    -- Rotate
    task.spawn(function()
        while beam.Parent do
            beam.CFrame = beam.CFrame * CFrame.Angles(0, math.rad(2), 0)
            task.wait()
        end
    end)

    return beam
end

return EffectsSystem
