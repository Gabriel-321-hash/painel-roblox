-- Loadstring Delta Painel + GuiLibrary
if not shared.GuiLibrary then
    -- Carrega GuiLibrary automaticamente
    local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
    local getasset = getsynasset or getcustomasset

    if not isfile("GuiLibrary.lua") then
        local req = requestfunc({
            Url = "https://raw.githubusercontent.com/VapeVoidware/vapevoidware/main/GuiLibrary.lua",
            Method = "GET"
        })
        writefile("GuiLibrary.lua", req.Body)
    end

    loadfile("GuiLibrary.lua")()
end

-- Aguarda GuiLibrary carregar
repeat wait() until shared.GuiLibrary

-- Delta Painel Script
local GuiLibrary = shared.GuiLibrary
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local debris = game:GetService("Debris")
local runService = game:GetService("RunService")

local lplr = players.LocalPlayer
local axeName = "Machado Velho"
local reach = 100

-- Verifica se o player está com o machado
local function hasAxeEquipped()
    local char = lplr.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == axeName
end

-- Kill Aura toggle
local killAuraEnabled = false
local killAuraToggle = GuiLibrary["ObjectsThatCanBeSaved"]["MainGuiFolder"]["Api"].CreateToggle("Kill Aura", function(state)
    killAuraEnabled = state
end)

-- Kill Aura Loop
runService.RenderStepped:Connect(function()
    if killAuraEnabled and hasAxeEquipped() then
        for _, npc in pairs(workspace:GetDescendants()) do
            -- NPC humanoid
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                local dist = (npc.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                if dist <= reach then
                    npc.Humanoid:TakeDamage(10)
                end
            -- Árvores ou logs
            elseif npc.Name == "Tree" or npc.Name == "Log" then
                local dist = (npc.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                if dist <= reach then
                    npc:Destroy()
                    local log = Instance.new("Part")
                    log.Size = Vector3.new(2,2,2)
                    log.Position = lplr.Character.HumanoidRootPart.Position + lplr.Character.HumanoidRootPart.CFrame.LookVector * 5
                    log.Anchored = false
                    log.Parent = workspace
                    debris:AddItem(log, 30)
                end
            end
        end
    end
end)

-- Puxar Madeira
GuiLibrary["ObjectsThatCanBeSaved"]["MainGuiFolder"]["Api"].CreateButton("Puxar Madeira", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Log" then
            obj.Position = lplr.Character.HumanoidRootPart.Position + lplr.Character.HumanoidRootPart.CFrame.LookVector * 5
        end
    end
end)

-- Puxar Sucata
GuiLibrary["ObjectsThatCanBeSaved"]["MainGuiFolder"]["Api"].CreateButton("Puxar Sucata", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Parafuso" or obj.Name == "Sucata" then
            obj.Position = lplr.Character.HumanoidRootPart.Position + lplr.Character.HumanoidRootPart.CFrame.LookVector * 5
        end
    end
end)

print("Painel Delta carregado com GuiLibrary!")
