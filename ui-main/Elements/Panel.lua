-- panel.lua
local TweenService = game:GetService("TweenService")

local PanelModule = {}

local MainColor = Color3.fromRGB(255, 0, 255)
local SaveConfigFunc = function() end
local ConfigData = {}

function PanelModule.Initialize(color, saveFunc, config)
    MainColor = color or MainColor
    SaveConfigFunc = saveFunc or function() end
    ConfigData = config or {}
end

function PanelModule.Create(parent, config, countItem, updateSizeCallback, saveConfig, configData)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or ""
    config.Placeholder = config.Placeholder or nil
    config.Default = config.Default or ""
    config.ButtonText = config.Button or config.ButtonText or "Confirm"
    config.ButtonCallback = config.Callback or config.ButtonCallback or function() end
    config.SubButtonText = config.SubButton or config.SubButtonText or nil
    config.SubButtonCallback = config.SubCallback or config.SubButtonCallback or function() end

    local configKey = "Panel_" .. config.Title
    if configData and configData[configKey] ~= nil then
        config.Default = configData[configKey]
    end

    local PanelFunc = { Value = config.Default }

    local baseHeight = 50
    if config.Placeholder then baseHeight = baseHeight + 40 end
    if config.SubButtonText then baseHeight = baseHeight + 40 else baseHeight = baseHeight + 36 end

    local Panel = Instance.new("Frame")
    Panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Panel.BackgroundTransparency = 0.935
    Panel.Size = UDim2.new(1, 0, 0, baseHeight)
    Panel.LayoutOrder = countItem
    Panel.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Panel

    local Title = Instance.new("TextLabel")
    Title.Font = Enum.Font.GothamBold
    Title.Text = config.Title
    Title.TextSize = 13
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Size = UDim2.new(1, -20, 0, 13)
    Title.Parent = Panel

    local Content = Instance.new("TextLabel")
    Content.Font = Enum.Font.Gotham
    Content.Text = config.Content
    Content.TextSize = 12
    Content.TextColor3 = Color3.fromRGB(255, 255, 255)
    Content.TextTransparency = 0
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.BackgroundTransparency = 1
    Content.RichText = true
    Content.Position = UDim2.new(0, 10, 0, 28)
    Content.Size = UDim2.new(1, -20, 0, 14)
    Content.Parent = Panel

    local InputBox
    if config.Placeholder then
        local InputFrame = Instance.new("Frame")
        InputFrame.AnchorPoint = Vector2.new(0.5, 0)
        InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrame.BackgroundTransparency = 0.95
        InputFrame.Position = UDim2.new(0.5, 0, 0, 48)
        InputFrame.Size = UDim2.new(1, -20, 0, 30)
        InputFrame.Parent = Panel

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 4)
        inputCorner.Parent = InputFrame

        InputBox = Instance.new("TextBox")
        InputBox.Font = Enum.Font.GothamBold
        InputBox.PlaceholderText = config.Placeholder
        InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputBox.Text = config.Default
        InputBox.TextSize = 11
        InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputBox.BackgroundTransparency = 1
        InputBox.TextXAlignment = Enum.TextXAlignment.Left
        InputBox.Size = UDim2.new(1, -10, 1, -6)
        InputBox.Position = UDim2.new(0, 5, 0, 3)
        InputBox.Parent = InputFrame
    end

    local yBtn = config.Placeholder and 88 or 48

    local ButtonMain = Instance.new("TextButton")
    ButtonMain.Font = Enum.Font.GothamBold
    ButtonMain.Text = config.ButtonText
    ButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.TextSize = 12
    ButtonMain.TextTransparency = 0.3
    ButtonMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.BackgroundTransparency = 0.935
    ButtonMain.Size = config.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
    ButtonMain.Position = UDim2.new(0, 10, 0, yBtn)
    ButtonMain.Parent = Panel

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = ButtonMain

    ButtonMain.MouseButton1Click:Connect(function()
        config.ButtonCallback(InputBox and InputBox.Text or "")
    end)

    if config.SubButtonText then
        local SubButton = Instance.new("TextButton")
        SubButton.Font = Enum.Font.GothamBold
        SubButton.Text = config.SubButtonText
        SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.TextSize = 12
        SubButton.TextTransparency = 0.3
        SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.BackgroundTransparency = 0.935
        SubButton.Size = UDim2.new(0.5, -12, 0, 30)
        SubButton.Position = UDim2.new(0.5, 2, 0, yBtn)
        SubButton.Parent = Panel

        local subCorner = Instance.new("UICorner")
        subCorner.CornerRadius = UDim.new(0, 6)
        subCorner.Parent = SubButton

        SubButton.MouseButton1Click:Connect(function()
            config.SubButtonCallback(InputBox and InputBox.Text or "")
        end)
    end

    if InputBox then
        InputBox.FocusLost:Connect(function()
            PanelFunc.Value = InputBox.Text
            configData[configKey] = InputBox.Text
            SaveConfigFunc()
        end)
    end

    function PanelFunc:GetInput()
        return InputBox and InputBox.Text or ""
    end

    return PanelFunc
end

return PanelModule
