local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

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
        Accent = Color3.fromRGB(29, 101, 245),
        AccentHover = Color3.fromRGB(50, 120, 255),
        AccentDark = Color3.fromRGB(18, 80, 210),
    },
    Emerald = {
        Accent = Color3.fromRGB(32, 201, 151),
        AccentHover = Color3.fromRGB(52, 211, 153),
        AccentDark = Color3.fromRGB(18, 140, 103),
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
    }
}

local Palette = {
    WindowBg = Color3.fromRGB(14, 14, 17),
    WindowBorder = Color3.fromRGB(28, 28, 34),
    SidebarBg = Color3.fromRGB(11, 11, 14),
    HeaderBg = Color3.fromRGB(14, 14, 17),
    CardBg = Color3.fromRGB(20, 20, 25),
    CardBorder = Color3.fromRGB(30, 30, 38),
    CardActive = Color3.fromRGB(18, 55, 130),
    CardActiveBorder = Color3.fromRGB(29, 101, 245),
    InputBg = Color3.fromRGB(12, 12, 15),
    InputBorder = Color3.fromRGB(28, 28, 36),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 150, 165),
    TextMuted = Color3.fromRGB(90, 90, 105),
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
    NotifyContainer = nil :: Frame?,
    IsGuiOpen = true,
}

local function ensureScreenGui()
    if HoodUI.ScreenGui and HoodUI.ScreenGui.Parent then return HoodUI.ScreenGui end

    local existing = getGuiParent():FindFirstChild("HoodUI_Interface")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "HoodUI_Interface"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999999
    sg.Parent = getGuiParent()

    local overlay = Instance.new("Frame")
    overlay.Name = "DarkenOverlay"
    overlay.Size = UDim2.new(1, 200, 1, 200)
    overlay.Position = UDim2.new(0, -100, 0, -100)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 1
    overlay.Active = true
    overlay.Parent = sg

    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "Notifications"
    notifFrame.Size = UDim2.new(0, 310, 1, -40)
    notifFrame.Position = UDim2.new(1, -330, 0, 20)
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
    HoodUI.NotifyContainer = notifFrame

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
        tween(self.DarkenOverlay, 0.22, { BackgroundTransparency = 0.3 })
    else
        local t = tween(self.DarkenOverlay, 0.22, { BackgroundTransparency = 1 })
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

function HoodUI:Notify(options: { Title: string?, Content: string?, Duration: number? })
    ensureScreenGui()
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 4

    local card = Instance.new("Frame")
    card.Name = "NotifCard"
    card.Size = UDim2.new(1, 0, 0, 68)
    card.Position = UDim2.new(1, 40, 0, 0)
    card.BackgroundColor3 = Palette.CardBg
    card.BorderSizePixel = 0
    card.ZIndex = 101
    card.Parent = HoodUI.NotifyContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Palette.CardBorder
    stroke.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 12, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Palette.TextPrimary
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 102
    titleLabel.Parent = card

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -24, 0, 30)
    contentLabel.Position = UDim2.new(0, 12, 0, 26)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Palette.TextSecondary
    contentLabel.TextSize = 11
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.ZIndex = 102
    contentLabel.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -6, 0, 3)
    bar.Position = UDim2.new(0, 3, 1, -4)
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

function HoodUI:CreateWindow(options: { Name: string?, ToggleKey: Enum.KeyCode?, Theme: string?, Width: number?, Height: number? })
    ensureScreenGui()
    options = options or {}

    if options.Theme then
        self:SetTheme(options.Theme)
    end

    local toggleKeyCode = options.ToggleKey or Enum.KeyCode.RightControl
    local winWidth = options.Width or 760
    local winHeight = options.Height or 480

    local winFrame = Instance.new("Frame")
    winFrame.Name = "VapeWindow"
    winFrame.Size = UDim2.new(0, winWidth, 0, winHeight)
    winFrame.Position = UDim2.new(0.5, -winWidth / 2, 0.5, -winHeight / 2)
    winFrame.BackgroundColor3 = Palette.WindowBg
    winFrame.BorderSizePixel = 0
    winFrame.ZIndex = 10
    winFrame.Parent = HoodUI.ScreenGui

    local winCorner = Instance.new("UICorner")
    winCorner.CornerRadius = UDim.new(0, 14)
    winCorner.Parent = winFrame

    local winStroke = Instance.new("UIStroke")
    winStroke.Thickness = 1
    winStroke.Color = Palette.WindowBorder
    winStroke.Parent = winFrame

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 56)
    header.BackgroundColor3 = Palette.HeaderBg
    header.BorderSizePixel = 0
    header.ZIndex = 11
    header.Parent = winFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 14)
    headerCorner.Parent = header

    local logoLabel = Instance.new("TextLabel")
    logoLabel.Size = UDim2.new(0, 55, 0, 24)
    logoLabel.Position = UDim2.new(0, 20, 0.5, -12)
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = "VAPE"
    logoLabel.TextColor3 = Palette.TextPrimary
    logoLabel.TextSize = 18
    logoLabel.Font = Enum.Font.GothamBlack
    logoLabel.TextXAlignment = Enum.TextXAlignment.Left
    logoLabel.ZIndex = 12
    logoLabel.Parent = header

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 26, 0, 18)
    badge.Position = UDim2.new(0, 76, 0.5, -9)
    badge.BackgroundColor3 = HoodUI.Accent
    badge.Text = "v4"
    badge.TextColor3 = Color3.fromRGB(255, 255, 255)
    badge.TextSize = 11
    badge.Font = Enum.Font.GothamBold
    badge.ZIndex = 13
    badge.Parent = header

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 4)
    badgeCorner.Parent = badge

    local homePill = Instance.new("Frame")
    homePill.Size = UDim2.new(0, 88, 0, 32)
    homePill.Position = UDim2.new(0, 116, 0.5, -16)
    homePill.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    homePill.BorderSizePixel = 0
    homePill.ZIndex = 12
    homePill.Parent = header

    local homeCorner = Instance.new("UICorner")
    homeCorner.CornerRadius = UDim.new(0, 6)
    homeCorner.Parent = homePill

    local homeText = Instance.new("TextLabel")
    homeText.Size = UDim2.new(1, 0, 1, 0)
    homeText.BackgroundTransparency = 1
    homeText.Text = "🏠  Home"
    homeText.TextColor3 = Palette.TextPrimary
    homeText.TextSize = 12
    homeText.Font = Enum.Font.GothamBold
    homeText.ZIndex = 13
    homeText.Parent = homePill

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -66, 0.5, -14)
    minBtn.BackgroundTransparency = 1
    minBtn.Text = "—"
    minBtn.TextColor3 = Palette.TextMuted
    minBtn.TextSize = 14
    minBtn.Font = Enum.Font.GothamBold
    minBtn.ZIndex = 13
    minBtn.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Palette.TextMuted
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 13
    closeBtn.Parent = header

    local isMinimized = false
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            tween(winFrame, 0.22, { Size = UDim2.new(0, winWidth, 0, 56) })
        else
            tween(winFrame, 0.22, { Size = UDim2.new(0, winWidth, 0, winHeight) })
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        HoodUI:ToggleGui()
    end)

    makeDraggable(winFrame, header)

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -56)
    body.Position = UDim2.new(0, 0, 0, 56)
    body.BackgroundTransparency = 1
    body.ZIndex = 11
    body.Parent = winFrame

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 150, 1, 0)
    sidebar.Position = UDim2.new(0, 0, 0, 0)
    sidebar.BackgroundColor3 = Palette.SidebarBg
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 11
    sidebar.Parent = body

    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 14)
    sideCorner.Parent = sidebar

    local catList = Instance.new("ScrollingFrame")
    catList.Name = "CategoryList"
    catList.Size = UDim2.new(1, -20, 1, -90)
    catList.Position = UDim2.new(0, 14, 0, 14)
    catList.BackgroundTransparency = 1
    catList.BorderSizePixel = 0
    catList.ScrollBarThickness = 0
    catList.CanvasSize = UDim2.new(0, 0, 0, 0)
    catList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    catList.ZIndex = 12
    catList.Parent = sidebar

    local catLayout = Instance.new("UIListLayout")
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Padding = UDim.new(0, 16)
    catLayout.Parent = catList

    local bottomIcons = Instance.new("Frame")
    bottomIcons.Size = UDim2.new(1, -20, 0, 60)
    bottomIcons.Position = UDim2.new(0, 14, 1, -70)
    bottomIcons.BackgroundTransparency = 1
    bottomIcons.ZIndex = 12
    bottomIcons.Parent = sidebar

    local iconGrid = Instance.new("UIGridLayout")
    iconGrid.CellSize = UDim2.new(0, 34, 0, 26)
    iconGrid.CellPadding = UDim2.new(0, 6, 0, 6)
    iconGrid.Parent = bottomIcons

    local miniIcons = { "☀", "🌙", "👤", "🎨", "⚙", "↻" }
    for _, sym in ipairs(miniIcons) do
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        btn.BorderSizePixel = 0
        btn.Text = sym
        btn.TextColor3 = Palette.TextMuted
        btn.TextSize = 11
        btn.ZIndex = 13
        btn.Parent = bottomIcons
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
    end

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -160, 1, -10)
    contentArea.Position = UDim2.new(0, 155, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex = 11
    contentArea.Parent = body

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKeyCode then
            HoodUI:ToggleGui()
        end
    end)

    local WindowObj = {
        Frame = winFrame,
        Tabs = {},
        ActiveTab = nil,
    }

    function WindowObj:SetVisible(visible: boolean)
        winFrame.Visible = visible
    end

    function WindowObj:CreateTab(tabName: string)
        local page = Instance.new("ScrollingFrame")
        page.Name = tabName .. "_Page"
        page.Size = UDim2.new(1, -10, 1, -10)
        page.Position = UDim2.new(0, 0, 0, 4)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = HoodUI.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.ZIndex = 12
        page.Parent = contentArea

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 6)
        pageLayout.Parent = page

        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "_TabBtn"
        tabBtn.Size = UDim2.new(1, 0, 0, 24)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Palette.TextMuted
        tabBtn.TextSize = 14
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 13
        tabBtn.Parent = catList

        local underbar = Instance.new("Frame")
        underbar.Size = UDim2.new(0, 14, 0, 3)
        underbar.Position = UDim2.new(0, 0, 1, 3)
        underbar.BackgroundColor3 = HoodUI.Accent
        underbar.BorderSizePixel = 0
        underbar.Visible = false
        underbar.ZIndex = 14
        underbar.Parent = tabBtn

        local underbarCorner = Instance.new("UICorner")
        underbarCorner.CornerRadius = UDim.new(1, 0)
        underbarCorner.Parent = underbar

        local TabObj = {
            Name = tabName,
            Page = page,
            Button = tabBtn,
            Underbar = underbar,
            Elements = {},
        }

        local function selectTab()
            for _, other in ipairs(WindowObj.Tabs) do
                other.Page.Visible = false
                other.Underbar.Visible = false
                other.Button.TextColor3 = Palette.TextMuted
            end
            page.Visible = true
            underbar.Visible = true
            tabBtn.TextColor3 = Palette.TextPrimary
            WindowObj.ActiveTab = TabObj
        end

        tabBtn.MouseButton1Click:Connect(selectTab)

        if #WindowObj.Tabs == 0 then
            selectTab()
        end

        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:CreateSection(name: string)
            local sec = Instance.new("Frame")
            sec.Name = "Section"
            sec.Size = UDim2.new(1, 0, 0, 24)
            sec.BackgroundTransparency = 1
            sec.ZIndex = 13
            sec.Parent = page

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -10, 1, 0)
            title.Position = UDim2.new(0, 4, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = name:upper()
            title.TextColor3 = Palette.TextMuted
            title.TextSize = 10
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 14
            title.Parent = sec

            return sec
        end

        function TabObj:CreateToggle(options: { Name: string, Subtitle: string?, CurrentValue: boolean?, Flag: string?, Callback: (boolean) -> () })
            local state = options.CurrentValue or false
            if options.Flag then HoodUI.Flags[options.Flag] = state end

            local modCard = Instance.new("Frame")
            modCard.Name = options.Name .. "_Card"
            modCard.Size = UDim2.new(1, 0, 0, 44)
            modCard.BackgroundColor3 = state and HoodUI.Accent or Palette.CardBg
            modCard.BorderSizePixel = 0
            modCard.ClipsDescendants = true
            modCard.ZIndex = 14
            modCard.Parent = page

            local modCorner = Instance.new("UICorner")
            modCorner.CornerRadius = UDim.new(0, 8)
            modCorner.Parent = modCard

            local iconLabel = Instance.new("TextLabel")
            iconLabel.Size = UDim2.new(0, 24, 0, 44)
            iconLabel.Position = UDim2.new(0, 14, 0, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Text = "✦"
            iconLabel.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Palette.TextMuted
            iconLabel.TextSize = 13
            iconLabel.ZIndex = 15
            iconLabel.Parent = modCard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 140, 0, 44)
            nameLabel.Position = UDim2.new(0, 44, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 15
            nameLabel.Parent = modCard

            local subText = options.Subtitle or ""
            local subLabel = Instance.new("TextLabel")
            subLabel.Size = UDim2.new(1, -310, 0, 44)
            subLabel.Position = UDim2.new(0, 190, 0, 0)
            subLabel.BackgroundTransparency = 1
            subLabel.Text = subText
            subLabel.TextColor3 = state and Color3.fromRGB(210, 230, 255) or Palette.TextMuted
            subLabel.TextSize = 11
            subLabel.Font = Enum.Font.Gotham
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.ZIndex = 15
            subLabel.Parent = modCard

            local pill = Instance.new("Frame")
            pill.Size = UDim2.new(0, 36, 0, 20)
            pill.Position = UDim2.new(1, -72, 0.5, -10)
            pill.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(36, 36, 44)
            pill.BorderSizePixel = 0
            pill.ZIndex = 15
            pill.Parent = modCard

            local pillCorner = Instance.new("UICorner")
            pillCorner.CornerRadius = UDim.new(1, 0)
            pillCorner.Parent = pill

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            knob.BackgroundColor3 = state and HoodUI.Accent or Color3.fromRGB(150, 150, 160)
            knob.BorderSizePixel = 0
            knob.ZIndex = 16
            knob.Parent = pill

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local dotsBtn = Instance.new("TextButton")
            dotsBtn.Size = UDim2.new(0, 24, 0, 44)
            dotsBtn.Position = UDim2.new(1, -30, 0, 0)
            dotsBtn.BackgroundTransparency = 1
            dotsBtn.Text = "⋮"
            dotsBtn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Palette.TextMuted
            dotsBtn.TextSize = 14
            dotsBtn.Font = Enum.Font.GothamBold
            dotsBtn.ZIndex = 16
            dotsBtn.Parent = modCard

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, -36, 0, 44)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 15
            hit.Parent = modCard

            local function setToggle(newVal: boolean)
                state = newVal
                if options.Flag then HoodUI.Flags[options.Flag] = state end

                local targetCardBg = state and HoodUI.Accent or Palette.CardBg
                local targetPillBg = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(36, 36, 44)
                local targetKnobPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                local targetKnobCol = state and HoodUI.Accent or Color3.fromRGB(150, 150, 160)

                tween(modCard, 0.18, { BackgroundColor3 = targetCardBg })
                tween(pill, 0.18, { BackgroundColor3 = targetPillBg })
                tween(knob, 0.18, { Position = targetKnobPos, BackgroundColor3 = targetKnobCol })

                iconLabel.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Palette.TextMuted
                subLabel.TextColor3 = state and Color3.fromRGB(210, 230, 255) or Palette.TextMuted
                dotsBtn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Palette.TextMuted

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

        function TabObj:CreateSlider(options: { Name: string, Range: { number }, Increment: number?, Suffix: string?, CurrentValue: number?, Flag: string?, Callback: (number) -> () })
            local min = options.Range[1] or 0
            local max = options.Range[2] or 100
            local inc = options.Increment or 1
            local suffix = options.Suffix or ""
            local curVal = options.CurrentValue or min
            if options.Flag then HoodUI.Flags[options.Flag] = curVal end

            local sldFrame = Instance.new("Frame")
            sldFrame.Name = options.Name .. "_Slider"
            sldFrame.Size = UDim2.new(1, 0, 0, 44)
            sldFrame.BackgroundColor3 = Palette.CardBg
            sldFrame.BorderSizePixel = 0
            sldFrame.ZIndex = 14
            sldFrame.Parent = page

            local sldCorner = Instance.new("UICorner")
            sldCorner.CornerRadius = UDim.new(0, 8)
            sldCorner.Parent = sldFrame

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 160, 0, 44)
            nameLabel.Position = UDim2.new(0, 14, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextPrimary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 15
            nameLabel.Parent = sldFrame

            local valLabel = Instance.new("TextLabel")
            valLabel.Size = UDim2.new(0, 80, 0, 44)
            valLabel.Position = UDim2.new(1, -94, 0, 0)
            valLabel.BackgroundTransparency = 1
            valLabel.Text = tostring(curVal) .. suffix
            valLabel.TextColor3 = HoodUI.Accent
            valLabel.TextSize = 12
            valLabel.Font = Enum.Font.GothamBold
            valLabel.TextXAlignment = Enum.TextXAlignment.Right
            valLabel.ZIndex = 15
            valLabel.Parent = sldFrame

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -290, 0, 6)
            track.Position = UDim2.new(0, 180, 0.5, -3)
            track.BackgroundColor3 = Palette.InputBg
            track.BorderSizePixel = 0
            track.ZIndex = 15
            track.Parent = sldFrame

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = track

            local fraction = math.clamp((curVal - min) / (max - min), 0, 1)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(fraction, 0, 1, 0)
            fill.BackgroundColor3 = HoodUI.Accent
            fill.BorderSizePixel = 0
            fill.ZIndex = 16
            fill.Parent = track

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 0, 30)
            hit.Position = UDim2.new(0, 0, 0.5, -15)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 17
            hit.Parent = track

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
            dropFrame.Size = UDim2.new(1, 0, 0, 44)
            dropFrame.BackgroundColor3 = Palette.CardBg
            dropFrame.BorderSizePixel = 0
            dropFrame.ClipsDescendants = true
            dropFrame.ZIndex = 14
            dropFrame.Parent = page

            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 8)
            dropCorner.Parent = dropFrame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(0, 160, 0, 44)
            title.Position = UDim2.new(0, 14, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextPrimary
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 15
            title.Parent = dropFrame

            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(0, 120, 0, 44)
            selectedLabel.Position = UDim2.new(1, -150, 0, 0)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = table.concat(curOption, ", ")
            selectedLabel.TextColor3 = HoodUI.Accent
            selectedLabel.TextSize = 12
            selectedLabel.Font = Enum.Font.GothamBold
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            selectedLabel.ZIndex = 15
            selectedLabel.Parent = dropFrame

            local headerHit = Instance.new("TextButton")
            headerHit.Size = UDim2.new(1, 0, 0, 44)
            headerHit.BackgroundTransparency = 1
            headerHit.Text = ""
            headerHit.ZIndex = 16
            headerHit.Parent = dropFrame

            local optContainer = Instance.new("Frame")
            optContainer.Size = UDim2.new(1, -28, 0, #options.Options * 28)
            optContainer.Position = UDim2.new(0, 14, 0, 46)
            optContainer.BackgroundTransparency = 1
            optContainer.ZIndex = 15
            optContainer.Parent = dropFrame

            local optLayout = Instance.new("UIListLayout")
            optLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optLayout.Padding = UDim.new(0, 3)
            optLayout.Parent = optContainer

            local isOpen = false
            local expandedHeight = 48 + (#options.Options * 28) + 6

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
                optBtn.ZIndex = 16
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
                    tween(dropFrame, 0.18, { Size = UDim2.new(1, 0, 0, 44) })

                    if options.Callback then
                        pcall(options.Callback, curOption)
                    end
                end)
            end

            headerHit.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                tween(dropFrame, 0.18, { Size = isOpen and UDim2.new(1, 0, 0, expandedHeight) or UDim2.new(1, 0, 0, 44) })
            end)

            return dropFrame
        end

        function TabObj:CreateInput(options: { Name: string, PlaceholderText: string?, CurrentValue: string?, Flag: string?, Callback: (string) -> () })
            local curVal = options.CurrentValue or ""
            if options.Flag then HoodUI.Flags[options.Flag] = curVal end

            local inFrame = Instance.new("Frame")
            inFrame.Name = options.Name .. "_Input"
            inFrame.Size = UDim2.new(1, 0, 0, 44)
            inFrame.BackgroundColor3 = Palette.CardBg
            inFrame.BorderSizePixel = 0
            inFrame.ZIndex = 14
            inFrame.Parent = page

            local inCorner = Instance.new("UICorner")
            inCorner.CornerRadius = UDim.new(0, 8)
            inCorner.Parent = inFrame

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 160, 1, 0)
            nameLabel.Position = UDim2.new(0, 14, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextPrimary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 15
            nameLabel.Parent = inFrame

            local boxFrame = Instance.new("Frame")
            boxFrame.Size = UDim2.new(0, 140, 0, 26)
            boxFrame.Position = UDim2.new(1, -154, 0.5, -13)
            boxFrame.BackgroundColor3 = Palette.InputBg
            boxFrame.BorderSizePixel = 0
            boxFrame.ZIndex = 15
            boxFrame.Parent = inFrame

            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 4)
            boxCorner.Parent = boxFrame

            local boxStroke = Instance.new("UIStroke")
            boxStroke.Thickness = 1
            boxStroke.Color = Palette.InputBorder
            boxStroke.Parent = boxFrame

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
            textBox.ZIndex = 16
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

        function TabObj:CreateButton(options: { Name: string, Callback: () -> () })
            local btnCard = Instance.new("Frame")
            btnCard.Name = options.Name .. "_Btn"
            btnCard.Size = UDim2.new(1, 0, 0, 44)
            btnCard.BackgroundColor3 = Palette.CardBg
            btnCard.BorderSizePixel = 0
            btnCard.ZIndex = 14
            btnCard.Parent = page

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btnCard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -30, 1, 0)
            nameLabel.Position = UDim2.new(0, 14, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextPrimary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 15
            nameLabel.Parent = btnCard

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 16
            hit.Parent = btnCard

            hit.MouseEnter:Connect(function()
                tween(btnCard, 0.15, { BackgroundColor3 = Color3.fromRGB(26, 26, 32) })
            end)

            hit.MouseLeave:Connect(function()
                tween(btnCard, 0.15, { BackgroundColor3 = Palette.CardBg })
            end)

            hit.MouseButton1Click:Connect(function()
                if options.Callback then
                    pcall(options.Callback)
                end
            end)

            return btnCard
        end

        function TabObj:CreateKeybind(options: { Name: string, CurrentKeybind: string?, Flag: string?, Callback: (string) -> () })
            local currentKey = options.CurrentKeybind or "None"
            if options.Flag then HoodUI.Flags[options.Flag] = currentKey end

            local kbFrame = Instance.new("Frame")
            kbFrame.Name = options.Name .. "_Keybind"
            kbFrame.Size = UDim2.new(1, 0, 0, 44)
            kbFrame.BackgroundColor3 = Palette.CardBg
            kbFrame.BorderSizePixel = 0
            kbFrame.ZIndex = 14
            kbFrame.Parent = page

            local kbCorner = Instance.new("UICorner")
            kbCorner.CornerRadius = UDim.new(0, 8)
            kbCorner.Parent = kbFrame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(0, 160, 1, 0)
            title.Position = UDim2.new(0, 14, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = options.Name
            title.TextColor3 = Palette.TextPrimary
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 15
            title.Parent = kbFrame

            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.new(0, 50, 0, 24)
            keyBtn.Position = UDim2.new(1, -64, 0.5, -12)
            keyBtn.BackgroundColor3 = Palette.InputBg
            keyBtn.BorderSizePixel = 0
            keyBtn.Text = currentKey:upper()
            keyBtn.TextColor3 = Palette.TextPrimary
            keyBtn.TextSize = 11
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.ZIndex = 15
            keyBtn.Parent = kbFrame

            local keyCorner = Instance.new("UICorner")
            keyCorner.CornerRadius = UDim.new(0, 4)
            keyCorner.Parent = keyBtn

            local isWaiting = false
            keyBtn.MouseButton1Click:Connect(function()
                isWaiting = true
                keyBtn.Text = "..."
                keyBtn.BackgroundColor3 = HoodUI.Accent
                keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
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

        return TabObj
    end

    table.insert(self.Windows, WindowObj)
    return WindowObj
end

function HoodUI:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
    self.Windows = {}
end

return HoodUI
