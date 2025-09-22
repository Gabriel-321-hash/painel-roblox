local killAuraAtivado = false
local intensidade = 80
local alcanceKillAura = 500
local painelStatus

function ativarKillAura()
    if killAuraAtivado then
        painelStatus.Text = "Kill Aura: Ativado (Alcance: " .. alcanceKillAura .. ")"
        painelStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        painelStatus.Text = "Kill Aura: Desativado"
        painelStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

local function executarKillAura()
    spawn(function()
        while killAuraAtivado do
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local inimigoHRP = plr.Character.HumanoidRootPart
                        local distancia = (hrp.Position - inimigoHRP.Position).Magnitude
                        if distancia <= alcanceKillAura then
                            -- Coloque aqui seu código de ataque real:
                            -- Exemplo:
                            -- plr.Character.Humanoid:TakeDamage(intensidade)
                            -- Por enquanto só print:
                            print("Atacando " .. plr.Name .. " à distância: " .. math.floor(distancia))
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

function curar()
    painelStatus.Text = "Cura ativada!"
    painelStatus.TextColor3 = Color3.fromRGB(0, 191, 255)
    wait(2)
    painelStatus.Text = killAuraAtivado and "Kill Aura: Ativado (Alcance: " .. alcanceKillAura .. ")" or "Kill Aura: Desativado"
    painelStatus.TextColor3 = killAuraAtivado and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

function criarPainel()
    local player = game.Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PainelAutomacao"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local painel = Instance.new("Frame")
    painel.Size = UDim2.new(0, 320, 0, 240)
    painel.Position = UDim2.new(0.5, -160, 0.5, -120)
    painel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    painel.BackgroundTransparency = 0.2
    painel.BorderSizePixel = 0
    painel.Parent = screenGui
    painel.Active = true
    painel.Draggable = true

    local titulo = Instance.new("TextLabel")
    titulo.Size = UDim2.new(1, 0, 0, 30)
    titulo.Position = UDim2.new(0, 0, 0, 0)
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

    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(0, 280, 0, 30)
    sliderBG.Position = UDim2.new(0, 20, 0, 140)
    sliderBG.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    sliderBG.BorderSizePixel = 0
    sliderBG.Parent = painel

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(intensidade / 100, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBG

    local txtIntensidade = Instance.new("TextLabel")
    txtIntensidade.Size = UDim2.new(0, 280, 0, 30)
    txtIntensidade.Position = UDim2.new(0, 20, 0, 180)
    txtIntensidade.BackgroundTransparency = 1
    txtIntensidade.TextColor3 = Color3.fromRGB(255, 255, 255)
    txtIntensidade.Font = Enum.Font.GothamSemibold
    txtIntensidade.TextSize = 16
    txtIntensidade.Text = "Intensidade do Kill Aura: " .. intensidade .. "%"
    txtIntensidade.Parent = painel

    painelStatus = Instance.new("TextLabel")
    painelStatus.Size = UDim2.new(0, 280, 0, 40)
    painelStatus.Position = UDim2.new(0, 20, 0, 220)
    painelStatus.BackgroundTransparency = 1
    painelStatus.TextColor3 = killAuraAtivado and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    painelStatus.Font = Enum.Font.GothamBold
    painelStatus.TextSize = 18
    painelStatus.Text = killAuraAtivado and "Kill Aura: Ativado (Alcance: " .. alcanceKillAura .. ")" or "Kill Aura: Desativado"
    painelStatus.Parent = painel

    local mouse = game.Players.LocalPlayer:GetMouse()
    local segurandoSlider = false

    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            segurandoSlider = true
        end
    end)

    sliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            segurandoSlider = false
        end
    end)

    mouse.Move:Connect(function()
        if segurandoSlider then
            local posX = mouse.X - sliderBG.AbsolutePosition.X
            local tamanho = sliderBG.AbsoluteSize.X
            local percentual = math.clamp(posX / tamanho, 0, 1)
            intensidade = math.floor(percentual * 100)
            sliderFill.Size = UDim2.new(percentual, 0, 1, 0)
            txtIntensidade.Text = "Intensidade do Kill Aura: " .. intensidade .. "%"
            if killAuraAtivado then
                ativarKillAura()
            end
        end
    end)

    btnKillAura.MouseButton1Click:Connect(function()
        killAuraAtivado = not killAuraAtivado
        if killAuraAtivado then
            btnKillAura.Text = "Desativar Kill Aura"
            btnKillAura.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
            ativarKillAura()
            executarKillAura()
        else
            btnKillAura.Text = "Ativar Kill Aura"
            btnKillAura.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
            ativarKillAura()
        end
    end)

    btnCura.MouseButton1Click:Connect(function()
        curar()
    end)

    btnTeleport.MouseButton1Click:Connect(function()
        local player = game.Players.LocalPlayer
        -- Substitua "Crianca" pelo nome correto do modelo das crianças no seu jogo
        local crianca = workspace:FindFirstChild("Crianca")
        if crianca and crianca:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = crianca.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            painelStatus.Text = "Teletransportado para a criança!"
            painelStatus.TextColor3 = Color3.fromRGB(255, 165, 0)
            wait(2)
            ativarKillAura()
        else
            painelStatus.Text = "Criança não encontrada!"
            painelStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
            wait(2)
            ativarKillAura()
        end
    end)
end

criarPainel()

