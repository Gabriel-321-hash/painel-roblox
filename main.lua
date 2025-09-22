-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Gui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomPanel"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Janela principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Painel de Cheats"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Função para criar botões
local function CreateButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = UDim2.new(0, 25, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name.." [OFF]"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Parent = MainFrame

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name.." ["..(enabled and "ON" or "OFF").."]"
        callback(enabled)
    end)
end

-- Kill Aura real usando machado
local KillAuraEnabled = false
local AttackRange = 10 -- raio em studs
local DamageAmount = 25 -- dano do machado

CreateButton("Kill Aura", 50, function(state)
    KillAuraEnabled = state
end)

-- Loop Kill Aura
RunService.RenderStepped:Connect(function()
    if KillAuraEnabled then
        for _, npc in pairs(Workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                local humanoid = npc.Humanoid
                local root = npc.HumanoidRootPart
                if humanoid.Health > 0 and (root.Position - player.Character.HumanoidRootPart.Position).Magnitude <= AttackRange then
                    -- Aplica dano
                    humanoid:TakeDamage(DamageAmount)
                end
            end
        end
    end
end)

-- Draggable da janela
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
