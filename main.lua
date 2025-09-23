-- main.lua - DeltaPainel funcional com GuiLibrary
local GuiLibrary = shared.GuiLibrary
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local axeName = "Machado Velho"
local killAuraRange = 100 -- alcance Kill Aura

-- Cria a janela principal
local window = GuiLibrary:CreateWindow("DeltaPainel")

-- Função para checar se o machado está equipado
local function hasAxeEquipped()
	local tool = Character:FindFirstChildOfClass("Tool")
	return tool and tool.Name == axeName
end

-- Kill Aura
local killAuraEnabled = false
window:CreateToggle({
	Name = "Kill Aura",
	Function = function(state)
		killAuraEnabled = state
	end
})

-- Puxar Madeira
window:CreateButton({
	Name = "Puxar Madeira",
	Function = function()
		for _, obj in pairs(Workspace:GetDescendants()) do
			if obj.Name == "Log" then
				obj.Position = HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 5
			end
		end
	end
})

-- Puxar Sucata/Parafuso
window:CreateButton({
	Name = "Puxar Sucata",
	Function = function()
		for _, obj in pairs(Workspace:GetDescendants()) do
			if obj.Name == "Parafuso" or obj.Name == "Sucata" then
				obj.Position = HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 5
			end
		end
	end
})

-- Função de Kill Aura
RunService.RenderStepped:Connect(function()
	if killAuraEnabled and hasAxeEquipped() then
		for _, obj in pairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
				-- NPC Humanoid
				local dist = (obj.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
				if dist <= killAuraRange then
					obj.Humanoid:TakeDamage(10)
				end
			elseif obj.Name == "Tree" or obj.Name == "Log" then
				-- Árvores
				local dist = (obj.Position - HumanoidRootPart.Position).Magnitude
				if dist <= killAuraRange then
					obj:Destroy()
					-- Cria drop de madeira na frente do player
					local log = Instance.new("Part")
					log.Size = Vector3.new(2,2,2)
					log.Position = HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 5
					log.Anchored = false
					log.Parent = Workspace
					Debris:AddItem(log, 30)
				end
			end
		end
	end
end)

print("DeltaPainel carregado com GuiLibrary!")
