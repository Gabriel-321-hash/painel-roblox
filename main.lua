-- Delta Roblox Script - Painel Funcional Atualizado
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIGURAÇÕES
local reach = 30 -- Alcance em studs (ajuste conforme o mapa)
local axeName = "Machado Velho"

-- GUI simples
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

-- Verifica se o machado está equipado
local function hasAxeEquipped()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Função para dar dano server-side
local function dealDamageToNPC(npc)
    local event = replicatedStorage:FindFirstChild("DamageNPC") -- troque pelo RemoteEvent real do jogo
    if event then
        event:FireServer(npc, 10) -- 10 de dano
    end
end

-- Função para coletar item server-side
local function collectItem(item)
    local event = replicatedStorage:FindFirstChild("CollectItem") -- troque pelo RemoteEvent real do jogo
    if event then
        event:FireServer(item)
    end
end

-- Kill Aura
local killAuraEnabled = false
createButton("Kill Aura", UDim2.new(0,10,0,10), function()
    killAuraEnabled = not killAuraEnabled
end)

-- Puxar Madeira
createButton("Puxar Madeira", UDim2.new(0,10,0,60), function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Log" then
            collectItem(obj)
        end
    end
end)

-- Puxar Sucata/Parafuso
createButton("Puxar Sucata", UDim2.new(0,10,0,110), function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Parafuso" or obj.Name == "Sucata" then
            collectItem(obj)
        end
    end
end)

-- Loop Kill Aura
runService.RenderStepped:Connect(function()
    if killAuraEnabled and hasAxeEquipped() then
        for _, npc in pairs(workspace:GetDescendants()) do
            if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                local dist = (npc.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist <= reach then
                    dealDamageToNPC(npc)
                end
            end
        end
    end
end)

print("Painel Delta carregado!")
