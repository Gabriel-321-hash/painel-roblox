-- GuiLibrary.lua - Sistema de GUI inspirado no Voidware
shared.GuiLibrary = shared.GuiLibrary or {}
local GuiLibrary = shared.GuiLibrary
GuiLibrary.Windows = {}

function GuiLibrary:CreateWindow(title)
    local window = {}
    window.Title = title
    window.Toggles = {}
    window.Buttons = {}

    local player = game.Players.LocalPlayer
    local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("DeltaScreenGui")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "DeltaScreenGui"
        screenGui.Parent = player.PlayerGui
    end

    function window:CreateToggle(args)
        local toggle = { Name = args.Name or "Toggle", State = false, Callback = args.Function or function() end }
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,150,0,35)
        btn.Position = UDim2.new(0,10,0,(#self.Toggles*45)+10)
        btn.Text = toggle.Name
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Parent = screenGui
        btn.MouseButton1Click:Connect(function()
            toggle.State = not toggle.State
            toggle.Callback(toggle.State)
            btn.BackgroundColor3 = toggle.State and Color3.fromRGB(0,150,0) or Color3.fromRGB(60,60,60)
        end)
        table.insert(self.Toggles,toggle)
        return toggle
    end

    function window:CreateButton(args)
        local button = { Name = args.Name or "Button", Callback = args.Function or function() end }
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,150,0,35)
        btn.Position = UDim2.new(0,10,0,(#self.Toggles + #self.Buttons)*45 + 10)
        btn.Text = button.Name
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Parent = screenGui
        btn.MouseButton1Click:Connect(function()
            button.Callback()
        end)
        table.insert(self.Buttons,button)
        return button
    end

    table.insert(GuiLibrary.Windows,window)
    return window
end
