-- main.lua - Painel funcional (usa shared.GuiLibrary)
-- Coloque GuiLibrary.lua no mesmo repo e carregue ambos (veja instruções abaixo).

-- Dependências
if not shared.GuiLibrary then
	-- tenta carregar local se estiver armazenado em PlayerGui por algum motivo
	local ok, lib = pcall(function() return require(game:GetService("ReplicatedStorage"):FindFirstChild("GuiLibrary")) end)
	-- se não existir, user precisa garantir que GuiLibrary.lua foi carregado antes
end
local GuiLibrary = shared.GuiLibrary or require(script:FindFirstChild("GuiLibrary") or script) -- fallback

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Character = function() return LocalPlayer.Character end
local HumanoidRoot = function() return Character() and Character():FindFirstChild("HumanoidRootPart") end

-- Config (ajuste nomes se o jogo tiver strings diferentes)
local AXE_NAMES = {["Machado Velho"]=true, ["Machado Bom"]=true}
local LOG_NAMES = {["Log"]=true, ["Tree"]=true}
local SCRAP_NAMES = {["Parafuso"]=true, ["Sucata"]=true, ["Scrap"]=true}
local FUEL_NAMES = {["Barrel"]=true, ["Coal"]=true, ["Wood"]=true}
local FIRE_NAMES = {["Campfire"]=true, ["Fire"]=true, ["Bonfire"]=true}
local WORKBENCH_NAMES = {["Workbench"]=true, ["TableBuild"]=true, ["ConstructionTable"]=true}

-- Estado
local killAuraEnabled = false
local killAuraRange = 50 -- default (will be controlled by slider)
local pullDistance = 5

-- Util helpers
local function isToolAxe()
	local ch = Character()
	if not ch then return false end
	for _, child in pairs(ch:GetChildren()) do
		if child:IsA("Tool") and AXE_NAMES[child.Name] then
			return true
		end
	end
	return false
end

local function isPlayerModel(model)
	if not model then return false end
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum then return false end
	-- check if this belongs to a player
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character == model then return true end
	end
	return false
end

local function isPlayerInstanceModel(model)
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character == model then return true end
	end
	return false
end

local function isHumanoidNPC(model)
	if not model then return false end
	if isPlayerInstanceModel(model) then return false end
	local hum = model:FindFirstChildOfClass("Humanoid")
	return hum ~= nil
end

local function findInWorkspaceByNames(nameset)
	local matched = {}
	for _, inst in pairs(workspace:GetDescendants()) do
		if inst and inst.Name and nameset[inst.Name] then
			table.insert(matched, inst)
		end
	end
	return matched
end

local function movePartToFrontOfPlayer(part, offsetDistance)
	if not (part and HumanoidRoot() and Character()) then return end
	if part:IsA("BasePart") then
		local targetPos = HumanoidRoot().Position + (Character():FindFirstChild("HumanoidRootPart").CFrame.LookVector * (offsetDistance or pullDistance))
		part.CFrame = CFrame.new(targetPos)
		part:SetNetworkOwner(LocalPlayer) -- helpful on some exploits
	elseif part:IsA("Model") then
		local primary = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart")
		if primary then
			local targetPos = HumanoidRoot().Position + (Character():FindFirstChild("HumanoidRootPart").CFrame.LookVector * (offsetDistance or pullDistance))
			primary.CFrame = CFrame.new(targetPos)
			part:BreakJoints() -- in case it's anchored as model with constraints
		end
	end
end

-- Damage function (uses :TakeDamage if Humanoid)
local function damageHumanoid(humanoid, amount)
	if humanoid and humanoid.Health and humanoid.Parent then
		if typeof(humanoid.TakeDamage) == "function" then
			pcall(function() humanoid:TakeDamage(amount) end)
		else
			-- fallback:
			pcall(function() humanoid.Health = math.max(0, humanoid.Health - amount) end)
		end
	end
end

-- Kill Aura loop
RunService.Heartbeat:Connect(function()
	if killAuraEnabled and isToolAxe() and HumanoidRoot() then
		local origin = HumanoidRoot().Position
		for _, obj in pairs(workspace:GetDescendants()) do
			-- humanoid NPCs
			if obj:IsA("Model") and isHumanoidNPC(obj) and obj:FindFirstChild("HumanoidRootPart") then
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				local dist = (hrp.Position - origin).Magnitude
				if dist <= killAuraRange then
					local humanoid = obj:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid.Health > 0 then
						-- apply damage (tunable)
						damageHumanoid(humanoid, 10)
					end
				end
			end
			-- trees/logs as parts or models
			if obj:IsA("BasePart") and LOG_NAMES[obj.Name] then
				local dist = (obj.Position - origin).Magnitude
				if dist <= killAuraRange then
					-- simulate hit: create a drop and remove original or move it
					local drop = Instance.new("Part")
					drop.Size = Vector3.new(2,2,2)
					drop.Position = origin + (Character():FindFirstChild("HumanoidRootPart").CFrame.LookVector * 4) + Vector3.new(0,2,0)
					drop.Anchored = false
					drop.Name = "LogDrop"
					drop.Parent = workspace
					Debris:AddItem(drop, 25)
					-- optional: destroy original to simulate cutting
					pcall(function() obj:Destroy() end)
				end
			end
		end
	end
end)

-- Functional buttons
local function PullAllLogsToFront()
	if not HumanoidRoot() then return end
	for _, inst in pairs(workspace:GetDescendants()) do
		if inst and LOG_NAMES[inst.Name] then
			pcall(function() movePartToFrontOfPlayer(inst, 4) end)
		end
	end
end

local function PullAllScrapToFront()
	if not HumanoidRoot() then return end
	for _, inst in pairs(workspace:GetDescendants()) do
		if inst and SCRAP_NAMES[inst.Name] then
			pcall(function() movePartToFrontOfPlayer(inst, 4) end)
		end
	end
end

local function ThrowFuelIntoFires()
	-- Move all fuel items near fires (or directly set their position to fire)
	local fires = {}
	for _, f in pairs(workspace:GetDescendants()) do
		if FIRE_NAMES[f.Name] and f:IsA("BasePart") then
			table.insert(fires, f)
		end
	end
	if #fires == 0 then
		-- try find by model with a part
		for _, f in pairs(workspace:GetDescendants()) do
			if f:IsA("Model") and FIRE_NAMES[f.Name] then
				local primary = f.PrimaryPart or f:FindFirstChildWhichIsA("BasePart")
				if primary then table.insert(fires, primary) end
			end
		end
	end
	-- if found fires, move fuels into their positions
	for _, fuel in pairs(workspace:GetDescendants()) do
		if FUEL_NAMES[fuel.Name] then
			for _, firepart in pairs(fires) do
				pcall(function()
					fuel.Position = firepart.Position + Vector3.new(0,2,0)
				end)
				break
			end
		end
	end
end

local function SendResourcesToWorkbench()
	-- find bench target
	local benchPart = nil
	for _, inst in pairs(workspace:GetDescendants()) do
		if WORKBENCH_NAMES[inst.Name] then
			if inst:IsA("BasePart") then benchPart = inst; break end
			if inst:IsA("Model") then benchPart = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart"); if benchPart then break end end
		end
	end
	if not benchPart then return end

	for _, inst in pairs(workspace:GetDescendants()) do
		if LOG_NAMES[inst.Name] or SCRAP_NAMES[inst.Name] then
			pcall(function()
				if inst:IsA("BasePart") then
					inst.Position = benchPart.Position + Vector3.new(math.random(-2,2), 1, math.random(-2,2))
				elseif inst:IsA("Model") then
					local prim = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart")
					if prim then prim.Position = benchPart.Position + Vector3.new(math.random(-2,2), 1, math.random(-2,2)) end
				end
			end)
		end
	end
end

-- GUI — usa shared.GuiLibrary (se você tiver colocado GuiLibrary.lua em shared)
if not shared.GuiLibrary then
	warn("GuiLibrary not found in shared. Ensure GuiLibrary.lua is loaded and assigned to shared.GuiLibrary.")
end

local WL = shared.GuiLibrary or (require and require(game:GetService("ReplicatedStorage"):FindFirstChild("GuiLibrary")) )
local window = WL.CreateWindow({Name = "Painel Delta", X = 10, Y = 10})

-- Kill Aura toggle
local killToggle = window.CreateToggle("Kill Aura (axe required)", function(state)
	killAuraEnabled = state
end, false)

-- Range slider
local rangeSlider = window.CreateSlider("Kill Range", 1, 200, killAuraRange, function(val)
	killAuraRange = val
end)

-- Pull wood button
window.CreateButton("Puxar Madeira", function()
	PullAllLogsToFront()
end)

-- Pull scrap button
window.CreateButton("Puxar Sucata", function()
	PullAllScrapToFront()
end)

-- Throw fuels into fires
window.CreateButton("Jogar no Fogo", function()
	ThrowFuelIntoFires()
end)

-- Send to workbench
window.CreateButton("Enviar para Mesa de Construção", function()
	SendResourcesToWorkbench()
end)

-- Quick notify
print("Painel Delta carregado. Abra o GUI (arraste) e ajuste as opções. Ajuste nomes de objetos se necessário.")
