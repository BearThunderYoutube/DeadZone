--[[
    TradingSystem.lua
    Vendor and player trading system
]]

local TradingSystem = {}
TradingSystem.Vendors = {}
TradingSystem.TradeOffers = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventorySystem = require(ReplicatedStorage.Modules.InventorySystem)
local EquipmentSystem = require(ReplicatedStorage.Modules.EquipmentSystem)

-- Vendor class
local Vendor = {}
Vendor.__index = Vendor

function Vendor.new(name, position, vendorType)
    local self = setmetatable({}, Vendor)

    self.Name = name
    self.Position = position
    self.Type = vendorType -- "Weapons", "Medical", "Equipment", "General"
    self.Stock = {}
    self.RefreshTime = 600 -- 10 minutes
    self.LastRefresh = 0

    self:CreateVendorNPC()
    self:GenerateStock()

    return self
end

function Vendor:CreateVendorNPC()
    -- Create NPC model
    local npc = Instance.new("Part")
    npc.Name = "Vendor_" .. self.Name
    npc.Size = Vector3.new(2, 5, 2)
    npc.Position = self.Position
    npc.Anchored = true
    npc.BrickColor = BrickColor.new("Bright blue")

    -- Add billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = npc

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = self.Name .. " [VENDOR]"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.BackgroundTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard

    -- Add click detector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 10
    clickDetector.Parent = npc

    clickDetector.MouseClick:Connect(function(player)
        self:OpenShop(player)
    end)

    npc.Parent = workspace:FindFirstChild("SafeZone") or workspace
    self.NPC = npc
end

function Vendor:GenerateStock()
    self.Stock = {}

    local stockLists = {
        Weapons = {
            {Item = "Glock19", Price = 1500, Stock = 5},
            {Item = "MP5", Price = 3500, Stock = 3},
            {Item = "AK47", Price = 5000, Stock = 2},
            {Item = "M4A1", Price = 7500, Stock = 2},
            {Item = "Shotgun", Price = 4000, Stock = 3},
            {Item = "9mm", Price = 5, Stock = 500},
            {Item = "5.56x45mm", Price = 8, Stock = 300},
            {Item = "7.62x39mm", Price = 10, Stock = 300},
            {Item = "Buckshot", Price = 15, Stock = 200}
        },
        Medical = {
            {Item = "Bandage", Price = 50, Stock = 50},
            {Item = "Medkit", Price = 500, Stock = 20},
            {Item = "Painkillers", Price = 200, Stock = 30},
            {Item = "Antibiotics", Price = 800, Stock = 10},
            {Item = "Splint", Price = 300, Stock = 15},
            {Item = "Defibrillator", Price = 5000, Stock = 2}
        },
        Equipment = {
            {Item = "ScoutBackpack", Price = 500, Stock = 10},
            {Item = "AssaultBackpack", Price = 1500, Stock = 5},
            {Item = "TacticalBackpack", Price = 3500, Stock = 3},
            {Item = "LightVest", Price = 800, Stock = 8},
            {Item = "TacticalVest", Price = 2000, Stock = 5},
            {Item = "PlateCarrier", Price = 5000, Stock = 2},
            {Item = "TacticalHelmet", Price = 1200, Stock = 5},
            {Item = "CombatHelmet", Price = 3500, Stock = 3}
        },
        General = {
            {Item = "WaterBottle", Price = 20, Stock = 100},
            {Item = "CannedFood", Price = 30, Stock = 100},
            {Item = "EnergyDrink", Price = 100, Stock = 50},
            {Item = "MRE", Price = 150, Stock = 40},
            {Item = "GPS", Price = 1000, Stock = 5},
            {Item = "Radio", Price = 500, Stock = 10},
            {Item = "GasMask", Price = 2000, Stock = 4}
        }
    }

    self.Stock = stockLists[self.Type] or stockLists.General
    self.LastRefresh = tick()
end

function Vendor:OpenShop(player)
    -- Send shop data to client
    local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("OpenVendor")
    if event then
        event:FireClient(player, self.Name, self.Type, self.Stock)
    end
    print(player.Name .. " opened shop: " .. self.Name)
end

function Vendor:PurchaseItem(player, itemName, quantity, playerData)
    -- Find item in stock
    local stockItem = nil
    local stockIndex = nil

    for i, item in pairs(self.Stock) do
        if item.Item == itemName then
            stockItem = item
            stockIndex = i
            break
        end
    end

    if not stockItem then
        warn("Item not in stock:", itemName)
        return false, "Item not available"
    end

    if stockItem.Stock < quantity then
        return false, "Insufficient stock"
    end

    local totalCost = stockItem.Price * quantity

    -- Check player money (from DataService)
    if not playerData or not playerData.Money or playerData.Money < totalCost then
        return false, "Insufficient funds"
    end

    -- Process purchase
    stockItem.Stock = stockItem.Stock - quantity
    playerData.Money = playerData.Money - totalCost

    return true, "Purchase successful"
end

function Vendor:SellItem(player, itemName, quantity, playerData)
    -- Get item data
    local itemData = InventorySystem.ItemDatabase[itemName] or
                    EquipmentSystem.EquipmentDatabase[itemName]

    if not itemData then
        return false, "Item not recognized"
    end

    -- Calculate sell price (50% of buy price)
    local sellPrice = math.floor((itemData.Price or 10) * 0.5) * quantity

    -- Give money to player
    if playerData then
        playerData.Money = playerData.Money + sellPrice
    end

    return true, "Sold for $" .. sellPrice
end

function Vendor:RefreshStock()
    if tick() - self.LastRefresh >= self.RefreshTime then
        self:GenerateStock()
        print("Vendor stock refreshed:", self.Name)
    end
end

-- Main system functions
function TradingSystem:Initialize()
    -- Create safe zone if it doesn't exist
    if not workspace:FindFirstChild("SafeZone") then
        local safeZone = Instance.new("Folder")
        safeZone.Name = "SafeZone"
        safeZone.Parent = workspace
    end

    -- Create vendors
    self:CreateVendors()

    -- Refresh stock periodically
    task.spawn(function()
        while true do
            task.wait(60)
            for _, vendor in pairs(self.Vendors) do
                vendor:RefreshStock()
            end
        end
    end)

    print("TradingSystem initialized")
end

function TradingSystem:CreateVendors()
    local vendorLocations = {
        {Name = "Arms Dealer", Position = Vector3.new(-200, 5, 0), Type = "Weapons"},
        {Name = "Medic", Position = Vector3.new(-200, 5, 20), Type = "Medical"},
        {Name = "Equipment Vendor", Position = Vector3.new(-200, 5, -20), Type = "Equipment"},
        {Name = "General Store", Position = Vector3.new(-220, 5, 0), Type = "General"}
    }

    for _, location in pairs(vendorLocations) do
        local vendor = Vendor.new(location.Name, location.Position, location.Type)
        table.insert(self.Vendors, vendor)
    end

    print("Created " .. #self.Vendors .. " vendors")
end

function TradingSystem:GetVendor(vendorName)
    for _, vendor in pairs(self.Vendors) do
        if vendor.Name == vendorName then
            return vendor
        end
    end
    return nil
end

-- Player-to-player trading
function TradingSystem:InitiateTrade(player1, player2)
    local tradeId = player1.UserId .. "_" .. player2.UserId .. "_" .. tick()

    self.TradeOffers[tradeId] = {
        Player1 = player1,
        Player2 = player2,
        Player1Items = {},
        Player2Items = {},
        Player1Ready = false,
        Player2Ready = false,
        Status = "Pending"
    }

    return tradeId
end

function TradingSystem:AddItemToTrade(tradeId, player, itemName, quantity)
    local trade = self.TradeOffers[tradeId]
    if not trade then return false end

    if player == trade.Player1 then
        table.insert(trade.Player1Items, {Item = itemName, Quantity = quantity})
    elseif player == trade.Player2 then
        table.insert(trade.Player2Items, {Item = itemName, Quantity = quantity})
    end

    -- Reset ready status
    trade.Player1Ready = false
    trade.Player2Ready = false

    return true
end

function TradingSystem:SetTradeReady(tradeId, player, ready)
    local trade = self.TradeOffers[tradeId]
    if not trade then return false end

    if player == trade.Player1 then
        trade.Player1Ready = ready
    elseif player == trade.Player2 then
        trade.Player2Ready = ready
    end

    -- Check if both ready
    if trade.Player1Ready and trade.Player2Ready then
        self:CompleteTrade(tradeId)
    end

    return true
end

function TradingSystem:CompleteTrade(tradeId)
    local trade = self.TradeOffers[tradeId]
    if not trade then return false end

    -- Execute trade (integrate with inventory systems)
    trade.Status = "Completed"

    print("Trade completed between", trade.Player1.Name, "and", trade.Player2.Name)

    -- Clean up
    self.TradeOffers[tradeId] = nil

    return true
end

return TradingSystem
