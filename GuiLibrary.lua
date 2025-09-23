-- GuiLibrary.lua - Simplificada e parecida com Voidware
shared.GuiLibrary = shared.GuiLibrary or {}

local GuiLibrary = shared.GuiLibrary
GuiLibrary.Windows = {}

-- Cria uma nova janela
function GuiLibrary:CreateWindow(name)
    local window = {}
    window.Name = name
    window.Toggles = {}
    window.Buttons = {}

    -- Toggle
    function window:CreateToggle(args)
        local toggle = {}
        toggle.Name = args.Name or "Toggle"
        toggle.State = false
        toggle.Callback = args.Function or function() end

        -- Cria botão visual
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 150, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, (#self.Toggles * 40) + 10)
        btn.Text = toggle.Name
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui") or Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
        btn.MouseButton1Click:Connect(function()
            toggle.State = not toggle.State
            toggle.Callback(toggle.State)
            btn.BackgroundColor3 = toggle.State and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
        end)

        table.insert(self.Toggles, toggle)
        return toggle
    end

    -- Botão simples
    function window:CreateButton(args)
        local button = {}
        button.Name = args.Name or "Button"
        button.Callback = args.Function or function() end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 150, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, (#self.Toggles + #self.Buttons) * 40 + 10)
        btn.Text = button.Name
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui") or Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
        btn.MouseButton1Click:Connect(function()
            button.Callback()
        end)

        table.insert(self.Buttons, button)
        return button
    end

    table.insert(GuiLibrary.Windows, window)
    return window
end
