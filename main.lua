-- Função para puxar madeira corrigida
window:CreateButton({
    Name = "Puxar Madeira",
    Function = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:find("Log") and obj.PrimaryPart then
                obj.PrimaryPart.CFrame = player.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 5
                print("Madeira puxada: "..obj.Name)
            elseif obj:IsA("Part") and obj.Name:find("Log") then
                obj.CFrame = player.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 5
                print("Madeira puxada: "..obj.Name)
            end
        end
    end
})

-- Função para puxar sucata corrigida
window:CreateButton({
    Name = "Puxar Sucata",
    Function = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:find("Parafuso") or obj.Name:find("Sucata")) and obj.PrimaryPart then
                obj.PrimaryPart.CFrame = player.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 5
                print("Sucata puxada: "..obj.Name)
            elseif obj:IsA("Part") and (obj.Name:find("Parafuso") or obj.Name:find("Sucata")) then
                obj.CFrame = player.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 5
                print("Sucata puxada: "..obj.Name)
            end
        end
    end
})
