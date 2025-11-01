--[[
    MinimapUI.lua
    Minimap, compass, and navigation UI
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MinimapUI = {}

function MinimapUI:CreateMinimapUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MinimapUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Minimap Frame
    local minimapFrame = Instance.new("Frame")
    minimapFrame.Name = "MinimapFrame"
    minimapFrame.Size = UDim2.new(0, 200, 0, 200)
    minimapFrame.Position = UDim2.new(1, -220, 0, 20)
    minimapFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    minimapFrame.BackgroundTransparency = 0.3
    minimapFrame.BorderSizePixel = 3
    minimapFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    minimapFrame.Parent = screenGui

    -- Minimap Image (ViewportFrame or ImageLabel)
    local minimapView = Instance.new("ImageLabel")
    minimapView.Name = "MapView"
    minimapView.Size = UDim2.new(1, -10, 1, -40)
    minimapView.Position = UDim2.new(0, 5, 0, 35)
    minimapView.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    minimapView.BorderSizePixel = 0
    minimapView.Image = "" -- Add map texture here
    minimapView.Parent = minimapFrame

    -- Player marker
    local playerMarker = Instance.new("Frame")
    playerMarker.Name = "PlayerMarker"
    playerMarker.Size = UDim2.new(0, 10, 0, 10)
    playerMarker.Position = UDim2.new(0.5, -5, 0.5, -5)
    playerMarker.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    playerMarker.BorderSizePixel = 0
    playerMarker.ZIndex = 3
    playerMarker.Parent = minimapView

    -- Marker rotation indicator
    local markerArrow = Instance.new("ImageLabel")
    markerArrow.Name = "Arrow"
    markerArrow.Size = UDim2.new(0, 20, 0, 20)
    markerArrow.Position = UDim2.new(0.5, -10, 0.5, -10)
    markerArrow.BackgroundTransparency = 1
    markerArrow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Replace with arrow
    markerArrow.ImageColor3 = Color3.fromRGB(50, 200, 50)
    markerArrow.ZIndex = 4
    markerArrow.Parent = minimapView

    -- Compass bar
    local compassFrame = Instance.new("Frame")
    compassFrame.Name = "CompassFrame"
    compassFrame.Size = UDim2.new(0, 400, 0, 40)
    compassFrame.Position = UDim2.new(0.5, -200, 0, 20)
    compassFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    compassFrame.BackgroundTransparency = 0.3
    compassFrame.BorderSizePixel = 2
    compassFrame.Parent = screenGui

    -- Compass directions
    local compassLabel = Instance.new("TextLabel")
    compassLabel.Name = "CompassLabel"
    compassLabel.Size = UDim2.new(1, 0, 1, 0)
    compassLabel.BackgroundTransparency = 1
    compassLabel.Text = "N"
    compassLabel.TextColor3 = Color3.new(1, 1, 1)
    compassLabel.TextScaled = true
    compassLabel.Font = Enum.Font.SourceSansBold
    compassLabel.Parent = compassFrame

    -- Coordinates display
    local coordsFrame = Instance.new("Frame")
    coordsFrame.Name = "CoordsFrame"
    coordsFrame.Size = UDim2.new(0, 150, 0, 30)
    coordsFrame.Position = UDim2.new(1, -220, 0, 230)
    coordsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    coordsFrame.BackgroundTransparency = 0.3
    coordsFrame.BorderSizePixel = 2
    coordsFrame.Parent = screenGui

    local coordsLabel = Instance.new("TextLabel")
    coordsLabel.Name = "Coords"
    coordsLabel.Size = UDim2.new(1, 0, 1, 0)
    coordsLabel.BackgroundTransparency = 1
    coordsLabel.Text = "X: 0, Z: 0"
    coordsLabel.TextColor3 = Color3.new(1, 1, 1)
    coordsLabel.TextScaled = true
    coordsLabel.Font = Enum.Font.SourceSans
    coordsLabel.Parent = coordsFrame

    self.ScreenGui = screenGui
    self.MinimapView = minimapView
    self.PlayerMarker = markerArrow
    self.CompassLabel = compassLabel
    self.CoordsLabel = coordsLabel
end

function MinimapUI:UpdateMinimap()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local character = player.Character
    local humanoidRootPart = character.HumanoidRootPart

    -- Update coordinates
    local pos = humanoidRootPart.Position
    self.CoordsLabel.Text = string.format("X: %d, Z: %d", math.floor(pos.X), math.floor(pos.Z))

    -- Update compass direction
    local camera = workspace.CurrentCamera
    if camera then
        local cameraLook = camera.CFrame.LookVector
        local angle = math.atan2(-cameraLook.X, -cameraLook.Z)
        local degrees = math.deg(angle)

        -- Convert to compass direction
        local direction = "N"
        if degrees >= -22.5 and degrees < 22.5 then
            direction = "N"
        elseif degrees >= 22.5 and degrees < 67.5 then
            direction = "NE"
        elseif degrees >= 67.5 and degrees < 112.5 then
            direction = "E"
        elseif degrees >= 112.5 and degrees < 157.5 then
            direction = "SE"
        elseif degrees >= 157.5 or degrees < -157.5 then
            direction = "S"
        elseif degrees >= -157.5 and degrees < -112.5 then
            direction = "SW"
        elseif degrees >= -112.5 and degrees < -67.5 then
            direction = "W"
        elseif degrees >= -67.5 and degrees < -22.5 then
            direction = "NW"
        end

        self.CompassLabel.Text = direction

        -- Rotate player marker
        self.PlayerMarker.Rotation = degrees
    end
end

-- Raid timer removed - open world mode

function MinimapUI:AddMarker(position, markerType, label)
    -- Add custom markers to minimap (extraction points, objectives, etc.)
    local marker = Instance.new("Frame")
    marker.Size = UDim2.new(0, 8, 0, 8)
    marker.BackgroundColor3 = markerType == "Extraction" and Color3.fromRGB(100, 200, 255) or
                              markerType == "Objective" and Color3.fromRGB(255, 200, 100) or
                              Color3.fromRGB(200, 200, 200)
    marker.BorderSizePixel = 0
    marker.ZIndex = 2
    marker.Parent = self.MinimapView

    -- Calculate position relative to player
    -- This would need actual map scaling logic

    return marker
end

function MinimapUI:ToggleMinimap()
    self.ScreenGui.MinimapFrame.Visible = not self.ScreenGui.MinimapFrame.Visible
end

-- Initialize
MinimapUI:CreateMinimapUI()

-- Update loop
RunService.Heartbeat:Connect(function()
    MinimapUI:UpdateMinimap()
end)

print("MinimapUI initialized - Open World Mode")

return MinimapUI
