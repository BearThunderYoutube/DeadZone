--[[
    SettingsMenu.lua
    Game settings and keybind customization
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SettingsMenu = {}
SettingsMenu.IsOpen = false
SettingsMenu.Settings = {
    Graphics = {
        Quality = 5,
        FOV = 80,
        ViewDistance = 100,
        Shadows = true,
        PostProcessing = true
    },
    Audio = {
        MasterVolume = 0.8,
        MusicVolume = 0.5,
        SFXVolume = 0.8,
        VoiceVolume = 1.0
    },
    Gameplay = {
        MouseSensitivity = 0.5,
        InvertY = false,
        AutoReload = true,
        ShowDamageNumbers = true,
        ShowHealthBar = true
    },
    Keybinds = {
        Forward = Enum.KeyCode.W,
        Backward = Enum.KeyCode.S,
        Left = Enum.KeyCode.A,
        Right = Enum.KeyCode.D,
        Sprint = Enum.KeyCode.LeftShift,
        Crouch = Enum.KeyCode.LeftControl,
        Jump = Enum.KeyCode.Space,
        Interact = Enum.KeyCode.E,
        Reload = Enum.KeyCode.R,
        Inventory = Enum.KeyCode.Tab,
        Map = Enum.KeyCode.M,
        Settings = Enum.KeyCode.Escape
    }
}

function SettingsMenu:CreateSettingsUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SettingsMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 700, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 3
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.BorderSizePixel = 0
    title.Text = "SETTINGS"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextScaled = true
    title.Parent = mainFrame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextScaled = true
    closeButton.Parent = mainFrame

    closeButton.MouseButton1Click:Connect(function()
        self:ToggleSettings()
    end)

    -- Tab buttons
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0.25, 0, 1, -50)
    tabFrame.Position = UDim2.new(0, 0, 0, 50)
    tabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = mainFrame

    local tabs = {"Graphics", "Audio", "Gameplay", "Keybinds"}
    local tabButtons = {}

    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.Size = UDim2.new(1, -10, 0, 50)
        tabButton.Position = UDim2.new(0, 5, 0, (i - 1) * 60 + 10)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.new(1, 1, 1)
        tabButton.Font = Enum.Font.SourceSans
        tabButton.TextScaled = true
        tabButton.Parent = tabFrame

        tabButton.MouseButton1Click:Connect(function()
            self:ShowTab(tabName)
        end)

        tabButtons[tabName] = tabButton
    end

    -- Content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(0.75, -20, 1, -70)
    contentFrame.Position = UDim2.new(0.25, 10, 0, 60)
    contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 8
    contentFrame.Parent = mainFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentFrame

    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.ContentFrame = contentFrame
    self.TabButtons = tabButtons
end

function SettingsMenu:ShowTab(tabName)
    -- Clear current content
    for _, child in pairs(self.ContentFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    -- Highlight selected tab
    for name, button in pairs(self.TabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        else
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end

    -- Show content based on tab
    if tabName == "Graphics" then
        self:CreateGraphicsSettings()
    elseif tabName == "Audio" then
        self:CreateAudioSettings()
    elseif tabName == "Gameplay" then
        self:CreateGameplaySettings()
    elseif tabName == "Keybinds" then
        self:CreateKeybindSettings()
    end
end

function SettingsMenu:CreateSlider(name, currentValue, minValue, maxValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name .. "Slider"
    sliderFrame.Size = UDim2.new(1, -20, 0, 60)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = self.ContentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0.4, 0)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(currentValue)
    valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextScaled = true
    valueLabel.Parent = sliderFrame

    -- Actual slider would need custom implementation
    -- Placeholder for now

    return sliderFrame
end

function SettingsMenu:CreateCheckbox(name, currentValue, callback)
    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.Name = name .. "Checkbox"
    checkboxFrame.Size = UDim2.new(1, -20, 0, 50)
    checkboxFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    checkboxFrame.BorderSizePixel = 0
    checkboxFrame.Parent = self.ContentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = checkboxFrame

    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 40, 0, 40)
    checkbox.Position = UDim2.new(1, -50, 0.5, -20)
    checkbox.BackgroundColor3 = currentValue and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
    checkbox.Text = currentValue and "✓" or "X"
    checkbox.TextColor3 = Color3.new(1, 1, 1)
    checkbox.Font = Enum.Font.SourceSansBold
    checkbox.TextScaled = true
    checkbox.Parent = checkboxFrame

    checkbox.MouseButton1Click:Connect(function()
        currentValue = not currentValue
        checkbox.BackgroundColor3 = currentValue and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
        checkbox.Text = currentValue and "✓" or "X"
        if callback then callback(currentValue) end
    end)

    return checkboxFrame
end

function SettingsMenu:CreateGraphicsSettings()
    self:CreateSlider("Quality", self.Settings.Graphics.Quality, 1, 10)
    self:CreateSlider("FOV", self.Settings.Graphics.FOV, 60, 120)
    self:CreateSlider("View Distance", self.Settings.Graphics.ViewDistance, 50, 200)
    self:CreateCheckbox("Shadows", self.Settings.Graphics.Shadows)
    self:CreateCheckbox("Post Processing", self.Settings.Graphics.PostProcessing)
end

function SettingsMenu:CreateAudioSettings()
    self:CreateSlider("Master Volume", self.Settings.Audio.MasterVolume, 0, 1)
    self:CreateSlider("Music Volume", self.Settings.Audio.MusicVolume, 0, 1)
    self:CreateSlider("SFX Volume", self.Settings.Audio.SFXVolume, 0, 1)
    self:CreateSlider("Voice Volume", self.Settings.Audio.VoiceVolume, 0, 1)
end

function SettingsMenu:CreateGameplaySettings()
    self:CreateSlider("Mouse Sensitivity", self.Settings.Gameplay.MouseSensitivity, 0.1, 2.0)
    self:CreateCheckbox("Invert Y Axis", self.Settings.Gameplay.InvertY)
    self:CreateCheckbox("Auto Reload", self.Settings.Gameplay.AutoReload)
    self:CreateCheckbox("Show Damage Numbers", self.Settings.Gameplay.ShowDamageNumbers)
    self:CreateCheckbox("Show Health Bar", self.Settings.Gameplay.ShowHealthBar)
end

function SettingsMenu:CreateKeybindSettings()
    -- Placeholder for keybind remapping
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 100)
    infoLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    infoLabel.Text = "Keybind customization coming soon!\n\nDefault controls are shown in the README"
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextScaled = true
    infoLabel.Parent = self.ContentFrame
end

function SettingsMenu:ToggleSettings()
    self.IsOpen = not self.IsOpen
    self.MainFrame.Visible = self.IsOpen

    if self.IsOpen then
        self:ShowTab("Graphics")
    end
end

function SettingsMenu:SaveSettings()
    -- Save to DataStore via server
    local event = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("SaveSettings")
    if event then
        event:FireServer(self.Settings)
    end
end

function SettingsMenu:LoadSettings(loadedSettings)
    if loadedSettings then
        self.Settings = loadedSettings
    end
end

-- Initialize
SettingsMenu:CreateSettingsUI()

-- Toggle with ESC key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Escape then
        SettingsMenu:ToggleSettings()
    end
end)

print("SettingsMenu initialized")

return SettingsMenu
