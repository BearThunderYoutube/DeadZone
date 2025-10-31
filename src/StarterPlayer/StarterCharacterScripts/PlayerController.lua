--[[
    PlayerController.lua
    Handles player movement, stamina, and stance
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameSettings = require(ReplicatedStorage.Modules.GameSettings)

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

-- State
local stamina = GameSettings.Player.MaxStamina
local isSprinting = false
local isCrouching = false
local isAiming = false

-- Input connections
local sprintKey = Enum.KeyCode.LeftShift
local crouchKey = Enum.KeyCode.LeftControl
local aimKey = Enum.UserInputType.MouseButton2

-- Function to update stamina
local function updateStamina(dt)
    if isSprinting and humanoid.MoveDirection.Magnitude > 0 then
        stamina = math.max(0, stamina - GameSettings.Player.StaminaDrainRate * dt)

        if stamina <= 0 then
            isSprinting = false
            humanoid.WalkSpeed = GameSettings.Player.WalkSpeed
        end
    else
        stamina = math.min(GameSettings.Player.MaxStamina, stamina + GameSettings.Player.StaminaRegenRate * dt)
    end
end

-- Function to handle sprinting
local function handleSprint(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == sprintKey then
        if stamina > 0 and not isCrouching then
            isSprinting = true
            humanoid.WalkSpeed = GameSettings.Player.SprintSpeed
        end
    end
end

local function stopSprint(input, gameProcessed)
    if input.KeyCode == sprintKey then
        isSprinting = false
        if not isCrouching then
            humanoid.WalkSpeed = GameSettings.Player.WalkSpeed
        end
    end
end

-- Function to handle crouching
local function handleCrouch(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == crouchKey then
        isCrouching = not isCrouching

        if isCrouching then
            isSprinting = false
            humanoid.WalkSpeed = GameSettings.Player.CrouchSpeed
            -- Scale character down slightly
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Size = part.Size * Vector3.new(1, 0.7, 1)
                end
            end
        else
            humanoid.WalkSpeed = GameSettings.Player.WalkSpeed
            -- Restore character size
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Size = part.Size / Vector3.new(1, 0.7, 1)
                end
            end
        end
    end
end

-- Function to handle aiming
local function handleAiming(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == aimKey then
        isAiming = true
        -- Trigger aim event
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("OnAim"):FireServer(true)
    end
end

local function stopAiming(input, gameProcessed)
    if input.UserInputType == aimKey then
        isAiming = false
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("OnAim"):FireServer(false)
    end
end

-- Connect inputs
UserInputService.InputBegan:Connect(handleSprint)
UserInputService.InputEnded:Connect(stopSprint)
UserInputService.InputBegan:Connect(handleCrouch)
UserInputService.InputBegan:Connect(handleAiming)
UserInputService.InputEnded:Connect(stopAiming)

-- Update loop
RunService.Heartbeat:Connect(function(dt)
    updateStamina(dt)

    -- Send stamina updates to server
    if tick() % 1 < dt then -- Update every second
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateStamina"):FireServer(stamina)
    end
end)

print("PlayerController loaded for", player.Name)
