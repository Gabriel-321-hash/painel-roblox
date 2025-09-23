-- main.lua - Painel Delta Funcional

-- Requer GuiLibrary
local GuiLibrary = require(game.ReplicatedStorage:WaitForChild("GuiLibrary"))

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

-- ======= KillAura Module =======
local KillAura = {}
KillAura.Enabled = false
KillAura.Reach = 50 -- alcance inicial
KillAura.AxeName = "Machado Velho"
KillAura.OnlyNPCs = true -- só atacar NPCs e animais

function KillAura:HasAxeEquipped()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == self.AxeName
end

function KillAura:IsTarget(obj)
    if self.OnlyNPCs then
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            -- Ignora players
            return not Players:FindFirstChild(obj.Name)
        elseif obj.Name == "Tree" or obj.Name == "Log" then
            return true
        end
        return false
    else
        return obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart")
    end
end

function KillAura:Start()
    RunService.RenderStepped:Connect(function()
        if self.Enabled and self:HasAxeEquipped() and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(workspace:GetDescendants()) do
                if self:IsTarget(obj) then
                    local pos
                    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                        pos = obj.HumanoidRootPart.Position
                    elseif obj:IsA("BasePart") then
                        pos = obj.Position
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        pos = obj.PrimaryPart.Position
                    end

                    if pos then
                        local dist = (pos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= self.Reach then
                            -- Dano ou destruição
                            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                                obj.Humanoid:TakeDamage(10)
                            elseif obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart) then
                                obj:Destroy()
                                local drop = Instance.new("Part")
                                drop.Size = Vector3.new(2,2,2)
                                drop.Position = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 5
                                drop.Anchored = false
                                drop.Parent = workspace
                                Debris:AddItem(drop, 30)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ======= PullResources Module =======
local PullResources = {}
function PullResources:Pull(resourceNames)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(workspace:GetDescendants()) do
            if table.find(resourceNames, obj.Name) then
                if obj:IsA("BasePart") then
                    obj.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 5
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    obj:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 5)
                end
            end
        end
    end
end

-- ======= Criando GUI =======
local screenGui = GuiLibrary:CreateScreenGui("DeltaPainel")

-- Kill Aura Toggle
local killBtn = GuiLibrary:CreateButton("Kill Aura", UDim2.new(0,10,0,10), function()
    KillAura.Enabled = not KillAura.Enabled
end)

-- Alcance Slider
GuiLibrary:CreateSlider("Alcance KillAura", 10, 200, KillAura.Reach, UDim2.new(0,10,0,60), function(value)
    KillAura.Reach = value
end)

KillAura:Start()

-- Puxar Madeira Button
GuiLibrary:CreateButton("Puxar Madeira", UDim2.new(0,10,0,110), function()
    PullResources:Pull({"Log","Tree"})
end)

-- Puxar Sucata Button
GuiLibrary:CreateButton("Puxar Sucata", UDim2.new(0,10,0,160), function()
    PullResources:Pull({"Parafuso","Sucata"})
end)

print("Painel Delta carregado!")
