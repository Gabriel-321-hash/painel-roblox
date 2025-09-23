-- Delta Auto-Painel Refinado

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- Cria módulo automaticamente se não existir
local function createModule(name, source)
    local module = ReplicatedStorage:FindFirstChild(name)
    if not module then
        module = Instance.new("ModuleScript")
        module.Name = name
        module.Source = source
        module.Parent = ReplicatedStorage
    end
    return require(module)
end

-- GuiLibrary
local GuiLibrary = createModule("GuiLibrary", [[
shared.GuiLibrary = shared.GuiLibrary or {}
local GuiLibrary = shared.GuiLibrary
GuiLibrary.Windows = {}

function GuiLibrary:CreateWindow(name)
    local window = {}
    window.Toggles = {}
    window.Buttons = {}

    function window:CreateToggle(args)
        local toggle = {}
        toggle.Name = args.Name or "Toggle"
        toggle.State = false
        toggle.Callback = args.Function or function() end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,150,0,35)
        btn.Position = UDim2.new(0,10,0,(#self.Toggles*40)+10)
        btn.Text = toggle.Name
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Parent = player:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui") or Instance.new("ScreenGui",player.PlayerGui)
        btn.MouseButton1Click:Connect(function()
            toggle.State = not toggle.State
            toggle.Callback(toggle.State)
            btn.BackgroundColor3 = toggle.State and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
        end)

        table.insert(self.Toggles, toggle)
        return toggle
    end

    function window:CreateButton(args)
        local button = {}
        button.Name = args.Name or "Button"
        button.Callback = args.Function or function() end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,150,0,35)
        btn.Position = UDim2.new(0,10,0,(#self.Toggles + #self.Buttons)*40 + 10)
        btn.Text = button.Name
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Parent = player:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui") or Instance.new("ScreenGui",player.PlayerGui)
        btn.MouseButton1Click:Connect(button.Callback)

        table.insert(self.Buttons, button)
        return button
    end

    table.insert(GuiLibrary.Windows, window)
    return window
end

return GuiLibrary
]])

-- BaseModule
local BaseModule = createModule("BaseModule", [[
local BaseModule = {}

function BaseModule:TakeDamage(npc, damage)
    if npc:FindFirstChild("Humanoid") then
        npc.Humanoid:TakeDamage(damage)
    end
end

function BaseModule:PullItem(itemName, player)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == itemName then
            obj.Position = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector*5
        end
    end
end

return BaseModule
]])

-- Configurações
local KILL_AURA_RANGE = 50 -- Alcance do Kill Aura
local KILL_AURA_DAMAGE = 10 -- Dano aplicado
local AXE_NAME = "Machado Velho"

-- Cria painel
local window = GuiLibrary:CreateWindow("Painel Delta")

-- Kill Aura
local killAuraEnabled = false
window:CreateToggle{
    Name = "Kill Aura",
    Function = function(state)
        killAuraEnabled = state
    end
}

-- Puxar Madeira
window:CreateButton{
    Name = "Puxar Madeira",
    Function = function()
        BaseModule:PullItem("Log", player)
    end
}

-- Puxar Sucata
window:CreateButton{
    Name = "Puxar Sucata",
    Function = function()
        BaseModule:PullItem("Sucata", player)
    end
}

-- Loop Kill Aura
RunService.RenderStepped:Connect(function()
    if killAuraEnabled then
        local char = player.Character
        if char and char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").Name == AXE_NAME then
            for _, npc in pairs(workspace:GetDescendants()) do
                -- NPC Humanoid
                if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                    local dist = (npc.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    if dist <= KILL_AURA_RANGE then
                        BaseModule:TakeDamage(npc,KILL_AURA_DAMAGE)
                    end
                -- Árvores e Logs
                elseif npc.Name == "Tree" or npc.Name == "Log" then
                    local dist = (npc.Position - char.HumanoidRootPart.Position).Magnitude
                    if dist <= KILL_AURA_RANGE then
                        npc:Destroy()
                        local log = Instance.new("Part")
                        log.Size = Vector3.new(2,2,2)
                        log.Position = char.HumanoidRootPart.Position + char.HumanoidRootPart.CFrame.LookVector*5
                        log.Anchored = false
                        log.Parent = workspace
                        Debris:AddItem(log,30)
                    end
                end
            end
        end
    end
end)
