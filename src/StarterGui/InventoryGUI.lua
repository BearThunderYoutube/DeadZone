--[[
    InventoryGUI.lua
    Inventory UI with drag-and-drop, item management, and weight tracking
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local InventoryGUI = {}
InventoryGUI.IsOpen = false

function InventoryGUI:CreateInventoryUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InventoryGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Main inventory frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.BorderSizePixel = 0
    title.Text = "INVENTORY"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextScaled = true
    title.Parent = mainFrame

    -- Weight info
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Name = "Weight"
    weightLabel.Size = UDim2.new(0, 200, 0, 30)
    weightLabel.Position = UDim2.new(1, -210, 0, 5)
    weightLabel.BackgroundTransparency = 1
    weightLabel.Text = "Weight: 0/50 kg"
    weightLabel.TextColor3 = Color3.new(1, 1, 1)
    weightLabel.Font = Enum.Font.SourceSans
    weightLabel.TextScaled = true
    weightLabel.Parent = mainFrame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextScaled = true
    closeButton.Parent = mainFrame

    closeButton.MouseButton1Click:Connect(function()
        self:ToggleInventory()
    end)

    -- Grid container
    local gridFrame = Instance.new("ScrollingFrame")
    gridFrame.Name = "GridFrame"
    gridFrame.Size = UDim2.new(1, -20, 1, -60)
    gridFrame.Position = UDim2.new(0, 10, 0, 50)
    gridFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    gridFrame.BorderSizePixel = 2
    gridFrame.ScrollBarThickness = 10
    gridFrame.Parent = mainFrame

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 80, 0, 80)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    gridLayout.Parent = gridFrame

    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.GridFrame = gridFrame
    self.WeightLabel = weightLabel
end

function InventoryGUI:ToggleInventory()
    self.IsOpen = not self.IsOpen
    self.MainFrame.Visible = self.IsOpen

    -- Request inventory data from server
    if self.IsOpen then
        local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("RequestInventory")
        if event then
            event:FireServer()
        end
    end
end

function InventoryGUI:UpdateInventory(inventoryData)
    -- Clear current items
    for _, child in pairs(self.GridFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Update weight
    self.WeightLabel.Text = string.format("Weight: %.1f/%.1f kg",
        inventoryData.CurrentWeight, inventoryData.MaxWeight)

    -- Create item slots
    for i, item in pairs(inventoryData.Items) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = "Item_" .. i
        itemFrame.BackgroundColor3 = self:GetRarityColor(item.Data.Rarity)
        itemFrame.BorderSizePixel = 2
        itemFrame.Parent = self.GridFrame

        -- Item icon (placeholder)
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(1, -10, 1, -30)
        icon.Position = UDim2.new(0, 5, 0, 5)
        icon.BackgroundTransparency = 1
        icon.Image = "" -- Add item icons here
        icon.Parent = itemFrame

        -- Item name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 15)
        nameLabel.Position = UDim2.new(0, 0, 1, -20)
        nameLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        nameLabel.BackgroundTransparency = 0.5
        nameLabel.Text = item.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.SourceSans
        nameLabel.TextScaled = true
        nameLabel.Parent = itemFrame

        -- Quantity
        if item.Quantity and item.Quantity > 1 then
            local quantityLabel = Instance.new("TextLabel")
            quantityLabel.Size = UDim2.new(0, 30, 0, 20)
            quantityLabel.Position = UDim2.new(1, -35, 0, 5)
            quantityLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            quantityLabel.BackgroundTransparency = 0.3
            quantityLabel.Text = "x" .. item.Quantity
            quantityLabel.TextColor3 = Color3.new(1, 1, 1)
            quantityLabel.Font = Enum.Font.SourceSansBold
            quantityLabel.TextScaled = true
            quantityLabel.Parent = itemFrame
        end

        -- Item button
        local itemButton = Instance.new("TextButton")
        itemButton.Size = UDim2.new(1, 0, 1, 0)
        itemButton.BackgroundTransparency = 1
        itemButton.Text = ""
        itemButton.Parent = itemFrame

        itemButton.MouseButton1Click:Connect(function()
            self:OnItemClick(item, i)
        end)

        itemButton.MouseButton2Click:Connect(function()
            self:OnItemRightClick(item, i)
        end)
    end
end

function InventoryGUI:GetRarityColor(rarity)
    local colors = {
        Common = Color3.fromRGB(150, 150, 150),
        Uncommon = Color3.fromRGB(100, 200, 100),
        Rare = Color3.fromRGB(100, 100, 255),
        Epic = Color3.fromRGB(200, 100, 255),
        Legendary = Color3.fromRGB(255, 150, 50)
    }
    return colors[rarity] or colors.Common
end

function InventoryGUI:OnItemClick(item, index)
    -- Use/Equip item
    local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("UseItem")
    if event then
        event:FireServer(item.Name, index)
    end
end

function InventoryGUI:OnItemRightClick(item, index)
    -- Drop/Destroy item
    local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("DropItem")
    if event then
        event:FireServer(item.Name, index)
    end
end

-- Initialize
InventoryGUI:CreateInventoryUI()

-- Toggle with TAB key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Tab then
        InventoryGUI:ToggleInventory()
    end
end)

print("InventoryGUI initialized")

return InventoryGUI
