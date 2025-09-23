-- Delta Roblox Script - Painel Funcional
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")

-- CONFIGURAÇÕES
local reach = 100 -- Alcance do Kill Aura
local axeName = "Machado Velho" -- Nome do machado

-- Criação da GUI simples
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "DeltaPainel"

local function createButton(name, pos, callback)
    local btn = Instance.new("TextButton", screenGui)
    btn.Size = UDim2.new(0, 160, 0, 40)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
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
createButton("Kill Aura", UDim2.new(0,10,0,10), function()
    killAuraEnabled = not killAuraEnabled
end)

runService.RenderStepped:Connect(function()
    if killAuraEnabled and hasAxeEquipped() and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        for _, obj in pairs(workspace:GetDescendants()) do
            -- Ataca NPC humanoid, mas ignora players
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local isPlayer = players:FindFirstChild(obj.Name)
                if not isPlayer then
                    local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist <= reach then
                        obj.Humanoid:TakeDamage(10)
                    end
                end
            end
            -- Árvores
            if obj:IsA("Model") and obj.Name:find("Tree") and obj.PrimaryPart then
                local dist = (obj.PrimaryPart.Position - hrp.Position).Magnitude
                if dist <= reach then
                    obj:Destroy()
                    local log = Instance.new("Part")
                    log.Size = Vector3.new(2,2,2)
                    log.Position = hrp.Position + hrp.CFrame.LookVector*5
                    log.Anchored = false
                    log.Parent = workspace
                    debris:AddItem(log, 30)
                end
            end
        end
    end
end)

-- Função Puxar Madeira (Logs)
createButton("Puxar Madeira", UDim2.new(0,10,0,60), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Log") and obj.PrimaryPart then
            obj.PrimaryPart.CFrame = hrp.CFrame + hrp.CFrame.LookVector*5
            print("Madeira puxada: "..obj.Name)
        elseif obj:IsA("Part") and obj.Name:find("Log") then
            obj.CFrame = hrp.CFrame + hrp.CFrame.LookVector*5
            print("Madeira puxada: "..obj.Name)
        end
    end
end)

-- Função Puxar Sucata/Parafusos
createButton("Puxar Sucata", UDim2.new(0,10,0,110), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:find("Parafuso") or obj.Name:find("Sucata")) and obj.PrimaryPart then
            obj.PrimaryPart.CFrame = hrp.CFrame + hrp.CFrame.LookVector*5
            print("Sucata puxada: "..obj.Name)
        elseif obj:IsA("Part") and (obj.Name:find("Parafuso") or obj.Name:find("Sucata")) then
            obj.CFrame = hrp.CFrame + hrp.CFrame.LookVector*5
            print("Sucata puxada: "..obj.Name)
        end
    end
end)

print("Painel Delta carregado!")
