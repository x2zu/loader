-- Dropdown.lua
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local DropdownModule = {}

local MainColor = Color3.fromRGB(255, 0, 255)
local SaveConfigFunc = function() end
local ConfigData = {}

function DropdownModule.Initialize(color, saveFunc, config)
    MainColor = color or MainColor
    SaveConfigFunc = saveFunc or function() end
    ConfigData = config or {}
end

function DropdownModule.Create(parent, config, countItem, countDropdown, moreBlur, dropPageLayout, updateSizeCallback, saveConfig, configData, guiColor)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or ""
    config.Multi = config.Multi or false
    config.Options = config.Options or {}
    config.Default = config.Default or (config.Multi and {} or nil)
    config.Callback = config.Callback or function() end

    local configKey = "Dropdown_" .. config.Title
    if configData and configData[configKey] ~= nil then
        config.Default = configData[configKey]
    end

    local DropdownFunc = { Value = config.Default, Options = config.Options }

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
    DropdownTitle.Text = config.Title
    DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    DropdownTitle.TextSize = 13
    DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
    DropdownTitle.BackgroundTransparency = 1
    DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
    DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
    DropdownTitle.Name = "DropdownTitle"
    DropdownTitle.Parent = Dropdown

    DropdownContent.Font = Enum.Font.GothamBold
    DropdownContent.Text = config.Content
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
        if not moreBlur.Visible then
            moreBlur.Visible = true
            dropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
            TweenService:Create(moreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(moreBlur:FindFirstChild("DropdownSelect"), TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
        end
    end)

    OptionSelecting.Font = Enum.Font.GothamBold
    OptionSelecting.Text = config.Multi and "Select Options" or "Select Option"
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
    DropdownContainer.Parent = moreBlur:FindFirstChild("DropdownSelect"):FindFirstChild("DropdownSelectReal"):FindFirstChild("DropdownFolder")

    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "Search"
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    SearchBox.TextSize = 12
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBox.BackgroundTransparency = 0.9
    SearchBox.BorderSizePixel = 0
    SearchBox.ClearTextOnFocus = false
    SearchBox.Name = "SearchBox"
    SearchBox.Parent = DropdownContainer

    -- =============================================
    -- ALL TOGGLE (hanya untuk Multi mode)
    -- =============================================
    local AllToggleHeight = 0
    local AllToggleFunc = nil

    if config.Multi then
        AllToggleHeight = 30 -- tinggi row "All"

        SearchBox.Size = UDim2.new(1, 0, 0, 25)
        SearchBox.Position = UDim2.new(0, 0, 0, 0)

        -- Frame untuk row "All"
        local AllRow = Instance.new("Frame")
        AllRow.Name = "AllRow"
        AllRow.Size = UDim2.new(1, 0, 0, AllToggleHeight)
        AllRow.Position = UDim2.new(0, 0, 0, 25) -- tepat di bawah SearchBox
        AllRow.BackgroundTransparency = 1
        AllRow.Parent = DropdownContainer

        -- Label "All"
        local AllLabel = Instance.new("TextLabel")
        AllLabel.Font = Enum.Font.GothamBold
        AllLabel.Text = "All"
        AllLabel.TextSize = 13
        AllLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        AllLabel.TextXAlignment = Enum.TextXAlignment.Left
        AllLabel.BackgroundTransparency = 1
        AllLabel.Position = UDim2.new(0, 8, 0, 8)
        AllLabel.Size = UDim2.new(1, -60, 0, 13)
        AllLabel.Name = "AllLabel"
        AllLabel.Parent = AllRow

        -- Toggle frame (mirip ToggleModule)
        local AllFeatureFrame = Instance.new("Frame")
        AllFeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        AllFeatureFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        AllFeatureFrame.BackgroundTransparency = 0.92
        AllFeatureFrame.BorderSizePixel = 0
        AllFeatureFrame.Position = UDim2.new(1, -8, 0.5, 0)
        AllFeatureFrame.Size = UDim2.new(0, 30, 0, 15)
        AllFeatureFrame.Name = "AllFeatureFrame"
        AllFeatureFrame.Parent = AllRow
        Instance.new("UICorner", AllFeatureFrame).CornerRadius = UDim.new(0, 15)

        local AllUIStroke = Instance.new("UIStroke")
        AllUIStroke.Color = Color3.fromRGB(255, 255, 255)
        AllUIStroke.Thickness = 2
        AllUIStroke.Transparency = 0.9
        AllUIStroke.Parent = AllFeatureFrame

        local AllCircle = Instance.new("Frame")
        AllCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        AllCircle.BorderSizePixel = 0
        AllCircle.Size = UDim2.new(0, 14, 0, 14)
        AllCircle.Position = UDim2.new(0, 0, 0, 0)
        AllCircle.Name = "AllCircle"
        AllCircle.Parent = AllFeatureFrame
        Instance.new("UICorner", AllCircle).CornerRadius = UDim.new(0, 15)

        -- Button untuk All row
        local AllButton = Instance.new("TextButton")
        AllButton.BackgroundTransparency = 1
        AllButton.Size = UDim2.new(1, 0, 1, 0)
        AllButton.Text = ""
        AllButton.Name = "AllButton"
        AllButton.Parent = AllRow

        -- Fungsi visual toggle "All"
        local allActive = false

        local function setAllVisual(state)
            allActive = state
            if state then
                TweenService:Create(AllLabel, TweenInfo.new(0.2), { TextColor3 = MainColor }):Play()
                TweenService:Create(AllCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) }):Play()
                TweenService:Create(AllUIStroke, TweenInfo.new(0.2), { Color = MainColor, Transparency = 0 }):Play()
                TweenService:Create(AllFeatureFrame, TweenInfo.new(0.2), { BackgroundColor3 = MainColor, BackgroundTransparency = 0 }):Play()
            else
                TweenService:Create(AllLabel, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
                TweenService:Create(AllCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
                TweenService:Create(AllUIStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
                TweenService:Create(AllFeatureFrame, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
            end
        end

        AllToggleFunc = { Active = false, SetVisual = setAllVisual }

        AllButton.Activated:Connect(function()
            allActive = not allActive
            setAllVisual(allActive)

            if allActive then
                -- Pilih semua option yang visible (tidak difilter search)
                local allValues = {}
                for _, opt in pairs(ScrollSelect:GetChildren()) do  -- ScrollSelect direferensi nanti
                    if opt.Name == "Option" and opt.Visible then
                        local v = opt:GetAttribute("RealValue")
                        if v ~= nil and not table.find(allValues, v) then
                            table.insert(allValues, v)
                        end
                    end
                end
                DropdownFunc:Set(allValues)
            else
                -- Kosongkan semua
                DropdownFunc:Set({})
            end
        end)
    else
        -- Mode single: SearchBox tetap di posisi sama
        SearchBox.Size = UDim2.new(1, 0, 0, 25)
        SearchBox.Position = UDim2.new(0, 0, 0, 0)
    end

    -- ScrollSelect posisinya tergantung ada/tidaknya AllToggle
    local scrollOffsetY = 25 + AllToggleHeight

    local ScrollSelect = Instance.new("ScrollingFrame")
    ScrollSelect.Size = UDim2.new(1, 0, 1, -scrollOffsetY)
    ScrollSelect.Position = UDim2.new(0, 0, 0, scrollOffsetY)
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

    -- Helper: cek apakah semua visible option sudah terpilih semua
    local function syncAllToggle()
        if not config.Multi or not AllToggleFunc then return end
        local allSelected = true
        local anyVisible = false
        for _, opt in pairs(ScrollSelect:GetChildren()) do
            if opt.Name == "Option" and opt.Visible then
                anyVisible = true
                local v = opt:GetAttribute("RealValue")
                if not table.find(DropdownFunc.Value, v) then
                    allSelected = false
                    break
                end
            end
        end
        local shouldBeActive = anyVisible and allSelected
        if AllToggleFunc.Active ~= shouldBeActive then
            AllToggleFunc.Active = shouldBeActive
            AllToggleFunc.SetVisual(shouldBeActive)
        end
    end

    function DropdownFunc:Clear()
        for _, DropFrame in ScrollSelect:GetChildren() do
            if DropFrame.Name == "Option" then
                DropFrame:Destroy()
            end
        end
        DropdownFunc.Value = config.Multi and {} or nil
        DropdownFunc.Options = {}
        OptionSelecting.Text = config.Multi and "Select Options" or "Select Option"
        if AllToggleFunc then
            AllToggleFunc.Active = false
            AllToggleFunc.SetVisual(false)
        end
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
        ChooseFrame.BackgroundColor3 = MainColor
        ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
        ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Option

        UIStroke15.Color = MainColor
        UIStroke15.Thickness = 1.6
        UIStroke15.Transparency = 0.999
        UIStroke15.Parent = ChooseFrame
        UICorner38.Parent = ChooseFrame

        OptionButton.Activated:Connect(function()
            if config.Multi then
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
        if config.Multi then
            DropdownFunc.Value = type(Value) == "table" and Value or {}
        else
            DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
        end

        ConfigData[configKey] = DropdownFunc.Value
        SaveConfigFunc()

        local texts = {}
        for _, Drop in ScrollSelect:GetChildren() do
            if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                local v = Drop:GetAttribute("RealValue")
                local selected = config.Multi and table.find(DropdownFunc.Value, v) or DropdownFunc.Value == v

                if selected then
                    TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.2),
                        { Size = UDim2.new(0, 1, 0, 12) }):Play()
                    TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.2), { Transparency = 0 })
                        :Play()
                    TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = 0.935 }):Play()
                    table.insert(texts, Drop.OptionText.Text)
                else
                    TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.1),
                        { Size = UDim2.new(0, 0, 0, 0) }):Play()
                    TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.1),
                        { Transparency = 0.999 }):Play()
                    TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                end
            end
        end

        OptionSelecting.Text = (#texts == 0)
            and (config.Multi and "Select Options" or "Select Option")
            or table.concat(texts, ", ")

        -- Sync tampilan toggle "All" setelah Set
        syncAllToggle()

        if config.Callback then
            if config.Multi then
                config.Callback(DropdownFunc.Value)
            else
                local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
                config.Callback(str)
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
        selecting = selecting or (config.Multi and {} or nil)
        DropdownFunc:Clear()
        for _, v in ipairs(newList) do
            DropdownFunc:AddOption(v)
        end
        DropdownFunc.Options = newList
        DropdownFunc:Set(selecting)
    end

    DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)

    return DropdownFunc
end

function DropdownModule.AddDivider(parent, countItem, guiColor)
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
        ColorSequenceKeypoint.new(0.5, guiColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    UIGradient.Parent = Divider

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 2)
    UICorner.Parent = Divider

    return Divider
end

function DropdownModule.AddSubSection(parent, title, countItem)
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

return DropdownModule
