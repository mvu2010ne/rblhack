-- MV Hub | Axiom Build v5.0 - Ultimate Edition
-- Tất cả tính năng được tối ưu và hoạt động ổn định

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- // Biến toàn cục
local MenuOpen = false
local SelectedMapPoint = nil
local SelectedMapName = "Chưa chọn"
local DetectedMapPoints = {}
local ESPObjects = {}
local MobsList = {}
local SelectedMob = nil
local SelectedWeapon = nil
local IsAutoFarm = false
local FarmTarget = nil
local FarmLoop = nil
local IsResizing = false
local ResizeStartPos = nil
local ResizeStartSize = nil
local MinSize = 600
local MaxSize = 900

-- // Toggles
local Toggles = {
    FixLag = false,
    SuperJump = false,
    Fly = false,
    Noclip = false,
    ESPPlayers = false,
    ESPMobs = false,
    ESPFruits = false,
    Ghost = false,
    NightVision = false,
    AutoFarm = false
}

-- // Variables
local FlySpeed = 50
local JumpPower = 250
local GhostStealth = 0.3
local FlyEnabled = false
local BodyVelocity = nil
local ESPUpdateRate = 0.3

-- ============================================
-- // PHẦN 1: TẠO UI THEO DẠNG HỘP NGANG
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MVHub"
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 800, 0, 550)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

-- Blur effect
local blur = Instance.new("BlurEffect")
blur.Parent = MainFrame
blur.Size = 8

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ MV HUB v5.0 - Axiom"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -42, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.MouseButton1Click:Connect(function()
    MenuOpen = false
    MainFrame.Visible = false
end)

-- Resize Handle
local ResizeHandle = Instance.new("Frame")
ResizeHandle.Parent = MainFrame
ResizeHandle.Size = UDim2.new(0, 25, 0, 25)
ResizeHandle.Position = UDim2.new(1, -25, 1, -25)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
ResizeHandle.BackgroundTransparency = 0.5
ResizeHandle.ZIndex = 10

local ResizeCorner = Instance.new("ImageLabel")
ResizeCorner.Parent = ResizeHandle
ResizeCorner.Size = UDim2.new(1, 0, 1, 0)
ResizeCorner.BackgroundTransparency = 1
ResizeCorner.Image = "rbxassetid://6023420974"
ResizeCorner.ImageColor3 = Color3.fromRGB(200, 200, 255)

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsResizing = true
        ResizeStartPos = input.Position
        ResizeStartSize = MainFrame.Size
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if IsResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - ResizeStartPos
        local newWidth = math.clamp(ResizeStartSize.X.Offset + delta.X, MinSize, MaxSize)
        local newHeight = math.clamp(ResizeStartSize.Y.Offset + delta.Y, MinSize, MaxSize)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsResizing = false
    end
end)

-- Menu Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -30)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
ToggleBtn.Text = "⚡"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.BackgroundTransparency = 0.2

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.Parent = ToggleBtn
ToggleCorner.CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
    if MenuOpen then
        BuildTeleportList()
        ScanMobs()
    end
    TweenService:Create(ToggleBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
    wait(0.1)
    TweenService:Create(ToggleBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()
end)

-- Tab Buttons
local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 45)
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 38)
TabContainer.BorderSizePixel = 0

local Tabs = {}
local TabContents = {}
local CurrentTab = "Combat"

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Parent = TabContainer
    btn.Size = UDim2.new(0.166, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Name = name
    
    local content = Instance.new("ScrollingFrame")
    content.Parent = MainFrame
    content.Size = UDim2.new(1, -10, 1, -95)
    content.Position = UDim2.new(0, 5, 0, 85)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    content.Visible = false
    content.Name = name .. "Content"
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    
    Tabs[name] = btn
    TabContents[name] = content
    
    btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.BackgroundTransparency = 1
            tab.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        for _, tabContent in pairs(TabContents) do
            tabContent.Visible = false
        end
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        content.Visible = true
        CurrentTab = name
        UpdateAllCanvas()
    end)
    
    return btn, content
end

-- Tạo các tab
local CombatTab, CombatContent = CreateTab("Combat", "⚔️")
local MovementTab, MovementContent = CreateTab("Movement", "🏃")
local ESPTab, ESPContent = CreateTab("ESP", "👁️")
local TeleportTab, TeleportContent = CreateTab("Teleport", "🚀")
local SettingsTab, SettingsContent = CreateTab("Settings", "⚙️")

-- Mặc định mở tab Combat
Tabs["Combat"]:BackgroundTransparency = 0.3
Tabs["Combat"]:TextColor3 = Color3.fromRGB(255, 255, 255)
CombatContent.Visible = true

-- ============================================
-- // PHẦN 2: HÀM TẠO NÚT BẬT TẮT
-- ============================================

local function CreateToggle(parent, label, key, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 52)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 6)
    
    local text = Instance.new("TextLabel")
    text.Parent = frame
    text.Size = UDim2.new(0.6, 0, 1, 0)
    text.Position = UDim2.new(0, 10, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.fromRGB(220, 220, 220)
    text.TextScaled = true
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0.25, 0, 0.7, 0)
    btn.Position = UDim2.new(0.7, 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = btn
    btnCorner.CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        Toggles[key] = not Toggles[key]
        btn.Text = Toggles[key] and "ON" or "OFF"
        btn.BackgroundColor3 = Toggles[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 60, 90)
        if callback then callback(Toggles[key]) end
        UpdateAllCanvas()
    end)
    
    return frame
end

-- ============================================
-- // PHẦN 3: BUILD TAB CONTENT
-- ============================================

-- // COMBAT TAB
local function BuildCombatTab()
    -- Auto Farm
    local farmFrame = Instance.new("Frame")
    farmFrame.Parent = CombatContent
    farmFrame.Size = UDim2.new(0.9, 0, 0, 50)
    farmFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    farmFrame.BorderSizePixel = 0
    
    local farmCorner = Instance.new("UICorner")
    farmCorner.Parent = farmFrame
    farmCorner.CornerRadius = UDim.new(0, 6)
    
    local farmLabel = Instance.new("TextLabel")
    farmLabel.Parent = farmFrame
    farmLabel.Size = UDim2.new(0.4, 0, 1, 0)
    farmLabel.Position = UDim2.new(0, 10, 0, 0)
    farmLabel.BackgroundTransparency = 1
    farmLabel.Text = "🤖 Auto Farm"
    farmLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    farmLabel.TextScaled = true
    farmLabel.Font = Enum.Font.GothamBold
    farmLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local farmBtn = Instance.new("TextButton")
    farmBtn.Parent = farmFrame
    farmBtn.Size = UDim2.new(0.2, 0, 0.7, 0)
    farmBtn.Position = UDim2.new(0.45, 0, 0.15, 0)
    farmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    farmBtn.Text = "START"
    farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    farmBtn.TextScaled = true
    farmBtn.Font = Enum.Font.GothamBold
    farmBtn.BorderSizePixel = 0
    
    local farmCorner2 = Instance.new("UICorner")
    farmCorner2.Parent = farmBtn
    farmCorner2.CornerRadius = UDim.new(0, 4)
    
    farmBtn.MouseButton1Click:Connect(function()
        IsAutoFarm = not IsAutoFarm
        farmBtn.Text = IsAutoFarm and "STOP" or "START"
        farmBtn.BackgroundColor3 = IsAutoFarm and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(60, 60, 90)
        if IsAutoFarm then
            StartAutoFarm()
        else
            StopAutoFarm()
        end
    end)
    
    -- Chọn quái
    local mobLabel = Instance.new("TextLabel")
    mobLabel.Parent = CombatContent
    mobLabel.Size = UDim2.new(0.9, 0, 0, 25)
    mobLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
    mobLabel.Text = "🎯 Chọn Quái: " .. (SelectedMob or "Chưa chọn")
    mobLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    mobLabel.TextScaled = true
    mobLabel.Font = Enum.Font.Gotham
    mobLabel.BorderSizePixel = 0
    mobLabel.Name = "MobLabel"
    
    local refreshMobs = Instance.new("TextButton")
    refreshMobs.Parent = CombatContent
    refreshMobs.Size = UDim2.new(0.2, 0, 0, 30)
    refreshMobs.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    refreshMobs.Text = "🔄 Quét"
    refreshMobs.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshMobs.TextScaled = true
    refreshMobs.Font = Enum.Font.GothamBold
    refreshMobs.BorderSizePixel = 0
    
    local mobCorner = Instance.new("UICorner")
    mobCorner.Parent = refreshMobs
    mobCorner.CornerRadius = UDim.new(0, 4)
    
    refreshMobs.MouseButton1Click:Connect(function()
        ScanMobs()
    end)
    
    -- Danh sách quái
    local mobListFrame = Instance.new("ScrollingFrame")
    mobListFrame.Parent = CombatContent
    mobListFrame.Size = UDim2.new(0.9, 0, 0, 100)
    mobListFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 38)
    mobListFrame.BorderSizePixel = 0
    mobListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    mobListFrame.ScrollBarThickness = 4
    mobListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    mobListFrame.Name = "MobList"
    
    local mobListLayout = Instance.new("UIListLayout")
    mobListLayout.Parent = mobListFrame
    mobListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mobListLayout.Padding = UDim.new(0, 2)
    
    -- Chọn vũ khí
    local weaponLabel = Instance.new("TextLabel")
    weaponLabel.Parent = CombatContent
    weaponLabel.Size = UDim2.new(0.9, 0, 0, 25)
    weaponLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
    weaponLabel.Text = "🗡️ Vũ Khí: " .. (SelectedWeapon or "Tay không")
    weaponLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    weaponLabel.TextScaled = true
    weaponLabel.Font = Enum.Font.Gotham
    weaponLabel.BorderSizePixel = 0
    weaponLabel.Name = "WeaponLabel"
    
    local weapons = {"Tay không", "Kiếm", "Súng", "Gậy", "Rìu", "Dao"}
    local weaponButtons = {}
    
    for i, w in ipairs(weapons) do
        local btn = Instance.new("TextButton")
        btn.Parent = CombatContent
        btn.Size = UDim2.new(0.14, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
        btn.Text = w
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.BackgroundTransparency = 0.2
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.Parent = btn
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            SelectedWeapon = w
            weaponLabel.Text = "🗡️ Vũ Khí: " .. w
            for _, b in pairs(weaponButtons) do
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                b.BackgroundTransparency = 0.2
            end
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            btn.BackgroundTransparency = 0
        end)
        
        table.insert(weaponButtons, btn)
    end
    
    -- Lưu references để cập nhật
    CombatContent.MobLabel = mobLabel
    CombatContent.WeaponLabel = weaponLabel
    CombatContent.MobListFrame = mobListFrame
    CombatContent.FarmBtn = farmBtn
end

-- // MOVEMENT TAB
local function BuildMovementTab()
    -- Fly Toggle
    CreateToggle(MovementContent, "✈️ Fly (F)", "Fly", function(val)
        if not val then
            if BodyVelocity then BodyVelocity:Destroy() end
            BodyVelocity = nil
            FlyEnabled = false
        end
    end)
    
    CreateToggle(MovementContent, "🦘 Super Jump", "SuperJump")
    CreateToggle(MovementContent, "👻 Noclip", "Noclip")
    CreateToggle(MovementContent, "👻 Ghost (F1)", "Ghost")
    
    -- Fly Speed Slider
    local speedFrame = Instance.new("Frame")
    speedFrame.Parent = MovementContent
    speedFrame.Size = UDim2.new(0.9, 0, 0, 45)
    speedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    speedFrame.BorderSizePixel = 0
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.Parent = speedFrame
    speedCorner.CornerRadius = UDim.new(0, 6)
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Parent = speedFrame
    speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
    speedLabel.Position = UDim2.new(0, 10, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Fly Speed: " .. FlySpeed
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    speedLabel.TextScaled = true
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local speedUp = Instance.new("TextButton")
    speedUp.Parent = speedFrame
    speedUp.Size = UDim2.new(0.1, 0, 0.7, 0)
    speedUp.Position = UDim2.new(0.55, 0, 0.15, 0)
    speedUp.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    speedUp.Text = "+"
    speedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedUp.TextScaled = true
    speedUp.Font = Enum.Font.GothamBold
    speedUp.BorderSizePixel = 0
    
    local speedUpCorner = Instance.new("UICorner")
    speedUpCorner.Parent = speedUp
    speedUpCorner.CornerRadius = UDim.new(0, 4)
    
    speedUp.MouseButton1Click:Connect(function()
        FlySpeed = math.min(200, FlySpeed + 5)
        speedLabel.Text = "Fly Speed: " .. FlySpeed
    end)
    
    local speedDown = Instance.new("TextButton")
    speedDown.Parent = speedFrame
    speedDown.Size = UDim2.new(0.1, 0, 0.7, 0)
    speedDown.Position = UDim2.new(0.7, 0, 0.15, 0)
    speedDown.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    speedDown.Text = "-"
    speedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedDown.TextScaled = true
    speedDown.Font = Enum.Font.GothamBold
    speedDown.BorderSizePixel = 0
    
    local speedDownCorner = Instance.new("UICorner")
    speedDownCorner.Parent = speedDown
    speedDownCorner.CornerRadius = UDim.new(0, 4)
    
    speedDown.MouseButton1Click:Connect(function()
        FlySpeed = math.max(10, FlySpeed - 5)
        speedLabel.Text = "Fly Speed: " .. FlySpeed
    end)
    
    -- Jump Power Slider
    local jumpFrame = Instance.new("Frame")
    jumpFrame.Parent = MovementContent
    jumpFrame.Size = UDim2.new(0.9, 0, 0, 45)
    jumpFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    jumpFrame.BorderSizePixel = 0
    
    local jumpCorner = Instance.new("UICorner")
    jumpCorner.Parent = jumpFrame
    jumpCorner.CornerRadius = UDim.new(0, 6)
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Parent = jumpFrame
    jumpLabel.Size = UDim2.new(0.5, 0, 1, 0)
    jumpLabel.Position = UDim2.new(0, 10, 0, 0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Jump Power: " .. JumpPower
    jumpLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    jumpLabel.TextScaled = true
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local jumpUp = Instance.new("TextButton")
    jumpUp.Parent = jumpFrame
    jumpUp.Size = UDim2.new(0.1, 0, 0.7, 0)
    jumpUp.Position = UDim2.new(0.55, 0, 0.15, 0)
    jumpUp.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    jumpUp.Text = "+"
    jumpUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpUp.TextScaled = true
    jumpUp.Font = Enum.Font.GothamBold
    jumpUp.BorderSizePixel = 0
    
    local jumpUpCorner = Instance.new("UICorner")
    jumpUpCorner.Parent = jumpUp
    jumpUpCorner.CornerRadius = UDim.new(0, 4)
    
    jumpUp.MouseButton1Click:Connect(function()
        JumpPower = math.min(800, JumpPower + 50)
        jumpLabel.Text = "Jump Power: " .. JumpPower
    end)
    
    local jumpDown = Instance.new("TextButton")
    jumpDown.Parent = jumpFrame
    jumpDown.Size = UDim2.new(0.1, 0, 0.7, 0)
    jumpDown.Position = UDim2.new(0.7, 0, 0.15, 0)
    jumpDown.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    jumpDown.Text = "-"
    jumpDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpDown.TextScaled = true
    jumpDown.Font = Enum.Font.GothamBold
    jumpDown.BorderSizePixel = 0
    
    local jumpDownCorner = Instance.new("UICorner")
    jumpDownCorner.Parent = jumpDown
    jumpDownCorner.CornerRadius = UDim.new(0, 4)
    
    jumpDown.MouseButton1Click:Connect(function()
        JumpPower = math.max(50, JumpPower - 50)
        jumpLabel.Text = "Jump Power: " .. JumpPower
    end)
end

-- // ESP TAB
local function BuildESPTab()
    CreateToggle(ESPTab, "👤 ESP Players", "ESPPlayers")
    CreateToggle(ESPTab, "👾 ESP Mobs", "ESPMobs")
    CreateToggle(ESPTab, "🍎 ESP Fruits", "ESPFruits")
    CreateToggle(ESPTab, "🌙 Night Vision (F2)", "NightVision")
    CreateToggle(ESPTab, "🔧 Fix Lag", "FixLag")
end

-- // TELEPORT TAB
local function BuildTeleportTab()
    -- Scan button
    local scanBtn = Instance.new("TextButton")
    scanBtn.Parent = TeleportContent
    scanBtn.Size = UDim2.new(0.4, 0, 0, 35)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    scanBtn.Text = "🔍 Quét Map"
    scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanBtn.TextScaled = true
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.BorderSizePixel = 0
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.Parent = scanBtn
    scanCorner.CornerRadius = UDim.new(0, 6)
    
    scanBtn.MouseButton1Click:Connect(function()
        BuildTeleportList()
    end)
    
    -- Selected location
    local locLabel = Instance.new("TextLabel")
    locLabel.Parent = TeleportContent
    locLabel.Size = UDim2.new(0.9, 0, 0, 25)
    locLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
    locLabel.Text = "📍 " .. SelectedMapName
    locLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    locLabel.TextScaled = true
    locLabel.Font = Enum.Font.GothamBold
    locLabel.BorderSizePixel = 0
    locLabel.Name = "LocLabel"
    
    -- Teleport button
    local teleBtn = Instance.new("TextButton")
    teleBtn.Parent = TeleportContent
    teleBtn.Size = UDim2.new(0.3, 0, 0, 35)
    teleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    teleBtn.Text = "🚀 Dịch Chuyển"
    teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleBtn.TextScaled = true
    teleBtn.Font = Enum.Font.GothamBold
    teleBtn.BorderSizePixel = 0
    
    local teleCorner = Instance.new("UICorner")
    teleCorner.Parent = teleBtn
    teleCorner.CornerRadius = UDim.new(0, 6)
    
    teleBtn.MouseButton1Click:Connect(function()
        if SelectedMapPoint then
            TeleportTo(SelectedMapPoint)
        else
            print("⚠️ Chưa chọn điểm dịch chuyển!")
        end
    end)
    
    -- Clear button
    local clearBtn = Instance.new("TextButton")
    clearBtn.Parent = TeleportContent
    clearBtn.Size = UDim2.new(0.2, 0, 0, 35)
    clearBtn.Position = UDim2.new(0.35, 0, 0, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    clearBtn.Text = "🧹 Bỏ chọn"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.TextScaled = true
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.BorderSizePixel = 0
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.Parent = clearBtn
    clearCorner.CornerRadius = UDim.new(0, 6)
    
    clearBtn.MouseButton1Click:Connect(function()
        SelectedMapPoint = nil
        SelectedMapName = "Chưa chọn"
        locLabel.Text = "📍 Chưa chọn"
    end)
    
    -- List of locations
    local locListFrame = Instance.new("ScrollingFrame")
    locListFrame.Parent = TeleportContent
    locListFrame.Size = UDim2.new(0.9, 0, 0, 200)
    locListFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 38)
    locListFrame.BorderSizePixel = 0
    locListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    locListFrame.ScrollBarThickness = 4
    locListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    locListFrame.Name = "LocList"
    
    local locListLayout = Instance.new("UIListLayout")
    locListLayout.Parent = locListFrame
    locListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    locListLayout.Padding = UDim.new(0, 2)
    
    TeleportContent.LocLabel = locLabel
    TeleportContent.LocList = locListFrame
end

-- // SETTINGS TAB
local function BuildSettingsTab()
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Parent = SettingsContent
    infoLabel.Size = UDim2.new(0.9, 0, 0, 80)
    infoLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
    infoLabel.Text = "⚡ MV HUB v5.0\nBy Axiom\nHotkeys: M - Menu | F - Fly | F1 - Ghost | F2 - Night Vision"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.BorderSizePixel = 0
    
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Parent = SettingsContent
    creditLabel.Size = UDim2.new(0.9, 0, 0, 40)
    creditLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
    creditLabel.Text = "📌 ESP hiển thị khoảng cách (mét)\n✅ Auto Farm tự động tấn công quái gần nhất"
    creditLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    creditLabel.TextScaled = true
    creditLabel.Font = Enum.Font.Gotham
    creditLabel.BorderSizePixel = 0
end

-- ============================================
-- // PHẦN 4: CẬP NHẬT CANVAS
-- ============================================

local function UpdateAllCanvas()
    for name, content in pairs(TabContents) do
        if content and content:IsA("ScrollingFrame") then
            local size = 10
            for _, child in pairs(content:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("ScrollingFrame") then
                    if child.Name ~= "MobList" and child.Name ~= "LocList" then
                        size = size + child.Size.Y.Offset + 6
                    end
                end
            end
            -- Thêm space cho các list
            local mobList = content:FindFirstChild("MobList")
            if mobList then
                size = size + 110
            end
            local locList = content:FindFirstChild("LocList")
            if locList then
                size = size + 210
            end
            content.CanvasSize = UDim2.new(0, 0, 0, size + 30)
        end
    end
end

-- ============================================
-- // PHẦN 5: CHỨC NĂNG CHÍNH
-- ============================================

-- // SCAN MOBS
function ScanMobs()
    MobsList = {}
    local mobList = CombatContent:FindFirstChild("MobList")
    if not mobList then return end
    
    -- Clear existing buttons
    for _, child in pairs(mobList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Scan for mobs
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = v.Name:lower()
            local isMob = name:find("npc") or name:find("mob") or name:find("boss") or name:find("enemy") or 
                         name:find("zombie") or name:find("skeleton") or name:find("spider") or name:find("wolf") or
                         name:find("monster") or name:find("creature") or name:find("golem") or name:find("demon")
            
            if isMob then
                local lvl = "?"
                if v:FindFirstChild("Level") then
                    lvl = v.Level.Value
                elseif v:FindFirstChild("LevelValue") then
                    lvl = v.LevelValue.Value
                end
                table.insert(MobsList, {
                    Model = v,
                    Name = v.Name,
                    Level = lvl,
                    Root = v.HumanoidRootPart,
                    Humanoid = v.Humanoid
                })
            end
        end
    end
    
    -- Fallback: lấy tất cả model có humanoid nhưng không phải player
    if #MobsList == 0 then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if not Players:GetPlayerFromCharacter(v) then
                    local lvl = "?"
                    if v:FindFirstChild("Level") then
                        lvl = v.Level.Value
                    elseif v:FindFirstChild("LevelValue") then
                        lvl = v.LevelValue.Value
                    end
                    table.insert(MobsList, {
                        Model = v,
                        Name = v.Name,
                        Level = lvl,
                        Root = v.HumanoidRootPart,
                        Humanoid = v.Humanoid
                    })
                end
            end
        end
    end
    
    -- Create buttons
    for i, mobData in ipairs(MobsList) do
        local btn = Instance.new("TextButton")
        btn.Parent = mobList
        btn.Size = UDim2.new(1, -4, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
        btn.Text = "👾 " .. mobData.Name .. " (Lv." .. mobData.Level .. ")"
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.BackgroundTransparency = 0.2
        btn.Name = "MobBtn_" .. i
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.Parent = btn
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            SelectedMob = mobData.Name
            local mobLabel = CombatContent:FindFirstChild("MobLabel")
            if mobLabel then
                mobLabel.Text = "🎯 Chọn Quái: " .. mobData.Name .. " (Lv." .. mobData.Level .. ")"
            end
            for _, b in pairs(mobList:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                    b.BackgroundTransparency = 0.2
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            btn.BackgroundTransparency = 0
        end)
    end
    
    local count = #MobsList
    mobList.CanvasSize = UDim2.new(0, 0, 0, count * 32 + 10)
    print("🔍 Đã quét được " .. count .. " quái")
end

-- // AUTO FARM
function StartAutoFarm()
    if FarmLoop then 
        FarmLoop:Disconnect()
        FarmLoop = nil
    end
    
    FarmLoop = RunService.Heartbeat:Connect(function()
        if not IsAutoFarm then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        
        -- Tìm target gần nhất
        local target = nil
        local targetDist = math.huge
        
        for _, mobData in pairs(MobsList) do
            if mobData.Model and mobData.Model.Parent and mobData.Humanoid and mobData.Humanoid.Health > 0 then
                local dist = (root.Position - mobData.Root.Position).Magnitude
                if dist < targetDist then
                    targetDist = dist
                    target = mobData
                end
            end
        end
        
        if target then
            FarmTarget = target
            local hrp = target.Root
            
            -- Di chuyển đến gần target
            if targetDist > 5 then
                local direction = (hrp.Position - root.Position).Unit
                local newPos = root.Position + direction * math.min(targetDist - 2, 15)
                root.CFrame = CFrame.new(newPos, hrp.Position)
            end
            
            -- Tấn công
            if targetDist < 25 then
                AttackTarget(target)
            end
        else
            -- Không có quái, quét lại
            if IsAutoFarm then
                ScanMobs()
            end
        end
    end)
end

function StopAutoFarm()
    if FarmLoop then
        FarmLoop:Disconnect()
        FarmLoop = nil
    end
    FarmTarget = nil
    print("🛑 Đã dừng Auto Farm")
end

-- // ATTACK TARGET
function AttackTarget(target)
    if not target or not target.Model then return end
    
    -- Thử các phương thức tấn công khác nhau
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Phương thức 1: Click vào quái
    local hrp = target.Root
    if hrp then
        -- Simulate click
        local args = {
            [1] = hrp
        }
        
        -- Thử các remote khác nhau
        local remotes = {
            "RemoteEvent",
            "AttackRemote",
            "CombatRemote",
            "ClickRemote",
            "DamageRemote",
            "MeleeRemote",
            "SwordRemote"
        }
        
        for _, remoteName in pairs(remotes) do
            local remote = ReplicatedStorage:FindFirstChild(remoteName)
            if remote then
                pcall(function()
                    remote:FireServer(unpack(args))
                end)
            end
        end
        
        -- Phương thức 2: Dùng tool
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                tool:Activate()
            end)
        end
        
        -- Phương thức 3: Click chuột
        pcall(function()
            Mouse.Button1Click()
        end)
    end
end

-- // TELEPORT
function TeleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local oldPos = root.Position
        
        -- Tạo hiệu ứng ở vị trí cũ
        local bp = Instance.new("Part")
        bp.Size = Vector3.new(3, 3, 3)
        bp.Position = oldPos
        bp.Anchored = true
        bp.CanCollide = false
        bp.BrickColor = BrickColor.new("Bright blue")
        bp.Material = Enum.Material.Neon
        bp.Parent = workspace
        TweenService:Create(bp, TweenInfo.new(0.5), {Size = Vector3.new(30, 30, 30), Transparency = 1}):Play()
        Debris:AddItem(bp, 0.5)
        
        -- Tạo hiệu ứng ở vị trí mới
        local bp2 = Instance.new("Part")
        bp2.Size = Vector3.new(3, 3, 3)
        bp2.Position = pos
        bp2.Anchored = true
        bp2.CanCollide = false
        bp2.BrickColor = BrickColor.new("Bright green")
        bp2.Material = Enum.Material.Neon
        bp2.Parent = workspace
        TweenService:Create(bp2, TweenInfo.new(0.5), {Size = Vector3.new(30, 30, 30), Transparency = 1}):Play()
        Debris:AddItem(bp2, 0.5)
        
        -- Teleport
        root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        print("🚀 Đã dịch chuyển đến: " .. SelectedMapName)
    end
end

-- // BUILD TELEPORT LIST
function BuildTeleportList()
    DetectedMapPoints = {}
    local locList = TeleportContent:FindFirstChild("LocList")
    if not locList then return end
    
    for _, child in pairs(locList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    ScanMapPoints()
    
    for i, data in ipairs(DetectedMapPoints) do
        local btn = Instance.new("TextButton")
        btn.Parent = locList
        btn.Size = UDim2.new(1, -4, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
        btn.Text = data.Name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.BackgroundTransparency = 0.2
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.Parent = btn
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            SelectedMapPoint = data.Position
            SelectedMapName = data.Name
            local locLabel = TeleportContent:FindFirstChild("LocLabel")
            if locLabel then
                locLabel.Text = "📍 " .. data.Name
            end
            for _, b in pairs(locList:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                    b.BackgroundTransparency = 0.2
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            btn.BackgroundTransparency = 0
        end)
    end
    
    locList.CanvasSize = UDim2.new(0, 0, 0, #DetectedMapPoints * 32 + 10)
    print("🗺️ Đã quét được " .. #DetectedMapPoints .. " điểm")
end

-- // SCAN MAP POINTS
function ScanMapPoints()
    DetectedMapPoints = {}
    
    -- Scan models
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
            local root = model.HumanoidRootPart
            if root and root.Position then
                local name = model.Name
                if not Players:GetPlayerFromCharacter(model) then
                    table.insert(DetectedMapPoints, {
                        Name = "📍 " .. name,
                        Position = root.Position
                    })
                end
            end
        end
    end
    
    -- Scan parts
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Size.Magnitude > 50 then
            local name = part.Name
            if not string.find(name, "Terrain") and not string.find(name, "Baseplate") then
                table.insert(DetectedMapPoints, {
                    Name = "🏔️ " .. name,
                    Position = part.Position
                })
            end
        end
    end
    
    if #DetectedMapPoints == 0 then
        table.insert(DetectedMapPoints, {Name = "🌍 Center", Position = Vector3.new(0, 10, 0)})
        table.insert(DetectedMapPoints, {Name = "⬆️ High", Position = Vector3.new(0, 200, 0)})
    end
    
    if #DetectedMapPoints > 50 then
        local newList = {}
        for i = 1, 50 do
            newList[i] = DetectedMapPoints[i]
        end
        DetectedMapPoints = newList
    end
end

-- ============================================
-- // PHẦN 6: ESP VỚI KHOẢNG CÁCH
-- ============================================

function CreateESP(object, color, text, objType)
    if not object or not object:IsA("BasePart") then return end
    
    -- Xóa ESP cũ
    for _, v in pairs(object:GetChildren()) do
        if v:IsA("BillboardGui") and v.Name == "MV_ESP" then
            v:Destroy()
        end
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MV_ESP"
    billboard.Size = UDim2.new(0, 220, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = object
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local label = Instance.new("TextLabel")
    label.Name = "NameLabel"
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "ESP"
    label.TextColor3 = color or Color3.fromRGB(255, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.2
    label.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0.2
    distLabel.Parent = billboard

    table.insert(ESPObjects, {
        Object = object,
        Billboard = billboard,
        DistLabel = distLabel,
        Type = objType or "unknown"
    })
end

-- Update distance
function UpdateDistances()
    spawn(function()
        while wait(ESPUpdateRate) do
            local char = LocalPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local myPos = root.Position

            for i = #ESPObjects, 1, -1 do
                local data = ESPObjects[i]
                if data.Object and data.Object.Parent then
                    local targetPos = data.Object.Position
                    if targetPos then
                        local dist = (myPos - targetPos).Magnitude
                        local distM = math.floor(dist)
                        
                        local color
                        if distM < 50 then
                            color = Color3.fromRGB(0, 255, 0)      -- Xanh lá (gần)
                        elseif distM < 150 then
                            color = Color3.fromRGB(255, 255, 0)    -- Vàng (trung bình)
                        else
                            color = Color3.fromRGB(255, 100, 0)    -- Cam (xa)
                        end
                        
                        if data.DistLabel then
                            data.DistLabel.Text = distM .. "m"
                            data.DistLabel.TextColor3 = color
                        end
                    end
                else
                    if data.Billboard then data.Billboard:Destroy() end
                    table.remove(ESPObjects, i)
                end
            end
        end
    end)
end

-- ESP Loop
function ESPLoop()
    spawn(function()
        while wait(0.5) do
            -- PLAYER ESP
            if Toggles.ESPPlayers then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local root = player.Character.HumanoidRootPart
                        local hasESP = false
                        for _, data in pairs(ESPObjects) do
                            if data.Object == root then hasESP = true; break end
                        end
                        if not hasESP then
                            CreateESP(root, Color3.fromRGB(0, 255, 0), "👤 " .. player.Name, "player")
                        end
                    end
                end
            end

            -- MOB ESP
            if Toggles.ESPMobs then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        local name = v.Name:lower()
                        local isMob = name:find("npc") or name:find("mob") or name:find("boss") or name:find("enemy") or
                                     name:find("zombie") or name:find("skeleton") or name:find("spider")
                        if isMob then
                            local root = v.HumanoidRootPart
                            local hasESP = false
                            for _, data in pairs(ESPObjects) do
                                if data.Object == root then hasESP = true; break end
                            end
                            if not hasESP then
                                local lvl = ""
                                if v:FindFirstChild("Level") then
                                    lvl = " Lv." .. v.Level.Value
                                end
                                CreateESP(root, Color3.fromRGB(255, 200, 0), "👾 " .. v.Name .. lvl, "mob")
                            end
                        end
                    end
                end
            end

            -- FRUIT ESP
            if Toggles.ESPFruits then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name:lower():find("fruit") then
                        local root = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Handle") or v.PrimaryPart
                        if root then
                            local hasESP = false
                            for _, data in pairs(ESPObjects) do
                                if data.Object == root then hasESP = true; break end
                            end
                            if not hasESP then
                                CreateESP(root, Color3.fromRGB(255, 0, 255), "🍎 " .. v.Name, "fruit")
                            end
                        end
                    end
                end
            end

            -- Cleanup
            for i = #ESPObjects, 1, -1 do
                local data = ESPObjects[i]
                if data.Object and data.Object.Parent then
                    local shouldKeep = false
                    if data.Type == "player" and Toggles.ESPPlayers then
                        shouldKeep = true
                    elseif data.Type == "mob" and Toggles.ESPMobs then
                        shouldKeep = true
                    elseif data.Type == "fruit" and Toggles.ESPFruits then
                        shouldKeep = true
                    end
                    if not shouldKeep then
                        if data.Billboard then data.Billboard:Destroy() end
                        table.remove(ESPObjects, i)
                    end
                else
                    if data.Billboard then data.Billboard:Destroy() end
                    table.remove(ESPObjects, i)
                end
            end
        end
    end)
end

-- ============================================
-- // PHẦN 7: CÁC HÀM HỖ TRỢ
-- ============================================

-- Fix Lag
local function FixLagLoop()
    spawn(function()
        while wait(1) do
            if Toggles.FixLag then
                settings().Rendering.QualityLevel = 1
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                end
                Lighting.GlobalShadows = false
                Lighting.Brightness = 2
            end
        end
    end)
end

-- Super Jump
local function SuperJumpLoop()
    spawn(function()
        while wait(0.1) do
            if Toggles.SuperJump then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = JumpPower
                end
            end
        end
    end)
end

-- Fly
local function FlyLoop()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F and Toggles.Fly then
            local char = LocalPlayer.Character
            if not char then return end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end

            FlyEnabled = not FlyEnabled
            if FlyEnabled then
                BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                BodyVelocity.Parent = rootPart
                print("✈️ Fly: ON")
            else
                if BodyVelocity then 
                    BodyVelocity:Destroy() 
                    BodyVelocity = nil
                end
                print("✈️ Fly: OFF")
            end
        end
    end)

    spawn(function()
        while wait() do
            if FlyEnabled and Toggles.Fly and BodyVelocity then
                local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not rootPart then
                    FlyEnabled = false
                    if BodyVelocity then BodyVelocity:Destroy() end
                    BodyVelocity = nil
                    continue
                end

                local moveDirection = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
                    moveDirection = moveDirection + Camera.CFrame.LookVector * Vector3.new(1, 0, 1) 
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
                    moveDirection = moveDirection - Camera.CFrame.LookVector * Vector3.new(1, 0, 1) 
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
                    moveDirection = moveDirection - Camera.CFrame.RightVector * Vector3.new(1, 0, 1) 
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
                    moveDirection = moveDirection + Camera.CFrame.RightVector * Vector3.new(1, 0, 1) 
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                    moveDirection = moveDirection + Vector3.new(0, 1, 0) 
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                    moveDirection = moveDirection - Vector3.new(0, 1, 0) 
                end

                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit * FlySpeed
                end
                BodyVelocity.Velocity = moveDirection
            end
        end
    end)
end

-- Noclip
local function NoclipLoop()
    spawn(function()
        while wait(0.1) do
            if Toggles.Noclip then
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            else
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    end)
end

-- Ghost
local function GhostLoop()
    spawn(function()
        while wait(0.1) do
            if Toggles.Ghost then
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0.3
                            part.CanCollide = false
                        end
                    end
                end
            else
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    end)
end

-- Night Vision
local function NightVisionLoop()
    spawn(function()
        while wait(0.5) do
            if Toggles.NightVision then
                Lighting.Brightness = 5
                Lighting.ClockTime = 12
                Lighting.FogEnd = 99999
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                for _, v in pairs(Lighting:GetDescendants()) do
                    if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
                        v.Enabled = false
                    end
                end
            else
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = true
                Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            end
        end
    end)
end

-- Anti-Idle
local function AntiIdleLoop()
    spawn(function()
        while wait(60) do
            pcall(function()
                LocalPlayer.Idled:Connect(function()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
        end
    end)
end

-- ============================================
-- // PHẦN 8: KHỞI TẠO
-- ============================================

-- Tạo UI
BuildCombatTab()
BuildMovementTab()
BuildESPTab()
BuildTeleportTab()
BuildSettingsTab()

-- Khởi tạo các loop
FixLagLoop()
SuperJumpLoop()
FlyLoop()
NoclipLoop()
ESPLoop()
UpdateDistances()
GhostLoop()
NightVisionLoop()
AntiIdleLoop()

-- Scan ban đầu
spawn(function()
    wait(1)
    ScanMobs()
    BuildTeleportList()
    UpdateAllCanvas()
end)

-- // Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        MenuOpen = not MenuOpen
        MainFrame.Visible = MenuOpen
        if MenuOpen then
            BuildTeleportList()
            ScanMobs()
        end
    end
    if input.KeyCode == Enum.KeyCode.F1 then
        Toggles.Ghost = not Toggles.Ghost
        print("👻 Ghost: " .. (Toggles.Ghost and "ON" or "OFF"))
    end
    if input.KeyCode == Enum.KeyCode.F2 then
        Toggles.NightVision = not Toggles.NightVision
        print("🌙 Night Vision: " .. (Toggles.NightVision and "ON" or "OFF"))
    end
end)

print("⚡ MV HUB v5.0 LOADED SUCCESSFULLY!")
print("📌 M - Menu | F - Fly | F1 - Ghost | F2 - Night Vision")
print("📌 Auto Farm tự động tìm và tấn công quái gần nhất")
print("📌 ESP hiển thị khoảng cách theo mét với màu sắc tương ứng")