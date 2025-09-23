-- GuiLibrary.lua (simples, reutilizável)
-- Um GUI helper bem leve para criar janelas, botões, toggles e sliders.

local GuiLibrary = {}
GuiLibrary.Windows = {}
GuiLibrary.MainGui = nil

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function ensureMainGui()
	if GuiLibrary.MainGui and GuiLibrary.MainGui.Parent then return GuiLibrary.MainGui end
	local screen = Instance.new("ScreenGui")
	screen.Name = "SimpleGuiLibrary"
	screen.ResetOnSpawn = false
	screen.Parent = LocalPlayer:WaitForChild("PlayerGui")
	GuiLibrary.MainGui = screen
	return screen
end

local function createBaseFrame(title, x, y)
	local screen = ensureMainGui()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 320, 0, 160)
	frame.Position = UDim2.new(0, x or 10, 0, y or 10)
	frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
	frame.BorderSizePixel = 0
	frame.Parent = screen
	local round = Instance.new("UICorner", frame)
	round.CornerRadius = UDim.new(0,6)

	local titleLabel = Instance.new("TextLabel", frame)
	titleLabel.Text = title or "Window"
	titleLabel.Size = UDim2.new(1, -10, 0, 28)
	titleLabel.Position = UDim2.new(0, 10, 0, 6)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = Enum.Font.SourceSansSemibold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(230,230,230)

	local content = Instance.new("Frame", frame)
	content.Size = UDim2.new(1, -20, 1, -44)
	content.Position = UDim2.new(0, 10, 0, 36)
	content.BackgroundTransparency = 1
	content.ClipsDescendants = true

	-- drag
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = inp.Position
			startPos = frame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	frame.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement and dragging and dragStart and startPos then
			local delta = inp.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	return frame, content
end

function GuiLibrary.CreateWindow(opts)
	opts = opts or {}
	local frame, content = createBaseFrame(opts.Name or "Window", opts.X or 10, opts.Y or 10)
	local window = {Frame = frame, Content = content, Widgets = {}}
	function window.CreateButton(name, callback)
		local btn = Instance.new("TextButton", content)
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.Position = UDim2.new(0, 0, 0, #window.Widgets * 36)
		btn.Text = name
		btn.BackgroundColor3 = Color3.fromRGB(44,44,44)
		btn.TextColor3 = Color3.fromRGB(230,230,230)
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 14
		btn.AutoButtonColor = true
		btn.MouseButton1Click:Connect(function()
			pcall(callback)
		end)
		table.insert(window.Widgets, btn)
		return btn
	end
	function window.CreateToggle(name, callback, default)
		local container = Instance.new("Frame", content)
		container.Size = UDim2.new(1, 0, 0, 30)
		container.Position = UDim2.new(0, 0, 0, #window.Widgets * 36)
		container.BackgroundTransparency = 1

		local lbl = Instance.new("TextLabel", container)
		lbl.Size = UDim2.new(0.75, 0, 1, 0)
		lbl.Position = UDim2.new(0, 0, 0, 0)
		lbl.Text = name
		lbl.BackgroundTransparency = 1
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.SourceSans
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.fromRGB(230,230,230)

		local btn = Instance.new("TextButton", container)
		btn.Size = UDim2.new(0.25, -4, 1, 0)
		btn.Position = UDim2.new(0.75, 4, 0, 0)
		btn.Text = default and "ON" or "OFF"
		btn.BackgroundColor3 = default and Color3.fromRGB(0,160,0) or Color3.fromRGB(80,80,80)
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 14
		btn.AutoButtonColor = true

		local state = default or false
		btn.MouseButton1Click:Connect(function()
			state = not state
			btn.Text = state and "ON" or "OFF"
			btn.BackgroundColor3 = state and Color3.fromRGB(0,160,0) or Color3.fromRGB(80,80,80)
			pcall(callback, state)
		end)
		table.insert(window.Widgets, container)
		return {Set = function(v) state = v; btn.Text = state and "ON" or "OFF"; btn.BackgroundColor3 = state and Color3.fromRGB(0,160,0) or Color3.fromRGB(80,80,80) end, Get = function() return state end}
	end
	function window.CreateSlider(name, min, max, default, callback)
		local container = Instance.new("Frame", content)
		container.Size = UDim2.new(1, 0, 0, 40)
		container.Position = UDim2.new(0, 0, 0, #window.Widgets * 46)
		container.BackgroundTransparency = 1

		local lbl = Instance.new("TextLabel", container)
		lbl.Size = UDim2.new(1, 0, 0, 16)
		lbl.Position = UDim2.new(0, 0, 0, 0)
		lbl.Text = (name or "").." : "..tostring(default or min)
		lbl.BackgroundTransparency = 1
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.SourceSans
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.fromRGB(230,230,230)

		local bar = Instance.new("Frame", container)
		bar.Size = UDim2.new(1, 0, 0, 12)
		bar.Position = UDim2.new(0, 0, 0, 20)
		bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
		local fill = Instance.new("Frame", bar)
		fill.Size = UDim2.new( ( (default or min) - min ) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(0,160,0)

		local dragging = false
		local function updateFromX(x)
			local relative = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			local value = min + (max - min) * relative
			fill.Size = UDim2.new(relative, 0, 1, 0)
			lbl.Text = (name or "").." : "..string.format("%.2f", value)
			pcall(callback, value)
		end
		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				updateFromX(i.Position.X)
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		bar.InputChanged:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseMovement and dragging then
				updateFromX(i.Position.X)
			end
		end)
		table.insert(window.Widgets, container)
		return {Set = function(v) local rel = (v - min)/(max-min); fill.Size = UDim2.new(rel,0,1,0); lbl.Text = name.." : "..tostring(v); pcall(callback, v) end}
	end

	table.insert(GuiLibrary.Windows, window)
	return window
end

return GuiLibrary
