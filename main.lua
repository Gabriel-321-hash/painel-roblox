-- Delta Roblox Script - Painel com GuiLibrary
-- Certifique-se de ter o GuiLibrary carregado antes de executar este script

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local reach = 100 -- Alcance do Kill Aura
local axeName = "Machado Velho" -- Nome do machado

-- Função para verificar se o machado está equipado
local function hasAxeEquipped()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Cria a janela principal usando GuiLibrary
local mainWindow = GuiLibrary.CreateMainWindow("DeltaPainel")

-- Toggle Kill Aura
local killAuraToggle = mainWindow.CreateToggle("Kill Aura", false, function(state)
    print("Kill Aura:", state and "Ativada" or "Desativada")
end)

-- Botão para puxar madeiras/logs
mainWindow.CreateButton("Puxar Madeira", function()
    if not player.Character then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Log" then
            obj.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 5
        end
    end
end)

-- Botão para puxar sucatas/parafusos
mainWindow.CreateButton("Puxar Sucata", function()
    if not player.Character then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Parafuso" or obj.Name == "Sucata" then
            obj.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 5
        end
    end
end)

-- Função principal do Kill Aura
runService.RenderStepped:Connect(function()
    if killAuraToggle and killAuraToggle.Enabled and hasAxeEquipped() and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPos = player.Character.HumanoidRootPart.Position
        for _, obj in pairs(workspace:GetDescendants()) do
            -- NPC humanoid
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local dist = (obj.HumanoidRootPart.Position - rootPos).Magnitude
                if dist <= reach then
                    obj.Humanoid:TakeDamage(10)
                end
            end
            -- Árvores ou logs
            if obj.Name == "Tree" or obj.Name == "Log" then
                local dist = (obj.Position - rootPos).Magnitude
                if dist <= reach then
                    obj:Destroy()
                    -- Drop de madeira na frente do player
                    local log = Instance.new("Part")
                    log.Size = Vector3.new(2,2,2)
                    log.Position = rootPos + player.Character.HumanoidRootPart.CFrame.LookVector * 5
                    log.Anchored = false
                    log.Parent = workspace
                    debris:AddItem(log, 30)
                end
            end
        end
    end
end)

print("DeltaPainel carregado com GuiLibrary!")
