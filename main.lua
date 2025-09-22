local killAuraAtivado = false
local intensidade = 80
local alcanceKillAura = 500
local painelStatus

-- Atualizar status do painel
local function atualizarStatus()
    if killAuraAtivado then
        painelStatus.Text = "Kill Aura: Ativado (Alcance: " .. alcanceKillAura .. ")"
        painelStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        painelStatus.Text = "Kill Aura: Desativado"
        painelStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- Função Kill Aura
local function executarKillAura()
    task.spawn(function()
        while killAuraAtivado do
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                
                -- Loop por todos os modelos do Workspace
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                        
                        -- Ignorar se for um player
                        local dono = game.Players:GetPlayerFromCharacter(obj)
                        if not dono then
                            local distancia = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
                            if distancia <= alcanceKillAura then
                                obj.Humanoid:TakeDamage(intensidade)
                                print("Atacando NPC: " .. obj.Name .. " à distância " .. math.floor(distancia))
                            end
                        end
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end

-- Função cura (apenas visual)
local function curar()
    painelStatus.Text = "Cura ativada!"
    painelStatus.TextColor3 = Color3.fromRGB(0, 191, 255)
    task.wait(2)
    atualizarStatus()
end

-- Função Teleportar até NPC "Crianca"
local function teleportarCrianca()
    local player = game.Players.LocalPlayer
    local crianca = workspace:FindFirstChild("Crianca")
    if crianca and crianca:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = crianca.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        painelStatus.Text = "Teletransportado para a criança!"
        painelStatus.TextColor3 = Color3.fromRGB(255, 165, 0)
    else
        painelStatus.Text = "Criança não encontrada!"
        painelStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
    task.wait(2)
    atualizarStatus()
end

-- Criar Painel
local function criarPainel()
    local player = game.Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PainelAutomacao"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local painel = Instance.new("Frame")
    painel.Size = UDim2.new(0, 320, 0, 260)
    painel.Position = UDim2.new(0.5, -160, 0.5, -130)
    painel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    painel.BackgroundTransparency = 0.2
    painel.BorderSizePixel = 0
    painel.Parent = screenGui
    painel.Active = true
    painel.Draggable = true

    local titulo = Instance.new("TextLabel")
    titulo.Size = UDim2.new(1, 0, 0, 30)
    titulo.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titulo.Text = "Painel de Controle"
    titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
    titulo.Font = Enum.Font.GothamBold
    titulo.TextSize = 18
    titulo.Parent = painel

    local btnKillAura = Instance.new("TextButton")
    btnKillAura.Size = UDim2.new(0, 140, 0, 40)
    btnKillAura.Position = UDim2.new(0, 20, 0, 50)
    btnKillAura.Text = "Ativar Kill Aura"
    btnKillAura.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    btnKillAura.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnKillAura.Font = Enum.Font.GothamSemibold
    btnKillAura.TextSize = 16
    btnKillAura.Parent = painel

    local btnCura = Instance.new("TextButton")
    btnCura.Size = UDim2.new(0, 140, 0, 40)
    btnCura.Position = UDim2.new(0, 160, 0, 50)
    btnCura.Text = "Ativar Cura"
    btnCura.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    btnCura.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCura.Font = Enum.Font.GothamSemibold
    btnCura.TextSize = 16
    btnCura.Parent = painel

    local btnTeleport = Instance.new("TextButton")
    btnTeleport.Size = UDim2.new(0, 280, 0, 40)
    btnTeleport.Position = UDim2.new(0, 20, 0, 100)
    btnTeleport.Text = "Teleporte para Criança"
    btnTeleport.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    btnTeleport.TextColor3 = Color3.fromRGB(0, 0, 0)
    btnTeleport.Font = Enum.Font.GothamSemibold
    btnTeleport.TextSize = 16
    btnTeleport.Parent = painel

    painelStatus = Instance.new("TextLabel")
    painelStatus.Size = UDim2.new(0, 280, 0, 40)
    painelStatus.Position = UDim2.new(0, 20, 0, 160)
    painelStatus.BackgroundTransparency = 1
    painelStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
    painelStatus.Font = Enum.Font.GothamBold
    painelStatus.TextSize = 18
    painelStatus.Text = "Kill Aura: Desativado"
    painelStatus.Parent = painel

    -- Eventos
    btnKillAura.MouseButton1Click:Connect(function()
        killAuraAtivado = not killAuraAtivado
        if killAuraAtivado then
            btnKillAura.Text = "Desativar Kill Aura"
            btnKillAura.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
            atualizarStatus()
            executarKillAura()
        else
            btnKillAura.Text = "Ativar Kill Aura"
            btnKillAura.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
            atualizarStatus()
        end
    end)

    btnCura.MouseButton1Click:Connect(curar)
    btnTeleport.MouseButton1Click:Connect(teleportarCrianca)
end

criarPainel()
