-- Delta Roblox Script - Painel Funcional Próprio com Feedback Visual
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

-- CONFIGURAÇÕES
local reach = 100 -- Alcance do Kill Aura (100% do mapa)
local axeName = "Machado Velho" -- Nome do machado

-- Criando GUI simples
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaPainel"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Função para criar botão estilizado
local function createButton(name, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 40)
    btn.Position = position
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.Parent = screenGui

    -- Hover efeito
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    btn.MouseLeave:Connect(function()
        if btn:GetAttribute("Toggled") then
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end)

    btn:SetAttribute("Toggled", false)
    return btn
end

-- Função para verificar se o machado está equipado
local function hasAxeEquipped()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- ================= Kill Aura =================
local killAuraEnabled = false
local killAuraBtn = createButton("Kill Aura", UDim2.new(0, 10, 0, 10))

killAuraBtn.MouseButton1Click:Connect(function()
    killAuraEnabled = not killAuraEnabled
    killAuraBtn:SetAttribute("Toggled", killAuraEnabled)
    killAuraBtn.BackgroundColor3 = killAuraEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 0, 0)
end)

runService.RenderStepped:Connect(function()
    if killAuraEnabled and hasAxeEquipped() and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(workspace:GetDescendants()) do
            -- NPC com humanoid
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local dist = (obj.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist <= reach then
                    obj.Humanoid:TakeDamage(10)
                end
            -- Árvores
            elseif obj.Name == "Tree" or obj.Name == "Log" then
                if obj:IsA("BasePart") then
                    local dist = (obj.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= reach then
                        obj:Destroy()
                        -- Drop na frente do player
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
    end
end)

-- ================= Puxar Madeira =================
local puxarMadeiraBtn = createButton("Puxar Madeira", UDim2.new(0, 10, 0, 60))
puxarMadeiraBtn.MouseButton1Click:Connect(function()
    puxarMadeiraBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    wait(0.2)
    puxarMadeiraBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Log" and obj:IsA("BasePart") then
                obj.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 5
            end
        end
    end
end)

-- ================= Puxar Sucata =================
local puxarSucataBtn = createButton("Puxar Sucata", UDim2.new(0, 10, 0, 110))
puxarSucataBtn.MouseButton1Click:Connect(function()
    puxarSucataBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    wait(0.2)
    puxarSucataBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj.Name == "Parafuso" or obj.Name == "Sucata") and obj:IsA("BasePart") then
                obj.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 5
            end
        end
    end
end)

print("Painel Delta pronto com feedback visual!")
