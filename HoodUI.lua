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

local Palette = {
    BlackOverlay = Color3.fromRGB(0, 0, 0),
    WindowBg = Color3.fromRGB(11, 11, 14),
    WindowBorder = Color3.fromRGB(26, 26, 32),
    HeaderBg = Color3.fromRGB(14, 14, 18),
    HeaderBorder = Color3.fromRGB(22, 22, 28),
    SidebarBg = Color3.fromRGB(13, 13, 16),
    SidebarBorder = Color3.fromRGB(22, 22, 28),
    CardBg = Color3.fromRGB(17, 17, 22),
    CardHover = Color3.fromRGB(22, 22, 28),
    CardBorder = Color3.fromRGB(28, 28, 36),
    CardActive = Color3.fromRGB(24, 24, 32),
    CardActiveBorder = Color3.fromRGB(48, 48, 62),
    InputBg = Color3.fromRGB(9, 9, 12),
    InputBorder = Color3.fromRGB(28, 28, 36),
    InputFocus = Color3.fromRGB(54, 54, 70),
    PillOff = Color3.fromRGB(24, 24, 30),
    PillOn = Color3.fromRGB(235, 235, 245),
    KnobOff = Color3.fromRGB(80, 80, 95),
    KnobOn = Color3.fromRGB(15, 15, 20),
    AccentWhite = Color3.fromRGB(245, 245, 250),
    AccentGray = Color3.fromRGB(180, 180, 195),
    TextPrimary = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(145, 145, 160),
    TextMuted = Color3.fromRGB(85, 85, 100),
    TextDim = Color3.fromRGB(55, 55, 68),
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
    overlay.BackgroundColor3 = Palette.BlackOverlay
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 1
    overlay.Active = true
    overlay.Parent = sg

    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "Notifications"
    notifFrame.Size = UDim2.new(0, 300, 1, -40)
    notifFrame.Position = UDim2.new(1, -320, 0, 20)
    notifFrame.BackgroundTransparency = 1
    notifFrame.BorderSizePixel = 0
    notifFrame.ZIndex = 100
    notifFrame.Parent = sg

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = notifFrame

    HoodUI.ScreenGui = sg
    HoodUI.DarkenOverlay = overlay
    HoodUI.NotifyContainer = notifFrame

    return sg
end

function HoodUI:SetGuiOpen(isOpen: boolean)
    self.IsGuiOpen = isOpen
    ensureScreenGui()

    if isOpen then
        self.DarkenOverlay.Visible = true
        tween(self.DarkenOverlay, 0.2, { BackgroundTransparency = 0.3 })
    else
        local t = tween(self.DarkenOverlay, 0.2, { BackgroundTransparency = 1 })
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
    local duration = options.Duration or 3.5

    local card = Instance.new("Frame")
    card.Name = "NotifCard"
    card.Size = UDim2.new(1, 0, 0, 62)
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
    contentLabel.Size = UDim2.new(1, -24, 0, 26)
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
    tween(card, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
    tween(bar, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if card and card.Parent then
            local exit = tween(card, 0.25, { Position = UDim2.new(1, 100, 0, 0), BackgroundTransparency = 1 })
            exit.Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

function HoodUI:CreateWindow(options: { Name: string?, ToggleKey: Enum.KeyCode?, Width: number?, Height: number? })
    ensureScreenGui()
    options = options or {}

    local toggleKeyCode = options.ToggleKey or Enum.KeyCode.RightControl
    local winWidth = options.Width or 740
    local winHeight = options.Height or 470

    local winFrame = Instance.new("Frame")
    winFrame.Name = "HoodWindow"
    winFrame.Size = UDim2.new(0, winWidth, 0, winHeight)
    winFrame.Position = UDim2.new(0.5, -winWidth / 2, 0.5, -winHeight / 2)
    winFrame.BackgroundColor3 = Palette.WindowBg
    winFrame.BorderSizePixel = 0
    winFrame.ZIndex = 10
    winFrame.Parent = HoodUI.ScreenGui

    local winCorner = Instance.new("UICorner")
    winCorner.CornerRadius = UDim.new(0, 10)
    winCorner.Parent = winFrame

    local winStroke = Instance.new("UIStroke")
    winStroke.Thickness = 1
    winStroke.Color = Palette.WindowBorder
    winStroke.Parent = winFrame

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Palette.HeaderBg
    header.BorderSizePixel = 0
    header.ZIndex = 11
    header.Parent = winFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = Palette.HeaderBorder
    headerLine.BorderSizePixel = 0
    headerLine.ZIndex = 12
    headerLine.Parent = header

    local logoLabel = Instance.new("TextLabel")
    logoLabel.Size = UDim2.new(0, 70, 0, 24)
    logoLabel.Position = UDim2.new(0, 18, 0.5, -12)
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = options.Name or "HOOD"
    logoLabel.TextColor3 = Palette.TextPrimary
    logoLabel.TextSize = 16
    logoLabel.Font = Enum.Font.GothamBold
    logoLabel.TextXAlignment = Enum.TextXAlignment.Left
    logoLabel.ZIndex = 13
    logoLabel.Parent = header

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 32, 0, 18)
    badge.Position = UDim2.new(0, 78, 0.5, -9)
    badge.BackgroundColor3 = Palette.CardActiveBorder
    badge.Text = "v4.0"
    badge.TextColor3 = Palette.AccentGray
    badge.TextSize = 10
    badge.Font = Enum.Font.GothamBold
    badge.ZIndex = 13
    badge.Parent = header

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 4)
    badgeCorner.Parent = badge

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -12)
    closeBtn.BackgroundColor3 = Palette.CardBg
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
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 11
    sidebar.Parent = body

    local sideDivider = Instance.new("Frame")
    sideDivider.Size = UDim2.new(0, 1, 1, 0)
    sideDivider.Position = UDim2.new(1, -1, 0, 0)
    sideDivider.BackgroundColor3 = Palette.SidebarBorder
    sideDivider.BorderSizePixel = 0
    sideDivider.ZIndex = 12
    sideDivider.Parent = sidebar

    local catList = Instance.new("ScrollingFrame")
    catList.Name = "CategoryList"
    catList.Size = UDim2.new(1, -16, 1, -20)
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

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -170, 1, -12)
    contentArea.Position = UDim2.new(0, 166, 0, 6)
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
        page.Size = UDim2.new(1, -8, 1, -4)
        page.Position = UDim2.new(0, 4, 0, 2)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Palette.CardActiveBorder
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
        activeBar.Size = UDim2.new(0, 3, 0.6, 0)
        activeBar.Position = UDim2.new(0, 2, 0.2, 0)
        activeBar.BackgroundColor3 = Palette.AccentWhite
        activeBar.BorderSizePixel = 0
        activeBar.Visible = false
        activeBar.ZIndex = 14
        activeBar.Parent = tabBtn

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 1)
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
                other.Button.BackgroundColor3 = Palette.SidebarBg
            end
            page.Visible = true
            activeBar.Visible = true
            tabBtn.TextColor3 = Palette.TextPrimary
            tabBtn.BackgroundColor3 = Palette.CardBg
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
            modCard.Size = UDim2.new(1, 0, 0, 42)
            modCard.BackgroundColor3 = state and Palette.CardActive or Palette.CardBg
            modCard.BorderSizePixel = 0
            modCard.ZIndex = 14
            modCard.Parent = page

            local modCorner = Instance.new("UICorner")
            modCorner.CornerRadius = UDim.new(0, 6)
            modCorner.Parent = modCard

            local modStroke = Instance.new("UIStroke")
            modStroke.Thickness = 1
            modStroke.Color = state and Palette.CardActiveBorder or Palette.CardBorder
            modStroke.Parent = modCard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 160, 1, 0)
            nameLabel.Position = UDim2.new(0, 14, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = options.Name
            nameLabel.TextColor3 = state and Palette.TextPrimary or Palette.TextSecondary
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 15
            nameLabel.Parent = modCard

            local subText = options.Subtitle or ""
            local subLabel = Instance.new("TextLabel")
            subLabel.Size = UDim2.new(1, -240, 1, 0)
            subLabel.Position = UDim2.new(0, 180, 0, 0)
            subLabel.BackgroundTransparency = 1
            subLabel.Text = subText
            subLabel.TextColor3 = Palette.TextMuted
            subLabel.TextSize = 11
            subLabel.Font = Enum.Font.Gotham
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.ZIndex = 15
            subLabel.Parent = modCard

            local pill = Instance.new("Frame")
            pill.Size = UDim2.new(0, 34, 0, 18)
            pill.Position = UDim2.new(1, -48, 0.5, -9)
            pill.BackgroundColor3 = state and Palette.PillOn or Palette.PillOff
            pill.BorderSizePixel = 0
            pill.ZIndex = 15
            pill.Parent = modCard

            local pillCorner = Instance.new("UICorner")
            pillCorner.CornerRadius = UDim.new(1, 0)
            pillCorner.Parent = pill

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            knob.BackgroundColor3 = state and Palette.KnobOn or Palette.KnobOff
            knob.BorderSizePixel = 0
            knob.ZIndex = 16
            knob.Parent = pill

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 16
            hit.Parent = modCard

            local function setToggle(newVal: boolean)
                state = newVal
                if options.Flag then HoodUI.Flags[options.Flag] = state end

                local targetCardBg = state and Palette.CardActive or Palette.CardBg
                local targetStroke = state and Palette.CardActiveBorder or Palette.CardBorder
                local targetPillBg = state and Palette.PillOn or Palette.PillOff
                local targetKnobPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                local targetKnobCol = state and Palette.KnobOn or Palette.KnobOff

                tween(modCard, 0.16, { BackgroundColor3 = targetCardBg })
                tween(modStroke, 0.16, { Color = targetStroke })
                tween(pill, 0.16, { BackgroundColor3 = targetPillBg })
                tween(knob, 0.16, { Position = targetKnobPos, BackgroundColor3 = targetKnobCol })

                nameLabel.TextColor3 = state and Palette.TextPrimary or Palette.TextSecondary

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
            sldFrame.Size = UDim2.new(1, 0, 0, 42)
            sldFrame.BackgroundColor3 = Palette.CardBg
            sldFrame.BorderSizePixel = 0
            sldFrame.ZIndex = 14
            sldFrame.Parent = page

            local sldCorner = Instance.new("UICorner")
            sldCorner.CornerRadius = UDim.new(0, 6)
            sldCorner.Parent = sldFrame

            local sldStroke = Instance.new("UIStroke")
            sldStroke.Thickness = 1
            sldStroke.Color = Palette.CardBorder
            sldStroke.Parent = sldFrame

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
            nameLabel.Parent = sldFrame

            local valLabel = Instance.new("TextLabel")
            valLabel.Size = UDim2.new(0, 70, 1, 0)
            valLabel.Position = UDim2.new(1, -84, 0, 0)
            valLabel.BackgroundTransparency = 1
            valLabel.Text = tostring(curVal) .. suffix
            valLabel.TextColor3 = Palette.AccentGray
            valLabel.TextSize = 12
            valLabel.Font = Enum.Font.GothamBold
            valLabel.TextXAlignment = Enum.TextXAlignment.Right
            valLabel.ZIndex = 15
            valLabel.Parent = sldFrame

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -270, 0, 4)
            track.Position = UDim2.new(0, 180, 0.5, -2)
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
            fill.BackgroundColor3 = Palette.AccentWhite
            fill.BorderSizePixel = 0
            fill.ZIndex = 16
            fill.Parent = track

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 0, 26)
            hit.Position = UDim2.new(0, 0, 0.5, -13)
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
            dropFrame.Size = UDim2.new(1, 0, 0, 42)
            dropFrame.BackgroundColor3 = Palette.CardBg
            dropFrame.BorderSizePixel = 0
            dropFrame.ClipsDescendants = true
            dropFrame.ZIndex = 14
            dropFrame.Parent = page

            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 6)
            dropCorner.Parent = dropFrame

            local dropStroke = Instance.new("UIStroke")
            dropStroke.Thickness = 1
            dropStroke.Color = Palette.CardBorder
            dropStroke.Parent = dropFrame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(0, 160, 0, 42)
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
            selectedLabel.Size = UDim2.new(0, 120, 0, 42)
            selectedLabel.Position = UDim2.new(1, -140, 0, 0)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = table.concat(curOption, ", ")
            selectedLabel.TextColor3 = Palette.AccentGray
            selectedLabel.TextSize = 12
            selectedLabel.Font = Enum.Font.GothamMedium
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            selectedLabel.ZIndex = 15
            selectedLabel.Parent = dropFrame

            local headerHit = Instance.new("TextButton")
            headerHit.Size = UDim2.new(1, 0, 0, 42)
            headerHit.BackgroundTransparency = 1
            headerHit.Text = ""
            headerHit.ZIndex = 16
            headerHit.Parent = dropFrame

            local optContainer = Instance.new("Frame")
            optContainer.Size = UDim2.new(1, -28, 0, #options.Options * 26)
            optContainer.Position = UDim2.new(0, 14, 0, 44)
            optContainer.BackgroundTransparency = 1
            optContainer.ZIndex = 15
            optContainer.Parent = dropFrame

            local optLayout = Instance.new("UIListLayout")
            optLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optLayout.Padding = UDim.new(0, 2)
            optLayout.Parent = optContainer

            local isOpen = false
            local expandedHeight = 46 + (#options.Options * 26) + 4

            for _, optName in ipairs(options.Options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 24)
                optBtn.BackgroundColor3 = Palette.InputBg
                optBtn.BorderSizePixel = 0
                optBtn.Text = "   " .. optName
                optBtn.TextColor3 = (optName == curOption[1]) and Palette.TextPrimary or Palette.TextMuted
                optBtn.TextSize = 11
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
                            child.TextColor3 = (child.Text == "   " .. optName) and Palette.TextPrimary or Palette.TextMuted
                        end
                    end

                    isOpen = false
                    tween(dropFrame, 0.16, { Size = UDim2.new(1, 0, 0, 42) })

                    if options.Callback then
                        pcall(options.Callback, curOption)
                    end
                end)
            end

            headerHit.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                tween(dropFrame, 0.16, { Size = isOpen and UDim2.new(1, 0, 0, expandedHeight) or UDim2.new(1, 0, 0, 42) })
            end)

            return dropFrame
        end

        function TabObj:CreateInput(options: { Name: string, PlaceholderText: string?, CurrentValue: string?, Flag: string?, Callback: (string) -> () })
            local curVal = options.CurrentValue or ""
            if options.Flag then HoodUI.Flags[options.Flag] = curVal end

            local inFrame = Instance.new("Frame")
            inFrame.Name = options.Name .. "_Input"
            inFrame.Size = UDim2.new(1, 0, 0, 42)
            inFrame.BackgroundColor3 = Palette.CardBg
            inFrame.BorderSizePixel = 0
            inFrame.ZIndex = 14
            inFrame.Parent = page

            local inCorner = Instance.new("UICorner")
            inCorner.CornerRadius = UDim.new(0, 6)
            inCorner.Parent = inFrame

            local inStroke = Instance.new("UIStroke")
            inStroke.Thickness = 1
            inStroke.Color = Palette.CardBorder
            inStroke.Parent = inFrame

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
            boxFrame.Size = UDim2.new(0, 130, 0, 24)
            boxFrame.Position = UDim2.new(1, -144, 0.5, -12)
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
            textBox.Size = UDim2.new(1, -10, 1, 0)
            textBox.Position = UDim2.new(0, 5, 0, 0)
            textBox.BackgroundTransparency = 1
            textBox.PlaceholderText = options.PlaceholderText or "Type..."
            textBox.PlaceholderColor3 = Palette.TextMuted
            textBox.Text = curVal
            textBox.TextColor3 = Palette.TextPrimary
            textBox.TextSize = 11
            textBox.Font = Enum.Font.Gotham
            textBox.ClearTextOnFocus = false
            textBox.ZIndex = 16
            textBox.Parent = boxFrame

            textBox.Focused:Connect(function()
                tween(boxStroke, 0.15, { Color = Palette.InputFocus })
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
            btnCard.Size = UDim2.new(1, 0, 0, 42)
            btnCard.BackgroundColor3 = Palette.CardBg
            btnCard.BorderSizePixel = 0
            btnCard.ZIndex = 14
            btnCard.Parent = page

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btnCard

            local btnStroke = Instance.new("UIStroke")
            btnStroke.Thickness = 1
            btnStroke.Color = Palette.CardBorder
            btnStroke.Parent = btnCard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -28, 1, 0)
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
                tween(btnCard, 0.15, { BackgroundColor3 = Palette.CardHover })
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
            kbFrame.Size = UDim2.new(1, 0, 0, 42)
            kbFrame.BackgroundColor3 = Palette.CardBg
            kbFrame.BorderSizePixel = 0
            kbFrame.ZIndex = 14
            kbFrame.Parent = page

            local kbCorner = Instance.new("UICorner")
            kbCorner.CornerRadius = UDim.new(0, 6)
            kbCorner.Parent = kbFrame

            local kbStroke = Instance.new("UIStroke")
            kbStroke.Thickness = 1
            kbStroke.Color = Palette.CardBorder
            kbStroke.Parent = kbFrame

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
            keyBtn.Size = UDim2.new(0, 50, 0, 22)
            keyBtn.Position = UDim2.new(1, -64, 0.5, -11)
            keyBtn.BackgroundColor3 = Palette.InputBg
            keyBtn.BorderSizePixel = 0
            keyBtn.Text = currentKey:upper()
            keyBtn.TextColor3 = Palette.AccentGray
            keyBtn.TextSize = 11
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.ZIndex = 15
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
