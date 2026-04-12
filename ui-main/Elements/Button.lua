-- Button.lua
local TweenService = game:GetService("TweenService")

local ButtonModule = {}

local MainColor = Color3.fromRGB(255, 0, 255)

function ButtonModule.Initialize(color, saveFunc, config)
    MainColor = color or MainColor
end

function ButtonModule.Create(parent, config, countItem, updateSizeCallback)
    config = config or {}
    config.Title = config.Title or "Confirm"
    config.Callback = config.Callback or function() end
    config.SubTitle = config.SubTitle or nil
    config.SubCallback = config.SubCallback or function() end

    local Button = Instance.new("Frame")
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundTransparency = 0.935
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.LayoutOrder = countItem
    Button.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Button

    local MainButton = Instance.new("TextButton")
    MainButton.Font = Enum.Font.GothamBold
    MainButton.Text = config.Title
    MainButton.TextSize = 12
    MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.TextTransparency = 0.3
    MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.BackgroundTransparency = 0.935
    MainButton.Size = config.SubTitle and UDim2.new(0.5, -8, 1, -10) or UDim2.new(1, -12, 1, -10)
    MainButton.Position = UDim2.new(0, 6, 0, 5)
    MainButton.Parent = Button

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 4)
    mainCorner.Parent = MainButton

    MainButton.MouseButton1Click:Connect(config.Callback)

    if config.SubTitle then
        local SubButton = Instance.new("TextButton")
        SubButton.Font = Enum.Font.GothamBold
        SubButton.Text = config.SubTitle
        SubButton.TextSize = 12
        SubButton.TextTransparency = 0.3
        SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.BackgroundTransparency = 0.935
        SubButton.Size = UDim2.new(0.5, -8, 1, -10)
        SubButton.Position = UDim2.new(0.5, 2, 0, 5)
        SubButton.Parent = Button

        local subCorner = Instance.new("UICorner")
        subCorner.CornerRadius = UDim.new(0, 4)
        subCorner.Parent = SubButton

        SubButton.MouseButton1Click:Connect(config.SubCallback)
    end

    return {Click = config.Callback}
end

return ButtonModule
