-- BaseCustomModule.lua
local BaseCustomModule = {}

function BaseCustomModule:HasToolEquipped(toolName)
    local char = game.Players.LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name == toolName
end

function BaseCustomModule:MoveObjectsToPlayer(objectNames)
    local player = game.Players.LocalPlayer
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    for _, obj in pairs(workspace:GetDescendants()) do
        if table.find(objectNames, obj.Name) then
            obj.Position = hrp.Position + hrp.CFrame.LookVector*5
        end
    end
end

function BaseCustomModule:DestroyObjectsInRange(objectNames, range, damage)
    local player = game.Players.LocalPlayer
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    for _, obj in pairs(workspace:GetDescendants()) do
        local distance = (obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and (obj.HumanoidRootPart.Position - hrp.Position).Magnitude) or
                         ((obj.Position - hrp.Position).Magnitude)
        if distance <= range then
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                obj.Humanoid:TakeDamage(damage)
            elseif table.find(objectNames, obj.Name) then
                obj:Destroy()
            end
        end
    end
end

return BaseCustomModule
