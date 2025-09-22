-- Delta Roblox Script - Painel Funcional estilo Voidware
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")

-- CONFIGURAÇÕES
local reach = 100 -- Alcance do Kill Aura (100% do mapa)
local axeName = "Machado Velho" -- Nome do machado
local killAuraEnabled = false

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaPainel"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Função para criar botões
local function createButton(name, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(callback)
    btn.Parent = screenGui
    return btn
end

-- Verifica se machado está equipado
local function hasAxeEquipped()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Kill Aura Toggle
local killAuraBtn = createButton("Kill Aura", UDim2.new(0, 10, 0, 10), function()
    killAuraEnabled = not killAuraEnabled
    killAuraBtn.BackgroundColor3 = killAuraEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
end)

-- Função Kill Aura e cortar árvores
runService.RenderStepped:Connect(function()
    if killAuraEnabled and hasAxeEquipped() and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        for _, obj in pairs(workspace:GetDescendants()) do
            -- NPC humanoid
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= player.Character then
                local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist <= reach then
                    obj.Humanoid:TakeDamage(10)
                end
            -- Árvores
            elseif obj.Name == "Tree" or obj.Name == "Log" then
                if obj:IsA("BasePart") then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist <= reach then
                        obj:Destroy()
                        local log = Instance.new("Part")
                        log.Size = Vector3.new(2,2,2)
                        log.Position = hrp.Position + hrp.CFrame.LookVector * 5
                        log.Anchored = false
                        log.Parent = workspace
                        debris:AddItem(log, 30)
                    end
                end
            end
        end
    end
end)

-- Puxar Madeira
createButton("Puxar Madeira", UDim2.new(0, 10, 0, 60), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Log" and obj:IsA("BasePart") then
            obj.Position = hrp.Position + hrp.CFrame.LookVector * 5
        end
    end
end)

-- Puxar Sucata / Parafuso
createButton("Puxar Sucata", UDim2.new(0, 10, 0, 110), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name == "Parafuso" or obj.Name == "Sucata") and obj:IsA("BasePart") then
            obj.Position = hrp.Position + hrp.CFrame.LookVector * 5
        end
    end
end)

print("Painel Delta carregado!")
