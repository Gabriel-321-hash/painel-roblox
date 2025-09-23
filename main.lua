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
KillAura.Reach = 50 -- alcance do KillAura
KillAura.AxeName = "Machado Velho"

function KillAura:HasAxeEquipped()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == self.AxeName
end

function KillAura:Start()
    RunService.RenderStepped:Connect(function()
        if self.Enabled and self:HasAxeEquipped() and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(workspace:GetDescendants()) do
                -- Dano a NPC humanoid
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    local dist = (obj.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= self.Reach then
                        obj.Humanoid:TakeDamage(10)
                    end
                -- Dano a árvores/logs
                elseif obj.Name == "Tree" or obj.Name == "Log" then
                    if obj:IsA("BasePart") then
                        local dist = (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= self.Reach then
                            obj:Destroy()
                            -- Drop na frente do player
                            local log = Instance.new("Part")
                            log.Size = Vector3.new(2,2,2)
                            log.Position = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 5
                            log.Anchored = false
                            log.Parent = workspace
                            Debris:AddItem(log, 30)
                        end
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        local dist = (obj.PrimaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= self.Reach then
                            obj:Destroy()
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

-- Kill Aura Button
local killBtn = GuiLibrary:CreateButton("Kill Aura", UDim2.new(0,10,0,10), function()
    KillAura.Enabled = not KillAura.Enabled
end)
KillAura:Start()

-- Puxar Madeira Button
GuiLibrary:CreateButton("Puxar Madeira", UDim2.new(0,10,0,60), function()
    PullResources:Pull({"Log","Tree"})
end)

-- Puxar Sucata Button
GuiLibrary:CreateButton("Puxar Sucata", UDim2.new(0,10,0,110), function()
    PullResources:Pull({"Parafuso","Sucata"})
end)

print("Painel Delta carregado!")
