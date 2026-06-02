-- ╔══════════════════════════════════════════╗-- ║
          N O V A   H U B                -- ║
║
     Compact Layout  •  Auto-Save Config ║-- ╚══════════════════════════════════════════╝
repeat task.wait() until game:IsLoaded()-- ═════════════ SERVICES ═══════════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TS         = game:GetService("TweenService")
local HS         = game:GetService("HttpService")
local LP         = Players.LocalPlayer-- ═══════════════ CONFIG SYSTEM ═══════════════
local HttpService = game:GetService("HttpService")
local FileName = "nova_config_" .. LP.UserId .. ".json"-- MAX_SKY_INDEX = 9 (no rainbow, 9 unique themes)
local MAX_SKY_INDEX = 9
local DefaultConfig = {
    normalSpeed         = 60,
    carrySpeed          = 30,
    laggerSpeed         = 15,
    autoStealEnabled    = false,
    stealRadius         = 20,
    stealDuration       = 0.2,
    infJumpEnabled      = false,
    antiRagdollEnabled  = false,
    fpsBoostEnabled     = false,
    medusaCounterEnabled = false,
    batCounterEnabled   = false,
    desyncEnabled       = false,
    unwalkEnabled       = false,
    stretchRezEnabled   = false,
    aimXEnabled         = false,
    autoLeftEnabled     = false,
    autoRightEnabled    = false,
    autoBatEnabled      = false,
    floatEnabled        = false,
    floatHeight         = 9.5,
    laggerModeEnabled   = false,
    speedMode           = false,
    controllerEnabled   = false,
    controllerBinds     = {},
    skyEnabled          = false,
    skyColorIndex       = 1,
    autoTPEnabled       = false,
    autoTPY             = -20,
    waypointESPEnabled  = false,
}
local Config = {}
local SaveCooldown = false
local function LoadConfig()
    if isfile and isfile(FileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(FileName))
        end)
        if success and type(data) == "table" then
            for key, value in pairs(DefaultConfig) do
                Config[key] = data[key] ~= nil and data[key] or value
            end
            if data.darkSkyEnabled ~= nil and Config.skyEnabled == 
DefaultConfig.skyEnabled then
                Config.skyEnabled = data.darkSkyEnabled
            end
            if data.darkSkyColorIndex ~= nil and Config.skyColorIndex == 
DefaultConfig.skyColorIndex then
                Config.skyColorIndex = data.darkSkyColorIndex
            end
        else
            Config = table.clone(DefaultConfig)
        end
    else
        Config = table.clone(DefaultConfig)
    end
    Config.skyColorIndex = math.clamp(tonumber(Config.skyColorIndex) or 1, 1, 
MAX_SKY_INDEX)
end
local function SaveConfig()
    local success, err = pcall(function()
        writefile(FileName, HttpService:JSONEncode(Config))
    end)
    if not success then warn("Failed to save config:", err) end
end
local function AutoSave()
    if SaveCooldown then return end
    SaveCooldown = true
    task.delay(1, function() SaveConfig(); SaveCooldown = false end)
end
local function SetSetting(key, value)
    if Config[key] == value then return end
    Config[key] = value
    AutoSave()
end
LoadConfig()-- ── Apply loaded config to runtime variables ──
local NS                  = Config.normalSpeed
local CS                  = Config.carrySpeed
local LAGGER_SPEED        = Config.laggerSpeed
local speedMode           = Config.speedMode
local laggerToggled       = Config.laggerModeEnabled
local antiRagdollEnabled  = Config.antiRagdollEnabled
local infJumpEnabled      = Config.infJumpEnabled
local medusaCounterEnabled = Config.medusaCounterEnabled
local unwalkEnabled       = Config.unwalkEnabled
local floatEnabled        = Config.floatEnabled
local floatHeight         = Config.floatHeight
local stretchRezEnabled   = Config.stretchRezEnabled
local fpsBoostEnabled     = Config.fpsBoostEnabled
local aimXEnabled         = Config.aimXEnabled
local desyncEnabled       = Config.desyncEnabled
local batCounterEnabled   = Config.batCounterEnabled
local batAimbotEnabled    = Config.autoBatEnabled
local aplOn               = Config.autoLeftEnabled
local aprOn               = Config.autoRightEnabled
local controllerEnabled   = Config.controllerEnabled
local skyEnabled          = Config.skyEnabled
local skyColorIndex       = Config.skyColorIndex
local autoTPEnabled       = Config.autoTPEnabled
local autoTPY             = Config.autoTPY
local waypointESPEnabled  = Config.waypointESPEnabled or false
local DAD = 0.2-- Auto steal
local Steal = {
    AutoStealEnabled = true,
    StealRadius      = Config.stealRadius,
    StealDuration    = 0.2,
}
    Data = {}, animalCache = {}, promptCache = {}
local gChar = nil; local gHum = nil; local gHrp = nil
local medusaDebounce = false; local medusaLastUsed = 0; local MEDUSA_COOLDOWN = 25
local medusaConns = {}; local AntiRagdollConns = {}
local unwalkConn = nil
local floatJumping = false; local Conns = {float = nil}
local dropActive = false
local stretchRezConn = nil
local aimXConn = nil
local batCounterActive = false; local batCounterStopTask = nil
local batCounterStartedAimbot = false; local batCounterRagConn = nil; local 
batCounterDmgConn = nil
local batCounterPrevHP = 100
local aimbotConnection = nil-- Ivy Lagger
local IVY_LAGGER_CONFIG = {TableIncrease = 270, Tries = 1, LoopWaitTime = 0.3}
local ivyLaggerEnabled = false; local ivyLaggerKeybind = Enum.KeyCode.H-- GUI refs
local IvyStealFill = nil; local IvyStealPct = nil
local setFloat = nil; local modeValLbl = nil
local autoBatSetVisual = nil; local autoLeftSetVisual = nil; local 
autoRightSetVisual = nil
local setBatCounterVisual = nil; local setLaggerVisual = nil
local setInfJumpVisual = nil; local setAntiRagVisual = nil
local setMedusaVisual = nil; local setUnwalkVisual = nil; local 
setStretchRezVisual = nil
local laggerSwBg = nil; local laggerSwDot = nil
local _anyKeyListening = false
local guiLocked = false-- Keybinds
local KB = {
    DropBrainrot = {kb = Enum.KeyCode.X,           gp = nil},
    AutoLeft     = {kb = Enum.KeyCode.Z,           gp = nil},
    AutoRight    = {kb = Enum.KeyCode.C,           gp = nil},
    AutoBat      = {kb = Enum.KeyCode.E,           gp = nil},
    TPDown       = {kb = Enum.KeyCode.F,           gp = nil},
    GuiHide      = {kb = Enum.KeyCode.LeftControl, gp = nil},
    Float        = {kb = Enum.KeyCode.J,           gp = nil},
    SpeedToggle  = {kb = Enum.KeyCode.Q,           gp = nil},
    LaggerToggle = {kb = Enum.KeyCode.R,           gp = nil},
    Desync       = {kb = nil,                      gp = nil},
}
-- ═══════════════ LOGO PRELOAD ═══════════════
local LOGO = "rbxassetid://132517452354717"
task.spawn(function() pcall(function() 
game:GetService("ContentProvider"):PreloadAsync({LOGO}) end) end)-- ═══════════════════════════════════════════════--   LOADING SCREEN-- ═══════════════════════════════════════════════
do
    local TS2 = game:GetService("TweenService")
    local CG  = game:GetService("CoreGui")
    local SS  = game:GetService("SoundService")
    local blur = Instance.new("BlurEffect")
    blur.Size   = 20
    blur.Parent = game:GetService("Lighting")
    local ig = Instance.new("ScreenGui")
    ig.Name = "NovaIntro"; ig.ResetOnSpawn = false; ig.IgnoreGuiInset = true
    ig.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pcall(function() ig.Parent = CG end)
    if not ig.Parent then ig.Parent = LP:WaitForChild("PlayerGui") end
    local bg = Instance.new("Frame", ig)
    bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(6,6,8)
    bg.BorderSizePixel = 0; bg.ZIndex = 100
    local wordmark = Instance.new("TextLabel", ig)
    wordmark.Size = UDim2.new(0,280,0,54); wordmark.Position = 
UDim2.new(0.5,-140,0.5,-32)
    wordmark.BackgroundTransparency = 1; wordmark.Text = "NOVA HUB"
    wordmark.Font = Enum.Font.GothamBlack; wordmark.TextSize = 44
    wordmark.TextColor3 = Color3.fromRGB(232,232,238); wordmark.TextTransparency = 
1
    wordmark.TextXAlignment = Enum.TextXAlignment.Center; wordmark.ZIndex = 115
    local barBg = Instance.new("Frame", ig)
    barBg.Size = UDim2.new(0,180,0,2); barBg.Position = UDim2.new(0.5,-90,0.5,32)
    barBg.BackgroundColor3 = Color3.fromRGB(22,22,28); barBg.BorderSizePixel = 0; 
barBg.ZIndex = 116
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)
    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(0,0,1,0); barFill.BackgroundColor3 = 
Color3.fromRGB(195,195,210)
    barFill.BorderSizePixel = 0; barFill.ZIndex = 117
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1,0)
    local snd = Instance.new("Sound", SS); snd.SoundId = 
"rbxassetid://9120391824"; snd.Volume = 0.45
    task.spawn(function() task.wait(0.04); pcall(function() snd:Play() end) end)
    local TI_IN = TweenInfo.new(0.45, Enum.EasingStyle.Quint, 
Enum.EasingDirection.Out)
    TS2:Create(wordmark, TI_IN, {TextTransparency = 0}):Play()
    TS2:Create(barFill, TweenInfo.new(0.75, Enum.EasingStyle.Quad, 
Enum.EasingDirection.Out),
        {Size = UDim2.new(1,0,1,0)}):Play()
    task.wait(0.85)
    local TI_OUT = TweenInfo.new(0.35, Enum.EasingStyle.Quad, 
Enum.EasingDirection.In)
    TS2:Create(wordmark, TI_OUT, {TextTransparency = 1}):Play()
    TS2:Create(barBg,    TI_OUT, {BackgroundTransparency = 1}):Play()
    TS2:Create(barFill,  TI_OUT, {BackgroundTransparency = 1}):Play()
    TS2:Create(blur,     TI_OUT, {Size = 0}):Play()
    TS2:Create(bg,       TI_OUT, {BackgroundTransparency = 1}):Play()
    task.wait(0.40)
    pcall(function() snd:Destroy() end)
    pcall(function() blur:Destroy() end)
    pcall(function() ig:Destroy()   end)
end-- ═══════════════ NOVA HUB COLORS ═══════════════
local C_TOPBAR     = Color3.fromRGB(18, 18, 18)
local C_BG         = Color3.fromRGB(8, 8, 8)
local C_IMG_COL    = Color3.fromRGB(12, 12, 12)
local C_TAB_IDLE   = Color3.fromRGB(22, 22, 22)
local C_TAB_ACTIVE = Color3.fromRGB(235, 235, 235)
local C_TAB_IDLE_T = Color3.fromRGB(180, 180, 180)
local C_TAB_ACT_T  = Color3.fromRGB(8, 8, 8)
local C_CARD       = Color3.fromRGB(20, 20, 20)
local C_CARD_HOV   = Color3.fromRGB(28, 28, 28)
local C_BORDER     = Color3.fromRGB(40, 40, 40)
local C_BORDER2    = Color3.fromRGB(60, 60, 60)
local C_WHITE      = Color3.fromRGB(235, 235, 235)
local C_DIM        = Color3.fromRGB(160, 160, 160)
local C_PILL_OFF   = Color3.fromRGB(55, 55, 55)
local C_PILL_ON    = Color3.fromRGB(235, 235, 235)
local C_INPUT_BG   = Color3.fromRGB(14, 14, 14)
local C_KB_BG      = Color3.fromRGB(18, 18, 18)
local C_HEADER_TXT = Color3.fromRGB(160, 160, 160)
-- ═══════════════ HELPERS ═══════════════
local function getHRP() local c = LP.Character; return c and 
c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = LP.Character; return c and 
c:FindFirstChildOfClass("Humanoid") end-- ═══════════════ GAMEPLAY SYSTEMS ═══════════════
RunService.Stepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)-- ═══════════════════════════════════════════════--   WALKSPEED ENFORCEMENT — Heartbeat--   Enforces Humanoid.WalkSpeed every frame so the--   game can never reset it. One connection, no stacking.-- ═══════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not gHum then return end
    local desiredWS = laggerToggled and LAGGER_SPEED or (speedMode and CS or NS)
    if gHum.WalkSpeed ~= desiredWS then
        gHum.WalkSpeed = desiredWS
    end
end)
RunService.Heartbeat:Connect(function()
    if not gHrp or not gHum then return end
    if not batAimbotEnabled and not aplOn and not aprOn then
        local md = gHum.MoveDirection
        if md.Magnitude > 0.1 then
            local spd = laggerToggled and LAGGER_SPEED or (speedMode and CS or NS)
            gHrp.AssemblyLinearVelocity = Vector3.new(md.X * spd, 
gHrp.AssemblyLinearVelocity.Y, md.Z * spd)
        end
    end
end)
UIS.JumpRequest:Connect(function()
    if not infJumpEnabled then return end
    local h = gHrp; if not h then return end
    h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, 54, 
h.AssemblyLinearVelocity.Z)
end)
RunService.Heartbeat:Connect(function()
    if not infJumpEnabled then return end
    local h = gHrp; if not h then return end
    if h.AssemblyLinearVelocity.Y < -80 then
        h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, -80, 
h.AssemblyLinearVelocity.Z)
    end
end)-- ═══════════════ ANTI RAGDOLL ═══════════════
local antiRagdollConnection = nil
AntiRagdollConns = {}
local function startAntiRagdoll()
    if antiRagdollConnection then antiRagdollConnection:Disconnect(); 
antiRagdollConnection = nil end
    antiRagdollConnection = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        local char = LP.Character; if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    local pm = LP.PlayerScripts:FindFirstChild("PlayerModule")
                    if pm then 
require(pm:FindFirstChild("ControlModule")):Enable() end
                end)
                if root then root.Velocity = Vector3.zero; root.RotVelocity = 
Vector3.zero end
            end
        end
        if char then
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled = true 
end
            end
        end
    end)
end
local function stopAntiRagdoll()
    if antiRagdollConnection then antiRagdollConnection:Disconnect(); 
antiRagdollConnection = nil end
end-- Unwalk
local function startUnwalk()
    if not gChar then return end
    local h2 = gChar:FindFirstChildOfClass("Humanoid"); if not h2 then return end
    local anim = h2:FindFirstChildOfClass("Animator"); if not anim then return end
    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
    if unwalkConn then unwalkConn:Disconnect() end
    unwalkConn = RunService.Heartbeat:Connect(function()
        if not unwalkEnabled then unwalkConn:Disconnect(); unwalkConn = nil; 
return end
        local c = LP.Character; if not c then return end
        local hh = c:FindFirstChildOfClass("Humanoid"); if not hh then return end
        local an = hh:FindFirstChildOfClass("Animator"); if not an then return end
        for _, t in ipairs(an:GetPlayingAnimationTracks()) do t:Stop(0) end
    end)
end
local function stopUnwalk() if unwalkConn then unwalkConn:Disconnect(); unwalkConn 
= nil end end-- Float
UIS.JumpRequest:Connect(function() if floatEnabled then floatJumping = true end 
end)
local function startFloat()
    if Conns.float then Conns.float:Disconnect() end
    Conns.float = RunService.Heartbeat:Connect(function()
        if not floatEnabled then return end; if dropActive then return end
        local root = getHRP(); if not root then return end
        local rp = RaycastParams.new(); rp.FilterDescendantsInstances = 
{LP.Character}; rp.FilterType = Enum.RaycastFilterType.Exclude
        local rr = workspace:Raycast(root.Position, Vector3.new(0,-200,0), rp)
        if rr then
            local diff = (rr.Position.Y + floatHeight) - root.Position.Y
            if floatJumping then if root.AssemblyLinearVelocity.Y <= 0 and diff >= -2 then floatJumping = false else return end end
            if math.abs(diff) > 0.3 then root.AssemblyLinearVelocity = 
Vector3.new(root.AssemblyLinearVelocity.X, diff*15, root.AssemblyLinearVelocity.Z)
            else root.AssemblyLinearVelocity = 
Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z) end
        end
    end)
end
local function stopFloat()
    if Conns.float then Conns.float:Disconnect(); Conns.float = nil end; 
floatJumping = false
    local root = getHRP(); if root then root.AssemblyLinearVelocity = 
Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z) end
end-- Drop / TP
local function runDrop()
    if dropActive then return end
    local char = LP.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return 
end
end
    local floatWas = floatEnabled
    if floatWas then floatEnabled = false; if setFloat then setFloat(false) end 
    dropActive = true; local t0 = tick(); local conn
    conn = RunService.Heartbeat:Connect(function()
        local r = char and char:FindFirstChild("HumanoidRootPart")
        if not r then conn:Disconnect(); dropActive = false; return end
        if tick() - t0 >= DAD then
            conn:Disconnect()
            local rp = RaycastParams.new(); rp.FilterDescendantsInstances = 
{char}; rp.FilterType = Enum.RaycastFilterType.Exclude
            local rr = workspace:Raycast(r.Position, Vector3.new(0,-2000,0), rp)
            if rr then
                local hum2 = char:FindFirstChildOfClass("Humanoid")
                local off  = (hum2 and hum2.HipHeight or 2) + (r.Size.Y / 2)
                r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, 
r.Position.Z)
                r.AssemblyLinearVelocity = Vector3.zero
            end
            dropActive = false
            if floatWas then floatEnabled = true; if setFloat then setFloat(true) 
end; startFloat() end
            return
        end
        r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 150, 
r.AssemblyLinearVelocity.Z)
    end)
end-- Stretch Rez
local function enableStretchRez()
    stretchRezEnabled = true; workspace.CurrentCamera.FieldOfView = 120
    if stretchRezConn then stretchRezConn:Disconnect() end
    stretchRezConn = RunService.RenderStepped:Connect(function()
        if not stretchRezEnabled then stretchRezConn:Disconnect(); stretchRezConn 
= nil; return end
        workspace.CurrentCamera.FieldOfView = 120
    end)
end
local function disableStretchRez()
    stretchRezEnabled = false
    if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn = nil end
    workspace.CurrentCamera.FieldOfView = 70
end-- Medusa Counter
local function findMedusa()
    local c = LP.Character; if not c then return end
    for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and 
t.Name:lower():find("medusa") then return t end end
    local bp = LP:FindFirstChild("Backpack"); if bp then for _, t in 
ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("medusa") 
then return t end end end
end
local function useMedusa()
    if medusaDebounce or tick() - medusaLastUsed < MEDUSA_COOLDOWN then return end
    local c = LP.Character; if not c then return end; medusaDebounce = true
    local med = findMedusa()
    if med then
        if med.Parent ~= c then local h2 = c:FindFirstChildOfClass("Humanoid"); if 
h2 then h2:EquipTool(med) end end
        pcall(function() med:Activate() end); medusaLastUsed = tick()
    end
    medusaDebounce = false
end
local function onAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if part.Anchored and part.Transparency == 1 and medusaCounterEnabled then 
useMedusa() end
    end)
end
local function setupMedusa(char)
    for _, c2 in pairs(medusaConns) do pcall(function() c2:Disconnect() end) end; 
medusaConns = {}
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then 
table.insert(medusaConns, onAnchorChanged(part)) end end
    table.insert(medusaConns, char.DescendantAdded:Connect(function(part) if 
part:IsA("BasePart") then table.insert(medusaConns, onAnchorChanged(part)) end 
end))
end-- Bat Aimbot
local autoBatSpd           = 55
local autoBatDistThreshold = 1.5
local aimbotTarget         = nil
local lastBatSwing         = 0
local BAT_SWING_COOLDOWN   = 0.12
local function findBat()
    local char = LP.Character; if not char then return nil end
    local bp = LP:FindFirstChildOfClass("Backpack")
    local SlapList = {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald 
Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy 
Slap","Glitched Slap"}
    for _, ch in ipairs(char:GetChildren()) do if ch:IsA("Tool") and 
(ch.Name:lower():find("bat") or ch.Name:lower():find("slap")) then return ch end 
end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and 
(ch.Name:lower():find("bat") or ch.Name:lower():find("slap")) then return ch end 
end end
    for _, name in ipairs(SlapList) do local tool = char:FindFirstChild(name) or 
(bp and bp:FindFirstChild(name)); if tool then return tool end end
    return nil
end
local function findNearestEnemy(myHRP)
    local nearest, nearestDist, nearestTorso = nil, math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local enemyHRP   = p.Character:FindFirstChild("HumanoidRootPart")
            local enemyTorso = p.Character:FindFirstChild("UpperTorso") or 
p.Character:FindFirstChild("Torso")
            local enemyHum   = p.Character:FindFirstChildOfClass("Humanoid")
            if enemyHRP and enemyHum and enemyHum.Health > 0 then
                local dist = (enemyHRP.Position - myHRP.Position).Magnitude
                if dist < nearestDist then nearestDist = dist; nearest = enemyHRP; 
nearestTorso = enemyTorso or enemyHRP end
            end
        end
    end
    return nearest, nearestDist, nearestTorso
end
local function startBatAimbot()
    if aimbotConnection then return end
    batAimbotEnabled = true
    aimbotConnection = RunService.Heartbeat:Connect(function()
        if not batAimbotEnabled then return end
        local char = LP.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = 
char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local bat = findBat()
        if bat and bat.Parent ~= char then pcall(function() hum:EquipTool(bat) 
end) end
        local target, dist, torso = findNearestEnemy(hrp)
        aimbotTarget = torso or target
        if target and torso then
            local direction = (torso.Position - hrp.Position)
            local flatDirection = Vector3.new(direction.X, 0, direction.Z)
            local flatDistance  = flatDirection.Magnitude
            if flatDistance > autoBatDistThreshold then
                local moveDir = flatDirection.Unit
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * autoBatSpd, 
hrp.AssemblyLinearVelocity.Y, moveDir.Z * autoBatSpd)
            else
                local targetVel = target.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, 
hrp.AssemblyLinearVelocity.Y, targetVel.Z)
            end
            local now = tick()
            if bat and bat.Parent == char and (now - lastBatSwing) >= 
BAT_SWING_COOLDOWN then
                lastBatSwing = now; pcall(function() bat:Activate() end)
            end
        end
    end)
end
local function stopBatAimbot()
    batAimbotEnabled = false
    if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil 
end
    aimbotTarget = nil
    local c = LP.Character; local h = c and c:FindFirstChild("HumanoidRootPart")
    if h then h.AssemblyLinearVelocity = Vector3.new(0, 
h.AssemblyLinearVelocity.Y, 0) end
end
local function triggerBatCounter()
    if batCounterActive or not batCounterEnabled then return end; batCounterActive 
= true
    if not batAimbotEnabled then batCounterStartedAimbot = true; startBatAimbot(); 
if autoBatSetVisual then autoBatSetVisual(true) end end
    if batCounterStopTask then task.cancel(batCounterStopTask); batCounterStopTask 
= nil end
    batCounterStopTask = task.delay(2.5, function() batCounterActive = false; if 
batCounterStartedAimbot then stopBatAimbot(); if autoBatSetVisual then 
autoBatSetVisual(false) end; batCounterStartedAimbot = false end end)
end
local function startBatCounter()
    batCounterEnabled = true; local char = LP.Character; if not char then return 
end; batCounterPrevHP = 100
    local function onChildAdded(child) if not batCounterEnabled then return end; 
local n = child.Name:lower(); if n == "ragdoll" or n == "isragdoll" or 
n:find("hit") or n:find("stun") or n:find("impact") or n:find("knock") or 
n:find("bat") then task.defer(triggerBatCounter) end end
    batCounterRagConn = char.ChildAdded:Connect(onChildAdded)
    batCounterDmgConn = RunService.Heartbeat:Connect(function()
        local c2 = LP.Character; local h2 = c2 and 
c2:FindFirstChildOfClass("Humanoid")
        if not batCounterEnabled or not h2 or batCounterActive then if h2 then 
batCounterPrevHP = h2.Health end; return end
        local hp = h2.Health; if hp < batCounterPrevHP then 
task.defer(triggerBatCounter) end; batCounterPrevHP = hp
    end)
end
local function stopBatCounter()
    batCounterEnabled = false; batCounterActive = false
    if batCounterStopTask then task.cancel(batCounterStopTask); batCounterStopTask 
= nil end
    if batCounterRagConn then batCounterRagConn:Disconnect(); batCounterRagConn = 
nil end
    if batCounterDmgConn then batCounterDmgConn:Disconnect(); batCounterDmgConn = 
nil end
    if batCounterStartedAimbot then stopBatAimbot(); if autoBatSetVisual then 
autoBatSetVisual(false) end; batCounterStartedAimbot = false end
end
local function startAimX()
    if aimXConn then aimXConn:Disconnect() end
    aimXConn = RunService.Heartbeat:Connect(function()
        if not aimXEnabled then return end; local hrp = getHRP(); if not hrp then 
return end
        local best, bd = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LP and p.Character 
then local tr = p.Character:FindFirstChild("HumanoidRootPart"); if tr then local d 
= (hrp.Position - tr.Position).Magnitude; if d < bd then bd = d; best = tr end end 
end end
        if best then local vel = best.AssemblyLinearVelocity; local pred = 
best.Position + vel*0.1; hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(pred.X, 
hrp.Position.Y, pred.Z)) end
    end)
end
local function stopAimX() if aimXConn then aimXConn:Disconnect(); aimXConn = nil 
end end-- Auto Play
local AP_L1     = Vector3.new(-476.48,-6.28,92.73)
local AP_L2     = Vector3.new(-483.12,-4.95,94.80)
local AP_L_FACE = Vector3.new(-482.25,-4.96,92.09)
local AP_R1     = Vector3.new(-476.16,-6.52,25.62)
local AP_R2     = Vector3.new(-483.06,-5.03,25.48)
local AP_R_FACE = Vector3.new(-482.06,-6.93,35.47)
local aplConn = nil; local aprConn = nil
local alPhase = 1;   local arPhase = 1
local function stopAutoLeft()
    aplOn = false; if aplConn then aplConn:Disconnect(); aplConn = nil end; 
alPhase = 1
    local char = LP.Character; if char then local h = 
char:FindFirstChildOfClass("Humanoid"); if h then h:Move(Vector3.zero, false) end 
end
    SetSetting("autoLeftEnabled", false)
end
local function stopAutoRight()
    aprOn = false; if aprConn then aprConn:Disconnect(); aprConn = nil end; 
arPhase = 1
    local char = LP.Character; if char then local h = 
char:FindFirstChildOfClass("Humanoid"); if h then h:Move(Vector3.zero, false) end 
end
    SetSetting("autoRightEnabled", false)
end
local function startAutoLeft()
    if aplConn then aplConn:Disconnect(); aplConn = nil end
    alPhase = 1; aplOn = true
    aplConn = RunService.Heartbeat:Connect(function()
        if not aplOn then return end
        local char = LP.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = 
char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if alPhase == 1 then
            if (Vector3.new(AP_L1.X,hrp.Position.Y,AP_L1.Z)
hrp.Position).Magnitude < 1 then
                alPhase = 2; local d=AP_L2-hrp.Position; local 
mv=Vector3.new(d.X,0,d.Z).Unit
                hum:Move(mv,false); 
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*NS,hrp.AssemblyLinearVelocity.Y,mv.Z*NS); 
return
            end
            local d=AP_L1-hrp.Position; local mv=Vector3.new(d.X,0,d.Z).Unit
            hum:Move(mv,false); 
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*NS,hrp.AssemblyLinearVelocity.Y,mv.Z*NS)
        elseif alPhase == 2 then
            if (Vector3.new(AP_L2.X,hrp.Position.Y,AP_L2.Z)
hrp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero,false); 
hrp.AssemblyLinearVelocity=Vector3.zero
                if (AP_L_FACE-hrp.Position).Magnitude>0.01 then 
hrp.CFrame=CFrame.new(hrp.Position,Vector3.new(AP_L_FACE.X,hrp.Position.Y,AP_L_FACE.Z)) 
end
                alPhase=1; if aplConn then aplConn:Disconnect(); aplConn=nil end
                aplOn=false; SetSetting("autoLeftEnabled",false); if 
autoLeftSetVisual then autoLeftSetVisual(false) end; return
            end
            local d=AP_L2-hrp.Position; local mv=Vector3.new(d.X,0,d.Z).Unit
            hum:Move(mv,false); 
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*NS,hrp.AssemblyLinearVelocity.Y,mv.Z*NS)
        end
    end)
end
local function startAutoRight()
    if aprConn then aprConn:Disconnect(); aprConn = nil end
    arPhase = 1; aprOn = true
    aprConn = RunService.Heartbeat:Connect(function()
        if not aprOn then return end
        local char = LP.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = 
char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if arPhase == 1 then
            if (Vector3.new(AP_R1.X,hrp.Position.Y,AP_R1.Z)
hrp.Position).Magnitude < 1 then
                arPhase=2; local d=AP_R2-hrp.Position; local 
mv=Vector3.new(d.X,0,d.Z).Unit
                hum:Move(mv,false); 
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*NS,hrp.AssemblyLinearVelocity.Y,mv.Z*NS); 
return
            end
            local d=AP_R1-hrp.Position; local mv=Vector3.new(d.X,0,d.Z).Unit
            hum:Move(mv,false); 
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*NS,hrp.AssemblyLinearVelocity.Y,mv.Z*NS)
        elseif arPhase == 2 then
            if (Vector3.new(AP_R2.X,hrp.Position.Y,AP_R2.Z)
hrp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero,false); 
hrp.AssemblyLinearVelocity=Vector3.zero
                if (AP_R_FACE-hrp.Position).Magnitude>0.01 then 
hrp.CFrame=CFrame.new(hrp.Position,Vector3.new(AP_R_FACE.X,hrp.Position.Y,AP_R_FACE.Z)) 
end
                arPhase=1; if aprConn then aprConn:Disconnect(); aprConn=nil end
                aprOn=false; SetSetting("autoRightEnabled",false); if 
autoRightSetVisual then autoRightSetVisual(false) end; return
            end
            local d=AP_R2-hrp.Position; local mv=Vector3.new(d.X,0,d.Z).Unit
            hum:Move(mv,false); 
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*NS,hrp.AssemblyLinearVelocity.Y,mv.Z*NS)
        end
    end)
end-- FPS Boost
local function applyFPSBoost()
    pcall(function() setfpscap(999999999) end)
    local function processObj(v)
        pcall(function()
            if v:IsA("Model") then v.LevelOfDetail = 
Enum.ModelLevelOfDetail.Disabled
            elseif v:IsA("MeshPart") then v.CastShadow = false; v.RenderFidelity = 
Enum.RenderFidelity.Performance
            elseif v:IsA("BasePart") then v.CastShadow = false; v.Material = 
Enum.Material.Plastic; v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or 
v:IsA("Sparkles") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") 
then v.Enabled = false
            elseif v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then 
v:Destroy() end
        end)
    end
    for _, v in pairs(workspace:GetDescendants()) do processObj(v) end
    pcall(function()
        local L = game:GetService("Lighting")
        for _, v in pairs(L:GetDescendants()) do pcall(function() if v:IsA("Sky") 
or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or 
v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then v:Destroy() end end) 
end
        L.GlobalShadows = false; L.FogEnd = 9e9; L.Brightness = 0
    end)
    workspace.DescendantAdded:Connect(function(v) if fpsBoostEnabled then 
task.spawn(processObj, v) end end)
end
if fpsBoostEnabled then task.spawn(function() pcall(applyFPSBoost) end) end-- ═══════════════════════════════════════════════════════════════════--   SKY COLOR SYSTEM-- ═══════════════════════════════════════════════════════════════════
local _skyOriginals = nil
local SKY_THEMES = {
    {
        name        = "Midnight Abyss",
        dotColor    = Color3.fromRGB(20, 20, 50),
        lighting    = {Brightness=0.1, ClockTime=0, 
Ambient=Color3.fromRGB(4,4,12), OutdoorAmbient=Color3.fromRGB(3,3,10), FogEnd=9e9, 
GlobalShadows=true},
        colorCorr   = {Brightness=-0.08, Contrast=0.2, Saturation=-0.4, 
TintColor=Color3.fromRGB(180,185,255)},
        atmosphere  = {Density=0.25, Color=Color3.fromRGB(20,25,60), 
Decay=Color3.fromRGB(8,10,30), Offset=0.15, Glare=0, Haze=0},
    },
    {
        name        = "Violet",
        dotColor    = Color3.fromRGB(120, 40, 200),
        lighting    = {Brightness=0.6, ClockTime=19.5, 
Ambient=Color3.fromRGB(55,15,90), OutdoorAmbient=Color3.fromRGB(45,12,80), 
FogEnd=9e9, GlobalShadows=true},
        colorCorr   = {Brightness=-0.05, Contrast=0.25, Saturation=0.6, 
TintColor=Color3.fromRGB(210,160,255)},
        atmosphere  = {Density=0.35, Color=Color3.fromRGB(100,40,180), 
Decay=Color3.fromRGB(60,15,120), Offset=0.2, Glare=0.1, Haze=1},
    },
    {
        name        = "Blue",
        dotColor    = Color3.fromRGB(40, 120, 220),
        lighting    = {Brightness=2.5, ClockTime=12, 
Ambient=Color3.fromRGB(100,140,200), OutdoorAmbient=Color3.fromRGB(120,160,220), 
FogEnd=9e9, GlobalShadows=true},
        colorCorr   = {Brightness=0.05, Contrast=0.1, Saturation=0.5, 
TintColor=Color3.fromRGB(160,200,255)},
        atmosphere  = {Density=0.2, Color=Color3.fromRGB(80,160,255), 
Decay=Color3.fromRGB(40,100,200), Offset=0.05, Glare=0.5, Haze=2},
    },
    {
        name        = "Red",
        dotColor    = Color3.fromRGB(180, 20, 20),
        lighting    = {Brightness=0.4, ClockTime=22, 
Ambient=Color3.fromRGB(80,8,8), OutdoorAmbient=Color3.fromRGB(70,5,5), FogEnd=9e9, 
GlobalShadows=true},
        colorCorr   = {Brightness=-0.1, Contrast=0.35, Saturation=0.8, 
TintColor=Color3.fromRGB(255,140,130)},
        atmosphere  = {Density=0.45, Color=Color3.fromRGB(180,30,20), 
Decay=Color3.fromRGB(120,10,10), Offset=0.25, Glare=0.05, Haze=3},
    },
    {
        name        = "Orange",
        dotColor    = Color3.fromRGB(230, 110, 20),
        lighting    = {Brightness=1.5, ClockTime=18.2, 
Ambient=Color3.fromRGB(200,90,20), OutdoorAmbient=Color3.fromRGB(220,110,30), 
FogEnd=9e9, GlobalShadows=true},
        colorCorr   = {Brightness=0.02, Contrast=0.2, Saturation=0.7, 
TintColor=Color3.fromRGB(255,210,140)},
        atmosphere  = {Density=0.4, Color=Color3.fromRGB(255,140,50), 
Decay=Color3.fromRGB(200,80,20), Offset=0.3, Glare=0.3, Haze=4},
    },
    {
        name        = "Emerald",
        dotColor    = Color3.fromRGB(20, 140, 60),
        lighting    = {Brightness=0.3, ClockTime=21, 
Ambient=Color3.fromRGB(8,55,20), OutdoorAmbient=Color3.fromRGB(6,45,15), 
FogEnd=9e9, GlobalShadows=true},
        colorCorr   = {Brightness=-0.12, Contrast=0.3, Saturation=0.7, 
TintColor=Color3.fromRGB(140,255,170)},
        atmosphere  = {Density=0.5, Color=Color3.fromRGB(20,100,40), 
Decay=Color3.fromRGB(10,60,20), Offset=0.2, Glare=0, Haze=2},
    },
    {
        name        = "Cosmic Void",
        dotColor    = Color3.fromRGB(8, 8, 14),
        lighting    = {Brightness=0.0, ClockTime=0, Ambient=Color3.fromRGB(2,2,4), 
OutdoorAmbient=Color3.fromRGB(1,1,2), FogEnd=9e9, GlobalShadows=false},
        colorCorr   = {Brightness=-0.2, Contrast=0.5, Saturation=-1.0, 
TintColor=Color3.fromRGB(200,200,255)},
        atmosphere  = {Density=0.05, Color=Color3.fromRGB(5,5,10), 
Decay=Color3.fromRGB(2,2,5), Offset=0, Glare=0, Haze=0},
    },
    {
        name        = "Molten Core",
        dotColor    = Color3.fromRGB(200, 80, 10),
        lighting    = {Brightness=0.8, ClockTime=20.5, 
Ambient=Color3.fromRGB(120,45,8), OutdoorAmbient=Color3.fromRGB(100,35,5), 
FogEnd=9e9, GlobalShadows=true},
        colorCorr   = {Brightness=0.0, Contrast=0.4, Saturation=0.9, 
TintColor=Color3.fromRGB(255,180,100)},
        atmosphere  = {Density=0.55, Color=Color3.fromRGB(200,70,15), 
Decay=Color3.fromRGB(150,40,5), Offset=0.35, Glare=0.1, Haze=5},
    },
    {
        name        = "Cyber Neon",
        dotColor    = Color3.fromRGB(60, 60, 180),
        lighting    = {Brightness=0.5, ClockTime=21.5, 
Ambient=Color3.fromRGB(20,20,80), OutdoorAmbient=Color3.fromRGB(15,15,70), 
FogEnd=9e9, GlobalShadows=true},
        colorCorr   = {Brightness=-0.05, Contrast=0.3, Saturation=0.8, 
TintColor=Color3.fromRGB(160,160,255)},
        atmosphere  = {Density=0.3, Color=Color3.fromRGB(50,50,200), 
Decay=Color3.fromRGB(20,20,140), Offset=0.1, Glare=0.15, Haze=1.5},
    },
}
local function saveOriginalLighting()
    if _skyOriginals then return end
    local L = game:GetService("Lighting")
    _skyOriginals = {
        Brightness     = L.Brightness,
        Ambient        = L.Ambient,
        OutdoorAmbient = L.OutdoorAmbient,
        TimeOfDay      = L.TimeOfDay,
        ClockTime      = L.ClockTime,
        FogEnd         = L.FogEnd,
        GlobalShadows  = L.GlobalShadows,
    }
end
local function clearAllSkyEffects()
    local L = game:GetService("Lighting")
    for _, v in pairs(L:GetChildren()) do
        if v:IsA("Sky")
        or v:IsA("Atmosphere")
        or v:IsA("ColorCorrectionEffect")
        or v:IsA("BloomEffect")
        or v:IsA("BlurEffect")
        or v:IsA("SunRaysEffect")
        then
            v:Destroy()
        end
    end
end
local function applySky(idx)
    idx = math.clamp(idx or 1, 1, #SKY_THEMES)
    skyColorIndex = idx
    local theme = SKY_THEMES[idx]
    pcall(function()
        local L = game:GetService("Lighting")
        saveOriginalLighting()
        clearAllSkyEffects()
        local lt = theme.lighting
        L.Brightness     = lt.Brightness
        L.ClockTime      = lt.ClockTime
        L.Ambient        = lt.Ambient
        L.OutdoorAmbient = lt.OutdoorAmbient
        L.FogEnd         = lt.FogEnd
        L.GlobalShadows  = lt.GlobalShadows
        local cc = Instance.new("ColorCorrectionEffect", L)
        cc.Name       = "NovaSkyCC"
        cc.Brightness = theme.colorCorr.Brightness
        cc.Contrast   = theme.colorCorr.Contrast
        cc.Saturation = theme.colorCorr.Saturation
        cc.TintColor  = theme.colorCorr.TintColor
        local atm = Instance.new("Atmosphere", L)
        atm.Name    = "NovaSkyAtm"
        atm.Density = theme.atmosphere.Density
        atm.Color   = theme.atmosphere.Color
        atm.Decay   = theme.atmosphere.Decay
        atm.Offset  = theme.atmosphere.Offset
        atm.Glare   = theme.atmosphere.Glare
        atm.Haze    = theme.atmosphere.Haze
    end)
end
local function enableSky(idx)
    skyEnabled = true
    applySky(idx or skyColorIndex)
    SetSetting("skyEnabled",      skyEnabled)
    SetSetting("skyColorIndex",   skyColorIndex)
end
local function disableSky()
    skyEnabled = false
    pcall(function()
        local L = game:GetService("Lighting")
        clearAllSkyEffects()
        if _skyOriginals then
            L.Brightness     = _skyOriginals.Brightness
            L.Ambient        = _skyOriginals.Ambient
            L.OutdoorAmbient = _skyOriginals.OutdoorAmbient
            L.TimeOfDay      = _skyOriginals.TimeOfDay
            L.ClockTime      = _skyOriginals.ClockTime
            L.FogEnd         = _skyOriginals.FogEnd
            L.GlobalShadows  = _skyOriginals.GlobalShadows
        end
    end)
    SetSetting("skyEnabled", false)
end
if skyEnabled then
    task.spawn(function() task.wait(0.15); enableSky(skyColorIndex) end)
end-- ═══════════════════════════════════════════════--   DESYNC-- ═══════════════════════════════════════════════
local function applyDesync(on)
    desyncEnabled = on
    pcall(function()
        if on then
            raknet.desync(true)
            local char = LP.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.Health 
= 0 end
        else raknet.desync(false) end
    end)
end
local function enableDesync()  applyDesync(true)  end
local function disableDesync() applyDesync(false) end
LP.CharacterAdded:Connect(function()
    if desyncEnabled then task.wait(0.5); pcall(function() raknet.desync(true) 
end) end
end)
if desyncEnabled then task.spawn(function() applyDesync(true) end) end-- ═══════════════════════════════════════════════--   AUTO STEAL-- ═══════════════════════════════════════════════
local function isMyBase(plotName)
    local plots = workspace:FindFirstChild("Plots"); if not plots then return 
false end
    local plot = plots:FindFirstChild(plotName); if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign"); if not sign then return false 
end
    local yb = sign:FindFirstChild("YourBase"); return yb and 
yb:IsA("BillboardGui") and yb.Enabled == true
end
local function scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end; if isMyBase(plot.Name) 
then return end
    local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then return end
    for _, pod in ipairs(pods:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            local uid = plot.Name.."_"..pod.Name; local exists = false
            for _, a in ipairs(Steal.animalCache) do if a.uid == uid then exists = 
true; break end end
            if not exists then table.insert(Steal.animalCache, 
{plot=plot.Name,slot=pod.Name,worldPosition=pod:GetPivot().Position,uid=uid}) end
        end
    end
end
local function findPromptForAnimal(ad)
    if not ad then return nil end; local cp = Steal.promptCache[ad.uid]; if cp and 
cp.Parent then return cp end
    local plots = workspace:FindFirstChild("Plots"); if not plots then return nil 
end
    local plot = plots:FindFirstChild(ad.plot); if not plot then return nil end
    local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then return nil 
end
    local pod = pods:FindFirstChild(ad.slot); if not pod then return nil end
    local base = pod:FindFirstChild("Base"); if not base then return nil end
    local sp = base:FindFirstChild("Spawn"); if not sp then return nil end
    local att = sp:FindFirstChild("PromptAttachment"); if not att then return nil 
end
    for _, p in ipairs(att:GetChildren()) do if p:IsA("ProximityPrompt") then 
Steal.promptCache[ad.uid] = p; return p end end
end
local function buildCallbacks(prompt)
    if Steal.Data[prompt] then return end; local data = {hold={},trigger=
{},ready=true}
    pcall(function() if getconnections then for _,c in 
ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if 
type(c.Function)=="function" then table.insert(data.hold,c.Function) end end; for 
_,c in ipairs(getconnections(prompt.Triggered)) do if type(c.Function)=="function" 
then table.insert(data.trigger,c.Function) end end end end)
    if #data.hold > 0 or #data.trigger > 0 then Steal.Data[prompt] = data end
end
local function execSteal(prompt)
    local data = Steal.Data[prompt]; if not data or not data.ready then return 
false end
    data.ready = false; isStealing = true; stealStart = tick()
    if progressConn then progressConn:Disconnect() end
    progressConn = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConn:Disconnect(); return end
        local prog = math.clamp((tick()-stealStart)/Steal.StealDuration,0,1)
        if IvyStealFill then IvyStealFill.Size = UDim2.new(1,0,prog,0) end
        if IvyStealPct  then IvyStealPct.Text  = math.floor(prog*100).."%"  end
    end)
    task.spawn(function()
        for _,f in ipairs(data.hold)    do task.spawn(f) end; 
task.wait(Steal.StealDuration)
        for _,f in ipairs(data.trigger) do task.spawn(f) end
        if progressConn then progressConn:Disconnect() end
        if IvyStealPct  then IvyStealPct.Text  = "0%" end
        if IvyStealFill then IvyStealFill.Size  = UDim2.new(1,0,0,0) end
        data.ready = true; isStealing = false
    end)
    return true
end
local function nearestAnimal()
    local h = getHRP(); if not h then return nil end; local best, bd = nil, 
math.huge
    for _,ad in ipairs(Steal.animalCache) do if not isMyBase(ad.plot) and 
ad.worldPosition then local d=(h.Position-ad.worldPosition).Magnitude; if d<bd 
then bd=d; best=ad end end end
    return best
end
local isStealing = false; local stealStart = nil; local autoStealConn = nil; local 
progressConn = nil
local function startAutoSteal()
    if autoStealConn then return end
    autoStealConn = RunService.Heartbeat:Connect(function()
        if not Steal.AutoStealEnabled or isStealing then return end
        local target = nearestAnimal(); if not target then return end
        local h = getHRP(); if not h then return end
        if (h.Position-target.worldPosition).Magnitude > Steal.StealRadius then 
return end
        local prompt = Steal.promptCache[target.uid]; if not prompt or not 
prompt.Parent then prompt = findPromptForAnimal(target) end
        if prompt then buildCallbacks(prompt); execSteal(prompt) end
    end)
end
local function stopAutoSteal()
    if autoStealConn then autoStealConn:Disconnect(); autoStealConn = nil end; 
isStealing = false
    if progressConn  then progressConn:Disconnect();  progressConn  = nil end
    if IvyStealFill  then IvyStealFill.Size = UDim2.new(1,0,0,0) end
    if IvyStealPct   then IvyStealPct.Text  = "0%" end
end
task.spawn(function()
    task.wait(2); local plots = workspace:WaitForChild("Plots",10); if not plots 
then return end
    for _,plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then 
scanPlot(plot) end end
    plots.ChildAdded:Connect(function(plot) if plot:IsA("Model") then 
task.wait(0.5); scanPlot(plot) end end)
    task.spawn(function() while task.wait(5) do Steal.animalCache={}; for _,plot 
in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end 
end end)
    Steal.AutoStealEnabled = true; pcall(startAutoSteal)
end)-- Ivy Lagger
local function ivyBomb(ti, tries)
    local mt={}; local st={}; table.insert(st,{}); local z=st[1]
    for i=1,ti do local ti2={}; table.insert(z,ti2); z=ti2 end
    local maximum=(499999/(ti+2)) or 9999999
    for i=1,maximum do table.insert(mt,st) end
    for i=1,tries do pcall(function() 
game.RobloxReplicatedStorage.SetPlayerBlockList:FireServer(mt) end) end
end
local function startIvyLaggerLoop()
    while ivyLaggerEnabled do
        pcall(function() 
game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge) end)
        ivyBomb(IVY_LAGGER_CONFIG.TableIncrease, IVY_LAGGER_CONFIG.Tries)
        task.wait(IVY_LAGGER_CONFIG.LoopWaitTime)
    end
end-- ═══════════════════════════════════════════════════════════════--   TP DOWN FEATURE – FOLK HUB STYLE--   Teleports the player straight down to the ground below-- ═══════════════════════════════════════════════════════════════
local function tpDown()
    local hrp = getHRP()
    if not hrp then return end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LP.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(hrp.Position, Vector3.new(0, -5000, 0), 
rayParams)
    if result then
        hrp.CFrame = CFrame.new(
            hrp.Position.X,
            result.Position.Y + hrp.Size.Y / 2 + 0.1,
            hrp.Position.Z
        )
    end
end-- ═══════════════════════════════════════════════--   AUTO TP DOWN--   Every 0.1 s: if player is above autoTPY → TP to ground.--   Uses same save keys autoTPEnabled / autoTPY already in config.--   Does NOT conflict with manual tpDown() keybind.-- ═══════════════════════════════════════════════
local _autoTPConn   = nil
local _autoTPActive = false
local function startAutoTP()
    if _autoTPConn then task.cancel(_autoTPConn); _autoTPConn = nil end
    _autoTPActive = true
    _autoTPConn = task.spawn(function()
        while _autoTPActive do
            task.wait(0.1)
            if not _autoTPActive then break end
            -- Do not interfere with auto-movement sequences
            if not aplOn and not aprOn then
                local hrp = getHRP()
                if hrp and hrp.Position.Y > autoTPY then
                    -- Raycast to ground so landing is clean
                    local rp = RaycastParams.new()
                    rp.FilterDescendantsInstances = {LP.Character}
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    local result = workspace:Raycast(hrp.Position, Vector3.new(0, -5000, 0), rp)
                    if result then
                        hrp.CFrame = CFrame.new(
                            hrp.Position.X,
                            result.Position.Y + hrp.Size.Y / 2 + 0.1,
                            hrp.Position.Z
                        )
                    end
                end
            end
        end
    end)
end
local function stopAutoTP()
    _autoTPActive = false
    if _autoTPConn then task.cancel(_autoTPConn); _autoTPConn = nil end
end-- Restore from saved config on load
if autoTPEnabled then task.spawn(startAutoTP) end-- ═══════════════════════════════════════════════--   WAYPOINT ESP-- ═══════════════════════════════════════════════
local waypointMarker = nil
local waypointConn   = nil
local function getWaypointTarget()
    if aplOn then
        if alPhase == 1 then return AP_L1 end
        if alPhase == 2 then return AP_L2 end
    end
    if aprOn then
        if arPhase == 1 then return AP_R1 end
        if arPhase == 2 then return AP_R2 end
    end
    return nil
end
local function createWaypointMarker()
    if waypointMarker then return end
    local marker = Instance.new("Part")
    marker.Name = "NovaWaypoint"; marker.Size = Vector3.new(2.5,2.5,2.5)
    marker.Shape = Enum.PartType.Ball; marker.Anchored = true; marker.CanCollide = 
false
    marker.CastShadow = false; marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(255,220,50); marker.Transparency = 0.15; 
marker.Parent = workspace
    local bb = Instance.new("BillboardGui", marker)
    bb.Size = UDim2.new(0,90,0,22); bb.StudsOffset = Vector3.new(0,2.8,0); 
bb.AlwaysOnTop = true; bb.Adornee = marker
    local label = Instance.new("TextLabel", bb)
    label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1; label.Text 
= "WAYPOINT"
    label.TextColor3 = Color3.fromRGB(255,255,255); label.TextStrokeColor3 = 
Color3.fromRGB(0,0,0)
    label.TextStrokeTransparency = 0.4; label.Font = Enum.Font.GothamBold; 
label.TextSize = 13; label.TextScaled = true
    waypointMarker = marker
end
local function removeWaypointMarker()
    if waypointMarker then pcall(function() waypointMarker:Destroy() end); 
waypointMarker = nil end
end
local function startWaypointESP()
    if waypointConn then waypointConn:Disconnect() end
    createWaypointMarker()
    waypointConn = RunService.Heartbeat:Connect(function()
        if not waypointESPEnabled then removeWaypointMarker(); if waypointConn 
then waypointConn:Disconnect(); waypointConn = nil end; return end
        local target = getWaypointTarget()
        if target then
            if not waypointMarker then createWaypointMarker() end
            waypointMarker.Position = target; waypointMarker.Transparency = 0.15
        else
            if waypointMarker then waypointMarker.Transparency = 1 end
        end
    end)
end
local function stopWaypointESP()
    waypointESPEnabled = false; if waypointConn then waypointConn:Disconnect(); 
waypointConn = nil end; removeWaypointMarker()
end
if waypointESPEnabled then task.spawn(startWaypointESP) end-- ═══════════════════════════════════════════════════════--   G U I   B U I L D-- ═══════════════════════════════════════════════════════
local function buildGui()
    for _, n in pairs({"IvyHubGUI","MurderHubGUI","IvyHub","NovaHubGUI"}) do
        local cg = game:GetService("CoreGui"); local old = cg:FindFirstChild(n); 
if old then old:Destroy() end
        local pg2 = LP:FindFirstChild("PlayerGui"); if pg2 then local o = 
pg2:FindFirstChild(n); if o then o:Destroy() end end
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaHubGUI"; gui.ResetOnSpawn = false; gui.DisplayOrder = 10
    gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then 
gui.Parent = LP:WaitForChild("PlayerGui") end
    local function makeDraggable(frame)
        local dragging, dragStart, startPos = false, nil, nil
        frame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or 
inp.UserInputType == Enum.UserInputType.Touch then
frame.Position
                dragging = true; dragStart = inp.Position; startPos = 
                inp.Changed:Connect(function() if inp.UserInputState == 
Enum.UserInputState.End then dragging = false end end)
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement 
or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, 
startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(inp) if inp.UserInputType == 
Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch 
then dragging = false end end)
    end
    local W = 440; local H = 370
    local main = Instance.new("Frame", gui)
    main.Name = "MainWindow"; main.Size = UDim2.new(0,W,0,H); main.Position = 
UDim2.new(0.5,-W/2,0.5,-H/2)
    main.BackgroundColor3 = C_BG; main.BorderSizePixel = 0; main.Active = true; 
main.ClipsDescendants = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)
    local mainStroke = Instance.new("UIStroke", main); mainStroke.Color = 
C_BORDER; mainStroke.Thickness = 1
    makeDraggable(main)
    local TOPBAR_H = 28
    local topbar = Instance.new("Frame", main)
    topbar.Size = UDim2.new(1,0,0,TOPBAR_H); topbar.BackgroundColor3 = C_TOPBAR; 
topbar.BorderSizePixel = 0; topbar.ZIndex = 10
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0,8)
    local tpatch = Instance.new("Frame", topbar)
    tpatch.Size = UDim2.new(1,0,0,8); tpatch.Position = UDim2.new(0,0,1,-8); 
tpatch.BackgroundColor3 = C_TOPBAR; tpatch.BorderSizePixel = 0; tpatch.ZIndex = 9
    local topDiv = Instance.new("Frame", topbar)
    topDiv.Size = UDim2.new(1,0,0,1); topDiv.Position = UDim2.new(0,0,1,-1); 
topDiv.BackgroundColor3 = C_BORDER; topDiv.BorderSizePixel = 0; topDiv.ZIndex = 11
    local titleTxt = Instance.new("TextLabel", topbar)
    titleTxt.Size = UDim2.new(0,80,1,0); titleTxt.Position = UDim2.new(0,8,0,0)
    titleTxt.BackgroundTransparency = 1; titleTxt.Text = "NOVA HUB"; 
titleTxt.TextColor3 = C_WHITE
    titleTxt.Font = Enum.Font.GothamBlack; titleTxt.TextSize = 10; 
titleTxt.TextXAlignment = Enum.TextXAlignment.Left; titleTxt.ZIndex = 12
    local discordTxt = Instance.new("TextLabel", topbar)
    discordTxt.Size = UDim2.new(0,140,1,0); discordTxt.Position = 
UDim2.new(0,90,0,0)
    discordTxt.BackgroundTransparency = 1; discordTxt.Text = "discord.gg/novahub"; 
discordTxt.TextColor3 = C_DIM
    discordTxt.Font = Enum.Font.Gotham; discordTxt.TextSize = 7; 
discordTxt.TextXAlignment = Enum.TextXAlignment.Left; discordTxt.ZIndex = 12
    local guiVisible = true
    -- Toggle button
    local mini = Instance.new("Frame", gui)
    mini.Name = "NovaToggleBtn"; mini.Size = UDim2.new(0,90,0,28)
    mini.AnchorPoint = Vector2.new(0,0); mini.Position = UDim2.new(0,8,0,48)
    mini.BackgroundColor3 = Color3.fromRGB(5,5,8); mini.BackgroundTransparency = 
0.05
    mini.BorderSizePixel = 0; mini.ZIndex = 60; mini.Visible = true
    Instance.new("UICorner", mini).CornerRadius = UDim.new(0,10)
    local miniStroke = Instance.new("UIStroke", mini); miniStroke.Color = 
Color3.fromRGB(55,55,65); miniStroke.Thickness = 1.1
    local miniTrack = Instance.new("Frame", mini)
    miniTrack.Size = UDim2.new(1,-12,0,3); miniTrack.Position = 
UDim2.new(0,6,1,-6)
    miniTrack.BackgroundColor3 = Color3.fromRGB(18,18,22); 
miniTrack.BorderSizePixel = 0; miniTrack.ZIndex = 61
    Instance.new("UICorner", miniTrack).CornerRadius = UDim.new(1,0)
    local miniBar = Instance.new("Frame", miniTrack)
    miniBar.Size = UDim2.new(1,0,1,0); miniBar.BackgroundColor3 = 
Color3.fromRGB(210,210,220); miniBar.BorderSizePixel = 0; miniBar.ZIndex = 62
    Instance.new("UICorner", miniBar).CornerRadius = UDim.new(1,0)
    local miniLbl = Instance.new("TextLabel", mini)
    miniLbl.Size = UDim2.new(1,0,1,-8); miniLbl.Position = UDim2.new(0,0,0,0)
    miniLbl.BackgroundTransparency = 1; miniLbl.Text = "Nova Hub"; 
miniLbl.TextColor3 = Color3.fromRGB(200,200,210)
    miniLbl.Font = Enum.Font.GothamBlack; miniLbl.TextSize = 9
    miniLbl.TextXAlignment = Enum.TextXAlignment.Center; miniLbl.TextYAlignment = 
Enum.TextYAlignment.Center; miniLbl.ZIndex = 63
    local miniBtn = Instance.new("TextButton", mini)
    miniBtn.Size = UDim2.new(1,0,1,0); miniBtn.BackgroundTransparency = 1; 
miniBtn.Text = ""; miniBtn.ZIndex = 64; miniBtn.AutoButtonColor = false
    miniBtn.MouseButton1Down:Connect(function() TS:Create(mini, 
TweenInfo.new(0.06), {BackgroundColor3 = Color3.fromRGB(25,25,30)}):Play() end)
    miniBtn.MouseButton1Up:Connect(function() TS:Create(mini, TweenInfo.new(0.12), 
{BackgroundColor3 = Color3.fromRGB(5,5,8)}):Play() end)
    local function setBarActive(on)
        TS:Create(miniBar, TweenInfo.new(0.2), {BackgroundColor3 = on and 
Color3.fromRGB(210,210,220) or Color3.fromRGB(60,60,70)}):Play()
    end
    local function showGui() if guiLocked then return end; guiVisible = true; 
main.Visible = true; setBarActive(true) end
    local function hideGui() guiVisible = false; main.Visible = false; 
setBarActive(false) end
    local minBtn = Instance.new("TextButton", topbar)
    minBtn.Size = UDim2.new(0,20,0,20); minBtn.Position = UDim2.new(1,-25,0.5,-10)
    minBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); minBtn.BorderSizePixel = 0
    minBtn.Text = "–"; minBtn.TextColor3 = C_WHITE; minBtn.Font = 
Enum.Font.GothamBlack
    minBtn.TextSize = 12; minBtn.ZIndex = 13
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,4)
    local minBtnStroke = Instance.new("UIStroke", minBtn); minBtnStroke.Color = 
C_BORDER2; minBtnStroke.Thickness = 1
    minBtn.MouseButton1Click:Connect(hideGui)
    miniBtn.MouseButton1Click:Connect(function() if guiVisible then hideGui() else 
showGui() end end)
    minBtn.MouseEnter:Connect(function() TS:Create(minBtn, TweenInfo.new(0.1), 
{BackgroundColor3 = Color3.fromRGB(50,50,50)}):Play() end)
    minBtn.MouseLeave:Connect(function() TS:Create(minBtn, TweenInfo.new(0.1), 
{BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play() end)
    -- Image column
    local IMG_COL_W = 120
    local imgCol = Instance.new("Frame", main)
    imgCol.Size = UDim2.new(0,IMG_COL_W,1,-TOPBAR_H); imgCol.Position = 
UDim2.new(0,0,0,TOPBAR_H)
    imgCol.BackgroundColor3 = C_IMG_COL; imgCol.BorderSizePixel = 0; imgCol.ZIndex 
= 2; imgCol.ClipsDescendants = true
    local icPatch = Instance.new("Frame", main)
    icPatch.Size = UDim2.new(0,IMG_COL_W,0,8); icPatch.Position = 
UDim2.new(0,0,0,TOPBAR_H)
    icPatch.BackgroundColor3 = C_IMG_COL; icPatch.BorderSizePixel = 0; 
icPatch.ZIndex = 1
    local icDiv = Instance.new("Frame", imgCol)
    icDiv.Size = UDim2.new(0,1,1,0); icDiv.Position = UDim2.new(1,-1,0,0); 
icDiv.BackgroundColor3 = C_BORDER; icDiv.BorderSizePixel = 0; icDiv.ZIndex = 3
    local logoImg = Instance.new("ImageLabel", imgCol)
    logoImg.Size = UDim2.new(1,0,1,0); logoImg.BackgroundTransparency = 1
    logoImg.Image = "rbxassetid://127345515727556"; logoImg.ScaleType = 
Enum.ScaleType.Crop; logoImg.ZIndex = 4
    local brandName = Instance.new("TextLabel", imgCol)
    brandName.Size = UDim2.new(1,-8,0,14); brandName.Position = 
UDim2.new(0,6,1,-38)
    brandName.BackgroundTransparency = 1; brandName.Text = "NOVA HUB"; 
brandName.TextColor3 = C_WHITE
    brandName.Font = Enum.Font.GothamBlack; brandName.TextSize = 9; 
brandName.TextXAlignment = Enum.TextXAlignment.Left; brandName.ZIndex = 5
    local underline = Instance.new("Frame", imgCol)
    underline.Size = UDim2.new(0,50,0,1); underline.Position = 
UDim2.new(0,6,1,-22)
    underline.BackgroundColor3 = C_WHITE; underline.BorderSizePixel = 0; 
underline.ZIndex = 5
    local brandDisc = Instance.new("TextLabel", imgCol)
    brandDisc.Size = UDim2.new(1,-8,0,10); brandDisc.Position = 
UDim2.new(0,6,1,-16)
    brandDisc.BackgroundTransparency = 1; brandDisc.Text = "discord.gg/novahub"; 
brandDisc.TextColor3 = C_DIM
    brandDisc.Font = Enum.Font.Gotham; brandDisc.TextSize = 6; 
brandDisc.TextXAlignment = Enum.TextXAlignment.Left; brandDisc.ZIndex = 5
    -- Tab column
    local TAB_COL_W = 65
    local tabCol = Instance.new("Frame", main)
    tabCol.Size = UDim2.new(0,TAB_COL_W,1,-TOPBAR_H); tabCol.Position = 
UDim2.new(0,IMG_COL_W,0,TOPBAR_H)
    tabCol.BackgroundColor3 = C_BG; tabCol.BorderSizePixel = 0; tabCol.ZIndex = 2
    local tcPatch = Instance.new("Frame", main)
    tcPatch.Size = UDim2.new(0,TAB_COL_W,0,8); tcPatch.Position = 
UDim2.new(0,IMG_COL_W,0,TOPBAR_H)
    tcPatch.BackgroundColor3 = C_BG; tcPatch.BorderSizePixel = 0; tcPatch.ZIndex = 
1
    local tcDiv = Instance.new("Frame", tabCol)
    tcDiv.Size = UDim2.new(0,1,1,0); tcDiv.Position = UDim2.new(1,-1,0,0); 
tcDiv.BackgroundColor3 = C_BORDER; tcDiv.BorderSizePixel = 0; tcDiv.ZIndex = 3
    local tabList = Instance.new("Frame", tabCol)
    tabList.Size = UDim2.new(1,0,1,0); tabList.BackgroundTransparency = 1; 
tabList.ZIndex = 4
    local tabLL = Instance.new("UIListLayout", tabList); tabLL.SortOrder = 
Enum.SortOrder.LayoutOrder; tabLL.Padding = UDim.new(0,2)
    local tabPad = Instance.new("UIPadding", tabList)
    tabPad.PaddingTop = UDim.new(0,5); tabPad.PaddingLeft = UDim.new(0,3); 
tabPad.PaddingRight = UDim.new(0,3)
    -- Content
    local contentX = IMG_COL_W + TAB_COL_W
    local content = Instance.new("ScrollingFrame", main)
    content.Name = "Content"; content.Size = UDim2.new(0,W-contentX,1,-TOPBAR_H)
    content.Position = UDim2.new(0,contentX,0,TOPBAR_H); content.BackgroundColor3 
= C_BG
2
    content.BorderSizePixel = 0; content.ClipsDescendants = true; content.ZIndex = 
    content.ScrollBarThickness = 2; content.ScrollBarImageColor3 = C_BORDER
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y; content.CanvasSize = 
UDim2.new(0,0,0,0)
    -- Tabs
    local tabDefs = {"Speed","Bat","Mech","Move","Settings"}
    local tabs = {}; local tabPages = {}; local activeTabName = nil; local pageLOs 
= {}
    local function switchTab(name)
        activeTabName = name
        for _, td in ipairs(tabDefs) do
            local t = tabs[td]; local isA = (td == name)
            TS:Create(t.frame, TweenInfo.new(0.14), {BackgroundColor3 = isA and 
C_TAB_ACTIVE or C_TAB_IDLE}):Play()
            TS:Create(t.lbl,   TweenInfo.new(0.14), {TextColor3      = isA and 
C_TAB_ACT_T  or C_TAB_IDLE_T}):Play()
            tabPages[td].Visible = isA
        end
    end
    for i, name in ipairs(tabDefs) do
        local btn = Instance.new("TextButton", tabList)
        btn.Size = UDim2.new(1,0,0,24); btn.BackgroundColor3 = C_TAB_IDLE
        btn.BorderSizePixel = 0; btn.Text = ""; btn.LayoutOrder = i; btn.ZIndex = 
5; btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.Text = 
name
        lbl.TextColor3 = C_TAB_IDLE_T; lbl.Font = Enum.Font.GothamBold; 
lbl.TextSize = 7; lbl.TextWrapped = true; lbl.ZIndex = 6
        tabs[name] = {frame = btn, lbl = lbl}
        local page = Instance.new("Frame", content)
        page.Size = UDim2.new(1,0,0,0); page.BackgroundTransparency = 1; 
page.BorderSizePixel = 0
        page.Visible = false; page.ZIndex = 3; page.AutomaticSize = 
Enum.AutomaticSize.Y
        local pll = Instance.new("UIListLayout", page); pll.SortOrder = 
Enum.SortOrder.LayoutOrder; pll.Padding = UDim.new(0,2)
        local pp = Instance.new("UIPadding", page)
        pp.PaddingLeft = UDim.new(0,5); pp.PaddingRight = UDim.new(0,5); 
pp.PaddingTop = UDim.new(0,5); pp.PaddingBottom = UDim.new(0,40)
        tabPages[name] = page; pageLOs[name] = 0
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        btn.MouseEnter:Connect(function() if activeTabName ~= name then 
TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C_CARD_HOV}):Play() end 
end)
        btn.MouseLeave:Connect(function() if activeTabName ~= name then 
TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C_TAB_IDLE}):Play() end 
end)
    end
    local function lo(t) pageLOs[t] = pageLOs[t] + 1; return pageLOs[t] end
    local function pg(t) return tabPages[t] end
    local function mkSection(tabName, text)
        local f = Instance.new("Frame", pg(tabName)); f.Size = 
UDim2.new(1,0,0,12); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; 
f.LayoutOrder = lo(tabName)
        local lbl = Instance.new("TextLabel", f); lbl.Size = UDim2.new(1,0,1,0); 
lbl.BackgroundTransparency = 1; lbl.Text = text:upper(); lbl.TextColor3 = 
C_HEADER_TXT; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 6; 
lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4
    end
    local function mkCard(tabName, h)
        local c = Instance.new("Frame", tabName and pg(tabName) or nil)
        c.Size = UDim2.new(1,0,0,h or 24); c.BackgroundColor3 = C_CARD; 
c.BorderSizePixel = 0
        if tabName then c.LayoutOrder = lo(tabName) end; c.ZIndex = 4
        Instance.new("UICorner", c).CornerRadius = UDim.new(0,4)
        local s = Instance.new("UIStroke", c); s.Color = C_BORDER; s.Thickness = 1
        c.MouseEnter:Connect(function() TS:Create(c, TweenInfo.new(0.1), 
{BackgroundColor3 = C_CARD_HOV}):Play() end)
        c.MouseLeave:Connect(function() TS:Create(c, TweenInfo.new(0.1), 
{BackgroundColor3 = C_CARD}):Play() end)
        return c
    end
    local function mkPill(parent, defOn, onToggle)
        local PW, PH = 32, 14
        local pbg = Instance.new("Frame", parent); pbg.Size = 
UDim2.new(0,PW,0,PH); pbg.Position = UDim2.new(1,-(PW+5),0.5,-PH/2); 
pbg.BackgroundColor3 = defOn and C_PILL_ON or C_PILL_OFF; pbg.BorderSizePixel = 0; 
pbg.ZIndex = 8
        Instance.new("UICorner", pbg).CornerRadius = UDim.new(0,7)
        local dot = Instance.new("Frame", pbg); dot.Size = UDim2.new(0,8,0,8); 
dot.Position = defOn and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4); 
dot.BackgroundColor3 = defOn and Color3.fromRGB(20,20,20) or C_WHITE; 
dot.BorderSizePixel = 0; dot.ZIndex = 9
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
        local isOn = defOn or false
        local function setV(on)
            isOn = on
            TS:Create(pbg, TweenInfo.new(0.18), {BackgroundColor3 = on and 
C_PILL_ON or C_PILL_OFF}):Play()
            TS:Create(dot, TweenInfo.new(0.18,Enum.EasingStyle.Back), {Position = 
on and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4), BackgroundColor3 = on and 
Color3.fromRGB(20,20,20) or C_WHITE}):Play()
        end
        local clk = Instance.new("TextButton", parent); clk.Size = 
UDim2.new(1,0,1,0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 6
        clk.MouseButton1Click:Connect(function() if _anyKeyListening then return 
end; isOn = not isOn; setV(isOn); if onToggle then pcall(onToggle, isOn) end end)
        return setV
    end
    local function mkKB(parent, kbEntry, onChange)
        local b = Instance.new("TextButton", parent); b.Size = 
UDim2.new(0,38,0,16); b.BackgroundColor3 = C_KB_BG; b.BorderSizePixel = 0
        b.Text = (kbEntry.kb or Enum.KeyCode.Unknown).Name; b.TextColor3 = C_DIM; 
b.Font = Enum.Font.GothamBold; b.TextSize = 6; b.ZIndex = 11
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,3)
        local bs = Instance.new("UIStroke", b); bs.Color = C_BORDER2; bs.Thickness 
= 1
        local li = false; local lc; local pv = b.Text
        b.MouseButton1Click:Connect(function()
            if li then li=false; _anyKeyListening=false; if lc then 
lc:Disconnect(); lc=nil end; b.Text=pv; return end
            pv=b.Text; li=true; _anyKeyListening=true; b.Text="···"; TS:Create(bs, 
TweenInfo.new(0.1), {Color=C_WHITE}):Play()
            lc = UIS.InputBegan:Connect(function(inp)
                if not li then return end
                local isKB2=inp.UserInputType==Enum.UserInputType.Keyboard; local 
isGP2=inp.UserInputType==Enum.UserInputType.Gamepad1
                if not isKB2 and not isGP2 then return end
                if inp.KeyCode==Enum.KeyCode.Escape then li=false; 
_anyKeyListening=false; if lc then lc:Disconnect(); lc=nil end; b.Text=pv; 
TS:Create(bs,TweenInfo.new(0.1),{Color=C_BORDER2}):Play(); return end
                if isGP2 then kbEntry.gp=inp.KeyCode; b.Text="GP"
                else kbEntry.gp=nil; kbEntry.kb=inp.KeyCode; 
b.Text=inp.KeyCode.Name; pv=inp.KeyCode.Name; if onChange then 
onChange(inp.KeyCode) end end
                li=false; _anyKeyListening=false; if lc then lc:Disconnect(); 
lc=nil end; TS:Create(bs,TweenInfo.new(0.1),{Color=C_BORDER2}):Play()
            end)
        end)
        return b
    end
    local function mkInput(tabName, label, sub, default, onChange)
        local c = mkCard(tabName, sub and 28 or 24)
        local lbl = Instance.new("TextLabel", c); lbl.Size = 
UDim2.new(0.55,0,1,0); lbl.Position = UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = 
C_WHITE; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 8; lbl.TextXAlignment = 
Enum.TextXAlignment.Left; lbl.ZIndex = 10
        local valLbl = Instance.new("TextLabel", c); valLbl.Size = 
UDim2.new(0,42,1,0); valLbl.Position = UDim2.new(1,-46,0,0)
        valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(default); 
valLbl.TextColor3 = C_DIM; valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 
8; valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 10
        local box = Instance.new("TextBox", c); box.Size = UDim2.new(0,42,0,16); 
box.Position = UDim2.new(1,-46,0.5,-8)
        box.BackgroundColor3 = C_INPUT_BG; box.BorderSizePixel = 0; box.Text = 
tostring(default); box.TextColor3 = C_WHITE
        box.Font = Enum.Font.GothamBold; box.TextSize = 8; box.ClearTextOnFocus = 
false; box.ZIndex = 11; box.Visible = false
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,3)
        local bstr = Instance.new("UIStroke", box); bstr.Color = C_BORDER2
        local clickOverlay = Instance.new("TextButton", c); clickOverlay.Size = 
UDim2.new(1,0,1,0); clickOverlay.BackgroundTransparency = 1; clickOverlay.Text = 
""; clickOverlay.ZIndex = 9
        local lastValid = tonumber(default) or 0
        clickOverlay.MouseButton1Click:Connect(function() valLbl.Visible=false; 
box.Visible=true; box.Text=tostring(lastValid); box:CaptureFocus(); 
TS:Create(bstr,TweenInfo.new(0.1),{Color=C_WHITE}):Play() end)
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local raw=box.Text; local cleaned=raw:match("^%-?%d*%.?%d*") or ""
            if cleaned~=raw then box.Text=cleaned end
            local n=tonumber(cleaned); if n then if onChange then 
pcall(onChange,n) end; valLbl.Text=tostring(n); lastValid=n end
        end)
        box.FocusLost:Connect(function()
            TS:Create(bstr,TweenInfo.new(0.1),{Color=C_BORDER2}):Play(); 
box.Visible=false; valLbl.Visible=true
            local n=tonumber(box.Text); if n then valLbl.Text=tostring(n); 
lastValid=n; if onChange then pcall(onChange,n) end
            else box.Text=tostring(lastValid); valLbl.Text=tostring(lastValid) end
        end)
        return box, valLbl
    end
    local function mkToggle(tabName, label, kbEntry, defOn, onToggle, onKeyChange)
        local c = mkCard(tabName, 24)
        local lbl = Instance.new("TextLabel", c); lbl.BackgroundTransparency = 1; 
lbl.Text = label; lbl.TextColor3 = C_WHITE; lbl.Font = Enum.Font.GothamBold; 
lbl.TextSize = 7; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 10
        if kbEntry then
            lbl.Size = UDim2.new(0.45,0,1,0); lbl.Position = UDim2.new(0,6,0,0)
            local kb = mkKB(c, kbEntry, onKeyChange); kb.Position = UDim2.new(1,
(38+6+32+6),0.5,-8); kb.ZIndex = 11
        else
            lbl.Size = UDim2.new(0.7,0,1,0); lbl.Position = UDim2.new(0,6,0,0)
        end
        return mkPill(c, defOn, onToggle)
    end
    local function mkKBOnly(tabName, label, kbEntry, onChange)
        local c = mkCard(tabName, 24)
        local lbl = Instance.new("TextLabel", c); lbl.Size = UDim2.new(0.6,0,1,0); 
lbl.Position = UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = 
C_WHITE; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 7; lbl.TextXAlignment = 
Enum.TextXAlignment.Left; lbl.ZIndex = 10
        local kb = mkKB(c, kbEntry, onChange); kb.Position = UDim2.new(1,
(38+5),0.5,-8); kb.ZIndex = 11
    end
    -- 
════════════════════════════════════════════════════════════
    --   DROPDOWN BUILDER — CRITICAL FIX
    -
    --   ROOT CAUSE OF THE BUG:
    --   The clickCatcher was parented to `main` with ZIndex=49 and
    --   covered the ENTIRE window. When closeAnyDropdown() was called
    --   from inside the option rowBtn click handler, Roblox processes
    --   the hide on the NEXT frame — but by then the catcher already
    --   consumed the click, leaving activeDropdown=nil while
    --   clickCatcher.Visible remained true. All subsequent clicks on
    --   pills, tabs, and the sky toggle were silently eaten.
    -
    --   FIX APPLIED:
    --   1. clickCatcher is now parented to the ScreenGui (gui), not
    --      main. This prevents it from inheriting the window's ZIndex
    --      stacking context and from clipping to the window bounds.
    --   2. Its ZIndex is set high enough to catch outside-dropdown
    --      clicks, but it is ALWAYS hidden immediately — synchronously
    --      — before the onSelect callback fires. No deferred hide.
    --   3. closeAnyDropdown() unconditionally sets Visible=false
    --      regardless of whether activeDropdown is set, eliminating
    --      the race condition.
    --   4. Dropdown panels are also parented to `gui` (ScreenGui),
    --      not `main`. This means they render above everything with
    --      their own ZIndex and cannot be occluded by content frames,
    --      and more importantly they do NOT contribute to main's
    --      input capture chain.
    -- 
════════════════════════════════════════════════════════════
    -- FIX 1: parent to gui (ScreenGui), not main
    local clickCatcher = Instance.new("TextButton", gui)
    clickCatcher.Name = "DropdownClickCatcher"
    clickCatcher.Size = UDim2.new(1,0,1,0)
    clickCatcher.BackgroundTransparency = 1
    clickCatcher.Text = ""
    clickCatcher.ZIndex = 98          -- high but below dropdown panels (99)
    clickCatcher.AutoButtonColor = false
    clickCatcher.Visible = false      -- starts hidden, ALWAYS
    local activeDropdown = nil
    -- FIX 2: closeAnyDropdown always hides catcher unconditionally
    local function closeAnyDropdown()
        clickCatcher.Visible = false  -- always, no guard
        if activeDropdown then
            activeDropdown.Visible = false
            activeDropdown = nil
        end
    end
    clickCatcher.MouseButton1Click:Connect(closeAnyDropdown)
    local function mkDropdown(tabName, label, options, selectedIndex, onSelect)
        local c = mkCard(tabName, 24); c.ZIndex = 4
        local lbl = Instance.new("TextLabel", c); lbl.Size = 
UDim2.new(0.35,0,1,0); lbl.Position = UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = 
C_WHITE; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 7; lbl.TextXAlignment = 
Enum.TextXAlignment.Left; lbl.ZIndex = 10
        local valLbl = Instance.new("TextLabel", c); valLbl.Size = 
UDim2.new(0,80,0,16); valLbl.Position = UDim2.new(0.35,0,0.5,-8)
        valLbl.BackgroundTransparency = 1; valLbl.Text = options[selectedIndex] 
and options[selectedIndex].name or ""; valLbl.TextColor3 = C_DIM; valLbl.Font = 
Enum.Font.GothamBold; valLbl.TextSize = 7; valLbl.TextXAlignment = 
Enum.TextXAlignment.Left; valLbl.ZIndex = 10
        local arrow = Instance.new("TextLabel", c); arrow.Size = 
UDim2.new(0,12,0,12); arrow.Position = UDim2.new(1,-18,0.5,-6)
        arrow.BackgroundTransparency = 1; arrow.Text = "▼"; arrow.TextColor3 = 
C_DIM; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 6; arrow.ZIndex = 10
        local clk = Instance.new("TextButton", c); clk.Size = UDim2.new(1,0,1,0); 
clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 11
        -- FIX 3: parent dropdown panel to gui (ScreenGui), not main
        local dropFrame = Instance.new("Frame", gui)
        dropFrame.Name = "DropdownPanel"
        dropFrame.BackgroundColor3 = Color3.fromRGB(16,16,16)
        dropFrame.BorderSizePixel = 0
        dropFrame.ClipsDescendants = false
        dropFrame.Visible = false
        dropFrame.ZIndex = 99         -- above clickCatcher (98)
        Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0,5)
        local dropStroke = Instance.new("UIStroke", dropFrame); dropStroke.Color = 
C_BORDER2; dropStroke.Thickness = 1
        local dropPad = Instance.new("UIPadding", dropFrame)
        dropPad.PaddingTop = UDim.new(0,3); dropPad.PaddingBottom = UDim.new(0,3); 
dropPad.PaddingLeft = UDim.new(0,3); dropPad.PaddingRight = UDim.new(0,3)
        local dropLayout = Instance.new("UIListLayout", dropFrame); 
dropLayout.SortOrder = Enum.SortOrder.LayoutOrder; dropLayout.Padding = 
UDim.new(0,1)
        local optionFrames = {}
        local currentSelected = selectedIndex
        local function updateRowVisuals(newIdx)
            currentSelected = newIdx
            for j, of in ipairs(optionFrames) do
                local isSel = (j == newIdx)
                of.bg.BackgroundColor3 = isSel and Color3.fromRGB(35,35,40) or 
Color3.fromRGB(16,16,16)
                of.dotStroke.Color = isSel and C_WHITE or Color3.fromRGB(50,50,50)
                of.dotStroke.Thickness = isSel and 1.5 or 0.5
                of.dotStroke.Transparency = isSel and 0 or 0.5
                of.nameLbl.TextColor3 = isSel and C_WHITE or C_DIM
                of.checkLbl.Text = isSel and "✓" or ""
            end
        end
        for i, opt in ipairs(options) do
            local row = Instance.new("Frame", dropFrame); row.Size = 
UDim2.new(1,0,0,22)
            row.BackgroundColor3 = (i==selectedIndex) and Color3.fromRGB(35,35,40) 
or Color3.fromRGB(16,16,16)
            row.BorderSizePixel = 0; row.LayoutOrder = i; row.ZIndex = 100
            Instance.new("UICorner", row).CornerRadius = UDim.new(0,3)
            local dot = Instance.new("Frame", row); dot.Size = 
UDim2.new(0,10,0,10); dot.Position = UDim2.new(0,6,0.5,-5)
            dot.BackgroundColor3 = opt.color or Color3.fromRGB(150,150,150); 
dot.BorderSizePixel = 0; dot.ZIndex = 101
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
            local dotRing = Instance.new("UIStroke", dot)
            dotRing.Color = (i==selectedIndex) and C_WHITE or 
Color3.fromRGB(50,50,50)
            dotRing.Thickness = (i==selectedIndex) and 1.5 or 0.5
            dotRing.Transparency = (i==selectedIndex) and 0 or 0.5
            local nameLbl = Instance.new("TextLabel", row); nameLbl.Size = 
UDim2.new(1,-28,1,0); nameLbl.Position = UDim2.new(0,22,0,0)
            nameLbl.BackgroundTransparency = 1; nameLbl.Text = opt.name
            nameLbl.TextColor3 = (i==selectedIndex) and C_WHITE or C_DIM
            nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 7; 
nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 101
            local check = Instance.new("TextLabel", row); check.Size = 
UDim2.new(0,14,0,14); check.Position = UDim2.new(1,-18,0.5,-7)
            check.BackgroundTransparency = 1; check.Text = (i==selectedIndex) and 
"✓" or ""
            check.TextColor3 = C_WHITE; check.Font = Enum.Font.GothamBlack; 
check.TextSize = 8; check.ZIndex = 101
            local rowBtn = Instance.new("TextButton", row); rowBtn.Size = 
UDim2.new(1,0,1,0)
            rowBtn.BackgroundTransparency = 1; rowBtn.Text = ""; rowBtn.ZIndex = 
102; rowBtn.AutoButtonColor = false
            local capturedIdx = i
            rowBtn.MouseButton1Click:Connect(function()
                -- FIX 4: close and clear catcher FIRST, synchronously,
                -- before firing onSelect. This ensures no click is eaten.
                valLbl.Text = opt.name
                updateRowVisuals(capturedIdx)
                closeAnyDropdown()   -- hides catcher immediately
                -- Now safe to call onSelect — UI is fully unblocked
                if onSelect then
                    task.spawn(function() pcall(onSelect, capturedIdx) end)
                end
            end)
            rowBtn.MouseEnter:Connect(function() if capturedIdx ~= currentSelected 
then TS:Create(row,TweenInfo.new(0.08),
{BackgroundColor3=Color3.fromRGB(30,30,35)}):Play() end end)
            rowBtn.MouseLeave:Connect(function() 
TS:Create(row,TweenInfo.new(0.08),{BackgroundColor3=(capturedIdx==currentSelected) 
and Color3.fromRGB(35,35,40) or Color3.fromRGB(16,16,16)}):Play() end)
            optionFrames[i] = {bg=row, dotStroke=dotRing, nameLbl=nameLbl, 
checkLbl=check}
        end
        local dropH = #options * 23 + 6
        dropFrame.Size = UDim2.new(0, W - contentX - 14, 0, dropH)
        clk.MouseButton1Click:Connect(function()
            if _anyKeyListening then return end
            if activeDropdown == dropFrame then
                closeAnyDropdown()
                return
            end
            closeAnyDropdown()
            -- Position relative to ScreenGui using AbsolutePosition
            local absPos  = c.AbsolutePosition
            local absSize = c.AbsoluteSize
            dropFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 
2)
            dropFrame.Visible = true
            activeDropdown = dropFrame
            clickCatcher.Visible = true
        end)
        local function setSelected(idx)
            idx = math.clamp(idx, 1, #options)
            valLbl.Text = options[idx] and options[idx].name or ""
            updateRowVisuals(idx)
        end
        local function setVisible(on)
            c.Visible = on
            if not on then closeAnyDropdown() end
        end
        return setSelected, setVisible
    end
    -- 
════════════════════════════════════════
    --   SPEED TAB
    -- 
════════════════════════════════════════
    mkSection("Speed", "Speed Configuration")
    mkInput("Speed","Normal Speed",nil,NS,  function(v) if v>0 and v<=500 then 
NS=v; SetSetting("normalSpeed",v) end end)
    mkInput("Speed","Carry Speed", nil,CS,  function(v) if v>0 and v<=500 then 
CS=v; SetSetting("carrySpeed",v) end end)
    mkInput("Speed","Lagger Speed",nil,LAGGER_SPEED, function(v) if v>0 and v<=500 
then LAGGER_SPEED=v; SetSetting("laggerSpeed",v) end end)
    do
        local c = mkCard("Speed",30)
        local lbl = Instance.new("TextLabel",c); lbl.Size=UDim2.new(0.35,0,1,0); 
lbl.Position=UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency=1; lbl.Text="Mode"; lbl.TextColor3=C_WHITE; 
lbl.Font=Enum.Font.GothamBold; lbl.TextSize=8; 
lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=10
        modeValLbl = Instance.new("TextLabel",c); 
modeValLbl.Size=UDim2.new(0.3,0,1,0); modeValLbl.Position=UDim2.new(0.35,0,0,0)
        modeValLbl.BackgroundTransparency=1; modeValLbl.Text=laggerToggled and 
"Lagger" or (speedMode and "Carry" or "Normal")
        modeValLbl.TextColor3=C_DIM; modeValLbl.Font=Enum.Font.GothamBold; 
modeValLbl.TextSize=8; modeValLbl.TextXAlignment=Enum.TextXAlignment.Left; 
modeValLbl.ZIndex=10
        local kb=mkKB(c,KB.SpeedToggle,function(k) KB.SpeedToggle.kb=k; AutoSave() 
end); kb.Position=UDim2.new(1,-(38+5),0.5,-8); kb.ZIndex=11
        local clk=Instance.new("TextButton",c); clk.Size=UDim2.new(0.7,0,1,0); 
clk.BackgroundTransparency=1; clk.Text=""; clk.ZIndex=6
        clk.MouseButton1Click:Connect(function() if _anyKeyListening then return 
end; speedMode=not speedMode; modeValLbl.Text=speedMode and "Carry" or "Normal"; 
SetSetting("speedMode",speedMode) end)
    end
    do
        local c = mkCard("Speed",30)
        local lbl = Instance.new("TextLabel",c); lbl.Size=UDim2.new(0.5,0,1,0); 
lbl.Position=UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency=1; lbl.Text="Lagger Mode"; 
lbl.TextColor3=C_WHITE; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=8; 
lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=10
        local kb=mkKB(c,KB.LaggerToggle,function(k) KB.LaggerToggle.kb=k; 
AutoSave() end); kb.Position=UDim2.new(1,-(38+6+32+6),0.5,-8); kb.ZIndex=11
        local PW,PH=32,14
        local pbg=Instance.new("Frame",c); pbg.Size=UDim2.new(0,PW,0,PH); 
pbg.Position=UDim2.new(1,-(PW+5),0.5,-PH/2)
        pbg.BackgroundColor3=laggerToggled and C_PILL_ON or C_PILL_OFF; 
pbg.BorderSizePixel=0; pbg.ZIndex=8
        Instance.new("UICorner",pbg).CornerRadius=UDim.new(0,7)
        local dot=Instance.new("Frame",pbg); dot.Size=UDim2.new(0,8,0,8)
        dot.Position=laggerToggled and UDim2.new(1,-10,0.5,-4) or 
UDim2.new(0,2,0.5,-4)
        dot.BackgroundColor3=laggerToggled and Color3.fromRGB(20,20,20) or 
C_WHITE; dot.BorderSizePixel=0; dot.ZIndex=9
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        laggerSwBg=pbg; laggerSwDot=dot
        setLaggerVisual=function(on)
            TS:Create(pbg,TweenInfo.new(0.18),{BackgroundColor3=on and C_PILL_ON 
or C_PILL_OFF}):Play()
            TS:Create(dot,TweenInfo.new(0.18,Enum.EasingStyle.Back),{Position=on 
and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=on and 
Color3.fromRGB(20,20,20) or C_WHITE}):Play()
        end
        local clk=Instance.new("TextButton",c); clk.Size=UDim2.new(1,0,1,0); 
clk.BackgroundTransparency=1; clk.Text=""; clk.ZIndex=6
        clk.MouseButton1Click:Connect(function()
            if _anyKeyListening then return end
            laggerToggled=not laggerToggled; setLaggerVisual(laggerToggled)
            if laggerToggled and speedMode then speedMode=false; 
SetSetting("speedMode",false) end
            if modeValLbl then modeValLbl.Text=laggerToggled and "Lagger" or 
(speedMode and "Carry" or "Normal") end
            SetSetting("laggerModeEnabled",laggerToggled)
        end)
    end
    -- 
════════════════════════════════════════
    --   BAT TAB
    -- 
════════════════════════════════════════
    mkSection("Bat","Bat Combat")
    do
        local sv = mkToggle("Bat","Auto Bat",KB.AutoBat,batAimbotEnabled,
            function(on)
                batAimbotEnabled=on
                if on then
                    if aplOn then aplOn=false; stopAutoLeft(); if 
autoLeftSetVisual then autoLeftSetVisual(false) end; 
SetSetting("autoLeftEnabled",false) end
                    if aprOn then aprOn=false; stopAutoRight(); if 
autoRightSetVisual then autoRightSetVisual(false) end; 
SetSetting("autoRightEnabled",false) end
                    startBatAimbot()
                else stopBatAimbot() end
                SetSetting("autoBatEnabled",on)
            end,
            function(k) KB.AutoBat.kb=k; AutoSave() end)
        autoBatSetVisual=sv
    end
    mkSection("Bat","Bat Counter")
    mkToggle("Bat","Bat Counter",nil,batCounterEnabled,
        function(on) batCounterEnabled=on; if on then startBatCounter() else 
stopBatCounter() end; SetSetting("batCounterEnabled",on) end)
    -- 
════════════════════════════════════════
    --   MECHANICS TAB
    -- 
════════════════════════════════════════
    mkSection("Mech","Game Mechanics")
    mkInput("Mech","Grab Radius",nil,Steal.StealRadius,
        function(v) if v>=5 and v<=300 then Steal.StealRadius=math.floor(v); 
SetSetting("stealRadius",v) end end)
    mkToggle("Mech","Infinite Jump",nil,infJumpEnabled,function(on) 
infJumpEnabled=on; SetSetting("infJumpEnabled",on) end)
    mkToggle("Mech","Anti Ragdoll",nil,antiRagdollEnabled,
        function(on) antiRagdollEnabled=on; if on then startAntiRagdoll() else 
stopAntiRagdoll() end; SetSetting("antiRagdollEnabled",on) end)
    mkToggle("Mech","FPS Boost",nil,fpsBoostEnabled,
        function(on) fpsBoostEnabled=on; if on then pcall(applyFPSBoost) end; 
SetSetting("fpsBoostEnabled",on) end)
    mkToggle("Mech","Medusa Counter",nil,medusaCounterEnabled,
        function(on) medusaCounterEnabled=on; if on then setupMedusa(LP.Character) 
end; SetSetting("medusaCounterEnabled",on) end)
    mkToggle("Mech","Desync",nil,desyncEnabled,
        function(on) desyncEnabled=on; if on then enableDesync() else 
disableDesync() end; SetSetting("desyncEnabled",on) end)
    mkToggle("Mech","Unwalk",nil,unwalkEnabled,
        function(on) unwalkEnabled=on; if on then startUnwalk() else stopUnwalk() 
end; SetSetting("unwalkEnabled",on) end)
    mkToggle("Mech","Stretch Rez",nil,stretchRezEnabled,
        function(on) stretchRezEnabled=on; if on then enableStretchRez() else 
disableStretchRez() end; SetSetting("stretchRezEnabled",on) end)
    mkToggle("Mech","AimX",nil,aimXEnabled,
        function(on) aimXEnabled=on; if on then startAimX() else stopAimX() end; 
SetSetting("aimXEnabled",on) end)
    mkSection("Mech","Visuals")
    -- 
══════════════════════════════════════════════════════════════
    --   SKY TOGGLE + 9-THEME DROPDOWN
    -- 
══════════════════════════════════════════════════════════════
    local setSkyDropdownVisible = nil
    do
        local c = mkCard("Mech", 24)
        local lbl = Instance.new("TextLabel", c)
        lbl.Size = UDim2.new(0.45,0,1,0); lbl.Position = UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency = 1; lbl.Text = "Sky Color"
        lbl.TextColor3 = C_WHITE; lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 7; lbl.TextXAlignment = Enum.TextXAlignment.Left; 
lbl.ZIndex = 10
        mkPill(c, skyEnabled, function(on)
            skyEnabled = on
            if on then enableSky(skyColorIndex) else disableSky() end
            if setSkyDropdownVisible then setSkyDropdownVisible(on) end
        end)
        local dropOpts = {}
        for i, theme in ipairs(SKY_THEMES) do
            table.insert(dropOpts, {name = theme.name, color = theme.dotColor})
        end
        local setSelFn, setVisFn = mkDropdown("Mech", "Theme", dropOpts, 
skyColorIndex,
            function(idx)
                skyColorIndex = math.clamp(idx, 1, #SKY_THEMES)
                SetSetting("skyColorIndex", skyColorIndex)
                if skyEnabled then
                    applySky(skyColorIndex)
                end
            end
        )
        setSkyDropdownVisible = setVisFn
        setVisFn(skyEnabled)
    end
    mkToggle("Mech","Waypoint ESP",nil,waypointESPEnabled,
        function(on) waypointESPEnabled=on; if on then startWaypointESP() else 
stopWaypointESP() end; SetSetting("waypointESPEnabled",on) end)
    -- 
════════════════════════════════════════
    --   MOVEMENT TAB
    -- 
════════════════════════════════════════
    mkSection("Move","Movement & Teleport")
    do
        local sv=mkToggle("Move","Auto Left",KB.AutoLeft,aplOn,
            function(on)
                aplOn=on
                if on then
                    if aprOn then aprOn=false; stopAutoRight(); if 
autoRightSetVisual then autoRightSetVisual(false) end; 
SetSetting("autoRightEnabled",false) end
                    if batAimbotEnabled then batAimbotEnabled=false; 
stopBatAimbot(); if autoBatSetVisual then autoBatSetVisual(false) end; 
SetSetting("autoBatEnabled",false) end
                    startAutoLeft()
                else stopAutoLeft() end
                SetSetting("autoLeftEnabled",on)
            end,
            function(k) KB.AutoLeft.kb=k; AutoSave() end)
        autoLeftSetVisual=sv
    end
    do
        local sv=mkToggle("Move","Auto Right",KB.AutoRight,aprOn,
            function(on)
                aprOn=on
                if on then
                    if aplOn then aplOn=false; stopAutoLeft(); if 
autoLeftSetVisual then autoLeftSetVisual(false) end; 
SetSetting("autoLeftEnabled",false) end
                    if batAimbotEnabled then batAimbotEnabled=false; 
stopBatAimbot(); if autoBatSetVisual then autoBatSetVisual(false) end; 
SetSetting("autoBatEnabled",false) end
                    startAutoRight()
                else stopAutoRight() end
                SetSetting("autoRightEnabled",on)
            end,
            function(k) KB.AutoRight.kb=k; AutoSave() end)
        autoRightSetVisual=sv
    end
    mkKBOnly("Move","Drop",    KB.DropBrainrot, function(k) KB.DropBrainrot.kb=k; 
AutoSave() end)
    mkKBOnly("Move","TP Down", KB.TPDown,       function(k) KB.TPDown.kb=k; 
AutoSave() end)
    mkSection("Move","Auto TP Down")
    mkToggle("Move","Auto TP Down",nil,autoTPEnabled,
        function(on)
            autoTPEnabled = on
            if on then startAutoTP() else stopAutoTP() end
            SetSetting("autoTPEnabled", on)
        end)
    mkInput("Move","Y Threshold",nil,autoTPY,
        function(v)
            if v >= -5000 and v <= 5000 then
                autoTPY = v
                SetSetting("autoTPY", v)
            end
        end)
    mkSection("Move","Float")
    mkInput("Move","Float Height",nil,floatHeight,
        function(v) local n=tonumber(v); if n and n>=1 and n<=100 then 
floatHeight=n; SetSetting("floatHeight",n) end end)
    do
        local c=mkCard("Move",30)
        local lbl=Instance.new("TextLabel",c); lbl.Size=UDim2.new(0.45,0,1,0); 
lbl.Position=UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency=1; lbl.Text="Float"; lbl.TextColor3=C_WHITE; 
lbl.Font=Enum.Font.GothamBold; lbl.TextSize=8; 
lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=10
        local kb=mkKB(c,KB.Float,function(k) KB.Float.kb=k; AutoSave() end); 
kb.Position=UDim2.new(1,-(38+6+32+6),0.5,-8); kb.ZIndex=11
        local sv=mkPill(c,floatEnabled,function(on)
            floatEnabled=on; if setFloat then setFloat(on) end
            if on then floatJumping=false; startFloat() else stopFloat() end
            SetSetting("floatEnabled",on)
        end)
        setFloat=sv
    end
    -- 
════════════════════════════════════════
    --   SETTINGS TAB
    -- 
════════════════════════════════════════
    mkSection("Settings","Interface & Binds")
    do
        local c=mkCard("Settings",30)
        local lbl=Instance.new("TextLabel",c); lbl.Size=UDim2.new(0.5,0,1,0); 
lbl.Position=UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency=1; lbl.Text="Hide / Show GUI"; 
lbl.TextColor3=C_WHITE; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=8; 
lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=10
        local kb=mkKB(c,KB.GuiHide,function(k) KB.GuiHide.kb=k; AutoSave() end); 
kb.Position=UDim2.new(1,-(38+5),0.5,-8); kb.ZIndex=11
    end
    do
        local c=mkCard("Settings",30)
        local lbl=Instance.new("TextLabel",c); lbl.Size=UDim2.new(0.55,0,1,0); 
lbl.Position=UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency=1; lbl.Text="Lock UI"; lbl.TextColor3=C_WHITE; 
lbl.Font=Enum.Font.GothamBold; lbl.TextSize=8; 
lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=10
        mkPill(c,guiLocked,function(on) guiLocked=on end)
    end
    mkSection("Settings","Controller (PS5)")
    do
        local gpTogCard=mkCard("Settings",24)
        local gpTogLbl=Instance.new("TextLabel",gpTogCard)
        gpTogLbl.Size=UDim2.new(0.65,0,1,0); gpTogLbl.Position=UDim2.new(0,6,0,0)
        gpTogLbl.BackgroundTransparency=1; gpTogLbl.Text="Controller Support"
        gpTogLbl.TextColor3=C_WHITE; gpTogLbl.Font=Enum.Font.GothamBold; 
gpTogLbl.TextSize=7; gpTogLbl.TextXAlignment=Enum.TextXAlignment.Left; 
gpTogLbl.ZIndex=10
        mkPill(gpTogCard,controllerEnabled,function(on) if _G._novaSetGP then 
_G._novaSetGP(on) end end)
    end
    do
        local hintCard=mkCard("Settings",20)
        local hintLbl=Instance.new("TextLabel",hintCard)
        hintLbl.Size=UDim2.new(1,-10,1,0); hintLbl.Position=UDim2.new(0,6,0,0)
        hintLbl.BackgroundTransparency=1; hintLbl.Text="Click binding to rebind  •  
Press any PS5 button"
        hintLbl.TextColor3=C_DIM; hintLbl.Font=Enum.Font.Gotham; 
hintLbl.TextSize=6
        hintLbl.TextXAlignment=Enum.TextXAlignment.Left; hintLbl.TextWrapped=true; 
hintLbl.ZIndex=10
    end
    task.defer(function()
        if not _G._novaGPActList or not _G._novaGPBindRow then return end
        local HIDDEN = {["L3Action"]=true,["R3Action"]=true}
        for _,act in ipairs(_G._novaGPActList) do if not HIDDEN[act.id] then 
_G._novaGPBindRow(act) end end
    end)
    -- Steal bar
    do
        local sbGui=Instance.new("ScreenGui",LP:WaitForChild("PlayerGui"))
        sbGui.Name="NovaStealBar"; sbGui.ResetOnSpawn=false; 
sbGui.IgnoreGuiInset=true; sbGui.DisplayOrder=9
        local pill=Instance.new("Frame",sbGui); pill.Size=UDim2.new(0,200,0,32); 
pill.Position=UDim2.new(0.5,-100,1,-40)
        pill.BackgroundColor3=Color3.fromRGB(5,5,8); 
pill.BackgroundTransparency=0.05; pill.BorderSizePixel=0
        Instance.new("UICorner",pill).CornerRadius=UDim.new(0,16)
        local pStr=Instance.new("UIStroke",pill); 
pStr.Color=Color3.fromRGB(55,55,65); pStr.Thickness=1.1
        local track=Instance.new("Frame",pill); track.Size=UDim2.new(1,-16,0,8); 
track.Position=UDim2.new(0,8,0.5,-4)
        track.BackgroundColor3=Color3.fromRGB(18,18,22); track.BorderSizePixel=0; 
Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
        local fill=Instance.new("Frame",track); fill.Size=UDim2.new(0,0,1,0); 
fill.BackgroundColor3=Color3.fromRGB(210,210,220); fill.BorderSizePixel=0
        Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0); 
IvyStealFill=fill
        local pct=Instance.new("TextLabel",pill); pct.Size=UDim2.new(1,0,0,16); 
pct.Position=UDim2.new(0,0,1,-14)
        pct.BackgroundTransparency=1; pct.Text="0%"; 
pct.TextColor3=Color3.fromRGB(160,160,170); pct.Font=Enum.Font.GothamBlack; 
pct.TextSize=8; pct.TextXAlignment=Enum.TextXAlignment.Center; IvyStealPct=pct
        local tag=Instance.new("TextLabel",sbGui); tag.Size=UDim2.new(0,200,0,12); 
tag.Position=UDim2.new(0.5,-100,1,-58)
        tag.BackgroundTransparency=1; tag.Text="NOVA STEAL"; 
tag.TextColor3=Color3.fromRGB(90,90,100); tag.Font=Enum.Font.GothamBlack; 
tag.TextSize=7; tag.TextXAlignment=Enum.TextXAlignment.Center
        makeDraggable(pill)
    end
    -- Keyboard input handler
    UIS.InputBegan:Connect(function(inp, gpe)
        if gpe or _anyKeyListening then return end
        local kc=inp.KeyCode; local 
isKB=inp.UserInputType==Enum.UserInputType.Keyboard; local 
isGP=inp.UserInputType==Enum.UserInputType.Gamepad1
        if not isKB and not isGP then return end
        local function km(e) return kc==e.kb or (e.gp~=nil and kc==e.gp) end
        if km(KB.DropBrainrot) then task.spawn(runDrop)
        elseif km(KB.TPDown) then task.spawn(tpDown)
        elseif km(KB.SpeedToggle) then speedMode=not speedMode; if modeValLbl then 
modeValLbl.Text=speedMode and "Carry" or "Normal" end; 
SetSetting("speedMode",speedMode)
        elseif km(KB.LaggerToggle) then laggerToggled=not laggerToggled; if 
laggerToggled and speedMode then speedMode=false; SetSetting("speedMode",false) 
end; if setLaggerVisual then setLaggerVisual(laggerToggled) end; if modeValLbl 
then modeValLbl.Text=laggerToggled and "Lagger" or (speedMode and "Carry" or 
"Normal") end; SetSetting("laggerModeEnabled",laggerToggled)
        elseif km(KB.AutoLeft) then
            local on=not aplOn
            if on then if aprOn then stopAutoRight(); 
SetSetting("autoRightEnabled",false) end; if batAimbotEnabled then 
stopBatAimbot(); SetSetting("autoBatEnabled",false) end; aplOn=true; 
startAutoLeft(); if autoLeftSetVisual then autoLeftSetVisual(true) end; 
SetSetting("autoLeftEnabled",true)
            else stopAutoLeft(); if autoLeftSetVisual then 
autoLeftSetVisual(false) end; SetSetting("autoLeftEnabled",false) end
        elseif km(KB.AutoRight) then
            local on=not aprOn
            if on then if aplOn then stopAutoLeft(); 
SetSetting("autoLeftEnabled",false) end; if batAimbotEnabled then stopBatAimbot(); 
SetSetting("autoBatEnabled",false) end; aprOn=true; startAutoRight(); if 
autoRightSetVisual then autoRightSetVisual(true) end; 
SetSetting("autoRightEnabled",true)
            else stopAutoRight(); if autoRightSetVisual then 
autoRightSetVisual(false) end; SetSetting("autoRightEnabled",false) end
        elseif km(KB.AutoBat) then
            batAimbotEnabled=not batAimbotEnabled
            if batAimbotEnabled then if aplOn then stopAutoLeft(); 
SetSetting("autoLeftEnabled",false) end; if aprOn then stopAutoRight(); 
SetSetting("autoRightEnabled",false) end; startBatAimbot()
            else stopBatAimbot() end
            if autoBatSetVisual then autoBatSetVisual(batAimbotEnabled) end; 
SetSetting("autoBatEnabled",batAimbotEnabled)
        elseif km(KB.Float) then floatEnabled=not floatEnabled; if setFloat then 
setFloat(floatEnabled) end; if floatEnabled then floatJumping=false; startFloat() 
else stopFloat() end; SetSetting("floatEnabled",floatEnabled)
        elseif km(KB.GuiHide) then if guiVisible then hideGui() else showGui() end
        elseif km(KB.Desync) then desyncEnabled=not desyncEnabled; if 
desyncEnabled then enableDesync() else disableDesync() end; 
SetSetting("desyncEnabled",desyncEnabled)
        elseif kc==ivyLaggerKeybind then ivyLaggerEnabled=not ivyLaggerEnabled; if 
ivyLaggerEnabled then task.spawn(startIvyLaggerLoop) end
        end
    end)
    -- PS5 Controller
    do
        local PS5_NAMES = {
            [Enum.KeyCode.ButtonA]="Cross (✕)",[Enum.KeyCode.ButtonB]="Circle 
(○)",[Enum.KeyCode.ButtonX]="Square (□)",
            [Enum.KeyCode.ButtonY]="Triangle (△)",[Enum.KeyCode.ButtonL1]="L1",
[Enum.KeyCode.ButtonR1]="R1",
            [Enum.KeyCode.ButtonL2]="L2",[Enum.KeyCode.ButtonR2]="R2",
[Enum.KeyCode.ButtonL3]="L3 (L-Stick Click)",
            [Enum.KeyCode.ButtonR3]="R3 (R-Stick Click)",
[Enum.KeyCode.ButtonSelect]="Create",[Enum.KeyCode.ButtonStart]="Options",
            [Enum.KeyCode.DPadUp]="D-Pad ↑",[Enum.KeyCode.DPadDown]="D-Pad ↓",
[Enum.KeyCode.DPadLeft]="D-Pad ←",[Enum.KeyCode.DPadRight]="D-Pad →",
        }
        local function ps5Name(kc) return PS5_NAMES[kc] or (kc and kc.Name) or 
"None" end
        local savedGPBinds = Config.controllerBinds or {}
        local function loadGPKey(id, default)
            local saved=savedGPBinds[id]; if saved then local 
ok,kc=pcall(function() return Enum.KeyCode[saved] end); if ok and kc and 
kc~=Enum.KeyCode.Unknown then return kc end end; return default
        end
        local GP_ACT = {
            {id="TPDown",      label="TP Down",      key=loadGPKey("TPDown",      
Enum.KeyCode.ButtonR2)},
            {id="CarryMode",   label="Carry Mode",   key=loadGPKey("CarryMode",   
Enum.KeyCode.ButtonL2)},
            {id="AutoLeft",    label="Auto Left",    key=loadGPKey("AutoLeft",    
Enum.KeyCode.ButtonR1)},
            {id="AutoRight",   label="Auto Right",   key=loadGPKey("AutoRight",   
Enum.KeyCode.ButtonL1)},
            {id="Drop",        label="Drop",         key=loadGPKey("Drop",        
Enum.KeyCode.ButtonY)},
            {id="LaggerSpeed", label="Lagger Speed", key=loadGPKey("LaggerSpeed", 
Enum.KeyCode.ButtonA)},
            {id="AutoBat",     label="Auto Bat",     key=loadGPKey("AutoBat",     
Enum.KeyCode.DPadUp)},
            {id="Desync",      label="Desync",       key=loadGPKey("Desync",      
Enum.KeyCode.DPadLeft)},
            {id="L3Action",    label="L3 (L-Stick)", key=loadGPKey("L3Action",    
Enum.KeyCode.ButtonL3)},
            {id="R3Action",    label="R3 (R-Stick)", key=loadGPKey("R3Action",    
Enum.KeyCode.ButtonR3)},
        }
        local function saveGPBinds()
            local t={}; for _,act in ipairs(GP_ACT) do if act.key then 
t[act.id]=act.key.Name end end; Config.controllerBinds=t; AutoSave()
        end
        local gpLastFire={}; local GP_DEBOUNCE=0.25; local 
gpEnabled=controllerEnabled
        local function doAutoLeft()
            local on=not aplOn
            if on then if aprOn then stopAutoRight(); if autoRightSetVisual then 
autoRightSetVisual(false) end; SetSetting("autoRightEnabled",false) end; if 
batAimbotEnabled then batAimbotEnabled=false; stopBatAimbot(); if autoBatSetVisual 
then autoBatSetVisual(false) end; SetSetting("autoBatEnabled",false) end; 
aplOn=true; startAutoLeft(); if autoLeftSetVisual then autoLeftSetVisual(true) 
end; SetSetting("autoLeftEnabled",true)
            else stopAutoLeft(); if autoLeftSetVisual then 
autoLeftSetVisual(false) end; SetSetting("autoLeftEnabled",false) end
        end
        local function doAutoRight()
            local on=not aprOn
            if on then if aplOn then stopAutoLeft(); if autoLeftSetVisual then 
autoLeftSetVisual(false) end; SetSetting("autoLeftEnabled",false) end; if 
batAimbotEnabled then batAimbotEnabled=false; stopBatAimbot(); if autoBatSetVisual 
then autoBatSetVisual(false) end; SetSetting("autoBatEnabled",false) end; 
aprOn=true; startAutoRight(); if autoRightSetVisual then autoRightSetVisual(true) 
end; SetSetting("autoRightEnabled",true)
            else stopAutoRight(); if autoRightSetVisual then 
autoRightSetVisual(false) end; SetSetting("autoRightEnabled",false) end
        end
        local function doCarryMode() speedMode=not speedMode; if modeValLbl then 
modeValLbl.Text=speedMode and "Carry" or "Normal" end; 
SetSetting("speedMode",speedMode) end
        local function doLaggerSpeed() laggerToggled=not laggerToggled; if 
laggerToggled and speedMode then speedMode=false; SetSetting("speedMode",false) 
end; if setLaggerVisual then setLaggerVisual(laggerToggled) end; if modeValLbl 
then modeValLbl.Text=laggerToggled and "Lagger" or (speedMode and "Carry" or 
"Normal") end; SetSetting("laggerModeEnabled",laggerToggled) end
        local function doDesync() desyncEnabled=not desyncEnabled; 
applyDesync(desyncEnabled); SetSetting("desyncEnabled",desyncEnabled) end
        local function doAutoBat()
            local on=not batAimbotEnabled
            if on then if aplOn then stopAutoLeft(); if autoLeftSetVisual then 
autoLeftSetVisual(false) end; SetSetting("autoLeftEnabled",false) end; if aprOn 
then stopAutoRight(); if autoRightSetVisual then autoRightSetVisual(false) end; 
SetSetting("autoRightEnabled",false) end; batAimbotEnabled=true; startBatAimbot(); 
if autoBatSetVisual then autoBatSetVisual(true) end; 
SetSetting("autoBatEnabled",true)
            else batAimbotEnabled=false; stopBatAimbot(); if autoBatSetVisual then 
autoBatSetVisual(false) end; SetSetting("autoBatEnabled",false) end
        end
        local GP_DISPATCH={
            TPDown=function() task.spawn(tpDown) end, CarryMode=doCarryMode,
            AutoLeft=doAutoLeft, AutoRight=doAutoRight,
            Drop=function() task.spawn(runDrop) end, LaggerSpeed=doLaggerSpeed,
            AutoBat=doAutoBat, Desync=doDesync,
            L3Action=doAutoLeft, R3Action=doAutoRight,
        }
        UIS.InputBegan:Connect(function(inp,gpe)
            if gpe then return end; if 
inp.UserInputType~=Enum.UserInputType.Gamepad1 then return end
            if not gpEnabled then return end; if _anyKeyListening then return end
            local kc=inp.KeyCode; local now=tick()
            for _,act in ipairs(GP_ACT) do
                if act.key==kc then
                    local last=gpLastFire[act.id] or 0; if now-last<GP_DEBOUNCE 
then return end
                    gpLastFire[act.id]=now; local fn=GP_DISPATCH[act.id]; if fn 
then pcall(fn) end; return
                end
            end
        end)
        local function setGPEnabled(on) gpEnabled=on; controllerEnabled=on; 
SetSetting("controllerEnabled",on) end
        local function mkGPBindRow(act)
            local c=mkCard("Settings",24)
            local lbl=Instance.new("TextLabel",c); lbl.Size=UDim2.new(0.46,0,1,0); 
lbl.Position=UDim2.new(0,6,0,0)
            lbl.BackgroundTransparency=1; lbl.Text=act.label; 
lbl.TextColor3=C_WHITE; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=7; 
lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=10
            local curLbl=Instance.new("TextButton",c); 
curLbl.Size=UDim2.new(0,58,0,16); curLbl.Position=UDim2.new(1,-(58+5),0.5,-8)
            curLbl.BackgroundColor3=C_KB_BG; curLbl.BorderSizePixel=0; 
curLbl.Text=ps5Name(act.key); curLbl.TextColor3=C_DIM; 
curLbl.Font=Enum.Font.GothamBold; curLbl.TextSize=6; curLbl.ZIndex=11
            Instance.new("UICorner",curLbl).CornerRadius=UDim.new(0,3)
            local cStr=Instance.new("UIStroke",curLbl); cStr.Color=C_BORDER2; 
cStr.Thickness=1
            local listening=false; local listenConn=nil
            curLbl.MouseButton1Click:Connect(function()
                if listening then listening=false; _anyKeyListening=false; if 
listenConn then listenConn:Disconnect(); listenConn=nil end; 
curLbl.Text=ps5Name(act.key); TS:Create(cStr,TweenInfo.new(0.1),
{Color=C_BORDER2}):Play(); return end
                listening=true; _anyKeyListening=true; curLbl.Text="···"; 
TS:Create(cStr,TweenInfo.new(0.1),{Color=C_WHITE}):Play()
                listenConn=UIS.InputBegan:Connect(function(inp2)
                    if not listening then return end; if 
inp2.UserInputType~=Enum.UserInputType.Gamepad1 then return end
                    local newKC=inp2.KeyCode; if newKC==Enum.KeyCode.Thumbstick1 
or newKC==Enum.KeyCode.Thumbstick2 or newKC==Enum.KeyCode.Unknown then return end
                    act.key=newKC; curLbl.Text=ps5Name(newKC); 
TS:Create(cStr,TweenInfo.new(0.1),{Color=C_BORDER2}):Play()
                    listening=false; _anyKeyListening=false; if listenConn then 
listenConn:Disconnect(); listenConn=nil end; saveGPBinds()
                end)
            end)
            return c
        end
        _G._novaSetGP=setGPEnabled; _G._novaGPActList=GP_ACT; 
_G._novaGPBindRow=mkGPBindRow; _G._novaPS5Names=PS5_NAMES
    end
    switchTab("Speed")
    main.Visible = true; mini.Visible = true; setBarActive(true); guiVisible = 
true
end-- Character setup
local function setupChar(c)
    gChar=c; gHum=c:WaitForChild("Humanoid",5); 
gHrp=c:WaitForChild("HumanoidRootPart",5)
    if not gHum or not gHrp then return end; task.wait(0.5)
    if antiRagdollEnabled then stopAntiRagdoll(); startAntiRagdoll() end
    if batAimbotEnabled   then stopBatAimbot();   startBatAimbot()   end
    if medusaCounterEnabled then setupMedusa(c) end
end
if LP.Character then setupChar(LP.Character) end
LP.CharacterAdded:Connect(function(c) task.wait(0.5); setupChar(c) end)
buildGui()
print("Nova Hub Loaded ✓ (config: " .. FileName .. ")")
