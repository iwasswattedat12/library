local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function getGuiParent(): Instance
    local success, hui = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return nil
    end)
    if success and hui then return hui end

    local successCore, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if successCore and coreGui then
        local test = pcall(function() return coreGui.Name end)
        if test then return coreGui end
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local Themes = {
    Default = {
        Accent = Color3.fromRGB(32, 201, 151),
        AccentHover = Color3.fromRGB(46, 222, 169),
        AccentDark = Color3.fromRGB(18, 140, 103),
    },
    Emerald = {
        Accent = Color3.fromRGB(16, 185, 129),
        AccentHover = Color3.fromRGB(52, 211, 153),
        AccentDark = Color3.fromRGB(5, 150, 105),
    },
    Ocean = {
        Accent = Color3.fromRGB(0, 180, 216),
        AccentHover = Color3.fromRGB(72, 202, 228),
        AccentDark = Color3.fromRGB(0, 119, 182),
    },
    Amethyst = {
        Accent = Color3.fromRGB(139, 92, 246),
        AccentHover = Color3.fromRGB(167, 139, 250),
        AccentDark = Color3.fromRGB(124, 58, 237),
    },
    Ruby = {
        Accent = Color3.fromRGB(244, 63, 94),
        AccentHover = Color3.fromRGB(251, 113, 133),
        AccentDark = Color3.fromRGB(225, 29, 72),
    },
    Midnight = {
        Accent = Color3.fromRGB(59, 130, 246),
        AccentHover = Color3.fromRGB(96, 165, 250),
        AccentDark = Color3.fromRGB(37, 99, 235),
    }
}

local Palette = {
    WindowBg = Color3.fromRGB(20, 20, 22),
    WindowBorder = Color3.fromRGB(32, 32, 36),
    SidebarBg = Color3.fromRGB(16, 16, 18),
    SidebarBorder = Color3.fromRGB(28, 28, 32),
    HeaderBg = Color3.fromRGB(18, 18, 20),
    HeaderBorder = Color3.fromRGB(30, 30, 34),
    ElementBg = Color3.fromRGB(24, 24, 28),
    ElementHover = Color3.fromRGB(32, 32, 38),
    ElementActive = Color3.fromRGB(28, 38, 34),
    InputBg = Color3.fromRGB(14, 14, 16),
    InputBorder = Color3.fromRGB(36, 36, 42),
    TextPrimary = Color3.fromRGB(245, 245, 245),
    TextSecondary = Color3.fromRGB(170, 170, 180),
    TextMuted = Color3.fromRGB(110, 110, 120),
}

local function tween(instance: Instance, duration: number, properties: { [string]: any }, style: Enum.EasingStyle?, direction: Enum.EasingDirection?)
    style = style or Enum.EasingStyle.Cubic
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, direction)
    local anim = TweenService:Create(instance, info, properties)
    anim:Play()
    return anim
end

local function makeDraggable(frame: Frame, dragHandle: GuiObject?)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local HoodUI = {
    Flags = {},
    Windows = {},
    CurrentTheme = "Default",
    Accent = Themes.Default.Accent,
    AccentHover = Themes.Default.AccentHover,
    ScreenGui = nil :: ScreenGui?,
    DarkenOverlay = nil :: Frame?,
    ParticleContainer = nil :: Frame?,
    NotifyContainer = nil :: Frame?,
    IsGuiOpen = true,
    Bullets = {},
    BulletConn = nil :: RBXScriptConnection?,
}

local ASSET_URLS = {
    "rbxthumb://type=Asset&id=123190078434353&w=420&h=420",
    "http://www.roblox.com/asset/?id=123190078434353",
    "rbxassetid://123190078434353"
}

local function startBullets()
    if HoodUI.BulletConn then return end
    if not HoodUI.ParticleContainer then return end

    local viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    local screenW = viewport.X
    local screenH = viewport.Y

    local bulletCount = 8
    HoodUI.Bullets = {}

    for i = 1, bulletCount do
        local img = Instance.new("ImageLabel")
        img.Name = "Bullet_" .. tostring(i)
        img.Image = ASSET_URLS[1]
        img.BackgroundTransparency = 1
        img.BorderSizePixel = 0
        img.ScaleType = Enum.ScaleType.Fit
        img.Active = false
        img.Selectable = false
        img.ZIndex = 3

        local size = math.random(75, 120)
        img.Size = UDim2.new(0, size, 0, size)

        local initialX = math.random(-150, math.floor(screenW))
        local initialY = math.random(40, math.max(60, math.floor(screenH - 120)))
        img.Position = UDim2.new(0, initialX, 0, initialY)
        img.Rotation = math.random(-15, 15)
        img.Parent = HoodUI.ParticleContainer

        local speed = math.random(220, 440)

        table.insert(HoodUI.Bullets, {
            Object = img,
            X = initialX,
            Y = initialY,
            Speed = speed,
            Size = size,
        })
    end

    HoodUI.BulletConn = RunService.RenderStepped:Connect(function(dt)
        if not HoodUI.IsGuiOpen then return end
        local vp = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
        local curW = vp.X
        local curH = vp.Y

        for _, b in ipairs(HoodUI.Bullets) do
            b.X = b.X + (b.Speed * dt)
            if b.X > curW + 120 then
                b.X = -math.random(100, 180)
                b.Y = math.random(40, math.max(60, math.floor(curH - 120)))
                b.Speed = math.random(220, 440)
            end
            b.Object.Position = UDim2.new(0, math.floor(b.X), 0, math.floor(b.Y))
        end
    end)
end

local function stopBullets()
    if HoodUI.BulletConn then
        HoodUI.BulletConn:Disconnect()
        HoodUI.BulletConn = nil
    end
    for _, b in ipairs(HoodUI.Bullets) do
        if b.Object and b.Object.Parent then
            b.Object:Destroy()
        end
    end
    HoodUI.Bullets = {}
end

local function ensureScreenGui()
    if HoodUI.ScreenGui and HoodUI.ScreenGui.Parent then return HoodUI.ScreenGui end

    local existing = getGuiParent():FindFirstChild("HoodUI_Interface")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "HoodUI_Interface"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 9999
    sg.Parent = getGuiParent()

    local overlay = Instance.new("Frame")
    overlay.Name = "DarkenOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.22
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 1
    overlay.Parent = sg

    local partContainer = Instance.new("Frame")
    partContainer.Name = "ParticleContainer"
    partContainer.Size = UDim2.new(1, 0, 1, 0)
    partContainer.Position = UDim2.new(0, 0, 0, 0)
    partContainer.BackgroundTransparency = 1
    partContainer.BorderSizePixel = 0
    partContainer.ZIndex = 2
    partContainer.ClipsDescendants = false
    partContainer.Parent = sg

    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "Notifications"
    notifFrame.Size = UDim2.new(0, 310, 1, -40)
    notifFrame.Position = UDim2.new(1, -320, 0, 20)
    notifFrame.BackgroundTransparency = 1
    notifFrame.BorderSizePixel = 0
    notifFrame.ZIndex = 100
    notifFrame.Parent = sg

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = notifFrame

    HoodUI.ScreenGui = sg
    HoodUI.DarkenOverlay = overlay
    HoodUI.ParticleContainer = partContainer
    HoodUI.NotifyContainer = notifFrame

    startBullets()

    return sg
end

function HoodUI:SetTheme(themeName: string)
    local preset = Themes[themeName] or Themes.Default
    self.CurrentTheme = themeName
    self.Accent = preset.Accent
    self.AccentHover = preset.AccentHover
end

function HoodUI:SetGuiOpen(isOpen: boolean)
    self.IsGuiOpen = isOpen
    ensureScreenGui()

    if isOpen then
        self.DarkenOverlay.Visible = true
        tween(self.DarkenOverlay, 0.25, { BackgroundTransparency = 0.22 })
        startBullets()
    else
        stopBullets()
        local t = tween(self.DarkenOverlay, 0.25, { BackgroundTransparency = 1 })
        t.Completed:Connect(function()
            if not self.IsGuiOpen then
                self.DarkenOverlay.Visible = false
            end
        end)
    end

    for _, win in ipairs(self.Windows) do
        win:SetVisible(isOpen)
    end
end

function HoodUI:ToggleGui()
    self:SetGuiOpen(not self.IsGuiOpen)
end

function HoodUI:Notify(options: { Title: string?, Content: string?, Duration: number?, Image: string? })
    ensureScreenGui()
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 4

    local card = Instance.new("Frame")
    card.Name = "NotifCard"
    card.Size = UDim2.new(1, 0, 0, 72)
    card.Position = UDim2.new(1, 40, 0, 0)
    card.BackgroundColor3 = Palette.ElementBg
    card.BorderSizePixel = 0
    card.BackgroundTransparency = 0.05
    card.ZIndex = 101
    card.Parent = HoodUI.NotifyContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Palette.ElementBorder
    stroke.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 12, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Palette.TextPrimary
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 102
    titleLabel.Parent = card

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -24, 0, 32)
    contentLabel.Position = UDim2.new(0, 12, 0, 28)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Palette.TextSecondary
    contentLabel.TextSize = 12
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.ZIndex = 102
    contentLabel.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -8, 0, 3)
    bar.Position = UDim2.new(0, 4, 1, -5)
    bar.BackgroundColor3 = HoodUI.Accent
    bar.BorderSizePixel = 0
    bar.ZIndex = 102
    bar.Parent = card

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = bar

    card.Position = UDim2.new(1, 100, 0, 0)
    tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) })
    tween(bar, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if card and card.Parent then
            local exit = tween(card, 0.3, { Position = UDim2.new(1, 100, 0, 0), BackgroundTransparency = 1 })
            exit.Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

function HoodUI:CreateWindow(options: { Name: string?, LoadingSubtitle: string?, ToggleKey: Enum.KeyCode?, Theme: string?, Width: number?, Height: number? })
    ensureScreenGui()
    options = options or {}

    if options.Theme then
        self:SetTheme(options.Theme)
    end

    local toggleKeyCode = options.ToggleKey or Enum.KeyCode.RightControl
    local navWidth = 190
    local navHeight = options.Height or 480

    local navFrame = Instance.new("Frame")
    navFrame.Name = "HoodUINav"
    navFrame.Size = UDim2.new(0, navWidth, 0, navHeight)
    navFrame.Position = UDim2.new(0, 60, 0.5, -navHeight / 2)
    navFrame.BackgroundColor3 = Palette.SidebarBg
    navFrame.BorderSizePixel = 0
    navFrame.ZIndex = 10
    navFrame.Parent = HoodUI.ScreenGui

    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = UDim.new(0, 8)
    navCorner.Parent = navFrame

    local navStroke = Instance.new("UIStroke")
    navStroke.Thickness = 1
    navStroke.Color = Palette.SidebarBorder
    navStroke.Parent = navFrame

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 52)
    header.BackgroundColor3 = Palette.HeaderBg
    header.BorderSizePixel = 0
    header.ZIndex = 11
    header.Parent = navFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header

    local titleRow = Instance.new("Frame")
    titleRow.Size = UDim2.new(1, -20, 0, 26)
    titleRow.Position = UDim2.new(0, 14, 0, 13)
    titleRow.BackgroundTransparency = 1
    titleRow.ZIndex = 12
    titleRow.Parent = header

    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(0, 68, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = (options.Name or "HOOD"):upper()
    logoText.TextColor3 = Palette.TextPrimary
    logoText.TextSize = 18
    logoText.Font = Enum.Font.GothamBlack
    logoText.TextXAlignment = Enum.TextXAlignment.Left
    logoText.ZIndex = 12
    logoText.Parent = titleRow

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 32, 0, 18)
    badge.Position = UDim2.new(0, 72, 0.5, -9)
    badge.BackgroundColor3 = HoodUI.Accent
    badge.Text = "V4"
    badge.TextColor3 = Color3.fromRGB(15, 15, 18)
    badge.TextSize = 11
    badge.Font = Enum.Font.GothamBold
    badge.ZIndex = 13
    badge.Parent = titleRow

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 4)
    badgeCorner.Parent = badge

    local gearBtn = Instance.new("TextButton")
    gearBtn.Size = UDim2.new(0, 24, 0, 24)
    gearBtn.Position = UDim2.new(1, -24, 0.5, -12)
    gearBtn.BackgroundTransparency = 1
    gearBtn.Text = "⚙"
    gearBtn.TextColor3 = Palette.TextMuted
    gearBtn.TextSize = 16
    gearBtn.Font = Enum.Font.GothamBold
    gearBtn.ZIndex = 13
    gearBtn.Parent = titleRow

    makeDraggable(navFrame, header)

    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "CategoryList"
    tabList.Size = UDim2.new(1, -12, 1, -64)
    tabList.Position = UDim2.new(0, 6, 0, 58)
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel = 0
    tabList.ScrollBarThickness = 2
    tabList.ScrollBarImageColor3 = Palette.SidebarBorder
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.ZIndex = 11
    tabList.Parent = navFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabList

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKeyCode then
            HoodUI:ToggleGui()
        end
    end)

    local WindowObj = {
        Frame = navFrame,
        Tabs = {},
        TabSpawnCount = 0,
    }

    function WindowObj:SetVisible(visible: boolean)
        navFrame.Visible = visible
        for _, tab in ipairs(self.Tabs) do
            if tab.IsOpen then
                tab.Window.Visible = visible
            else
                tab.Window.Visible = false
            end
        end
    end

    function WindowObj:CreateTab(tabName: string, iconId: string?)
        local tabWinWidth = 260
        local tabWinHeight = 440

        local offsetX = (navFrame.Position.X.Offset + navWidth + 16) + (WindowObj.TabSpawnCount * 272)
        local offsetY = navFrame.Position.Y.Offset
        WindowObj.TabSpawnCount = WindowObj.TabSpawnCount + 1

        local tabWin = Instance.new("Frame")
        tabWin.Name = tabName .. "_VapeWindow"
        tabWin.Size = UDim2.new(0, tabWinWidth, 0, tabWinHeight)
        tabWin.Position = UDim2.new(navFrame.Position.X.Scale, offsetX, navFrame.Position.Y.Scale, offsetY)
        tabWin.BackgroundColor3 = Palette.WindowBg
        tabWin.BorderSizePixel = 0
        tabWin.ZIndex = 15
        tabWin.Visible = false
        tabWin.Parent = HoodUI.ScreenGui

        local tabWinCorner = Instance.new("UICorner")
        tabWinCorner.CornerRadius = UDim.new(0, 8)
        tabWinCorner.Parent = tabWin

        local tabWinStroke = Instance.new("UIStroke")
        tabWinStroke.Thickness = 1
        tabWinStroke.Color = Palette.WindowBorder
        tabWinStroke.Parent = tabWin

        local tabHeader = Instance.new("Frame")
        tabHeader.Name = "Header"
        tabHeader.Size = UDim2.new(1, 0, 0, 42)
        tabHeader.BackgroundColor3 = Palette.HeaderBg
        tabHeader.BorderSizePixel = 0
        tabHeader.ZIndex = 16
        tabHeader.Parent = tabWin

        local tabHeaderCorner = Instance.new("UICorner")
        tabHeaderCorner.CornerRadius = UDim.new(0, 8)
        tabHeaderCorner.Parent = tabHeader

        local tabHeaderStroke = Instance.new("UIStroke")
        tabHeaderStroke.Thickness = 1
        tabHeaderStroke.Color = Palette.HeaderBorder
        tabHeaderStroke.Parent = tabHeader

        local tabTitle = Instance.new("TextLabel")
        tabTitle.Size = UDim2.new(1, -60, 1, 0)
        tabTitle.Position = UDim2.new(0, 14, 0, 0)
        tabTitle.BackgroundTransparency = 1
        tabTitle.Text = tabName
        tabTitle.TextColor3 = Palette.TextPrimary
        tabTitle.TextSize = 14
        tabTitle.Font = Enum.Font.GothamBold
        tabTitle.TextXAlignment = Enum.TextXAlignment.Left
        tabTitle.ZIndex = 17
        tabTitle.Parent = tabHeader

        local tabCollapseBtn = Instance.new("TextButton")
        tabCollapseBtn.Size = UDim2.new(0, 24, 0, 24)
        tabCollapseBtn.Position = UDim2.new(1, -30, 0.5, -12)
        tabCollapseBtn.BackgroundTransparency = 1
        tabCollapseBtn.Text = "✕"
        tabCollapseBtn.TextColor3 = Palette.TextMuted
        tabCollapseBtn.TextSize = 13
        tabCollapseBtn.Font = Enum.Font.GothamBold
        tabCollapseBtn.ZIndex = 17
        tabCollapseBtn.Parent = tabHeader

        makeDraggable(tabWin, tabHeader)

        local page = Instance.new("ScrollingFrame")
        page.Name = "ModulesList"
        page.Size = UDim2.new(1, -12, 1, -50)
        page.Position = UDim2.new(0, 6, 0, 46)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = HoodUI.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ZIndex = 16
        page.Parent = tabWin

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 4)
        pageLayout.Parent = page

        local navBtn = Instance.new("TextButton")
        navBtn.Name = tabName .. "_CategoryBtn"
        navBtn.Size = UDim2.new(1, 0, 0, 38)
        navBtn.BackgroundColor3 = Palette.SidebarBg
        navBtn.BorderSizePixel = 0
        navBtn.Text = ""
        navBtn.AutoButtonColor = false
        navBtn.ZIndex = 12
        navBtn.Parent = tabList

        local navBtnCorner = Instance.new("UICorner")
        navBtnCorner.CornerRadius = UDim.new(0, 6)
        navBtnCorner.Parent = navBtn

        local navLabel = Instance.new("TextLabel")
        navLabel.Size = UDim2.new(1, -40, 1, 0)
        navLabel.Position = UDim2.new(0, 14, 0, 0)
        navLabel.BackgroundTransparency = 1
        navLabel.Text = tabName
        navLabel.TextColor3 = Palette.TextSecondary
        navLabel.TextSize = 13
        navLabel.Font = Enum.Font.Gotham
        navLabel.TextXAlignment = Enum.TextXAlignment.Left
        navLabel.ZIndex = 13
        navLabel.Parent = navBtn

        local navArrow = Instance.new("TextLabel")
        navArrow.Size = UDim2.new(0, 20, 1, 0)
        navArrow.Position = UDim2.new(1, -24, 0, 0)
        navArrow.BackgroundTransparency = 1
        navArrow.Text = ">"
        navArrow.TextColor3 = Palette.TextMuted
        navArrow.TextSize = 12
        navArrow.Font = Enum.Font.GothamBold
        navArrow.ZIndex = 13
        navArrow.Parent = navBtn

        local TabObj = {
            Name = tabName,
            Window = tabWin,
            Page = page,
            Button = navBtn,
            Label = navLabel,
            Arrow = navArrow,
            IsOpen = false,
        }

        local function setTabOpen(open: boolean)
            TabObj.IsOpen = open
            if open then
                tabWin.Visible = true
                navLabel.TextColor3 = HoodUI.Accent
                navArrow.TextColor3 = HoodUI.Accent
                navBtn.BackgroundColor3 = Palette.ElementBg
                tabWin.Size = UDim2.new(0, tabWinWidth * 0.95, 0, tabWinHeight * 0.95)
                tween(tabWin, 0.18, { Size = UDim2.new(0, tabWinWidth, 0, tabWinHeight) })
            else
                tabWin.Visible = false
                navLabel.TextColor3 = Palette.TextSecondary
                navArrow.TextColor3 = Palette.TextMuted
                navBtn.BackgroundColor3 = Palette.SidebarBg
            end
        end

        navBtn.MouseButton1Click:Connect(function()
            setTabOpen(not TabObj.IsOpen)
        end)

        tabCollapseBtn.MouseButton1Click:Connect(function()
            setTabOpen(false)
        end)

        if #WindowObj.Tabs == 0 then
            setTabOpen(true)
        end

        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:CreateSection(name: string)
            local sec = Instance.new("Frame")
            sec.Name = "Section"
            sec.Size = UDim2.new(1, 0, 0, 22)
            sec.BackgroundTransparency = 1
            sec.ZIndex = 16
            sec.Parent = page

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(1, -10, 1, 0)
            title.Position = UDim2.new(0, 6, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = name:upper()
            title.TextColor3 = Palette.TextMuted
            title.TextSize = 10
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = sec

            return sec
        end

        function TabObj:CreateToggle(options: { Name: string, CurrentValue: boolean?, Flag: string?, Callback: (boolean) -> () })
            local state = options.CurrentValue or false
            if options.Flag then HoodUI.Flags[options.Flag] = state end

            local modCard = Instance.new("Frame")
            modCard.Name = options.Name .. "_Module"
            modCard.Size = UDim2.new(1, 0, 0, 36)
            modCard.BackgroundColor3 = state and Palette.ElementActive or Palette.ElementBg
            modCard.BorderSizePixel = 0
            modCard.ZIndex = 16
            modCard.Parent = page

            local modCorner = Instance.new("UICorner")
            modCorner.CornerRadius = UDim.new(0, 6)
            modCorner.Parent = modCard

            local modStroke = Instance.new("UIStroke")
            modStroke.Thickness = 1
            modStroke.Color = state and HoodUI.Accent or Palette.ElementBorder
            modStroke.Parent = modCard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -40, 0, 36)
            nameLabel.Position = UDim2.new(0, 12, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = state and HoodUI.Accent or Palette.TextSecondary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 17
            nameLabel.Parent = modCard

            local dotIndicator = Instance.new("Frame")
            dotIndicator.Size = UDim2.new(0, 6, 0, 6)
            dotIndicator.Position = UDim2.new(1, -20, 0.5, -3)
            dotIndicator.BackgroundColor3 = state and HoodUI.Accent or Palette.TextMuted
            dotIndicator.BorderSizePixel = 0
            dotIndicator.ZIndex = 17
            dotIndicator.Parent = modCard

            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dotIndicator

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 0, 36)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 18
            hit.Parent = modCard

            local function setToggle(newVal: boolean)
                state = newVal
                if options.Flag then HoodUI.Flags[options.Flag] = state end

                nameLabel.TextColor3 = state and HoodUI.Accent or Palette.TextSecondary
                dotIndicator.BackgroundColor3 = state and HoodUI.Accent or Palette.TextMuted
                modCard.BackgroundColor3 = state and Palette.ElementActive or Palette.ElementBg
                modStroke.Color = state and HoodUI.Accent or Palette.ElementBorder

                if options.Callback then
                    pcall(options.Callback, state)
                end
            end

            hit.MouseButton1Click:Connect(function()
                setToggle(not state)
            end)

            return {
                Frame = modCard,
                Set = setToggle
            }
        end

        function TabObj:CreateButton(options: { Name: string, Description: string?, Callback: () -> () })
            local btnCard = Instance.new("Frame")
            btnCard.Name = options.Name .. "_Btn"
            btnCard.Size = UDim2.new(1, 0, 0, 36)
            btnCard.BackgroundColor3 = Palette.ElementBg
            btnCard.BorderSizePixel = 0
            btnCard.ZIndex = 16
            btnCard.Parent = page

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btnCard

            local btnStroke = Instance.new("UIStroke")
            btnStroke.Thickness = 1
            btnStroke.Color = Palette.ElementBorder
            btnStroke.Parent = btnCard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -30, 1, 0)
            nameLabel.Position = UDim2.new(0, 12, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextPrimary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 17
            nameLabel.Parent = btnCard

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 18
            hit.Parent = btnCard

            hit.MouseEnter:Connect(function()
                tween(btnCard, 0.15, { BackgroundColor3 = Palette.ElementHover })
                tween(btnStroke, 0.15, { Color = HoodUI.Accent })
            end)

            hit.MouseLeave:Connect(function()
                tween(btnCard, 0.15, { BackgroundColor3 = Palette.ElementBg })
                tween(btnStroke, 0.15, { Color = Palette.ElementBorder })
            end)

            hit.MouseButton1Click:Connect(function()
                if options.Callback then
                    pcall(options.Callback)
                end
            end)

            return btnCard
        end

        function TabObj:CreateSlider(options: { Name: string, Range: { number }, Increment: number?, Suffix: string?, CurrentValue: number?, Flag: string?, Callback: (number) -> () })
            local min = options.Range[1] or 0
            local max = options.Range[2] or 100
            local inc = options.Increment or 1
            local suffix = options.Suffix or ""
            local curVal = options.CurrentValue or min
            if options.Flag then HoodUI.Flags[options.Flag] = curVal end

            local sldFrame = Instance.new("Frame")
            sldFrame.Name = options.Name .. "_Slider"
            sldFrame.Size = UDim2.new(1, 0, 0, 46)
            sldFrame.BackgroundColor3 = Palette.ElementBg
            sldFrame.BorderSizePixel = 0
            sldFrame.ZIndex = 16
            sldFrame.Parent = page

            local sldCorner = Instance.new("UICorner")
            sldCorner.CornerRadius = UDim.new(0, 6)
            sldCorner.Parent = sldFrame

            local sldStroke = Instance.new("UIStroke")
            sldStroke.Thickness = 1
            sldStroke.Color = Palette.ElementBorder
            sldStroke.Parent = sldFrame

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -70, 0, 20)
            nameLabel.Position = UDim2.new(0, 12, 0, 6)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextSecondary
            nameLabel.TextSize = 12
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 17
            nameLabel.Parent = sldFrame

            local valLabel = Instance.new("TextLabel")
            valLabel.Size = UDim2.new(0, 60, 0, 20)
            valLabel.Position = UDim2.new(1, -72, 0, 6)
            valLabel.BackgroundTransparency = 1
            valLabel.Text = tostring(curVal) .. suffix
            valLabel.TextColor3 = HoodUI.Accent
            valLabel.TextSize = 12
            valLabel.Font = Enum.Font.GothamBold
            valLabel.TextXAlignment = Enum.TextXAlignment.Right
            valLabel.ZIndex = 17
            valLabel.Parent = sldFrame

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -24, 0, 5)
            track.Position = UDim2.new(0, 12, 0, 31)
            track.BackgroundColor3 = Palette.InputBg
            track.BorderSizePixel = 0
            track.ZIndex = 17
            track.Parent = sldFrame

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = track

            local fraction = math.clamp((curVal - min) / (max - min), 0, 1)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(fraction, 0, 1, 0)
            fill.BackgroundColor3 = HoodUI.Accent
            fill.BorderSizePixel = 0
            fill.ZIndex = 18
            fill.Parent = track

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 0, 22)
            hit.Position = UDim2.new(0, 0, 0, 22)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 19
            hit.Parent = sldFrame

            local isDragging = false

            local function updateSlider(inputX: number)
                local relX = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local rawVal = min + (relX * (max - min))
                local stepped = math.floor(rawVal / inc + 0.5) * inc
                stepped = math.clamp(stepped, min, max)

                curVal = stepped
                if options.Flag then HoodUI.Flags[options.Flag] = curVal end
                valLabel.Text = tostring(curVal) .. suffix

                local newFrac = math.clamp((curVal - min) / (max - min), 0, 1)
                fill.Size = UDim2.new(newFrac, 0, 1, 0)

                if options.Callback then
                    pcall(options.Callback, curVal)
                end
            end

            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    updateSlider(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)

            return {
                Frame = sldFrame,
                Set = function(newVal: number)
                    curVal = math.clamp(newVal, min, max)
                    if options.Flag then HoodUI.Flags[options.Flag] = curVal end
                    valLabel.Text = tostring(curVal) .. suffix
                    local newFrac = math.clamp((curVal - min) / (max - min), 0, 1)
                    fill.Size = UDim2.new(newFrac, 0, 1, 0)
                end
            }
        end

        function TabObj:CreateDropdown(options: { Name: string, Options: { string }, CurrentOption: { string }?, Flag: string?, Callback: ({ string }) -> () })
            local curOption = options.CurrentOption or { options.Options[1] or "" }
            if options.Flag then HoodUI.Flags[options.Flag] = curOption end

            local dropFrame = Instance.new("Frame")
            dropFrame.Name = options.Name .. "_Dropdown"
            dropFrame.Size = UDim2.new(1, 0, 0, 36)
            dropFrame.BackgroundColor3 = Palette.ElementBg
            dropFrame.BorderSizePixel = 0
            dropFrame.ClipsDescendants = true
            dropFrame.ZIndex = 16
            dropFrame.Parent = page

            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 6)
            dropCorner.Parent = dropFrame

            local dropStroke = Instance.new("UIStroke")
            dropStroke.Thickness = 1
            dropStroke.Color = Palette.ElementBorder
            dropStroke.Parent = dropFrame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -100, 0, 36)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextSecondary
            title.TextSize = 12
            title.Font = Enum.Font.Gotham
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = dropFrame

            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(0, 80, 0, 36)
            selectedLabel.Position = UDim2.new(1, -94, 0, 0)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = table.concat(curOption, ", ")
            selectedLabel.TextColor3 = HoodUI.Accent
            selectedLabel.TextSize = 11
            selectedLabel.Font = Enum.Font.GothamBold
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            selectedLabel.ZIndex = 17
            selectedLabel.Parent = dropFrame

            local headerHit = Instance.new("TextButton")
            headerHit.Size = UDim2.new(1, 0, 0, 36)
            headerHit.BackgroundTransparency = 1
            headerHit.Text = ""
            headerHit.ZIndex = 18
            headerHit.Parent = dropFrame

            local optContainer = Instance.new("Frame")
            optContainer.Size = UDim2.new(1, -16, 0, #options.Options * 26)
            optContainer.Position = UDim2.new(0, 8, 0, 38)
            optContainer.BackgroundTransparency = 1
            optContainer.ZIndex = 17
            optContainer.Parent = dropFrame

            local optLayout = Instance.new("UIListLayout")
            optLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optLayout.Padding = UDim.new(0, 2)
            optLayout.Parent = optContainer

            local isOpen = false
            local expandedHeight = 40 + (#options.Options * 26) + 4

            for _, optName in ipairs(options.Options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 24)
                optBtn.BackgroundColor3 = Palette.InputBg
                optBtn.BorderSizePixel = 0
                optBtn.Text = "   " .. optName
                optBtn.TextColor3 = (optName == curOption[1]) and HoodUI.Accent or Palette.TextSecondary
                optBtn.TextSize = 11
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                optBtn.ZIndex = 18
                optBtn.Parent = optContainer

                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 4)
                optCorner.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    curOption = { optName }
                    if options.Flag then HoodUI.Flags[options.Flag] = curOption end
                    selectedLabel.Text = optName

                    for _, child in ipairs(optContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.TextColor3 = (child.Text == "   " .. optName) and HoodUI.Accent or Palette.TextSecondary
                        end
                    end

                    isOpen = false
                    tween(dropFrame, 0.18, { Size = UDim2.new(1, 0, 0, 36) })

                    if options.Callback then
                        pcall(options.Callback, curOption)
                    end
                end)
            end

            headerHit.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                tween(dropFrame, 0.18, { Size = isOpen and UDim2.new(1, 0, 0, expandedHeight) or UDim2.new(1, 0, 0, 36) })
            end)

            return dropFrame
        end

        function TabObj:CreateInput(options: { Name: string, PlaceholderText: string?, CurrentValue: string?, Flag: string?, Callback: (string) -> () })
            local curVal = options.CurrentValue or ""
            if options.Flag then HoodUI.Flags[options.Flag] = curVal end

            local inFrame = Instance.new("Frame")
            inFrame.Name = options.Name .. "_Input"
            inFrame.Size = UDim2.new(1, 0, 0, 36)
            inFrame.BackgroundColor3 = Palette.ElementBg
            inFrame.BorderSizePixel = 0
            inFrame.ZIndex = 16
            inFrame.Parent = page

            local inCorner = Instance.new("UICorner")
            inCorner.CornerRadius = UDim.new(0, 6)
            inCorner.Parent = inFrame

            local inStroke = Instance.new("UIStroke")
            inStroke.Thickness = 1
            inStroke.Color = Palette.ElementBorder
            inStroke.Parent = inFrame

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 110, 1, 0)
            nameLabel.Position = UDim2.new(0, 12, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextSecondary
            nameLabel.TextSize = 12
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 17
            nameLabel.Parent = inFrame

            local boxFrame = Instance.new("Frame")
            boxFrame.Size = UDim2.new(0, 110, 0, 24)
            boxFrame.Position = UDim2.new(1, -122, 0.5, -12)
            boxFrame.BackgroundColor3 = Palette.InputBg
            boxFrame.BorderSizePixel = 0
            boxFrame.ZIndex = 17
            boxFrame.Parent = inFrame

            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 4)
            boxCorner.Parent = boxFrame

            local boxStroke = Instance.new("UIStroke")
            boxStroke.Thickness = 1
            boxStroke.Color = Palette.InputBorder
            boxStroke.Parent = boxFrame

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -8, 1, 0)
            textBox.Position = UDim2.new(0, 4, 0, 0)
            textBox.BackgroundTransparency = 1
            textBox.PlaceholderText = options.PlaceholderText or "Type..."
            textBox.PlaceholderColor3 = Palette.TextMuted
            textBox.Text = curVal
            textBox.TextColor3 = Palette.TextPrimary
            textBox.TextSize = 11
            textBox.Font = Enum.Font.Gotham
            textBox.ClearTextOnFocus = false
            textBox.ZIndex = 18
            textBox.Parent = boxFrame

            textBox.Focused:Connect(function()
                tween(boxStroke, 0.15, { Color = HoodUI.Accent })
            end)

            textBox.FocusLost:Connect(function()
                tween(boxStroke, 0.15, { Color = Palette.InputBorder })
                curVal = textBox.Text
                if options.Flag then HoodUI.Flags[options.Flag] = curVal end
                if options.Callback then
                    pcall(options.Callback, curVal)
                end
            end)

            return inFrame
        end

        function TabObj:CreateKeybind(options: { Name: string, CurrentKeybind: string?, Flag: string?, Callback: (string) -> () })
            local currentKey = options.CurrentKeybind or "None"
            if options.Flag then HoodUI.Flags[options.Flag] = currentKey end

            local kbFrame = Instance.new("Frame")
            kbFrame.Name = options.Name .. "_Keybind"
            kbFrame.Size = UDim2.new(1, 0, 0, 36)
            kbFrame.BackgroundColor3 = Palette.ElementBg
            kbFrame.BorderSizePixel = 0
            kbFrame.ZIndex = 16
            kbFrame.Parent = page

            local kbCorner = Instance.new("UICorner")
            kbCorner.CornerRadius = UDim.new(0, 6)
            kbCorner.Parent = kbFrame

            local kbStroke = Instance.new("UIStroke")
            kbStroke.Thickness = 1
            kbStroke.Color = Palette.ElementBorder
            kbStroke.Parent = kbFrame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -60, 1, 0)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextSecondary
            title.TextSize = 12
            title.Font = Enum.Font.Gotham
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = kbFrame

            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.new(0, 44, 0, 22)
            keyBtn.Position = UDim2.new(1, -52, 0.5, -11)
            keyBtn.BackgroundColor3 = Palette.InputBg
            keyBtn.BorderSizePixel = 0
            keyBtn.Text = currentKey:upper()
            keyBtn.TextColor3 = Palette.TextPrimary
            keyBtn.TextSize = 11
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.ZIndex = 17
            keyBtn.Parent = kbFrame

            local keyCorner = Instance.new("UICorner")
            keyCorner.CornerRadius = UDim.new(0, 4)
            keyCorner.Parent = keyBtn

            local keyStroke = Instance.new("UIStroke")
            keyStroke.Thickness = 1
            keyStroke.Color = Palette.InputBorder
            keyStroke.Parent = keyBtn

            local isWaiting = false
            keyBtn.MouseButton1Click:Connect(function()
                isWaiting = true
                keyBtn.Text = "..."
                keyBtn.BackgroundColor3 = HoodUI.Accent
                keyBtn.TextColor3 = Color3.fromRGB(15, 15, 18)
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if isWaiting and not gpe then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local keyName = input.KeyCode.Name
                        if input.KeyCode == Enum.KeyCode.Escape then
                            keyName = "None"
                        end
                        currentKey = keyName
                        isWaiting = false
                        keyBtn.Text = currentKey:upper()
                        keyBtn.BackgroundColor3 = Palette.InputBg
                        keyBtn.TextColor3 = Palette.TextPrimary

                        if options.Flag then HoodUI.Flags[options.Flag] = currentKey end
                        if options.Callback then
                            pcall(options.Callback, currentKey)
                        end
                    end
                end
            end)

            return kbFrame
        end

        function TabObj:CreateParagraph(options: { Title: string, Content: string })
            local card = Instance.new("Frame")
            card.Name = "Paragraph"
            card.Size = UDim2.new(1, 0, 0, 58)
            card.BackgroundColor3 = Palette.ElementBg
            card.BorderSizePixel = 0
            card.ZIndex = 16
            card.Parent = page

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = card

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = Palette.ElementBorder
            stroke.Parent = card

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -20, 0, 18)
            title.Position = UDim2.new(0, 10, 0, 6)
            title.BackgroundTransparency = 1
            title.Text = options.Title
            title.TextColor3 = HoodUI.Accent
            title.TextSize = 12
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = card

            local body = Instance.new("TextLabel")
            body.Size = UDim2.new(1, -20, 0, 30)
            body.Position = UDim2.new(0, 10, 0, 24)
            body.BackgroundTransparency = 1
            body.Text = options.Content
            body.TextColor3 = Palette.TextSecondary
            body.TextSize = 10
            body.Font = Enum.Font.Gotham
            body.TextWrapped = true
            body.TextXAlignment = Enum.TextXAlignment.Left
            body.TextYAlignment = Enum.TextYAlignment.Top
            body.ZIndex = 17
            body.Parent = card

            return card
        end

        return TabObj
    end

    table.insert(self.Windows, WindowObj)
    return WindowObj
end

function HoodUI:Destroy()
    stopBullets()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
    self.Windows = {}
end

return HoodUI
