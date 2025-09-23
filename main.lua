-- MainScript.lua
local GuiLibrary = shared.GuiLibrary
local BaseModule = require(game.ReplicatedStorage:WaitForChild("BaseCustomModule"))

local axeName = "Machado Velho"
local reach = 100
local damage = 10

local window = GuiLibrary:CreateWindow("Delta Painel")

-- Kill Aura
local killAura = false
window:CreateToggle({
    Name = "Kill Aura",
    Function = function(state)
        killAura = state
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if killAura and BaseModule:HasToolEquipped(axeName) then
        BaseModule:DestroyObjectsInRange({"Tree","Log"}, reach, damage)
    end
end)

-- Puxar Madeira
window:CreateButton({
    Name = "Puxar Madeira",
    Function = function()
        BaseModule:MoveObjectsToPlayer({"Log"})
    end
})

-- Puxar Sucata
window:CreateButton({
    Name = "Puxar Sucata",
    Function = function()
        BaseModule:MoveObjectsToPlayer({"Parafuso","Sucata"})
    end
})
