local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local localPlayer = Players.LocalPlayer
local sessionStartTime = os.time()

-- Configuration Flags
local targetWalkSpeed = 16
local sprintWalkSpeed = 35
local targetJumpPower = 50
local targetFOV = 70
local isSprinting = false
local sprintKey = Enum.KeyCode.LeftShift

-- Exploits Tracking
local infiniteJumpEnabled = false
local flyEnabled = false
local flySpeed = 50
local bodyVelocity, bodyGyro
local noclipEnabled = false
local xrayEnabled = false
local originalTransparencies = {}
local espEnabled = false
local highlights = {}
local tracerEnabled = false
local tracers = {}
local selectedTargetPlayer = nil

-- Performance Metrics
local fpsValue, pingValue = 0, 0

´´
local function cleanUpActiveVisuals()
    for obj, trans in pairs(originalTransparencies) do
        if obj and obj.Parent then pcall(function() obj.Transparency = trans end) end
    end
    table.clear(originalTransparencies)
    xrayEnabled = false
    
    for name, hl in pairs(highlights) do
        if hl and hl.Parent then pcall(function() hl:Destroy() end) end
    end
    table.clear(highlights)
    
    for _, drawing in pairs(tracers) do
        pcall(function() drawing:Destroy() end)
    end
    table.clear(tracers)
    
    if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) end
    if bodyGyro then pcall(function() bodyGyro:Destroy() end) end
    flyEnabled = false
    noclipEnabled = false
end

local function initializeCharacterTethers(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = targetWalkSpeed
    humanoid.JumpPower = targetJumpPower
    humanoid.UseJumpPower = true
    
    humanoid.Died:Connect(function()
        cleanUpActiveVisuals()
    end)
end

if localPlayer.Character then initializeCharacterTethers(localPlayer.Character) end
localPlayer.CharacterAdded:Connect(initializeCharacterTethers)


task.spawn(function()
    while true do
        local lastTime = os.clock()
        task.wait(1)
        fpsValue = math.floor(1 / (os.clock() - lastTime))
        pcall(function()
            pingValue = math.floor(Stats.Network.ServerPercentIn:GetPercent() * 100) or 0
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                local activeSpeed = isSprinting and sprintWalkSpeed or targetWalkSpeed
                
                if humanoid.WalkSpeed ~= activeSpeed then humanoid.WalkSpeed = activeSpeed end
                if humanoid.JumpPower ~= targetJumpPower then humanoid.JumpPower = targetJumpPower end
                
                if workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView ~= targetFOV then
                    workspace.CurrentCamera.FieldOfView = targetFOV
                end
            end
        end)
    end
end)

local Window = Rayfield:CreateWindow({
   Name = "SleepyHub --- Universal V2",
   Icon = 0, 
   LoadingTitle = "Loading SleepyHub...",
   LoadingSubtitle = "by SleepySnail",
   ShowText = "Rayfield", 
   Theme = "Default", 
   ToggleUIKeybind = "K", 
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = true, 
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SleepyHubConfigs", 
      FileName = "UniversalHubV2"
   },
   Discord = {
      Enabled = true, 
      Invite = "cgZ3AGu8Gt", 
      RememberJoins = false 
   },
   KeySystem = true, 
   KeySettings = {
      Title = "Key Verification",
      Subtitle = "Security Gate",
      Note = "Join Discord: discord.gg/cgZ3AGu8Gt", 
      FileName = "SleepyHubKey", 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"sleepyisdaddy"} 
})


local MovementTab = Window:CreateTab("Movement", nil) 
local VisualsTab = Window:CreateTab("ESP & Render", nil)
local TargetTab = Window:CreateTab("Targeting List", nil)
local MacrosTab = Window:CreateTab("Macros", nil)
local TelemetryTab = Window:CreateTab("Telemetry & Engine", nil)
local CreditTab = Window:CreateTab("Shoutouts", nil)

Rayfield:Notify({
   Title = "SleepyHub Status: Active",
   Content = "System Core Loaded Successfully! Press K to toggle the UI menu.",
   Duration = 7,
   Image = 4483362458,
})

MovementTab:CreateSection("--- Speed Adjustments ---")

MovementTab:CreateSlider({
   Name = "Custom Base WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   Suffix = " Studs/Sec",
   CurrentValue = 16,
   Flag = "PlayerSpeed", 
   Callback = function(Value)
       targetWalkSpeed = Value 
   end,
})

MovementTab:CreateSlider({
   Name = "Sprint Multiplier Speed",
   Range = {20, 600},
   Increment = 5,
   Suffix = " Studs/Sec",
   CurrentValue = 35,
   Flag = "PlayerSprintSpeed", 
   Callback = function(Value)
       sprintWalkSpeed = Value 
   end,
})

MovementTab:CreateKeybind({
   Name = "Remap Sprint Keybind",
   CurrentKeybind = "LeftShift",
   HoldToInteract = false,
   Flag = "SprintKeybindMapping",
   Callback = function(Keybind)
       sprintKey = Keybind
   end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == sprintKey then isSprinting = true end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == sprintKey then isSprinting = false end
end)

MovementTab:CreateSection("--- Vertical Leap Controls ---")

MovementTab:CreateSlider({
   Name = "Jump Power Calibration",
   Range = {50, 1000},
   Increment = 5,
   Suffix = " Power Units",
   CurrentValue = 50,
   Flag = "PlayerJumpPowerSlider", 
   Callback = function(Value)
       targetJumpPower = Value 
   end,
})

MovementTab:CreateToggle({ 
   Name = "Infinite Jump Air Leap",
   CurrentValue = false,
   Flag = "InfJump_Switch",
   Callback = function(Value)
       infiniteJumpEnabled = Value
   end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        pcall(function()
            if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                localPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

MovementTab:CreateSection("--- Flight Options ---")

MovementTab:CreateSlider({
   Name = "Flight Velocity Vector",
   Range = {10, 300},
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = 50,
   Flag = "FlySpeed_Setting", 
   Callback = function(Value)
       flySpeed = Value 
   end,
})

MovementTab:CreateToggle({
   Name = "Enable Aerospace Fly Mode",
   CurrentValue = false,
   Flag = "Fly_Switch",
   Callback = function(Value)
       flyEnabled = Value
       local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
       local hrp = char:WaitForChild("HumanoidRootPart")
       local cam = workspace.CurrentCamera

       if flyEnabled then
           bodyVelocity = Instance.new("BodyVelocity")
           bodyGyro = Instance.new("BodyGyro")
           
           bodyVelocity.Velocity = Vector3.new(0, 0, 0)
           bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
           bodyVelocity.Parent = hrp
           
           bodyGyro.CFrame = hrp.CFrame
           bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
           bodyGyro.Parent = hrp

           task.spawn(function()
               while flyEnabled and char and hrp and bodyVelocity do
                   task.wait()
                   local moveDirection = char:WaitForChild("Humanoid").MoveDirection
                   local camLook = cam.CFrame.LookVector
                   
                   local velocityVector = Vector3.new(0, 0, 0)
                   if moveDirection.Magnitude > 0 then
                       velocityVector = camLook * flySpeed 
                   end
                   
                   bodyVelocity.Velocity = velocityVector
                   bodyGyro.CFrame = cam.CFrame
               end
           end)
       else
           if bodyVelocity then bodyVelocity:Destroy() end
           if bodyGyro then bodyGyro:Destroy() end
       end
   end,
})

MovementTab:CreateToggle({
   Name = "Noclip (Phase Through Walls)",
   CurrentValue = false,
   Flag = "Noclip_Switch",
   Callback = function(Value)
       noclipEnabled = Value
       task.spawn(function()
           while noclipEnabled do
               task.wait()
               if localPlayer.Character then
                   for _, part in pairs(localPlayer.Character:GetDescendants()) do
                       if part:IsA("BasePart") and part.CanCollide == true then
                           part.CanCollide = false
                       end
                   end
               end
           end
       end)
   end,
})

VisualsTab:CreateSection("--- Perspective Adjustments ---")

VisualsTab:CreateSlider({
   Name = "Camera Field of View (FOV)",
   Range = {30, 120},
   Increment = 1,
   Suffix = " Degrees",
   CurrentValue = 70,
   Flag = "CameraFOV_Slider",
   Callback = function(Value)
       targetFOV = Value
   end,
})

VisualsTab:CreateSection("--- Map & Player ESP Engine ---")

VisualsTab:CreateToggle({
   Name = "X-Ray Sub-Surface Map View",
   CurrentValue = false,
   Flag = "Xray_Switch",
   Callback = function(Value)
       xrayEnabled = Value
       if xrayEnabled then
           for _, obj in pairs(workspace:GetDescendants()) do
               if obj:IsA("BasePart") and not obj:IsDescendantOf(localPlayer.Character) and not Players:GetPlayerFromCharacter(obj.Parent) then
                   originalTransparencies[obj] = obj.Transparency
                   obj.Transparency = 0.65
               end
           end
       else
           for obj, trans in pairs(originalTransparencies) do
               if obj and obj.Parent then obj.Transparency = trans end
           end
           table.clear(originalTransparencies)
       end
   end,
})

local function applyESP(player)
    if player == localPlayer then return end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if espEnabled and not char:FindFirstChildOfClass("Highlight") then
            local hl = Instance.new("Highlight", char)
            hl.FillColor = Color3.fromRGB(255, 0, 0) 
            hl.OutlineColor = Color3.fromRGB(255, 255, 255) 
            highlights[player.Name] = hl
        end
    end)
    if player.Character and espEnabled and not player.Character:FindFirstChildOfClass("Highlight") then
        local hl = Instance.new("Highlight", player.Character)
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        highlights[player.Name] = hl
    end
end

VisualsTab:CreateToggle({
   Name = "Chamber Highlight Box ESP",
   CurrentValue = false,
   Flag = "BoxESP_Switch",
   Callback = function(Value)
       espEnabled = Value
       if espEnabled then
           for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
       else
           for name, hl in pairs(highlights) do
               if hl and hl.Parent then hl:Destroy() end
           end
           table.clear(highlights)
       end
   end,
})

Players.PlayerAdded:Connect(applyESP)

VisualsTab:CreateToggle({
   Name = "Snapline Projectile Tracers",
   CurrentValue = false,
   Flag = "Tracers_Switch",
   Callback = function(Value)
       tracerEnabled = Value
       task.spawn(function()
           while tracerEnabled do
               task.wait()
               for _, p in pairs(Players:GetPlayers()) do
                   if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                       local hrp = p.Character.HumanoidRootPart
                       local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                       
                       if onScreen then
                           local tracer = tracers[p.Name] or Drawing.new("Line")
                           tracer.Visible = true
                           tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                           tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                           tracer.Color = Color3.fromRGB(255, 255, 0) 
                           tracer.Thickness = 1.5
                           tracers[p.Name] = tracer
                       else
                           if tracers[p.Name] then tracers[p.Name].Visible = false end
                       end
                   else
                       if tracers[p.Name] then tracers[p.Name].Visible = false end
                   end
               end
           end
           for _, drawing in pairs(tracers) do drawing:Destroy() end
           table.clear(tracers)
       end)
   end,
})


TargetTab:CreateSection("--- Player Tracker  ---")

local playerDropdownList = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= localPlayer then table.insert(playerDropdownList, p.Name) end
end

local TargetDropdown = TargetTab:CreateDropdown({
   Name = "Select Priority Server Target",
   Options = playerDropdownList,
   CurrentOption = "",
   MultipleOptions = false,
   Flag = "TargetDropdownSelection",
   Callback = function(Option)
       if type(Option) == "table" then Option = Option[1] end
       selectedTargetPlayer = Players:FindFirstChild(Option or "")
   end,
})

task.spawn(function()
    while true do
        task.wait(4)
        local updatedList = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= localPlayer then table.insert(updatedList, p.Name) end
        end
        TargetDropdown:Refresh(updatedList)
    end
end)

TargetTab:CreateToggle({
   Name = "Isolate Highlight Target Only",
   CurrentValue = false,
   Flag = "TargetHighlightToggle",
   Callback = function(Value)
       if Value and selectedTargetPlayer and selectedTargetPlayer.Character then
           local existing = selectedTargetPlayer.Character:FindFirstChild("TargetIsolatedHighlight")
           if not existing then
               local hl = Instance.new("Highlight", selectedTargetPlayer.Character)
               hl.FillColor = Color3.fromRGB(0, 255, 255)
               hl.OutlineColor = Color3.fromRGB(255, 255, 255)
               hl.Name = "TargetIsolatedHighlight"
           end
       else
           if selectedTargetPlayer and selectedTargetPlayer.Character then
               local hl = selectedTargetPlayer.Character:FindFirstChild("TargetIsolatedHighlight")
               if hl then hl:Destroy() end
           end
       end
   end,
})

local autoclickerEnabled = false
local clickDelay = 0.1

task.spawn(function()
    while true do
        if autoclickerEnabled then
            if mouse1click then
                mouse1click()
            else
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local mouse = localPlayer:GetMouse()
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
            end
            task.wait(clickDelay)
        else
            task.wait(0.1)
        end
    end
end)

local keyboardPresserEnabled = false
local keypressDelay = 0.5
local rawKeys = {"Q", "E", "R", "F", "Z"}
local keysList = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.F, Enum.KeyCode.Z}
local keysActive = {false, false, false, false, false}

task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    while true do
        if keyboardPresserEnabled then
            for i = 1, 5 do
                if not keyboardPresserEnabled then break end
                if keysActive[i] then
                    local targetKey = keysList[i]
                    if targetKey then
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, targetKey, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, targetKey, false, game)
                        end)
                    end
                    task.wait(keypressDelay)
                end
            end
        else
            task.wait(0.1)
        end
    end
end)

MacrosTab:CreateSection("--- Autoclicker ---")

MacrosTab:CreateKeybind({
    Name = "Autoclicker: Press G to toggle",
    CurrentKeybind = "G",
    HoldToInteract = false,
    Flag = "AutoclickerKeybind", 
    Callback = function(Keybind)
        autoclickerEnabled = not autoclickerEnabled
        Rayfield:Notify({
            Title = "Autoclicker Status",
            Content = autoclickerEnabled and "Status: ACTIVE" or "Status: DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MacrosTab:CreateSlider({
    Name = "Click Action Delay",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "AutoclickerDelaySlider",
    Callback = function(Value) clickDelay = Value end,
})

MacrosTab:CreateSection("--- Auto Keyboard Sequence Presser ---")

local MasterToggle = MacrosTab:CreateToggle({
    Name = "Master Enable: Keyboard Presser",
    CurrentValue = false,
    Flag = "KeyboardPresserToggle",
    Callback = function(Value) keyboardPresserEnabled = Value end
})

MacrosTab:CreateSlider({
    Name = "Sequence Interval Delay",
    Range = {0.05, 5},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.5,
    Flag = "KeyboardPresserDelaySlider",
    Callback = function(Value) keypressDelay = Value end
})

local slotToggles = {}
for i = 1, 5 do
    MacrosTab:CreateSection("Key Slot " .. i)
    slotToggles[i] = MacrosTab:CreateToggle({
        Name = "Enable Key " .. i,
        CurrentValue = false, 
        Flag = "EnableKeyToggle_Slot" .. i,
        Callback = function(Value) keysActive[i] = Value end,
    })
    MacrosTab:CreateKeybind({
        Name = "Set Key " .. i,
        CurrentKeybind = rawKeys[i],
        HoldToInteract = false,
        Flag = "CustomKeybindSlot_Slot" .. i,
        Callback = function(Keybind)
            local targetString = tostring(Keybind):gsub("Enum.KeyCode.", "")
            local cleanSuccess, codeObject = pcall(function() return Enum.KeyCode[targetString] end)
            if cleanSuccess and codeObject then keysList[i] = codeObject end
        end,
    })
end


TelemetryTab:CreateSection("--- Live Diagnostic Data ---")

local OverlayParagraph = TelemetryTab:CreateParagraph({
    Title = "Realtime Telemetry Matrix",
    Content = "Loading Data Stream..."
})

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(function()
            local rawX, rawY, rawZ = 0, 0, 0
            local headingStr = "N/A"
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = localPlayer.Character.HumanoidRootPart.Position
                rawX, rawY, rawZ = math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z)
                local look = localPlayer.Character.HumanoidRootPart.CFrame.LookVector
                local angle = math.atan2(look.X, look.Z) * (180 / math.pi)
                if angle < 0 then angle = angle + 360 end
                if angle >= 337.5 or angle < 22.5 then headingStr = "South (+Z)"
                elseif angle >= 22.5 and angle < 67.5 then headingStr = "South-West"
                elseif angle >= 67.5 and angle < 112.5 then headingStr = "West (-X)"
                elseif angle >= 112.5 and angle < 157.5 then headingStr = "North-West"
                elseif angle >= 157.5 and angle < 202.5 then headingStr = "North (-Z)"
                elseif angle >= 202.5 and angle < 247.5 then headingStr = "North-East"
                elseif angle >= 247.5 and angle < 292.5 then headingStr = "East (+X)"
                elseif angle >= 292.5 and angle < 337.5 then headingStr = "South-East"
                end
            end
            local elapsed = os.time() - sessionStartTime
            local hrs = math.floor(elapsed / 3600)
            local mins = math.floor((elapsed % 3600) / 60)
            local secs = elapsed % 60
            OverlayParagraph:Set({
                Title = "Realtime Telemetry Matrix",
                Content = string.format("FPS Monitor: %d frames/sec\nPing Latency: %d ms\nCoordinate Node: X: %d | Y: %d | Z: %d\nVector Heading: %s\nSession Active Duration: %02d:%02d:%02d", fpsValue, pingValue, rawX, rawY, rawZ, headingStr, hrs, mins, secs)
            })
        end)
    end
end)

TelemetryTab:CreateSection("--- Low Graphics Optimization Engine ---")

TelemetryTab:CreateToggle({
   Name = "Potato PC Mode (Low Graphics / Max FPS)",
   CurrentValue = false,
   Flag = "LowGraphics_Switch",
   Callback = function(Value)
       if Value then
           settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
           for _, v in pairs(workspace:GetDescendants()) do
               if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                   v.Material = Enum.Material.SmoothPlastic
                   v.Reflectance = 0
               elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
               elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false
               end
           end
       end
   end,
})

TelemetryTab:CreateSection("--- Global Engine Relocation ---")

TelemetryTab:CreateButton({
   Name = "Instant Self-Destruct / Kill Respawn",
   Callback = function() pcall(function() localPlayer.Character:BreakJoints() end) end,
})

TelemetryTab:CreateButton({
   Name = "Force Instance Server Rejoin",
   Callback = function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, localPlayer) end) end,
})

TelemetryTab:CreateSection("--- Interface Modification ---")

TelemetryTab:CreateDropdown({
   Name = "Select Workspace Theme Canvas",
   Options = {"Default", "Amber", "Amethyst", "Aqua", "Bloom", "DarkBlue", "Green", "Ocean", "Serenity", "TokyoNight"},
   CurrentOption = {"Default"},
   MultipleOptions = false,
   Flag = "ThemeSelectorDropdown",
   Callback = function(ThemeTable) 
       if type(ThemeTable) == "table" then ThemeTable = ThemeTable[1] end
       pcall(function() Window:SetTheme(ThemeTable) end) 
   end,
})

CreditTab:CreateParagraph({
    Title = " COMMUNITY SHOUTOUTS RECOGNITION:", 
    Content = "fuck you"
})

Rayfield:LoadConfiguration()

task.spawn(function()
    task.wait(0.5)
    keyboardPresserEnabled = false
    MasterToggle:Set(false)
    for i = 1, 5 do
        keysActive[i] = false
        if slotToggles[i] and slotToggles[i].Set then slotToggles[i]:Set(false) end
    end
end)
