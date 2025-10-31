--[[
    HUD.lua
    Main heads-up display showing health, stamina, survival stats, and inventory
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create main HUD
local HUD = {}

function HUD:CreateMainHUD()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameHUD"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Health Bar
    local healthFrame = Instance.new("Frame")
    healthFrame.Name = "HealthFrame"
    healthFrame.Size = UDim2.new(0, 300, 0, 30)
    healthFrame.Position = UDim2.new(0, 20, 1, -100)
    healthFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    healthFrame.BorderSizePixel = 2
    healthFrame.Parent = screenGui

    local healthBar = Instance.new("Frame")
    healthBar.Name = "Bar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthFrame

    local healthText = Instance.new("TextLabel")
    healthText.Name = "Text"
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.BackgroundTransparency = 1
    healthText.Text = "HEALTH: 100"
    healthText.TextColor3 = Color3.new(1, 1, 1)
    healthText.TextScaled = true
    healthText.Font = Enum.Font.SourceSansBold
    healthText.ZIndex = 2
    healthText.Parent = healthFrame

    -- Stamina Bar
    local staminaFrame = Instance.new("Frame")
    staminaFrame.Name = "StaminaFrame"
    staminaFrame.Size = UDim2.new(0, 300, 0, 20)
    staminaFrame.Position = UDim2.new(0, 20, 1, -65)
    staminaFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    staminaFrame.BorderSizePixel = 2
    staminaFrame.Parent = screenGui

    local staminaBar = Instance.new("Frame")
    staminaBar.Name = "Bar"
    staminaBar.Size = UDim2.new(1, 0, 1, 0)
    staminaBar.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    staminaBar.BorderSizePixel = 0
    staminaBar.Parent = staminaFrame

    local staminaText = Instance.new("TextLabel")
    staminaText.Name = "Text"
    staminaText.Size = UDim2.new(1, 0, 1, 0)
    staminaText.BackgroundTransparency = 1
    staminaText.Text = "STAMINA: 100"
    staminaText.TextColor3 = Color3.new(1, 1, 1)
    staminaText.TextScaled = true
    staminaText.Font = Enum.Font.SourceSansBold
    staminaText.ZIndex = 2
    staminaText.Parent = staminaFrame

    -- Hunger & Thirst
    local survivalFrame = Instance.new("Frame")
    survivalFrame.Name = "SurvivalFrame"
    survivalFrame.Size = UDim2.new(0, 150, 0, 80)
    survivalFrame.Position = UDim2.new(0, 20, 0, 20)
    survivalFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    survivalFrame.BackgroundTransparency = 0.3
    survivalFrame.BorderSizePixel = 2
    survivalFrame.Parent = screenGui

    local hungerText = Instance.new("TextLabel")
    hungerText.Name = "Hunger"
    hungerText.Size = UDim2.new(1, -10, 0, 30)
    hungerText.Position = UDim2.new(0, 5, 0, 5)
    hungerText.BackgroundTransparency = 1
    hungerText.Text = "🍖 Hunger: 100"
    hungerText.TextColor3 = Color3.fromRGB(255, 200, 100)
    hungerText.TextScaled = true
    hungerText.Font = Enum.Font.SourceSans
    hungerText.TextXAlignment = Enum.TextXAlignment.Left
    hungerText.Parent = survivalFrame

    local thirstText = Instance.new("TextLabel")
    thirstText.Name = "Thirst"
    thirstText.Size = UDim2.new(1, -10, 0, 30)
    thirstText.Position = UDim2.new(0, 5, 0, 40)
    thirstText.BackgroundTransparency = 1
    thirstText.Text = "💧 Thirst: 100"
    thirstText.TextColor3 = Color3.fromRGB(100, 200, 255)
    thirstText.TextScaled = true
    thirstText.Font = Enum.Font.SourceSans
    thirstText.TextXAlignment = Enum.TextXAlignment.Left
    thirstText.Parent = survivalFrame

    -- Weapon Info
    local weaponFrame = Instance.new("Frame")
    weaponFrame.Name = "WeaponFrame"
    weaponFrame.Size = UDim2.new(0, 200, 0, 80)
    weaponFrame.Position = UDim2.new(1, -220, 1, -100)
    weaponFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    weaponFrame.BackgroundTransparency = 0.3
    weaponFrame.BorderSizePixel = 2
    weaponFrame.Parent = screenGui

    local weaponNameText = Instance.new("TextLabel")
    weaponNameText.Name = "WeaponName"
    weaponNameText.Size = UDim2.new(1, -10, 0, 30)
    weaponNameText.Position = UDim2.new(0, 5, 0, 5)
    weaponNameText.BackgroundTransparency = 1
    weaponNameText.Text = "No Weapon"
    weaponNameText.TextColor3 = Color3.new(1, 1, 1)
    weaponNameText.TextScaled = true
    weaponNameText.Font = Enum.Font.SourceSansBold
    weaponNameText.Parent = weaponFrame

    local ammoText = Instance.new("TextLabel")
    ammoText.Name = "Ammo"
    ammoText.Size = UDim2.new(1, -10, 0, 40)
    ammoText.Position = UDim2.new(0, 5, 0, 35)
    ammoText.BackgroundTransparency = 1
    ammoText.Text = "0 / 0"
    ammoText.TextColor3 = Color3.new(1, 1, 1)
    ammoText.TextScaled = true
    ammoText.Font = Enum.Font.SourceSansBold
    ammoText.Parent = weaponFrame

    -- Status Effects
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(0, 200, 0, 100)
    statusFrame.Position = UDim2.new(1, -220, 0, 20)
    statusFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    statusFrame.BackgroundTransparency = 0.3
    statusFrame.BorderSizePixel = 2
    statusFrame.Parent = screenGui

    local statusTitle = Instance.new("TextLabel")
    statusTitle.Name = "Title"
    statusTitle.Size = UDim2.new(1, 0, 0, 20)
    statusTitle.BackgroundTransparency = 1
    statusTitle.Text = "STATUS EFFECTS"
    statusTitle.TextColor3 = Color3.new(1, 1, 1)
    statusTitle.Font = Enum.Font.SourceSansBold
    statusTitle.TextScaled = true
    statusTitle.Parent = statusFrame

    local statusList = Instance.new("ScrollingFrame")
    statusList.Name = "List"
    statusList.Size = UDim2.new(1, -10, 1, -25)
    statusList.Position = UDim2.new(0, 5, 0, 20)
    statusList.BackgroundTransparency = 1
    statusList.ScrollBarThickness = 6
    statusList.Parent = statusFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = statusList

    self.ScreenGui = screenGui
end

function HUD:UpdateHealth(health, maxHealth)
    local healthFrame = self.ScreenGui:FindFirstChild("HealthFrame")
    if healthFrame then
        local bar = healthFrame:FindFirstChild("Bar")
        local text = healthFrame:FindFirstChild("Text")

        local percentage = health / maxHealth
        bar.Size = UDim2.new(percentage, 0, 1, 0)
        text.Text = "HEALTH: " .. math.floor(health)

        -- Change color based on health
        if percentage > 0.6 then
            bar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        elseif percentage > 0.3 then
            bar.BackgroundColor3 = Color3.fromRGB(220, 150, 50)
        else
            bar.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    end
end

function HUD:UpdateStamina(stamina, maxStamina)
    local staminaFrame = self.ScreenGui:FindFirstChild("StaminaFrame")
    if staminaFrame then
        local bar = staminaFrame:FindFirstChild("Bar")
        local text = staminaFrame:FindFirstChild("Text")

        local percentage = stamina / maxStamina
        bar.Size = UDim2.new(percentage, 0, 1, 0)
        text.Text = "STAMINA: " .. math.floor(stamina)
    end
end

function HUD:UpdateSurvival(hunger, thirst, maxHunger, maxThirst)
    local survivalFrame = self.ScreenGui:FindFirstChild("SurvivalFrame")
    if survivalFrame then
        local hungerText = survivalFrame:FindFirstChild("Hunger")
        local thirstText = survivalFrame:FindFirstChild("Thirst")

        hungerText.Text = "🍖 Hunger: " .. math.floor(hunger)
        thirstText.Text = "💧 Thirst: " .. math.floor(thirst)

        -- Change colors based on levels
        if hunger < 20 then
            hungerText.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            hungerText.TextColor3 = Color3.fromRGB(255, 200, 100)
        end

        if thirst < 20 then
            thirstText.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            thirstText.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
    end
end

function HUD:UpdateWeapon(weaponName, currentAmmo, reserveAmmo)
    local weaponFrame = self.ScreenGui:FindFirstChild("WeaponFrame")
    if weaponFrame then
        local nameText = weaponFrame:FindFirstChild("WeaponName")
        local ammoText = weaponFrame:FindFirstChild("Ammo")

        nameText.Text = weaponName or "No Weapon"
        ammoText.Text = currentAmmo .. " / " .. reserveAmmo
    end
end

function HUD:UpdateStatusEffects(effects)
    local statusFrame = self.ScreenGui:FindFirstChild("StatusFrame")
    if statusFrame then
        local statusList = statusFrame:FindFirstChild("List")
        statusList:ClearAllChildren()

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = statusList

        for _, effect in pairs(effects) do
            local effectLabel = Instance.new("TextLabel")
            effectLabel.Size = UDim2.new(1, 0, 0, 20)
            effectLabel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            effectLabel.Text = effect
            effectLabel.TextColor3 = Color3.new(1, 1, 1)
            effectLabel.Font = Enum.Font.SourceSans
            effectLabel.TextScaled = true
            effectLabel.Parent = statusList
        end
    end
end

-- Initialize
HUD:CreateMainHUD()

print("HUD initialized")

return HUD
