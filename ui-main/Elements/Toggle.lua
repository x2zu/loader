-- toggle.lua - V2.0 (Fixed)
local TweenService = game:GetService("TweenService")

local ToggleModule = {}

local MainColor = Color3.fromRGB(255, 0, 255)
local SaveConfigFunc = function() end
local ConfigData = {}

function ToggleModule.Initialize(color, saveFunc, config)
    MainColor = color or MainColor
    SaveConfigFunc = saveFunc or function() end
    ConfigData = config or {}
end

function ToggleModule.Create(parent, config, countItem, updateSizeCallback, saveConfig, configData)
    -- Validasi parameter
    if not parent then
        warn("Toggle.Create: parent is nil")
        return
    end
    
    config = config or {}
    config.Title = config.Title or "Title"
    config.Title2 = config.Title2 or ""
    config.Content = config.Content or ""
    config.Default = config.Default or false
    config.Callback = config.Callback or function() end

    local configKey = "Toggle_" .. config.Title
    if configData and configData[configKey] ~= nil then
        config.Default = configData[configKey]
    end

    local ToggleFunc = { Value = config.Default }

    -- Buat semua instance dengan pengecekan
    local Toggle = Instance.new("Frame")
    local UICorner20 = Instance.new("UICorner")
    local ToggleTitle = Instance.new("TextLabel")
    local ToggleContent = Instance.new("TextLabel")
    local ToggleButton = Instance.new("TextButton")
    local FeatureFrame2 = Instance.new("Frame")
    local UICorner22 = Instance.new("UICorner")
    local UIStroke8 = Instance.new("UIStroke")
    local ToggleCircle = Instance.new("Frame")
    local UICorner23 = Instance.new("UICorner")
    local ToggleTitle2 = Instance.new("TextLabel")  -- Pindah ke sini

    -- Set properties dengan pengecekan
    Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.BackgroundTransparency = 0.935
    Toggle.BorderSizePixel = 0
    Toggle.LayoutOrder = countItem or 0
    Toggle.Name = "Toggle"
    Toggle.Parent = parent

    UICorner20.CornerRadius = UDim.new(0, 4)
    UICorner20.Parent = Toggle

    ToggleTitle.Font = Enum.Font.GothamBold
    ToggleTitle.Text = config.Title
    ToggleTitle.TextSize = 13
    ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
    ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
    ToggleTitle.Name = "ToggleTitle"
    ToggleTitle.Parent = Toggle

    ToggleTitle2.Font = Enum.Font.GothamBold
    ToggleTitle2.Text = config.Title2
    ToggleTitle2.TextSize = 12
    ToggleTitle2.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle2.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle2.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle2.BackgroundTransparency = 1
    ToggleTitle2.Position = UDim2.new(0, 10, 0, 23)
    ToggleTitle2.Size = UDim2.new(1, -100, 0, 12)
    ToggleTitle2.Name = "ToggleTitle2"
    ToggleTitle2.Parent = Toggle

    ToggleContent.Font = Enum.Font.GothamBold
    ToggleContent.Text = config.Content
    ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleContent.TextSize = 12
    ToggleContent.TextTransparency = 0.6
    ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
    ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
    ToggleContent.BackgroundTransparency = 1
    ToggleContent.Size = UDim2.new(1, -100, 0, 12)
    ToggleContent.Name = "ToggleContent"
    ToggleContent.Parent = Toggle

    -- Set ukuran berdasarkan konten
    if config.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, 57)
        ToggleContent.Position = UDim2.new(0, 10, 0, 36)
        ToggleTitle2.Visible = true
    else
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        ToggleContent.Position = UDim2.new(0, 10, 0, 23)
        ToggleTitle2.Visible = false
    end

    -- Hitung ukuran konten dengan aman
    local textBoundsX = 0
    local success, bounds = pcall(function()
        return ToggleContent.TextBounds.X
    end)
    if success then
        textBoundsX = bounds
    end
    
    local absoluteSizeX = 1
    success, bounds = pcall(function()
        return ToggleContent.AbsoluteSize.X
    end)
    if success and bounds > 0 then
        absoluteSizeX = bounds
    end

    local extraLines = math.floor(textBoundsX / math.max(1, absoluteSizeX))
    ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * extraLines))
    ToggleContent.TextWrapped = true
    
    if config.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
    else
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
    end

    -- Signal untuk update ukuran
    ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ToggleContent.TextWrapped = false
        local newExtraLines = math.floor(ToggleContent.TextBounds.X / math.max(1, ToggleContent.AbsoluteSize.X))
        ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * newExtraLines))
        if config.Title2 ~= "" then
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
        else
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
        end
        ToggleContent.TextWrapped = true
        if updateSizeCallback and type(updateSizeCallback) == "function" then
            updateSizeCallback()
        end
    end)

    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Text = ""
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = Toggle

    FeatureFrame2.AnchorPoint = Vector2.new(1, 0.5)
    FeatureFrame2.BackgroundTransparency = 0.92
    FeatureFrame2.BorderSizePixel = 0
    FeatureFrame2.Position = UDim2.new(1, -15, 0.5, 0)
    FeatureFrame2.Size = UDim2.new(0, 30, 0, 15)
    FeatureFrame2.Name = "FeatureFrame"
    FeatureFrame2.Parent = Toggle

    UICorner22.CornerRadius = UDim.new(0, 15)
    UICorner22.Parent = FeatureFrame2

    UIStroke8.Color = Color3.fromRGB(255, 255, 255)
    UIStroke8.Thickness = 2
    UIStroke8.Transparency = 0.9
    UIStroke8.Parent = FeatureFrame2

    ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
    ToggleCircle.Name = "ToggleCircle"
    ToggleCircle.Parent = FeatureFrame2

    UICorner23.CornerRadius = UDim.new(0, 15)
    UICorner23.Parent = ToggleCircle

    ToggleButton.Activated:Connect(function()
        ToggleFunc.Value = not ToggleFunc.Value
        ToggleFunc:Set(ToggleFunc.Value)
    end)

    function ToggleFunc:Set(Value)
        if type(config.Callback) == "function" then
            local ok, err = pcall(function()
                config.Callback(Value)
            end)
            if not ok then warn("Toggle Callback error:", err) end
        end
        
        if configData then
            configData[configKey] = Value
        end
        if SaveConfigFunc and type(SaveConfigFunc) == "function" then
            SaveConfigFunc()
        end
        
        if Value then
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = MainColor }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = MainColor, Transparency = 0 }):Play()
            TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
                { BackgroundColor3 = MainColor, BackgroundTransparency = 0 }):Play()
        else
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2),
                { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2),
                { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
            TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
                { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
        end
    end

    ToggleFunc:Set(ToggleFunc.Value)
    return ToggleFunc
end

return ToggleModule
