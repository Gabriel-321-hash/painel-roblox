-- Delta Roblox Script - Painel Funcional com GuiLibrary
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local axeName = "Machado Velho" -- Nome do machado
local reach = 100 -- Alcance do Kill Aura

-- Carregando GuiLibrary (supondo que você já tem o arquivo GuiLibrary.lua)
local GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/main/GuiLibrary.lua"))()

-- Função para verificar se o machado está equipado
local function hasAxeEquipped()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Kill Aura Toggle
local killAuraEnabled = false
local KillAuraButton = GuiLibrary.CreateToggle({
    Name = "Kill Aura",
    Function = function(state)
        killAuraEnabled = state
    end
})

-- Função para puxar logs
local function pullLogs()
    local charHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not charHRP then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Log" then
            obj.Position = charHRP.Position + charHRP.CFrame.LookVector * 5
        end
    end
end

-- Função para puxar sucatas
local function pullScrap()
    local charHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not charHRP then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Parafuso" or obj.Name == "Sucata" then
            obj.Position = charHRP.Position + charHRP.CFrame.LookVector * 5
        end
    end
end

-- Criando botões para puxar itens
GuiLibrary.CreateButton({Name = "Puxar Madeira", Function = pullLogs})
GuiLibrary.CreateButton({Name = "Puxar Sucata", Function = pullScrap})

-- Loop do Kill Aura
runService.RenderStepped:Connect(function()
    if killAuraEnabled and hasAxeEquipped() then
        local charHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not charHRP then return end

        for _, npc in pairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                local dist = (npc.HumanoidRootPart.Position - charHRP.Position).Magnitude
                if dist <= reach then
                    npc.Humanoid:TakeDamage(10)
                end
            elseif npc.Name == "Tree" or npc.Name == "Log" then
                local dist = (npc.Position - charHRP.Position).Magnitude
                if dist <= reach then
                    npc:Destroy()
                    -- Drop de madeira
                    local log = Instance.new("Part")
                    log.Size = Vector3.new(2,2,2)
                    log.Position = charHRP.Position + charHRP.CFrame.LookVector * 5
                    log.Anchored = false
                    log.Parent = workspace
                    debris:AddItem(log, 30)
                end
            end
        end
    end
end)

print("Painel Delta carregado com GuiLibrary!")

