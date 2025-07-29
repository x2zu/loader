local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- Blur efek awal
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

-- ScreenGui loader
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "StellarLoader"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1

local bg = Instance.new("Frame", frame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
bg.BackgroundTransparency = 1
bg.ZIndex = 0
TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()

-- Animasi kata STELLAR
local word = "STELLAR"
local letters = {}

local function tweenOutAndDestroy()
	for _, label in ipairs(letters) do
		TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
	end
	TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()

	-- Fade out blur agar tidak permanen
	TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()

	wait(0.6)
	screenGui:Destroy()
	blur:Destroy()
end

for i = 1, #word do
	local char = word:sub(i, i)

	local label = Instance.new("TextLabel")
	label.Text = char
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 1 
	label.TextTransparency = 1
	label.TextScaled = false
	label.TextSize = 30 
	label.Size = UDim2.new(0, 60, 0, 60)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 65, 0.5, 0)
	label.BackgroundTransparency = 1
	label.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 160))
	})
	gradient.Rotation = 90
	gradient.Parent = label

	local tweenIn = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60})
	tweenIn:Play()

	table.insert(letters, label)
	wait(0.25)
end

wait(2)
tweenOutAndDestroy()

-- GUI Modern Join Discord
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "DiscordJoinUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 320, 0, 160)
container.Position = UDim2.new(0.5, -160, 0.5, -80)
container.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
container.BorderSizePixel = 0
container.BackgroundTransparency = 0
container.ClipsDescendants = true

-- Rounded corners
local uicorner = Instance.new("UICorner", container)
uicorner.CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel", container)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "Join Our Discord"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.GothamBold

-- Tombol Join
local joinButton = Instance.new("TextButton", container)
joinButton.Size = UDim2.new(0, 220, 0, 40)
joinButton.Position = UDim2.new(0.5, -110, 1, -60)
joinButton.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
joinButton.Text = "Join discord.gg/x2zu"
joinButton.TextColor3 = Color3.new(1,1,1)
joinButton.Font = Enum.Font.GothamMedium
joinButton.TextSize = 18

local cornerBtn = Instance.new("UICorner", joinButton)
cornerBtn.CornerRadius = UDim.new(0, 8)

-- Hover efek
joinButton.MouseEnter:Connect(function()
	TweenService:Create(joinButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 140, 255)}):Play()
end)
joinButton.MouseLeave:Connect(function()
	TweenService:Create(joinButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 120, 255)}):Play()
end)

-- Aksi join
joinButton.MouseButton1Click:Connect(function()
	setclipboard("https://discord.gg/x2zu")
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Copied!",
		Text = "Discord link copied to clipboard.",
		Duration = 3
	})
end)

-- Fungsi drag
local UIS = game:GetService("UserInputService")
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	container.Position = UDim2.new(
		startPos.X.Scale, startPos.X.Offset + delta.X,
		startPos.Y.Scale, startPos.Y.Offset + delta.Y
	)
end

container.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = container.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

container.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)
