-- Delta Roblox Script - Painel Funcional
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- CONFIGURAÇÕES
local reach = 100 -- Alcance do Kill Aura (100% do mapa)
local axeName = "Machado Velho" -- Nome do machado

-- Criando GUI simples
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "DeltaPainel"

local function createButton(name, pos, callback)
    local btn = Instance.new("TextButton", screenGui)
    btn.Size = UDim2.new(0, 150, 0, 35)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Função para verificar se o machado está equipado
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
    if killAuraEnabled and hasAxeEquipped() then
        for _, npc in pairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                local dist = (npc.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist <= reach then
                    -- Dano simulado (10 por exemplo)
                    npc.Humanoid:TakeDamage(10)
                end
            elseif npc.Name == "Tree" or npc.Name == "Log" then
                local dist = (npc.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist <= reach then
                    npc:Destroy() -- Remove a árvore para simular cut
                    -- Cria drop de madeira na frente do player
                    local log = Instance.new("Part")
                    log.Size = Vector3.new(2,2,2)
                    log.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 5
                    log.Anchored = false
                    log.Parent = workspace
                    debris:AddItem(log, 30)
                end
            end
        end
    end
end)

-- Botão para puxar madeiras/logs
createButton("Puxar Madeira", UDim2.new(0, 10, 0, 60), function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Log" then
            obj.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 5
        end
    end
end)

-- Botão para puxar sucatas/parafusos
createButton("Puxar Sucata", UDim2.new(0, 10, 0, 110), function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Parafuso" or obj.Name == "Sucata" then
            obj.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 5
        end
    end
end)

print("Painel Delta carregado!")
