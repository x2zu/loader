
local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BASE = "https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/main/ui-main/ui-main/"
local function load(path) return loadstring(game:HttpGet(BASE .. path))() end

-- Modules
local ColorModule    = load("Elements/color.lua")
local ElementsModule = load("Elements/Elements.lua")
local KeybindModule  = load("Elements/keybind.lua")
local ConfigModule   = load("addons/configsection.lua")
-- Icons
local defaultIcons = load("Icon/defaulticons.lua")
local lucideIcons  = load("Icon/lucideIcons.lua")
local solarIcons   = load("Icon/solarIcons.lua")

-- Merge all icons
local Icons = {}
for name, id in pairs(defaultIcons) do
    Icons[name] = id
end
for name, id in pairs(lucideIcons) do
    Icons["lucide:" .. name] = id
end
for name, id in pairs(solarIcons) do
    Icons["solar:" .. name] = id
end

-- Function to get icon ID
local function getIconId(iconName)
    if not iconName or iconName == "" then
        return ""
    end
    if iconName:match("^%d+$") then
        return "rbxassetid://" .. iconName
    end
    if Icons[iconName] then
        return Icons[iconName]
    end
    if iconName:match("^https?://") then
        return iconName
    end
    return ""
end

-- Function to get color from name or direct Color3
local function getColor(colorInput)
    if typeof(colorInput) == "Color3" then
        return colorInput
    end
    if type(colorInput) == "string" then
        if ColorModule[colorInput] then
            return ColorModule[colorInput]
        else
            warn("Color '" .. colorInput .. "' not found, using Default")
            return ColorModule["Default"] or Color3.fromRGB(0, 208, 255)
        end
    end
    return ColorModule["Default"] or Color3.fromRGB(0, 208, 255)
end

-- Variables
local ConfigFolder = "Nemesis UI"
local ConfigFile = ""
local ConfigData = {}
local Elements = {}
local CURRENT_VERSION = nil
local AUTO_SAVE = false
local AUTO_LOAD = false

function SaveConfig()
    if writefile and ConfigFile ~= "" then
        ConfigData._version = CURRENT_VERSION
        writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
    end
end

function LoadConfigFromFile()
    if not CURRENT_VERSION or ConfigFile == "" then return end
    if isfile and isfile(ConfigFile) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            if result._version == CURRENT_VERSION then
                ConfigData = result
            else
                ConfigData = { _version = CURRENT_VERSION }
            end
        else
            ConfigData = { _version = CURRENT_VERSION }
        end
    else
        ConfigData = { _version = CURRENT_VERSION }
    end
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        if ConfigData[key] ~= nil and element.Set then
            element:Set(ConfigData[key], true)
        end
    end
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local viewport = workspace.CurrentCamera.ViewportSize

local function isMobileDevice()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local scaleX = pxWidth / viewport.X
    local scaleY = pxHeight / viewport.Y
    if isMobile then
        if scaleX > 0.5 then scaleX = 0.5 end
        if scaleY > 0.3 then scaleY = 0.3 end
    end
    return UDim2.new(scaleX, 0, scaleY, 0)
end

local function MakeDraggable(topbarobject, object, GuiConfig)
    local function CustomPos(topbarobject, object)
        local Dragging, DragInput, DragStart, StartPosition

        local function UpdatePos(input)
            local Delta = input.Position - DragStart
            local pos = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
            local Tween = TweenService:Create(object, TweenInfo.new(0.2), { Position = pos })
            Tween:Play()
        end

        topbarobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        topbarobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                UpdatePos(input)
            end
        end)
    end

    local function CustomSize(object)
        local Dragging, DragInput, DragStart, StartSize
        local minSizeX, minSizeY
        local defSizeX, defSizeY

        local cfgW = (GuiConfig and GuiConfig.Size and GuiConfig.Size.X.Offset) or 640
        local cfgH = (GuiConfig and GuiConfig.Size and GuiConfig.Size.Y.Offset) or 400

        if isMobile then
            minSizeX, minSizeY = 100, 100
            defSizeX = math.min(cfgW, 470)
            defSizeY = math.min(cfgH, 270)
        else
            minSizeX, minSizeY = 100, 100
            defSizeX = cfgW
            defSizeY = cfgH
        end

        object.Size = UDim2.new(0, defSizeX, 0, defSizeY)

        local changesizeobject = Instance.new("Frame")
        changesizeobject.AnchorPoint = Vector2.new(1, 1)
        changesizeobject.BackgroundTransparency = 1
        changesizeobject.Size = UDim2.new(0, 40, 0, 40)
        changesizeobject.Position = UDim2.new(1, 20, 1, 20)
        changesizeobject.Name = "changesizeobject"
        changesizeobject.Parent = object

        local function UpdateSize(input)
            local Delta = input.Position - DragStart
            local newWidth = StartSize.X.Offset + Delta.X
            local newHeight = StartSize.Y.Offset + Delta.Y
            newWidth = math.max(newWidth, minSizeX)
            newHeight = math.max(newHeight, minSizeY)
            local Tween = TweenService:Create(object, TweenInfo.new(0.2), { Size = UDim2.new(0, newWidth, 0, newHeight) })
            Tween:Play()
        end

        changesizeobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartSize = object.Size
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        changesizeobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                UpdateSize(input)
            end
        end)
    end

    CustomSize(object)
    CustomPos(topbarobject, object)
end

function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.8999999761581421
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button

        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.Y * 1.5
        elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        end

        local Time = 0.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size / 2, 0.5, -Size / 2), "Out", "Quad",
            Time, false, nil)
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

local Nemesis = {}

function Nemesis:MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "Nemesis X"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = getColor(NotifyConfig.Color or "Periwinkle Purple")
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5
    NotifyConfig.Icon = NotifyConfig.Icon or ""
    local NotifyFunction = {}
    spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.Parent = CoreGui
        end
        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame")
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            NotifyLayout.BackgroundTransparency = 0.9990000128746033
            NotifyLayout.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyLayout.BorderSizePixel = 0
            NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
            NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(
                        v,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count)) }
                    ):Play()
                    Count = Count + 1
                end
            end)
        end
        local NotifyPosHeigh = 0
        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
        end
        local NotifyFrame = Instance.new("Frame")
        local NotifyFrameReal = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local DropShadowHolder = Instance.new("Frame")
        local DropShadow = Instance.new("ImageLabel")
        local Top = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")
        local UICorner1 = Instance.new("UICorner")
        local TextLabel1 = Instance.new("TextLabel")
        local Close = Instance.new("TextButton")
        local ImageLabel = Instance.new("ImageLabel")
        local TextLabel2 = Instance.new("TextLabel")

        NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.Parent = NotifyFrame

        UICorner.Parent = NotifyFrameReal
        UICorner.CornerRadius = UDim.new(0, 8)

        DropShadowHolder.BackgroundTransparency = 1
        DropShadowHolder.BorderSizePixel = 0
        DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
        DropShadowHolder.ZIndex = 0
        DropShadowHolder.Name = "DropShadowHolder"
        DropShadowHolder.Parent = NotifyFrameReal

        Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Top.BackgroundTransparency = 0.9990000128746033
        Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Top.BorderSizePixel = 0
        Top.Size = UDim2.new(1, 0, 0, 36)
        Top.Name = "Top"
        Top.Parent = NotifyFrameReal

        local hasIcon = NotifyConfig.Icon and NotifyConfig.Icon ~= ""
        local iconSize = 36
        local iconPadding = 10
        local titleOffsetX = hasIcon and (iconPadding + iconSize + 8) or 10

        if hasIcon then
            local NotifyIcon = Instance.new("ImageLabel")
            NotifyIcon.AnchorPoint = Vector2.new(0, 0.5)
            NotifyIcon.BackgroundTransparency = 1
            NotifyIcon.BorderSizePixel = 0
            NotifyIcon.Position = UDim2.new(0, iconPadding, 0.5, 0)
            NotifyIcon.Size = UDim2.new(0, iconSize, 0, iconSize)
            NotifyIcon.ImageColor3 = NotifyConfig.Color
            NotifyIcon.Name = "NotifyIcon"
            NotifyIcon.Parent = NotifyFrameReal

            local iconId = getIconId(NotifyConfig.Icon)
            if iconId and iconId ~= "" then
                NotifyIcon.Image = iconId
            end
        end

        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.Text = NotifyConfig.Title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 0.9990000128746033
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.BorderSizePixel = 0
        TextLabel.Size = UDim2.new(1, -(titleOffsetX + 60), 1, 0)
        TextLabel.Parent = Top
        TextLabel.Position = UDim2.new(0, titleOffsetX, 0, 0)

        UICorner1.Parent = Top
        UICorner1.CornerRadius = UDim.new(0, 5)

        TextLabel1.Font = Enum.Font.GothamBold
        TextLabel1.Text = NotifyConfig.Description
        TextLabel1.TextColor3 = NotifyConfig.Color
        TextLabel1.TextSize = 14
        TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel1.BackgroundTransparency = 0.9990000128746033
        TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel1.BorderSizePixel = 0
        TextLabel1.Size = UDim2.new(1, 0, 1, 0)
        TextLabel1.Position = UDim2.new(0, titleOffsetX + TextLabel.TextBounds.X + 5, 0, 0)
        TextLabel1.Parent = Top

        Close.Font = Enum.Font.SourceSans
        Close.Text = ""
        Close.TextColor3 = Color3.fromRGB(0, 0, 0)
        Close.TextSize = 14
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Close.BackgroundTransparency = 0.9990000128746033
        Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Close.BorderSizePixel = 0
        Close.Position = UDim2.new(1, -5, 0.5, 0)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Name = "Close"
        Close.Parent = Top

        ImageLabel.Image = "rbxassetid://9886659671"
        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageLabel.BackgroundTransparency = 0.9990000128746033
        ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageLabel.BorderSizePixel = 0
        ImageLabel.Position = UDim2.new(0.49000001, 0, 0.5, 0)
        ImageLabel.Size = UDim2.new(1, -8, 1, -8)
        ImageLabel.Parent = Close

        local contentOffsetX = hasIcon and titleOffsetX or 10
        TextLabel2.Font = Enum.Font.GothamBold
        TextLabel2.TextColor3 = Color3.fromRGB(150, 150, 150)
        TextLabel2.TextSize = 13
        TextLabel2.Text = NotifyConfig.Content
        TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
        TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel2.BackgroundTransparency = 0.9990000128746033
        TextLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel2.BorderSizePixel = 0
        TextLabel2.Position = UDim2.new(0, contentOffsetX, 0, 27)
        TextLabel2.Parent = NotifyFrameReal
        TextLabel2.Size = UDim2.new(1, -(contentOffsetX + 10), 0, 13)
        TextLabel2.Size = UDim2.new(1, -(contentOffsetX + 10), 0, 13 + (13 * (TextLabel2.TextBounds.X // TextLabel2.AbsoluteSize.X)))
        TextLabel2.TextWrapped = true

        if TextLabel2.AbsoluteSize.Y < 27 then
            NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
        else
            NotifyFrame.Size = UDim2.new(1, 0, 0, TextLabel2.AbsoluteSize.Y + 40)
        end

        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then return false end
            waitbruh = true
            TweenService:Create(
                NotifyFrameReal,
                TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                { Position = UDim2.new(0, 400, 0, 0) }
            ):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end

        Close.Activated:Connect(function()
            NotifyFunction:Close()
        end)

        TweenService:Create(
            NotifyFrameReal,
            TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            { Position = UDim2.new(0, 0, 0, 0) }
        ):Play()
        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    return NotifyFunction
end

function Nt(msg, delay, color, title, desc, icon)
    return Nemesis:MakeNotify({
        Title = title or ConfigFolder,
        Description = desc or "Notification",
        Content = msg or "Content",
        Color = getColor(color or "Default"),
        Delay = delay or 4,
        Icon = icon or ""
    })
end

Notify = Nt

-- ==================== DIALOG ====================
local ActiveDialog = nil

function Nemesis:Dialog(DialogConfig)
    DialogConfig = DialogConfig or {}
    DialogConfig.Title = DialogConfig.Title or "Dialog"
    DialogConfig.Content = DialogConfig.Content or ""
    DialogConfig.Buttons = DialogConfig.Buttons or {}

    if ActiveDialog and ActiveDialog.Parent then
        pcall(function() ActiveDialog:Destroy() end)
    end

    local DialogGui = Instance.new("ScreenGui")
    DialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    DialogGui.Name = "DialogGui"
    DialogGui.Parent = CoreGui

    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.ZIndex = 50
    Overlay.Name = "Overlay"
    Overlay.Parent = DialogGui

    local Dialog = Instance.new("ImageLabel")
    Dialog.Size = UDim2.new(0, 300, 0, 150)
    Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    Dialog.Image = "rbxassetid://9542022979"
    Dialog.ImageTransparency = 0
    Dialog.BorderSizePixel = 0
    Dialog.ZIndex = 51
    Dialog.Parent = Overlay

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Dialog

    local DialogGlow = Instance.new("Frame")
    DialogGlow.Size = UDim2.new(0, 310, 0, 160)
    DialogGlow.Position = UDim2.new(0.5, -155, 0.5, -80)
    DialogGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DialogGlow.BackgroundTransparency = 0.75
    DialogGlow.BorderSizePixel = 0
    DialogGlow.ZIndex = 50
    DialogGlow.Parent = Overlay

    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(0, 10)
    GlowCorner.Parent = DialogGlow

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(0, 191, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 140, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 191, 255))
    })
    Gradient.Rotation = 90
    Gradient.Parent = DialogGlow

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 4)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = DialogConfig.Title
    Title.TextSize = 22
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.ZIndex = 52
    Title.Parent = Dialog

    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -20, 0, 60)
    Message.Position = UDim2.new(0, 10, 0, 30)
    Message.BackgroundTransparency = 1
    Message.Font = Enum.Font.Gotham
    Message.Text = DialogConfig.Content
    Message.TextSize = 14
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextWrapped = true
    Message.ZIndex = 52
    Message.Parent = Dialog

    for i, buttonConfig in ipairs(DialogConfig.Buttons) do
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.45, -10, 0, 35)
        if i == 1 then
            Button.Position = UDim2.new(0.05, 0, 1, -55)
        else
            Button.Position = UDim2.new(0.5, 10, 1, -55)
        end
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.Text = buttonConfig.Name or "Button"
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 15
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextTransparency = 0.3
        Button.ZIndex = 52
        Button.Name = "DialogButton_" .. i
        Button.Parent = Dialog

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button

        Button.MouseButton1Click:Connect(function()
            if buttonConfig.Callback and type(buttonConfig.Callback) == "function" then
                pcall(function() buttonConfig.Callback() end)
            end
            pcall(function()
                DialogGui:Destroy()
                if ActiveDialog == DialogGui then ActiveDialog = nil end
            end)
        end)
    end

    ActiveDialog = DialogGui
    return DialogGui
end
-- ==================== AKHIR DIALOG ====================

function Nemesis:Window(GuiConfig)
    GuiConfig               = GuiConfig or {}
    GuiConfig.Title         = GuiConfig.Title or "Nemesis X"
    GuiConfig.Footer        = GuiConfig.Footer or "Nemesise :3"
    GuiConfig.Content       = GuiConfig.Content or ""
    GuiConfig.ShowUser      = GuiConfig.ShowUser or false
    GuiConfig.Color         = getColor(GuiConfig.Color or "Default")
    GuiConfig["Tab Width"]  = GuiConfig["Tab Width"] or 120
    GuiConfig.Version       = GuiConfig.Version or 1
    GuiConfig.Uitransparent = GuiConfig.Uitransparent or 0
    GuiConfig.Image         = GuiConfig.Image or "70884221600423"
    GuiConfig.Configname    = GuiConfig.Configname or "Nemesis UI"
    GuiConfig.Size          = GuiConfig.Size or UDim2.fromOffset(640, 400)
    GuiConfig.Search        = GuiConfig.Search ~= nil and GuiConfig.Search or false

    GuiConfig.Config = GuiConfig.Config or {}
    GuiConfig.Config.AutoSave = GuiConfig.Config.AutoSave ~= nil and GuiConfig.Config.AutoSave or true
    GuiConfig.Config.AutoLoad = GuiConfig.Config.AutoLoad ~= nil and GuiConfig.Config.AutoLoad or true

    CURRENT_VERSION = GuiConfig.Version
    AUTO_SAVE       = GuiConfig.Config.AutoSave
    AUTO_LOAD       = GuiConfig.Config.AutoLoad

    ConfigFolder = GuiConfig.Configname

    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    if not isfolder(ConfigFolder .. "/Config") then makefolder(ConfigFolder .. "/Config") end

    local gameName = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
    gameName = gameName:gsub("[^%w_ ]", "")
    gameName = gameName:gsub("%s+", "_")
    ConfigFile = ConfigFolder .. "/Config/CHX_" .. gameName .. ".json"

    if AUTO_LOAD then LoadConfigFromFile() end

    ElementsModule:Initialize(GuiConfig, SaveConfig, ConfigData, Icons)
    
    local GuiFunc = {}

    local NemesisGui           = Instance.new("ScreenGui")
    local DropShadowHolder  = Instance.new("Frame")
    local DropShadow        = Instance.new("ImageLabel")
    local Main              = Instance.new("Frame")
    local UICorner          = Instance.new("UICorner")
    local Top               = Instance.new("Frame")
    local TextLabel         = Instance.new("TextLabel")
    local UICorner1         = Instance.new("UICorner")
    local TextLabel1        = Instance.new("TextLabel")
    local Close             = Instance.new("TextButton")
    local ImageLabel1       = Instance.new("ImageLabel")
    local Min               = Instance.new("TextButton")
    local ImageLabel2       = Instance.new("ImageLabel")

    NemesisGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NemesisGui.Name = "Nemesis"
    NemesisGui.ResetOnSpawn = false
    NemesisGui.Parent = game:GetService("CoreGui")

    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)

    local baseW = GuiConfig.Size.X.Offset
    local baseH = GuiConfig.Size.Y.Offset
    if isMobile then
        DropShadowHolder.Size = safeSize(math.min(baseW, 470), math.min(baseH, 270))
    else
        DropShadowHolder.Size = safeSize(baseW, baseH)
    end

    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = NemesisGui

    DropShadowHolder.Position = UDim2.new(
        0, (NemesisGui.AbsoluteSize.X // 2 - DropShadowHolder.Size.X.Offset // 2),
        0, (NemesisGui.AbsoluteSize.Y // 2 - DropShadowHolder.Size.Y.Offset // 2)
    )

    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    DropShadow.ImageTransparency = 1
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    if GuiConfig.Theme then
        Main:Destroy()
        Main = Instance.new("ImageLabel")
        Main.Image = "rbxassetid://" .. GuiConfig.Theme
        Main.ScaleType = Enum.ScaleType.Crop
        Main.BackgroundTransparency = 1
        Main.ImageTransparency = GuiConfig.ThemeTransparency or GuiConfig.Uitransparent or 0.15
    else
        Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Main.BackgroundTransparency = GuiConfig.Uitransparent or 0
    end

    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow

    UICorner.Parent = Main

    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.9990000128746033
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Parent = Main

    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = GuiConfig.Title
    TextLabel.TextColor3 = GuiConfig.Color
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 0.9990000128746033
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, -100, 1, 0)
    TextLabel.Position = UDim2.new(0, 10, 0, 0)
    TextLabel.Parent = Top

    UICorner1.Parent = Top

    TextLabel1.Font = Enum.Font.GothamBold
    TextLabel1.Text = GuiConfig.Footer
    TextLabel1.TextColor3 = GuiConfig.Color
    TextLabel1.TextSize = 14
    TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel1.BackgroundTransparency = 0.9990000128746033
    TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel1.BorderSizePixel = 0
    TextLabel1.Size = UDim2.new(1, -(TextLabel.TextBounds.X + 104), 1, 0)
    TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
    TextLabel1.Parent = Top

    local function UpdateFooterPosition()
        local titleWidth = TextLabel.TextBounds.X
        TextLabel1.Position = UDim2.new(0, titleWidth + 15, 0, 0)
        TextLabel1.Size = UDim2.new(1, -(titleWidth + 104), 1, 0)
    end

    TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(UpdateFooterPosition)
    UpdateFooterPosition()

    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Close.BackgroundTransparency = 0.9990000128746033
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    ImageLabel1.Image = "rbxassetid://9886659671"
    ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel1.BackgroundTransparency = 0.9990000128746033
    ImageLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel1.BorderSizePixel = 0
    ImageLabel1.Position = UDim2.new(0.49, 0, 0.5, 0)
    ImageLabel1.Size = UDim2.new(1, -8, 1, -8)
    ImageLabel1.Parent = Close

    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Min.BackgroundTransparency = 0.9990000128746033
    Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -38, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    ImageLabel2.Image = "rbxassetid://9886659276"
    ImageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel2.BackgroundTransparency = 0.9990000128746033
    ImageLabel2.ImageTransparency = 0.2
    ImageLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel2.BorderSizePixel = 0
    ImageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel2.Size = UDim2.new(1, -9, 1, -9)
    ImageLabel2.Parent = Min

    if GuiConfig.Content and GuiConfig.Content ~= "" then
        local ContentFrame = Instance.new("Frame")
        ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ContentFrame.BorderSizePixel = 0
        ContentFrame.Size = UDim2.new(1, 0, 0, 25)
        ContentFrame.Position = UDim2.new(0, 0, 0, 38)
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Parent = Main

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Font = Enum.Font.GothamBold
        ContentLabel.Text = GuiConfig.Content
        ContentLabel.TextColor3 = GuiConfig.Color
        ContentLabel.TextSize = 14
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Center
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Center
        ContentLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ContentLabel.BorderSizePixel = 0
        ContentLabel.Size = UDim2.new(1, -20, 1, 0)
        ContentLabel.Position = UDim2.new(0, 10, 0, 0)
        ContentLabel.Parent = ContentFrame

        local Divider = Instance.new("Frame")
        Divider.BackgroundColor3 = GuiConfig.Color
        Divider.BackgroundTransparency = 0.8
        Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Divider.BorderSizePixel = 0
        Divider.Size = UDim2.new(1, -20, 0, 1)
        Divider.Position = UDim2.new(0, 10, 1, -1)
        Divider.Parent = ContentFrame
    end

    local LayersTab        = Instance.new("Frame")
    local UICorner2        = Instance.new("UICorner")
    local DecideFrame      = Instance.new("Frame")
    local Layers           = Instance.new("Frame")
    local UICorner6        = Instance.new("UICorner")
    local NameTab          = Instance.new("TextLabel")
    local LayersReal       = Instance.new("Frame")
    local LayersFolder     = Instance.new("Folder")
    local LayersPageLayout = Instance.new("UIPageLayout")

    local topOffset
    if GuiConfig.Content and GuiConfig.Content ~= "" then
        topOffset = 38 + 25 + 10
    else
        topOffset = 50
    end

    LayersTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LayersTab.BackgroundTransparency = 0.9990000128746033
    LayersTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LayersTab.BorderSizePixel = 0
    LayersTab.Position = UDim2.new(0, 9, 0, topOffset)
    LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -(topOffset + 9))
    LayersTab.Name = "LayersTab"
    LayersTab.Parent = Main

    UICorner2.CornerRadius = UDim.new(0, 2)
    UICorner2.Parent = LayersTab

    local ScrollTab    = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")

    ScrollTab.CanvasSize = UDim2.new(0, 0, 1.10000002, 0)
    ScrollTab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ScrollTab.BackgroundTransparency = 0.9990000128746033
    ScrollTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.BorderSizePixel = 0
    ScrollTab.Name = "ScrollTab"

    -- ==================== SEARCH BAR ====================
    local searchOffset = 0

    if GuiConfig.Search then
        searchOffset = 34

        local SearchContainer = Instance.new("Frame")
        SearchContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SearchContainer.BackgroundTransparency = 0.88
        SearchContainer.BorderSizePixel = 0
        SearchContainer.Size = UDim2.new(1, 0, 0, 28)
        SearchContainer.Position = UDim2.new(0, 0, 0, 0)
        SearchContainer.Name = "SearchContainer"
        SearchContainer.Parent = LayersTab

        local SearchCorner = Instance.new("UICorner")
        SearchCorner.CornerRadius = UDim.new(0, 5)
        SearchCorner.Parent = SearchContainer

        local SearchStroke = Instance.new("UIStroke")
        SearchStroke.Color = GuiConfig.Color
        SearchStroke.Thickness = 1
        SearchStroke.Transparency = 1
        SearchStroke.Parent = SearchContainer

        local SearchIcon = Instance.new("ImageLabel")
        SearchIcon.BackgroundTransparency = 1
        SearchIcon.BorderSizePixel = 0
        SearchIcon.Position = UDim2.new(0, 7, 0.5, -7)
        SearchIcon.Size = UDim2.new(0, 14, 0, 14)
        SearchIcon.Image = "rbxassetid://3926305904"
        SearchIcon.ImageRectOffset = Vector2.new(964, 324)
        SearchIcon.ImageRectSize = Vector2.new(36, 36)
        SearchIcon.ImageColor3 = Color3.fromRGB(160, 160, 160)
        SearchIcon.Parent = SearchContainer

        local SearchBox = Instance.new("TextBox")
        SearchBox.Font = Enum.Font.Gotham
        SearchBox.PlaceholderText = "Search..."
        SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
        SearchBox.Text = ""
        SearchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
        SearchBox.TextSize = 12
        SearchBox.TextXAlignment = Enum.TextXAlignment.Left
        SearchBox.BackgroundTransparency = 1
        SearchBox.BorderSizePixel = 0
        SearchBox.ClearTextOnFocus = false
        SearchBox.Position = UDim2.new(0, 26, 0, 0)
        SearchBox.Size = UDim2.new(1, -30, 1, 0)
        SearchBox.Name = "SearchBox"
        SearchBox.Parent = SearchContainer

        local ClearBtn = Instance.new("TextButton")
        ClearBtn.Font = Enum.Font.GothamBold
        ClearBtn.Text = "×"
        ClearBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        ClearBtn.TextSize = 16
        ClearBtn.BackgroundTransparency = 1
        ClearBtn.BorderSizePixel = 0
        ClearBtn.AnchorPoint = Vector2.new(1, 0.5)
        ClearBtn.Position = UDim2.new(1, -4, 0.5, 0)
        ClearBtn.Size = UDim2.new(0, 20, 0, 20)
        ClearBtn.ZIndex = 10
        ClearBtn.Visible = false
        ClearBtn.Name = "ClearBtn"
        ClearBtn.Parent = SearchContainer

        ClearBtn.MouseButton1Click:Connect(function()
            SearchBox.Text = ""
        end)

        local MiniDropdown = Instance.new("Frame")
        MiniDropdown.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        MiniDropdown.BackgroundTransparency = 0
        MiniDropdown.BorderSizePixel = 0
        MiniDropdown.ClipsDescendants = true
        MiniDropdown.Position = UDim2.new(0, 0, 0, 30)
        MiniDropdown.Size = UDim2.new(1, 0, 0, 0)
        MiniDropdown.ZIndex = 20
        MiniDropdown.Visible = false
        MiniDropdown.Name = "MiniDropdown"
        MiniDropdown.Parent = LayersTab

        local MiniCorner = Instance.new("UICorner")
        MiniCorner.CornerRadius = UDim.new(0, 6)
        MiniCorner.Parent = MiniDropdown

        local MiniStroke = Instance.new("UIStroke")
        MiniStroke.Color = Color3.fromRGB(50, 50, 50)
        MiniStroke.Thickness = 1
        MiniStroke.Transparency = 0
        MiniStroke.Parent = MiniDropdown

        local ResultScroll = Instance.new("ScrollingFrame")
        ResultScroll.ScrollBarThickness = 2
        ResultScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        ResultScroll.BackgroundTransparency = 1
        ResultScroll.BorderSizePixel = 0
        ResultScroll.Position = UDim2.new(0, 0, 0, 0)
        ResultScroll.Size = UDim2.new(1, 0, 1, 0)
        ResultScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        ResultScroll.ZIndex = 21
        ResultScroll.Name = "ResultScroll"
        ResultScroll.Parent = MiniDropdown

        local ResultList = Instance.new("UIListLayout")
        ResultList.Padding = UDim.new(0, 0)
        ResultList.SortOrder = Enum.SortOrder.LayoutOrder
        ResultList.Parent = ResultScroll

        ResultList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ResultScroll.CanvasSize = UDim2.new(0, 0, 0, ResultList.AbsoluteContentSize.Y)
        end)

        local NoResultLabel = Instance.new("TextLabel")
        NoResultLabel.Font = Enum.Font.Gotham
        NoResultLabel.Text = "No results found"
        NoResultLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        NoResultLabel.TextSize = 11
        NoResultLabel.BackgroundTransparency = 1
        NoResultLabel.BorderSizePixel = 0
        NoResultLabel.Size = UDim2.new(1, 0, 0, 36)
        NoResultLabel.ZIndex = 22
        NoResultLabel.Visible = false
        NoResultLabel.Name = "NoResultLabel"
        NoResultLabel.Parent = MiniDropdown

        local ITEM_H = 36
        local MAX_VISIBLE = 5
        local function ResizeDropdown(count)
            local h = math.min(count, MAX_VISIBLE) * ITEM_H
            if count == 0 then h = ITEM_H end
            MiniDropdown.Size = UDim2.new(1, 0, 0, h)
        end

        local SearchOverlay = MiniDropdown
        local OverlayHeader = { Text = "" }

        local function NavigateToItem(tabLayoutOrder, sectionRef, itemRef)
            LayersPageLayout:JumpToIndex(tabLayoutOrder)

            for _, tabFrame in _G.ScrollTab:GetChildren() do
                if tabFrame.Name == "Tab" then
                    TweenService:Create(tabFrame, TweenInfo.new(0.3), {
                        BackgroundTransparency = tabFrame.LayoutOrder == tabLayoutOrder
                            and 0.9200000166893005
                            or  0.9990000128746033
                    }):Play()
                end
            end

            for _, tabFrame in _G.ScrollTab:GetChildren() do
                if tabFrame.Name == "Tab" and tabFrame.LayoutOrder == tabLayoutOrder then
                    local tn = tabFrame:FindFirstChild("TabName")
                    if tn then
                        NameTab.Text = tn.Text:gsub("^╏ ", "")
                    end
                end
            end

            if sectionRef then
                local sectionAdd   = sectionRef:FindFirstChild("SectionAdd")
                local sectionReal  = sectionRef:FindFirstChild("SectionReal")
                local featureFrame = sectionReal and sectionReal:FindFirstChild("FeatureFrame")
                local decideFr     = sectionRef:FindFirstChild("SectionDecideFrame")

                if sectionAdd then
                    local h = 38
                    for _, v in sectionAdd:GetChildren() do
                        if v:IsA("Frame") and v.Name ~= "UICorner" then
                            h = h + v.Size.Y.Offset + 3
                        end
                    end
                    TweenService:Create(sectionRef, TweenInfo.new(0.4), { Size = UDim2.new(1, 1, 0, h) }):Play()
                    TweenService:Create(sectionAdd, TweenInfo.new(0.4), { Size = UDim2.new(1, 0, 0, h - 38) }):Play()
                    if featureFrame then
                        TweenService:Create(featureFrame, TweenInfo.new(0.4), { Rotation = 90 }):Play()
                    end
                    if decideFr then
                        TweenService:Create(decideFr, TweenInfo.new(0.4), { Size = UDim2.new(1, 0, 0, 2) }):Play()
                    end
                end

                task.wait(0.45)
                if itemRef then
                    local scrolParent
                    for _, sc in LayersFolder:GetChildren() do
                        if sc:IsA("ScrollingFrame") and sc.LayoutOrder == tabLayoutOrder then
                            scrolParent = sc
                            break
                        end
                    end
                    if scrolParent then
                        local offsetY = 0
                        for _, sec in scrolParent:GetChildren() do
                            if sec.Name == "Section" then
                                if sec == sectionRef then
                                    local secAdd = sec:FindFirstChild("SectionAdd")
                                    if secAdd then
                                        local innerY = 0
                                        for _, it in secAdd:GetChildren() do
                                            if it.Name ~= "UIListLayout" and it.Name ~= "UICorner" then
                                                if it == itemRef then break end
                                                innerY = innerY + it.Size.Y.Offset + 3
                                            end
                                        end
                                        offsetY = offsetY + 38 + innerY
                                    end
                                    break
                                else
                                    offsetY = offsetY + sec.Size.Y.Offset + 3
                                end
                            end
                        end
                        TweenService:Create(scrolParent, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                            CanvasPosition = Vector2.new(0, math.max(0, offsetY - 10))
                        }):Play()

                        local origTrans = itemRef.BackgroundTransparency
                        TweenService:Create(itemRef, TweenInfo.new(0.3), { BackgroundTransparency = 0.5 }):Play()
                        task.wait(0.5)
                        TweenService:Create(itemRef, TweenInfo.new(0.5), { BackgroundTransparency = origTrans }):Play()
                    end
                end
            end
        end

        local function CreateResultCard(tabName, tabOrder, sectionRef, sectionTitle, itemName, itemRef, orderIdx)
            local Row = Instance.new("Frame")
            Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Row.BackgroundTransparency = 1
            Row.BorderSizePixel = 0
            Row.Size = UDim2.new(1, 0, 0, ITEM_H)
            Row.LayoutOrder = orderIdx
            Row.Name = "ResultRow"
            Row.ZIndex = 21
            Row.Parent = ResultScroll

            local Divider = Instance.new("Frame")
            Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Divider.BackgroundTransparency = 0
            Divider.BorderSizePixel = 0
            Divider.AnchorPoint = Vector2.new(0, 1)
            Divider.Position = UDim2.new(0, 0, 1, 0)
            Divider.Size = UDim2.new(1, 0, 0, 1)
            Divider.ZIndex = 22
            Divider.Parent = Row

            local RowIcon = Instance.new("ImageLabel")
            RowIcon.BackgroundTransparency = 1
            RowIcon.BorderSizePixel = 0
            RowIcon.Position = UDim2.new(0, 10, 0.5, -8)
            RowIcon.Size = UDim2.new(0, 16, 0, 16)
            RowIcon.ImageColor3 = Color3.fromRGB(130, 130, 130)
            RowIcon.Image = "rbxassetid://86512767702085"
            RowIcon.ImageRectOffset = Vector2.new(0, 0)
            RowIcon.ImageRectSize = Vector2.new(0, 0)
            RowIcon.ZIndex = 22
            RowIcon.Parent = Row

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.Text = itemName
            NameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            NameLabel.TextSize = 12
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            NameLabel.BackgroundTransparency = 1
            NameLabel.BorderSizePixel = 0
            NameLabel.Position = UDim2.new(0, 32, 0, 5)
            NameLabel.Size = UDim2.new(1, -36, 0, 14)
            NameLabel.ZIndex = 22
            NameLabel.Parent = Row

            local BreadLabel = Instance.new("TextLabel")
            BreadLabel.Font = Enum.Font.Gotham
            BreadLabel.Text = tabName .. " › " .. sectionTitle
            BreadLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
            BreadLabel.TextSize = 10
            BreadLabel.TextXAlignment = Enum.TextXAlignment.Left
            BreadLabel.TextTruncate = Enum.TextTruncate.AtEnd
            BreadLabel.BackgroundTransparency = 1
            BreadLabel.BorderSizePixel = 0
            BreadLabel.Position = UDim2.new(0, 32, 0, 20)
            BreadLabel.Size = UDim2.new(1, -36, 0, 12)
            BreadLabel.ZIndex = 22
            BreadLabel.Parent = Row

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.ZIndex = 23
            ClickBtn.Parent = Row

            ClickBtn.MouseEnter:Connect(function()
                TweenService:Create(Row, TweenInfo.new(0.12), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    BackgroundTransparency = 0
                }):Play()
                TweenService:Create(NameLabel, TweenInfo.new(0.12), {
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
            end)
            ClickBtn.MouseLeave:Connect(function()
                TweenService:Create(Row, TweenInfo.new(0.12), {
                    BackgroundTransparency = 1
                }):Play()
                TweenService:Create(NameLabel, TweenInfo.new(0.12), {
                    TextColor3 = Color3.fromRGB(230, 230, 230)
                }):Play()
            end)

            ClickBtn.MouseButton1Click:Connect(function()
                SearchBox.Text = ""
                MiniDropdown.Visible = false
                ClearBtn.Visible = false
                task.spawn(function()
                    task.wait(0.05)
                    NavigateToItem(tabOrder, sectionRef, itemRef)
                end)
            end)

            return Row
        end

        local function PerformSearch(query)
            query = query:lower():gsub("^%s+", ""):gsub("%s+$", "")
            local isSearching = query ~= ""

            ClearBtn.Visible = isSearching

            if not isSearching then
                MiniDropdown.Visible = false
                return
            end

            for _, child in ResultScroll:GetChildren() do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            local resultCount = 0
            local orderIdx = 0

            for _, scrolLayers in LayersFolder:GetChildren() do
                if scrolLayers:IsA("ScrollingFrame") then
                    local tabOrder = scrolLayers.LayoutOrder

                    local tabName = "Tab"
                    for _, tabFrame in _G.ScrollTab:GetChildren() do
                        if tabFrame.Name == "Tab" and tabFrame.LayoutOrder == tabOrder then
                            local tn = tabFrame:FindFirstChild("TabName")
                            if tn then
                                tabName = tn.Text:gsub("^╏ ", "")
                            end
                            break
                        end
                    end

                    for _, section in scrolLayers:GetChildren() do
                        if section.Name == "Section" then
                            local sectionAdd  = section:FindFirstChild("SectionAdd")
                            local sectionReal = section:FindFirstChild("SectionReal")

                            local sectionTitle = "Section"
                            if sectionReal then
                                local st = sectionReal:FindFirstChild("SectionTitle")
                                if st then sectionTitle = st.Text end
                            end

                            if sectionAdd then
                                for _, item in sectionAdd:GetChildren() do
                                    if item:IsA("Frame") and item.Name ~= "UICorner" then
                                        local titleText  = ""
                                        local displayName = ""

                                        local bestSize = 0
                                        for _, child in item:GetChildren() do
                                            if child:IsA("TextLabel") and child.Text ~= "" then
                                                local txt = child.Text
                                                if #txt > 1 and not txt:match("^%[") and child.TextSize >= bestSize then
                                                    bestSize = child.TextSize
                                                    titleText = txt:lower()
                                                    displayName = txt
                                                end
                                            end
                                        end

                                        if titleText:find(query, 1, true) ~= nil and titleText ~= "" then
                                            CreateResultCard(
                                                tabName,
                                                tabOrder,
                                                section,
                                                sectionTitle,
                                                displayName ~= "" and displayName or "Item",
                                                item,
                                                orderIdx
                                            )
                                            orderIdx    = orderIdx + 1
                                            resultCount = resultCount + 1
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            NoResultLabel.Visible = (resultCount == 0)
            MiniDropdown.Visible = true
            ResizeDropdown(resultCount)
        end

        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            PerformSearch(SearchBox.Text)
        end)
    end
    -- ==================== END SEARCH BAR ====================

    if GuiConfig.ShowUser then
        ScrollTab.Position = UDim2.new(0, 0, 0, searchOffset)
        ScrollTab.Size = UDim2.new(1, 0, 1, -(40 + searchOffset))
    else
        ScrollTab.Position = UDim2.new(0, 0, 0, searchOffset)
        ScrollTab.Size = UDim2.new(1, 0, 1, -searchOffset)
    end

    ScrollTab.Parent = LayersTab

    UIListLayout.Padding = UDim.new(0, 3)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollTab

    local function UpdateSize1()
        local OffsetY = 0
        for _, child in ScrollTab:GetChildren() do
            if child.Name ~= "UIListLayout" then
                OffsetY = OffsetY + 3 + child.Size.Y.Offset
            end
        end
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end
    ScrollTab.ChildAdded:Connect(UpdateSize1)
    ScrollTab.ChildRemoved:Connect(UpdateSize1)
    if GuiConfig.ShowUser then
        local UserInfoFrame = Instance.new("Frame")
        UserInfoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        UserInfoFrame.BackgroundTransparency = 0.3
        UserInfoFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        UserInfoFrame.BorderSizePixel = 0
        UserInfoFrame.Position = UDim2.new(0, 5, 1, -45)
        UserInfoFrame.Size = UDim2.new(1, -10, 0, 40)
        UserInfoFrame.Name = "UserInfoFrame"
        UserInfoFrame.Parent = LayersTab

        local UserInfoCorner = Instance.new("UICorner")
        UserInfoCorner.CornerRadius = UDim.new(0, 6)
        UserInfoCorner.Parent = UserInfoFrame

        local UserInfoStroke = Instance.new("UIStroke")
        UserInfoStroke.Color = Color3.fromRGB(142, 130, 254)
        UserInfoStroke.Thickness = 1
        UserInfoStroke.Transparency = 0.5
        UserInfoStroke.Parent = UserInfoFrame

        local Avatar = Instance.new("ImageLabel")
        Avatar.BackgroundTransparency = 1  -- transparan, ga ada background ungu
        Avatar.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Avatar.BorderSizePixel = 0
        Avatar.Position = UDim2.new(0, 5, 0.5, -15)
        Avatar.Size = UDim2.new(0, 30, 0, 30)
        Avatar.ScaleType = Enum.ScaleType.Fit
        Avatar.Name = "Avatar"
        Avatar.Parent = UserInfoFrame

        local AvatarCorner = Instance.new("UICorner")
        AvatarCorner.CornerRadius = UDim.new(1, 0)
        AvatarCorner.Parent = Avatar

        Avatar.Image = "rbxassetid://82972649071701"

        local DisplayName = Instance.new("TextLabel")
        DisplayName.Font = Enum.Font.GothamBold
        DisplayName.Text = "NEMESIS"
        DisplayName.TextColor3 = Color3.fromRGB(255, 255, 255)
        DisplayName.TextSize = 12
        DisplayName.TextXAlignment = Enum.TextXAlignment.Left
        DisplayName.TextTruncate = Enum.TextTruncate.AtEnd  -- biar ga keluar frame
        DisplayName.BackgroundTransparency = 1
        DisplayName.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DisplayName.BorderSizePixel = 0
        DisplayName.Position = UDim2.new(0, 40, 0, 5)
        DisplayName.Size = UDim2.new(1, -48, 0, 16)  -- size lebih pas
        DisplayName.Name = "DisplayName"
        DisplayName.Parent = UserInfoFrame

        local GradientDisplay = Instance.new("UIGradient")
        GradientDisplay.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(142, 130, 254)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(210, 205, 255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(142, 130, 254))
        })
        GradientDisplay.Rotation = 0
        GradientDisplay.Parent = DisplayName

        local Username = Instance.new("TextLabel")
        Username.Font = Enum.Font.Gotham
        Username.Text = "JOIN DISCORD"
        Username.TextColor3 = Color3.fromRGB(255, 255, 255)
        Username.TextSize = 10
        Username.TextXAlignment = Enum.TextXAlignment.Left
        Username.TextTruncate = Enum.TextTruncate.AtEnd  -- biar ga keluar frame
        Username.BackgroundTransparency = 1
        Username.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Username.BorderSizePixel = 0
        Username.Position = UDim2.new(0, 40, 0, 22)
        Username.Size = UDim2.new(1, -48, 0, 13)  -- size lebih pas
        Username.Name = "Username"
        Username.Parent = UserInfoFrame

        local GradientUsername = Instance.new("UIGradient")
        GradientUsername.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(142, 130, 254)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 170, 255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(142, 130, 254))
        })
        GradientUsername.Rotation = 0
        GradientUsername.Parent = Username
    end
    _G.ScrollTab = ScrollTab

    DecideFrame.AnchorPoint = Vector2.new(0.5, 0)
    DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DecideFrame.BackgroundTransparency = 0.85
    DecideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DecideFrame.BorderSizePixel = 0
    DecideFrame.Position = UDim2.new(0.5, 0, 0, 38)
    DecideFrame.Size = UDim2.new(1, 0, 0, 1)
    DecideFrame.Name = "DecideFrame"
    DecideFrame.Parent = Main

    Layers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Layers.BackgroundTransparency = 0.9990000128746033
    Layers.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Layers.BorderSizePixel = 0
    Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 18, 0, topOffset)
    Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 9 + 18), 1, -(topOffset + 9))
    Layers.Name = "Layers"
    Layers.Parent = Main

    UICorner6.CornerRadius = UDim.new(0, 2)
    UICorner6.Parent = Layers

    NameTab.Font = Enum.Font.GothamBold
    NameTab.Text = ""
    NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.TextSize = 24
    NameTab.TextWrapped = true
    NameTab.TextXAlignment = Enum.TextXAlignment.Left
    NameTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.BackgroundTransparency = 0.9990000128746033
    NameTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    NameTab.BorderSizePixel = 0
    NameTab.Size = UDim2.new(1, 0, 0, 30)
    NameTab.Name = "NameTab"
    NameTab.Parent = Layers

    LayersReal.AnchorPoint = Vector2.new(0, 1)
    LayersReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LayersReal.BackgroundTransparency = 0.9990000128746033
    LayersReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LayersReal.BorderSizePixel = 0
    LayersReal.ClipsDescendants = true
    LayersReal.Position = UDim2.new(0, 0, 1, 0)
    LayersReal.Size = UDim2.new(1, 0, 1, -33)
    LayersReal.Name = "LayersReal"
    LayersReal.Parent = Layers

    LayersFolder.Name = "LayersFolder"
    LayersFolder.Parent = LayersReal

    LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LayersPageLayout.Name = "LayersPageLayout"
    LayersPageLayout.Parent = LayersFolder
    LayersPageLayout.TweenTime = 0.5
    LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
    LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad

    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("Nemesis") then
            NemesisGui:Destroy()
        end
    end

    function GuiFunc:SetToggleKey(keyCode)
        GuiConfig.Keybind = keyCode
    end

    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
    end)

    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        Nemesis:Dialog({
            Title = GuiConfig.Configname .. " Window",
            Content = "Do you want to close this window?\nYou will not be able to open it again",
            Buttons = {
                {
                    Name = "Yes",
                    Callback = function()
                        if Nemesis then NemesisGui:Destroy() end
                        if GuiFunc._toggleGui then
                            pcall(function() GuiFunc._toggleGui:Destroy() end)
                            GuiFunc._toggleGui = nil
                        end
                    end
                },
                {
                    Name = "Cancel",
                    Callback = function() end
                }
            }
        })
    end)

    function GuiFunc:ToggleUI()
        if GuiFunc._toggleGui then
            pcall(function() GuiFunc._toggleGui:Destroy() end)
            GuiFunc._toggleGui = nil
        end

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game:GetService("CoreGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "ToggleUIButton"

        GuiFunc._toggleGui = ScreenGui

        local MainButton = Instance.new("ImageLabel")
        MainButton.Parent = ScreenGui
        MainButton.Size = UDim2.new(0, 40, 0, 40)
        MainButton.Position = UDim2.new(0, 20, 0, 100)
        MainButton.BackgroundTransparency = 1
        MainButton.Image = "rbxassetid://" .. GuiConfig.Image
        MainButton.ScaleType = Enum.ScaleType.Fit

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = MainButton

        local Button = Instance.new("TextButton")
        Button.Parent = MainButton
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""

        Button.MouseButton1Click:Connect(function()
            if DropShadowHolder then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end)

        local dragging = false
        local dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            MainButton.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end

        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
    end

    GuiFunc:ToggleUI()

    GuiConfig.Keybind = GuiConfig.Keybind or Enum.KeyCode.RightShift

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == GuiConfig.Keybind then
            DropShadowHolder.Visible = not DropShadowHolder.Visible
        end
    end)

    MakeDraggable(Top, DropShadowHolder, GuiConfig)

    local MoreBlur          = Instance.new("Frame")
    local DropShadowHolder1 = Instance.new("Frame")
    local DropShadow1       = Instance.new("ImageLabel")
    local UICorner28        = Instance.new("UICorner")
    local ConnectButton     = Instance.new("TextButton")

    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BorderSizePixel = 0
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = Layers

    DropShadowHolder1.BackgroundTransparency = 1
    DropShadowHolder1.BorderSizePixel = 0
    DropShadowHolder1.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder1.ZIndex = 0
    DropShadowHolder1.Name = "DropShadowHolder"
    DropShadowHolder1.Parent = MoreBlur

    DropShadow1.Image = "rbxassetid://6015897843"
    DropShadow1.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow1.ImageTransparency = 1
    DropShadow1.ScaleType = Enum.ScaleType.Slice
    DropShadow1.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow1.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow1.BackgroundTransparency = 1
    DropShadow1.BorderSizePixel = 0
    DropShadow1.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow1.Size = UDim2.new(1, 35, 1, 35)
    DropShadow1.ZIndex = 0
    DropShadow1.Name = "DropShadow"
    DropShadow1.Parent = DropShadowHolder1

    UICorner28.Parent = MoreBlur

    ConnectButton.Font = Enum.Font.SourceSans
    ConnectButton.Text = ""
    ConnectButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    ConnectButton.TextSize = 14
    ConnectButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ConnectButton.BackgroundTransparency = 0.999
    ConnectButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ConnectButton.BorderSizePixel = 0
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Name = "ConnectButton"
    ConnectButton.Parent = MoreBlur

    local DropdownSelect     = Instance.new("Frame")
    local UICorner36         = Instance.new("UICorner")
    local UIStroke14         = Instance.new("UIStroke")
    local DropdownSelectReal = Instance.new("Frame")
    local DropdownFolder     = Instance.new("Folder")
    local DropPageLayout     = Instance.new("UIPageLayout")

    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownSelect.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelect.BorderSizePixel = 0
    DropdownSelect.LayoutOrder = 1
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Parent = MoreBlur

    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            MoreBlur.BackgroundTransparency = 0.999
            DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
            task.wait(0.3)
            MoreBlur.Visible = false
        end
    end)

    UICorner36.CornerRadius = UDim.new(0, 3)
    UICorner36.Parent = DropdownSelect

    UIStroke14.Color = Color3.fromRGB(12, 159, 255)
    UIStroke14.Thickness = 2.5
    UIStroke14.Transparency = 0.8
    UIStroke14.Parent = DropdownSelect

    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(0, 27, 98)
    DropdownSelectReal.BackgroundTransparency = 0.7
    DropdownSelectReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelectReal.BorderSizePixel = 0
    DropdownSelectReal.LayoutOrder = 1
    DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownSelectReal.Size = UDim2.new(1, 1, 1, 1)
    DropdownSelectReal.Name = "DropdownSelectReal"
    DropdownSelectReal.Parent = DropdownSelect

    DropdownFolder.Name = "DropdownFolder"
    DropdownFolder.Parent = DropdownSelectReal

    DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
    DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
    DropPageLayout.TweenTime = 0.009999999776482582
    DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropPageLayout.FillDirection = Enum.FillDirection.Vertical
    DropPageLayout.Archivable = false
    DropPageLayout.Name = "DropPageLayout"
    DropPageLayout.Parent = DropdownFolder

    --// Tabs
    local Tabs = {}
    local CountTab = 0
    local CountDropdown = 0

    function Tabs:AddTab(TabConfig)
        local TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""

        local ScrolLayers   = Instance.new("ScrollingFrame")
        local UIListLayout1 = Instance.new("UIListLayout")

        ScrolLayers.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        ScrolLayers.ScrollBarThickness = 0
        ScrolLayers.Active = true
        ScrolLayers.LayoutOrder = CountTab
        ScrolLayers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ScrolLayers.BackgroundTransparency = 0.9990000128746033
        ScrolLayers.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ScrolLayers.BorderSizePixel = 0
        ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
        ScrolLayers.Name = "ScrolLayers"
        ScrolLayers.Parent = LayersFolder

        UIListLayout1.Padding = UDim.new(0, 3)
        UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout1.Parent = ScrolLayers

        local Tab        = Instance.new("Frame")
        local UICorner3  = Instance.new("UICorner")
        local TabButton  = Instance.new("TextButton")
        local TabName    = Instance.new("TextLabel")
        local FeatureImg = Instance.new("ImageLabel")
        local UIStroke2  = Instance.new("UIStroke")
        local UICorner4  = Instance.new("UICorner")

        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        if CountTab == 0 then
            Tab.BackgroundTransparency = 0.9200000166893005
        else
            Tab.BackgroundTransparency = 0.9990000128746033
        end
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BorderSizePixel = 0
        Tab.LayoutOrder = CountTab
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.Name = "Tab"
        Tab.Parent = _G.ScrollTab

        UICorner3.CornerRadius = UDim.new(0, 4)
        UICorner3.Parent = Tab

        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 0.9990000128746033
        TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        TabName.Font = Enum.Font.GothamBold
        TabName.Text = "╏ " .. tostring(TabConfig.Name)
        TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabName.TextSize = 13
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabName.BackgroundTransparency = 0.9990000128746033
        TabName.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabName.BorderSizePixel = 0
        TabName.Size = UDim2.new(1, 0, 1, 0)
        TabName.Position = UDim2.new(0, 30, 0, 0)
        TabName.Name = "TabName"
        TabName.Parent = Tab

        FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        FeatureImg.BackgroundTransparency = 0.9990000128746033
        FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0, 9, 0, 7)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab

        if TabConfig.Icon and TabConfig.Icon ~= "" then
            local iconId = getIconId(TabConfig.Icon)
            if iconId and iconId ~= "" then
                FeatureImg.Image = iconId
            end
        end

        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = TabConfig.Name
            local ChooseFrame = Instance.new("Frame")
            ChooseFrame.BackgroundColor3 = GuiConfig.Color
            ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ChooseFrame.BorderSizePixel = 0
            ChooseFrame.Position = UDim2.new(0, 2, 0, 9)
            ChooseFrame.Size = UDim2.new(0, 1, 0, 12)
            ChooseFrame.Name = "ChooseFrame"
            ChooseFrame.Parent = Tab

            UIStroke2.Color = GuiConfig.Color
            UIStroke2.Thickness = 1.6
            UIStroke2.Parent = ChooseFrame

            UICorner4.Parent = ChooseFrame
        end

        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            local FrameChoose
            for a, s in _G.ScrollTab:GetChildren() do
                for i, v in s:GetChildren() do
                    if v.Name == "ChooseFrame" then
                        FrameChoose = v
                        break
                    end
                end
            end
            if FrameChoose ~= nil and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                for _, TabFrame in _G.ScrollTab:GetChildren() do
                    if TabFrame.Name == "Tab" then
                        TweenService:Create(TabFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.9990000128746033 }):Play()
                    end
                end
                TweenService:Create(Tab, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.9200000166893005 }):Play()
                TweenService:Create(FrameChoose, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Position = UDim2.new(0, 2, 0, 9 + (33 * Tab.LayoutOrder)) }):Play()
                LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
                task.wait(0.05)
                NameTab.Text = TabConfig.Name
                TweenService:Create(FrameChoose, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 1, 0, 20) }):Play()
                task.wait(0.2)
                TweenService:Create(FrameChoose, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 1, 0, 12) }):Play()
            end
        end)

        --// Section
        local Sections = {}
        local CountSection = 0

        function Sections:AddSection(SectionConfig)
            local Title = "Section"
            local Icon = ""
            local Open = false

            if type(SectionConfig) == "string" then
                Title = SectionConfig
            elseif type(SectionConfig) == "table" then
                Title = SectionConfig.Title or "Section"
                Icon  = SectionConfig.Icon or ""
                Open  = SectionConfig.Open or false
            end

            local Section            = Instance.new("Frame")
            local SectionDecideFrame = Instance.new("Frame")
            local UICorner1          = Instance.new("UICorner")
            local UIGradient         = Instance.new("UIGradient")

            Section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Section.BackgroundTransparency = 0.9990000128746033
            Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Section.BorderSizePixel = 0
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            Section.LayoutOrder = 1
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.Name = "Section"
            Section.Parent = ScrolLayers

            local SectionReal   = Instance.new("Frame")
            local UICorner      = Instance.new("UICorner")
            local UIStroke      = Instance.new("UIStroke")
            local SectionButton = Instance.new("TextButton")
            local FeatureFrame  = Instance.new("Frame")
            local FeatureImg    = Instance.new("ImageLabel")
            local SectionTitle  = Instance.new("TextLabel")
            local SectionIcon   = Instance.new("ImageLabel")

            SectionReal.AnchorPoint = Vector2.new(0.5, 0)
            SectionReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionReal.BackgroundTransparency = 0.935
            SectionReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionReal.BorderSizePixel = 0
            SectionReal.LayoutOrder = 1
            SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
            SectionReal.Size = UDim2.new(1, 1, 0, 30)
            SectionReal.Name = "SectionReal"
            SectionReal.Parent = Section

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = SectionReal

            if Icon and Icon ~= "" then
                SectionIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SectionIcon.BackgroundTransparency = 0.9990000128746033
                SectionIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SectionIcon.BorderSizePixel = 0
                SectionIcon.Position = UDim2.new(0, 10, 0.5, -8)
                SectionIcon.Size = UDim2.new(0, 16, 0, 16)
                SectionIcon.Name = "SectionIcon"
                SectionIcon.Parent = SectionReal
                local iconId = getIconId(Icon)
                if iconId and iconId ~= "" then
                    SectionIcon.Image = iconId
                end
            end

            SectionButton.Font = Enum.Font.SourceSans
            SectionButton.Text = ""
            SectionButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            SectionButton.TextSize = 14
            SectionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionButton.BackgroundTransparency = 0.9990000128746033
            SectionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionButton.BorderSizePixel = 0
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.Name = "SectionButton"
            SectionButton.Parent = SectionReal

            FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
            FeatureFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            FeatureFrame.BackgroundTransparency = 0.9990000128746033
            FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            FeatureFrame.BorderSizePixel = 0
            FeatureFrame.Position = UDim2.new(1, -5, 0.5, 0)
            FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
            FeatureFrame.Name = "FeatureFrame"
            FeatureFrame.Parent = SectionReal

            FeatureImg.Image = "rbxassetid://16851841101"
            FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
            FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            FeatureImg.BackgroundTransparency = 0.9990000128746033
            FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
            FeatureImg.BorderSizePixel = 0
            FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            FeatureImg.Rotation = -90
            FeatureImg.Size = UDim2.new(1, 6, 1, 6)
            FeatureImg.Name = "FeatureImg"
            FeatureImg.Parent = FeatureFrame

            local alignMap = {
                Left   = Enum.TextXAlignment.Left,
                Center = Enum.TextXAlignment.Center,
                Right  = Enum.TextXAlignment.Right,
            }

            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
            SectionTitle.TextSize = 13
            SectionTitle.TextXAlignment = (type(SectionConfig) == "table" and alignMap[SectionConfig.TextXAlignment]) or Enum.TextXAlignment.Left
            SectionTitle.TextYAlignment = Enum.TextYAlignment.Top
            SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
            SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.BackgroundTransparency = 0.9990000128746033
            SectionTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionTitle.BorderSizePixel = 0
            if Icon and Icon ~= "" then
                SectionTitle.Position = UDim2.new(0, 32, 0.5, 0)
            else
                SectionTitle.Position = UDim2.new(0, 10, 0.5, 0)
            end
            SectionTitle.Size = UDim2.new(1, -50, 0, 13)
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionReal

            SectionDecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionDecideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionDecideFrame.AnchorPoint = Vector2.new(0.5, 0)
            SectionDecideFrame.BorderSizePixel = 0
            SectionDecideFrame.Position = UDim2.new(0.5, 0, 0, 33)
            SectionDecideFrame.Size = UDim2.new(0, 0, 0, 2)
            SectionDecideFrame.Name = "SectionDecideFrame"
            SectionDecideFrame.Parent = Section

            UICorner1.Parent = SectionDecideFrame

            UIGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
                ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
            }
            UIGradient.Parent = SectionDecideFrame

            local SectionAdd    = Instance.new("Frame")
            local UICorner8     = Instance.new("UICorner")
            local UIListLayout2 = Instance.new("UIListLayout")

            SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
            SectionAdd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionAdd.BackgroundTransparency = 0.9990000128746033
            SectionAdd.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionAdd.BorderSizePixel = 0
            SectionAdd.ClipsDescendants = true
            SectionAdd.LayoutOrder = 1
            SectionAdd.Position = UDim2.new(0.5, 0, 0, 38)
            SectionAdd.Size = UDim2.new(1, 0, 0, 100)
            SectionAdd.Name = "SectionAdd"
            SectionAdd.Parent = Section

            UICorner8.CornerRadius = UDim.new(0, 2)
            UICorner8.Parent = SectionAdd

            UIListLayout2.Padding = UDim.new(0, 3)
            UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout2.Parent = SectionAdd

            local OpenSection = Open

            local function UpdateSizeScroll()
                local OffsetY = 0
                for _, child in ScrolLayers:GetChildren() do
                    if child.Name ~= "UIListLayout" then
                        OffsetY = OffsetY + 3 + child.Size.Y.Offset
                    end
                end
                ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
            end

            local function UpdateSizeSection()
                if OpenSection then
                    local SectionSizeYWitdh = 38
                    for _, v in SectionAdd:GetChildren() do
                        if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                            SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
                        end
                    end
                    TweenService:Create(FeatureFrame, TweenInfo.new(0.5), { Rotation = 90 }):Play()
                    TweenService:Create(Section, TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, SectionSizeYWitdh) }):Play()
                    TweenService:Create(SectionAdd, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 38) }):Play()
                    TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0, 2) }):Play()
                    task.wait(0.5)
                    UpdateSizeScroll()
                end
            end

            if OpenSection then UpdateSizeSection() end

            SectionButton.Activated:Connect(function()
                CircleClick(SectionButton, Mouse.X, Mouse.Y)
                if OpenSection then
                    TweenService:Create(FeatureFrame, TweenInfo.new(0.5), { Rotation = 0 }):Play()
                    TweenService:Create(Section, TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, 30) }):Play()
                    TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), { Size = UDim2.new(0, 0, 0, 2) }):Play()
                    OpenSection = false
                    task.wait(0.5)
                    UpdateSizeScroll()
                else
                    OpenSection = true
                    UpdateSizeSection()
                end
            end)

            SectionAdd.ChildAdded:Connect(UpdateSizeSection)
            SectionAdd.ChildRemoved:Connect(UpdateSizeSection)

            local layout = ScrolLayers:FindFirstChildOfClass("UIListLayout")
            if layout then
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
                end)
            end

            local Items = {}
            local CountItem = 0

            function Items:AddParagraph(ParagraphConfig)
                local func = ElementsModule:CreateParagraph(SectionAdd, ParagraphConfig, CountItem)
                CountItem = CountItem + 1
                return func
            end

            function Items:AddPanel(PanelConfig)
                local func = ElementsModule:CreatePanel(SectionAdd, PanelConfig, CountItem)
                CountItem = CountItem + 1
                return func
            end

            function Items:AddButton(ButtonConfig)
                ElementsModule:CreateButton(SectionAdd, ButtonConfig, CountItem)
                CountItem = CountItem + 1
            end

            function Items:AddToggle(ToggleConfig)
                local func = ElementsModule:CreateToggle(SectionAdd, ToggleConfig, CountItem, UpdateSizeSection, Elements)
                CountItem = CountItem + 1
                return func
            end

            function Items:AddSlider(SliderConfig)
                local func = ElementsModule:CreateSlider(SectionAdd, SliderConfig, CountItem, UpdateSizeSection, Elements)
                CountItem = CountItem + 1
                return func
            end

            function Items:AddInput(InputConfig)
                local func = ElementsModule:CreateInput(SectionAdd, InputConfig, CountItem, UpdateSizeSection, Elements)
                CountItem = CountItem + 1
                return func
            end

            function Items:AddDropdown(DropdownConfig)
                local func = ElementsModule:CreateDropdown(SectionAdd, DropdownConfig, CountItem, CountDropdown, DropdownFolder, MoreBlur, DropdownSelect, DropPageLayout, Elements)
                CountItem = CountItem + 1
                CountDropdown = CountDropdown + 1
                return func
            end

            function Items:AddDivider()
                local divider = ElementsModule:CreateDivider(SectionAdd, CountItem)
                CountItem = CountItem + 1
                return divider
            end

            function Items:AddSubSection(title)
                local subsection = ElementsModule:CreateSubSection(SectionAdd, title, CountItem)
                CountItem = CountItem + 1
                return subsection
            end

            function Items:AddKeybind(KeybindConfig)
                local func = KeybindModule:CreateKeybind(SectionAdd, KeybindConfig, CountItem, Elements)
                CountItem = CountItem + 1
                return func
            end

            CountSection = CountSection + 1
            return Items
        end

        CountTab = CountTab + 1
        local safeName = TabConfig.Name:gsub("%s+", "_")
        _G[safeName] = Sections
        return Sections
    end

    return Tabs
end
ConfigModule(
    Nemesis,
    function() return ConfigFolder end,
    function() return CURRENT_VERSION end,
    function() return ConfigData end,
    function() return Elements end,
    LoadConfigElements,
    SaveConfig,
    Nt,
    function() return AUTO_LOAD end
)
NemesisUI = Nemesis
return Nemesis
