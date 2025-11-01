--[[
    SimpleMapGenerator.lua
    Creates a simple Apocalypse Rising-style map
    Run this once in Studio to generate the map
]]

local MapGenerator = {}

local MAP_SIZE = 2048 -- 2048x2048 studs
local TERRAIN_HEIGHT = 50

function MapGenerator:GenerateSimpleMap()
    print("Generating simple map...")

    -- Clear existing terrain
    workspace.Terrain:Clear()

    -- Create simple flat terrain with some variation
    local region = Region3.new(
        Vector3.new(-MAP_SIZE/2, 0, -MAP_SIZE/2),
        Vector3.new(MAP_SIZE/2, TERRAIN_HEIGHT, MAP_SIZE/2)
    )
    region = region:ExpandToGrid(4)

    local size = region.Size
    local base = region.CFrame.Position - region.Size/2

    -- Fill with grass (simple and flat like Apoc)
    workspace.Terrain:FillRegion(region, 4, Enum.Material.Grass)

    print("Base terrain created")

    -- Add some simple roads (gray parts)
    self:CreateRoads()

    -- Add simple buildings
    self:CreateSimpleBuildings()

    -- Add trees (simple cylinders)
    self:CreateSimpleTrees()

    -- Create spawn area
    self:CreateSpawnArea()

    print("Map generation complete!")
end

function MapGenerator:CreateRoads()
    local roadWidth = 20
    local roadColor = Color3.fromRGB(60, 60, 60)

    -- Main cross roads
    -- North-South road
    local nsRoad = Instance.new("Part")
    nsRoad.Name = "Road_NS"
    nsRoad.Size = Vector3.new(roadWidth, 0.5, MAP_SIZE)
    nsRoad.Position = Vector3.new(0, 0.25, 0)
    nsRoad.Anchored = true
    nsRoad.Color = roadColor
    nsRoad.Material = Enum.Material.Asphalt
    nsRoad.Parent = workspace.Map

    -- East-West road
    local ewRoad = Instance.new("Part")
    ewRoad.Name = "Road_EW"
    ewRoad.Size = Vector3.new(MAP_SIZE, 0.5, roadWidth)
    ewRoad.Position = Vector3.new(0, 0.25, 0)
    ewRoad.Anchored = true
    ewRoad.Color = roadColor
    ewRoad.Material = Enum.Material.Asphalt
    ewRoad.Parent = workspace.Map
end

function MapGenerator:CreateSimpleBuildings()
    -- Simple box buildings like Apoc
    local buildingLocations = {
        {Pos = Vector3.new(200, 0, 200), Size = Vector3.new(30, 15, 40), Color = Color3.fromRGB(100, 100, 100)},
        {Pos = Vector3.new(-200, 0, 200), Size = Vector3.new(25, 12, 30), Color = Color3.fromRGB(120, 100, 80)},
        {Pos = Vector3.new(200, 0, -200), Size = Vector3.new(35, 18, 35), Color = Color3.fromRGB(80, 80, 100)},
        {Pos = Vector3.new(-200, 0, -200), Size = Vector3.new(40, 20, 50), Color = Color3.fromRGB(100, 80, 80)},
        {Pos = Vector3.new(300, 0, 0), Size = Vector3.new(30, 15, 30), Color = Color3.fromRGB(90, 90, 90)},
        {Pos = Vector3.new(-300, 0, 0), Size = Vector3.new(25, 12, 35), Color = Color3.fromRGB(110, 90, 70)},
        {Pos = Vector3.new(0, 0, 300), Size = Vector3.new(28, 14, 32), Color = Color3.fromRGB(85, 85, 95)},
        {Pos = Vector3.new(0, 0, -300), Size = Vector3.new(32, 16, 38), Color = Color3.fromRGB(95, 75, 75)}
    }

    for i, building in pairs(buildingLocations) do
        local model = Instance.new("Model")
        model.Name = "Building_" .. i
        model.Parent = workspace.Map

        -- Main building
        local main = Instance.new("Part")
        main.Name = "Main"
        main.Size = building.Size
        main.Position = building.Pos + Vector3.new(0, building.Size.Y/2, 0)
        main.Anchored = true
        main.Color = building.Color
        main.Material = Enum.Material.Concrete
        main.Parent = model

        -- Simple door (hole in the wall would be better, but keeping it simple)
        local door = Instance.new("Part")
        door.Name = "Door"
        door.Size = Vector3.new(6, 8, 0.5)
        door.Position = main.Position + Vector3.new(0, -building.Size.Y/2 + 4, building.Size.Z/2)
        door.Anchored = true
        door.Color = Color3.fromRGB(60, 40, 20)
        door.Material = Enum.Material.Wood
        door.CanCollide = false
        door.Transparency = 0.5
        door.Parent = model
    end
end

function MapGenerator:CreateSimpleTrees()
    -- Simple tree models (cylinder trunk + sphere top)
    local treeCount = 50
    local minDistance = 30

    for i = 1, treeCount do
        local x = math.random(-MAP_SIZE/2 + 50, MAP_SIZE/2 - 50)
        local z = math.random(-MAP_SIZE/2 + 50, MAP_SIZE/2 - 50)

        -- Don't spawn trees on roads
        if math.abs(x) > 15 and math.abs(z) > 15 then
            local tree = Instance.new("Model")
            tree.Name = "Tree_" .. i
            tree.Parent = workspace.Map

            -- Trunk
            local trunk = Instance.new("Part")
            trunk.Name = "Trunk"
            trunk.Shape = Enum.PartType.Cylinder
            trunk.Size = Vector3.new(8, 1.5, 1.5)
            trunk.Position = Vector3.new(x, 4, z)
            trunk.Orientation = Vector3.new(0, 0, 90)
            trunk.Anchored = true
            trunk.Color = Color3.fromRGB(100, 70, 40)
            trunk.Material = Enum.Material.Wood
            trunk.Parent = tree

            -- Leaves
            local leaves = Instance.new("Part")
            leaves.Name = "Leaves"
            leaves.Shape = Enum.PartType.Ball
            leaves.Size = Vector3.new(8, 8, 8)
            leaves.Position = Vector3.new(x, 10, z)
            leaves.Anchored = true
            leaves.Color = Color3.fromRGB(40, 100, 40)
            leaves.Material = Enum.Material.Grass
            leaves.Parent = tree
        end
    end
end

function MapGenerator:CreateSpawnArea()
    -- Safe zone marker
    local safeZone = Instance.new("Part")
    safeZone.Name = "SafeZoneMarker"
    safeZone.Size = Vector3.new(100, 1, 100)
    safeZone.Position = Vector3.new(-200, 0.5, 0)
    safeZone.Anchored = true
    safeZone.Color = Color3.fromRGB(100, 200, 100)
    safeZone.Material = Enum.Material.Neon
    safeZone.Transparency = 0.7
    safeZone.CanCollide = false
    safeZone.Parent = workspace.SafeZone
end

-- Create folders
if not workspace:FindFirstChild("Map") then
    local mapFolder = Instance.new("Folder")
    mapFolder.Name = "Map"
    mapFolder.Parent = workspace
end

if not workspace:FindFirstChild("SafeZone") then
    local safeFolder = Instance.new("Folder")
    safeFolder.Name = "SafeZone"
    safeFolder.Parent = workspace
end

return MapGenerator

-- Uncomment to generate map:
-- MapGenerator:GenerateSimpleMap()
