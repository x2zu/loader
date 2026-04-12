local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local KeybindModule = {}

function KeybindModule:CreateKeybind(SectionAdd, KeybindConfig, CountItem, Elements)
    KeybindConfig = KeybindConfig or {}
    KeybindConfig.Title    = KeybindConfig.Title    or "Keybind"
    KeybindConfig.Content  = KeybindConfig.Content  or ""
    KeybindConfig.Value    = KeybindConfig.Value    or "RightShift"
    KeybindConfig.Flag     = KeybindConfig.Flag     or nil
    KeybindConfig.Callback = KeybindConfig.Callback or function() end

    -- ==================== FRAME ====================
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    KeybindFrame.BackgroundTransparency = 0.935
    KeybindFrame.BorderSizePixel = 0
    KeybindFrame.Size = UDim2.new(1, 0, 0, 38)
    KeybindFrame.LayoutOrder = CountItem
    KeybindFrame.Name = "KeybindFrame"
    KeybindFrame.Parent = SectionAdd

    local KBCorner = Instance.new("UICorner")
    KBCorner.CornerRadius = UDim.new(0, 4)
    KBCorner.Parent = KeybindFrame

    -- ==================== TITLE ====================
    local KBTitle = Instance.new("TextLabel")
    KBTitle.Font = Enum.Font.GothamBold
    KBTitle.Text = KeybindConfig.Title
    KBTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    KBTitle.TextSize = 13
    KBTitle.TextXAlignment = Enum.TextXAlignment.Left
    KBTitle.BackgroundTransparency = 1
    KBTitle.BorderSizePixel = 0
    KBTitle.Position = UDim2.new(0, 10, 0, 0)
    KBTitle.Size = UDim2.new(0.6, 0, 0.5, 0)
    KBTitle.Name = "KBTitle"
    KBTitle.Parent = KeybindFrame

    -- ==================== CONTENT / SUBTITLE ====================
    local KBContent = Instance.new("TextLabel")
    KBContent.Font = Enum.Font.Gotham
    KBContent.Text = KeybindConfig.Content
    KBContent.TextColor3 = Color3.fromRGB(150, 150, 150)
    KBContent.TextSize = 11
    KBContent.TextXAlignment = Enum.TextXAlignment.Left
    KBContent.BackgroundTransparency = 1
    KBContent.BorderSizePixel = 0
    KBContent.Position = UDim2.new(0, 10, 0.5, 0)
    KBContent.Size = UDim2.new(0.6, 0, 0.5, 0)
    KBContent.Name = "KBContent"
    KBContent.Parent = KeybindFrame

    -- ==================== BUTTON ====================
    local KBButton = Instance.new("TextButton")
    KBButton.Font = Enum.Font.GothamBold
    KBButton.Text = "[" .. KeybindConfig.Value .. "]"
    KBButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KBButton.TextSize = 12
    KBButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    KBButton.BackgroundTransparency = 0.85
    KBButton.BorderSizePixel = 0
    KBButton.AnchorPoint = Vector2.new(1, 0.5)
    KBButton.Position = UDim2.new(1, -8, 0.5, 0)
    KBButton.Size = UDim2.new(0, 80, 0, 24)
    KBButton.Name = "KBButton"
    KBButton.Parent = KeybindFrame

    local KBButtonCorner = Instance.new("UICorner")
    KBButtonCorner.CornerRadius = UDim.new(0, 4)
    KBButtonCorner.Parent = KBButton

    local KBButtonStroke = Instance.new("UIStroke")
    KBButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    KBButtonStroke.Thickness = 1
    KBButtonStroke.Transparency = 0.85
    KBButtonStroke.Parent = KBButton

    -- ==================== LOGIC ====================
    local currentKey = KeybindConfig.Value
    local listening = false

    local function setListening(state)
        listening = state
        if state then
            KBButton.Text = "[...]"
            TweenService:Create(KBButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.6,
                TextColor3 = Color3.fromRGB(180, 180, 180)
            }):Play()
        else
            TweenService:Create(KBButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.85,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end

    KBButton.MouseButton1Click:Connect(function()
        if listening then return end
        setListening(true)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = input.KeyCode.Name
                currentKey = keyName
                KBButton.Text = "[" .. keyName .. "]"
                setListening(false)
                conn:Disconnect()

                -- Save ke config kalau ada Flag
                if KeybindConfig.Flag and Elements then
                    Elements[KeybindConfig.Flag] = {
                        Set = function(self, val, silent)
                            currentKey = val
                            KBButton.Text = "[" .. val .. "]"
                        end
                    }
                end

                pcall(function()
                    KeybindConfig.Callback(keyName)
                end)
            end
        end)
    end)

    -- Hover effect
    KBButton.MouseEnter:Connect(function()
        if listening then return end
        TweenService:Create(KBButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.7
        }):Play()
    end)
    KBButton.MouseLeave:Connect(function()
        if listening then return end
        TweenService:Create(KBButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.85
        }):Play()
    end)

    -- ==================== PUBLIC API ====================
    local KeybindFunc = {}

    function KeybindFunc:Set(value, silent)
        currentKey = value
        KBButton.Text = "[" .. value .. "]"
        if not silent then
            pcall(function()
                KeybindConfig.Callback(value)
            end)
        end
    end

    function KeybindFunc:Get()
        return currentKey
    end

    function KeybindFunc:Destroy()
        KeybindFrame:Destroy()
    end

    -- Register ke Elements kalau ada Flag
    if KeybindConfig.Flag and Elements then
        Elements[KeybindConfig.Flag] = KeybindFunc
    end

    return KeybindFunc
end

return KeybindModule
