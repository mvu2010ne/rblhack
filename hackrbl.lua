-- MV Hub | Axiom Build v6.3
-- Auto Farm Select: Load all mobs on map, show level, choose target, choose weapon, auto farm

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // UI Variables
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local ToggleBtn = Instance.new("TextButton")
local ResizeHandle = Instance.new("Frame")
local ResizeCorner = Instance.new("ImageLabel")

-- // Category Scroll
local CategoryScroll = Instance.new("ScrollingFrame")
local CategoryList = Instance.new("UIListLayout")
local CategoryBoxes = {}
local CategoryNames = {"⚔️ Combat", "🦘 Movement", "👁️ Visual", "📡 Tracer", "🚀 Teleport"}

-- // Resize Variables
local MinSize = 550
local MaxSize = 950
local IsResizing = false
local ResizeStartPos
local ResizeStartSize

-- // Icon Drag
local IsDraggingIcon = false
local DragStartPos
local IconStartPos
local DragThreshold = 15

-- // Toggle States
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
    TracerPlayers = false,
    TracerMobs = false,
    AutoFarm = false,
    AutoSkill = false,
    PullMobs = false
}

-- // Auto Farm Variables
local SelectedMob = nil
local SelectedMobName = "Chưa chọn"
local SelectedMobPosition = nil
local AutoFarmWeapon = "Melee"
local AutoFarmWeapons = {"Melee", "Sword", "Gun", "Fruit"}
local AutoFarmAttackCooldown = 0
local AutoFarmSkillCooldown = 0
local AllMobs = {}
local MobButtons = {}

-- // Fly Variables
local FlySpeed = 50
local JumpPower = 250
local GhostStealth = 0.3
local flyEnabled = false
local flyBodyPosition = nil
local flyBodyGyro = nil

-- // Menu State
local MenuOpen = false

-- // Teleport Variables
local SelectedMapPoint = nil
local SelectedMapName = "Chưa chọn"
local DetectedMapPoints = {}

-- // ESP & Tracer
local ESPObjects = {}
local ESPUpdateRate = 0.3
local TracerLines = {}
local TracerUpdateRate = 0.1

-- // ============ GET ALL MOBS WITH LEVEL ============
local function GetAllMobs()
    local mobs = {}
    local playerLevel = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") 
        and LocalPlayer.Data.Level.Value or 0
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = v.Name:lower()
            if name:find("npc") or name:find("mob") or name:find("boss") or name:find("enemy") or name:find("marine") or name:find("pirate") or name:find("bandit") then
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local root = v:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Lấy level từ tên hoặc từ attribute
                        local level = 0
                        local mobName = v.Name
                        -- Thử lấy level từ tên (vd: "Bandit Lv.15" -> 15)
                        local levelMatch = string.match(mobName, "Lv%.?(%d+)") or string.match(mobName, "Level (%d+)") or string.match(mobName, "(%d+)")
                        if levelMatch then
                            level = tonumber(levelMatch) or 0
                        end
                        -- Thử lấy từ attribute
                        local levelAttr = v:FindFirstChild("Level")
                        if levelAttr then
                            level = levelAttr.Value
                        end
                        -- Thử lấy từ humanoid display name
                        if level == 0 and humanoid.DisplayName then
                            local dnMatch = string.match(humanoid.DisplayName, "(%d+)")
                            if dnMatch then level = tonumber(dnMatch) or 0 end
                        end
                        
                        table.insert(mobs, {
                            Model = v,
                            Name = v.Name,
                            Root = root,
                            Humanoid = humanoid,
                            Position = root.Position,
                            Level = level,
                            Health = humanoid.Health,
                            MaxHealth = humanoid.MaxHealth
                        })
                    end
                end
            end
        end
    end
    
    -- Sắp xếp theo level tăng dần
    table.sort(mobs, function(a, b)
        return a.Level < b.Level
    end)
    
    return mobs
end

-- // ============ UPDATE MOB LIST UI ============
local function UpdateMobList()
    local combat = CategoryBoxes["⚔️ Combat"]
    if not combat then return end
    
    -- Xóa mob list cũ (giữ lại các toggle và dropdown)
    local toRemove = {}
    for _, child in pairs(combat:GetChildren()) do
        if child:IsA("ScrollingFrame") and child.Name == "MobList" then
            table.insert(toRemove, child)
        end
    end
    for _, child in pairs(toRemove) do
        child:Destroy()
    end
    MobButtons = {}
    
    -- Scan all mobs
    AllMobs = GetAllMobs()
    
    -- Tạo ScrollingFrame cho danh sách quái
    local mobScroll = Instance.new("ScrollingFrame")
    mobScroll.Name = "MobList"
    mobScroll.Parent = combat
    mobScroll.Size = UDim2.new(1, -6, 0, 120)
    mobScroll.Position = UDim2.new(0, 3, 0, 180) -- Đặt dưới các toggle
    mobScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
    mobScroll.BackgroundTransparency = 0.3
    mobScroll.BorderSizePixel = 0
    mobScroll.CanvasSize = UDim2.new(0, 0, 0, #AllMobs * 32 + 10)
    mobScroll.ScrollBarThickness = 4
    mobScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    
    local corner = Instance.new("UICorner")
    corner.Parent = mobScroll
    corner.CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel")
    label.Parent = mobScroll
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = "📋 DANH SÁCH QUÁI (" .. #AllMobs .. " con)"
    label.TextColor3 = Color3.fromRGB(255, 200, 50)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    
    local yOff = 26
    for i, mob in ipairs(AllMobs) do
        local btn = Instance.new("TextButton")
        btn.Parent = mobScroll
        btn.Size = UDim2.new(1, -4, 0, 28)
        btn.Position = UDim2.new(0, 2, 0, yOff)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
        btn.BackgroundTransparency = 0.2
        btn.Text = "⚔️ " .. mob.Name .. " | Lv." .. mob.Level .. " | HP: " .. math.floor(mob.Health) .. "/" .. math.floor(mob.MaxHealth)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.Parent = btn
        btnCorner.CornerRadius = UDim.new(0, 3)
        
        -- Lưu mob data vào button
        btn.MobData = mob
        
        btn.MouseButton1Click:Connect(function()
            SelectedMob = mob.Model
            SelectedMobName = mob.Name
            SelectedMobPosition = mob.Position
            -- Highlight button
            for _, b in pairs(MobButtons) do
                if b and b ~= btn then
                    b.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                    b.BackgroundTransparency = 0.2
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            btn.BackgroundTransparency = 0
            print("🎯 Đã chọn quái: " .. mob.Name .. " (Lv." .. mob.Level .. ")")
        end)
        
        table.insert(MobButtons, btn)
        yOff = yOff + 32
    end
    
    mobScroll.CanvasSize = UDim2.new(0, 0, 0, yOff + 10)
    
    -- Refresh nút quét lại
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Parent = combat
    refreshBtn.Size = UDim2.new(0.5, -6, 0, 28)
    refreshBtn.Position = UDim2.new(0, 3, 0, 310)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    refreshBtn.Text = "🔄 Quét Lại"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.TextScaled = true
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.BorderSizePixel = 0
    
    local corner2 = Instance.new("UICorner")
    corner2.Parent = refreshBtn
    corner2.CornerRadius = UDim.new(0, 4)
    
    refreshBtn.MouseButton1Click:Connect(function()
        UpdateMobList()
        print("🔄 Đã quét lại danh sách quái")
    end)
    
    -- Cập nhật canvas size cho combat box
    local parentScroll = combat.Parent
    if parentScroll and parentScroll:IsA("ScrollingFrame") then
        parentScroll.CanvasSize = UDim2.new(0, 0, 0, 360)
    end
end

-- // ============ AUTO FARM CORE ============
local function GetWeapon(toolName)
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local backpack = LocalPlayer.Backpack
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if toolName == "Melee" and (name:find("melee") or name:find("fist") or name:find("combat") or name:find("superhuman") or name:find("dark step") or name:find("electric") or name:find("fighting")) then
                return tool
            elseif toolName == "Sword" and (name:find("sword") or name:find("blade") or name:find("katana") or name:find("cutlass") or name:find("saber") or name:find("dual")) then
                return tool
            elseif toolName == "Gun" and (name:find("gun") or name:find("pistol") or name:find("rifle") or name:find("cannon") or name:find("bazooka") or name:find("musket")) then
                return tool
            elseif toolName == "Fruit" and (name:find("fruit") or name:find("devil") or name:find("blox") or name:find("flame") or name:find("ice") or name:find("light") or name:find("dark") or name:find("venom") or name:find("dough")) then
                return tool
            end
        end
    end
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if toolName == "Melee" and (name:find("melee") or name:find("fist") or name:find("combat") or name:find("superhuman") or name:find("dark step") or name:find("electric") or name:find("fighting")) then
                return tool
            elseif toolName == "Sword" and (name:find("sword") or name:find("blade") or name:find("katana") or name:find("cutlass") or name:find("saber") or name:find("dual")) then
                return tool
            elseif toolName == "Gun" and (name:find("gun") or name:find("pistol") or name:find("rifle") or name:find("cannon") or name:find("bazooka") or name:find("musket")) then
                return tool
            elseif toolName == "Fruit" and (name:find("fruit") or name:find("devil") or name:find("blox") or name:find("flame") or name:find("ice") or name:find("light") or name:find("dark") or name:find("venom") or name:find("dough")) then
                return tool
            end
        end
    end
    
    return nil
end

local function EquipWeapon(weaponType)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local tool = GetWeapon(weaponType)
    if tool then
        if tool.Parent == LocalPlayer.Backpack then
            tool.Parent = char
        end
        if tool.Parent == char then
            char.Humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

local function UseSkill()
    local char = LocalPlayer.Character
    if not char then return false end
    
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local remote = child:FindFirstChild("RemoteEvent") or child:FindFirstChild("Activate")
            if remote then
                remote:FireServer()
                return true
            end
            if child:FindFirstChild("Handle") then
                local handle = child.Handle
                if handle and handle:FindFirstChild("ClickDetector") then
                    handle.ClickDetector:Click()
                    return true
                end
            end
        end
    end
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        local remote = currentTool:FindFirstChild("RemoteEvent")
        if remote then
            remote:FireServer()
            return true
        end
    end
    
    return false
end

local function AutoAttack(target)
    if not target then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    
    local lookVector = (targetRoot.Position - root.Position).Unit
    root.CFrame = CFrame.new(root.Position, root.Position + lookVector)
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        mouse1click()
        return true
    end
    return false
end

local function AutoFarmLoop()
    spawn(function()
        while wait(0.1) do
            if Toggles.AutoFarm then
                local char = LocalPlayer.Character
                if not char then continue end
                local humanoid = char:FindFirstChild("Humanoid")
                if not humanoid or humanoid.Health <= 0 then continue end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                
                -- Nếu bật gom quái
                if Toggles.PullMobs then
                    PullPoint = root.Position
                    PullMobsToPoint(PullPoint, PullRange)
                    wait(0.3)
                end
                
                -- Kiểm tra target đã chọn
                local target = SelectedMob
                local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = target and target:FindFirstChild("Humanoid")
                
                -- Nếu target chết hoặc không tồn tại, tìm lại
                if not target or not target.Parent or not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
                    -- Tìm quái gần nhất cùng tên
                    local mobs = GetAllMobs()
                    for _, m in pairs(mobs) do
                        if m.Name == SelectedMobName and m.Humanoid.Health > 0 then
                            SelectedMob = m.Model
                            SelectedMobPosition = m.Position
                            target = SelectedMob
                            targetRoot = m.Root
                            targetHumanoid = m.Humanoid
                            break
                        end
                    end
                    -- Nếu không tìm thấy, tìm quái gần nhất
                    if not target then
                        local nearest = GetNearestMob()
                        if nearest then
                            SelectedMob = nearest
                            target = nearest
                            targetRoot = nearest:FindFirstChild("HumanoidRootPart")
                            targetHumanoid = nearest:FindFirstChild("Humanoid")
                        else
                            -- Không có quái, đứng yên
                            humanoid:MoveTo(humanoid.RootPart.Position)
                            continue
                        end
                    end
                end
                
                if target and targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local dist = (root.Position - targetRoot.Position).Magnitude
                    local attackDist = Toggles.PullMobs and 8 or 10
                    
                    if dist > attackDist then
                        -- Di chuyển đến quái
                        local moveDir = (targetRoot.Position - root.Position).Unit
                        humanoid:MoveTo(root.Position + moveDir * math.min(dist - attackDist, 20))
                    else
                        -- Đứng lại và tấn công
                        humanoid:MoveTo(humanoid.RootPart.Position)
                        
                        EquipWeapon(AutoFarmWeapon)
                        
                        if Toggles.AutoSkill and AutoFarmSkillCooldown <= 0 then
                            if UseSkill() then
                                AutoFarmSkillCooldown = 2
                            end
                        end
                        
                        if AutoFarmAttackCooldown <= 0 then
                            AutoAttack(target)
                            AutoFarmAttackCooldown = 0.5
                        end
                    end
                else
                    humanoid:MoveTo(humanoid.RootPart.Position)
                end
                
                if AutoFarmAttackCooldown > 0 then
                    AutoFarmAttackCooldown = AutoFarmAttackCooldown - 0.1
                end
                if AutoFarmSkillCooldown > 0 then
                    AutoFarmSkillCooldown = AutoFarmSkillCooldown - 0.1
                end
            end
        end
    end)
end

-- // ============ PULL MOBS ============
local function GetMobsInRange(center, range)
    local mobs = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = v.Name:lower()
            if name:find("npc") or name:find("mob") or name:find("boss") or name:find("enemy") or name:find("marine") or name:find("pirate") or name:find("bandit") then
                local root = v.HumanoidRootPart
                local humanoid = v.Humanoid
                if humanoid and humanoid.Health > 0 then
                    local dist = (center - root.Position).Magnitude
                    if dist <= range then
                        table.insert(mobs, v)
                    end
                end
            end
        end
    end
    return mobs
end

local function PullMobsToPoint(center, range)
    if not center then return 0 end
    
    local mobs = GetMobsInRange(center, range)
    for _, mob in pairs(mobs) do
        local root = mob:FindFirstChild("HumanoidRootPart")
        local humanoid = mob:FindFirstChild("Humanoid")
        if root and humanoid and humanoid.Health > 0 then
            local dist = (center - root.Position).Magnitude
            if dist > 5 then
                local moveDir = (center - root.Position).Unit
                local targetPos = center - moveDir * 3
                local bv = root:FindFirstChild("PullVelocity")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "PullVelocity"
                    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                    bv.Parent = root
                end
                bv.Velocity = (targetPos - root.Position).Unit * 25
                game:GetService("Debris"):AddItem(bv, 0.3)
            end
        end
    end
    return #mobs
end

local function GetNearestMob()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local nearestDist = 100
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = v.Name:lower()
            if name:find("npc") or name:find("mob") or name:find("boss") or name:find("enemy") or name:find("marine") or name:find("pirate") or name:find("bandit") then
                local targetRoot = v.HumanoidRootPart
                local humanoid = v.Humanoid
                if humanoid and humanoid.Health > 0 then
                    local dist = (root.Position - targetRoot.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = v
                    end
                end
            end
        end
    end
    
    return nearest
end

-- // ============ NOCLIP ============
local function NoclipLoop()
    spawn(function()
        while wait(0.05) do
            if Toggles.Noclip then
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end)
end

-- // ============ SUPER JUMP ============
local function SuperJumpLoop()
    spawn(function()
        while wait(0.1) do
            if Toggles.SuperJump then
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.JumpPower = JumpPower
                    end
                end
            else
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid and humanoid.JumpPower == JumpPower then
                        humanoid.JumpPower = 50
                    end
                end
            end
        end
    end)
end

-- // ============ FLY ============
local function FlyLoop()
    spawn(function()
        while wait() do
            if Toggles.Fly and flyEnabled then
                local char = LocalPlayer.Character
                if not char then
                    flyEnabled = false
                    if flyBodyPosition then flyBodyPosition:Destroy() end
                    if flyBodyGyro then flyBodyGyro:Destroy() end
                    flyBodyPosition = nil
                    flyBodyGyro = nil
                    continue
                end
                
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if not rootPart then
                    flyEnabled = false
                    if flyBodyPosition then flyBodyPosition:Destroy() end
                    if flyBodyGyro then flyBodyGyro:Destroy() end
                    flyBodyPosition = nil
                    flyBodyGyro = nil
                    continue
                end

                if not flyBodyPosition then
                    flyBodyPosition = Instance.new("BodyPosition")
                    flyBodyPosition.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                    flyBodyPosition.P = 2000
                    flyBodyPosition.Parent = rootPart
                end
                
                if not flyBodyGyro then
                    flyBodyGyro = Instance.new("BodyGyro")
                    flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                    flyBodyGyro.P = 2000
                    flyBodyGyro.D = 100
                    flyBodyGyro.Parent = rootPart
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
                
                flyBodyPosition.Position = rootPart.Position + moveDirection
                flyBodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Camera.CFrame.LookVector)
            else
                if flyBodyPosition then flyBodyPosition:Destroy(); flyBodyPosition = nil end
                if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
            end
        end
    end)
end

-- // FLY TOGGLE
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F and Toggles.Fly then
        local char = LocalPlayer.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        flyEnabled = not flyEnabled
        if flyEnabled then
            flyBodyPosition = Instance.new("BodyPosition")
            flyBodyPosition.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            flyBodyPosition.P = 2000
            flyBodyPosition.Parent = rootPart
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            flyBodyGyro.P = 2000
            flyBodyGyro.D = 100
            flyBodyGyro.Parent = rootPart
        else
            if flyBodyPosition then flyBodyPosition:Destroy(); flyBodyPosition = nil end
            if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        end
    end
end)

-- // ============ ICON DRAG ============
local function SetupIconDrag()
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            IsDraggingIcon = true
            DragStartPos = input.Position
            IconStartPos = ToggleBtn.Position
        end
    end)

    ToggleBtn.InputChanged:Connect(function(input)
        if IsDraggingIcon and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - DragStartPos
            local newX = math.clamp(IconStartPos.X.Offset + delta.X, 0, 100)
            local newY = math.clamp(IconStartPos.Y.Offset + delta.Y, 0, 100)
            ToggleBtn.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    ToggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dist = (input.Position - DragStartPos).Magnitude
            if dist < DragThreshold then
                MenuOpen = not MenuOpen
                MainFrame.Visible = MenuOpen
                if MenuOpen then 
                    ScanMap()
                    UpdateMobList()
                end
            end
            IsDraggingIcon = false
        end
    end)
end

-- // ============ CREATE TRACER ============
local function CreateTracer(fromPart, toPart, color)
    if not fromPart or not toPart then return nil end
    for _, data in pairs(TracerLines) do
        if data.From == fromPart and data.To == toPart then
            if data.Line then data.Line:Destroy() end
            return nil
        end
    end
    
    local line = Instance.new("Part")
    line.Name = "TracerLine"
    line.Size = Vector3.new(0.1, 0.1, 0.1)
    line.Anchored = true
    line.CanCollide = false
    line.Material = Enum.Material.Neon
    line.BrickColor = BrickColor.new(color or "Bright red")
    line.Transparency = 0.2
    line.Parent = workspace
    
    local att1 = Instance.new("Attachment")
    att1.Parent = fromPart
    local att2 = Instance.new("Attachment")
    att2.Parent = toPart
    
    local constraint = Instance.new("RopeConstraint")
    constraint.Parent = line
    constraint.Attachment0 = att1
    constraint.Attachment1 = att2
    constraint.Length = 0
    constraint.Visible = true
    constraint.Color = color or Color3.fromRGB(255, 0, 0)
    constraint.Thickness = 0.05
    
    return {
        Line = line,
        Constraint = constraint,
        Att1 = att1,
        Att2 = att2,
        From = fromPart,
        To = toPart
    }
end

-- // ============ UPDATE TRACERS ============
local function UpdateTracers()
    spawn(function()
        while wait(TracerUpdateRate) do
            for _, data in pairs(TracerLines) do
                if data.Line then data.Line:Destroy() end
            end
            TracerLines = {}
            
            local char = LocalPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            if Toggles.TracerPlayers then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = player.Character.HumanoidRootPart
                        local tracer = CreateTracer(root, targetRoot, Color3.fromRGB(0, 255, 0))
                        if tracer then table.insert(TracerLines, tracer) end
                    end
                end
            end
            
            if Toggles.TracerMobs then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        local name = v.Name:lower()
                        if name:find("npc") or name:find("mob") or name:find("boss") or name:find("enemy") or name:find("marine") or name:find("pirate") or name:find("bandit") then
                            local targetRoot = v.HumanoidRootPart
                            local tracer = CreateTracer(root, targetRoot, Color3.fromRGB(255, 200, 0))
                            if tracer then table.insert(TracerLines, tracer) end
                        end
                    end
                end
            end
        end
    end)
end

-- // ============ SCAN MAP ============
local function ScanMap()
    DetectedMapPoints = {}
    
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
            local root = model.HumanoidRootPart
            if root and root.Position then
                if not Players:GetPlayerFromCharacter(model) then
                    table.insert(DetectedMapPoints, {
                        Name = model.Name,
                        Position = root.Position
                    })
                end
            end
        end
    end
    
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Size.Magnitude > 50 then
            if not string.find(part.Name, "Terrain") and not string.find(part.Name, "Baseplate") then
                table.insert(DetectedMapPoints, {
                    Name = part.Name,
                    Position = part.Position
                })
            end
        end
    end
    
    if #DetectedMapPoints == 0 then
        table.insert(DetectedMapPoints, {Name = "Center", Position = Vector3.new(0, 10, 0)})
    end
    
    if #DetectedMapPoints > 30 then
        local newList = {}
        for i = 1, 30 do newList[i] = DetectedMapPoints[i] end
        DetectedMapPoints = newList
    end
    
    UpdateTeleportBox()
    return DetectedMapPoints
end

-- // ============ CREATE ESP ============
local function CreateESP(object, color, text, objectType)
    if not object or not object:IsA("BasePart") then return end
    for _, v in pairs(object:GetChildren()) do
        if v:IsA("BillboardGui") and v.Name == "MV_ESP" then
            v:Destroy()
        end
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MV_ESP"
    billboard.Size = UDim2.new(0, 250, 0, 60)
    billboard.AlwaysOnTop = true
    billboard.Parent = object
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "ESP"
    label.TextColor3 = color or Color3.fromRGB(255, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.2
    label.Parent = billboard

    local distLabel = Instance.new("TextLabel")
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
        Type = objectType or "unknown"
    })
end

-- // ============ UPDATE DISTANCE ============
local function UpdateDistances()
    spawn(function()
        while wait(ESPUpdateRate) do
            local char = LocalPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local myPos = root.Position

            for _, data in pairs(ESPObjects) do
                if data.Object and data.Object.Parent then
                    local targetPos = data.Object.Position
                    if targetPos then
                        local dist = (myPos - targetPos).Magnitude
                        local distM = math.floor(dist)
                        local color = distM < 50 and Color3.fromRGB(0, 255, 0) or 
                                      distM < 150 and Color3.fromRGB(255, 255, 0) or 
                                      Color3.fromRGB(255, 100, 0)
                        if data.DistLabel then
                            data.DistLabel.Text = distM .. "m"
                            data.DistLabel.TextColor3 = color
                        end
                    end
                end
            end
        end
    end)
end

-- // ============ ESP LOOP ============
local function ESPLoop()
    spawn(function()
        while wait(0.5) do
            for i = #ESPObjects, 1, -1 do
                local data = ESPObjects[i]
                if data.Object and data.Object.Parent then
                    local shouldKeep = false
                    if data.Type == "player" and Toggles.ESPPlayers then shouldKeep = true
                    elseif data.Type == "mob" and Toggles.ESPMobs then shouldKeep = true
                    elseif data.Type == "fruit" and Toggles.ESPFruits then shouldKeep = true
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

            if Toggles.ESPMobs then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        local name = v.Name:lower()
                        if name:find("npc") or name:find("mob") or name:find("boss") or name:find("enemy") or name:find("marine") or name:find("pirate") or name:find("bandit") then
                            local root = v.HumanoidRootPart
                            local hasESP = false
                            for _, data in pairs(ESPObjects) do
                                if data.Object == root then hasESP = true; break end
                            end
                            if not hasESP then
                                CreateESP(root, Color3.fromRGB(255, 200, 0), "👾 " .. v.Name, "mob")
                            end
                        end
                    end
                end
            end

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
        end
    end)
end

-- // ============ UPDATE TELEPORT BOX ============
local function UpdateTeleportBox()
    local teleportBox = CategoryBoxes["🚀 Teleport"]
    if not teleportBox then return end
    
    for _, child in pairs(teleportBox:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("ScrollingFrame") then
            child:Destroy()
        end
    end
    
    local label = Instance.new("TextLabel")
    label.Parent = teleportBox
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = "📍 " .. SelectedMapName
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    
    local mapScroll = Instance.new("ScrollingFrame")
    mapScroll.Parent = teleportBox
    mapScroll.Size = UDim2.new(1, 0, 1, -30)
    mapScroll.Position = UDim2.new(0, 0, 0, 28)
    mapScroll.BackgroundTransparency = 1
    mapScroll.BorderSizePixel = 0
    mapScroll.CanvasSize = UDim2.new(0, #DetectedMapPoints * 120, 0, 0)
    mapScroll.ScrollBarThickness = 4
    mapScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    
    local mapList = Instance.new("UIListLayout")
    mapList.Parent = mapScroll
    mapList.FillDirection = Enum.FillDirection.Horizontal
    mapList.Padding = UDim.new(0, 6)
    
    for i, mapData in ipairs(DetectedMapPoints) do
        local btn = Instance.new("TextButton")
        btn.Parent = mapScroll
        btn.Size = UDim2.new(0, 110, 1, -4)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        btn.Text = mapData.Name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.Parent = btn
        corner.CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            SelectedMapPoint = mapData.Position
            SelectedMapName = mapData.Name
            label.Text = "📍 " .. mapData.Name
            for _, child in pairs(mapScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        end)
    end
    
    local teleBtn = Instance.new("TextButton")
    teleBtn.Parent = teleportBox
    teleBtn.Size = UDim2.new(1, 0, 0, 35)
    teleBtn.Position = UDim2.new(0, 0, 1, -35)
    teleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 200)
    teleBtn.Text = "🚀 DỊCH CHUYỂN"
    teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleBtn.TextScaled = true
    teleBtn.Font = Enum.Font.GothamBold
    teleBtn.BorderSizePixel = 0
    
    teleBtn.MouseButton1Click:Connect(function()
        if SelectedMapPoint then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(SelectedMapPoint + Vector3.new(0, 5, 0))
            end
        end
    end)
end

-- // ============ CREATE TOGGLE BUTTON ============
local function CreateToggleButton(parent, label, key)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -6, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 4)
    
    local labelBtn = Instance.new("TextButton")
    labelBtn.Parent = frame
    labelBtn.Size = UDim2.new(0.6, 0, 1, 0)
    labelBtn.BackgroundTransparency = 1
    labelBtn.Text = label
    labelBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    labelBtn.TextScaled = true
    labelBtn.TextXAlignment = Enum.TextXAlignment.Left
    labelBtn.Font = Enum.Font.Gotham
    labelBtn.BorderSizePixel = 0
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = frame
    toggleBtn.Size = UDim2.new(0.32, 0, 1, -4)
    toggleBtn.Position = UDim2.new(0.68, 0, 0, 2)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = toggleBtn
    btnCorner.CornerRadius = UDim.new(0, 4)
    
    local function ToggleFunc()
        Toggles[key] = not Toggles[key]
        if Toggles[key] then
            toggleBtn.Text = "ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        else
            toggleBtn.Text = "OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end
    
    toggleBtn.MouseButton1Click:Connect(ToggleFunc)
    labelBtn.MouseButton1Click:Connect(ToggleFunc)
    
    return frame
end

-- // ============ CREATE DROPDOWN ============
local function CreateDropdown(parent, label, options, defaultOption, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -6, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 4)
    
    local labelBtn = Instance.new("TextLabel")
    labelBtn.Parent = frame
    labelBtn.Size = UDim2.new(0.4, 0, 1, 0)
    labelBtn.BackgroundTransparency = 1
    labelBtn.Text = label
    labelBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    labelBtn.TextScaled = true
    labelBtn.TextXAlignment = Enum.TextXAlignment.Left
    labelBtn.Font = Enum.Font.Gotham
    labelBtn.BorderSizePixel = 0
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Parent = frame
    dropdownBtn.Size = UDim2.new(0.5, 0, 1, -4)
    dropdownBtn.Position = UDim2.new(0.45, 0, 0, 2)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    dropdownBtn.Text = defaultOption or options[1]
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.TextScaled = true
    dropdownBtn.Font = Enum.Font.GothamBold
    dropdownBtn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = dropdownBtn
    btnCorner.CornerRadius = UDim.new(0, 4)
    
    local isOpen = false
    local optionFrame = Instance.new("Frame")
    optionFrame.Parent = frame
    optionFrame.Size = UDim2.new(0.5, 0, 0, #options * 30)
    optionFrame.Position = UDim2.new(0.45, 0, 1, 2)
    optionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    optionFrame.BackgroundTransparency = 0.1
    optionFrame.BorderSizePixel = 0
    optionFrame.Visible = false
    optionFrame.ZIndex = 10
    
    local optCorner = Instance.new("UICorner")
    optCorner.Parent = optionFrame
    optCorner.CornerRadius = UDim.new(0, 4)
    
    local yOff = 0
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Parent = optionFrame
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.Position = UDim2.new(0, 0, 0, yOff)
        optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
        optBtn.Text = opt
        optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        optBtn.TextScaled = true
        optBtn.Font = Enum.Font.Gotham
        optBtn.BorderSizePixel = 0
        optBtn.ZIndex = 10
        
        optBtn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = opt
            optionFrame.Visible = false
            isOpen = false
            if callback then callback(opt) end
        end)
        yOff = yOff + 30
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionFrame.Visible = isOpen
        frame.Size = UDim2.new(1, -6, 0, isOpen and 34 + #options * 30 or 34)
    end)
    
    return frame
end

-- // ============ BUILD CATEGORIES ============
local function BuildCategories()
    for _, catName in ipairs(CategoryNames) do
        local box = Instance.new("Frame")
        box.Parent = CategoryScroll
        box.Size = UDim2.new(0, 300, 1, -10)
        box.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
        box.BackgroundTransparency = 0.2
        box.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.Parent = box
        corner.CornerRadius = UDim.new(0, 8)
        
        local title = Instance.new("TextLabel")
        title.Parent = box
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
        title.Text = catName
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextScaled = true
        title.Font = Enum.Font.GothamBold
        title.BorderSizePixel = 0
        
        local titleCorner = Instance.new("UICorner")
        titleCorner.Parent = title
        titleCorner.CornerRadius = UDim.new(0, 8)
        
        local content = Instance.new("ScrollingFrame")
        content.Parent = box
        content.Size = UDim2.new(1, -6, 1, -38)
        content.Position = UDim2.new(0, 3, 0, 34)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.ScrollBarThickness = 3
        
        local contentList = Instance.new("UIListLayout")
        contentList.Parent = content
        contentList.Padding = UDim.new(0, 4)
        
        CategoryBoxes[catName] = content
    end
    
    -- // === COMBAT BOX ===
    local combat = CategoryBoxes["⚔️ Combat"]
    
    CreateToggleButton(combat, "🤖 Auto Farm", "AutoFarm")
    CreateToggleButton(combat, "📦 Gom Quái", "PullMobs")
    
    CreateDropdown(combat, "⚔️ Vũ Khí", AutoFarmWeapons, "Melee", function(selected)
        AutoFarmWeapon = selected
        print("🔫 Đã chọn vũ khí: " .. selected)
    end)
    
    CreateToggleButton(combat, "🌀 Auto Chiêu", "AutoSkill")
    CreateToggleButton(combat, "👤 ESP Players", "ESPPlayers")
    CreateToggleButton(combat, "👾 ESP Mobs", "ESPMobs")
    CreateToggleButton(combat, "🍎 ESP Fruits", "ESPFruits")
    
    -- Danh sách quái sẽ được tạo sau khi scan
    UpdateMobList()
    
    -- // === MOVEMENT BOX ===
    local movement = CategoryBoxes["🦘 Movement"]
    CreateToggleButton(movement, "🦘 Super Jump", "SuperJump")
    CreateToggleButton(movement, "✈️ Fly (F)", "Fly")
    CreateToggleButton(movement, "👻 Noclip", "Noclip")
    
    local speedFrame = Instance.new("Frame")
    speedFrame.Parent = movement
    speedFrame.Size = UDim2.new(1, 0, 0, 40)
    speedFrame.BackgroundTransparency = 1
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Parent = speedFrame
    speedLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Fly Speed: " .. FlySpeed
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    speedLabel.TextScaled = true
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local speedUp = Instance.new("TextButton")
    speedUp.Parent = speedFrame
    speedUp.Size = UDim2.new(0.15, 0, 0.5, 0)
    speedUp.Position = UDim2.new(0.7, 0, 0.5, 0)
    speedUp.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    speedUp.Text = "+"
    speedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedUp.TextScaled = true
    speedUp.BorderSizePixel = 0
    speedUp.MouseButton1Click:Connect(function()
        FlySpeed = FlySpeed + 5
        speedLabel.Text = "Fly Speed: " .. FlySpeed
    end)
    
    local speedDown = Instance.new("TextButton")
    speedDown.Parent = speedFrame
    speedDown.Size = UDim2.new(0.15, 0, 0.5, 0)
    speedDown.Position = UDim2.new(0.85, 0, 0.5, 0)
    speedDown.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    speedDown.Text = "-"
    speedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedDown.TextScaled = true
    speedDown.BorderSizePixel = 0
    speedDown.MouseButton1Click:Connect(function()
        FlySpeed = math.max(10, FlySpeed - 5)
        speedLabel.Text = "Fly Speed: " .. FlySpeed
    end)
    
    local jumpFrame = Instance.new("Frame")
    jumpFrame.Parent = movement
    jumpFrame.Size = UDim2.new(1, 0, 0, 40)
    jumpFrame.BackgroundTransparency = 1
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Parent = jumpFrame
    jumpLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Jump Power: " .. JumpPower
    jumpLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    jumpLabel.TextScaled = true
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local jumpUp = Instance.new("TextButton")
    jumpUp.Parent = jumpFrame
    jumpUp.Size = UDim2.new(0.15, 0, 0.5, 0)
    jumpUp.Position = UDim2.new(0.7, 0, 0.5, 0)
    jumpUp.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    jumpUp.Text = "+"
    jumpUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpUp.TextScaled = true
    jumpUp.BorderSizePixel = 0
    jumpUp.MouseButton1Click:Connect(function()
        JumpPower = JumpPower + 50
        jumpLabel.Text = "Jump Power: " .. JumpPower
    end)
    
    local jumpDown = Instance.new("TextButton")
    jumpDown.Parent = jumpFrame
    jumpDown.Size = UDim2.new(0.15, 0, 0.5, 0)
    jumpDown.Position = UDim2.new(0.85, 0, 0.5, 0)
    jumpDown.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    jumpDown.Text = "-"
    jumpDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpDown.TextScaled = true
    jumpDown.BorderSizePixel = 0
    jumpDown.MouseButton1Click:Connect(function()
        JumpPower = math.max(50, JumpPower - 50)
        jumpLabel.Text = "Jump Power: " .. JumpPower
    end)
    
    -- // === VISUAL BOX ===
    local visual = CategoryBoxes["👁️ Visual"]
    CreateToggleButton(visual, "🔧 Fix Lag", "FixLag")
    CreateToggleButton(visual, "👻 Ghost (F1)", "Ghost")
    CreateToggleButton(visual, "🌙 Night Vision (F2)", "NightVision")
    
    -- // === TRACER BOX ===
    local tracer = CategoryBoxes["📡 Tracer"]
    CreateToggleButton(tracer, "🔴 Tracer Players", "TracerPlayers")
    CreateToggleButton(tracer, "🟡 Tracer Mobs", "TracerMobs")
    
    -- // === TELEPORT BOX ===
    UpdateTeleportBox()
end

-- // ============ FIX LAG ============
local function FixLag()
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

-- // ============ GHOST ============
local function GhostMode()
    spawn(function()
        while wait(0.1) do
            if Toggles.Ghost then
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = GhostStealth
                            if GhostStealth <= 0.1 then part.CanCollide = false end
                        end
                    end
                    local head = char:FindFirstChild("Head")
                    if head then
                        for _, child in pairs(head:GetChildren()) do
                            if child:IsA("BillboardGui") then child.Enabled = false end
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
                    local head = char:FindFirstChild("Head")
                    if head then
                        for _, child in pairs(head:GetChildren()) do
                            if child:IsA("BillboardGui") then child.Enabled = true end
                        end
                    end
                end
            end
        end
    end)
end

-- // ============ NIGHT VISION ============
local function NightVision()
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

-- // ============ ANTI-IDLE ============
local function AntiIdle()
    spawn(function()
        while wait(60) do
            LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            end)
        end
    end)
end

-- // ============ HOTKEYS ============
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        MenuOpen = not MenuOpen
        MainFrame.Visible = MenuOpen
        if MenuOpen then 
            ScanMap()
            UpdateMobList()
        end
    end
    if input.KeyCode == Enum.KeyCode.F1 then
        Toggles.Ghost = not Toggles.Ghost
    end
    if input.KeyCode == Enum.KeyCode.F2 then
        Toggles.NightVision = not Toggles.NightVision
    end
end)

-- // ============ CREATE UI ============
local function CreateUI()
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.Name = "MVHack"
    ScreenGui.ResetOnSpawn = false

    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 600, 0, 330)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -165)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true

    local blur = Instance.new("BlurEffect")
    blur.Parent = MainFrame
    blur.Size = 10

    Title.Parent = MainFrame
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    Title.Text = "⚡ MV HACK v6.3 - Auto Farm Select"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.BorderSizePixel = 0

    CloseBtn.Parent = MainFrame
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 3)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextScaled = true
    CloseBtn.BorderSizePixel = 0
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.MouseButton1Click:Connect(function()
        MenuOpen = false
        MainFrame.Visible = false
    end)

    ResizeHandle.Parent = MainFrame
    ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
    ResizeHandle.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    ResizeHandle.BackgroundTransparency = 0.5
    ResizeHandle.ZIndex = 10

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
            local newHeight = math.clamp(ResizeStartSize.Y.Offset + delta.Y, 250, 450)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            IsResizing = false
        end
    end)

    -- ICON MV
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
    ToggleBtn.Position = UDim2.new(0, 15, 0.5, -30)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    ToggleBtn.Text = "ShinnDev"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextScaled = true
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.BackgroundTransparency = 0.2

    local glow = Instance.new("UICorner")
    glow.Parent = ToggleBtn
    glow.CornerRadius = UDim.new(1, 0)

    SetupIconDrag()

    -- CATEGORY SCROLL
    CategoryScroll.Parent = MainFrame
    CategoryScroll.Size = UDim2.new(1, -10, 1, -45)
    CategoryScroll.Position = UDim2.new(0, 5, 0, 40)
    CategoryScroll.BackgroundTransparency = 1
    CategoryScroll.BorderSizePixel = 0
    CategoryScroll.CanvasSize = UDim2.new(0, #CategoryNames * 320, 0, 0)
    CategoryScroll.ScrollBarThickness = 6
    CategoryScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)

    CategoryList.Parent = CategoryScroll
    CategoryList.FillDirection = Enum.FillDirection.Horizontal
    CategoryList.Padding = UDim.new(0, 8)

    BuildCategories()
    ScanMap()
    UpdateMobList()
end

-- // ============ KHỞI TẠO ============
CreateUI()
FixLag()
SuperJumpLoop()
FlyLoop()
NoclipLoop()
AutoFarmLoop()
ESPLoop()
UpdateDistances()
UpdateTracers()
GhostMode()
NightVision()
AntiIdle()

print("⚡ MV HACK v6.3 LOADED - Auto Farm Select + Full Mob List + Level Display - Boss man, fuck yeah!")