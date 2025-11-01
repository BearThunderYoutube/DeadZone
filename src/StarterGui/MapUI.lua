--[[
    MapUI.lua
    Full-screen accurate map with player tracking
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local GameSettings = require(ReplicatedStorage.Modules.GameSettings)

local MapUI = {}
MapUI.IsOpen = false
MapUI.ExtractionMarkers = {}
MapUI.LootMarkers = {}

-- Map configuration
local MAP_SIZE = GameSettings.Map.Size
local MAP_CENTER = GameSettings.Map.CenterPosition
local MAP_UI_SIZE = 700 -- pixels

function MapUI:CreateMapUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MapUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Main map frame (full screen when open)
    local mapFrame = Instance.new("Frame")
    mapFrame.Name = "MapFrame"
    mapFrame.Size = UDim2.new(0, MAP_UI_SIZE, 0, MAP_UI_SIZE)
    mapFrame.Position = UDim2.new(0.5, -MAP_UI_SIZE/2, 0.5, -MAP_UI_SIZE/2)
    mapFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mapFrame.BorderSizePixel = 3
    mapFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    mapFrame.Visible = false
    mapFrame.Parent = screenGui

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    title.BorderSizePixel = 0
    title.Text = "MAP - Press M to close"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = mapFrame

    -- Map display area
    local mapDisplay = Instance.new("Frame")
    mapDisplay.Name = "MapDisplay"
    mapDisplay.Size = UDim2.new(1, -20, 1, -60)
    mapDisplay.Position = UDim2.new(0, 10, 0, 50)
    mapDisplay.BackgroundColor3 = Color3.fromRGB(60, 70, 60) -- Greenish terrain color
    mapDisplay.BorderSizePixel = 2
    mapDisplay.BorderColor3 = Color3.fromRGB(80, 80, 80)
    mapDisplay.Parent = mapFrame

    -- Grid lines
    self:CreateGrid(mapDisplay)

    -- Extraction point markers
    self:CreateExtractionMarkers(mapDisplay)

    -- Player marker
    local playerMarker = Instance.new("Frame")
    playerMarker.Name = "PlayerMarker"
    playerMarker.Size = UDim2.new(0, 16, 0, 16)
    playerMarker.AnchorPoint = Vector2.new(0.5, 0.5)
    playerMarker.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    playerMarker.BorderSizePixel = 2
    playerMarker.BorderColor3 = Color3.new(0, 0, 0)
    playerMarker.ZIndex = 10
    playerMarker.Parent = mapDisplay

    -- Direction arrow on player
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 24, 0, 24)
    arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.Position = UDim2.new(0.5, 0, 0.5, 0)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    arrow.ImageColor3 = Color3.new(1, 1, 1)
    arrow.ZIndex = 11
    arrow.Parent = playerMarker

    -- Coordinates label
    local coordsLabel = Instance.new("TextLabel")
    coordsLabel.Name = "Coords"
    coordsLabel.Size = UDim2.new(0, 200, 0, 30)
    coordsLabel.Position = UDim2.new(0, 10, 1, -40)
    coordsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    coordsLabel.BackgroundTransparency = 0.3
    coordsLabel.Text = "X: 0, Z: 0"
    coordsLabel.TextColor3 = Color3.new(1, 1, 1)
    coordsLabel.Font = Enum.Font.SourceSansBold
    coordsLabel.TextSize = 16
    coordsLabel.Parent = mapFrame

    -- Legend
    local legend = Instance.new("TextLabel")
    legend.Name = "Legend"
    legend.Size = UDim2.new(0, 250, 0, 80)
    legend.Position = UDim2.new(1, -260, 1, -90)
    legend.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    legend.BackgroundTransparency = 0.3
    legend.BorderSizePixel = 1
    legend.Text = "🟢 You\n🔵 Extraction Point\n🟡 Loot Container"
    legend.TextColor3 = Color3.new(1, 1, 1)
    legend.Font = Enum.Font.SourceSans
    legend.TextSize = 14
    legend.TextXAlignment = Enum.TextXAlignment.Left
    legend.TextYAlignment = Enum.TextYAlignment.Top
    legend.Parent = mapFrame

    self.ScreenGui = screenGui
    self.MapFrame = mapFrame
    self.MapDisplay = mapDisplay
    self.PlayerMarker = playerMarker
    self.Arrow = arrow
    self.CoordsLabel = coordsLabel
end

function MapUI:CreateGrid(mapDisplay)
    -- Create grid lines every 512 studs (4x4 grid)
    local gridSize = 4
    local lineThickness = 2

    for i = 0, gridSize do
        -- Vertical lines
        local vLine = Instance.new("Frame")
        vLine.Name = "GridLineV" .. i
        vLine.Size = UDim2.new(0, lineThickness, 1, 0)
        vLine.Position = UDim2.new(i / gridSize, -lineThickness/2, 0, 0)
        vLine.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
        vLine.BorderSizePixel = 0
        vLine.ZIndex = 2
        vLine.Parent = mapDisplay

        -- Horizontal lines
        local hLine = Instance.new("Frame")
        hLine.Name = "GridLineH" .. i
        hLine.Size = UDim2.new(1, 0, 0, lineThickness)
        hLine.Position = UDim2.new(0, 0, i / gridSize, -lineThickness/2)
        hLine.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
        hLine.BorderSizePixel = 0
        hLine.ZIndex = 2
        hLine.Parent = mapDisplay

        -- Grid labels
        if i < gridSize then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 30, 0, 20)
            label.Position = UDim2.new(i / gridSize, 5, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = string.char(65 + i) -- A, B, C, D
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 14
            label.ZIndex = 3
            label.Parent = mapDisplay

            local labelNum = Instance.new("TextLabel")
            labelNum.Size = UDim2.new(0, 30, 0, 20)
            labelNum.Position = UDim2.new(0, 5, i / gridSize, 5)
            labelNum.BackgroundTransparency = 1
            labelNum.Text = tostring(i + 1)
            labelNum.TextColor3 = Color3.fromRGB(200, 200, 200)
            labelNum.Font = Enum.Font.SourceSansBold
            labelNum.TextSize = 14
            labelNum.ZIndex = 3
            labelNum.Parent = mapDisplay
        end
    end
end

function MapUI:CreateExtractionMarkers(mapDisplay)
    -- Extraction point positions (from ExtractionSystem)
    local extractionPoints = {
        {Position = Vector3.new(100, 5, 100), Name = "North Checkpoint"},
        {Position = Vector3.new(-100, 5, 100), Name = "West Outpost"},
        {Position = Vector3.new(100, 5, -100), Name = "South Bridge"},
        {Position = Vector3.new(-100, 5, -100), Name = "East Harbor"},
        {Position = Vector3.new(0, 5, 0), Name = "Central Helipad"}
    }

    for _, extraction in pairs(extractionPoints) do
        local mapPos = self:WorldToMapPosition(extraction.Position)

        local marker = Instance.new("Frame")
        marker.Name = "Extraction_" .. extraction.Name
        marker.Size = UDim2.new(0, 12, 0, 12)
        marker.AnchorPoint = Vector2.new(0.5, 0.5)
        marker.Position = mapPos
        marker.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        marker.BorderSizePixel = 2
        marker.BorderColor3 = Color3.new(0, 0, 0)
        marker.ZIndex = 5
        marker.Parent = mapDisplay

        -- Label
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 120, 0, 16)
        label.Position = UDim2.new(0, -60, 1, 2)
        label.AnchorPoint = Vector2.new(0, 0)
        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        label.BackgroundTransparency = 0.5
        label.Text = extraction.Name
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 10
        label.TextScaled = true
        label.ZIndex = 6
        label.Parent = marker

        table.insert(self.ExtractionMarkers, marker)
    end
end

function MapUI:WorldToMapPosition(worldPos)
    -- Convert world position to map UI position
    -- Map ranges from -MAP_SIZE/2 to MAP_SIZE/2 in world
    -- UI ranges from 0 to 1

    local halfSize = MAP_SIZE / 2
    local normalizedX = (worldPos.X + halfSize) / MAP_SIZE
    local normalizedZ = (worldPos.Z + halfSize) / MAP_SIZE

    -- Clamp to 0-1 range
    normalizedX = math.clamp(normalizedX, 0, 1)
    normalizedZ = math.clamp(normalizedZ, 0, 1)

    return UDim2.new(normalizedX, 0, normalizedZ, 0)
end

function MapUI:UpdateMap()
    if not self.IsOpen then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local character = player.Character
    local humanoidRootPart = character.HumanoidRootPart
    local position = humanoidRootPart.Position

    -- Update player marker position
    local mapPos = self:WorldToMapPosition(position)
    self.PlayerMarker.Position = mapPos

    -- Update coordinates
    self.CoordsLabel.Text = string.format("X: %d, Z: %d", math.floor(position.X), math.floor(position.Z))

    -- Update arrow rotation
    local camera = workspace.CurrentCamera
    if camera then
        local cameraLook = camera.CFrame.LookVector
        local angle = math.atan2(-cameraLook.X, -cameraLook.Z)
        self.Arrow.Rotation = math.deg(angle)
    end
end

function MapUI:ToggleMap()
    self.IsOpen = not self.IsOpen
    self.MapFrame.Visible = self.IsOpen

    if self.IsOpen then
        self:UpdateMap()
    end
end

function MapUI:AddLootMarker(worldPosition)
    if not self.MapDisplay then return end

    local mapPos = self:WorldToMapPosition(worldPosition)

    local marker = Instance.new("Frame")
    marker.Size = UDim2.new(0, 8, 0, 8)
    marker.AnchorPoint = Vector2.new(0.5, 0.5)
    marker.Position = mapPos
    marker.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    marker.BorderSizePixel = 1
    marker.BorderColor3 = Color3.new(0, 0, 0)
    marker.ZIndex = 4
    marker.Parent = self.MapDisplay

    table.insert(self.LootMarkers, marker)

    return marker
end

-- Initialize
MapUI:CreateMapUI()

-- Toggle with M key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.M then
        MapUI:ToggleMap()
    end
end)

-- Update loop when map is open
RunService.Heartbeat:Connect(function()
    if MapUI.IsOpen then
        MapUI:UpdateMap()
    end
end)

print("MapUI initialized - Press M to open map")

return MapUI
