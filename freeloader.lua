--// Services
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer

--// Utilities
local connections = {}
local states = { build = false }

local function add_connection(cn)
    connections[#connections + 1] = cn
end

local function fade_text(object, text, duration)
    local tweenInfo = TweenInfo.new(duration or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenOut = TS:Create(object, tweenInfo, { TextTransparency = 1 })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    object.Text = text
    local tweenIn = TS:Create(object, tweenInfo, { TextTransparency = 0 })
    tweenIn:Play()
end

local function create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do 
        inst[k] = v 
    end
    for _, child in ipairs(children or {}) do 
        child.Parent = inst 
    end
    return inst
end

-- Function to load external script
local function loadExternalScript()
    -- Ganti URL dengan script-mu
    local scriptUrl = "https://raw.githubusercontent.com/xwwwwwwwwwwwwwwwwwwwqd/loader/main/stellar"

    local success, err = pcall(function()
        local response = game:HttpGet(scriptUrl) -- ✅ langsung pakai HttpGet, bukan HttpService
        if response then
            local loadedFunction = loadstring(response)
            if loadedFunction then
                loadedFunction()
            else
                warn("Failed to load external script: Invalid script content")
            end
        end
    end)

    if not success then
        warn("Failed to load external script: " .. tostring(err))
    end
end

--// MAIN KEYSYSTEM
local function CreateKeySystem()
    local ScreenGui = create("ScreenGui", {
        Name = "KeySystemUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Client:WaitForChild("PlayerGui"),
    })

    -- Background overlay
    local Overlay = create("Frame", {
        Name = "Overlay",
        Parent = ScreenGui,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        ZIndex = 0
    })

    local Window = create("Frame", {
        Name = "KeySystem",
        Parent = ScreenGui,
        Size = UDim2.fromOffset(400, 500),
        Position = UDim2.new(0.5, -200, 0.5, -250),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        ClipsDescendants = true,
        ZIndex = 1
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        create("UIStroke", {
            Color = Color3.fromRGB(45, 45, 55),
            Thickness = 2
        }),

        -- Header
        create("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Color3.fromRGB(25, 25, 32),
            BorderSizePixel = 0,
            ZIndex = 2
        }, {
            create("UICorner", {
                CornerRadius = UDim.new(0, 12),
            }),
            create("TextLabel", {
                Name = "Title",
                Text = "STELLAR COMMUNITY",
                TextColor3 = Color3.fromRGB(180, 180, 200),
                Font = Enum.Font.GothamSemibold,
                TextSize = 16,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 20, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            create("ImageButton", {
                Name = "Close",
                Image = "rbxassetid://10734959599", -- X icon
                ImageColor3 = Color3.fromRGB(150, 150, 170),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -15, 0.5, 0),
                Size = UDim2.fromOffset(20, 20),
                ZIndex = 3
            })
        }),

        -- Logo
        create("ImageLabel", {
            Name = "Logo",
            Image = "http://www.roblox.com/asset/?id=105059922903197",
            ImageColor3 = Color3.fromRGB(120, 130, 230),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 70),
            Size = UDim2.fromOffset(100, 100),
            ZIndex = 2
        }),

        -- Textfield
        create("Frame", {
            Name = "Textfield",
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 180),
            Size = UDim2.new(0.8, 0, 0, 50),
            ZIndex = 2
        }, {
            create("Frame", {
                Name = "Container",
                BackgroundColor3 = Color3.fromRGB(30, 30, 38),
                Size = UDim2.new(1, 0, 1, 0),
            }, {
                create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                create("UIStroke", {
                    Color = Color3.fromRGB(50, 50, 60),
                    Thickness = 1
                }),
                create("TextBox", {
                    Name = "Input",
                    ClearTextOnFocus = false,
                    PlaceholderText = "Enter your key...",
                    PlaceholderColor3 = Color3.fromRGB(100, 100, 120),
                    Text = "",
                    TextColor3 = Color3.fromRGB(220, 220, 240),
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -45, 1, 0),
                    Position = UDim2.new(0, 15, 0, 0),
                }),
                create("ImageLabel", {
                    Image = "rbxassetid://15450356515", -- icon grid
                    ImageColor3 = Color3.fromRGB(120, 130, 230),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -15, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20),
                }),
            }),
        }),

        -- Status
        create("TextLabel", {
            Name = "Status",
            Text = "Enter your key to continue",
            TextColor3 = Color3.fromRGB(150, 150, 170),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 240),
            Size = UDim2.new(0.8, 0, 0, 20),
            TextTransparency = 0,
            ZIndex = 2
        }),

        -- Continue Button
        create("TextButton", {
            Name = "ContinueButton",
            Text = "CONTINUE",
            TextColor3 = Color3.fromRGB(220, 220, 240),
            Font = Enum.Font.GothamSemibold,
            TextSize = 16,
            BackgroundColor3 = Color3.fromRGB(40, 45, 60),
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 280),
            Size = UDim2.new(0.8, 0, 0, 45),
            ZIndex = 2
        }, {
            create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            create("UIStroke", {
                Color = Color3.fromRGB(80, 90, 160),
                Thickness = 1
            }),
        }),

        -- Divider
        create("Frame", {
            Name = "Divider",
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Color3.fromRGB(45, 45, 55),
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0, 345),
            Size = UDim2.new(0.8, 0, 0, 1),
            ZIndex = 2
        }),

        -- Action Buttons (Icons only)
        create("Frame", {
            Name = "Actions",
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 360),
            Size = UDim2.new(0.8, 0, 0, 50),
            ZIndex = 2
        }, {
            create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            }),
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 30)
            }),

            -- Get Key Button (Icon)
            create("ImageButton", {
                Name = "GetButton",
                Image = "rbxassetid://107412013683022", -- Key icon
                ImageColor3 = Color3.fromRGB(120, 130, 230),
                BackgroundColor3 = Color3.fromRGB(30, 30, 40),
                AutoButtonColor = false,
                Size = UDim2.fromOffset(40, 40),
                LayoutOrder = 1
            }, {
                create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                create("UIStroke", {
                    Color = Color3.fromRGB(60, 60, 75),
                    Thickness = 1
                }),
            }),

            -- Help Button (Icon)
            create("ImageButton", {
                Name = "HelpButton",
                Image = "rbxassetid://97459381308349", -- Help icon
                ImageColor3 = Color3.fromRGB(120, 130, 230),
                BackgroundColor3 = Color3.fromRGB(30, 30, 40),
                AutoButtonColor = false,
                Size = UDim2.fromOffset(40, 40),
                LayoutOrder = 2
            }, {
                create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                create("UIStroke", {
                    Color = Color3.fromRGB(60, 60, 75),
                    Thickness = 1
                }),
            }),
        }),

        -- Footer
        create("TextLabel", {
            Name = "Footer",
            Text = "Authentication System Stellar",
            TextColor3 = Color3.fromRGB(100, 100, 120),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 1, -15),
            Size = UDim2.new(1, -20, 0, 20),
            ZIndex = 2
        }),
    })

    --// Logic
    local keyInput = Window.Textfield.Container.Input
    local status = Window.Status
    local continueBtn = Window.ContinueButton
    local getBtn = Window.Actions.GetButton
    local helpBtn = Window.Actions.HelpButton
    local closeBtn = Window.Header.Close

    -- Dragging functionality
    local dragging, dragStart, startPos
    Window.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Button animations
    continueBtn.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(continueBtn, tweenInfo, { BackgroundColor3 = Color3.fromRGB(50, 55, 75) })
        tween:Play()
        local strokeTween = TS:Create(continueBtn.UIStroke, tweenInfo, { Color = Color3.fromRGB(100, 110, 200) })
        strokeTween:Play()
    end)
    
    continueBtn.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(continueBtn, tweenInfo, { BackgroundColor3 = Color3.fromRGB(40, 45, 60) })
        tween:Play()
        local strokeTween = TS:Create(continueBtn.UIStroke, tweenInfo, { Color = Color3.fromRGB(80, 90, 160) })
        strokeTween:Play()
    end)
    
    continueBtn.MouseButton1Down:Connect(function()
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(continueBtn, tweenInfo, { BackgroundColor3 = Color3.fromRGB(35, 40, 55) })
        tween:Play()
        tween.Completed:Connect(function()
            if continueBtn.Parent then
                local tweenBack = TS:Create(continueBtn, tweenInfo, { BackgroundColor3 = Color3.fromRGB(50, 55, 75) })
                tweenBack:Play()
            end
        end)
    end)

    -- Icon button animations
    local function animateIconHover(button)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(button, tweenInfo, { 
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            ImageColor3 = Color3.fromRGB(140, 150, 250)
        })
        tween:Play()
        local strokeTween = TS:Create(button.UIStroke, tweenInfo, { Color = Color3.fromRGB(80, 85, 120) })
        strokeTween:Play()
    end
    
    local function animateIconLeave(button)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(button, tweenInfo, { 
            BackgroundColor3 = Color3.fromRGB(30, 30, 40),
            ImageColor3 = Color3.fromRGB(120, 130, 230)
        })
        tween:Play()
        local strokeTween = TS:Create(button.UIStroke, tweenInfo, { Color = Color3.fromRGB(60, 60, 75) })
        strokeTween:Play()
    end
    
    local function animateIconClick(button)
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(button, tweenInfo, { 
            BackgroundColor3 = Color3.fromRGB(25, 25, 35),
            ImageColor3 = Color3.fromRGB(160, 170, 255)
        })
        tween:Play()
        tween.Completed:Connect(function()
            if button.Parent then
                animateIconHover(button)
            end
        end)
    end

    -- Close button
    closeBtn.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(closeBtn, tweenInfo, { ImageColor3 = Color3.fromRGB(200, 200, 220) })
        tween:Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(closeBtn, tweenInfo, { ImageColor3 = Color3.fromRGB(150, 150, 170) })
        tween:Play()
    end)
    
    add_connection(closeBtn.MouseButton1Click:Connect(function()
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(Window, tweenInfo, { Size = UDim2.fromOffset(400, 0), Position = UDim2.new(0.5, -200, 0.5, 0) })
        tween:Play()
        tween.Completed:Wait()
        ScreenGui:Destroy()
    end))
    -- StellarKey
    -- Continue button functionality
    add_connection(continueBtn.MouseButton1Click:Connect(function()
        local userKey = keyInput.Text
        if userKey == "Stellar" then
            fade_text(status, "Success! Access granted.", 0.3)
            
            -- Change button text directly (don't tween text)
            continueBtn.Text = "ACCESS GRANTED"
            
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TS:Create(continueBtn, tweenInfo, { 
                BackgroundColor3 = Color3.fromRGB(60, 180, 80)
            })
            local strokeTween = TS:Create(continueBtn.UIStroke, tweenInfo, { 
                Color = Color3.fromRGB(100, 220, 120)
            })
            tween:Play()
            strokeTween:Play()
            
            -- Wait for animation to complete
            task.wait(1.5)
            
            -- Fade out the entire UI simultaneously
            local fadeDuration = 0.5
            local fadeTweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            -- Create a list of all tweens to run simultaneously
            local allTweens = {}
            
            -- Fade out overlay
            table.insert(allTweens, TS:Create(Overlay, fadeTweenInfo, {BackgroundTransparency = 1}))
            
            -- Fade out main window
            table.insert(allTweens, TS:Create(Window, fadeTweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -200, 0.5, -220)
            }))
            
            -- Fade out window stroke
            if Window:FindFirstChild("UIStroke") then
                table.insert(allTweens, TS:Create(Window.UIStroke, fadeTweenInfo, {Transparency = 1}))
            end
            
            -- Fade out all text elements
            local textElements = {
                Window.Header.Title,
                Window.Status,
                Window.Footer,
                Window.Textfield.Container.Input,
                Window.ContinueButton
            }
            
            for _, textElement in ipairs(textElements) do
                if textElement then
                    table.insert(allTweens, TS:Create(textElement, fadeTweenInfo, {TextTransparency = 1}))
                end
            end
            
            -- Fade out all images
            local imageElements = {
                Window.Logo,
                Window.Textfield.Container.ImageLabel,
                Window.Actions.GetButton,
                Window.Actions.HelpButton,
                Window.Header.Close
            }
            
            for _, imageElement in ipairs(imageElements) do
                if imageElement then
                    table.insert(allTweens, TS:Create(imageElement, fadeTweenInfo, {ImageTransparency = 1}))
                end
            end
            
            -- Fade out all frames with background
            local backgroundFrames = {
                Window.Header,
                Window.Textfield.Container,
                Window.Actions.GetButton,
                Window.Actions.HelpButton,
                Window.ContinueButton
            }
            
            for _, frame in ipairs(backgroundFrames) do
                if frame and frame:IsA("Frame") then
                    table.insert(allTweens, TS:Create(frame, fadeTweenInfo, {BackgroundTransparency = 1}))
                    
                    -- Also fade out any strokes on these frames
                    if frame:FindFirstChild("UIStroke") then
                        table.insert(allTweens, TS:Create(frame.UIStroke, fadeTweenInfo, {Transparency = 1}))
                    end
                end
            end
            
            -- Play all tweens simultaneously
            for _, t in ipairs(allTweens) do
                t:Play()
            end
            
            -- Wait for fade out to complete
            task.wait(fadeDuration)
            
            -- Load the external script
            loadExternalScript()
            
            -- Finally destroy the GUI
            ScreenGui:Destroy()
            
        else
            fade_text(status, "Invalid key. Please try again.", 0.3)
            local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
            local tween = TS:Create(Window, tweenInfo, { Position = UDim2.new(0.5, -210, 0.5, -250) })
            tween:Play()
            tween = TS:Create(Window, tweenInfo, { Position = UDim2.new(0.5, -190, 0.5, -250) })
            tween:Play()
            tween = TS:Create(Window, tweenInfo, { Position = UDim2.new(0.5, -200, 0.5, -250) })
            tween:Play()
        end
    end))

    -- Get key button
    getBtn.MouseEnter:Connect(function()
        animateIconHover(getBtn)
    end)
    
    getBtn.MouseLeave:Connect(function()
        animateIconLeave(getBtn)
    end)
    
    getBtn.MouseButton1Down:Connect(function()
        animateIconClick(getBtn)
    end)
    
    add_connection(getBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/FmMuvkaWvG")
        fade_text(status, "Key link copied to clipboard!", 0.3)
    end))

    -- Help button
    helpBtn.MouseEnter:Connect(function()
        animateIconHover(helpBtn)
    end)
    
    helpBtn.MouseLeave:Connect(function()
        animateIconLeave(helpBtn)
    end)
    
    helpBtn.MouseButton1Down:Connect(function()
        animateIconClick(helpBtn)
    end)
    
    add_connection(helpBtn.MouseButton1Click:Connect(function()
        fade_text(status, "Join our discord to get key", 0.5)
        task.wait(3)
        fade_text(status, "Enter your key to continue", 0.5)
    end))

    -- Input field focus effect
    keyInput.Focused:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(Window.Textfield.Container, tweenInfo, { 
            BackgroundColor3 = Color3.fromRGB(35, 35, 45),
        })
        tween:Play()
        local strokeTween = TS:Create(Window.Textfield.Container.UIStroke, tweenInfo, {
            Color = Color3.fromRGB(100, 110, 200)
        })
        strokeTween:Play()
    end)
    
    keyInput.FocusLost:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TS:Create(Window.Textfield.Container, tweenInfo, { 
            BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        })
        tween:Play()
        local strokeTween = TS:Create(Window.Textfield.Container.UIStroke, tweenInfo, {
            Color = Color3.fromRGB(50, 50, 60)
        })
        strokeTween:Play()
    end)

    -- Entrance animation
    local entranceTween = TS:Create(Window, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -200, 0.5, -250)
    })
    Window.Position = UDim2.new(0.5, -200, 0.5, -300)
    entranceTween:Play()
end

-- Run
CreateKeySystem()