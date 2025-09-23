-- main.lua - Painel Delta com GuiLibrary do Voidware
-- Certifique-se de ter GuiLibrary.lua no mesmo repositório

-- Carrega GuiLibrary se ainda não estiver carregada
if not shared.GuiLibrary then
    shared.GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gabriel-321-hash/painel-roblox/main/GuiLibrary.lua"))()
end
local GuiLibrary = shared.GuiLibrary

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer

-- Configurações
local reach = 100 -- Alcance do Kill Aura
local axeName = "Machado Velho"

-- Variáveis de estado
local killAuraEnabled = false

-- Espera o personagem carregar
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Função para verificar se o machado está equipado
local function hasAxeEquipped()
    local tool = character:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Função Kill Aura
RunService.RenderStepped:Connect(function()
    if killAuraEnabled and hasAxeEquipped() then
        for _, obj in pairs(workspace:GetDescendants()) do
            -- NPCs
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local dist = (obj.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                if dist <= reach then
                    obj.Humanoid:TakeDamage(10)
                end
            end
            -- Árvores
            if obj.Name == "Tree" or obj.Name == "Log" then
                local dist = (obj.Position - humanoidRootPart.Position).Magnitude
                if dist <= reach then
                    obj:Destroy()
                    local log = Instance.new("Part")
                    log.Size = Vector3.new(2,2,2)
                    log.Position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
                    log.Anchored = false
                    log.Parent = workspace
                    Debris:AddItem(log, 30)
                end
            end
        end
    end
end)

-- Cria janela do painel
local window = GuiLibrary["CreateWindow"]("Delta Painel")

-- Botão Kill Aura
window:AddToggle({
    Name = "Kill Aura",
    Function = function(state)
        killAuraEnabled = state
    end
})

-- Botão Puxar Madeira
window:AddButton({
    Name = "Puxar Madeira",
    Function = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Log" then
                obj.Position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
            end
        end
    end
})

-- Botão Puxar Sucata/Parafuso
window:AddButton({
    Name = "Puxar Sucata",
    Function = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Parafuso" or obj.Name == "Sucata" then
                obj.Position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
            end
        end
    end
})

print("Painel Delta carregado com sucesso!")
