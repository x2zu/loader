-- // dialog.lua | Velaris UI Dialog Module

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local ActiveDialog = nil

local function Dialog(DialogConfig)
    DialogConfig = DialogConfig or {}
    DialogConfig.Title   = DialogConfig.Title or "Dialog"
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
        ColorSequenceKeypoint.new(0.0,  Color3.fromRGB(0, 191, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0, 140, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.0,  Color3.fromRGB(0, 191, 255))
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

return Dialog
