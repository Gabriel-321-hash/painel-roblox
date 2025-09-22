-- ==========================================
--          VAPE GUI PRINCIPAL
-- ==========================================

-- Serviços
local playersService = game:GetService("Players")
local inputService = game:GetService("UserInputService")
local gameCamera = workspace.CurrentCamera
local runService = game:GetService("RunService")

-- Variáveis compartilhadas
shared.VapeIndependent = shared.VapeIndependent or false
shared.VapeFullyLoaded = false
shared.VapeSwitchServers = false
shared.VapeOpenGui = false
local vapeInjected = true
local teleportedServers = false

-- ==========================================
--         TOGGLES E SLIDERS DA GUI
-- ==========================================
local GUISettings = GuiLibrary.SettingsSection or {}
local GeneralSettings = GuiLibrary.GeneralSection or {}

-- Blur Background
GUISettings.CreateToggle({
	Name = "Blur Background", 
	Function = function(callback) 
		GuiLibrary.MainBlur.Size = (callback and 25 or 0) 
	end,
	Default = true,
	HoverText = "Blur the background of the GUI"
})

-- GUI Bind Indicator
local welcomeMessage = GUISettings.CreateToggle({
	Name = "GUI bind indicator", 
	Function = function() end, 
	Default = true,
	HoverText = 'Displays a message indicating your GUI keybind upon injecting.'
})

-- Old Rainbow
GUISettings.CreateToggle({
	Name = "Old Rainbow", 
	Function = function(callback) oldrainbow = callback end,
	HoverText = "Reverts to old rainbow"
})

-- Show Tooltips
GUISettings.CreateToggle({
	Name = "Show Tooltips", 
	Function = function(callback) GuiLibrary.ToggleTooltips = callback end,
	Default = true,
	HoverText = "Toggles visibility of tooltips"
})

-- Rescale GUI
local GUIRescaleToggle = GUISettings.CreateToggle({
	Name = "Rescale", 
	Function = function(callback) 
		task.spawn(function()
			GuiLibrary.MainRescale.Scale = (callback and math.clamp(gameCamera.ViewportSize.X / 1920, 0.5, 1) or 0.99)
			task.wait(0.01)
			GuiLibrary.MainRescale.Scale = (callback and math.clamp(gameCamera.ViewportSize.X / 1920, 0.5, 1) or 1)
		end)
	end,
	Default = true,
	HoverText = "Rescales the GUI"
})

gameCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if GUIRescaleToggle.Enabled then
		GuiLibrary.MainRescale.Scale = math.clamp(gameCamera.ViewportSize.X / 1920, 0.5, 1)
	end
end)

-- Notifications
GUISettings.CreateToggle({
	Name = "Notifications", 
	Function = function(callback) 
		GuiLibrary.Notifications = callback 
	end,
	Default = true,
	HoverText = "Shows notifications"
})

-- Toggle Alert
local ToggleNotifications
ToggleNotifications = GUISettings.CreateToggle({
	Name = "Toggle Alert", 
	Function = function(callback) GuiLibrary.ToggleNotifications = callback end,
	Default = true,
	HoverText = "Notifies you if a module is enabled/disabled."
})
ToggleNotifications.Object.BackgroundTransparency = 0
ToggleNotifications.Object.BorderSizePixel = 0
ToggleNotifications.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

-- Rainbow Speed Slider
GUISettings.CreateSlider({
	Name = "Rainbow Speed",
	Function = function(val)
		GuiLibrary.RainbowSpeed = math.max((val / 10) - 0.4, 0)
	end,
	Min = 1,
	Max = 100,
	Default = 10
})

-- GUI Bind
local GUIbind = GUI.CreateGUIBind()

-- ==========================================
--               KILLAURA
-- ==========================================
local killAuraEnabled = false
local killAuraRange = 15 -- alcance em studs
local killAuraDamage = 10

GUISettings.CreateToggle({
	Name = "KillAura",
	Function = function(callback)
		killAuraEnabled = callback
	end,
	Default = false,
	HoverText = "Automatically attacks nearby NPCs"
})

local function getClosestNPC()
	local closest = nil
	local shortestDist = killAuraRange
	for _, npc in pairs(workspace:GetChildren()) do
		if npc:FindFirstChild("Humanoid") and npc ~= playersService.LocalPlayer.Character then
			local hrp = npc:FindFirstChild("HumanoidRootPart")
			local playerHRP = playersService.LocalPlayer.Character and playersService.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp and playerHRP then
				local dist = (hrp.Position - playerHRP.Position).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					closest = npc
				end
			end
		end
	end
	return closest
end

runService.RenderStepped:Connect(function()
	if killAuraEnabled then
		local target = getClosestNPC()
		if target then
			local humanoid = target:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(killAuraDamage)
			end
		end
	end
end)

-- ==========================================
--        TELEPORT E RE-EXECUÇÃO
-- ==========================================
if not shared.NoAutoExecute then
	local teleportConnection = playersService.LocalPlayer.OnTeleport:Connect(function(State)
		if not teleportedServers and not shared.VapeIndependent then
			teleportedServers = true
			local teleportScript = [[
				shared.VapeSwitchServers = true 
				if shared.VapeDeveloper then 
					loadstring(readfile("vape/NewMainScript.lua"))() 
				else 
					loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/main/NewMainScript.lua", true))()
				end
			]]
			if shared.VapeDeveloper then teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript end
			if shared.VapePrivate then teleportScript = 'shared.VapePrivate = true\n'..teleportScript end
			if shared.VapeCustomProfile then 
				teleportScript = "shared.VapeCustomProfile = '"..shared.VapeCustomProfile.."'\n"..teleportScript
			end
			GuiLibrary.SaveSettings()
			queueonteleport(teleportScript)
		end
	end)
end

-- ==========================================
--         FUNÇÃO SELFDESTRUCT
-- ==========================================
GuiLibrary.SelfDestruct = function()
	task.spawn(function() coroutine.close(saveSettingsLoop) end)
	if GuiLibrary.ColorStepped then GuiLibrary.ColorStepped:Disconnect() end

	if vapeInjected then GuiLibrary.SaveSettings() end
	vapeInjected = false
	inputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None

	for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
		if (v.Type == "Button" or v.Type == "OptionsButton" or v.Type == "LegitModule") and v.Api.Enabled then
			v.Api.ToggleButton(false)
		end
	end

	for i,v in pairs(TextGUIConnections) do v:Disconnect() end
	for i,v in pairs(TextGUIObjects) do 
		for i2,v2 in pairs(v) do 
			v2.Visible = false
			v2:Destroy()
			v[i2] = nil
		end
	end

	GuiLibrary.SelfDestructEvent:Fire()
	shared.VapeExecuted = nil
	shared.VapePrivate = nil
	shared.VapeFullyLoaded = nil
	shared.VapeSwitchServers = nil
	shared.GuiLibrary = nil
	shared.VapeIndependent = nil
	shared.VapeManualLoad = nil
	shared.CustomSaveVape = nil

	GuiLibrary.KeyInputHandler:Disconnect()
	GuiLibrary.KeyInputHandler2:Disconnect()
	if MiddleClickInput then MiddleClickInput:Disconnect() end
	pcall(function() teleportConnection:Disconnect() end)
	GuiLibrary.MainGui:Destroy()
end

-- ==========================================
--             FUNÇÃO RESTART
-- ==========================================
GuiLibrary.Restart = function()
	GuiLibrary.SelfDestruct()
	local vapePrivateCheck = shared.VapePrivate
	shared.VapeSwitchServers = true
	shared.VapeOpenGui = true
	shared.VapePrivate = vapePrivateCheck
	loadstring(vapeGithubRequest("NewMainScript.lua"))()
end

-- ==========================================
--           BOTÕES GERAIS
-- ==========================================
GeneralSettings.CreateButton2({
	Name = "RESET CURRENT PROFILE", 
	Function = function()
		local vapePrivateCheck = shared.VapePrivate
		GuiLibrary.SelfDestruct()
		if delfile then
			delfile(baseDirectory.."Profiles/"..(GuiLibrary.CurrentProfile ~= "default" and GuiLibrary.CurrentProfile or "")..(shared.CustomSaveVape or game.PlaceId)..".vapeprofile.txt")
		else
			writefile(baseDirectory.."Profiles/"..(GuiLibrary.CurrentProfile ~= "default" and GuiLibrary.CurrentProfile or "")..(shared.CustomSaveVape or game.PlaceId)..".vapeprofile.txt", "")
		end
		shared.VapeSwitchServers = true
		shared.VapeOpenGui = true
		shared.VapePrivate = vapePrivateCheck
		loadstring(vapeGithubRequest("NewMainScript.lua"))()
	end
})

GUISettings.CreateButton2({
	Name = "RESET GUI POSITIONS", 
	Function = function()
		for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
			if (v.Type == "Window" or v.Type == "CustomWindow") then
				v.Object.Position = (
