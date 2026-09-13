local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer

local function getDetectedExecutor()
    local name = "Unknown Executor"
    local ver = ""
    pcall(function()
        if type(identifyexecutor) == "function" then
            name, ver = identifyexecutor()
        elseif type(getexecutorname) == "function" then
            name = getexecutorname()
        end
    end)
    if ver and ver ~= "" then
        return tostring(name) .. " " .. tostring(ver)
    end
    return tostring(name)
end

local function getDetectedGameName()
    local gameName = "Universal"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = info.Name
        end
    end)
    return gameName
end

local TargetParent
local success = pcall(function()
    TargetParent = CoreGui
    local _ = CoreGui.Name
end)
if not success or not TargetParent then
    TargetParent = LocalPlayer:WaitForChild("PlayerGui")
end

local Library = {
    ToggleKey = Enum.KeyCode.RightControl,
    Open = true,
    Windows = {},
    Theme = {
        MainBg        = Color3.fromRGB(9, 10, 13),
        CardBg        = Color3.fromRGB(15, 16, 21),
        CardBorder    = Color3.fromRGB(25, 27, 35),
        BoxBg         = Color3.fromRGB(20, 22, 29),
        BoxBorder     = Color3.fromRGB(30, 33, 44),
        BoxChecked    = Color3.fromRGB(157, 123, 255),
        Accent        = Color3.fromRGB(157, 123, 255),
        SliderTrack   = Color3.fromRGB(28, 30, 40),
        SliderFill    = Color3.fromRGB(157, 123, 255),
        BtnBg         = Color3.fromRGB(18, 20, 27),
        BtnBorder     = Color3.fromRGB(28, 31, 41),
        BtnHover      = Color3.fromRGB(25, 28, 38),
        BtnPress      = Color3.fromRGB(32, 36, 48),
        BadgeBg       = Color3.fromRGB(18, 20, 27),
        BadgeBorder   = Color3.fromRGB(28, 31, 41),
        BadgeText     = Color3.fromRGB(95, 98, 115),
        TextWhite     = Color3.fromRGB(245, 246, 250),
        TextNormal    = Color3.fromRGB(145, 149, 165),
        TextMuted     = Color3.fromRGB(115, 119, 135),
        BorderDivider = Color3.fromRGB(22, 24, 32)
    }
}

local function tween(object, info, properties)
    local tw = TweenService:Create(object, info, properties)
    tw:Play()
    return tw
end

local function makeDraggable(topbar, main)
    local dragging = false
    local dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local GUI_NAME = "Wisper_UI_Exact"
local existingGui = TargetParent:FindFirstChild(GUI_NAME)
if existingGui then
    existingGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = TargetParent

local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 280, 1, -40)
ToastContainer.Position = UDim2.new(1, -300, 0, 20)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 1000
ToastContainer.Parent = ScreenGui

local ToastList = Instance.new("UIListLayout")
ToastList.SortOrder = Enum.SortOrder.LayoutOrder
ToastList.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastList.Padding = UDim.new(0, 8)
ToastList.Parent = ToastContainer

function Library:Notify(config)
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 3

    local Toast = Instance.new("Frame")
    Toast.Name = "Toast"
    Toast.Size = UDim2.new(1, 0, 0, 0)
    Toast.AutomaticSize = Enum.AutomaticSize.Y
    Toast.BackgroundColor3 = Library.Theme.CardBg
    Toast.BorderSizePixel = 0
    Toast.ClipsDescendants = true
    Toast.Parent = ToastContainer

    local ToastCorner = Instance.new("UICorner")
    ToastCorner.CornerRadius = UDim.new(0, 6)
    ToastCorner.Parent = Toast

    local ToastStroke = Instance.new("UIStroke")
    ToastStroke.Color = Library.Theme.CardBorder
    ToastStroke.Thickness = 1
    ToastStroke.Parent = Toast

    local ToastPadding = Instance.new("UIPadding")
    ToastPadding.PaddingTop = UDim.new(0, 10)
    ToastPadding.PaddingBottom = UDim.new(0, 12)
    ToastPadding.PaddingLeft = UDim.new(0, 12)
    ToastPadding.PaddingRight = UDim.new(0, 12)
    ToastPadding.Parent = Toast

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 18)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Library.Theme.TextWhite
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Toast

    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Size = UDim2.new(1, 0, 0, 0)
    ContentLabel.Position = UDim2.new(0, 0, 0, 20)
    ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Font = Enum.Font.Gotham
    ContentLabel.Text = content
    ContentLabel.TextColor3 = Library.Theme.TextNormal
    ContentLabel.TextSize = 12
    ContentLabel.TextWrapped = true
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.Parent = Toast

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(1, 0, 0, 2)
    ProgressBar.Position = UDim2.new(0, 0, 1, 8)
    ProgressBar.BackgroundColor3 = Library.Theme.Accent
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = Toast

    Toast.Position = UDim2.new(1, 50, 0, 0)
    Toast.BackgroundTransparency = 1
    TitleLabel.TextTransparency = 1
    ContentLabel.TextTransparency = 1

    tween(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0
    })
    tween(TitleLabel, TweenInfo.new(0.3), { TextTransparency = 0 })
    tween(ContentLabel, TweenInfo.new(0.3), { TextTransparency = 0 })
    tween(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })

    task.delay(duration, function()
        local tw = tween(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 50, 0, 0),
            BackgroundTransparency = 1
        })
        tween(TitleLabel, TweenInfo.new(0.2), { TextTransparency = 1 })
        tween(ContentLabel, TweenInfo.new(0.2), { TextTransparency = 1 })
        tw.Completed:Connect(function()
            Toast:Destroy()
        end)
    end)
end

function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "******"
    local windowSubtitle = config.Subtitle or getDetectedExecutor()
    local footerTitle = config.FooterTitle or "Vectra"
    local footerSubtitle = config.FooterSubtitle or getDetectedGameName()
    local windowSize = config.Size or UDim2.fromOffset(720, 460)
    local toggleKey = config.ToggleKey or Library.ToggleKey

    local Window = {
        Visible = true
    }

    local ShadowFrame = Instance.new("Frame")
    ShadowFrame.Name = "Shadow"
    ShadowFrame.Size = UDim2.new(windowSize.X.Scale, windowSize.X.Offset + 24, windowSize.Y.Scale, windowSize.Y.Offset + 24)
    ShadowFrame.Position = UDim2.new(0.5, -(windowSize.X.Offset + 24) / 2, 0.5, -(windowSize.Y.Offset + 24) / 2)
    ShadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ShadowFrame.BackgroundTransparency = 0.55
    ShadowFrame.BorderSizePixel = 0
    ShadowFrame.Parent = ScreenGui

    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 14)
    ShadowCorner.Parent = ShadowFrame

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "WisperWindow"
    MainFrame.Size = windowSize
    MainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2)
    MainFrame.BackgroundColor3 = Library.Theme.MainBg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Library.Theme.CardBorder
    MainStroke.Thickness = 1.2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
        ShadowFrame.Position = UDim2.new(
            MainFrame.Position.X.Scale,
            MainFrame.Position.X.Offset - 12,
            MainFrame.Position.Y.Scale,
            MainFrame.Position.Y.Offset - 12
        )
    end)
    MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
        ShadowFrame.Size = UDim2.new(
            MainFrame.Size.X.Scale,
            MainFrame.Size.X.Offset + 24,
            MainFrame.Size.Y.Scale,
            MainFrame.Size.Y.Offset + 24
        )
    end)

    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 48)
    Topbar.BackgroundColor3 = Library.Theme.MainBg
    Topbar.BorderSizePixel = 0
    Topbar.Parent = MainFrame

    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 10)
    TopbarCorner.Parent = Topbar

    local TopbarPatch = Instance.new("Frame")
    TopbarPatch.Name = "TopbarPatch"
    TopbarPatch.Size = UDim2.new(1, 0, 0, 10)
    TopbarPatch.Position = UDim2.new(0, 0, 1, -10)
    TopbarPatch.BackgroundColor3 = Library.Theme.MainBg
    TopbarPatch.BorderSizePixel = 0
    TopbarPatch.Parent = Topbar

    local targetUsername = (LocalPlayer and LocalPlayer.Name) or "User"
    local isTitleHovered = false
    local titleAnimThread = nil

    local TitleHitbox = Instance.new("TextButton")
    TitleHitbox.Name = "TitleInteractive"
    TitleHitbox.Size = UDim2.new(0, 200, 0, 18)
    TitleHitbox.Position = UDim2.new(0, 16, 0, 9)
    TitleHitbox.BackgroundTransparency = 1
    TitleHitbox.Text = ""
    TitleHitbox.AutoButtonColor = false
    TitleHitbox.Parent = Topbar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = windowTitle
    TitleLabel.TextColor3 = Library.Theme.TextWhite
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleHitbox

    local function animateTitleText(toText)
        if titleAnimThread then
            task.cancel(titleAnimThread)
            titleAnimThread = nil
        end
        titleAnimThread = task.spawn(function()
            local chars = "!@#$%&*?0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
            local len = #toText
            local steps = 10
            for i = 1, steps do
                local progress = i / steps
                local revealed = math.floor(progress * len)
                local str = string.sub(toText, 1, revealed)
                for _ = revealed + 1, len do
                    local r = math.random(1, #chars)
                    str = str .. string.sub(chars, r, r)
                end
                TitleLabel.Text = str
                task.wait(0.02)
            end
            TitleLabel.Text = toText
        end)
    end

    TitleHitbox.MouseEnter:Connect(function()
        isTitleHovered = true
        animateTitleText(targetUsername)
    end)

    TitleHitbox.MouseLeave:Connect(function()
        isTitleHovered = false
        animateTitleText(windowTitle)
    end)

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name = "Subtitle"
    SubtitleLabel.Size = UDim2.new(1, -32, 0, 14)
    SubtitleLabel.Position = UDim2.new(0, 16, 0, 27)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.Text = windowSubtitle
    SubtitleLabel.TextColor3 = Library.Theme.TextMuted
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = Topbar

    makeDraggable(Topbar, MainFrame)

    local FooterBar = Instance.new("Frame")
    FooterBar.Name = "FooterBar"
    FooterBar.Size = UDim2.new(1, 0, 0, 46)
    FooterBar.Position = UDim2.new(0, 0, 1, -46)
    FooterBar.BackgroundColor3 = Library.Theme.MainBg
    FooterBar.BorderSizePixel = 0
    FooterBar.Parent = MainFrame

    local FooterCorner = Instance.new("UICorner")
    FooterCorner.CornerRadius = UDim.new(0, 10)
    FooterCorner.Parent = FooterBar

    local FooterPatch = Instance.new("Frame")
    FooterPatch.Name = "FooterPatch"
    FooterPatch.Size = UDim2.new(1, 0, 0, 10)
    FooterPatch.Position = UDim2.new(0, 0, 0, 0)
    FooterPatch.BackgroundColor3 = Library.Theme.MainBg
    FooterPatch.BorderSizePixel = 0
    FooterPatch.Parent = FooterBar

    local FooterDivider = Instance.new("Frame")
    FooterDivider.Name = "Divider"
    FooterDivider.Size = UDim2.new(1, 0, 0, 1)
    FooterDivider.Position = UDim2.new(0, 0, 0, 0)
    FooterDivider.BackgroundColor3 = Library.Theme.BorderDivider
    FooterDivider.BorderSizePixel = 0
    FooterDivider.Parent = FooterBar

    local FootTitle = Instance.new("TextLabel")
    FootTitle.Name = "Title"
    FootTitle.Size = UDim2.new(1, -32, 0, 16)
    FootTitle.Position = UDim2.new(0, 16, 0, 7)
    FootTitle.BackgroundTransparency = 1
    FootTitle.Font = Enum.Font.GothamBold
    FootTitle.Text = footerTitle
    FootTitle.TextColor3 = Library.Theme.TextWhite
    FootTitle.TextSize = 13
    FootTitle.TextXAlignment = Enum.TextXAlignment.Left
    FootTitle.Parent = FooterBar

    local FootSubtitle = Instance.new("TextLabel")
    FootSubtitle.Name = "Subtitle"
    FootSubtitle.Size = UDim2.new(1, -32, 0, 14)
    FootSubtitle.Position = UDim2.new(0, 16, 0, 24)
    FootSubtitle.BackgroundTransparency = 1
    FootSubtitle.Font = Enum.Font.Gotham
    FootSubtitle.Text = footerSubtitle
    FootSubtitle.TextColor3 = Library.Theme.TextMuted
    FootSubtitle.TextSize = 11
    FootSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    FootSubtitle.Parent = FooterBar

    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Size = UDim2.new(1, -32, 1, -94)
    ContentScroll.Position = UDim2.new(0, 16, 0, 48)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 0
    ContentScroll.VerticalScrollBarInset = Enum.ScrollBarInset.None
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentScroll.Parent = MainFrame

    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 4)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.Parent = ContentScroll

    local LeftColumn = Instance.new("Frame")
    LeftColumn.Name = "LeftColumn"
    LeftColumn.Size = UDim2.new(0.5, -5, 0, 0)
    LeftColumn.Position = UDim2.new(0, 0, 0, 0)
    LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
    LeftColumn.BackgroundTransparency = 1
    LeftColumn.Parent = ContentScroll

    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Padding = UDim.new(0, 10)
    LeftLayout.Parent = LeftColumn

    local RightColumn = Instance.new("Frame")
    RightColumn.Name = "RightColumn"
    RightColumn.Size = UDim2.new(0.5, -5, 0, 0)
    RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
    RightColumn.AutomaticSize = Enum.AutomaticSize.Y
    RightColumn.BackgroundTransparency = 1
    RightColumn.Parent = ContentScroll

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 10)
    RightLayout.Parent = RightColumn

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            Window.Visible = not Window.Visible
            MainFrame.Visible = Window.Visible
            ShadowFrame.Visible = Window.Visible
        end
    end)

    local function buildSection(sectionConfig, optionalSide)
        local sectionName = "Section"
        local side = "Left"

        if type(sectionConfig) == "table" then
            sectionName = sectionConfig.Name or "Section"
            side = sectionConfig.Side or optionalSide or "Left"
        elseif type(sectionConfig) == "string" then
            sectionName = sectionConfig
            side = optionalSide or "Left"
        end

        local targetColumn = LeftColumn
        if string.lower(tostring(side)) == "right" then
            targetColumn = RightColumn
        end

        local Section = {
            Name = sectionName
        }

        local SectionCard = Instance.new("Frame")
        SectionCard.Name = "SectionCard_" .. sectionName
        SectionCard.Size = UDim2.new(1, 0, 0, 0)
        SectionCard.AutomaticSize = Enum.AutomaticSize.Y
        SectionCard.BackgroundColor3 = Library.Theme.CardBg
        SectionCard.BorderSizePixel = 0
        SectionCard.ClipsDescendants = false
        SectionCard.Parent = targetColumn

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 8)
        CardCorner.Parent = SectionCard

        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Library.Theme.CardBorder
        CardStroke.Thickness = 1
        CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        CardStroke.Parent = SectionCard

        local CardPadding = Instance.new("UIPadding")
        CardPadding.PaddingTop = UDim.new(0, 12)
        CardPadding.PaddingBottom = UDim.new(0, 14)
        CardPadding.PaddingLeft = UDim.new(0, 12)
        CardPadding.PaddingRight = UDim.new(0, 12)
        CardPadding.Parent = SectionCard

        local CardLayout = Instance.new("UIListLayout")
        CardLayout.SortOrder = Enum.SortOrder.LayoutOrder
        CardLayout.Padding = UDim.new(0, 9)
        CardLayout.Parent = SectionCard

        local HeaderTitle = Instance.new("TextLabel")
        HeaderTitle.Name = "Title"
        HeaderTitle.Size = UDim2.new(1, 0, 0, 18)
        HeaderTitle.BackgroundTransparency = 1
        HeaderTitle.Font = Enum.Font.GothamBold
        HeaderTitle.Text = sectionName
        HeaderTitle.TextColor3 = Library.Theme.TextWhite
        HeaderTitle.TextSize = 13
        HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
        HeaderTitle.LayoutOrder = 0
        HeaderTitle.Parent = SectionCard

        Section.Card = SectionCard

        function Section:CreateToggle(tglConfig)
            local tglName = tglConfig.Name or "Toggle"
            local default = tglConfig.Default or false
            local defaultKey = tglConfig.Keybind or nil
            local callback = tglConfig.Callback or function() end

            local state = default
            local currentKey = defaultKey
            local binding = false

            local ToggleRow = Instance.new("TextButton")
            ToggleRow.Name = "Toggle_" .. tglName
            ToggleRow.Size = UDim2.new(1, 0, 0, 20)
            ToggleRow.BackgroundTransparency = 1
            ToggleRow.AutoButtonColor = false
            ToggleRow.Text = ""
            ToggleRow.Parent = SectionCard

            local Checkbox = Instance.new("Frame")
            Checkbox.Name = "Checkbox"
            Checkbox.Size = UDim2.new(0, 16, 0, 16)
            Checkbox.Position = UDim2.new(0, 0, 0.5, -8)
            Checkbox.BackgroundColor3 = state and Library.Theme.BoxChecked or Library.Theme.BoxBg
            Checkbox.BorderSizePixel = 0
            Checkbox.Parent = ToggleRow

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = Checkbox

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = state and Library.Theme.BoxChecked or Library.Theme.BoxBorder
            BoxStroke.Thickness = 1
            BoxStroke.Parent = Checkbox

            local Checkmark = Instance.new("TextLabel")
            Checkmark.Name = "Mark"
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Font = Enum.Font.GothamBold
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
            Checkmark.TextSize = 11
            Checkmark.Visible = state
            Checkmark.Parent = Checkbox

            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 24, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamMedium
            Label.Text = tglName
            Label.TextColor3 = state and Library.Theme.TextWhite or Library.Theme.TextNormal
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleRow

            local KeybindBadge = Instance.new("TextButton")
            KeybindBadge.Name = "KeybindBadge"
            KeybindBadge.Size = UDim2.new(0, 42, 0, 18)
            KeybindBadge.Position = UDim2.new(1, -42, 0.5, -9)
            KeybindBadge.BackgroundColor3 = Library.Theme.BadgeBg
            KeybindBadge.Text = currentKey and currentKey.Name or "None"
            KeybindBadge.Font = Enum.Font.Gotham
            KeybindBadge.TextColor3 = Library.Theme.BadgeText
            KeybindBadge.TextSize = 10
            KeybindBadge.AutoButtonColor = false
            KeybindBadge.Parent = ToggleRow

            local BadgeCorner = Instance.new("UICorner")
            BadgeCorner.CornerRadius = UDim.new(0, 4)
            BadgeCorner.Parent = KeybindBadge

            local BadgeStroke = Instance.new("UIStroke")
            BadgeStroke.Color = Library.Theme.BadgeBorder
            BadgeStroke.Thickness = 1
            BadgeStroke.Parent = KeybindBadge

            local function updateState(newState)
                state = newState
                Checkmark.Visible = state
                if state then
                    tween(Checkbox, TweenInfo.new(0.12), { BackgroundColor3 = Library.Theme.BoxChecked })
                    tween(BoxStroke, TweenInfo.new(0.12), { Color = Library.Theme.BoxChecked })
                    tween(Label, TweenInfo.new(0.12), { TextColor3 = Library.Theme.TextWhite })
                else
                    tween(Checkbox, TweenInfo.new(0.12), { BackgroundColor3 = Library.Theme.BoxBg })
                    tween(BoxStroke, TweenInfo.new(0.12), { Color = Library.Theme.BoxBorder })
                    tween(Label, TweenInfo.new(0.12), { TextColor3 = Library.Theme.TextNormal })
                end
                pcall(callback, state)
            end

            ToggleRow.MouseButton1Click:Connect(function()
                if not binding then
                    updateState(not state)
                end
            end)

            KeybindBadge.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true
                KeybindBadge.Text = "..."
                tween(BadgeStroke, TweenInfo.new(0.15), { Color = Library.Theme.Accent })

                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then
                            currentKey = nil
                            KeybindBadge.Text = "None"
                        elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                            currentKey = input.KeyCode
                            KeybindBadge.Text = currentKey.Name
                        end
                        binding = false
                        tween(BadgeStroke, TweenInfo.new(0.15), { Color = Library.Theme.BadgeBorder })
                        connection:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if not processed and not binding and currentKey and input.KeyCode == currentKey then
                    updateState(not state)
                end
            end)

            return {
                Set = function(self, val)
                    updateState(val)
                end,
                Value = function(self)
                    return state
                end
            }
        end

        function Section:CreateSlider(sldConfig)
            local sldName = sldConfig.Name or "Slider"
            local min = sldConfig.Min or 0
            local max = sldConfig.Max or 100
            local default = math.clamp(sldConfig.Default or min, min, max)
            local suffix = sldConfig.Suffix or "%"
            local precision = sldConfig.Precision or 0
            local callback = sldConfig.Callback or function() end

            local value = default

            local SliderBox = Instance.new("Frame")
            SliderBox.Name = "Slider_" .. sldName
            SliderBox.Size = UDim2.new(1, 0, 0, 32)
            SliderBox.BackgroundTransparency = 1
            SliderBox.Parent = SectionCard

            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(1, -60, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamMedium
            Label.Text = sldName
            Label.TextColor3 = Library.Theme.TextNormal
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderBox

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "Value"
            ValueLabel.Size = UDim2.new(0, 50, 0, 16)
            ValueLabel.Position = UDim2.new(1, -50, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Text = tostring(value) .. suffix
            ValueLabel.TextColor3 = Library.Theme.TextWhite
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderBox

            local Track = Instance.new("Frame")
            Track.Name = "Track"
            Track.Size = UDim2.new(1, 0, 0, 5)
            Track.Position = UDim2.new(0, 0, 0, 21)
            Track.BackgroundColor3 = Library.Theme.SliderTrack
            Track.BorderSizePixel = 0
            Track.Parent = SliderBox

            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = Track

            local Fill = Instance.new("Frame")
            Fill.Name = "Fill"
            local initPercent = math.clamp((value - min) / (max - min), 0, 1)
            Fill.Size = UDim2.new(initPercent, 0, 1, 0)
            Fill.BackgroundColor3 = Library.Theme.SliderFill
            Fill.BorderSizePixel = 0
            Fill.Parent = Track

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill

            local Thumb = Instance.new("Frame")
            Thumb.Name = "Thumb"
            Thumb.Size = UDim2.new(0, 11, 0, 11)
            Thumb.Position = UDim2.new(initPercent, 0, 0.5, 0)
            Thumb.AnchorPoint = Vector2.new(initPercent, 0.5)
            Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Thumb.BorderSizePixel = 0
            Thumb.Parent = Track

            local ThumbCorner = Instance.new("UICorner")
            ThumbCorner.CornerRadius = UDim.new(1, 0)
            ThumbCorner.Parent = Thumb

            local dragging = false

            local function updateSlider(input)
                local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local rawVal = min + (max - min) * percent
                if precision == 0 then
                    value = math.floor(rawVal + 0.5)
                else
                    local mult = 10 ^ precision
                    value = math.floor(rawVal * mult + 0.5) / mult
                end

                local clampedPercent = math.clamp((value - min) / (max - min), 0, 1)
                tween(Fill, TweenInfo.new(0.04), { Size = UDim2.new(clampedPercent, 0, 1, 0) })
                Thumb.Position = UDim2.new(clampedPercent, 0, 0.5, 0)
                Thumb.AnchorPoint = Vector2.new(clampedPercent, 0.5)
                ValueLabel.Text = tostring(value) .. suffix
                pcall(callback, value)
            end

            local function startDrag(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end

            Track.InputBegan:Connect(startDrag)
            SliderBox.InputBegan:Connect(startDrag)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)

            return {
                Set = function(self, val)
                    value = math.clamp(val, min, max)
                    local p = (value - min) / (max - min)
                    tween(Fill, TweenInfo.new(0.1), { Size = UDim2.new(p, 0, 1, 0) })
                    Thumb.Position = UDim2.new(p, 0, 0.5, 0)
                    Thumb.AnchorPoint = Vector2.new(p, 0.5)
                    ValueLabel.Text = tostring(value) .. suffix
                    pcall(callback, value)
                end,
                Value = function(self)
                    return value
                end
            }
        end

        function Section:CreateButton(btnConfig)
            local btnName = (type(btnConfig) == "table" and btnConfig.Name) or btnConfig or "Button"
            local callback = (type(btnConfig) == "table" and btnConfig.Callback) or function() end

            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Name = "Button_" .. btnName
            ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
            ButtonFrame.BackgroundColor3 = Library.Theme.BtnBg
            ButtonFrame.AutoButtonColor = false
            ButtonFrame.Text = btnName
            ButtonFrame.Font = Enum.Font.GothamMedium
            ButtonFrame.TextColor3 = Library.Theme.TextNormal
            ButtonFrame.TextSize = 12
            ButtonFrame.Parent = SectionCard

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 5)
            BtnCorner.Parent = ButtonFrame

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Library.Theme.BtnBorder
            BtnStroke.Thickness = 1
            BtnStroke.Parent = ButtonFrame

            ButtonFrame.MouseEnter:Connect(function()
                tween(ButtonFrame, TweenInfo.new(0.12), { BackgroundColor3 = Library.Theme.BtnHover, TextColor3 = Library.Theme.TextWhite })
            end)

            ButtonFrame.MouseLeave:Connect(function()
                tween(ButtonFrame, TweenInfo.new(0.12), { BackgroundColor3 = Library.Theme.BtnBg, TextColor3 = Library.Theme.TextNormal })
            end)

            ButtonFrame.MouseButton1Down:Connect(function()
                tween(ButtonFrame, TweenInfo.new(0.06), { BackgroundColor3 = Library.Theme.BtnPress })
            end)

            ButtonFrame.MouseButton1Up:Connect(function()
                tween(ButtonFrame, TweenInfo.new(0.08), { BackgroundColor3 = Library.Theme.BtnHover })
            end)

            ButtonFrame.MouseButton1Click:Connect(function()
                pcall(callback)
            end)

            return ButtonFrame
        end

        function Section:CreateDropdown(drpConfig)
            local drpName = drpConfig.Name or "Dropdown"
            local options = drpConfig.Options or {}
            local default = drpConfig.Default or options[1] or "Select..."
            local callback = drpConfig.Callback or function() end

            local selected = default
            local expanded = false

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "Dropdown_" .. drpName
            DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
            DropdownFrame.BackgroundColor3 = Library.Theme.BtnBg
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = SectionCard

            local DrpCorner = Instance.new("UICorner")
            DrpCorner.CornerRadius = UDim.new(0, 5)
            DrpCorner.Parent = DropdownFrame

            local DrpStroke = Instance.new("UIStroke")
            DrpStroke.Color = Library.Theme.BtnBorder
            DrpStroke.Thickness = 1
            DrpStroke.Parent = DropdownFrame

            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Name = "Header"
            HeaderBtn.Size = UDim2.new(1, 0, 0, 30)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Text = ""
            HeaderBtn.Parent = DropdownFrame

            local DrpLabel = Instance.new("TextLabel")
            DrpLabel.Size = UDim2.new(1, -36, 1, 0)
            DrpLabel.Position = UDim2.new(0, 10, 0, 0)
            DrpLabel.BackgroundTransparency = 1
            DrpLabel.Font = Enum.Font.GothamMedium
            DrpLabel.Text = drpName .. ": " .. tostring(selected)
            DrpLabel.TextColor3 = Library.Theme.TextNormal
            DrpLabel.TextSize = 12
            DrpLabel.TextXAlignment = Enum.TextXAlignment.Left
            DrpLabel.Parent = HeaderBtn

            local ArrowLabel = Instance.new("TextLabel")
            ArrowLabel.Size = UDim2.new(0, 20, 1, 0)
            ArrowLabel.Position = UDim2.new(1, -24, 0, 0)
            ArrowLabel.BackgroundTransparency = 1
            ArrowLabel.Font = Enum.Font.GothamBold
            ArrowLabel.Text = "▼"
            ArrowLabel.TextColor3 = Library.Theme.BadgeText
            ArrowLabel.TextSize = 9
            ArrowLabel.Parent = HeaderBtn

            local OptionList = Instance.new("Frame")
            OptionList.Name = "OptionList"
            OptionList.Size = UDim2.new(1, -12, 0, #options * 24)
            OptionList.Position = UDim2.new(0, 6, 0, 32)
            OptionList.BackgroundTransparency = 1
            OptionList.Parent = DropdownFrame

            local OptionLayout = Instance.new("UIListLayout")
            OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionLayout.Padding = UDim.new(0, 2)
            OptionLayout.Parent = OptionList

            local function rebuildOptions()
                for _, child in ipairs(OptionList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Name = "Opt_" .. tostring(opt)
                    OptBtn.Size = UDim2.new(1, 0, 0, 22)
                    OptBtn.BackgroundColor3 = (opt == selected) and Library.Theme.BtnPress or Library.Theme.MainBg
                    OptBtn.Text = tostring(opt)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextColor3 = (opt == selected) and Library.Theme.TextWhite or Library.Theme.TextNormal
                    OptBtn.TextSize = 11
                    OptBtn.AutoButtonColor = false
                    OptBtn.Parent = OptionList

                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 4)
                    OptCorner.Parent = OptBtn

                    OptBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        DrpLabel.Text = drpName .. ": " .. tostring(selected)
                        expanded = false
                        ArrowLabel.Text = "▼"
                        tween(DropdownFrame, TweenInfo.new(0.18), { Size = UDim2.new(1, 0, 0, 30) })
                        rebuildOptions()
                        pcall(callback, selected)
                    end)
                end
            end

            rebuildOptions()

            HeaderBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                ArrowLabel.Text = expanded and "▲" or "▼"
                local targetHeight = expanded and (34 + #options * 24 + 4) or 30
                tween(DropdownFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetHeight)
                })
            end)

            return {
                Set = function(self, opt)
                    selected = opt
                    DrpLabel.Text = drpName .. ": " .. tostring(selected)
                    rebuildOptions()
                    pcall(callback, selected)
                end,
                Value = function(self)
                    return selected
                end
            }
        end

        function Section:CreateInput(inpConfig)
            local inpName = inpConfig.Name or "Input"
            local placeholder = inpConfig.Placeholder or "Enter..."
            local default = inpConfig.Default or ""
            local callback = inpConfig.Callback or function() end

            local InputFrame = Instance.new("Frame")
            InputFrame.Name = "Input_" .. inpName
            InputFrame.Size = UDim2.new(1, 0, 0, 30)
            InputFrame.BackgroundColor3 = Library.Theme.BtnBg
            InputFrame.Parent = SectionCard

            local InpCorner = Instance.new("UICorner")
            InpCorner.CornerRadius = UDim.new(0, 5)
            InpCorner.Parent = InputFrame

            local InpStroke = Instance.new("UIStroke")
            InpStroke.Color = Library.Theme.BtnBorder
            InpStroke.Thickness = 1
            InpStroke.Parent = InputFrame

            local InpLabel = Instance.new("TextLabel")
            InpLabel.Size = UDim2.new(0.4, 0, 1, 0)
            InpLabel.Position = UDim2.new(0, 10, 0, 0)
            InpLabel.BackgroundTransparency = 1
            InpLabel.Font = Enum.Font.GothamMedium
            InpLabel.Text = inpName
            InpLabel.TextColor3 = Library.Theme.TextNormal
            InpLabel.TextSize = 12
            InpLabel.TextXAlignment = Enum.TextXAlignment.Left
            InpLabel.Parent = InputFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0.6, -10, 0, 22)
            TextBox.Position = UDim2.new(0.4, 0, 0.5, -11)
            TextBox.BackgroundColor3 = Library.Theme.MainBg
            TextBox.Font = Enum.Font.Gotham
            TextBox.PlaceholderText = placeholder
            TextBox.PlaceholderColor3 = Library.Theme.TextMuted
            TextBox.Text = default
            TextBox.TextColor3 = Library.Theme.TextWhite
            TextBox.TextSize = 11
            TextBox.Parent = InputFrame

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = TextBox

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = Library.Theme.BtnBorder
            BoxStroke.Thickness = 1
            BoxStroke.Parent = TextBox

            TextBox.Focused:Connect(function()
                tween(BoxStroke, TweenInfo.new(0.15), { Color = Library.Theme.Accent })
            end)

            TextBox.FocusLost:Connect(function(enterPressed)
                tween(BoxStroke, TweenInfo.new(0.15), { Color = Library.Theme.BtnBorder })
                pcall(callback, TextBox.Text, enterPressed)
            end)

            return {
                Set = function(self, text)
                    TextBox.Text = text
                    pcall(callback, text, false)
                end,
                Value = function(self)
                    return TextBox.Text
                end
            }
        end

        function Section:CreateKeybind(kbConfig)
            local kbName = kbConfig.Name or "Keybind"
            local defaultKey = kbConfig.Default or Enum.KeyCode.E
            local callback = kbConfig.Callback or function() end

            local currentKey = defaultKey
            local binding = false

            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = "Keybind_" .. kbName
            KeybindFrame.Size = UDim2.new(1, 0, 0, 26)
            KeybindFrame.BackgroundTransparency = 1
            KeybindFrame.Parent = SectionCard

            local KbLabel = Instance.new("TextLabel")
            KbLabel.Size = UDim2.new(1, -60, 1, 0)
            KbLabel.Position = UDim2.new(0, 0, 0, 0)
            KbLabel.BackgroundTransparency = 1
            KbLabel.Font = Enum.Font.GothamMedium
            KbLabel.Text = kbName
            KbLabel.TextColor3 = Library.Theme.TextNormal
            KbLabel.TextSize = 12
            KbLabel.TextXAlignment = Enum.TextXAlignment.Left
            KbLabel.Parent = KeybindFrame

            local BindBtn = Instance.new("TextButton")
            BindBtn.Name = "BindBtn"
            BindBtn.Size = UDim2.new(0, 44, 0, 20)
            BindBtn.Position = UDim2.new(1, -44, 0.5, -10)
            BindBtn.BackgroundColor3 = Library.Theme.BadgeBg
            BindBtn.Text = currentKey and currentKey.Name or "None"
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.TextColor3 = Library.Theme.BadgeText
            BindBtn.TextSize = 11
            BindBtn.AutoButtonColor = false
            BindBtn.Parent = KeybindFrame

            local BindCorner = Instance.new("UICorner")
            BindCorner.CornerRadius = UDim.new(0, 4)
            BindCorner.Parent = BindBtn

            local BindStroke = Instance.new("UIStroke")
            BindStroke.Color = Library.Theme.BadgeBorder
            BindStroke.Thickness = 1
            BindStroke.Parent = BindBtn

            BindBtn.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true
                BindBtn.Text = "..."
                tween(BindStroke, TweenInfo.new(0.15), { Color = Library.Theme.Accent })

                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then
                            currentKey = nil
                            BindBtn.Text = "None"
                        elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                            currentKey = input.KeyCode
                            BindBtn.Text = currentKey.Name
                        end
                        binding = false
                        tween(BadgeStroke, TweenInfo.new(0.15), { Color = Library.Theme.BadgeBorder })
                        connection:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if not processed and not binding and currentKey and input.KeyCode == currentKey then
                    pcall(callback, currentKey)
                end
            end)

            return {
                Set = function(self, key)
                    currentKey = key
                    BindBtn.Text = currentKey and currentKey.Name or "None"
                end,
                Value = function(self)
                    return currentKey
                end
            }
        end

        function Section:CreateParagraph(paraConfig)
            local title = paraConfig.Title or "Information"
            local content = paraConfig.Content or ""

            local ParaFrame = Instance.new("Frame")
            ParaFrame.Name = "Paragraph"
            ParaFrame.Size = UDim2.new(1, 0, 0, 0)
            ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
            ParaFrame.BackgroundColor3 = Library.Theme.BtnBg
            ParaFrame.Parent = SectionCard

            local ParaCorner = Instance.new("UICorner")
            ParaCorner.CornerRadius = UDim.new(0, 5)
            ParaCorner.Parent = ParaFrame

            local ParaStroke = Instance.new("UIStroke")
            ParaStroke.Color = Library.Theme.BtnBorder
            ParaStroke.Thickness = 1
            ParaStroke.Parent = ParaFrame

            local ParaPad = Instance.new("UIPadding")
            ParaPad.PaddingTop = UDim.new(0, 8)
            ParaPad.PaddingBottom = UDim.new(0, 8)
            ParaPad.PaddingLeft = UDim.new(0, 10)
            ParaPad.PaddingRight = UDim.new(0, 10)
            ParaPad.Parent = ParaFrame

            local ParaTitle = Instance.new("TextLabel")
            ParaTitle.Size = UDim2.new(1, 0, 0, 16)
            ParaTitle.BackgroundTransparency = 1
            ParaTitle.Font = Enum.Font.GothamBold
            ParaTitle.Text = title
            ParaTitle.TextColor3 = Library.Theme.TextWhite
            ParaTitle.TextSize = 12
            ParaTitle.TextXAlignment = Enum.TextXAlignment.Left
            ParaTitle.Parent = ParaFrame

            local ParaContent = Instance.new("TextLabel")
            ParaContent.Size = UDim2.new(1, 0, 0, 0)
            ParaContent.Position = UDim2.new(0, 0, 0, 18)
            ParaContent.AutomaticSize = Enum.AutomaticSize.Y
            ParaContent.BackgroundTransparency = 1
            ParaContent.Font = Enum.Font.Gotham
            ParaContent.Text = content
            ParaContent.TextColor3 = Library.Theme.TextNormal
            ParaContent.TextSize = 11
            ParaContent.TextWrapped = true
            ParaContent.TextXAlignment = Enum.TextXAlignment.Left
            ParaContent.Parent = ParaFrame

            return {
                Set = function(self, newTitle, newContent)
                    ParaTitle.Text = newTitle
                    ParaContent.Text = newContent
                end
            }
        end

        return Section
    end

    function Window:CreateSection(sectionConfig, optionalSide)
        return buildSection(sectionConfig, optionalSide)
    end

    function Window:CreateTab(tabConfig)
        local Tab = {}
        function Tab:CreateSection(sectionConfig, optionalSide)
            return buildSection(sectionConfig, optionalSide)
        end
        return Tab
    end

    return Window
end

return Library
