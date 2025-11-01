--[[
    ExtractionSystem.lua
    Manages extraction points and safe zone mechanics
]]

local ExtractionSystem = {}
ExtractionSystem.ExtractionPoints = {}
ExtractionSystem.ActiveExtractions = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GameSettings = require(ReplicatedStorage.Modules.GameSettings)

-- Extraction point class
local ExtractionPoint = {}
ExtractionPoint.__index = ExtractionPoint

function ExtractionPoint.new(position, name, extractionType)
    local self = setmetatable({}, ExtractionPoint)

    self.Name = name or "Extraction Point"
    self.Position = position
    self.Type = extractionType or "Open" -- Open, Timed, Paid
    self.IsActive = true
    self.PlayersInRange = {}
    self.ExtractionRadius = 15

    -- Create visual marker
    self:CreateMarker()

    return self
end

function ExtractionPoint:CreateMarker()
    -- Create extraction zone part
    local extractionPart = Instance.new("Part")
    extractionPart.Name = self.Name
    extractionPart.Size = Vector3.new(self.ExtractionRadius * 2, 1, self.ExtractionRadius * 2)
    extractionPart.Position = self.Position
    extractionPart.Anchored = true
    extractionPart.CanCollide = false
    extractionPart.Transparency = 0.7
    extractionPart.BrickColor = BrickColor.new("Bright green")
    extractionPart.Material = Enum.Material.Neon
    extractionPart.Parent = workspace.ExtractionPoints

    -- Add border effect
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = extractionPart
    selectionBox.LineThickness = 0.1
    selectionBox.Color3 = Color3.new(0, 1, 0)
    selectionBox.Parent = extractionPart

    -- Add billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = extractionPart

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = self.Name
    textLabel.TextColor3 = Color3.new(0, 1, 0)
    textLabel.TextScaled = true
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    self.Part = extractionPart
end

function ExtractionPoint:Update(dt)
    if not self.IsActive then return end

    -- Check for players in range
    local currentPlayers = {}

    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - self.Position).Magnitude

            if distance <= self.ExtractionRadius then
                table.insert(currentPlayers, player)

                -- Start extraction if not already extracting
                if not self.PlayersInRange[player] then
                    self:StartExtraction(player)
                end
            else
                -- Cancel extraction if player left
                if self.PlayersInRange[player] then
                    self:CancelExtraction(player)
                end
            end
        end
    end

    -- Update extraction timers
    for player, extractionData in pairs(self.PlayersInRange) do
        extractionData.Timer = extractionData.Timer + dt

        if extractionData.Timer >= GameSettings.Extraction.ExtractionTime then
            self:CompleteExtraction(player)
        end
    end
end

function ExtractionPoint:StartExtraction(player)
    self.PlayersInRange[player] = {
        Timer = 0,
        StartTime = tick()
    }

    -- Notify player
    local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("ExtractionStarted")
    if event then
        event:FireClient(player, self.Name, GameSettings.Extraction.ExtractionTime)
    end

    print(player.Name .. " started extraction at " .. self.Name)
end

function ExtractionPoint:CancelExtraction(player)
    if self.PlayersInRange[player] then
        self.PlayersInRange[player] = nil

        -- Notify player
        local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("ExtractionCancelled")
        if event then
            event:FireClient(player)
        end

        print(player.Name .. " cancelled extraction at " .. self.Name)
    end
end

function ExtractionPoint:CompleteExtraction(player)
    if not self.PlayersInRange[player] then return end

    print(player.Name .. " successfully extracted at " .. self.Name)

    -- Fire extraction complete event
    local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("ExtractionComplete")
    if event then
        event:FireClient(player)
    end

    -- Remove from extraction
    self.PlayersInRange[player] = nil

    -- Call global extraction callback
    if ExtractionSystem.OnPlayerExtracted then
        ExtractionSystem.OnPlayerExtracted(player, self.Name)
    end

    -- Teleport to safe zone
    if player.Character then
        local safeZone = workspace:FindFirstChild("SafeZone")
        if safeZone then
            player.Character:SetPrimaryPartCFrame(CFrame.new(-200, 10, 0))
        else
            -- Fallback spawn
            player.Character:SetPrimaryPartCFrame(CFrame.new(0, 10, 0))
        end
    end
end

-- Main system functions
function ExtractionSystem:Initialize()
    -- Create extraction points folder
    if not workspace:FindFirstChild("ExtractionPoints") then
        local folder = Instance.new("Folder")
        folder.Name = "ExtractionPoints"
        folder.Parent = workspace
    end

    -- Create default extraction points
    self:CreateDefaultExtractionPoints()

    -- Start update loop
    RunService.Heartbeat:Connect(function(dt)
        self:UpdateAll(dt)
    end)
end

function ExtractionSystem:CreateDefaultExtractionPoints()
    -- Create several extraction points around the map
    local extractionLocations = {
        {Position = Vector3.new(100, 5, 100), Name = "North Checkpoint", Type = "Open"},
        {Position = Vector3.new(-100, 5, 100), Name = "West Outpost", Type = "Timed"},
        {Position = Vector3.new(100, 5, -100), Name = "South Bridge", Type = "Open"},
        {Position = Vector3.new(-100, 5, -100), Name = "East Harbor", Type = "Open"},
        {Position = Vector3.new(0, 5, 0), Name = "Central Helipad", Type = "Paid"}
    }

    for _, location in pairs(extractionLocations) do
        local extraction = ExtractionPoint.new(
            location.Position,
            location.Name,
            location.Type
        )
        table.insert(self.ExtractionPoints, extraction)
    end
end

function ExtractionSystem:UpdateAll(dt)
    for _, extraction in pairs(self.ExtractionPoints) do
        extraction:Update(dt)
    end
end

function ExtractionSystem:GetNearestExtraction(position)
    local nearest = nil
    local nearestDistance = math.huge

    for _, extraction in pairs(self.ExtractionPoints) do
        if extraction.IsActive then
            local distance = (extraction.Position - position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearest = extraction
            end
        end
    end

    return nearest, nearestDistance
end

return ExtractionSystem
