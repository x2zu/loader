-- slider.lua
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local SliderModule = {}

local MainColor = Color3.fromRGB(255, 0, 255)
local SaveConfigFunc = function() end
local ConfigData = {}

function SliderModule.Initialize(color, saveFunc, config)
    MainColor = color or MainColor
    SaveConfigFunc = saveFunc or function() end
    ConfigData = config or {}
end

function SliderModule.Create(parent, config, countItem, updateSizeCallback, saveConfig, configData)
    config = config or {}
    config.Title = config.Title or "Slider"
    config.Content = config.Content or ""
    config.Increment = config.Increment or 1
    config.Min = config.Min or 0
    config.Max = config.Max or 100
    config.Default = config.Default or 50
    config.Callback = config.Callback or function() end

    local configKey = "Slider_" .. config.Title
    if configData and configData[configKey] ~= nil then
        config.Default = configData[configKey]
    end

    local SliderFunc = { Value = config.Default }

    local Slider = Instance.new("Frame");
    local UICorner15 = Instance.new("UICorner");
    local SliderTitle = Instance.new("TextLabel");
    local SliderContent = Instance.new("TextLabel");
    local SliderInput = Instance.new("Frame");
    local UICorner16 = Instance.new("UICorner");
    local TextBox = Instance.new("TextBox");
    local SliderFrame = Instance.new("Frame");
    local UICorner17 = Instance.new("UICorner");
    local SliderDraggable = Instance.new("Frame");
    local UICorner18 = Instance.new("UICorner");
    local UIStroke5 = Instance.new("UIStroke");
    local SliderCircle = Instance.new("Frame");
    local UICorner19 = Instance.new("UICorner");
    local UIStroke6 = Instance.new("UIStroke");
    local UIStroke7 = Instance.new("UIStroke");

    Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slider.BackgroundTransparency = 0.935
    Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Slider.BorderSizePixel = 0
    Slider.LayoutOrder = countItem
    Slider.Size = UDim2.new(1, 0, 0, 46)
    Slider.Name = "Slider"
    Slider.Parent = parent

    UICorner15.CornerRadius = UDim.new(0, 4)
    UICorner15.Parent = Slider

    SliderTitle.Font = Enum.Font.GothamBold
    SliderTitle.Text = config.Title
    SliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    SliderTitle.TextSize = 13
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
    SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderTitle.BackgroundTransparency = 0.999
    SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderTitle.BorderSizePixel = 0
    SliderTitle.Position = UDim2.new(0, 10, 0, 10)
    SliderTitle.Size = UDim2.new(1, -180, 0, 13)
    SliderTitle.Name = "SliderTitle"
    SliderTitle.Parent = Slider

    SliderContent.Font = Enum.Font.GothamBold
    SliderContent.Text = config.Content
    SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderContent.TextSize = 12
    SliderContent.TextTransparency = 0.6
    SliderContent.TextXAlignment = Enum.TextXAlignment.Left
    SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
    SliderContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderContent.BackgroundTransparency = 0.999
    SliderContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderContent.BorderSizePixel = 0
    SliderContent.Position = UDim2.new(0, 10, 0, 25)
    SliderContent.Size = UDim2.new(1, -180, 0, 12)
    SliderContent.Name = "SliderContent"
    SliderContent.Parent = Slider

    SliderContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
    SliderContent.TextWrapped = true
    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)

    SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        SliderContent.TextWrapped = false
        SliderContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
        Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
        SliderContent.TextWrapped = true
        if updateSizeCallback then updateSizeCallback() end
    end)

    SliderInput.AnchorPoint = Vector2.new(0, 0.5)
    SliderInput.BackgroundColor3 = MainColor
    SliderInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderInput.BackgroundTransparency = 1
    SliderInput.BorderSizePixel = 0
    SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
    SliderInput.Size = UDim2.new(0, 28, 0, 20)
    SliderInput.Name = "SliderInput"
    SliderInput.Parent = Slider

    UICorner16.CornerRadius = UDim.new(0, 2)
    UICorner16.Parent = SliderInput

    TextBox.Font = Enum.Font.GothamBold
    TextBox.Text = "90"
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 13
    TextBox.TextWrapped = true
    TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.BackgroundTransparency = 0.999
    TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0, -1, 0, 0)
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.Parent = SliderInput

    SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFrame.BackgroundTransparency = 0.8
    SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
    SliderFrame.Size = UDim2.new(0, 100, 0, 3)
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Parent = Slider

    UICorner17.Parent = SliderFrame

    SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
    SliderDraggable.BackgroundColor3 = MainColor
    SliderDraggable.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderDraggable.BorderSizePixel = 0
    SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
    SliderDraggable.Size = UDim2.new(0.9, 0, 0, 1)
    SliderDraggable.Name = "SliderDraggable"
    SliderDraggable.Parent = SliderFrame

    UICorner18.Parent = SliderDraggable

    SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
    SliderCircle.BackgroundColor3 = MainColor
    SliderCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderCircle.BorderSizePixel = 0
    SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
    SliderCircle.Size = UDim2.new(0, 8, 0, 8)
    SliderCircle.Name = "SliderCircle"
    SliderCircle.Parent = SliderDraggable

    UICorner19.Parent = SliderCircle

    UIStroke6.Color = MainColor
    UIStroke6.Parent = SliderCircle

    local Dragging = false
    local function Round(Number, Factor)
        local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
        if Result < 0 then
            Result = Result + Factor
        end
        return Result
    end
    
    function SliderFunc:Set(Value)
        Value = math.clamp(Round(Value, config.Increment), config.Min, config.Max)
        SliderFunc.Value = Value
        TextBox.Text = tostring(Value)
        TweenService:Create(
            SliderDraggable,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale((Value - config.Min) / (config.Max - config.Min), 1) }
        ):Play()

        config.Callback(Value)
        configData[configKey] = Value
        SaveConfigFunc()
    end

    SliderFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            TweenService:Create(
                SliderCircle,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, 14, 0, 14) }
            ):Play()
            local SizeScale = math.clamp(
                (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                0,
                1
            )
            SliderFunc:Set(config.Min + ((config.Max - config.Min) * SizeScale))
        end
    end)

    SliderFrame.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            config.Callback(SliderFunc.Value)
            TweenService:Create(
                SliderCircle,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, 8, 0, 8) }
            ):Play()
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local SizeScale = math.clamp(
                (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                0,
                1
            )
            SliderFunc:Set(config.Min + ((config.Max - config.Min) * SizeScale))
        end
    end)

    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local Valid = TextBox.Text:gsub("[^%d]", "")
        if Valid ~= "" then
            local ValidNumber = math.clamp(tonumber(Valid), config.Min, config.Max)
            SliderFunc:Set(ValidNumber)
        else
            SliderFunc:Set(config.Min)
        end
    end)
    
    SliderFunc:Set(config.Default)
    return SliderFunc
end

return SliderModule
