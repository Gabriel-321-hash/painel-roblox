-- Delta Roblox Script - Painel Funcional
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

-- CONFIGURAÇÕES
local reach = 100 -- Alcance do Kill Aura
local axeName = "Machado Velho"

-- Criando GUI simples
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaPainel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local function createButton(name, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 0, 35)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(callback)
    btn.Parent = screenGui
    return btn
end

-- Verifica se o machado está equipado
local function hasAxeEquipped()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Kill Aura
local killAuraEnabled = false
local killAuraBtn = createButton("Kill Aura", UDim2.new(0, 10, 0, 10), function()
    killAuraEnabled = not killAuraEnabled
    killAuraBtn.BackgroundColor3 = killAuraEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
end)

runService.RenderStepped:Connect(function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if killAuraEnabled and hasAxeEquipped() then
        for _, npc in pairs(workspace:GetDescendants()) do
            -- NPC humanoid
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                local dist = (npc.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if dist <= reach then
                    npc.Humanoid:TakeDamage(10)
                end
            end
            -- Árvores
            if npc:IsA("Model") and npc.Name == "Tree" then
                local primary = npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")
                if primary then
                    local dist = (primary.Position - char.HumanoidRootPart.Position).Magnitude
                    if dist <= reach then
                        npc:Destroy()
                        local log = Instance.new("Part")
                        log.Size = Vector3.new(2,2,2)
                        log.Position = char.HumanoidRootPart.Position + char.HumanoidRootPart.CFrame.LookVector * 5
                        log.Anchored = false
                        log.Parent = workspace
                        debris:AddItem(log, 30)
                    end
                end
            end
        end
    end
end)

-- Botão para puxar madeira
createButton("Puxar Madeira", UDim2.new(0, 10, 0, 60), function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Log" and obj:IsA("BasePart") then
            obj.Position = char.HumanoidRootPart.Position + char.HumanoidRootPart.CFrame.LookVector * 5
        end
    end
end)

-- Botão para puxar sucata/parafusos
createButton("Puxar Sucata", UDim2.new(0, 10, 0, 110), function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name == "Parafuso" or obj.Name == "Sucata") and obj:IsA("BasePart") then
            obj.Position = char.HumanoidRootPart.Position + char.HumanoidRootPart.CFrame.LookVector * 5
        end
    end
end)

print("Painel Delta carregado!")
