local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local function getGuiParent(): Instance
    local successHui, hui = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return nil
    end)
    if successHui and hui then return hui end

    local successCore, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if successCore and coreGui then
        local canParent = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = coreGui
            test:Destroy()
        end)
        if canParent then return coreGui end
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local Palette = {
    BlackOverlay = Color3.fromRGB(0, 0, 0),
    WindowBg = Color3.fromRGB(13, 14, 18),
    WindowBorder = Color3.fromRGB(32, 34, 44),
    HeaderBg = Color3.fromRGB(16, 17, 22),
    HeaderBorder = Color3.fromRGB(28, 29, 38),
    SidebarBg = Color3.fromRGB(10, 11, 15),
    SidebarBorder = Color3.fromRGB(24, 25, 34),
    CardBg = Color3.fromRGB(18, 19, 25),
    CardHover = Color3.fromRGB(25, 27, 36),
    CardBorder = Color3.fromRGB(30, 32, 42),
    CardActive = Color3.fromRGB(24, 26, 35),
    CardActiveBorder = Color3.fromRGB(55, 58, 75),
    InputBg = Color3.fromRGB(11, 12, 16),
    InputBorder = Color3.fromRGB(30, 32, 42),
    InputFocus = Color3.fromRGB(75, 78, 98),
    PillOff = Color3.fromRGB(32, 34, 44),
    PillOffBorder = Color3.fromRGB(48, 50, 64),
    PillOn = Color3.fromRGB(245, 246, 252),
    KnobOff = Color3.fromRGB(85, 88, 105),
    KnobOn = Color3.fromRGB(15, 16, 22),
    AccentWhite = Color3.fromRGB(255, 255, 255),
    AccentGray = Color3.fromRGB(190, 192, 208),
    TextPrimary = Color3.fromRGB(245, 246, 252),
    TextSecondary = Color3.fromRGB(145, 148, 168),
    TextMuted = Color3.fromRGB(100, 103, 122),
    TextDim = Color3.fromRGB(65, 68, 84),
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
    ScreenGui = nil :: ScreenGui?,
    DarkenOverlay = nil :: Frame?,
    NotifyContainer = nil :: Frame?,
    WatermarkBtn = nil :: GuiObject?,
    IsGuiOpen = true,
    ToggleKey = Enum.KeyCode.RightControl,
    _inputBound = false,
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
    overlay.Size = UDim2.new(1, 400, 1, 400)
    overlay.Position = UDim2.new(0, -200, 0, -200)
    overlay.BackgroundColor3 = Palette.BlackOverlay
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 1
    overlay.Active = false
    overlay.Parent = sg

    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "Notifications"
    notifFrame.Size = UDim2.new(0, 310, 1, -60)
    notifFrame.Position = UDim2.new(1, -330, 0, 40)
    notifFrame.BackgroundTransparency = 1
    notifFrame.BorderSizePixel = 0
    notifFrame.ZIndex = 100
    notifFrame.Parent = sg

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = notifFrame

    local watermark = Instance.new("TextButton")
    watermark.Name = "WatermarkToggle"
    watermark.Size = UDim2.new(0, 130, 0, 26)
    watermark.Position = UDim2.new(0, 16, 0, 16)
    watermark.BackgroundColor3 = Palette.WindowBg
    watermark.BackgroundTransparency = 0.2
    watermark.BorderSizePixel = 0
    watermark.Text = "HOOD v4  [RCtrl]"
    watermark.TextColor3 = Palette.TextMuted
    watermark.TextSize = 11
    watermark.Font = Enum.Font.GothamBold
    watermark.AutoButtonColor = false
    watermark.ZIndex = 50
    watermark.Parent = sg

    local wmCorner = Instance.new("UICorner")
    wmCorner.CornerRadius = UDim.new(0, 6)
    wmCorner.Parent = watermark

    local wmStroke = Instance.new("UIStroke")
    wmStroke.Thickness = 1
    wmStroke.Color = Palette.WindowBorder
    wmStroke.Parent = watermark

    watermark.MouseEnter:Connect(function()
        tween(watermark, 0.15, { BackgroundTransparency = 0.05, TextColor3 = Palette.TextPrimary })
    end)
    watermark.MouseLeave:Connect(function()
        tween(watermark, 0.15, { BackgroundTransparency = 0.2, TextColor3 = Palette.TextMuted })
    end)
    watermark.MouseButton1Click:Connect(function()
        HoodUI:ToggleGui()
    end)

    HoodUI.ScreenGui = sg
    HoodUI.DarkenOverlay = overlay
    HoodUI.NotifyContainer = notifFrame
    HoodUI.WatermarkBtn = watermark

    if not HoodUI._inputBound then
        HoodUI._inputBound = true
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == HoodUI.ToggleKey then
                local focused = UserInputService:GetFocusedTextBox()
                if not focused then
                    HoodUI:ToggleGui()
                end
            end
        end)
    end

    return sg
end

function HoodUI:SetGuiOpen(isOpen: boolean)
    self.IsGuiOpen = isOpen
    ensureScreenGui()

    if self.DarkenOverlay then
        if isOpen then
            self.DarkenOverlay.Visible = true
            tween(self.DarkenOverlay, 0.2, { BackgroundTransparency = 0.3 })
        else
            local fade = tween(self.DarkenOverlay, 0.18, { BackgroundTransparency = 1 })
            fade.Completed:Connect(function()
                if not self.IsGuiOpen and self.DarkenOverlay then
                    self.DarkenOverlay.Visible = false
                end
            end)
        end
    end

    for _, win in ipairs(self.Windows) do
        if win.Frame then
            win.Frame.Visible = isOpen
        end
    end
end

function HoodUI:ToggleGui()
    self:SetGuiOpen(not self.IsGuiOpen)
end

function HoodUI:SetToggleKey(newKey: Enum.KeyCode)
    self.ToggleKey = newKey
    if self.WatermarkBtn then
        self.WatermarkBtn.Text = "HOOD v4  [" .. newKey.Name .. "]"
    end
end

function HoodUI:Notify(options: { Title: string?, Content: string?, Duration: number? })
    ensureScreenGui()
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 3.5

    local card = Instance.new("Frame")
    card.Name = "NotifCard"
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Palette.CardBg
    card.BackgroundTransparency = 0.15
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
    titleLabel.Size = UDim2.new(1, -20, 0, 18)
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
    contentLabel.Size = UDim2.new(1, -24, 0, 24)
    contentLabel.Position = UDim2.new(0, 12, 0, 28)
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
    bar.Size = UDim2.new(1, -6, 0, 2)
    bar.Position = UDim2.new(0, 3, 1, -3)
    bar.BackgroundColor3 = Palette.AccentWhite
    bar.BorderSizePixel = 0
    bar.ZIndex = 102
    bar.Parent = card

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 1)
    barCorner.Parent = bar

    card.Position = UDim2.new(1, 100, 0, 0)
    tween(card, 0.25, { Position = UDim2.new(0, 0, 0, 0) })
    tween(bar, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if card and card.Parent then
            local exit = tween(card, 0.22, { Position = UDim2.new(1, 100, 0, 0), BackgroundTransparency = 1 })
            exit.Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

function HoodUI:CreateWindow(options: { Name: string?, ToggleKey: Enum.KeyCode?, Width: number?, Height: number? })
    ensureScreenGui()
    options = options or {}

    local toggleKey = options.ToggleKey or HoodUI.ToggleKey or Enum.KeyCode.RightControl
    HoodUI:SetToggleKey(toggleKey)

    local winWidth = options.Width or 750
    local winHeight = options.Height or 470

    local winFrame = Instance.new("Frame")
    winFrame.Name = "HoodWindow"
    winFrame.Size = UDim2.new(0, winWidth, 0, winHeight)
    winFrame.Position = UDim2.new(0.5, -winWidth / 2, 0.5, -winHeight / 2)
    winFrame.BackgroundColor3 = Palette.WindowBg
    winFrame.BackgroundTransparency = 0.12
    winFrame.BorderSizePixel = 0
    winFrame.ZIndex = 10
    winFrame.Parent = HoodUI.ScreenGui

    local winCorner = Instance.new("UICorner")
    winCorner.CornerRadius = UDim.new(0, 12)
    winCorner.Parent = winFrame

    local winStroke = Instance.new("UIStroke")
    winStroke.Thickness = 1
    winStroke.Color = Palette.WindowBorder
    winStroke.Parent = winFrame

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Palette.HeaderBg
    header.BackgroundTransparency = 0.12
    header.BorderSizePixel = 0
    header.ZIndex = 11
    header.Parent = winFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = Palette.HeaderBorder
    headerLine.BorderSizePixel = 0
    headerLine.ZIndex = 12
    headerLine.Parent = header

    local logoLabel = Instance.new("TextLabel")
    logoLabel.Size = UDim2.new(0, 54, 0, 24)
    logoLabel.Position = UDim2.new(0, 18, 0.5, -12)
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = options.Name or "VAPE"
    logoLabel.TextColor3 = Palette.TextPrimary
    logoLabel.TextSize = 16
    logoLabel.Font = Enum.Font.GothamBold
    logoLabel.TextXAlignment = Enum.TextXAlignment.Left
    logoLabel.ZIndex = 13
    logoLabel.Parent = header

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 26, 0, 18)
    badge.Position = UDim2.new(0, 74, 0.5, -9)
    badge.BackgroundColor3 = Palette.CardBorder
    badge.BackgroundTransparency = 0.2
    badge.Text = "v4"
    badge.TextColor3 = Palette.TextSecondary
    badge.TextSize = 11
    badge.Font = Enum.Font.GothamBold
    badge.ZIndex = 13
    badge.Parent = header

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 4)
    badgeCorner.Parent = badge

    local homeBtn = Instance.new("Frame")
    homeBtn.Size = UDim2.new(0, 74, 0, 28)
    homeBtn.Position = UDim2.new(0, 112, 0.5, -14)
    homeBtn.BackgroundColor3 = Palette.CardBg
    homeBtn.BackgroundTransparency = 0.2
    homeBtn.BorderSizePixel = 0
    homeBtn.ZIndex = 13
    homeBtn.Parent = header

    local homeBtnCorner = Instance.new("UICorner")
    homeBtnCorner.CornerRadius = UDim.new(0, 6)
    homeBtnCorner.Parent = homeBtn

    local homeText = Instance.new("TextLabel")
    homeText.Size = UDim2.new(1, 0, 1, 0)
    homeText.BackgroundTransparency = 1
    homeText.Text = "Home"
    homeText.TextColor3 = Palette.TextPrimary
    homeText.TextSize = 12
    homeText.Font = Enum.Font.GothamMedium
    homeText.ZIndex = 14
    homeText.Parent = homeBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -12)
    closeBtn.BackgroundColor3 = Palette.CardBg
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Palette.TextMuted
    closeBtn.TextSize = 11
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 13
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(180, 50, 50), TextColor3 = Color3.fromRGB(255, 255, 255) })
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, 0.15, { BackgroundColor3 = Palette.CardBg, TextColor3 = Palette.TextMuted })
    end)
    closeBtn.MouseButton1Click:Connect(function()
        HoodUI:ToggleGui()
    end)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(1, -64, 0.5, -12)
    minBtn.BackgroundColor3 = Palette.CardBg
    minBtn.BackgroundTransparency = 0.2
    minBtn.BorderSizePixel = 0
    minBtn.Text = "-"
    minBtn.TextColor3 = Palette.TextMuted
    minBtn.TextSize = 12
    minBtn.Font = Enum.Font.GothamBold
    minBtn.ZIndex = 13
    minBtn.Parent = header

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 4)
    minCorner.Parent = minBtn

    local isMinimized = false
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            tween(winFrame, 0.2, { Size = UDim2.new(0, winWidth, 0, 50) })
        else
            tween(winFrame, 0.2, { Size = UDim2.new(0, winWidth, 0, winHeight) })
        end
    end)

    makeDraggable(winFrame, header)

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -50)
    body.Position = UDim2.new(0, 0, 0, 50)
    body.BackgroundTransparency = 1
    body.ZIndex = 11
    body.Parent = winFrame

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 160, 1, 0)
    sidebar.Position = UDim2.new(0, 0, 0, 0)
    sidebar.BackgroundColor3 = Palette.SidebarBg
    sidebar.BackgroundTransparency = 0.15
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 11
    sidebar.Parent = body

    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 12)
    sideCorner.Parent = sidebar

    local sideDivider = Instance.new("Frame")
    sideDivider.Size = UDim2.new(0, 1, 1, 0)
    sideDivider.Position = UDim2.new(1, -1, 0, 0)
    sideDivider.BackgroundColor3 = Palette.SidebarBorder
    sideDivider.BorderSizePixel = 0
    sideDivider.ZIndex = 12
    sideDivider.Parent = sidebar

    local catList = Instance.new("ScrollingFrame")
    catList.Name = "CategoryList"
    catList.Size = UDim2.new(1, -16, 1, -70)
    catList.Position = UDim2.new(0, 8, 0, 10)
    catList.BackgroundTransparency = 1
    catList.BorderSizePixel = 0
    catList.ScrollBarThickness = 0
    catList.CanvasSize = UDim2.new(0, 0, 0, 0)
    catList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    catList.ZIndex = 12
    catList.Parent = sidebar

    local catLayout = Instance.new("UIListLayout")
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Padding = UDim.new(0, 4)
    catLayout.Parent = catList

    local sideBottom = Instance.new("Frame")
    sideBottom.Name = "SideBottomGrid"
    sideBottom.Size = UDim2.new(1, -16, 0, 48)
    sideBottom.Position = UDim2.new(0, 8, 1, -56)
    sideBottom.BackgroundTransparency = 1
    sideBottom.ZIndex = 12
    sideBottom.Parent = sidebar

    local bottomGrid = Instance.new("UIGridLayout")
    bottomGrid.CellSize = UDim2.new(0, 32, 0, 22)
    bottomGrid.CellPadding = UDim2.new(0, 5, 0, 4)
    bottomGrid.SortOrder = Enum.SortOrder.LayoutOrder
    bottomGrid.Parent = sideBottom

    local miniIcons = { "HUD", "CFG", "KEY", "SET" }
    for i, iconText in ipairs(miniIcons) do
        local miniBtn = Instance.new("TextButton")
        miniBtn.BackgroundColor3 = Palette.CardBg
        miniBtn.BackgroundTransparency = 0.25
        miniBtn.BorderSizePixel = 0
        miniBtn.Text = iconText
        miniBtn.TextColor3 = Palette.TextDim
        miniBtn.TextSize = 9
        miniBtn.Font = Enum.Font.GothamBold
        miniBtn.ZIndex = 13
        miniBtn.Parent = sideBottom

        local mCorner = Instance.new("UICorner")
        mCorner.CornerRadius = UDim.new(0, 4)
        mCorner.Parent = miniBtn

        miniBtn.MouseEnter:Connect(function()
            tween(miniBtn, 0.15, { TextColor3 = Palette.TextPrimary, BackgroundTransparency = 0.1 })
        end)
        miniBtn.MouseLeave:Connect(function()
            tween(miniBtn, 0.15, { TextColor3 = Palette.TextDim, BackgroundTransparency = 0.25 })
        end)
    end

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -172, 1, -12)
    contentArea.Position = UDim2.new(0, 166, 0, 6)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex = 11
    contentArea.Parent = body

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
        page.Size = UDim2.new(1, -6, 1, -4)
        page.Position = UDim2.new(0, 3, 0, 2)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Palette.CardBorder
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
        tabBtn.Name = tabName .. "_Btn"
        tabBtn.Size = UDim2.new(1, 0, 0, 36)
        tabBtn.BackgroundColor3 = Palette.SidebarBg
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = "   " .. tabName
        tabBtn.TextColor3 = Palette.TextMuted
        tabBtn.TextSize = 13
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 13
        tabBtn.Parent = catList

        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 6)
        tabBtnCorner.Parent = tabBtn

        local activeBar = Instance.new("Frame")
        activeBar.Size = UDim2.new(0, 16, 0, 2)
        activeBar.Position = UDim2.new(0, 12, 1, -3)
        activeBar.BackgroundColor3 = Palette.AccentWhite
        activeBar.BorderSizePixel = 0
        activeBar.Visible = false
        activeBar.ZIndex = 14
        activeBar.Parent = tabBtn

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = activeBar

        local TabObj = {
            Name = tabName,
            Page = page,
            Button = tabBtn,
            ActiveBar = activeBar,
            Elements = {},
        }

        local function selectTab()
            for _, other in ipairs(WindowObj.Tabs) do
                other.Page.Visible = false
                other.ActiveBar.Visible = false
                other.Button.TextColor3 = Palette.TextMuted
                other.Button.BackgroundTransparency = 1
            end
            page.Visible = true
            activeBar.Visible = true
            tabBtn.TextColor3 = Palette.TextPrimary
            tabBtn.BackgroundColor3 = Palette.CardBg
            tabBtn.BackgroundTransparency = 0.2
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
            sec.Size = UDim2.new(1, 0, 0, 22)
            sec.BackgroundTransparency = 1
            sec.ZIndex = 13
            sec.Parent = page

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -8, 1, 0)
            title.Position = UDim2.new(0, 4, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = name:upper()
            title.TextColor3 = Palette.TextDim
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
            modCard.BackgroundColor3 = state and Palette.CardActive or Palette.CardBg
            modCard.BackgroundTransparency = 0.18
            modCard.BorderSizePixel = 0
            modCard.ZIndex = 13
            modCard.Parent = page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = modCard

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Thickness = 1
            cardStroke.Color = state and Palette.CardActiveBorder or Palette.CardBorder
            cardStroke.Parent = modCard

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 6, 0, 6)
            dot.Position = UDim2.new(0, 12, 0.5, -3)
            dot.BackgroundColor3 = state and Palette.AccentWhite or Palette.TextDim
            dot.BorderSizePixel = 0
            dot.ZIndex = 14
            dot.Parent = modCard

            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -120, 0, options.Subtitle and 18 or 44)
            nameLabel.Position = UDim2.new(0, 26, 0, options.Subtitle and 4 or 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = state and Palette.TextPrimary or Palette.TextSecondary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 14
            nameLabel.Parent = modCard

            if options.Subtitle then
                local sub = Instance.new("TextLabel")
                sub.Size = UDim2.new(1, -120, 0, 16)
                sub.Position = UDim2.new(0, 26, 0, 22)
                sub.BackgroundTransparency = 1
                sub.Text = options.Subtitle
                sub.TextColor3 = Palette.TextMuted
                sub.TextSize = 11
                sub.Font = Enum.Font.Gotham
                sub.TextXAlignment = Enum.TextXAlignment.Left
                sub.ZIndex = 14
                sub.Parent = modCard
            end

            local pill = Instance.new("Frame")
            pill.Size = UDim2.new(0, 36, 0, 18)
            pill.Position = UDim2.new(1, -72, 0.5, -9)
            pill.BackgroundColor3 = state and Palette.PillOn or Palette.PillOff
            pill.BorderSizePixel = 0
            pill.ZIndex = 14
            pill.Parent = modCard

            local pillCorner = Instance.new("UICorner")
            pillCorner.CornerRadius = UDim.new(1, 0)
            pillCorner.Parent = pill

            local pillStroke = Instance.new("UIStroke")
            pillStroke.Thickness = 1
            pillStroke.Color = state and Palette.PillOn or Palette.PillOffBorder
            pillStroke.Parent = pill

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            knob.BackgroundColor3 = state and Palette.KnobOn or Palette.KnobOff
            knob.BorderSizePixel = 0
            knob.ZIndex = 15
            knob.Parent = pill

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local dotsBtn = Instance.new("TextButton")
            dotsBtn.Size = UDim2.new(0, 22, 0, 24)
            dotsBtn.Position = UDim2.new(1, -30, 0.5, -12)
            dotsBtn.BackgroundTransparency = 1
            dotsBtn.Text = ":"
            dotsBtn.TextColor3 = Palette.TextDim
            dotsBtn.TextSize = 15
            dotsBtn.Font = Enum.Font.GothamBold
            dotsBtn.ZIndex = 14
            dotsBtn.Parent = modCard

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, -34, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 16
            hit.Parent = modCard

            local function updateToggle(val: boolean)
                state = val
                if options.Flag then HoodUI.Flags[options.Flag] = state end

                if state then
                    tween(modCard, 0.18, { BackgroundColor3 = Palette.CardActive })
                    tween(cardStroke, 0.18, { Color = Palette.CardActiveBorder })
                    tween(dot, 0.18, { BackgroundColor3 = Palette.AccentWhite })
                    tween(nameLabel, 0.18, { TextColor3 = Palette.TextPrimary })
                    tween(pill, 0.18, { BackgroundColor3 = Palette.PillOn })
                    tween(pillStroke, 0.18, { Color = Palette.PillOn })
                    tween(knob, 0.18, { Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Palette.KnobOn })
                else
                    tween(modCard, 0.18, { BackgroundColor3 = Palette.CardBg })
                    tween(cardStroke, 0.18, { Color = Palette.CardBorder })
                    tween(dot, 0.18, { BackgroundColor3 = Palette.TextDim })
                    tween(nameLabel, 0.18, { TextColor3 = Palette.TextSecondary })
                    tween(pill, 0.18, { BackgroundColor3 = Palette.PillOff })
                    tween(pillStroke, 0.18, { Color = Palette.PillOffBorder })
                    tween(knob, 0.18, { Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Palette.KnobOff })
                end

                if options.Callback then
                    pcall(options.Callback, state)
                end
            end

            hit.MouseButton1Click:Connect(function()
                updateToggle(not state)
            end)

            local ToggleObj = {
                Set = function(self, val: boolean)
                    updateToggle(val)
                end,
                CurrentValue = function() return state end,
            }

            return ToggleObj
        end

        function TabObj:CreateButton(options: { Name: string, Callback: () -> () })
            local btnCard = Instance.new("TextButton")
            btnCard.Name = options.Name .. "_Btn"
            btnCard.Size = UDim2.new(1, 0, 0, 38)
            btnCard.BackgroundColor3 = Palette.CardBg
            btnCard.BackgroundTransparency = 0.18
            btnCard.BorderSizePixel = 0
            btnCard.Text = ""
            btnCard.AutoButtonColor = false
            btnCard.ZIndex = 13
            btnCard.Parent = page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = btnCard

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Thickness = 1
            cardStroke.Color = Palette.CardBorder
            cardStroke.Parent = btnCard

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -24, 1, 0)
            label.Position = UDim2.new(0, 14, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = options.Name
            label.TextColor3 = Palette.TextPrimary
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 14
            label.Parent = btnCard

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -28, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = ">"
            arrow.TextColor3 = Palette.TextDim
            arrow.TextSize = 12
            arrow.Font = Enum.Font.GothamBold
            arrow.ZIndex = 14
            arrow.Parent = btnCard

            btnCard.MouseEnter:Connect(function()
                tween(btnCard, 0.15, { BackgroundColor3 = Palette.CardHover, BackgroundTransparency = 0.1 })
                tween(arrow, 0.15, { TextColor3 = Palette.TextPrimary })
            end)
            btnCard.MouseLeave:Connect(function()
                tween(btnCard, 0.15, { BackgroundColor3 = Palette.CardBg, BackgroundTransparency = 0.18 })
                tween(arrow, 0.15, { TextColor3 = Palette.TextDim })
            end)
            btnCard.MouseButton1Click:Connect(function()
                tween(btnCard, 0.1, { BackgroundColor3 = Palette.CardActiveBorder })
                task.delay(0.12, function()
                    tween(btnCard, 0.15, { BackgroundColor3 = Palette.CardBg })
                end)
                if options.Callback then
                    pcall(options.Callback)
                end
            end)

            return btnCard
        end

        function TabObj:CreateSlider(options: { Name: string, Range: { number }, Increment: number?, CurrentValue: number?, Suffix: string?, Flag: string?, Callback: (number) -> () })
            local minVal = options.Range[1] or 0
            local maxVal = options.Range[2] or 100
            local inc = options.Increment or 1
            local suffix = options.Suffix or ""
            local current = options.CurrentValue or minVal
            if options.Flag then HoodUI.Flags[options.Flag] = current end

            local sliderCard = Instance.new("Frame")
            sliderCard.Name = options.Name .. "_Slider"
            sliderCard.Size = UDim2.new(1, 0, 0, 52)
            sliderCard.BackgroundColor3 = Palette.CardBg
            sliderCard.BackgroundTransparency = 0.18
            sliderCard.BorderSizePixel = 0
            sliderCard.ZIndex = 13
            sliderCard.Parent = page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = sliderCard

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Thickness = 1
            cardStroke.Color = Palette.CardBorder
            cardStroke.Parent = sliderCard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -90, 0, 20)
            nameLabel.Position = UDim2.new(0, 14, 0, 8)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextPrimary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 14
            nameLabel.Parent = sliderCard

            local valLabel = Instance.new("TextLabel")
            valLabel.Size = UDim2.new(0, 70, 0, 20)
            valLabel.Position = UDim2.new(1, -84, 0, 8)
            valLabel.BackgroundTransparency = 1
            valLabel.Text = tostring(current) .. suffix
            valLabel.TextColor3 = Palette.TextMuted
            valLabel.TextSize = 12
            valLabel.Font = Enum.Font.GothamBold
            valLabel.TextXAlignment = Enum.TextXAlignment.Right
            valLabel.ZIndex = 14
            valLabel.Parent = sliderCard

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -28, 0, 4)
            track.Position = UDim2.new(0, 14, 0, 36)
            track.BackgroundColor3 = Palette.PillOff
            track.BorderSizePixel = 0
            track.ZIndex = 14
            track.Parent = sliderCard

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = track

            local pct = math.clamp((current - minVal) / (maxVal - minVal), 0, 1)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(pct, 0, 1, 0)
            fill.BackgroundColor3 = Palette.AccentWhite
            fill.BorderSizePixel = 0
            fill.ZIndex = 15
            fill.Parent = track

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 10, 0, 10)
            knob.Position = UDim2.new(pct, -5, 0.5, -5)
            knob.BackgroundColor3 = Palette.AccentWhite
            knob.BorderSizePixel = 0
            knob.ZIndex = 16
            knob.Parent = track

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local isSliding = false

            local function applyValue(rawVal: number)
                local snapped = math.floor((rawVal - minVal) / inc + 0.5) * inc + minVal
                snapped = math.clamp(snapped, minVal, maxVal)
                current = snapped
                if options.Flag then HoodUI.Flags[options.Flag] = current end

                valLabel.Text = tostring(current) .. suffix
                local newPct = math.clamp((current - minVal) / (maxVal - minVal), 0, 1)
                tween(fill, 0.08, { Size = UDim2.new(newPct, 0, 1, 0) })
                tween(knob, 0.08, { Position = UDim2.new(newPct, -5, 0.5, -5) })

                if options.Callback then
                    pcall(options.Callback, current)
                end
            end

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 0, 20)
            hit.Position = UDim2.new(0, 0, 0, 28)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 17
            hit.Parent = sliderCard

            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isSliding = true
                    local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    applyValue(minVal + rel * (maxVal - minVal))
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isSliding = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    applyValue(minVal + rel * (maxVal - minVal))
                end
            end)

            local SliderObj = {
                Set = function(self, val: number)
                    applyValue(val)
                end,
                CurrentValue = function() return current end,
            }

            return SliderObj
        end

        function TabObj:CreateDropdown(options: { Name: string, Options: { string }, CurrentOption: { string } | string?, Flag: string?, Callback: (string) -> () })
            local list = options.Options or {}
            local current = ""
            if typeof(options.CurrentOption) == "table" then
                current = options.CurrentOption[1] or (list[1] or "")
            elseif typeof(options.CurrentOption) == "string" then
                current = options.CurrentOption
            else
                current = list[1] or ""
            end
            if options.Flag then HoodUI.Flags[options.Flag] = current end

            local dropCard = Instance.new("Frame")
            dropCard.Name = options.Name .. "_Dropdown"
            dropCard.Size = UDim2.new(1, 0, 0, 44)
            dropCard.BackgroundColor3 = Palette.CardBg
            dropCard.BackgroundTransparency = 0.18
            dropCard.BorderSizePixel = 0
            dropCard.ClipsDescendants = true
            dropCard.ZIndex = 13
            dropCard.Parent = page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = dropCard

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Thickness = 1
            cardStroke.Color = Palette.CardBorder
            cardStroke.Parent = dropCard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.5, -14, 0, 44)
            nameLabel.Position = UDim2.new(0, 14, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextPrimary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 14
            nameLabel.Parent = dropCard

            local dropBtn = Instance.new("TextButton")
            dropBtn.Size = UDim2.new(0.46, 0, 0, 28)
            dropBtn.Position = UDim2.new(0.52, 0, 0, 8)
            dropBtn.BackgroundColor3 = Palette.InputBg
            dropBtn.BackgroundTransparency = 0.2
            dropBtn.BorderSizePixel = 0
            dropBtn.Text = current .. "  v"
            dropBtn.TextColor3 = Palette.TextSecondary
            dropBtn.TextSize = 11
            dropBtn.Font = Enum.Font.GothamBold
            dropBtn.ZIndex = 14
            dropBtn.Parent = dropCard

            local dropBtnCorner = Instance.new("UICorner")
            dropBtnCorner.CornerRadius = UDim.new(0, 6)
            dropBtnCorner.Parent = dropBtn

            local dropBtnStroke = Instance.new("UIStroke")
            dropBtnStroke.Thickness = 1
            dropBtnStroke.Color = Palette.InputBorder
            dropBtnStroke.Parent = dropBtn

            local listHolder = Instance.new("Frame")
            listHolder.Size = UDim2.new(1, -28, 0, #list * 28 + 6)
            listHolder.Position = UDim2.new(0, 14, 0, 46)
            listHolder.BackgroundTransparency = 1
            listHolder.ZIndex = 14
            listHolder.Parent = dropCard

            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 4)
            listLayout.Parent = listHolder

            local isExpanded = false

            local function toggleExpand()
                isExpanded = not isExpanded
                if isExpanded then
                    local targetH = 48 + (#list * 32)
                    tween(dropCard, 0.2, { Size = UDim2.new(1, 0, 0, targetH) })
                    dropBtn.Text = current .. "  ^"
                else
                    tween(dropCard, 0.2, { Size = UDim2.new(1, 0, 0, 44) })
                    dropBtn.Text = current .. "  v"
                end
            end

            dropBtn.MouseButton1Click:Connect(toggleExpand)

            for _, opt in ipairs(list) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3 = (opt == current) and Palette.CardActive or Palette.InputBg
                optBtn.BackgroundTransparency = 0.2
                optBtn.BorderSizePixel = 0
                optBtn.Text = "  " .. opt
                optBtn.TextColor3 = (opt == current) and Palette.TextPrimary or Palette.TextMuted
                optBtn.TextSize = 11
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                optBtn.ZIndex = 15
                optBtn.Parent = listHolder

                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 4)
                optCorner.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    current = opt
                    if options.Flag then HoodUI.Flags[options.Flag] = current end
                    dropBtn.Text = current .. "  v"
                    toggleExpand()

                    for _, c in ipairs(listHolder:GetChildren()) do
                        if c:IsA("TextButton") then
                            c.TextColor3 = Palette.TextMuted
                            c.BackgroundColor3 = Palette.InputBg
                        end
                    end
                    optBtn.TextColor3 = Palette.TextPrimary
                    optBtn.BackgroundColor3 = Palette.CardActive

                    if options.Callback then
                        pcall(options.Callback, current)
                    end
                end)
            end

            local DropObj = {
                Set = function(self, opt: string)
                    current = opt
                    if options.Flag then HoodUI.Flags[options.Flag] = current end
                    dropBtn.Text = current .. "  v"
                    if options.Callback then pcall(options.Callback, current) end
                end,
                CurrentOption = function() return current end,
            }

            return DropObj
        end

        function TabObj:CreateInput(options: { Name: string, PlaceholderText: string?, Flag: string?, Callback: (string) -> () })
            local inCard = Instance.new("Frame")
            inCard.Name = options.Name .. "_Input"
            inCard.Size = UDim2.new(1, 0, 0, 44)
            inCard.BackgroundColor3 = Palette.CardBg
            inCard.BackgroundTransparency = 0.18
            inCard.BorderSizePixel = 0
            inCard.ZIndex = 13
            inCard.Parent = page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = inCard

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Thickness = 1
            cardStroke.Color = Palette.CardBorder
            cardStroke.Parent = inCard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.4, -14, 1, 0)
            nameLabel.Position = UDim2.new(0, 14, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextPrimary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 14
            nameLabel.Parent = inCard

            local tb = Instance.new("TextBox")
            tb.Size = UDim2.new(0.56, 0, 0, 28)
            tb.Position = UDim2.new(0.42, 0, 0.5, -14)
            tb.BackgroundColor3 = Palette.InputBg
            tb.BackgroundTransparency = 0.2
            tb.BorderSizePixel = 0
            tb.PlaceholderText = options.PlaceholderText or "Type here..."
            tb.PlaceholderColor3 = Palette.TextDim
            tb.Text = ""
            tb.TextColor3 = Palette.TextPrimary
            tb.TextSize = 12
            tb.Font = Enum.Font.Gotham
            tb.ClearTextOnFocus = false
            tb.ZIndex = 14
            tb.Parent = inCard

            local tbCorner = Instance.new("UICorner")
            tbCorner.CornerRadius = UDim.new(0, 6)
            tbCorner.Parent = tb

            local tbStroke = Instance.new("UIStroke")
            tbStroke.Thickness = 1
            tbStroke.Color = Palette.InputBorder
            tbStroke.Parent = tb

            tb.Focused:Connect(function()
                tween(tbStroke, 0.15, { Color = Palette.InputFocus })
            end)
            tb.FocusLost:Connect(function()
                tween(tbStroke, 0.15, { Color = Palette.InputBorder })
                if options.Flag then HoodUI.Flags[options.Flag] = tb.Text end
                if options.Callback then
                    pcall(options.Callback, tb.Text)
                end
            end)

            return inCard
        end

        function TabObj:CreateKeybind(options: { Name: string, CurrentKeybind: string?, Flag: string?, Callback: (string) -> () })
            local currentKey = options.CurrentKeybind or "None"
            if options.Flag then HoodUI.Flags[options.Flag] = currentKey end

            local kbFrame = Instance.new("Frame")
            kbFrame.Name = options.Name .. "_Keybind"
            kbFrame.Size = UDim2.new(1, 0, 0, 44)
            kbFrame.BackgroundColor3 = Palette.CardBg
            kbFrame.BackgroundTransparency = 0.18
            kbFrame.BorderSizePixel = 0
            kbFrame.ZIndex = 13
            kbFrame.Parent = page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = kbFrame

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Thickness = 1
            cardStroke.Color = Palette.CardBorder
            cardStroke.Parent = kbFrame

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -90, 1, 0)
            nameLabel.Position = UDim2.new(0, 14, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = Palette.TextPrimary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 14
            nameLabel.Parent = kbFrame

            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.new(0, 64, 0, 24)
            keyBtn.Position = UDim2.new(1, -78, 0.5, -12)
            keyBtn.BackgroundColor3 = Palette.InputBg
            keyBtn.BackgroundTransparency = 0.2
            keyBtn.BorderSizePixel = 0
            keyBtn.Text = currentKey:upper()
            keyBtn.TextColor3 = Palette.AccentGray
            keyBtn.TextSize = 11
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.ZIndex = 14
            keyBtn.Parent = kbFrame

            local keyCorner = Instance.new("UICorner")
            keyCorner.CornerRadius = UDim.new(0, 5)
            keyCorner.Parent = keyBtn

            local keyStroke = Instance.new("UIStroke")
            keyStroke.Thickness = 1
            keyStroke.Color = Palette.InputBorder
            keyStroke.Parent = keyBtn

            local isWaiting = false
            keyBtn.MouseButton1Click:Connect(function()
                isWaiting = true
                keyBtn.Text = "..."
                keyBtn.BackgroundColor3 = Palette.CardActiveBorder
                keyBtn.TextColor3 = Palette.TextPrimary
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
                        keyBtn.TextColor3 = Palette.AccentGray

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
