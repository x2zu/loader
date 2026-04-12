-- Paragraph.lua
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")  -- Tambahkan ini

local ParagraphModule = {}

local MainColor = Color3.fromRGB(255, 0, 255)

function ParagraphModule.Initialize(color, saveFunc, config)
    MainColor = color or MainColor
end

function ParagraphModule.Create(parent, config, countItem, updateSizeCallback, Icons)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or "Content"
    config.Icon = config.Icon or nil
    config.ButtonText = config.ButtonText or nil
    config.ButtonCallback = config.ButtonCallback or function() end

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
    if config.Icon then
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.Position = UDim2.new(0, 8, 0, 12)
        IconImg.BackgroundTransparency = 1
        IconImg.Name = "ParagraphIcon"
        IconImg.Parent = Paragraph

        if Icons and Icons[config.Icon] then
            IconImg.Image = Icons[config.Icon]
        else
            IconImg.Image = config.Icon
        end

        iconOffset = 30
    end

    ParagraphTitle.Font = Enum.Font.GothamBold
    ParagraphTitle.Text = config.Title
    ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ParagraphTitle.TextSize = 13
    ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTitle.BackgroundTransparency = 1
    ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
    ParagraphTitle.Size = UDim2.new(1, -16, 0, 13)
    ParagraphTitle.Name = "ParagraphTitle"
    ParagraphTitle.Parent = Paragraph

    ParagraphContent.Font = Enum.Font.Gotham
    ParagraphContent.Text = config.Content
    ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ParagraphContent.TextSize = 12
    ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphContent.BackgroundTransparency = 1
    ParagraphContent.Position = UDim2.new(0, iconOffset, 0, 25)
    ParagraphContent.Name = "ParagraphContent"
    ParagraphContent.TextWrapped = true  -- Ubah menjadi true
    ParagraphContent.RichText = true
    ParagraphContent.Parent = Paragraph

    local ParagraphButton
    if config.ButtonText then
        ParagraphButton = Instance.new("TextButton")
        ParagraphButton.Position = UDim2.new(0, 10, 0, 42)
        ParagraphButton.Size = UDim2.new(1, -22, 0, 28)
        ParagraphButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.BackgroundTransparency = 0.935
        ParagraphButton.Font = Enum.Font.GothamBold
        ParagraphButton.TextSize = 12
        ParagraphButton.TextTransparency = 0.3
        ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.Text = config.ButtonText
        ParagraphButton.Parent = Paragraph

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = ParagraphButton

        if config.ButtonCallback then
            ParagraphButton.MouseButton1Click:Connect(config.ButtonCallback)
        end
    end

    -- ============ PERBAIKAN UTAMA ============
    local function CalculateTextHeight()
        -- Hitung lebar yang tersedia untuk teks
        local availableWidth = Paragraph.AbsoluteSize.X - iconOffset - 10
        if availableWidth <= 0 then
            availableWidth = 200 -- fallback
        end
        
        -- Gunakan TextService untuk menghitung tinggi teks yang sebenarnya
        local textSize = TextService:GetTextSize(
            config.Content,
            12,  -- ukuran font
            Enum.Font.Gotham,
            Vector2.new(availableWidth, math.huge)
        )
        
        return textSize.Y
    end

    local function UpdateSize()
        -- Hitung tinggi konten
        local contentHeight = CalculateTextHeight()
        
        -- Hitung total tinggi
        local totalHeight = contentHeight + 33  -- 33 = padding atas (10) + judul (13) + jarak (10)
        
        if ParagraphButton then
            totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 5
        end
        
        -- Set ukuran paragraph
        Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
        
        -- Set ukuran konten
        ParagraphContent.Size = UDim2.new(1, -16, 0, contentHeight)
        
        -- Panggil callback update jika ada
        if updateSizeCallback then 
            updateSizeCallback() 
        end
    end

    -- Panggil UpdateSize setelah GUI selesai dirender
    task.defer(UpdateSize)

    -- Update jika ukuran paragraph berubah (misal parent di-resize)
    Paragraph:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)

    -- Update jika konten berubah
    ParagraphContent:GetPropertyChangedSignal("Text"):Connect(UpdateSize)
    -- ============ AKHIR PERBAIKAN ============

    function ParagraphFunc:SetContent(content)
        content = content or "Content"
        config.Content = content
        ParagraphContent.Text = content
        -- UpdateSize akan dipanggil otomatis melalui event TextChanged
    end

    return ParagraphFunc
end

return ParagraphModule