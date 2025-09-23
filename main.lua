-- main.lua - Delta Roblox Script com GuiLibrary
local GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gabriel-321-hash/painel-roblox/main/GuiLibrary.lua"))()
shared.GuiLibrary = GuiLibrary

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- CONFIGURAÇÕES
local reach = 100 -- Alcance do Kill Aura
local axeName = "Machado Velho" -- Nome do machado
local killAuraEnabled = false

-- Função para verificar se o machado está equipado
local function hasAxeEquipped()
    local tool = character:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Função para aplicar dano em NPC ou destruir árvore
local function applyKillAura()
    if not killAuraEnabled or not hasAxeEquipped() then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local dist = (obj.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            if dist <= reach then
                obj.Humanoid:TakeDamage(10)
            end
        elseif obj.Name == "Tree" or obj.Name == "Log" then
            local dist = (obj.Position - humanoidRootPart.Position).Magnitude
            if dist <= reach then
                obj:Destroy()
                local log = Instance.new("Part")
                log.Size = Vector3.new(2,2,2)
                log.Position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
                log.Anchored = false
                log.Parent = Workspace
                Debris:AddItem(log, 30)
            end
        end
    end
end

RunService.RenderStepped:Connect(applyKillAura)

-- Criando janela no GuiLibrary
local window = GuiLibrary["CreateWindow"]("DeltaPainel")

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
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Log" then
                obj.Position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
            end
        end
    end
})

-- Botão Puxar Sucata
window:AddButton({
    Name = "Puxar Sucata",
    Function = function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Parafuso" or obj.Name == "Sucata" then
                obj.Position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
            end
        end
    end
})

print("Painel Delta carregado com GuiLibrary!")
