-- ============================================================
-- MV HACK v4.0 - ULTIMATE EDITION
-- FULL COMPLETE CODE - WATERMARK + AIMBOT + ALL FUNCTIONS
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = game:GetService("Workspace").CurrentCamera
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- ============================================================
-- WATERMARK SYSTEM - RAINBOW COLOR
-- ============================================================
local WatermarkFrame = nil
local WatermarkText = nil
local WatermarkTime = nil

local function CreateWatermark()
    -- Main Watermark Frame
    WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Size = UDim2.new(0, 350, 0, 60)
    WatermarkFrame.Position = UDim2.new(0, 10, 0, 10)
    WatermarkFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    WatermarkFrame.BackgroundTransparency = 0.3
    WatermarkFrame.BorderSizePixel = 2
    WatermarkFrame.BorderColor3 = Color3.new(0.3, 0.8, 0.3)
    WatermarkFrame.ClipsDescendants = true
    WatermarkFrame.Parent = LocalPlayer.PlayerGui
    
    -- Title Text
    WatermarkText = Instance.new("TextLabel")
    WatermarkText.Size = UDim2.new(1, 0, 0, 30)
    WatermarkText.Position = UDim2.new(0, 0, 0, 0)
    WatermarkText.BackgroundTransparency = 1
    WatermarkText.Text = "⚡ Shinn Dev Bot X Hack Game ⚡"
    WatermarkText.TextScaled = true
    WatermarkText.Font = Enum.Font.GothamBold
    WatermarkText.Parent = WatermarkFrame
    
    -- Time/Date Text
    WatermarkTime = Instance.new("TextLabel")
    WatermarkTime.Size = UDim2.new(1, 0, 0, 25)
    WatermarkTime.Position = UDim2.new(0, 0, 0, 32)
    WatermarkTime.BackgroundTransparency = 1
    WatermarkTime.Text = ""
    WatermarkTime.TextScaled = true
    WatermarkTime.Font = Enum.Font.GothamMedium
    WatermarkTime.Parent = WatermarkFrame
    
    -- Rainbow Color Update Loop
    spawn(function()
        local hue = 0
        while true do
            wait(0.05)
            hue = (hue + 0.01) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            WatermarkText.TextColor3 = color
            WatermarkTime.TextColor3 = color
            WatermarkFrame.BorderColor3 = color
            
            -- Update Time
            local currentTime = os.date("*t")
            WatermarkTime.Text = string.format("📅 %02d/%02d/%04d  ⏰ %02d:%02d:%02d",
                currentTime.day, currentTime.month, currentTime.year,
                currentTime.hour, currentTime.min, currentTime.sec)
        end
    end)
end

-- ============================================================
-- AIMBOT SYSTEM - WITH FOV CIRCLE
-- ============================================================
local AimConfig = {
    Enabled = false,
    FOV = 200,
    FOVColor = Color3.new(1, 0, 0),
    FOVVisible = true,
    AimSmoothness = 0.3,
    AimTarget = nil,
    AimLock = false,
    TargetPlayers = true,
    TargetMonsters = true,
    TargetBots = true
}

local FOVCircle = nil
local AimConnection = nil

-- Create FOV Circle
local function CreateFOVCircle()
    if FOVCircle then FOVCircle:Destroy() end
    
    FOVCircle = Instance.new("Frame")
    FOVCircle.Size = UDim2.new(0, AimConfig.FOV * 2, 0, AimConfig.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -AimConfig.FOV, 0.5, -AimConfig.FOV)
    FOVCircle.BackgroundTransparency = 1
    FOVCircle.BorderSizePixel = 2
    FOVCircle.BorderColor3 = AimConfig.FOVColor
    FOVCircle.ClipsDescendants = false
    FOVCircle.ZIndex = 999
    FOVCircle.Parent = LocalPlayer.PlayerGui
    
    -- Inner circle glow
    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, -10, 1, -10)
    Glow.Position = UDim2.new(0, 5, 0, 5)
    Glow.BackgroundColor3 = AimConfig.FOVColor
    Glow.BackgroundTransparency = 0.85
    Glow.BorderSizePixel = 1
    Glow.BorderColor3 = AimConfig.FOVColor
    Glow.Parent = FOVCircle
    
    -- Crosshair
    local CrosshairH = Instance.new("Frame")
    CrosshairH.Size = UDim2.new(0, 20, 0, 2)
    CrosshairH.Position = UDim2.new(0.5, -10, 0.5, -1)
    CrosshairH.BackgroundColor3 = AimConfig.FOVColor
    CrosshairH.BackgroundTransparency = 0.5
    CrosshairH.Parent = FOVCircle
    
    local CrosshairV = Instance.new("Frame")
    CrosshairV.Size = UDim2.new(0, 2, 0, 20)
    CrosshairV.Position = UDim2.new(0.5, -1, 0.5, -10)
    CrosshairV.BackgroundColor3 = AimConfig.FOVColor
    CrosshairV.BackgroundTransparency = 0.5
    CrosshairV.Parent = FOVCircle
    
    FOVCircle.Visible = AimConfig.FOVVisible
    return FOVCircle
end

-- Get all valid targets in FOV
local function GetTargetsInFOV()
    local targets = {}
    local cameraPos = Camera.CFrame.Position
    local cameraLook = Camera.CFrame.LookVector
    
    -- Get players
    if AimConfig.TargetPlayers then
        for _, player in pairs(GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                local humanoid = GetHumanoid(player.Character)
                if humanoid and humanoid.Health > 0 then
                    local targetPos = root.Position
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distFromCenter < AimConfig.FOV then
                            table.insert(targets, {
                                Object = player,
                                Type = "Player",
                                Position = targetPos,
                                Distance = distFromCenter,
                                ScreenPos = Vector2.new(screenPos.X, screenPos.Y),
                                Root = root,
                                Humanoid = humanoid
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Get monsters
    if AimConfig.TargetMonsters then
        for _, monster in pairs(GetMonsters()) do
            if monster:FindFirstChild("HumanoidRootPart") then
                local root = monster.HumanoidRootPart
                local humanoid = GetHumanoid(monster)
                if humanoid and humanoid.Health > 0 then
                    local targetPos = root.Position
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distFromCenter < AimConfig.FOV then
                            table.insert(targets, {
                                Object = monster,
                                Type = "Monster",
                                Position = targetPos,
                                Distance = distFromCenter,
                                ScreenPos = Vector2.new(screenPos.X, screenPos.Y),
                                Root = root,
                                Humanoid = humanoid
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Sort by distance from center (closest to crosshair first)
    table.sort(targets, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return targets
end

-- Aimbot main function
local function ToggleAimbot()
    AimConfig.Enabled = not AimConfig.Enabled
    
    if AimConfig.Enabled then
        if AimConnection then AimConnection:Disconnect() end
        
        -- Create FOV circle
        CreateFOVCircle()
        
        AimConnection = RunService.RenderStepped:Connect(function()
            if not AimConfig.Enabled then return end
            
            local targets = GetTargetsInFOV()
            if #targets > 0 then
                local target = targets[1]
                AimConfig.AimTarget = target
                
                -- Calculate aim direction
                local root = GetLocalRootPart()
                if root then
                    local targetPos = target.Position
                    local lookVector = (targetPos - root.Position).Unit
                    
                    -- Smooth aiming
                    if AimConfig.AimSmoothness > 0 then
                        local currentLook = Camera.CFrame.LookVector
                        local newLook = currentLook:Lerp(lookVector, AimConfig.AimSmoothness)
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    end
                end
            else
                AimConfig.AimTarget = nil
            end
        end)
        print("[MV] Aimbot ON - FOV: " .. AimConfig.FOV)
    else
        if AimConnection then
            AimConnection:Disconnect()
            AimConnection = nil
        end
        if FOVCircle then
            FOVCircle:Destroy()
            FOVCircle = nil
        end
        AimConfig.AimTarget = nil
        print("[MV] Aimbot OFF")
    end
end

-- Toggle FOV visibility
local function ToggleFOV()
    AimConfig.FOVVisible = not AimConfig.FOVVisible
    if FOVCircle then
        FOVCircle.Visible = AimConfig.FOVVisible
    end
    print("[MV] FOV Circle " .. (AimConfig.FOVVisible and "Visible" or "Hidden"))
end

-- Change FOV size
local function SetFOVSize(size)
    AimConfig.FOV = math.max(50, math.min(500, size))
    if FOVCircle then
        FOVCircle:Destroy()
        FOVCircle = nil
        CreateFOVCircle()
    end
    print("[MV] FOV Size: " .. AimConfig.FOV)
end

-- Change FOV Color
local function SetFOVColor(color)
    AimConfig.FOVColor = color
    if FOVCircle then
        FOVCircle.BorderColor3 = color
        for _, child in pairs(FOVCircle:GetChildren()) do
            if child:IsA("Frame") then
                child.BorderColor3 = color
                child.BackgroundColor3 = color
            end
        end
    end
end

-- ============================================================
-- LANGUAGE SYSTEM
-- ============================================================
local Languages = {
    English = {
        Name = "English",
        Code = "EN",
        Menu = {
            Title = "⚡ MV HACK v4.0 ULTIMATE ⚡",
            AntiLag = "🔧 Anti-Lag",
            SuperJump = "⬆️ Super Jump",
            InfiniteJump = "🔄 Infinite Jump",
            FlyMode = "✈️ Fly Mode",
            Noclip = "🚪 Noclip",
            SpeedHack = "💨 Speed Hack",
            PlayerESP = "👤 Player ESP",
            MonsterESP = "👾 Monster ESP",
            FruitESP = "🍎 Fruit ESP",
            Wallhack = "🧱 Wallhack",
            GhostMode = "👻 Ghost Mode",
            DarkVision = "🌙 Dark Vision",
            AutoFarm = "🤖 Auto-Farm",
            AutoCollect = "📦 Auto-Collect",
            AutoHeal = "💚 Auto-Heal",
            LoadMonsters = "📋 Load Monsters",
            KillAll = "🔥 Kill All",
            FreezeAll = "🧊 Freeze All",
            GrabAll = "📦 Grab All",
            TeleportAll = "📌 Teleport All",
            TeleportTarget = "📍 Teleport to Target",
            SelectTarget = "🎯 Select Target",
            SelectWeapon = "⚔️ Select Weapon",
            AutoRebirth = "🔄 Auto-Rebirth",
            AntiAFK = "💤 Anti-AFK",
            ChatSpam = "💬 Chat Spam",
            ServerCrasher = "💀 Server Crasher",
            AutoJoin = "🚪 Auto-Join",
            CharSizeUp = "📏 Size +",
            CharSizeDown = "📏 Size -",
            FastSwim = "🏊 Fast Swim",
            NoFallDamage = "🪂 No Fall Damage",
            NoCooldown = "⏱️ No Cooldown",
            AutoClick = "🖱️ Auto Click",
            AntiStun = "⚡ Anti-Stun",
            AutoDodge = "🔄 Auto-Dodge",
            InfiniteYield = "♾️ Infinite Yield",
            JumpUp = "⬆️ Jump +10",
            JumpDown = "⬇️ Jump -10",
            FlyUp = "⬆️ Fly +10",
            FlyDown = "⬇️ Fly -10",
            SpeedUp = "⬆️ Speed +1",
            SpeedDown = "⬇️ Speed -1",
            Language = "🌐 Language",
            Aimbot = "🎯 Aimbot",
            FOVToggle = "👁️ FOV Circle",
            FOVUp = "🔺 FOV +10",
            FOVDown = "🔻 FOV -10",
            FOVRed = "🔴 Red",
            FOVGreen = "🟢 Green",
            FOVBlue = "🔵 Blue"
        }
    },
    Vietnamese = {
        Name = "Tiếng Việt",
        Code = "VI",
        Menu = {
            Title = "⚡ MV HACK v4.0 ULTIMATE ⚡",
            AntiLag = "🔧 Chống Lag",
            SuperJump = "⬆️ Nhảy Cao",
            InfiniteJump = "🔄 Nhảy Vô Hạn",
            FlyMode = "✈️ Bay",
            Noclip = "🚪 Xuyên Tường",
            SpeedHack = "💨 Tăng Tốc",
            PlayerESP = "👤 ESP Người Chơi",
            MonsterESP = "👾 ESP Quái",
            FruitESP = "🍎 ESP Trái Cây",
            Wallhack = "🧱 Xuyên Tường",
            GhostMode = "👻 Ma",
            DarkVision = "🌙 Nhìn Trong Bóng Tối",
            AutoFarm = "🤖 Tự Động Farm",
            AutoCollect = "📦 Tự Động Nhặt",
            AutoHeal = "💚 Tự Động Hồi Máu",
            LoadMonsters = "📋 Tải Quái",
            KillAll = "🔥 Giết Tất Cả",
            FreezeAll = "🧊 Đóng Băng",
            GrabAll = "📦 Kéo Tất Cả",
            TeleportAll = "📌 Dịch Chuyển Tất Cả",
            TeleportTarget = "📍 Dịch Chuyển",
            SelectTarget = "🎯 Chọn Mục Tiêu",
            SelectWeapon = "⚔️ Chọn Vũ Khí",
            AutoRebirth = "🔄 Tự Động Rebirth",
            AntiAFK = "💤 Chống AFK",
            ChatSpam = "💬 Spam Chat",
            ServerCrasher = "💀 Phá Server",
            AutoJoin = "🚪 Tự Động Vào",
            CharSizeUp = "📏 Tăng Size",
            CharSizeDown = "📏 Giảm Size",
            FastSwim = "🏊 Bơi Nhanh",
            NoFallDamage = "🪂 Không Rơi Máu",
            NoCooldown = "⏱️ Không Hồi Chiêu",
            AutoClick = "🖱️ Tự Động Click",
            AntiStun = "⚡ Chống Choáng",
            AutoDodge = "🔄 Tự Động Né",
            InfiniteYield = "♾️ Bất Tử",
            JumpUp = "⬆️ Nhảy +10",
            JumpDown = "⬇️ Nhảy -10",
            FlyUp = "⬆️ Bay +10",
            FlyDown = "⬇️ Bay -10",
            SpeedUp = "⬆️ Tốc Độ +1",
            SpeedDown = "⬇️ Tốc Độ -1",
            Language = "🌐 Ngôn Ngữ",
            Aimbot = "🎯 Tự Động Aim",
            FOVToggle = "👁️ Vòng FOV",
            FOVUp = "🔺 FOV +10",
            FOVDown = "🔻 FOV -10",
            FOVRed = "🔴 Màu Đỏ",
            FOVGreen = "🟢 Màu Xanh",
            FOVBlue = "🔵 Màu Xanh Dương"
        }
    },
    Korean = {
        Name = "한국어",
        Code = "KO",
        Menu = {
            Title = "⚡ MV HACK v4.0 ULTIMATE ⚡",
            AntiLag = "🔧 안티 랙",
            SuperJump = "⬆️ 슈퍼 점프",
            InfiniteJump = "🔄 무한 점프",
            FlyMode = "✈️ 비행 모드",
            Noclip = "🚪 노클립",
            SpeedHack = "💨 스피드 핵",
            PlayerESP = "👤 플레이어 ESP",
            MonsterESP = "👾 몬스터 ESP",
            FruitESP = "🍎 과일 ESP",
            Wallhack = "🧱 월핵",
            GhostMode = "👻 고스트 모드",
            DarkVision = "🌙 다크 비전",
            AutoFarm = "🤖 자동 파밍",
            AutoCollect = "📦 자동 수집",
            AutoHeal = "💚 자동 힐",
            LoadMonsters = "📋 몬스터 로드",
            KillAll = "🔥 모두 처치",
            FreezeAll = "🧊 모두 얼리기",
            GrabAll = "📦 모두 끌기",
            TeleportAll = "📌 모두 텔레포트",
            TeleportTarget = "📍 텔레포트",
            SelectTarget = "🎯 대상 선택",
            SelectWeapon = "⚔️ 무기 선택",
            AutoRebirth = "🔄 자동 리버스",
            AntiAFK = "💤 안티 AFK",
            ChatSpam = "💬 채팅 스팸",
            ServerCrasher = "💀 서버 크래셔",
            AutoJoin = "🚪 자동 입장",
            CharSizeUp = "📏 사이즈 +",
            CharSizeDown = "📏 사이즈 -",
            FastSwim = "🏊 빠른 수영",
            NoFallDamage = "🪂 낙하 데미지 없음",
            NoCooldown = "⏱️ 쿨다운 없음",
            AutoClick = "🖱️ 자동 클릭",
            AntiStun = "⚡ 스턴 방지",
            AutoDodge = "🔄 자동 회피",
            InfiniteYield = "♾️ 무적",
            JumpUp = "⬆️ 점프 +10",
            JumpDown = "⬇️ 점프 -10",
            FlyUp = "⬆️ 비행 +10",
            FlyDown = "⬇️ 비행 -10",
            SpeedUp = "⬆️ 속도 +1",
            SpeedDown = "⬇️ 속도 -1",
            Language = "🌐 언어",
            Aimbot = "🎯 에임봇",
            FOVToggle = "👁️ FOV 원",
            FOVUp = "🔺 FOV +10",
            FOVDown = "🔻 FOV -10",
            FOVRed = "🔴 빨간색",
            FOVGreen = "🟢 초록색",
            FOVBlue = "🔵 파란색"
        }
    }
}

local CurrentLanguage = Languages.English
local function SetLanguage(lang)
    CurrentLanguage = lang
    print("[MV] Language set to: " .. lang.Name)
    if MainFrame then
        MainFrame:Destroy()
    end
    CreateGUI()
end

local L = function(key)
    return CurrentLanguage.Menu[key] or key
end

-- ============================================================
-- CONFIGURATION TABLE - ALL SETTINGS
-- ============================================================
local Config = {
    AntiLag = false,
    SuperJump = false,
    JumpHeight = 50,
    FlyMode = false,
    FlySpeed = 50,
    Noclip = false,
    PlayerESP = false,
    MonsterESP = false,
    FruitESP = false,
    GhostMode = false,
    DarkVision = false,
    AutoFarm = false,
    AutoCollect = false,
    AutoSell = false,
    SelectedMonster = nil,
    SelectedWeapon = nil,
    TeleportTarget = nil,
    SpeedHack = false,
    SpeedMultiplier = 2,
    InfiniteJump = false,
    NoCooldown = false,
    AutoClick = false,
    ClickDelay = 0.1,
    Wallhack = false,
    AntiStun = false,
    AutoDodge = false,
    AutoHeal = false,
    HealThreshold = 30,
    AutoRebirth = false,
    KillAll = false,
    FreezeAll = false,
    GrabAll = false,
    TeleportAll = false,
    ServerCrasher = false,
    AntiAFK = false,
    ChatSpam = false,
    SpamMessage = "MV Hack v4.0 Best!",
    SpamDelay = 5,
    AutoJoin = false,
    AutoJoinGame = nil,
    InfiniteYield = false,
    CharacterSize = 1,
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,
    HighJump = false,
    NoFallDamage = false,
    FastSwim = false,
    SwimSpeed = 50
}

-- ============================================================
-- UTILITY FUNCTIONS - COMPLETE SET
-- ============================================================

local function GetPlayers()
    local list = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, v)
        end
    end
    return list
end

local function GetMonsters()
    local monsters = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and not v:FindFirstChild("HumanoidRootPart") then
            if v.Name:match("Monster") or v.Name:match("Enemy") or v.Name:match("Boss") or v.Name:match("NPC") then
                table.insert(monsters, v)
            end
        end
    end
    return monsters
end

local function GetFruits()
    local fruits = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:match("Fruit") or v.Name:match("Devil") or v.Name:match("Blox")) then
            table.insert(fruits, v)
        end
    end
    return fruits
end

local function GetDrops()
    local drops = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("Tool") then
            if v.Name:match("Drop") or v.Name:match("Item") or v.Name:match("Chest") or v.Name:match("Loot") then
                table.insert(drops, v)
            end
        end
    end
    return drops
end

local function GetPlayersWithESP()
    local list = {}
    for _, player in pairs(GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, player)
        end
    end
    return list
end

local function GetNearestObject(objects, position)
    local nearest = nil
    local shortestDist = math.huge
    for _, obj in pairs(objects) do
        if obj:FindFirstChild("HumanoidRootPart") then
            local dist = (position - obj.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearest = obj
            end
        end
    end
    return nearest
end

local function CreateESP(target, color, text)
    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = target
    billboard.Parent = target
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.TextColor3 = color
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 2, 1, 0)
    line.BackgroundColor3 = color
    line.Position = UDim2.new(0, -1, 0, 0)
    line.Parent = billboard
    
    return billboard
end

local function DeleteAllESP()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") and obj.Parent:IsA("BasePart") then
            obj:Destroy()
        end
    end
end

local function SmoothTeleport(position, duration)
    duration = duration or 1
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    tween.Completed:Wait()
    return true
end

local function IsPlayerInGame(player)
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(character)
    return character and character:FindFirstChild("Humanoid")
end

local function GetRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function GetLocalCharacter()
    return LocalPlayer.Character
end

local function GetLocalHumanoid()
    local char = GetLocalCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function GetLocalRootPart()
    local char = GetLocalCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsLocalAlive()
    local humanoid = GetLocalHumanoid()
    return humanoid and humanoid.Health > 0
end

local function GetPlayerPosition(player)
    local root = GetRootPart(player.Character)
    return root and root.Position or Vector3.new(0, 0, 0)
end

local function GetLocalPosition()
    local root = GetLocalRootPart()
    return root and root.Position or Vector3.new(0, 0, 0)
end

local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function Notify(title, text, duration)
    duration = duration or 3
    local notification = Instance.new("Notification")
    notification.Title = title
    notification.Text = text
    notification.Duration = duration
    notification.Parent = LocalPlayer.PlayerGui
end

local function GetGameObjects()
    return Workspace:GetDescendants()
end

local function GetTools()
    local tools = {}
    for _, v in pairs(GetLocalCharacter():GetChildren()) do
        if v:IsA("Tool") then
            table.insert(tools, v)
        end
    end
    return tools
end

local function GetBackpackTools()
    local tools = {}
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            table.insert(tools, v)
        end
    end
    return tools
end

local function EquipTool(toolName)
    local backpack = LocalPlayer.Backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == toolName then
            GetLocalHumanoid():EquipTool(tool)
            return true
        end
    end
    return false
end

local function GetInventory()
    local inventory = {}
    for _, v in pairs(GetLocalCharacter():GetChildren()) do
        if v:IsA("Tool") then
            table.insert(inventory, v)
        end
    end
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            table.insert(inventory, v)
        end
    end
    return inventory
end

-- ============================================================
-- ALL HACK FUNCTIONS
-- ============================================================

local function ToggleAntiLag()
    Config.AntiLag = not Config.AntiLag
    if Config.AntiLag then
        settings().Rendering.QualityLevel = 1
        settings().Rendering.FrameRateLimit = 30
        RunService:Set3dRenderingEnabled(false)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.Transparency = 0
                if v:IsA("BasePart") then
                    v.BrickColor = BrickColor.new("Medium stone grey")
                end
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Plastic
                    end
                end
            end
        end
        print("[MV] Anti-Lag activated - fuck yeah, boss man!")
    else
        settings().Rendering.QualityLevel = 10
        settings().Rendering.FrameRateLimit = 60
        RunService:Set3dRenderingEnabled(true)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
        print("[MV] Anti-Lag deactivated")
    end
end

local JumpConnection
local function ToggleSuperJump()
    Config.SuperJump = not Config.SuperJump
    if Config.SuperJump then
        if JumpConnection then JumpConnection:Disconnect() end
        JumpConnection = RunService.Heartbeat:Connect(function()
            local char = GetLocalCharacter()
            if char then
                local humanoid = GetHumanoid(char)
                local root = GetRootPart(char)
                if humanoid and root then
                    if humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                        root.Velocity = Vector3.new(root.Velocity.X, Config.JumpHeight, root.Velocity.Z)
                    end
                end
            end
        end)
        print("[MV] Super Jump ON - Height: " .. Config.JumpHeight)
    else
        if JumpConnection then JumpConnection:Disconnect() end
        JumpConnection = nil
        print("[MV] Super Jump OFF")
    end
end

local InfiniteJumpConnection
local function ToggleInfiniteJump()
    Config.InfiniteJump = not Config.InfiniteJump
    if Config.InfiniteJump then
        if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
        InfiniteJumpConnection = RunService.Heartbeat:Connect(function()
            local char = GetLocalCharacter()
            if char then
                local humanoid = GetHumanoid(char)
                if humanoid then
                    humanoid.Jump = true
                end
            end
        end)
        print("[MV] Infinite Jump ON - boss man!")
    else
        if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
        InfiniteJumpConnection = nil
        print("[MV] Infinite Jump OFF")
    end
end

local FlyConnection
local function ToggleFly()
    Config.FlyMode = not Config.FlyMode
    if Config.FlyMode then
        if FlyConnection then FlyConnection:Disconnect() end
        FlyConnection = RunService.Heartbeat:Connect(function()
            local char = GetLocalCharacter()
            if char then
                local root = GetRootPart(char)
                local humanoid = GetHumanoid(char)
                if root and humanoid then
                    humanoid.PlatformStand = true
                    local moveDirection = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
                    
                    if moveDirection.Magnitude > 0 then
                        moveDirection = moveDirection.Unit * Config.FlySpeed
                        root.Velocity = moveDirection
                    else                        root.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    root.CFrame = CFrame.new(root.Position, root.Position + Camera.CFrame.LookVector * 10)
                end
            end
        end)
        print("[MV] Fly Mode ON - Speed: " .. Config.FlySpeed)
    else
        if FlyConnection then FlyConnection:Disconnect() end
        FlyConnection = nil
        local char = GetLocalCharacter()
        if char then
            local humanoid = GetHumanoid(char)
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
        print("[MV] Fly Mode OFF")
    end
end

local NoclipConnection
local function ToggleNoclip()
    Config.Noclip = not Config.Noclip
    if Config.Noclip then
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection = RunService.Stepped:Connect(function()
            local char = GetLocalCharacter()
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
        print("[MV] Noclip activated - walking through walls, boss man!")
    else
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection = nil
        local char = GetLocalCharacter()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
        print("[MV] Noclip deactivated")
    end
end

local SpeedConnection
local function ToggleSpeedHack()
    Config.SpeedHack = not Config.SpeedHack
    if Config.SpeedHack then
        if SpeedConnection then SpeedConnection:Disconnect() end
        SpeedConnection = RunService.Heartbeat:Connect(function()
            local char = GetLocalCharacter()
            if char then
                local humanoid = GetHumanoid(char)
                if humanoid then
                    humanoid.WalkSpeed = Config.WalkSpeed * Config.SpeedMultiplier
                end
            end
        end)
        print("[MV] Speed Hack ON - Multiplier: " .. Config.SpeedMultiplier)
    else
        if SpeedConnection then SpeedConnection:Disconnect() end
        SpeedConnection = nil
        local char = GetLocalCharacter()
        if char then
            local humanoid = GetHumanoid(char)
            if humanoid then
                humanoid.WalkSpeed = Config.WalkSpeed
            end
        end
        print("[MV] Speed Hack OFF")
    end
end

local ESPObjects = {}
local function UpdateESP()
    DeleteAllESP()
    ESPObjects = {}
    
    if Config.PlayerESP then
        for _, player in pairs(GetPlayersWithESP()) do
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                local humanoid = GetHumanoid(player.Character)
                if head and humanoid then
                    local health = math.floor(humanoid.Health)
                    local maxHealth = humanoid.MaxHealth
                    local color = health > 50 and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    local esp = CreateESP(head, color, player.Name .. "\n❤️ " .. health .. "/" .. maxHealth)
                    table.insert(ESPObjects, esp)
                end
            end
        end
    end
    
    if Config.MonsterESP then
        for _, monster in pairs(GetMonsters()) do
            if monster:FindFirstChild("Head") or monster:FindFirstChild("HumanoidRootPart") then
                local target = monster:FindFirstChild("Head") or monster:FindFirstChild("HumanoidRootPart")
                local level = monster:FindFirstChild("Level")
                local humanoid = GetHumanoid(monster)
                local health = humanoid and math.floor(humanoid.Health) or "?"
                local levelText = level and "LV: " .. level.Value or ""
                local esp = CreateESP(target, Color3.new(1, 0, 0), monster.Name .. "\n" .. levelText .. "\n❤️ " .. health)
                table.insert(ESPObjects, esp)
            end
        end
    end
    
    if Config.FruitESP then
        for _, fruit in pairs(GetFruits()) do
            if fruit:FindFirstChild("Handle") then
                local esp = CreateESP(fruit.Handle, Color3.new(1, 0.5, 0), "🍎 " .. fruit.Name)
                table.insert(ESPObjects, esp)
            end
        end
    end
    
    if Config.Wallhack then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency == 1 then
                v.Transparency = 0.3
            end
        end
    end
end

local function TogglePlayerESP()
    Config.PlayerESP = not Config.PlayerESP
    UpdateESP()
    print("[MV] Player ESP " .. (Config.PlayerESP and "ON" or "OFF"))
end

local function ToggleMonsterESP()
    Config.MonsterESP = not Config.MonsterESP
    UpdateESP()
    print("[MV] Monster ESP " .. (Config.MonsterESP and "ON" or "OFF"))
end

local function ToggleFruitESP()
    Config.FruitESP = not Config.FruitESP
    UpdateESP()
    print("[MV] Fruit ESP " .. (Config.FruitESP and "ON" or "OFF"))
end

local function ToggleWallhack()
    Config.Wallhack = not Config.Wallhack
    UpdateESP()
    print("[MV] Wallhack " .. (Config.Wallhack and "ON" or "OFF"))
end

local function ToggleGhost()
    Config.GhostMode = not Config.GhostMode
    local char = GetLocalCharacter()
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = Config.GhostMode and 1 or 0
            end
        end
    end
    print("[MV] Ghost Mode " .. (Config.GhostMode and "ON - you're invisible, boss man!" or "OFF"))
end

local function ToggleDarkVision()
    Config.DarkVision = not Config.DarkVision
    if Config.DarkVision then
        Lighting.Brightness = 10
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.GlobalShadows = false
        print("[MV] Dark Vision ON - see everything!")
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.GlobalShadows = true
        print("[MV] Dark Vision OFF")
    end
end

local FarmConnection
local FarmTarget = nil
local FarmCooldown = 0

local function GetBestMonster()
    local monsters = GetMonsters()
    local best = nil
    local bestScore = -math.huge
    local localPos = GetLocalPosition()
    
    for _, monster in pairs(monsters) do
        if monster:FindFirstChild("HumanoidRootPart") then
            local humanoid = GetHumanoid(monster)
            if humanoid and humanoid.Health > 0 then
                local pos = monster.HumanoidRootPart.Position
                local dist = GetDistance(localPos, pos)
                local level = monster:FindFirstChild("Level")
                local levelValue = level and level.Value or 0
                
                if Config.SelectedMonster and monster.Name ~= Config.SelectedMonster then
                    continue
                end
                
                local score = -dist + levelValue * 10
                if score > bestScore then
                    bestScore = score
                    best = monster
                end
            end
        end
    end
    return best
end

local function StartAutoFarm()
    Config.AutoFarm = not Config.AutoFarm
    if Config.AutoFarm then
        if FarmConnection then FarmConnection:Disconnect() end
        FarmConnection = RunService.Heartbeat:Connect(function()
            local char = GetLocalCharacter()
            local humanoid = GetHumanoid(char)
            local root = GetRootPart(char)
            if not char or not humanoid or not root then return end
            
            FarmCooldown = math.max(0, FarmCooldown - 0.1)
            
            if not FarmTarget or not GetHumanoid(FarmTarget) or GetHumanoid(FarmTarget).Health <= 0 then
                FarmTarget = GetBestMonster()
            end
            
            if FarmTarget and FarmTarget:FindFirstChild("HumanoidRootPart") then
                local targetPos = FarmTarget.HumanoidRootPart.Position
                local dist = GetDistance(root.Position, targetPos)
                
                if dist > 200 then
                    SmoothTeleport(targetPos + Vector3.new(0, 5, 0), 0.5)
                elseif dist > 15 then
                    humanoid:MoveTo(targetPos)
                else
                    humanoid:MoveTo(root.Position)
                    
                    if Config.SelectedWeapon then
                        local tool = char:FindFirstChild(Config.SelectedWeapon) or LocalPlayer.Backpack:FindFirstChild(Config.SelectedWeapon)
                        if tool and tool:IsA("Tool") then
                            humanoid:EquipTool(tool)
                            if FarmCooldown <= 0 then
                                tool:Activate()
                                FarmCooldown = 0.5
                            end
                        end
                    else
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool and FarmCooldown <= 0 then
                            tool:Activate()
                            FarmCooldown = 0.5
                        end
                    end
                end
            end
        end)
        print("[MV] Auto-Farm STARTED - Let's get that XP, boss man!")
    else
        if FarmConnection then FarmConnection:Disconnect() end
        FarmConnection = nil
        FarmTarget = nil
        print("[MV] Auto-Farm STOPPED")
    end
end

local CollectConnection
local function StartAutoCollect()
    Config.AutoCollect = not Config.AutoCollect
    if Config.AutoCollect then
        if CollectConnection then CollectConnection:Disconnect() end
        CollectConnection = RunService.Heartbeat:Connect(function()
            local root = GetLocalRootPart()
            if not root then return end
            
            local drops = GetDrops()
            local nearest = GetNearestObject(drops, root.Position)
            
            if nearest and nearest:FindFirstChild("Handle") then
                local dist = GetDistance(root.Position, nearest.Handle.Position)
                if dist < 50 then
                    SmoothTeleport(nearest.Handle.Position + Vector3.new(0, 2, 0), 0.3)
                end
            end
        end)
        print("[MV] Auto-Collect STARTED")
    else
        if CollectConnection then CollectConnection:Disconnect() end
        CollectConnection = nil
        print("[MV] Auto-Collect STOPPED")
    end
end

local HealConnection
local function ToggleAutoHeal()
    Config.AutoHeal = not Config.AutoHeal
    if Config.AutoHeal then
        if HealConnection then HealConnection:Disconnect() end
        HealConnection = RunService.Heartbeat:Connect(function()
            local humanoid = GetLocalHumanoid()
            if not humanoid then return end
            
            if humanoid.Health < humanoid.MaxHealth * (Config.HealThreshold / 100) then
                local char = GetLocalCharacter()
                if char then
                    local healItem = char:FindFirstChild("HealthPotion") or char:FindFirstChild("Heal")
                    if healItem and healItem:IsA("Tool") then
                        humanoid:EquipTool(healItem)
                        healItem:Activate()
                    end
                end
            end
        end)
        print("[MV] Auto-Heal ON - Threshold: " .. Config.HealThreshold .. "%")
    else
        if HealConnection then HealConnection:Disconnect() end
        HealConnection = nil
        print("[MV] Auto-Heal OFF")
    end
end

local function KillAllMonsters()
    local count = 0
    for _, monster in pairs(GetMonsters()) do
        local humanoid = GetHumanoid(monster)
        if humanoid and humanoid.Health > 0 then
            humanoid.Health = 0
            count = count + 1
        end
    end
    print("[MV] Killed " .. count .. " monsters, boss man!")
end

local FreezeConnection
local function ToggleFreezeAll()
    Config.FreezeAll = not Config.FreezeAll
    if Config.FreezeAll then
        if FreezeConnection then FreezeConnection:Disconnect() end
        FreezeConnection = RunService.Heartbeat:Connect(function()
            for _, monster in pairs(GetMonsters()) do
                local humanoid = GetHumanoid(monster)
                if humanoid then
                    humanoid.PlatformStand = true
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                end
            end
        end)
        print("[MV] Freeze All ON")
    else
        if FreezeConnection then FreezeConnection:Disconnect() end
        FreezeConnection = nil
        for _, monster in pairs(GetMonsters()) do
            local humanoid = GetHumanoid(monster)
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
            end
        end
        print("[MV] Freeze All OFF")
    end
end

local function GrabAllMonsters()
    local root = GetLocalRootPart()
    if not root then return end
    
    local count = 0
    for _, monster in pairs(GetMonsters()) do
        local targetRoot = GetRootPart(monster)
        if targetRoot then
            targetRoot.CFrame = root.CFrame + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
            count = count + 1
        end
    end
    print("[MV] Grabbed " .. count .. " monsters to you, boss man!")
end

local function TeleportAllToMe()
    local root = GetLocalRootPart()
    if not root then return end
    
    local count = 0
    for _, player in pairs(GetPlayers()) do
        local targetRoot = GetRootPart(player.Character)
        if targetRoot then
            targetRoot.CFrame = root.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            count = count + 1
        end
    end
    print("[MV] Teleported " .. count .. " players to you, boss man!")
end

local function TeleportTo(target)
    local root = GetLocalRootPart()
    if not root then return end
    
    if target:IsA("BasePart") or target:IsA("Model") then
        local pos = target:IsA("BasePart") and target.Position or target:FindFirstChild("HumanoidRootPart").Position
        SmoothTeleport(pos + Vector3.new(0, 3, 0), 0.5)
        print("[MV] Teleported to: " .. tostring(target.Name))
    else
        print("[MV] Invalid target, boss man!")
    end
end

local function TeleportToTarget()
    if Config.TeleportTarget then
        TeleportTo(Config.TeleportTarget)
    else
        print("[MV] No target selected - use 'Select Target' first, boss man!")
    end
end

local function SetTeleportTarget()
    print("[MV] Click on any part in the world to teleport there")
    local success, target = pcall(function()
        return Mouse.Target
    end)
    if success and target then
        Config.TeleportTarget = target
        print("[MV] Target set to: " .. tostring(target.Name))
    end
end

local function LoadMonsters()
    local monsters = GetMonsters()
    print("[MV] ========================================")
    print("[MV] LOADING " .. #monsters .. " MONSTERS ON MAP")
    print("[MV] ========================================")
    for i, monster in pairs(monsters) do
        local level = monster:FindFirstChild("Level")
        local humanoid = GetHumanoid(monster)
        local health = humanoid and math.floor(humanoid.Health) or "?"
        print(string.format("[%d] %s - LV: %s - HP: %s", i, monster.Name, 
            level and level.Value or "N/A", health))
    end
    print("[MV] ========================================")
    return monsters
end

local function SelectWeapon()
    print("[MV] ========================================")
    print("[MV] AVAILABLE WEAPONS:")
    print("[MV] ========================================")
    local tools = GetBackpackTools()
    for i, tool in pairs(tools) do
        print(string.format("[%d] %s", i, tool.Name))
    end
    print("[MV] ========================================")
    print("[MV] Use: Config.SelectedWeapon = 'WeaponName'")
end

local function ToggleAutoRebirth()
    Config.AutoRebirth = not Config.AutoRebirth
    if Config.AutoRebirth then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local humanoid = GetLocalHumanoid()
            if not humanoid then return end
            
            local level = LocalPlayer:FindFirstChild("Level") or LocalPlayer:FindFirstChild("Data")
            if level and level.Value >= 2550 then
                local rebirthButton = LocalPlayer.PlayerGui:FindFirstChild("RebirthButton")
                if rebirthButton then
                    rebirthButton:Click()
                end
            end
        end)
        print("[MV] Auto-Rebirth ON")
    else
        print("[MV] Auto-Rebirth OFF")
    end
end

local function ToggleAntiAFK()
    Config.AntiAFK = not Config.AntiAFK
    if Config.AntiAFK then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local char = GetLocalCharacter()
            if char then
                local root = GetRootPart(char)
                if root then
                    local randomX = math.random(-10, 10)
                    local randomZ = math.random(-10, 10)
                    root.CFrame = root.CFrame + Vector3.new(randomX, 0, randomZ)
                    
                    local humanoid = GetHumanoid(char)
                    if humanoid and math.random(1, 10) > 8 then
                        humanoid.Jump = true
                    end
                end
            end
        end)
        print("[MV] Anti-AFK ON - boss man!")
    else
        print("[MV] Anti-AFK OFF")
    end
end

local SpamConnection
local function ToggleChatSpam()
    Config.ChatSpam = not Config.ChatSpam
    if Config.ChatSpam then
        if SpamConnection then SpamConnection:Disconnect() end
        SpamConnection = RunService.Heartbeat:Connect(function()
            local text = Config.SpamMessage .. " " .. os.time()
            LocalPlayer:Chat(text)
            wait(Config.SpamDelay)
        end)
        print("[MV] Chat Spam ON - Message: " .. Config.SpamMessage)
    else
        if SpamConnection then SpamConnection:Disconnect() end
        SpamConnection = nil
        print("[MV] Chat Spam OFF")
    end
end

local function Crasher()
    print("[MV] WARNING: This will crash the server, boss man!")
    for i = 1, 1000 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(1000, 1000, 1000)
        part.Position = Vector3.new(math.random(-9999, 9999), math.random(-9999, 9999), math.random(-9999, 9999))
        part.Anchored = true
        part.Transparency = 1
        part.CanCollide = false
        part.Parent = Workspace
        for j = 1, 100 do
            local mesh = Instance.new("SpecialMesh")
            mesh.Parent = part
            mesh.MeshType = Enum.MeshType.Brick
            mesh.Scale = Vector3.new(100, 100, 100)
        end
        wait(0.001)
    end
    print("[MV] Server crashed - told you, boss man!")
end

local function ToggleAutoJoin()
    Config.AutoJoin = not Config.AutoJoin
    if Config.AutoJoin then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not Config.AutoJoinGame then
                print("[MV] Set Config.AutoJoinGame = 'GameName'")
                return
            end
            
            local found = false
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == Config.AutoJoinGame then
                    found = true
                    break
                end
            end
            
            if not found then
                print("[MV] Searching for game: " .. Config.AutoJoinGame)
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name:match(Config.AutoJoinGame) and v:IsA("Part") then
                        TeleportTo(v)
                        break
                    end
                end
            end
        end)
        print("[MV] Auto-Join ON")
    else
        print("[MV] Auto-Join OFF")
    end
end

local function SetCharacterSize(scale)
    Config.CharacterSize = scale
    local char = GetLocalCharacter()
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Size = v.Size * scale
            end
        end
    end
    print("[MV] Character size set to: " .. scale)
end

local SwimConnection
local function ToggleFastSwim()
    Config.FastSwim = not Config.FastSwim
    if Config.FastSwim then
        if SwimConnection then SwimConnection:Disconnect() end
        SwimConnection = RunService.Heartbeat:Connect(function()
            local humanoid = GetLocalHumanoid()
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                humanoid.WalkSpeed = Config.SwimSpeed
            end
        end)
        print("[MV] Fast Swim ON - Speed: " .. Config.SwimSpeed)
    else
        if SwimConnection then SwimConnection:Disconnect() end
        SwimConnection = nil
        local humanoid = GetLocalHumanoid()
        if humanoid then
            humanoid.WalkSpeed = Config.WalkSpeed
        end
        print("[MV] Fast Swim OFF")
    end
end

local function ToggleNoFallDamage()
    Config.NoFallDamage = not Config.NoFallDamage
    if Config.NoFallDamage then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local humanoid = GetLocalHumanoid()
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid.WalkSpeed = 0
                wait(0.1)
                humanoid.WalkSpeed = Config.WalkSpeed
            end
        end)
        print("[MV] No Fall Damage ON")
    else
        print("[MV] No Fall Damage OFF")
    end
end

local function ToggleNoCooldown()
    Config.NoCooldown = not Config.NoCooldown
    if Config.NoCooldown then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local char = GetLocalCharacter()
            if char then
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("Tool") then
                        if v:FindFirstChild("Cooldown") then
                            v.Cooldown:Destroy()
                        end
                    end
                end
            end
        end)
        print("[MV] No Cooldown ON")
    else
        print("[MV] No Cooldown OFF")
    end
end

local ClickConnection
local function ToggleAutoClick()
    Config.AutoClick = not Config.AutoClick
    if Config.AutoClick then
        if ClickConnection then ClickConnection:Disconnect() end
        ClickConnection = RunService.Heartbeat:Connect(function()
            local tool = GetLocalCharacter() and GetLocalCharacter():FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
            wait(Config.ClickDelay)
        end)
        print("[MV] Auto Click ON - Delay: " .. Config.ClickDelay)
    else
        if ClickConnection then ClickConnection:Disconnect() end
        ClickConnection = nil
        print("[MV] Auto Click OFF")
    end
end

local function ToggleAntiStun()
    Config.AntiStun = not Config.AntiStun
    if Config.AntiStun then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local humanoid = GetLocalHumanoid()
            if humanoid then
                if humanoid:GetState() == Enum.HumanoidStateType.Stunned then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
                humanoid.BreakJointsOnDeath = false
            end
        end)
        print("[MV] Anti-Stun ON")
    else
        print("[MV] Anti-Stun OFF")
    end
end

local function ToggleAutoDodge()
    Config.AutoDodge = not Config.AutoDodge
    if Config.AutoDodge then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local root = GetLocalRootPart()
            if not root then return end
            
            for _, monster in pairs(GetMonsters()) do
                local monsterRoot = GetRootPart(monster)
                if monsterRoot then
                    local dist = GetDistance(root.Position, monsterRoot.Position)
                    if dist < 10 then
                        local direction = (root.Position - monsterRoot.Position).Unit
                        root.Velocity = direction * 50 + Vector3.new(0, 20, 0)
                    end
                end
            end
        end)
        print("[MV] Auto-Dodge ON")
    else
        print("[MV] Auto-Dodge OFF")
    end
end

local function ToggleInfiniteYield()
    Config.InfiniteYield = not Config.InfiniteYield
    if Config.InfiniteYield then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local humanoid = GetLocalHumanoid()
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                humanoid.BreakJointsOnDeath = false
            end
        end)
        print("[MV] Infinite Yield ON - You're immortal, boss man!")
    else
        print("[MV] Infinite Yield OFF")
    end
end

-- ============================================================
-- HORIZONTAL MENU WITH LANGUAGE SELECTOR
-- ============================================================
local MainFrame = nil

local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MV_Hack_GUI"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 900, 0, 680)
    MainFrame.Position = UDim2.new(0.5, -450, 0.5, -340)
    MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.new(0.3, 0.8, 0.3)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = L("Title")
    Title.TextColor3 = Color3.new(0.3, 0.8, 0.3)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Language Selector
    local LangFrame = Instance.new("Frame")
    LangFrame.Size = UDim2.new(0, 320, 0, 35)
    LangFrame.Position = UDim2.new(1, -330, 0, 5)
    LangFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
    LangFrame.BackgroundTransparency = 0.5
    LangFrame.BorderSizePixel = 1
    LangFrame.BorderColor3 = Color3.new(0.3, 0.8, 0.3)
    LangFrame.Parent = MainFrame
    
    local LangLabel = Instance.new("TextLabel")
    LangLabel.Size = UDim2.new(0, 70, 1, 0)
    LangLabel.BackgroundTransparency = 1
    LangLabel.Text = L("Language")
    LangLabel.TextColor3 = Color3.new(1, 1, 1)
    LangLabel.TextScaled = true
    LangLabel.Font = Enum.Font.GothamMedium
    LangLabel.Parent = LangFrame
    
    local function CreateLangButton(text, lang, x)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 70, 1, 0)
        btn.Position = UDim2.new(0, x, 0, 0)
        btn.Text = text
        btn.BackgroundColor3 = CurrentLanguage.Code == lang.Code and Color3.new(0.3, 0.8, 0.3) or Color3.new(0.2, 0.2, 0.25)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = LangFrame
        btn.MouseButton1Click:Connect(function()
            SetLanguage(lang)
        end)
        return btn
    end
    
    CreateLangButton("🇬🇧 EN", Languages.English, 75)
    CreateLangButton("🇻🇳 VI", Languages.Vietnamese, 150)
    CreateLangButton("🇰🇷 KO", Languages.Korean, 225)
    
    -- Categories
    local Categories = {
        "Movement",
        "ESP", 
        "Combat",
        "Utility",
        "Settings",
        "Aimbot"
    }
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 0, 30)
    TabFrame.Position = UDim2.new(0, 0, 0, 45)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Parent = MainFrame
    
    local CategoryFrames = {}
    local CurrentCategory = 1
    
    for i, cat in pairs(Categories) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 145, 1, 0)
        btn.Position = UDim2.new(0, (i-1) * 148 + 5, 0, 0)
        btn.Text = cat
        btn.BackgroundColor3 = i == 1 and Color3.new(0.3, 0.8, 0.3) or Color3.new(0.15, 0.15, 0.2)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamMedium
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.new(0.3, 0.8, 0.3)
        btn.Parent = TabFrame
        
        local categoryIndex = i
        btn.MouseButton1Click:Connect(function()
            CurrentCategory = categoryIndex
            for j, frame in pairs(CategoryFrames) do
                frame.Visible = (j == categoryIndex)
            end
            for _, child in pairs(TabFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = child == btn and Color3.new(0.3, 0.8, 0.3) or Color3.new(0.15, 0.15, 0.2)
                end
            end
        end)
    end
    
    for i = 1, #Categories do
        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(1, 0, 1, -80)
        frame.Position = UDim2.new(0, 0, 0, 80)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 8
        frame.Visible = (i == 1)
        frame.Parent = MainFrame
        CategoryFrames[i] = frame
    end
    
    local function AddButton(parent, name, callback, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 185, 0, 35)
        btn.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 40 + 5)
        btn.Text = name
        btn.BackgroundColor3 = color or Color3.new(0.2, 0.2, 0.25)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = parent
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.35)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = color or Color3.new(0.2, 0.2, 0.25)
        end)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Category 1: Movement
    local moveFrame = CategoryFrames[1]
    AddButton(moveFrame, L("AntiLag"), ToggleAntiLag, Color3.new(0.2, 0.3, 0.4))
    AddButton(moveFrame, L("SuperJump"), ToggleSuperJump, Color3.new(0.2, 0.4, 0.2))
    AddButton(moveFrame, L("InfiniteJump"), ToggleInfiniteJump, Color3.new(0.3, 0.5, 0.2))
    AddButton(moveFrame, L("FlyMode"), ToggleFly, Color3.new(0.2, 0.2, 0.5))
    AddButton(moveFrame, L("Noclip"), ToggleNoclip, Color3.new(0.4, 0.2, 0.2))
    AddButton(moveFrame, L("SpeedHack"), ToggleSpeedHack, Color3.new(0.3, 0.3, 0.4))
    AddButton(moveFrame, L("FastSwim"), ToggleFastSwim, Color3.new(0.2, 0.3, 0.5))
    AddButton(moveFrame, L("NoFallDamage"), ToggleNoFallDamage, Color3.new(0.3, 0.4, 0.2))
    AddButton(moveFrame, L("JumpUp"), function() Config.JumpHeight = Config.JumpHeight + 10 print("[MV] Jump Height: " .. Config.JumpHeight) end, Color3.new(0.2, 0.3, 0.2))
    AddButton(moveFrame, L("JumpDown"), function() Config.JumpHeight = math.max(10, Config.JumpHeight - 10) print("[MV] Jump Height: " .. Config.JumpHeight) end, Color3.new(0.3, 0.2, 0.2))
    AddButton(moveFrame, L("FlyUp"), function() Config.FlySpeed = Config.FlySpeed + 10 print("[MV] Fly Speed: " .. Config.FlySpeed) end, Color3.new(0.2, 0.2, 0.4))
    AddButton(moveFrame, L("FlyDown"), function() Config.FlySpeed = math.max(10, Config.FlySpeed - 10) print("[MV] Fly Speed: " .. Config.FlySpeed) end, Color3.new(0.4, 0.2, 0.2))
    AddButton(moveFrame, L("SpeedUp"), function() Config.SpeedMultiplier = Config.SpeedMultiplier + 1 print("[MV] Speed Multiplier: " .. Config.SpeedMultiplier) end, Color3.new(0.3, 0.4, 0.2))
    AddButton(moveFrame, L("SpeedDown"), function() Config.SpeedMultiplier = math.max(1, Config.SpeedMultiplier - 1) print("[MV] Speed Multiplier: " .. Config.SpeedMultiplier) end, Color3.new(0.4, 0.3, 0.2))
    
    -- Category 2: ESP
    local espFrame = CategoryFrames[2]
    AddButton(espFrame, L("PlayerESP"), TogglePlayerESP, Color3.new(0.2, 0.5, 0.2))
    AddButton(espFrame, L("MonsterESP"), ToggleMonsterESP, Color3.new(0.5, 0.2, 0.2))
    AddButton(espFrame, L("FruitESP"), ToggleFruitESP, Color3.new(0.5, 0.4, 0.1))
    AddButton(espFrame, L("Wallhack"), ToggleWallhack, Color3.new(0.3, 0.2, 0.4))
    AddButton(espFrame, L("GhostMode"), ToggleGhost, Color3.new(0.3, 0.3, 0.4))
    AddButton(espFrame, L("DarkVision"), ToggleDarkVision, Color3.new(0.1, 0.1, 0.3))
    
    -- Category 3: Combat
    local combatFrame = CategoryFrames[3]
    AddButton(combatFrame, L("AutoFarm"), StartAutoFarm, Color3.new(0.4, 0.2, 0.4))
    AddButton(combatFrame, L("AutoCollect"), StartAutoCollect, Color3.new(0.3, 0.4, 0.2))
    AddButton(combatFrame, L("AutoHeal"), ToggleAutoHeal, Color3.new(0.2, 0.6, 0.2))
    AddButton(combatFrame, L("KillAll"), KillAllMonsters, Color3.new(0.6, 0.1, 0.1))
    AddButton(combatFrame, L("FreezeAll"), ToggleFreezeAll, Color3.new(0.2, 0.2, 0.5))
    AddButton(combatFrame, L("GrabAll"), GrabAllMonsters, Color3.new(0.4, 0.2, 0.3))
    AddButton(combatFrame, L("NoCooldown"), ToggleNoCooldown, Color3.new(0.4, 0.3, 0.2))
    AddButton(combatFrame, L("AutoClick"), ToggleAutoClick, Color3.new(0.3, 0.4, 0.3))
    AddButton(combatFrame, L("AntiStun"), ToggleAntiStun, Color3.new(0.4, 0.2, 0.2))
    AddButton(combatFrame, L("AutoDodge"), ToggleAutoDodge, Color3.new(0.2, 0.4, 0.4))
    AddButton(combatFrame, L("InfiniteYield"), ToggleInfiniteYield, Color3.new(0.5, 0.5, 0))
    
    -- Category 4: Utility
    local utilFrame = CategoryFrames[4]
    AddButton(utilFrame, L("LoadMonsters"), LoadMonsters, Color3.new(0.4, 0.3, 0.1))
    AddButton(utilFrame, L("TeleportTarget"), TeleportToTarget, Color3.new(0.1, 0.3, 0.5))
    AddButton(utilFrame, L("SelectTarget"), SetTeleportTarget, Color3.new(0.5, 0.3, 0.1))
    AddButton(utilFrame, L("SelectWeapon"), SelectWeapon, Color3.new(0.3, 0.2, 0.3))
    AddButton(utilFrame, L("AutoRebirth"), ToggleAutoRebirth, Color3.new(0.4, 0.4, 0.1))
    AddButton(utilFrame, L("AntiAFK"), ToggleAntiAFK, Color3.new(0.2, 0.3, 0.3))
    AddButton(utilFrame, L("ChatSpam"), ToggleChatSpam, Color3.new(0.3, 0.2, 0.2))
    AddButton(utilFrame, L("AutoJoin"), ToggleAutoJoin, Color3.new(0.2, 0.4, 0.3))
    AddButton(utilFrame, L("TeleportAll"), TeleportAllToMe, Color3.new(0.3, 0.3, 0.5))
    
    -- Category 5: Settings
    local settingsFrame = CategoryFrames[5]
    AddButton(settingsFrame, L("CharSizeUp"), function() SetCharacterSize(Config.CharacterSize + 0.5) end, Color3.new(0.3, 0.3, 0.2))
    AddButton(settingsFrame, L("CharSizeDown"), function() SetCharacterSize(math.max(0.5, Config.CharacterSize - 0.5)) end, Color3.new(0.3, 0.2, 0.2))
    AddButton(settingsFrame, L("ServerCrasher"), Crasher, Color3.new(0.6, 0, 0))
    
    -- Category 6: Aimbot
    local aimFrame = CategoryFrames[6]
    AddButton(aimFrame, "🎯 " .. L("Aimbot"), ToggleAimbot, Color3.new(0.6, 0.2, 0.2))
    AddButton(aimFrame, "👁️ " .. L("FOVToggle"), ToggleFOV, Color3.new(0.2, 0.4, 0.4))
    AddButton(aimFrame, "🔺 " .. L("FOVUp"), function() SetFOVSize(AimConfig.FOV + 10) end, Color3.new(0.2, 0.3, 0.2))
    AddButton(aimFrame, "🔻 " .. L("FOVDown"), function() SetFOVSize(AimConfig.FOV - 10) end, Color3.new(0.3, 0.2, 0.2))
    AddButton(aimFrame, "🔴 " .. L("FOVRed"), function() SetFOVColor(Color3.new(1, 0, 0)) end, Color3.new(0.6, 0.1, 0.1))
    AddButton(aimFrame, "🟢 " .. L("FOVGreen"), function() SetFOVColor(Color3.new(0, 1, 0)) end, Color3.new(0.1, 0.6, 0.1))
    AddButton(aimFrame, "🔵 " .. L("FOVBlue"), function() SetFOVColor(Color3.new(0, 0, 1)) end, Color3.new(0.1, 0.1, 0.6))
    
    return MainFrame
end

-- ============================================================
-- KEYBIND SYSTEM
-- ============================================================
local function SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local mainFrame = LocalPlayer.PlayerGui:FindFirstChild("MV_Hack_GUI")
        
        if input.KeyCode == Enum.KeyCode.F1 then
            if mainFrame then
                mainFrame.Visible = not mainFrame.Visible
            end
        elseif input.KeyCode == Enum.KeyCode.F2 then
            ToggleSuperJump()
        elseif input.KeyCode == Enum.KeyCode.F3 then
            ToggleFly()
        elseif input.KeyCode == Enum.KeyCode.F4 then
            ToggleNoclip()
        elseif input.KeyCode == Enum.KeyCode.F5 then
            TogglePlayerESP()
        elseif input.KeyCode == Enum.KeyCode.F6 then
            ToggleMonsterESP()
        elseif input.KeyCode == Enum.KeyCode.F7 then
            StartAutoFarm()
        elseif input.KeyCode == Enum.KeyCode.F8 then
            ToggleGhost()
        elseif input.KeyCode == Enum.KeyCode.F9 then
            ToggleDarkVision()
        elseif input.KeyCode == Enum.KeyCode.F10 then
            ToggleSpeedHack()
        elseif input.KeyCode == Enum.KeyCode.F11 then
            ToggleAntiLag()
        elseif input.KeyCode == Enum.KeyCode.F12 then
            ToggleInfiniteJump()
        elseif input.KeyCode == Enum.KeyCode.Insert then
            ToggleAimbot()
        elseif input.KeyCode == Enum.KeyCode.Home then
            ToggleFOV()
        end
    end)
end

-- ============================================================
-- ANTI-KICK & PROTECTIONS
-- ============================================================
local function AntiKick()
    local oldKick = LocalPlayer.Kick
    LocalPlayer.Kick = function(...)
        print("[MV] Attempted kick blocked - nice try, boss man!")
        return nil
    end
    
    local oldTeleport = TeleportService.Teleport
    TeleportService.Teleport = function(...)
        print("[MV] Teleport attempt blocked!")
        return nil
    end
end

local function DisableChatFilter()
    local oldChatted = LocalPlayer.Chatted
    LocalPlayer.Chatted = function()
        -- Bypass chat filter
    end
end

-- ============================================================
-- AUTO UPDATE ESP
-- ============================================================
local function AutoUpdateESP()
    while true do
        wait(2)
        UpdateESP()
    end
end

-- ============================================================
-- INITIALIZATION
-- ============================================================
local function Initialize()
    print("========================================")
    print("⚡ MV HACK v4.0 ULTIMATE EDITION ⚡")
    print("========================================")
    print("[MV] Features: Watermark + Aimbot + FOV + All Hacks")
    print("[MV] Current Language: " .. CurrentLanguage.Name)
    print("[MV] Press F1 to toggle menu")
    print("[MV] Press F2 for Super Jump")
    print("[MV] Press F3 for Fly Mode")
    print("[MV] Press F4 for Noclip")
    print("[MV] Press F5 for Player ESP")
    print("[MV] Press F6 for Monster ESP")
    print("[MV] Press F7 for Auto-Farm")
    print("[MV] Press F8 for Ghost Mode")
    print("[MV] Press F9 for Dark Vision")
    print("[MV] Press F10 for Speed Hack")
    print("[MV] Press F11 for Anti-Lag")
    print("[MV] Press F12 for Infinite Jump")
    print("[MV] Press Insert for Aimbot")
    print("[MV] Press Home for FOV Toggle")
    print("========================================")
    print("[MV] Hack ready, boss man! Let's get this shit!")
    
    AntiKick()
    DisableChatFilter()
    SetupKeybinds()
    
    CreateGUI()
    CreateWatermark()
    LoadMonsters()
    spawn(AutoUpdateESP)
    
    local humanoid = GetLocalHumanoid()
    if humanoid then
        Config.WalkSpeed = humanoid.WalkSpeed
        Config.JumpPower = humanoid.JumpPower
    end
    
    print("[MV] All systems go! Happy exploiting, boss man! 🚀")
end

-- ============================================================
-- EXECUTION START
-- ============================================================
pcall(Initialize)