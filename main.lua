-- main.lua
local GuiLibrary = shared.GuiLibrary
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local workspace = game:GetService("Workspace")

-- Configurações
local reach = 100
local axeName = "Machado Velho"
local killAuraEnabled = false

-- Função para checar se o machado está equipado
local function hasAxeEquipped()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Criando janela
local window = GuiLibrary:CreateWindow("Delta Painel")

-- Kill Aura toggle
window:CreateToggle({
    Name = "Kill Aura",
    Function = function(state)
        killAuraEnabled = state
    end
})

-- Função de Kill Aura
runService.RenderStepped:Connect(function()
    if killAuraEnabled and hasAxeEquipped() and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local dist = (obj.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist <= reach then
                    obj.Humanoid:TakeDamage(10)
                end
            elseif obj.Name == "Tree" or obj.Name == "Log" then
                local dist = (obj.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist <= reach then
                    obj:Destroy()
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

-- Botão para puxar madeira
window:CreateButton({
    Name = "Puxar Madeira",
    Function = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Log" then
                obj.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 5
            end
        end
    end
})

-- Botão para puxar sucata
window:CreateButton({
    Name = "Puxar Sucata",
    Function = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Parafuso" or obj.Name == "Sucata" then
                obj.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 5
            end
        end
    end
})
