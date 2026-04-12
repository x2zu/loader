-- Elements.lua V0.0.5
-- UI Elements Module for NexaHub
-- Added: Button Click Highlight Animations
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Elements = {}

-- Import required functions from main library
local SaveConfig, ConfigData, GuiConfig, Icons

function Elements:Initialize(config, saveFunc, configData, icons)
    GuiConfig = config
    SaveConfig = saveFunc
    ConfigData = configData
    Icons = icons
end

-- Helper function for button click animation
local function AnimateButtonClick(button, color)
    color = color or GuiConfig.Color
    
    -- Create highlight effect
    local originalTransparency = button.BackgroundTransparency
    local originalColor = button.BackgroundColor3
    
    -- Flash effect on click
    TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.7,
        BackgroundColor3 = color
    }):Play()
    
    task.wait(0.1)
    
    TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = originalTransparency,
        BackgroundColor3 = originalColor
    }):Play()
end

--[[
    PERBAIKAN: CreateParagraph - Button sekarang full-width dan paragraph menyesuaikan height
    TAMBAHAN: Animasi highlight saat button diklik
]]
function Elements:CreateParagraph(parent, config, countItem)
    local ParagraphConfig = config or {}
    ParagraphConfig.Title = ParagraphConfig.Title or "Title"
    ParagraphConfig.Content = ParagraphConfig.Content or "Content"
    local ParagraphFunc = {}

    local Paragraph = Instance.new("Frame")
    local UICorner14 = Instance.new("UICorner")
    local ParagraphTitle = Instance.new("TextLabel")
    local ParagraphContent = Instance.new("TextLabel")

    Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Paragraph.BackgroundTransparency = 0.935
    Paragraph.BorderSizePixel = 0
    Paragraph.LayoutOrder = countItem
    Paragraph.Size = UDim2.new(1, 0, 0, 46)
    Paragraph.Name = "Paragraph"
    Paragraph.Parent = parent

    UICorner14.CornerRadius = UDim.new(0, 4)
    UICorner14.Parent = Paragraph

    local iconOffset = 10
    if ParagraphConfig.Icon then
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.Position = UDim2.new(0, 8, 0, 12)
        IconImg.BackgroundTransparency = 1
        IconImg.Name = "ParagraphIcon"
        IconImg.Parent = Paragraph

        if Icons and Icons[ParagraphConfig.Icon] then
            IconImg.Image = Icons[ParagraphConfig.Icon]
        else
            IconImg.Image = ParagraphConfig.Icon
        end

        iconOffset = 30
    end

    ParagraphTitle.Font = Enum.Font.GothamBold
    ParagraphTitle.Text = ParagraphConfig.Title
    ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ParagraphTitle.TextSize = 13
    ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTitle.BackgroundTransparency = 1
    ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
    ParagraphTitle.Size = UDim2.new(1, -(iconOffset + 6), 0, 13)
    ParagraphTitle.Name = "ParagraphTitle"
    ParagraphTitle.Parent = Paragraph

    ParagraphContent.Font = Enum.Font.Gotham
    ParagraphContent.Text = ParagraphConfig.Content
    ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ParagraphContent.TextSize = 12
    ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphContent.BackgroundTransparency = 1
    ParagraphContent.Position = UDim2.new(0, iconOffset, 0, 26)
    ParagraphContent.Name = "ParagraphContent"
    ParagraphContent.TextWrapped = true  -- Enable text wrapping
    ParagraphContent.RichText = true
    ParagraphContent.Parent = Paragraph

    -- Set proper width for content to wrap correctly
    ParagraphContent.Size = UDim2.new(1, -(iconOffset + 6), 1, 0)

    local ParagraphButton
    if ParagraphConfig.ButtonText then
        ParagraphButton = Instance.new("TextButton")
        -- PERBAIKAN: Button sekarang full-width dengan padding yang sama
        ParagraphButton.Size = UDim2.new(1, -20, 0, 28)  -- Full width minus padding
        ParagraphButton.Position = UDim2.new(0, 10, 0, 0)  -- Will be updated by UpdateSize
        ParagraphButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.BackgroundTransparency = 0.935
        ParagraphButton.Font = Enum.Font.GothamBold
        ParagraphButton.TextSize = 12
        ParagraphButton.TextTransparency = 0.3
        ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.Text = ParagraphConfig.ButtonText
        ParagraphButton.Parent = Paragraph

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = ParagraphButton

        -- ANIMASI HIGHLIGHT
        ParagraphButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(ParagraphButton)
            if ParagraphConfig.ButtonCallback then
                ParagraphConfig.ButtonCallback()
            end
        end)
    end

    local function UpdateSize()
        -- Wait for text to be rendered and measure actual bounds
        task.wait()
        
        -- Calculate content height based on TextBounds
        local contentHeight = math.max(12, ParagraphContent.TextBounds.Y)
        
        -- Update content label size to fit text
        ParagraphContent.Size = UDim2.new(1, -(iconOffset + 6), 0, contentHeight)
        
        -- Calculate total height: title (10) + title height (13) + spacing (3) + content height + bottom padding (10)
        local totalHeight = 10 + 13 + 3 + contentHeight + 10
        
        if ParagraphButton then
            -- Position button below content with proper spacing
            local buttonY = 10 + 13 + 3 + contentHeight + 8
            ParagraphButton.Position = UDim2.new(0, 10, 0, buttonY)
            -- Add button height + spacing to total
            totalHeight = buttonY + ParagraphButton.Size.Y.Offset + 10
        end
        
        Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
    end

    -- Initial size update
    UpdateSize()
    
    -- Update size when content changes
    ParagraphContent:GetPropertyChangedSignal("Text"):Connect(UpdateSize)
    ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
    Paragraph:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)

    function ParagraphFunc:SetContent(content)
        content = content or "Content"
        ParagraphContent.Text = content
        -- UpdateSize will be called automatically via signals
    end

    return ParagraphFunc
end

--[[
    CreateEditableParagraph - Paragraph dengan TextBox yang bisa diedit
    Teks otomatis menyesuaikan tinggi dan support teks panjang
]]
function Elements:CreateEditableParagraph(parent, config, countItem)
    local ParagraphConfig = config or {}
    ParagraphConfig.Title = ParagraphConfig.Title or "Title"
    ParagraphConfig.Content = ParagraphConfig.Content or "Type here..."
    ParagraphConfig.Placeholder = ParagraphConfig.Placeholder or "Type something..."
    ParagraphConfig.Callback = ParagraphConfig.Callback or function() end
    ParagraphConfig.Default = ParagraphConfig.Default or ""
    
    local configKey = "EditableParagraph_" .. ParagraphConfig.Title
    if ConfigData[configKey] ~= nil then
        ParagraphConfig.Default = ConfigData[configKey]
    end

    local ParagraphFunc = { Value = ParagraphConfig.Default }

    local Paragraph = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local ParagraphTitle = Instance.new("TextLabel")
    local TextBoxFrame = Instance.new("Frame")
    local TextBoxCorner = Instance.new("UICorner")
    local ParagraphTextBox = Instance.new("TextBox")

    Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Paragraph.BackgroundTransparency = 0.935
    Paragraph.BorderSizePixel = 0
    Paragraph.LayoutOrder = countItem
    Paragraph.Size = UDim2.new(1, 0, 0, 80)
    Paragraph.Name = "EditableParagraph"
    Paragraph.Parent = parent

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Paragraph

    local iconOffset = 10
    if ParagraphConfig.Icon then
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.Position = UDim2.new(0, 8, 0, 10)
        IconImg.BackgroundTransparency = 1
        IconImg.Name = "ParagraphIcon"
        IconImg.Parent = Paragraph

        if Icons and Icons[ParagraphConfig.Icon] then
            IconImg.Image = Icons[ParagraphConfig.Icon]
        else
            IconImg.Image = ParagraphConfig.Icon
        end

        iconOffset = 35
    end

    ParagraphTitle.Font = Enum.Font.GothamBold
    ParagraphTitle.Text = ParagraphConfig.Title
    ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ParagraphTitle.TextSize = 13
    ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTitle.BackgroundTransparency = 1
    ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
    ParagraphTitle.Size = UDim2.new(1, -iconOffset - 10, 0, 13)
    ParagraphTitle.Name = "ParagraphTitle"
    ParagraphTitle.Parent = Paragraph

    TextBoxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBoxFrame.BackgroundTransparency = 0.95
    TextBoxFrame.BorderSizePixel = 0
    TextBoxFrame.Position = UDim2.new(0, 10, 0, 30)
    TextBoxFrame.Size = UDim2.new(1, -20, 0, 40)
    TextBoxFrame.Name = "TextBoxFrame"
    TextBoxFrame.Parent = Paragraph

    TextBoxCorner.CornerRadius = UDim.new(0, 4)
    TextBoxCorner.Parent = TextBoxFrame

    ParagraphTextBox.Font = Enum.Font.Gotham
    ParagraphTextBox.PlaceholderText = ParagraphConfig.Placeholder
    ParagraphTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    ParagraphTextBox.Text = ParagraphConfig.Default
    ParagraphTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ParagraphTextBox.TextSize = 12
    ParagraphTextBox.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTextBox.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTextBox.BackgroundTransparency = 1
    ParagraphTextBox.Position = UDim2.new(0, 8, 0, 6)
    ParagraphTextBox.Size = UDim2.new(1, -16, 1, -12)
    ParagraphTextBox.Name = "ParagraphTextBox"
    ParagraphTextBox.TextWrapped = true
    ParagraphTextBox.MultiLine = true
    ParagraphTextBox.ClearTextOnFocus = false
    ParagraphTextBox.RichText = false
    ParagraphTextBox.Parent = TextBoxFrame

    local ParagraphButton
    if ParagraphConfig.ButtonText then
        ParagraphButton = Instance.new("TextButton")
        ParagraphButton.Size = UDim2.new(1, -20, 0, 28)
        ParagraphButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.BackgroundTransparency = 0.935
        ParagraphButton.Font = Enum.Font.GothamBold
        ParagraphButton.TextSize = 12
        ParagraphButton.TextTransparency = 0.3
        ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.Text = ParagraphConfig.ButtonText
        ParagraphButton.Position = UDim2.new(0, 10, 0, 75)
        ParagraphButton.Parent = Paragraph

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = ParagraphButton

        ParagraphButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(ParagraphButton)
            if ParagraphConfig.ButtonCallback then
                ParagraphConfig.ButtonCallback(ParagraphTextBox.Text)
            end
        end)
    end

    local function UpdateSize()
        -- Calculate required height for text
        local textHeight = math.max(40, ParagraphTextBox.TextBounds.Y + 12)
        TextBoxFrame.Size = UDim2.new(1, -20, 0, textHeight)
        
        local totalHeight = 30 + textHeight + 10  -- Title + TextBox + padding
        
        if ParagraphButton then
            ParagraphButton.Position = UDim2.new(0, 10, 0, 30 + textHeight + 5)
            totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 10
        end
        
        Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
    end

    -- Initial size update
    UpdateSize()
    
    -- Update size when text changes
    ParagraphTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateSize()
        ParagraphFunc.Value = ParagraphTextBox.Text
        ConfigData[configKey] = ParagraphTextBox.Text
        SaveConfig()
        
        if ParagraphConfig.Callback then
            ParagraphConfig.Callback(ParagraphTextBox.Text)
        end
    end)

    ParagraphTextBox:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
    Paragraph:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)

    function ParagraphFunc:SetContent(content)
        content = content or ""
        ParagraphTextBox.Text = content
    end

    function ParagraphFunc:GetContent()
        return ParagraphTextBox.Text
    end

    return ParagraphFunc
end

function Elements:CreatePanel(parent, config, countItem)
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
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local PanelFunc = { Value = config.Default }

    local baseHeight = 50
    if config.Placeholder then
        baseHeight = baseHeight + 40
    end
    if config.SubButtonText then
        baseHeight = baseHeight + 40
    else
        baseHeight = baseHeight + 36
    end

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

    -- ANIMASI HIGHLIGHT
    ButtonMain.MouseButton1Click:Connect(function()
        AnimateButtonClick(ButtonMain)
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

        -- ANIMASI HIGHLIGHT
        SubButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(SubButton)
            config.SubButtonCallback(InputBox and InputBox.Text or "")
        end)
    end

    if InputBox then
        InputBox.FocusLost:Connect(function()
            PanelFunc.Value = InputBox.Text
            ConfigData[configKey] = InputBox.Text
            SaveConfig()
        end)
    end

    function PanelFunc:GetInput()
        return InputBox and InputBox.Text or ""
    end

    return PanelFunc
end

function Elements:CreateButton(parent, config, countItem)
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

    -- ANIMASI HIGHLIGHT
    MainButton.MouseButton1Click:Connect(function()
        AnimateButtonClick(MainButton)
        config.Callback()
    end)

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

        -- ANIMASI HIGHLIGHT
        SubButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(SubButton)
            config.SubCallback()
        end)
    end
end

function Elements:CreateToggle(parent, config, countItem, updateSectionSize, Elements_Table)
    local ToggleConfig = config or {}
    ToggleConfig.Title = ToggleConfig.Title or "Title"
    ToggleConfig.Title2 = ToggleConfig.Title2 or ""
    ToggleConfig.Content = ToggleConfig.Content or ""
    ToggleConfig.Default = ToggleConfig.Default or false
    ToggleConfig.Callback = ToggleConfig.Callback or function() end

    local configKey = "Toggle_" .. ToggleConfig.Title
    if ConfigData[configKey] ~= nil then
        ToggleConfig.Default = ConfigData[configKey]
    end

    local ToggleFunc = { Value = ToggleConfig.Default }

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

    Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.BackgroundTransparency = 0.935
    Toggle.BorderSizePixel = 0
    Toggle.LayoutOrder = countItem
    Toggle.Name = "Toggle"
    Toggle.Parent = parent

    UICorner20.CornerRadius = UDim.new(0, 4)
    UICorner20.Parent = Toggle

    ToggleTitle.Font = Enum.Font.GothamBold
    ToggleTitle.Text = ToggleConfig.Title
    ToggleTitle.TextSize = 13
    ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
    ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
    ToggleTitle.Name = "ToggleTitle"
    ToggleTitle.Parent = Toggle

    local ToggleTitle2 = Instance.new("TextLabel")
    ToggleTitle2.Font = Enum.Font.GothamBold
    ToggleTitle2.Text = ToggleConfig.Title2
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
    ToggleContent.Text = ToggleConfig.Content
    ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleContent.TextSize = 12
    ToggleContent.TextTransparency = 0.6
    ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
    ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
    ToggleContent.BackgroundTransparency = 1
    ToggleContent.Size = UDim2.new(1, -100, 0, 12)
    ToggleContent.Name = "ToggleContent"
    ToggleContent.Parent = Toggle

    if ToggleConfig.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, 57)
        ToggleContent.Position = UDim2.new(0, 10, 0, 36)
        ToggleTitle2.Visible = true
    else
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        ToggleContent.Position = UDim2.new(0, 10, 0, 23)
        ToggleTitle2.Visible = false
    end

    ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
    ToggleContent.TextWrapped = true
    if ToggleConfig.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
    else
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
    end

    ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ToggleContent.TextWrapped = false
        ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
        if ToggleConfig.Title2 ~= "" then
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
        else
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
        end
        updateSectionSize()
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
        if typeof(ToggleConfig.Callback) == "function" then
            local ok, err = pcall(function()
                ToggleConfig.Callback(Value)
            end)
            if not ok then warn("Toggle Callback error:", err) end
        end
        ConfigData[configKey] = Value
        SaveConfig()
        if Value then
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play()
            TweenService:Create(FeatureFrame2, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
        else
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
            TweenService:Create(FeatureFrame2, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
        end
    end

    ToggleFunc:Set(ToggleFunc.Value)
    Elements_Table[configKey] = ToggleFunc
    return ToggleFunc
end

function Elements:CreateSlider(parent, config, countItem, updateSectionSize, Elements_Table)
    local SliderConfig = config or {}
    SliderConfig.Title = SliderConfig.Title or "Slider"
    SliderConfig.Content = SliderConfig.Content or ""
    SliderConfig.Increment = SliderConfig.Increment or 1
    SliderConfig.Min = SliderConfig.Min or 0
    SliderConfig.Max = SliderConfig.Max or 100
    SliderConfig.Default = SliderConfig.Default or 50
    SliderConfig.Callback = SliderConfig.Callback or function() end

    local configKey = "Slider_" .. SliderConfig.Title
    if ConfigData[configKey] ~= nil then
        SliderConfig.Default = ConfigData[configKey]
    end

    local SliderFunc = { Value = SliderConfig.Default }

    local Slider = Instance.new("Frame")
    local UICorner15 = Instance.new("UICorner")
    local SliderTitle = Instance.new("TextLabel")
    local SliderContent = Instance.new("TextLabel")
    local SliderInput = Instance.new("Frame")
    local UICorner16 = Instance.new("UICorner")
    local TextBox = Instance.new("TextBox")
    local SliderFrame = Instance.new("Frame")
    local UICorner17 = Instance.new("UICorner")
    local SliderDraggable = Instance.new("Frame")
    local UICorner18 = Instance.new("UICorner")
    local SliderCircle = Instance.new("Frame")
    local UICorner19 = Instance.new("UICorner")
    local UIStroke6 = Instance.new("UIStroke")

    Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slider.BackgroundTransparency = 0.935
    Slider.BorderSizePixel = 0
    Slider.LayoutOrder = countItem
    Slider.Size = UDim2.new(1, 0, 0, 46)
    Slider.Name = "Slider"
    Slider.Parent = parent

    UICorner15.CornerRadius = UDim.new(0, 4)
    UICorner15.Parent = Slider

    SliderTitle.Font = Enum.Font.GothamBold
    SliderTitle.Text = SliderConfig.Title
    SliderTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    SliderTitle.TextSize = 13
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Position = UDim2.new(0, 10, 0, 10)
    SliderTitle.Size = UDim2.new(1, -180, 0, 13)
    SliderTitle.Name = "SliderTitle"
    SliderTitle.Parent = Slider

    SliderContent.Font = Enum.Font.GothamBold
    SliderContent.Text = SliderConfig.Content
    SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderContent.TextSize = 12
    SliderContent.TextTransparency = 0.6
    SliderContent.TextXAlignment = Enum.TextXAlignment.Left
    SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
    SliderContent.BackgroundTransparency = 1
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
        updateSectionSize()
    end)

    SliderInput.AnchorPoint = Vector2.new(0, 0.5)
    SliderInput.BackgroundColor3 = GuiConfig.Color
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
    TextBox.BackgroundTransparency = 1
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0, -1, 0, 0)
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.Parent = SliderInput

    SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFrame.BackgroundTransparency = 0.8
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
    SliderFrame.Size = UDim2.new(0, 100, 0, 3)
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Parent = Slider

    UICorner17.Parent = SliderFrame

    SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
    SliderDraggable.BackgroundColor3 = GuiConfig.Color
    SliderDraggable.BorderSizePixel = 0
    SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
    SliderDraggable.Size = UDim2.new(0.9, 0, 0, 1)
    SliderDraggable.Name = "SliderDraggable"
    SliderDraggable.Parent = SliderFrame

    UICorner18.Parent = SliderDraggable

    SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
    SliderCircle.BackgroundColor3 = GuiConfig.Color
    SliderCircle.BorderSizePixel = 0
    SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
    SliderCircle.Size = UDim2.new(0, 8, 0, 8)
    SliderCircle.Name = "SliderCircle"
    SliderCircle.Parent = SliderDraggable

    UICorner19.Parent = SliderCircle

    UIStroke6.Color = GuiConfig.Color
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
        Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
        SliderFunc.Value = Value
        TextBox.Text = tostring(Value)
        TweenService:Create(
            SliderDraggable,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1) }
        ):Play()

        SliderConfig.Callback(Value)
        ConfigData[configKey] = Value
        SaveConfig()
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
            SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
        end
    end)

    SliderFrame.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            SliderConfig.Callback(SliderFunc.Value)
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
            SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
        end
    end)

    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local Valid = TextBox.Text:gsub("[^%d]", "")
        if Valid ~= "" then
            local ValidNumber = math.clamp(tonumber(Valid), SliderConfig.Min, SliderConfig.Max)
            SliderFunc:Set(ValidNumber)
        else
            SliderFunc:Set(SliderConfig.Min)
        end
    end)

    SliderFunc:Set(SliderConfig.Default)
    Elements_Table[configKey] = SliderFunc
    return SliderFunc
end

function Elements:CreateInput(parent, config, countItem, updateSectionSize, Elements_Table)
    local InputConfig = config or {}
    InputConfig.Title = InputConfig.Title or "Title"
    InputConfig.Content = InputConfig.Content or ""
    InputConfig.Callback = InputConfig.Callback or function() end
    InputConfig.Default = InputConfig.Default or ""

    local configKey = "Input_" .. InputConfig.Title
    if ConfigData[configKey] ~= nil then
        InputConfig.Default = ConfigData[configKey]
    end

    local InputFunc = { Value = InputConfig.Default }

    local Input = Instance.new("Frame")
    local UICorner12 = Instance.new("UICorner")
    local InputTitle = Instance.new("TextLabel")
    local InputContent = Instance.new("TextLabel")
    local InputFrame = Instance.new("Frame")
    local UICorner13 = Instance.new("UICorner")
    local InputTextBox = Instance.new("TextBox")

    Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Input.BackgroundTransparency = 0.935
    Input.BorderSizePixel = 0
    Input.LayoutOrder = countItem
    Input.Size = UDim2.new(1, 0, 0, 46)
    Input.Name = "Input"
    Input.Parent = parent

    UICorner12.CornerRadius = UDim.new(0, 4)
    UICorner12.Parent = Input

    InputTitle.Font = Enum.Font.GothamBold
    InputTitle.Text = InputConfig.Title
    InputTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    InputTitle.TextSize = 13
    InputTitle.TextXAlignment = Enum.TextXAlignment.Left
    InputTitle.TextYAlignment = Enum.TextYAlignment.Top
    InputTitle.BackgroundTransparency = 1
    InputTitle.Position = UDim2.new(0, 10, 0, 10)
    InputTitle.Size = UDim2.new(1, -180, 0, 13)
    InputTitle.Name = "InputTitle"
    InputTitle.Parent = Input

    InputContent.Font = Enum.Font.GothamBold
    InputContent.Text = InputConfig.Content
    InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputContent.TextSize = 12
    InputContent.TextTransparency = 0.6
    InputContent.TextWrapped = true
    InputContent.TextXAlignment = Enum.TextXAlignment.Left
    InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
    InputContent.BackgroundTransparency = 1
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
        updateSectionSize()
    end)

    InputFrame.AnchorPoint = Vector2.new(1, 0.5)
    InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputFrame.BackgroundTransparency = 0.95
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
    InputTextBox.Text = InputConfig.Default
    InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputTextBox.TextSize = 12
    InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
    InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
    InputTextBox.BackgroundTransparency = 1
    InputTextBox.BorderSizePixel = 0
    InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
    InputTextBox.Size = UDim2.new(1, -10, 1, -8)
    InputTextBox.Name = "InputTextBox"
    InputTextBox.Parent = InputFrame

    function InputFunc:Set(Value)
        InputTextBox.Text = Value
        InputFunc.Value = Value
        InputConfig.Callback(Value)
        ConfigData[configKey] = Value
        SaveConfig()
    end

    InputFunc:Set(InputFunc.Value)

    InputTextBox.FocusLost:Connect(function()
        InputFunc:Set(InputTextBox.Text)
    end)

    Elements_Table[configKey] = InputFunc
    return InputFunc
end

function Elements:CreateDropdown(parent, config, countItem, countDropdown, DropdownFolder, MoreBlur, DropdownSelect, DropPageLayout, Elements_Table)
    local DropdownConfig = config or {}
    DropdownConfig.Title = DropdownConfig.Title or "Title"
    DropdownConfig.Content = DropdownConfig.Content or ""
    DropdownConfig.Multi = DropdownConfig.Multi or false
    DropdownConfig.Options = DropdownConfig.Options or {}
    DropdownConfig.Default = DropdownConfig.Default or (DropdownConfig.Multi and {} or nil)
    DropdownConfig.Callback = DropdownConfig.Callback or function() end

    local configKey = "Dropdown_" .. DropdownConfig.Title
    if ConfigData[configKey] ~= nil then
        DropdownConfig.Default = ConfigData[configKey]
    end

    local DropdownFunc = { Value = DropdownConfig.Default, Options = DropdownConfig.Options }

    local Dropdown = Instance.new("Frame")
    local DropdownButton = Instance.new("TextButton")
    local UICorner10 = Instance.new("UICorner")
    local DropdownTitle = Instance.new("TextLabel")
    local DropdownContent = Instance.new("TextLabel")
    local SelectOptionsFrame = Instance.new("Frame")
    local UICorner11 = Instance.new("UICorner")
    local OptionSelecting = Instance.new("TextLabel")
    local OptionImg = Instance.new("ImageLabel")

    Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dropdown.BackgroundTransparency = 0.935
    Dropdown.BorderSizePixel = 0
    Dropdown.LayoutOrder = countItem
    Dropdown.Size = UDim2.new(1, 0, 0, 46)
    Dropdown.Name = "Dropdown"
    Dropdown.Parent = parent

    DropdownButton.Text = ""
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.Name = "ToggleButton"
    DropdownButton.Parent = Dropdown

    UICorner10.CornerRadius = UDim.new(0, 4)
    UICorner10.Parent = Dropdown

    DropdownTitle.Font = Enum.Font.GothamBold
    DropdownTitle.Text = DropdownConfig.Title
    DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    DropdownTitle.TextSize = 13
    DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
    DropdownTitle.BackgroundTransparency = 1
    DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
    DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
    DropdownTitle.Name = "DropdownTitle"
    DropdownTitle.Parent = Dropdown

    DropdownContent.Font = Enum.Font.GothamBold
    DropdownContent.Text = DropdownConfig.Content
    DropdownContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownContent.TextSize = 12
    DropdownContent.TextTransparency = 0.6
    DropdownContent.TextWrapped = true
    DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
    DropdownContent.BackgroundTransparency = 1
    DropdownContent.Position = UDim2.new(0, 10, 0, 25)
    DropdownContent.Size = UDim2.new(1, -180, 0, 12)
    DropdownContent.Name = "DropdownContent"
    DropdownContent.Parent = Dropdown

    SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
    SelectOptionsFrame.BackgroundTransparency = 0.95
    SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
    SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
    SelectOptionsFrame.Name = "SelectOptionsFrame"
    SelectOptionsFrame.LayoutOrder = countDropdown
    SelectOptionsFrame.Parent = Dropdown

    UICorner11.CornerRadius = UDim.new(0, 4)
    UICorner11.Parent = SelectOptionsFrame

    DropdownButton.Activated:Connect(function()
        if not MoreBlur.Visible then
            MoreBlur.Visible = true
            DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
        end
    end)

    OptionSelecting.Font = Enum.Font.GothamBold
    OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
    OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptionSelecting.TextSize = 12
    OptionSelecting.TextTransparency = 0.6
    OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
    OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
    OptionSelecting.BackgroundTransparency = 1
    OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
    OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
    OptionSelecting.Name = "OptionSelecting"
    OptionSelecting.Parent = SelectOptionsFrame

    OptionImg.Image = "rbxassetid://16851841101"
    OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
    OptionImg.AnchorPoint = Vector2.new(1, 0.5)
    OptionImg.BackgroundTransparency = 1
    OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
    OptionImg.Size = UDim2.new(0, 25, 0, 25)
    OptionImg.Name = "OptionImg"
    OptionImg.Parent = SelectOptionsFrame

    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
    DropdownContainer.BackgroundTransparency = 1
    DropdownContainer.Parent = DropdownFolder

    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "Search"
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    SearchBox.TextSize = 12
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBox.BackgroundTransparency = 0.9
    SearchBox.BorderSizePixel = 0
    SearchBox.Size = UDim2.new(1, 0, 0, 25)
    SearchBox.Position = UDim2.new(0, 0, 0, 0)
    SearchBox.ClearTextOnFocus = false
    SearchBox.Name = "SearchBox"
    SearchBox.Parent = DropdownContainer

    local ScrollSelect = Instance.new("ScrollingFrame")
    ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
    ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
    ScrollSelect.ScrollBarImageTransparency = 1
    ScrollSelect.BorderSizePixel = 0
    ScrollSelect.BackgroundTransparency = 1
    ScrollSelect.ScrollBarThickness = 0
    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollSelect.Name = "ScrollSelect"
    ScrollSelect.Parent = DropdownContainer

    local UIListLayout4 = Instance.new("UIListLayout")
    UIListLayout4.Padding = UDim.new(0, 3)
    UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout4.Parent = ScrollSelect

    UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, option in pairs(ScrollSelect:GetChildren()) do
            if option.Name == "Option" and option:FindFirstChild("OptionText") then
                local text = string.lower(option.OptionText.Text)
                option.Visible = query == "" or string.find(text, query, 1, true)
            end
        end
        ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
    end)

    function DropdownFunc:Clear()
        for _, DropFrame in ScrollSelect:GetChildren() do
            if DropFrame.Name == "Option" then
                DropFrame:Destroy()
            end
        end
        DropdownFunc.Value = DropdownConfig.Multi and {} or nil
        DropdownFunc.Options = {}
        OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
    end

    function DropdownFunc:AddOption(option)
        local label, value
        if typeof(option) == "table" and option.Label and option.Value ~= nil then
            label = tostring(option.Label)
            value = option.Value
        else
            label = tostring(option)
            value = option
        end

        local Option = Instance.new("Frame")
        local OptionButton = Instance.new("TextButton")
        local OptionText = Instance.new("TextLabel")
        local ChooseFrame = Instance.new("Frame")
        local UIStroke15 = Instance.new("UIStroke")
        local UICorner38 = Instance.new("UICorner")
        local UICorner37 = Instance.new("UICorner")

        Option.BackgroundTransparency = 1
        Option.Size = UDim2.new(1, 0, 0, 30)
        Option.Name = "Option"
        Option.Parent = ScrollSelect

        UICorner37.CornerRadius = UDim.new(0, 3)
        UICorner37.Parent = Option

        OptionButton.BackgroundTransparency = 1
        OptionButton.Size = UDim2.new(1, 0, 1, 0)
        OptionButton.Text = ""
        OptionButton.Name = "OptionButton"
        OptionButton.Parent = Option

        OptionText.Font = Enum.Font.GothamBold
        OptionText.Text = label
        OptionText.TextSize = 13
        OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
        OptionText.Position = UDim2.new(0, 8, 0, 8)
        OptionText.Size = UDim2.new(1, -100, 0, 13)
        OptionText.BackgroundTransparency = 1
        OptionText.TextXAlignment = Enum.TextXAlignment.Left
        OptionText.Name = "OptionText"
        OptionText.Parent = Option

        Option:SetAttribute("RealValue", value)

        ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
        ChooseFrame.BackgroundColor3 = GuiConfig.Color
        ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
        ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Option

        UIStroke15.Color = GuiConfig.Color
        UIStroke15.Thickness = 1.6
        UIStroke15.Transparency = 0.999
        UIStroke15.Parent = ChooseFrame
        UICorner38.Parent = ChooseFrame

        OptionButton.Activated:Connect(function()
            if DropdownConfig.Multi then
                if not table.find(DropdownFunc.Value, value) then
                    table.insert(DropdownFunc.Value, value)
                else
                    for i, v in pairs(DropdownFunc.Value) do
                        if v == value then
                            table.remove(DropdownFunc.Value, i)
                            break
                        end
                    end
                end
            else
                DropdownFunc.Value = value
            end
            DropdownFunc:Set(DropdownFunc.Value)
        end)
    end

    function DropdownFunc:Set(Value)
        if DropdownConfig.Multi then
            DropdownFunc.Value = type(Value) == "table" and Value or {}
        else
            DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
        end

        ConfigData[configKey] = DropdownFunc.Value
        SaveConfig()

        local texts = {}
        for _, Drop in ScrollSelect:GetChildren() do
            if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                local v = Drop:GetAttribute("RealValue")
                local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or DropdownFunc.Value == v

                if selected then
                    TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 1, 0, 12) }):Play()
                    TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
                    TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = 0.935 }):Play()
                    table.insert(texts, Drop.OptionText.Text)
                else
                    TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.1), { Size = UDim2.new(0, 0, 0, 0) }):Play()
                    TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.1), { Transparency = 0.999 }):Play()
                    TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                end
            end
        end

        OptionSelecting.Text = (#texts == 0)
            and (DropdownConfig.Multi and "Select Options" or "Select Option")
            or table.concat(texts, ", ")

        if DropdownConfig.Callback then
            if DropdownConfig.Multi then
                DropdownConfig.Callback(DropdownFunc.Value)
            else
                local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
                DropdownConfig.Callback(str)
            end
        end
    end

    function DropdownFunc:SetValue(val)
        self:Set(val)
    end

    function DropdownFunc:GetValue()
        return self.Value
    end

    function DropdownFunc:SetValues(newList, selecting)
        newList = newList or {}
        selecting = selecting or (DropdownConfig.Multi and {} or nil)
        DropdownFunc:Clear()
        for _, v in ipairs(newList) do
            DropdownFunc:AddOption(v)
        end
        DropdownFunc.Options = newList
        DropdownFunc:Set(selecting)
    end

    DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)
    Elements_Table[configKey] = DropdownFunc
    return DropdownFunc
end

function Elements:CreateDivider(parent, countItem)
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Parent = parent
    Divider.AnchorPoint = Vector2.new(0.5, 0)
    Divider.Position = UDim2.new(0.5, 0, 0, 0)
    Divider.Size = UDim2.new(1, 0, 0, 2)
    Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Divider.BackgroundTransparency = 0
    Divider.BorderSizePixel = 0
    Divider.LayoutOrder = countItem

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    UIGradient.Parent = Divider

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 2)
    UICorner.Parent = Divider

    return Divider
end

function Elements:CreateSubSection(parent, title, countItem)
    title = title or "Sub Section"

    local SubSection = Instance.new("Frame")
    SubSection.Name = "SubSection"
    SubSection.Parent = parent
    SubSection.BackgroundTransparency = 1
    SubSection.Size = UDim2.new(1, 0, 0, 22)
    SubSection.LayoutOrder = countItem

    local Background = Instance.new("Frame")
    Background.Parent = SubSection
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Background.BackgroundTransparency = 0.935
    Background.BorderSizePixel = 0
    Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Parent = SubSection
    Label.AnchorPoint = Vector2.new(0, 0.5)
    Label.Position = UDim2.new(0, 10, 0.5, 0)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = "── [ " .. title .. " ] ──"
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    return SubSection
end

return Elements
