-- showuser.lua
-- Fungsi untuk membuat dan mengatur bagian user profile di UI

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ==============================================
-- UTILITY FUNCTIONS
-- ==============================================

local function getUserThumbnail(userId, thumbnailType)
    local success, result = pcall(function()
        return Players:GetUserThumbnailAsync(userId, thumbnailType, Enum.ThumbnailSize.Size420x420)
    end)
    
    return success and result or "rbxassetid://0"
end

-- ==============================================
-- UI COMPONENT CREATORS
-- ==============================================

local function createAvatarFrame(parent, size, showStatus)
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Name = "AvatarFrame"
    AvatarFrame.AnchorPoint = Vector2.new(0, 0.5)
    AvatarFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    AvatarFrame.Size = UDim2.new(0, size, 0, size)
    AvatarFrame.Position = UDim2.new(0, 8, 0.5, 0)
    AvatarFrame.Parent = parent
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarFrame
    
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Size = UDim2.new(1, -4, 1, -4)
    AvatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    AvatarImage.Parent = AvatarFrame
    
    if showStatus then
        local StatusIndicator = Instance.new("Frame")
        StatusIndicator.Name = "StatusIndicator"
        StatusIndicator.AnchorPoint = Vector2.new(1, 1)
        StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        StatusIndicator.BorderColor3 = Color3.fromRGB(20, 20, 20)
        StatusIndicator.BorderSizePixel = 2
        StatusIndicator.Size = UDim2.new(0, math.max(6, size/5), 0, math.max(6, size/5))
        StatusIndicator.Position = UDim2.new(1, -2, 1, -2)
        StatusIndicator.Visible = false
        StatusIndicator.Parent = AvatarFrame
        
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(1, 0)
        StatusCorner.Parent = StatusIndicator
        
        return AvatarFrame, AvatarImage, StatusIndicator
    end
    
    return AvatarFrame, AvatarImage
end

local function createUserInfoFrame(parent, offsetX)
    local UserInfoFrame = Instance.new("Frame")
    UserInfoFrame.Name = "UserInfoFrame"
    UserInfoFrame.AnchorPoint = Vector2.new(0, 0.5)
    UserInfoFrame.BackgroundTransparency = 1
    UserInfoFrame.Size = UDim2.new(1, -offsetX, 0, 32)
    UserInfoFrame.Position = UDim2.new(0, offsetX, 0.5, 0)
    UserInfoFrame.Parent = parent
    
    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Name = "DisplayNameLabel"
    DisplayNameLabel.Font = Enum.Font.GothamBold
    DisplayNameLabel.Text = "Loading..."
    DisplayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DisplayNameLabel.TextSize = 12
    DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayNameLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    DisplayNameLabel.Position = UDim2.new(0, 0, 0, 0)
    DisplayNameLabel.Parent = UserInfoFrame
    
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.Text = "@username"
    UsernameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    UsernameLabel.TextSize = 10
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextYAlignment = Enum.TextYAlignment.Top
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    UsernameLabel.Position = UDim2.new(0, 0, 0.6, 0)
    UsernameLabel.Parent = UserInfoFrame
    
    return UserInfoFrame, DisplayNameLabel, UsernameLabel
end

local function createStatsContainer(parent, offsetX)
    local StatsContainer = Instance.new("Frame")
    StatsContainer.Name = "StatsContainer"
    StatsContainer.AnchorPoint = Vector2.new(0, 0.5)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.Visible = false
    StatsContainer.Size = UDim2.new(1, -offsetX, 0, 16)
    StatsContainer.Position = UDim2.new(0, offsetX, 0.5, 8)
    StatsContainer.Parent = parent
    
    return StatsContainer
end

-- ==============================================
-- STATS MANAGEMENT
-- ==============================================

local function createStatDisplay(stat, container, color)
    local StatFrame = Instance.new("Frame")
    StatFrame.BackgroundTransparency = 1
    StatFrame.Size = UDim2.new(0, 0, 1, 0)
    StatFrame.LayoutOrder = #container:GetChildren()
    StatFrame.Parent = container
    
    local StatName = Instance.new("TextLabel")
    StatName.Font = Enum.Font.Gotham
    StatName.Text = stat.Name .. ": "
    StatName.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatName.TextSize = 9
    StatName.TextXAlignment = Enum.TextXAlignment.Left
    StatName.BackgroundTransparency = 1
    StatName.Size = UDim2.new(0, 0, 1, 0)
    StatName.Parent = StatFrame
    
    local StatValue = Instance.new("TextLabel")
    StatValue.Font = Enum.Font.GothamBold
    StatValue.Text = tostring(stat.Value)
    StatValue.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    StatValue.TextSize = 9
    StatValue.TextXAlignment = Enum.TextXAlignment.Left
    StatValue.BackgroundTransparency = 1
    StatValue.Size = UDim2.new(0, 0, 1, 0)
    StatValue.Position = UDim2.new(0, StatName.TextBounds.X, 0, 0)
    StatValue.Parent = StatFrame
    
    local function updateSize()
        StatFrame.Size = UDim2.new(0, StatName.TextBounds.X + StatValue.TextBounds.X, 1, 0)
    end
    
    updateSize()
    
    stat.Changed:Connect(function()
        StatValue.Text = tostring(stat.Value)
        updateSize()
    end)
    
    return StatFrame
end

local function updatePlayerStats(localPlayer, statsContainer, color)
    if not localPlayer:FindFirstChild("leaderstats") then return end
    
    -- Clear existing stats
    for _, child in pairs(statsContainer:GetChildren()) do
        if child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    -- Add layout if not exists
    if not statsContainer:FindFirstChild("UIListLayout") then
        local StatsLayout = Instance.new("UIListLayout")
        StatsLayout.FillDirection = Enum.FillDirection.Horizontal
        StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        StatsLayout.Padding = UDim.new(0, 5)
        StatsLayout.Parent = statsContainer
    end
    
    -- Create stat displays
    for _, stat in pairs(localPlayer.leaderstats:GetChildren()) do
        if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
            createStatDisplay(stat, statsContainer, color)
        end
    end
    
    statsContainer.Visible = true
end

-- ==============================================
-- USER PROFILE FUNCTIONS
-- ==============================================

local function createUserProfile(parentFrame, showUser, uitransparent, color)
    if not showUser then return nil end
    
    -- Create main container
    local UserProfileContainer = Instance.new("Frame")
    UserProfileContainer.Name = "UserProfileContainer"
    UserProfileContainer.BackgroundTransparency = 1
    UserProfileContainer.BorderSizePixel = 0
    UserProfileContainer.Size = UDim2.new(1, 0, 1, -5)
    UserProfileContainer.Position = UDim2.new(0, 0, 0, 5)
    UserProfileContainer.Parent = parentFrame
    
    -- Create UI components
    local AvatarFrame, AvatarImage, StatusIndicator = createAvatarFrame(UserProfileContainer, 32, true)
    local UserInfoFrame, DisplayNameLabel, UsernameLabel = createUserInfoFrame(UserProfileContainer, 48)
    local StatsContainer = createStatsContainer(UserProfileContainer, 48)
    
    -- User data management
    local function updateUserData()
        local localPlayer = Players.LocalPlayer
        if not localPlayer then return end
        
        local userId = localPlayer.UserId
        
        -- Update basic info
        DisplayNameLabel.Text = localPlayer.DisplayName
        UsernameLabel.Text = "@" .. localPlayer.Name
        
        -- Update avatar
        local avatarUrl = getUserThumbnail(userId, Enum.ThumbnailType.HeadShot)
        AvatarImage.Image = avatarUrl
        
        -- Update status
        if StatusIndicator then
            local function updateFriendshipStatus()
                local friendStatus = localPlayer:GetFriendStatus(localPlayer)
                StatusIndicator.Visible = true
                
                if friendStatus == Enum.FriendStatus.Friend then
                    StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                elseif friendStatus == Enum.FriendStatus.NotFriend then
                    StatusIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
                else
                    StatusIndicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            
            pcall(updateFriendshipStatus)
        end
        
        -- Update stats
        updatePlayerStats(localPlayer, StatsContainer, color)
        
        -- Adjust layout based on stats visibility
        if StatsContainer.Visible then
            UserInfoFrame.Size = UDim2.new(1, -48, 0, 20)
            UserInfoFrame.Position = UDim2.new(0, 48, 0.5, -4)
        else
            UserInfoFrame.Size = UDim2.new(1, -48, 0, 32)
            UserInfoFrame.Position = UDim2.new(0, 48, 0.5, 0)
        end
    end
    
    -- Initialize user data
    spawn(updateUserData)
    
    -- Player leaving handler
    Players.PlayerRemoving:Connect(function(player)
        if player == Players.LocalPlayer then
            DisplayNameLabel.Text = "Player Left"
            UsernameLabel.Text = "@disconnected"
            AvatarImage.Image = "rbxassetid://0"
            if StatusIndicator then
                StatusIndicator.Visible = false
            end
        end
    end)
    
    -- Control functions
    local function refreshUserData()
        updateUserData()
    end
    
    local function setAvatarSize(size)
        if size and size > 0 then
            AvatarFrame.Size = UDim2.new(0, size, 0, size)
            AvatarImage.Size = UDim2.new(1, -4, 1, -4)
            
            if StatusIndicator then
                StatusIndicator.Size = UDim2.new(0, math.max(6, size/5), 0, math.max(6, size/5))
                StatusIndicator.Position = UDim2.new(1, -2, 1, -2)
            end
            
            local offsetX = size + 16
            UserInfoFrame.Position = UDim2.new(0, offsetX, 0.5, 0)
            UserInfoFrame.Size = UDim2.new(1, -offsetX, 0, 32)
            StatsContainer.Position = UDim2.new(0, offsetX, 0.5, 8)
            StatsContainer.Size = UDim2.new(1, -offsetX, 0, 16)
        end
    end
    
    local function toggleStats(visible)
        StatsContainer.Visible = visible
        if visible then
            UserInfoFrame.Size = UDim2.new(1, -48, 0, 20)
            UserInfoFrame.Position = UDim2.new(0, 48, 0.5, -4)
        else
            UserInfoFrame.Size = UDim2.new(1, -48, 0, 32)
            UserInfoFrame.Position = UDim2.new(0, 48, 0.5, 0)
        end
    end
    
    local function setStatusColor(color3)
        if StatusIndicator and color3 then
            StatusIndicator.BackgroundColor3 = color3
        end
    end
    
    return {
        Refresh = refreshUserData,
        SetAvatarSize = setAvatarSize,
        ToggleStats = toggleStats,
        SetStatusColor = setStatusColor,
        Container = UserProfileContainer,
        Avatar = AvatarImage,
        DisplayName = DisplayNameLabel,
        Username = UsernameLabel
    }
end

-- ==============================================
-- SIMPLE USER PROFILE
-- ==============================================

local function createSimpleUserProfile(parentFrame, showUser, uitransparent, color)
    if not showUser then return nil end
    
    local UserProfileContainer = Instance.new("Frame")
    UserProfileContainer.Name = "UserProfileContainer"
    UserProfileContainer.BackgroundTransparency = 1
    UserProfileContainer.BorderSizePixel = 0
    UserProfileContainer.Size = UDim2.new(1, 0, 1, -10)
    UserProfileContainer.Position = UDim2.new(0, 0, 0, 5)
    UserProfileContainer.Parent = parentFrame
    
    local AvatarFrame, AvatarImage = createAvatarFrame(UserProfileContainer, 30, false)
    AvatarFrame.Position = UDim2.new(0, 5, 0.5, 0)
    
    local UserInfoFrame = Instance.new("Frame")
    UserInfoFrame.Name = "UserInfoFrame"
    UserInfoFrame.AnchorPoint = Vector2.new(0, 0.5)
    UserInfoFrame.BackgroundTransparency = 1
    UserInfoFrame.Size = UDim2.new(1, -40, 0, 30)
    UserInfoFrame.Position = UDim2.new(0, 40, 0.5, 0)
    UserInfoFrame.Parent = UserProfileContainer
    
    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Name = "DisplayNameLabel"
    DisplayNameLabel.Font = Enum.Font.GothamBold
    DisplayNameLabel.Text = "Loading..."
    DisplayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DisplayNameLabel.TextSize = 12
    DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayNameLabel.TextYAlignment = Enum.TextYAlignment.Center
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    DisplayNameLabel.Position = UDim2.new(0, 0, 0, 0)
    DisplayNameLabel.Parent = UserInfoFrame
    
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.Text = "@username"
    UsernameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    UsernameLabel.TextSize = 10
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextYAlignment = Enum.TextYAlignment.Center
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    UsernameLabel.Position = UDim2.new(0, 0, 0.6, 0)
    UsernameLabel.Parent = UserInfoFrame
    
    spawn(function()
        local localPlayer = Players.LocalPlayer
        if not localPlayer then return end
        
        local userId = localPlayer.UserId
        
        DisplayNameLabel.Text = localPlayer.DisplayName
        UsernameLabel.Text = "@" .. localPlayer.Name
        
        local avatarUrl = getUserThumbnail(userId, Enum.ThumbnailType.HeadShot)
        AvatarImage.Image = avatarUrl
    end)
    
    return {
        Container = UserProfileContainer,
        Avatar = AvatarImage,
        DisplayName = DisplayNameLabel,
        Username = UsernameLabel
    }
end

-- ==============================================
-- MODULE EXPORTS
-- ==============================================

return {
    CreateUserProfile = createUserProfile,
    CreateSimpleUserProfile = createSimpleUserProfile,
    GetUserThumbnail = getUserThumbnail
}
