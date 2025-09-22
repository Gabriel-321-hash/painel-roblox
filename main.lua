-- Função que retorna true se o jogador estiver segurando o machado velho
local function IsHoldingAxe()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Tool") then
        return char.Tool.Name == "OldAxe" -- nome do machado velho
    end
    return false
end

-- Função Kill Aura
local KillAuraEnabled = false
local function KillAura()
    if not KillAuraEnabled then return end
    if not IsHoldingAxe() then return end

    local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position

    for i, obj in pairs(workspace:GetChildren()) do
        -- NPC humanoid
        if obj:FindFirstChild("Humanoid") then
            local playerCheck = game.Players:GetPlayerFromCharacter(obj)
            if not playerCheck then
                -- dano ao NPC
                obj.Humanoid:TakeDamage(15)
            end
        -- Árvores ou árvores de madeira
        elseif obj.Name == "Tree" or obj.Name == "WoodTree" then
            if obj:FindFirstChild("Health") then
                obj.Health.Value = math.max(obj.Health.Value - 15, 0)
            end
        end
    end
end

-- Botão Kill Aura
local killAuraButton = Instance.new("TextButton")
killAuraButton.Size = UDim2.new(0, 120, 0, 30)
killAuraButton.Position = UDim2.new(0, 10, 0, 140)
killAuraButton.Text = "Kill Aura"
killAuraButton.Parent = GuiLibrary.MainGui
killAuraButton.MouseButton1Click:Connect(function()
    KillAuraEnabled = not KillAuraEnabled
    killAuraButton.BackgroundColor3 = KillAuraEnabled and Color3.new(0, 0.7, 0) or Color3.new(1, 0, 0)
end)

-- Loop Kill Aura automático
task.spawn(function()
    while true do
        task.wait(0.1)
        if KillAuraEnabled then
            KillAura()
        end
    end
end)

