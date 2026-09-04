local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

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
        Accent = Color3.fromRGB(243, 156, 18),
        AccentHover = Color3.fromRGB(245, 176, 65),
        AccentDark = Color3.fromRGB(214, 137, 16),
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
    Emerald = {
        Accent = Color3.fromRGB(16, 185, 129),
        AccentHover = Color3.fromRGB(52, 211, 153),
        AccentDark = Color3.fromRGB(5, 150, 105),
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
    WindowBg = Color3.fromRGB(19, 19, 23),
    WindowBorder = Color3.fromRGB(36, 36, 46),
    SidebarBg = Color3.fromRGB(15, 15, 19),
    SidebarBorder = Color3.fromRGB(30, 30, 38),
    HeaderBg = Color3.fromRGB(24, 24, 31),
    HeaderBorder = Color3.fromRGB(34, 34, 45),
    ElementBg = Color3.fromRGB(28, 28, 36),
    ElementHover = Color3.fromRGB(37, 37, 48),
    InputBg = Color3.fromRGB(20, 20, 26),
    InputBorder = Color3.fromRGB(44, 44, 58),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 176),
    TextMuted = Color3.fromRGB(100, 100, 117),
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
    ActiveParticles = {},
    ParticleRunning = false,
}

local FLYING_ASSET_ID = "rbxassetid://123190078434353"

local function spawnSingleParticle(initialXFrac: number?)
    if not HoodUI.ScreenGui or not HoodUI.ParticleContainer or not HoodUI.IsGuiOpen then return end

    local size = math.random(60, 110)
    local startYFrac = math.random(5, 85) / 100
    local endYFrac = math.clamp(startYFrac + (math.random(-15, 15) / 100), 0.05, 0.9)
    local travelDuration = math.random(25, 55) / 10

    local img = Instance.new("ImageLabel")
    img.Name = "FlyingAsset"
    img.Image = FLYING_ASSET_ID
    img.Size = UDim2.new(0, size, 0, size)
    img.BackgroundTransparency = 1
    img.BorderSizePixel = 0
    img.ScaleType = Enum.ScaleType.Fit
    img.Active = false
    img.Selectable = false
    img.ZIndex = 3
    img.Rotation = math.random(-25, 25)
    img.Parent = HoodUI.ParticleContainer

    table.insert(HoodUI.ActiveParticles, img)

    local startXScale = initialXFrac or -0.15
    local startXOffset = initialXFrac and 0 or -size
    img.Position = UDim2.new(startXScale, startXOffset, startYFrac, 0)

    local remainingFrac = 1.15 - startXScale
    local adjustedDuration = travelDuration * (remainingFrac / 1.3)

    local endPos = UDim2.new(1.15, size, endYFrac, 0)
    local flyAnim = tween(img, adjustedDuration, { Position = endPos, Rotation = img.Rotation + math.random(-40, 40) }, Enum.EasingStyle.Linear)

    flyAnim.Completed:Connect(function()
        for idx, p in ipairs(HoodUI.ActiveParticles) do
            if p == img then
                table.remove(HoodUI.ActiveParticles, idx)
                break
            end
        end
        img:Destroy()

        if HoodUI.IsGuiOpen and HoodUI.ParticleRunning then
            spawnSingleParticle(nil)
        end
    end)
end

local function startParticles()
    if HoodUI.ParticleRunning then return end
    HoodUI.ParticleRunning = true

    for i = 1, 6 do
        local frac = (i - 1) * 0.18
        spawnSingleParticle(frac)
    end

    task.spawn(function()
        while HoodUI.IsGuiOpen and HoodUI.ParticleRunning do
            while #HoodUI.ActiveParticles < 5 and HoodUI.IsGuiOpen do
                spawnSingleParticle(nil)
            end
            task.wait(0.5)
        end
    end)
end

local function stopParticles()
    HoodUI.ParticleRunning = false
    for _, p in ipairs(HoodUI.ActiveParticles) do
        if p and p.Parent then
            p:Destroy()
        end
    end
    HoodUI.ActiveParticles = {}
end

local function ensureScreenGui()
    if HoodUI.ScreenGui and HoodUI.ScreenGui.Parent then return HoodUI.ScreenGui end

    local existing = getGuiParent():FindFirstChild("HoodUI_Interface")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "HoodUI_Interface"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999
    sg.Parent = getGuiParent()

    local overlay = Instance.new("Frame")
    overlay.Name = "DarkenOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.55
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
    partContainer.ClipsDescendants = true
    partContainer.Parent = sg

    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "Notifications"
    notifFrame.Size = UDim2.new(0, 310, 1, -20)
    notifFrame.Position = UDim2.new(1, -320, 0, 10)
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

    startParticles()

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
        tween(self.DarkenOverlay, 0.3, { BackgroundTransparency = 0.55 })
        startParticles()
    else
        tween(self.DarkenOverlay, 0.3, { BackgroundTransparency = 1 })
        stopParticles()
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
    corner.CornerRadius = UDim.new(0, 8)
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
    titleLabel.TextSize = 14
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
    local navWidth = 210
    local navHeight = options.Height or 460

    local navFrame = Instance.new("Frame")
    navFrame.Name = "HoodUINav"
    navFrame.Size = UDim2.new(0, navWidth, 0, navHeight)
    navFrame.Position = UDim2.new(0.5, -340, 0.5, -navHeight / 2)
    navFrame.BackgroundColor3 = Palette.SidebarBg
    navFrame.BorderSizePixel = 0
    navFrame.ZIndex = 10
    navFrame.Parent = HoodUI.ScreenGui

    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = UDim.new(0, 10)
    navCorner.Parent = navFrame

    local navStroke = Instance.new("UIStroke")
    navStroke.Thickness = 1
    navStroke.Color = Palette.SidebarBorder
    navStroke.Parent = navFrame

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Palette.HeaderBg
    header.BorderSizePixel = 0
    header.ZIndex = 11
    header.Parent = navFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local headerStroke = Instance.new("UIStroke")
    headerStroke.Thickness = 1
    headerStroke.Color = Palette.HeaderBorder
    headerStroke.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 20)
    titleLabel.Position = UDim2.new(0, 14, 0, 7)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = options.Name or "Hood UI"
    titleLabel.TextColor3 = Palette.TextPrimary
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 12
    titleLabel.Parent = header

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -60, 0, 14)
    subLabel.Position = UDim2.new(0, 14, 0, 26)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = options.LoadingSubtitle or "by Antigravity"
    subLabel.TextColor3 = Palette.TextMuted
    subLabel.TextSize = 11
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.ZIndex = 12
    subLabel.Parent = header

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 28, 0, 28)
    toggleBtn.Position = UDim2.new(1, -34, 0, 10)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = "✕"
    toggleBtn.TextColor3 = Palette.TextMuted
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.ZIndex = 12
    toggleBtn.Parent = header

    toggleBtn.MouseButton1Click:Connect(function()
        HoodUI:ToggleGui()
    end)

    makeDraggable(navFrame, header)

    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -20, 0, 28)
    searchFrame.Position = UDim2.new(0, 10, 0, 56)
    searchFrame.BackgroundColor3 = Palette.InputBg
    searchFrame.BorderSizePixel = 0
    searchFrame.ZIndex = 11
    searchFrame.Parent = navFrame

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchFrame

    local searchStroke = Instance.new("UIStroke")
    searchStroke.Thickness = 1
    searchStroke.Color = Palette.InputBorder
    searchStroke.Parent = searchFrame

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -16, 1, 0)
    searchBox.Position = UDim2.new(0, 8, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Search elements..."
    searchBox.PlaceholderColor3 = Palette.TextMuted
    searchBox.TextColor3 = Palette.TextPrimary
    searchBox.TextSize = 12
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.ZIndex = 12
    searchBox.Parent = searchFrame

    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.Size = UDim2.new(1, -12, 1, -96)
    tabList.Position = UDim2.new(0, 6, 0, 92)
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
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = tabList

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKeyCode then
            HoodUI:ToggleGui()
        end
    end)

    local WindowObj = {
        Frame = navFrame,
        Tabs = {},
        TabSpawnOffset = 0,
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
        local tabWinWidth = 470
        local tabWinHeight = 440

        local initialX = navFrame.Position.X.Offset + navWidth + 14 + (WindowObj.TabSpawnOffset % 60)
        local initialY = navFrame.Position.Y.Offset + (WindowObj.TabSpawnOffset % 60)
        WindowObj.TabSpawnOffset = WindowObj.TabSpawnOffset + 20

        local tabWin = Instance.new("Frame")
        tabWin.Name = tabName .. "_Window"
        tabWin.Size = UDim2.new(0, tabWinWidth, 0, tabWinHeight)
        tabWin.Position = UDim2.new(navFrame.Position.X.Scale, initialX, navFrame.Position.Y.Scale, initialY)
        tabWin.BackgroundColor3 = Palette.WindowBg
        tabWin.BorderSizePixel = 0
        tabWin.ZIndex = 15
        tabWin.Visible = false
        tabWin.Parent = HoodUI.ScreenGui

        local tabWinCorner = Instance.new("UICorner")
        tabWinCorner.CornerRadius = UDim.new(0, 10)
        tabWinCorner.Parent = tabWin

        local tabWinStroke = Instance.new("UIStroke")
        tabWinStroke.Thickness = 1
        tabWinStroke.Color = Palette.WindowBorder
        tabWinStroke.Parent = tabWin

        local tabHeader = Instance.new("Frame")
        tabHeader.Name = "Header"
        tabHeader.Size = UDim2.new(1, 0, 0, 40)
        tabHeader.BackgroundColor3 = Palette.HeaderBg
        tabHeader.BorderSizePixel = 0
        tabHeader.ZIndex = 16
        tabHeader.Parent = tabWin

        local tabHeaderCorner = Instance.new("UICorner")
        tabHeaderCorner.CornerRadius = UDim.new(0, 10)
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
        tabTitle.TextSize = 13
        tabTitle.Font = Enum.Font.GothamBold
        tabTitle.TextXAlignment = Enum.TextXAlignment.Left
        tabTitle.ZIndex = 17
        tabTitle.Parent = tabHeader

        local tabCloseBtn = Instance.new("TextButton")
        tabCloseBtn.Size = UDim2.new(0, 24, 0, 24)
        tabCloseBtn.Position = UDim2.new(1, -30, 0, 8)
        tabCloseBtn.BackgroundTransparency = 1
        tabCloseBtn.Text = "✕"
        tabCloseBtn.TextColor3 = Palette.TextMuted
        tabCloseBtn.TextSize = 13
        tabCloseBtn.Font = Enum.Font.GothamBold
        tabCloseBtn.ZIndex = 17
        tabCloseBtn.Parent = tabHeader

        makeDraggable(tabWin, tabHeader)

        local page = Instance.new("ScrollingFrame")
        page.Name = "Page"
        page.Size = UDim2.new(1, -16, 1, -52)
        page.Position = UDim2.new(0, 8, 0, 46)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = HoodUI.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ZIndex = 16
        page.Parent = tabWin

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.Parent = page

        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "_NavBtn"
        tabBtn.Size = UDim2.new(1, 0, 0, 36)
        tabBtn.BackgroundColor3 = Palette.ElementBg
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = "   " .. tabName
        tabBtn.TextColor3 = Palette.TextMuted
        tabBtn.TextSize = 13
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 12
        tabBtn.Parent = tabList

        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 6)
        tabBtnCorner.Parent = tabBtn

        local tabBtnStroke = Instance.new("UIStroke")
        tabBtnStroke.Thickness = 1
        tabBtnStroke.Color = Palette.ElementBorder
        tabBtnStroke.Parent = tabBtn

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0.6, 0)
        indicator.Position = UDim2.new(0, 3, 0.2, 0)
        indicator.BackgroundColor3 = HoodUI.Accent
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        indicator.ZIndex = 13
        indicator.Parent = tabBtn

        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(0, 2)
        indCorner.Parent = indicator

        local TabObj = {
            Name = tabName,
            Window = tabWin,
            Page = page,
            Button = tabBtn,
            Indicator = indicator,
            Elements = {},
            IsOpen = false,
        }

        local function setTabOpen(open: boolean)
            TabObj.IsOpen = open
            if open then
                tabWin.Visible = true
                indicator.Visible = true
                tabBtn.TextColor3 = Palette.TextPrimary
                tabBtn.BackgroundColor3 = Palette.ElementHover
                tabBtnStroke.Color = HoodUI.Accent
                tabWin.Size = UDim2.new(0, tabWinWidth * 0.95, 0, tabWinHeight * 0.95)
                tween(tabWin, 0.2, { Size = UDim2.new(0, tabWinWidth, 0, tabWinHeight) })
            else
                tabWin.Visible = false
                indicator.Visible = false
                tabBtn.TextColor3 = Palette.TextMuted
                tabBtn.BackgroundColor3 = Palette.ElementBg
                tabBtnStroke.Color = Palette.ElementBorder
            end
        end

        tabBtn.MouseButton1Click:Connect(function()
            setTabOpen(not TabObj.IsOpen)
        end)

        tabCloseBtn.MouseButton1Click:Connect(function()
            setTabOpen(false)
        end)

        if #WindowObj.Tabs == 0 then
            setTabOpen(true)
        end

        table.insert(WindowObj.Tabs, TabObj)

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = searchBox.Text:lower()
            for _, elem in ipairs(TabObj.Elements) do
                if query == "" then
                    elem.Visible = true
                else
                    local match = (elem:FindFirstChild("Title") and elem.Title.Text:lower():find(query, 1, true)) ~= nil
                    elem.Visible = match
                end
            end
        end)

        function TabObj:CreateSection(name: string)
            local sec = Instance.new("Frame")
            sec.Name = "Section"
            sec.Size = UDim2.new(1, 0, 0, 26)
            sec.BackgroundTransparency = 1
            sec.ZIndex = 16
            sec.Parent = page

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(0, 200, 1, 0)
            title.Position = UDim2.new(0, 4, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = name
            title.TextColor3 = HoodUI.Accent
            title.TextSize = 12
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = sec

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -120, 0, 1)
            line.Position = UDim2.new(0, 110, 0.5, 0)
            line.BackgroundColor3 = Palette.ElementBorder
            line.BorderSizePixel = 0
            line.ZIndex = 16
            line.Parent = sec

            table.insert(TabObj.Elements, sec)
            return sec
        end

        function TabObj:CreateButton(options: { Name: string, Description: string?, Callback: () -> () })
            local hasDesc = options.Description ~= nil
            local btnFrame = Instance.new("Frame")
            btnFrame.Name = "Button"
            btnFrame.Size = UDim2.new(1, 0, 0, hasDesc and 50 or 38)
            btnFrame.BackgroundColor3 = Palette.ElementBg
            btnFrame.BorderSizePixel = 0
            btnFrame.ZIndex = 16
            btnFrame.Parent = page

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = btnFrame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = Palette.ElementBorder
            stroke.Parent = btnFrame

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(1, -40, 0, 20)
            title.Position = UDim2.new(0, 14, 0, hasDesc and 8 or 9)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextPrimary
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = btnFrame

            if hasDesc then
                local desc = Instance.new("TextLabel")
                desc.Size = UDim2.new(1, -40, 0, 16)
                desc.Position = UDim2.new(0, 14, 0, 26)
                desc.BackgroundTransparency = 1
                desc.Text = options.Description or ""
                desc.TextColor3 = Palette.TextMuted
                desc.TextSize = 11
                desc.Font = Enum.Font.Gotham
                desc.TextXAlignment = Enum.TextXAlignment.Left
                desc.ZIndex = 17
                desc.Parent = btnFrame
            end

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 18
            hit.Parent = btnFrame

            hit.MouseEnter:Connect(function()
                tween(btnFrame, 0.15, { BackgroundColor3 = Palette.ElementHover })
                tween(stroke, 0.15, { Color = HoodUI.Accent })
            end)

            hit.MouseLeave:Connect(function()
                tween(btnFrame, 0.15, { BackgroundColor3 = Palette.ElementBg })
                tween(stroke, 0.15, { Color = Palette.ElementBorder })
            end)

            hit.MouseButton1Click:Connect(function()
                if options.Callback then
                    pcall(options.Callback)
                end
            end)

            table.insert(TabObj.Elements, btnFrame)
            return btnFrame
        end

        function TabObj:CreateToggle(options: { Name: string, CurrentValue: boolean?, Flag: string?, Callback: (boolean) -> () })
            local state = options.CurrentValue or false
            if options.Flag then HoodUI.Flags[options.Flag] = state end

            local tglFrame = Instance.new("Frame")
            tglFrame.Name = "Toggle"
            tglFrame.Size = UDim2.new(1, 0, 0, 38)
            tglFrame.BackgroundColor3 = Palette.ElementBg
            tglFrame.BorderSizePixel = 0
            tglFrame.ZIndex = 16
            tglFrame.Parent = page

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = tglFrame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = Palette.ElementBorder
            stroke.Parent = tglFrame

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(1, -70, 1, 0)
            title.Position = UDim2.new(0, 14, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextPrimary
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = tglFrame

            local pill = Instance.new("Frame")
            pill.Size = UDim2.new(0, 38, 0, 20)
            pill.Position = UDim2.new(1, -50, 0.5, -10)
            pill.BackgroundColor3 = state and HoodUI.Accent or Palette.InputBg
            pill.BorderSizePixel = 0
            pill.ZIndex = 17
            pill.Parent = tglFrame

            local pillCorner = Instance.new("UICorner")
            pillCorner.CornerRadius = UDim.new(1, 0)
            pillCorner.Parent = pill

            local pillStroke = Instance.new("UIStroke")
            pillStroke.Thickness = 1
            pillStroke.Color = state and HoodUI.AccentHover or Palette.InputBorder
            pillStroke.Parent = pill

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 18
            knob.Parent = pill

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 19
            hit.Parent = tglFrame

            local function setToggle(newVal: boolean)
                state = newVal
                if options.Flag then HoodUI.Flags[options.Flag] = state end
                local targetX = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                local targetPill = state and HoodUI.Accent or Palette.InputBg
                local targetStroke = state and HoodUI.AccentHover or Palette.InputBorder

                tween(knob, 0.2, { Position = targetX })
                tween(pill, 0.2, { BackgroundColor3 = targetPill })
                tween(pillStroke, 0.2, { Color = targetStroke })

                if options.Callback then
                    pcall(options.Callback, state)
                end
            end

            hit.MouseButton1Click:Connect(function()
                setToggle(not state)
            end)

            table.insert(TabObj.Elements, tglFrame)
            return {
                Frame = tglFrame,
                Set = setToggle
            }
        end

        function TabObj:CreateSlider(options: { Name: string, Range: { number }, Increment: number?, Suffix: string?, CurrentValue: number?, Flag: string?, Callback: (number) -> () })
            local min = options.Range[1] or 0
            local max = options.Range[2] or 100
            local inc = options.Increment or 1
            local suffix = options.Suffix or ""
            local curVal = options.CurrentValue or min
            if options.Flag then HoodUI.Flags[options.Flag] = curVal end

            local sldFrame = Instance.new("Frame")
            sldFrame.Name = "Slider"
            sldFrame.Size = UDim2.new(1, 0, 0, 48)
            sldFrame.BackgroundColor3 = Palette.ElementBg
            sldFrame.BorderSizePixel = 0
            sldFrame.ZIndex = 16
            sldFrame.Parent = page

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = sldFrame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = Palette.ElementBorder
            stroke.Parent = sldFrame

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(1, -100, 0, 20)
            title.Position = UDim2.new(0, 14, 0, 6)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextPrimary
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = sldFrame

            local valLabel = Instance.new("TextLabel")
            valLabel.Size = UDim2.new(0, 80, 0, 20)
            valLabel.Position = UDim2.new(1, -94, 0, 6)
            valLabel.BackgroundTransparency = 1
            valLabel.Text = tostring(curVal) .. suffix
            valLabel.TextColor3 = HoodUI.Accent
            valLabel.TextSize = 12
            valLabel.Font = Enum.Font.GothamBold
            valLabel.TextXAlignment = Enum.TextXAlignment.Right
            valLabel.ZIndex = 17
            valLabel.Parent = sldFrame

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -28, 0, 6)
            track.Position = UDim2.new(0, 14, 0, 32)
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

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = UDim2.new(fraction, -6, 0.5, -6)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 19
            knob.Parent = track

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 0, 20)
            hit.Position = UDim2.new(0, 0, 0, 24)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 20
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
                knob.Position = UDim2.new(newFrac, -6, 0.5, -6)

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

            table.insert(TabObj.Elements, sldFrame)
            return {
                Frame = sldFrame,
                Set = function(newVal: number)
                    curVal = math.clamp(newVal, min, max)
                    if options.Flag then HoodUI.Flags[options.Flag] = curVal end
                    valLabel.Text = tostring(curVal) .. suffix
                    local newFrac = math.clamp((curVal - min) / (max - min), 0, 1)
                    fill.Size = UDim2.new(newFrac, 0, 1, 0)
                    knob.Position = UDim2.new(newFrac, -6, 0.5, -6)
                end
            }
        end

        function TabObj:CreateDropdown(options: { Name: string, Options: { string }, CurrentOption: { string }?, Flag: string?, Callback: ({ string }) -> () })
            local curOption = options.CurrentOption or { options.Options[1] or "" }
            if options.Flag then HoodUI.Flags[options.Flag] = curOption end

            local dropFrame = Instance.new("Frame")
            dropFrame.Name = "Dropdown"
            dropFrame.Size = UDim2.new(1, 0, 0, 38)
            dropFrame.BackgroundColor3 = Palette.ElementBg
            dropFrame.BorderSizePixel = 0
            dropFrame.ClipsDescendants = true
            dropFrame.ZIndex = 16
            dropFrame.Parent = page

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = dropFrame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = Palette.ElementBorder
            stroke.Parent = dropFrame

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(0, 180, 0, 38)
            title.Position = UDim2.new(0, 14, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextPrimary
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = dropFrame

            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(0, 140, 0, 38)
            selectedLabel.Position = UDim2.new(1, -170, 0, 0)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = table.concat(curOption, ", ")
            selectedLabel.TextColor3 = Palette.TextSecondary
            selectedLabel.TextSize = 12
            selectedLabel.Font = Enum.Font.Gotham
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            selectedLabel.ZIndex = 17
            selectedLabel.Parent = dropFrame

            local chevron = Instance.new("TextLabel")
            chevron.Size = UDim2.new(0, 20, 0, 38)
            chevron.Position = UDim2.new(1, -26, 0, 0)
            chevron.BackgroundTransparency = 1
            chevron.Text = "▼"
            chevron.TextColor3 = Palette.TextMuted
            chevron.TextSize = 10
            chevron.ZIndex = 17
            chevron.Parent = dropFrame

            local headerHit = Instance.new("TextButton")
            headerHit.Size = UDim2.new(1, 0, 0, 38)
            headerHit.BackgroundTransparency = 1
            headerHit.Text = ""
            headerHit.ZIndex = 18
            headerHit.Parent = dropFrame

            local optContainer = Instance.new("Frame")
            optContainer.Size = UDim2.new(1, -20, 0, #options.Options * 28)
            optContainer.Position = UDim2.new(0, 10, 0, 42)
            optContainer.BackgroundTransparency = 1
            optContainer.ZIndex = 17
            optContainer.Parent = dropFrame

            local optLayout = Instance.new("UIListLayout")
            optLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optLayout.Padding = UDim.new(0, 2)
            optLayout.Parent = optContainer

            local isOpen = false
            local expandedHeight = 44 + (#options.Options * 28) + 6

            for _, optName in ipairs(options.Options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3 = Palette.InputBg
                optBtn.BorderSizePixel = 0
                optBtn.Text = "   " .. optName
                optBtn.TextColor3 = (optName == curOption[1]) and HoodUI.Accent or Palette.TextSecondary
                optBtn.TextSize = 12
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
                    chevron.Text = "▼"
                    tween(dropFrame, 0.2, { Size = UDim2.new(1, 0, 0, 38) })

                    if options.Callback then
                        pcall(options.Callback, curOption)
                    end
                end)
            end

            headerHit.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                chevron.Text = isOpen and "▲" or "▼"
                tween(dropFrame, 0.2, { Size = isOpen and UDim2.new(1, 0, 0, expandedHeight) or UDim2.new(1, 0, 0, 38) })
            end)

            table.insert(TabObj.Elements, dropFrame)
            return dropFrame
        end

        function TabObj:CreateInput(options: { Name: string, PlaceholderText: string?, CurrentValue: string?, Flag: string?, Callback: (string) -> () })
            local curVal = options.CurrentValue or ""
            if options.Flag then HoodUI.Flags[options.Flag] = curVal end

            local inFrame = Instance.new("Frame")
            inFrame.Name = "Input"
            inFrame.Size = UDim2.new(1, 0, 0, 38)
            inFrame.BackgroundColor3 = Palette.ElementBg
            inFrame.BorderSizePixel = 0
            inFrame.ZIndex = 16
            inFrame.Parent = page

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = inFrame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = Palette.ElementBorder
            stroke.Parent = inFrame

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(0, 180, 1, 0)
            title.Position = UDim2.new(0, 14, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextPrimary
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = inFrame

            local inputBg = Instance.new("Frame")
            inputBg.Size = UDim2.new(0, 150, 0, 24)
            inputBg.Position = UDim2.new(1, -164, 0.5, -12)
            inputBg.BackgroundColor3 = Palette.InputBg
            inputBg.BorderSizePixel = 0
            inputBg.ZIndex = 17
            inputBg.Parent = inFrame

            local inputCorner = Instance.new("UICorner")
            inputCorner.CornerRadius = UDim.new(0, 4)
            inputCorner.Parent = inputBg

            local inputStroke = Instance.new("UIStroke")
            inputStroke.Thickness = 1
            inputStroke.Color = Palette.InputBorder
            inputStroke.Parent = inputBg

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -12, 1, 0)
            textBox.Position = UDim2.new(0, 6, 0, 0)
            textBox.BackgroundTransparency = 1
            textBox.PlaceholderText = options.PlaceholderText or "Type..."
            textBox.PlaceholderColor3 = Palette.TextMuted
            textBox.Text = curVal
            textBox.TextColor3 = Palette.TextPrimary
            textBox.TextSize = 12
            textBox.Font = Enum.Font.Gotham
            textBox.ClearTextOnFocus = false
            textBox.ZIndex = 18
            textBox.Parent = inputBg

            textBox.Focused:Connect(function()
                tween(inputStroke, 0.15, { Color = HoodUI.Accent })
            end)

            textBox.FocusLost:Connect(function()
                tween(inputStroke, 0.15, { Color = Palette.InputBorder })
                curVal = textBox.Text
                if options.Flag then HoodUI.Flags[options.Flag] = curVal end
                if options.Callback then
                    pcall(options.Callback, curVal)
                end
            end)

            table.insert(TabObj.Elements, inFrame)
            return inFrame
        end

        function TabObj:CreateKeybind(options: { Name: string, CurrentKeybind: string?, Flag: string?, Callback: (string) -> () })
            local currentKey = options.CurrentKeybind or "None"
            if options.Flag then HoodUI.Flags[options.Flag] = currentKey end

            local kbFrame = Instance.new("Frame")
            kbFrame.Name = "Keybind"
            kbFrame.Size = UDim2.new(1, 0, 0, 38)
            kbFrame.BackgroundColor3 = Palette.ElementBg
            kbFrame.BorderSizePixel = 0
            kbFrame.ZIndex = 16
            kbFrame.Parent = page

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = kbFrame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = Palette.ElementBorder
            stroke.Parent = kbFrame

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(0, 180, 1, 0)
            title.Position = UDim2.new(0, 14, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextPrimary
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = kbFrame

            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.new(0, 50, 0, 22)
            keyBtn.Position = UDim2.new(1, -64, 0.5, -11)
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
                keyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
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

            table.insert(TabObj.Elements, kbFrame)
            return kbFrame
        end

        function TabObj:CreateParagraph(options: { Title: string, Content: string })
            local card = Instance.new("Frame")
            card.Name = "Paragraph"
            card.Size = UDim2.new(1, 0, 0, 60)
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
            title.Name = "Title"
            title.Size = UDim2.new(1, -28, 0, 20)
            title.Position = UDim2.new(0, 14, 0, 8)
            title.BackgroundTransparency = 1
            title.Text = options.Title
            title.TextColor3 = HoodUI.Accent
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 17
            title.Parent = card

            local body = Instance.new("TextLabel")
            body.Size = UDim2.new(1, -28, 0, 30)
            body.Position = UDim2.new(0, 14, 0, 26)
            body.BackgroundTransparency = 1
            body.Text = options.Content
            body.TextColor3 = Palette.TextSecondary
            body.TextSize = 11
            body.Font = Enum.Font.Gotham
            body.TextWrapped = true
            body.TextXAlignment = Enum.TextXAlignment.Left
            body.TextYAlignment = Enum.TextYAlignment.Top
            body.ZIndex = 17
            body.Parent = card

            table.insert(TabObj.Elements, card)
            return card
        end

        return TabObj
    end

    table.insert(self.Windows, WindowObj)
    return WindowObj
end

function HoodUI:Destroy()
    stopParticles()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
    self.Windows = {}
end

return HoodUI
