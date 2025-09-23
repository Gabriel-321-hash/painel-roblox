-- main.lua - Compatível com GuiLibrary.lua do seu repositório
local GuiLibrary = shared.GuiLibrary
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local localPlayer = Players.LocalPlayer
local axeName = "Machado Velho" -- Nome do machado
local reach = 100 -- Alcance do Kill Aura
local killAuraEnabled = false

-- Função para verificar se o machado está equipado
local function hasAxeEquipped()
    local char = localPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Função para obter NPCs ou árvores dentro do alcance
local function getTargets()
    local targets = {}
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return targets end
    local hrp = localPlayer.Character.HumanoidRootPart

    for _, obj in pairs(Workspace:GetDescendants()) do
        local objPos
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            objPos = obj.HumanoidRootPart.Position
        elseif obj.Name == "Tree" or obj.Name == "Log" then
            objPos = obj.Position
        end

        if objPos and (hrp.Position - objPos).Magnitude <= reach then
            table.insert(targets, obj)
        end
    end

    return targets
end

-- Função de Kill Aura
local function killAura()
    if killAuraEnabled and hasAxeEquipped() then
        for _, target in pairs(getTargets()) do
            if target:IsA("Model") and target:FindFirstChild("Humanoid") then
                target.Humanoid:TakeDamage(10)
            elseif target.Name == "Tree" or target.Name == "Log" then
                local pos = localPlayer.Character.HumanoidRootPart.Position + localPlayer.Character.HumanoidRootPart.CFrame.LookVector * 5
                target:Destroy()
                local log = Instance.new("Part")
                log.Size = Vector3.new(2,2,2)
                log.Position = pos
                log.Anchored = false
                log.Parent = Workspace
                Debris:AddItem(log, 30)
            end
        end
    end
end

-- Funções para puxar recursos
local function pullWood()
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Log" then
            obj.Position = hrp.Position + hrp.CFrame.LookVector * 5
        end
    end
end

local function pullScrap()
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Parafuso" or obj.Name == "Sucata" then
            obj.Position = hrp.Position + hrp.CFrame.LookVector * 5
        end
    end
end

-- Criando a GUI
local mainTab = GuiLibrary["CreateWindow"]("DeltaPainel")
local combatTab = mainTab["CreateTab"]("Combate")
local resourcesTab = mainTab["CreateTab"]("Recursos")

-- Botões
combatTab["CreateButton"]("Kill Aura", function()
    killAuraEnabled = not killAuraEnabled
end)

resourcesTab["CreateButton"]("Puxar Madeira", pullWood)
resourcesTab["CreateButton"]("Puxar Sucata", pullScrap)

-- Loop de RenderStepped para Kill Aura
RunService.RenderStepped:Connect(function()
    if killAuraEnabled then
        killAura()
    end
end)

print("DeltaPainel carregado!")
