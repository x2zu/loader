-- input.lua
local InputModule = {}

local MainColor = Color3.fromRGB(255, 0, 255)
local SaveConfigFunc = function() end
local ConfigData = {}

function InputModule.Initialize(color, saveFunc, config)
    MainColor = color or MainColor
    SaveConfigFunc = saveFunc or function() end
    ConfigData = config or {}
end

function InputModule.Create(parent, config, countItem, updateSizeCallback, saveConfig, configData)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or ""
    config.Callback = config.Callback or function() end
    config.Default = config.Default or ""

    local configKey = "Input_" .. config.Title
    if configData and configData[configKey] ~= nil then
        config.Default = configData[configKey]
    end

    local InputFunc = { Value = config.Default }

    local Input = Instance.new("Frame");
    local UICorner12 = Instance.new("UICorner");
    local InputTitle = Instance.new("TextLabel");
    local InputContent = Instance.new("TextLabel");
    local InputFrame = Instance.new("Frame");
    local UICorner13 = Instance.new("UICorner");
    local InputTextBox = Instance.new("TextBox");

    Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Input.BackgroundTransparency = 0.935
    Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Input.BorderSizePixel = 0
    Input.LayoutOrder = countItem
    Input.Size = UDim2.new(1, 0, 0, 46)
    Input.Name = "Input"
    Input.Parent = parent

    UICorner12.CornerRadius = UDim.new(0, 4)
    UICorner12.Parent = Input

    InputTitle.Font = Enum.Font.GothamBold
    InputTitle.Text = config.Title or "TextBox"
    InputTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    InputTitle.TextSize = 13
    InputTitle.TextXAlignment = Enum.TextXAlignment.Left
    InputTitle.TextYAlignment = Enum.TextYAlignment.Top
    InputTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputTitle.BackgroundTransparency = 0.999
    InputTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InputTitle.BorderSizePixel = 0
    InputTitle.Position = UDim2.new(0, 10, 0, 10)
    InputTitle.Size = UDim2.new(1, -180, 0, 13)
    InputTitle.Name = "InputTitle"
    InputTitle.Parent = Input

    InputContent.Font = Enum.Font.GothamBold
    InputContent.Text = config.Content or "This is a TextBox"
    InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputContent.TextSize = 12
    InputContent.TextTransparency = 0.6
    InputContent.TextWrapped = true
    InputContent.TextXAlignment = Enum.TextXAlignment.Left
    InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
    InputContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputContent.BackgroundTransparency = 0.999
    InputContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InputContent.BorderSizePixel = 0
    InputContent.Position = UDim2.new(0, 10, 0, 25)
    InputContent.Size = UDim2.new(1, -180, 0, 12)
    InputContent.Name = "InputContent"
    InputContent.Parent = Input

    InputContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (InputContent.TextBounds.X // InputContent.AbsoluteSize.X)))
    InputContent.TextWrapped = true
    Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)

    InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        InputContent.TextWrapped = false
        InputContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (InputContent.TextBounds.X // InputContent.AbsoluteSize.X)))
        Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
        InputContent.TextWrapped = true
        if updateSizeCallback then updateSizeCallback() end
    end)

    InputFrame.AnchorPoint = Vector2.new(1, 0.5)
    InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputFrame.BackgroundTransparency = 0.95
    InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InputFrame.BorderSizePixel = 0
    InputFrame.ClipsDescendants = true
    InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
    InputFrame.Size = UDim2.new(0, 148, 0, 30)
    InputFrame.Name = "InputFrame"
    InputFrame.Parent = Input

    UICorner13.CornerRadius = UDim.new(0, 4)
    UICorner13.Parent = InputFrame

    InputTextBox.CursorPosition = -1
    InputTextBox.Font = Enum.Font.GothamBold
    InputTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    InputTextBox.PlaceholderText = "Input Here"
    InputTextBox.Text = config.Default
    InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputTextBox.TextSize = 12
    InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
    InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
    InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputTextBox.BackgroundTransparency = 0.999
    InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InputTextBox.BorderSizePixel = 0
    InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
    InputTextBox.Size = UDim2.new(1, -10, 1, -8)
    InputTextBox.Name = "InputTextBox"
    InputTextBox.Parent = InputFrame
    
    function InputFunc:Set(Value)
        InputTextBox.Text = Value
        InputFunc.Value = Value
        config.Callback(Value)
        configData[configKey] = Value
        SaveConfigFunc()
    end

    InputFunc:Set(InputFunc.Value)

    InputTextBox.FocusLost:Connect(function()
        InputFunc:Set(InputTextBox.Text)
    end)
    
    return InputFunc
end

return InputModule
