--[[
    SNOWY LIB — BF PREMIUM EDITION (V9)
    100% Faithful Port | High-End Visuals | Stable Core
--]]

local Library = {}
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local UI_Elements = {
    AnimatedGradients = {},
    AnimatedStrokes = {},
    RowStrokes = {},
    RowStrokeGradients = {},
    DivGradients = {},
    TabGradients = {},
    Switches = {}
}

local CurrentTheme = "Sakura"
local Notifications = {}

local Themes = {
    ["Moonlight"] = {
        MainStroke = Color3.fromRGB(180, 180, 180),
        Wave = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 40)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 240)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 40))
        }),
        TitleStroke = Color3.fromRGB(150, 150, 150),
        TextGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 200)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
        }),
        TabGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
        }),
        DivGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 200)),
            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
        }),
        RowStroke = Color3.fromRGB(100, 100, 100),
        RowStrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
        }),
        ToggleActive = Color3.fromRGB(200, 200, 200),
        LoopSeq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
        })
    },
    ["Sakura"] = {
        MainStroke = Color3.fromRGB(255, 235, 240),
        Wave = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 240, 240)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 120, 120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 140, 140))
        }),
        TitleStroke = Color3.fromRGB(255, 235, 240),
        TextGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 210, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 240))
        }),
        TabGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 210, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 240))
        }),
        DivGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 250, 250)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }),
        RowStroke = Color3.new(1, 1, 1),
        RowStrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 210, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 240))
        }),
        ToggleActive = Color3.fromRGB(255, 235, 240),
        LoopSeq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 240, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 240, 245))
        })
    },
    ["Blue"] = {
        MainStroke = Color3.new(1, 1, 1),
        Wave = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 180)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 120, 120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 140, 140))
        }),
        TitleStroke = Color3.fromRGB(130, 190, 250),
        TextGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 240, 255))
        }),
        TabGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 240, 255))
        }),
        DivGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 220, 255)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }),
        RowStroke = Color3.new(1, 1, 1),
        RowStrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 240, 255))
        }),
        ToggleActive = Color3.fromRGB(100, 180, 255),
        LoopSeq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 230, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 230, 255))
        })
    }
}

-- ── Utilities ──────────────────────────────────────────────────────────────

local function applyPadding(inst, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = inst
end

function Library:SendNotification(titleText, descText)
    local g2 = Instance.new("ScreenGui")
    g2.Name = "Snowy_Notification_" .. math.random(100, 999)
    g2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() g2.Parent = CoreGui end)
    if not g2.Parent then g2.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    local m2 = Instance.new("Frame", g2)
    m2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    m2.BackgroundTransparency = 0.3
    m2.Size = UDim2.new(0, 260, 0, 80)
    m2.AnchorPoint = Vector2.new(1, 1)
    m2.Position = UDim2.new(1, 50, 1, -20)
    Instance.new("UICorner", m2).CornerRadius = UDim.new(0, 10)
    
    local u2 = Instance.new("UIStroke", m2)
    u2.Thickness = 2.5
    u2.Color = Themes[CurrentTheme].MainStroke
    local e2 = Instance.new("UIGradient", u2)
    e2.Color = Themes[CurrentTheme].LoopSeq
    
    local bgGradient = Instance.new("UIGradient", m2)
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 248, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(224, 240, 255))
    })
    
    local statusGradients = {}
    local function CreateStatusLabel(name, pos, text, size)
        local label = Instance.new("TextLabel", m2)
        label.Size = UDim2.new(1, -20, 0, 25)
        label.Position = UDim2.new(0.5, 0, 0, pos)
        label.AnchorPoint = Vector2.new(0.5, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = text
        label.TextSize = size or 12
        label.TextColor3 = Color3.new(1, 1, 1)
        local txtStroke = Instance.new("UIStroke", label)
        txtStroke.Thickness = 1.2
        txtStroke.Color = Themes[CurrentTheme].TitleStroke
        local txtGradient = Instance.new("UIGradient", label)
        txtGradient.Color = Themes[CurrentTheme].TextGrad
        table.insert(statusGradients, txtGradient)
        return label
    end
    
    CreateStatusLabel("Title", 12, titleText, 16)
    CreateStatusLabel("Subtitle", 40, descText, 12)
    
    local r2 = 0
    local conn
    conn = RunService.RenderStepped:Connect(function()
        r2 = (r2 + 1.5) % 360
        e2.Rotation = r2
        for _, grad in ipairs(statusGradients) do grad.Rotation = r2 end
        bgGradient.Offset = Vector2.new(math.sin(tick() * 1.5) * 0.3, 0)
    end)
    
    for i, notif in ipairs(Notifications) do
        if notif and notif.Parent then
            local newY = -20 - (i * 90)
            TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 1, newY)}):Play()
        end
    end
    
    table.insert(Notifications, 1, m2)
    if #Notifications > 5 then
        local old = table.remove(Notifications, 6)
        if old then task.delay(0.3, function() old.Parent:Destroy() end) end
    end
    
    TweenService:Create(m2, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 1, -20)}):Play()
    task.delay(3, function()
        for i, v in ipairs(Notifications) do if v == m2 then table.remove(Notifications, i) break end end
        local t = TweenService:Create(m2, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 300, 1, m2.Position.Y.Offset)})
        t:Play()
        t.Completed:Connect(function() conn:Disconnect(); g2:Destroy() end)
    end)
end

function Library:CreateWindow(config)
    local Window = {}
    config = config or {}
    local windowTitle = config.Title or "Hub Premium"
    
    if getgenv().SnowyLib_Instance then pcall(function() getgenv().SnowyLib_Instance:Destroy() end) end
    
    local g = Instance.new("ScreenGui")
    g.Name = "SnowyLib_" .. math.random(100, 999)
    g.ResetOnSpawn = false
    pcall(function() g.Parent = CoreGui end)
    if not g.Parent then g.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    getgenv().SnowyLib_Instance = g
    
    local m = Instance.new("Frame", g)
    m.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    m.BackgroundTransparency = 0.5
    m.Size = UDim2.new(0, 700, 0, 500)
    m.Position = UDim2.new(0.5, 0, 0.5, 0)
    m.AnchorPoint = Vector2.new(0.5, 0.5)
    m.ClipsDescendants = true
    Instance.new("UICorner", m).CornerRadius = UDim.new(0, 15)
    
    local isMini, isMax = false, false
    
    local SnowContainer = Instance.new("Frame", m)
    SnowContainer.Size = UDim2.new(1, -20, 1, -20)
    SnowContainer.Position = UDim2.new(0, 10, 0, 10)
    SnowContainer.BackgroundTransparency = 1
    SnowContainer.ClipsDescendants = true
    Instance.new("UICorner", SnowContainer).CornerRadius = UDim.new(0, 15)
    
    task.spawn(function()
        while task.wait(0.15) do
            if not m.Visible or isMini then continue end
            local flake = Instance.new("ImageLabel", SnowContainer)
            flake.BackgroundTransparency = 1
            local iconId = "137906289429512"
            if CurrentTheme == "Sakura" then iconId = "129633366976969"
            elseif CurrentTheme == "Moonlight" then iconId = "116750779040036" end
            flake.Image = "rbxthumb://type=Asset&id=" .. iconId .. "&w=150&h=150"
            local size = math.random(13, 20)
            flake.Size = UDim2.new(0, size, 0, size)
            flake.Position = UDim2.new(math.random(), 0, -0.1, 0)
            flake.ImageTransparency = math.random(2, 6) / 10
            local t = TweenService:Create(flake, TweenInfo.new(math.random(40, 70)/10, Enum.EasingStyle.Linear), {Position = UDim2.new(flake.Position.X.Scale, 0, 1.1, 0), Rotation = math.random(-180, 180)})
            t:Play(); t.Completed:Connect(function() flake:Destroy() end)
        end
    end)
    
    local ToggleIcon = Instance.new("ImageButton", g)
    ToggleIcon.Size = UDim2.new(0, 45, 0, 45)
    ToggleIcon.Position = UDim2.new(0, 20, 1, -65)
    ToggleIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleIcon.Image = "rbxassetid://6031090990"
    ToggleIcon.BackgroundTransparency = 0.5
    Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(1, 0)
    
    ToggleIcon.MouseButton1Click:Connect(function()
        if not m then return end
        if m.Size.X.Offset > 0 or m.Size.X.Scale > 0 then
            TweenService:Create(m, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.wait(0.3); m.Visible = false
        else
            m.Visible = true
            local targetSize = isMini and UDim2.new(0, 700, 0, 45) or (isMax and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 700, 0, 500))
            TweenService:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize, Position = UDim2.new(0.5, 0, isMini and 0 or 0.5, isMini and 25 or 0)}):Play()
        end
    end)
    
    local u = Instance.new("UIStroke", m)
    u.Thickness = 4.5
    table.insert(UI_Elements.AnimatedStrokes, {Obj = u, Type = "MainStroke"})
    local e = Instance.new("UIGradient", u)
    
    local waveBg = Instance.new("Frame", m)
    waveBg.Size = UDim2.new(1, 0, 1, 0)
    waveBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    waveBg.BackgroundTransparency = 0.7
    Instance.new("UICorner", waveBg).CornerRadius = UDim.new(0, 15)
    local waveGrad = Instance.new("UIGradient", waveBg)
    waveGrad.Color = Themes[CurrentTheme].Wave
    
    local titleBar = Instance.new("Frame", m)
    titleBar.Size = UDim2.new(1, 0, 0, 55)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex = 2
    
    local hubTitle = Instance.new("TextLabel", titleBar)
    hubTitle.Size = UDim2.new(0, 300, 1, 0); hubTitle.Position = UDim2.new(0, 20, 0, 0); hubTitle.BackgroundTransparency = 1; hubTitle.Font = Enum.Font.GothamMedium; hubTitle.Text = windowTitle; hubTitle.TextColor3 = Color3.new(1, 1, 1); hubTitle.TextSize = 15; hubTitle.TextXAlignment = Enum.TextXAlignment.Left
    local hubTitleStroke = Instance.new("UIStroke", hubTitle); hubTitleStroke.Thickness = 1.2; hubTitleStroke.Color = Themes[CurrentTheme].TitleStroke; table.insert(UI_Elements.AnimatedStrokes, {Obj = hubTitleStroke, Type = "TitleStroke"})
    local hubTitleGrad = Instance.new("UIGradient", hubTitle); hubTitleGrad.Color = Themes[CurrentTheme].TextGrad; table.insert(UI_Elements.AnimatedGradients, hubTitleGrad)
    
    local function CreateWinBtn(text, pos)
        local btn = Instance.new("TextButton", titleBar); btn.Size = UDim2.new(0, 30, 0, 30); btn.Position = UDim2.new(1, pos, 0.5, 0); btn.AnchorPoint = Vector2.new(0, 0.5); btn.BackgroundTransparency = 1; btn.Text = text; btn.Font = Enum.Font.GothamMedium; btn.TextColor3 = Color3.new(1, 1, 1); btn.TextSize = 16
        local btnStroke = Instance.new("UIStroke", btn); btnStroke.Thickness = 1; btnStroke.Color = Themes[CurrentTheme].TitleStroke; table.insert(UI_Elements.AnimatedStrokes, {Obj = btnStroke, Type = "TitleStroke"})
        local btnGrad = Instance.new("UIGradient", btn); btnGrad.Color = Themes[CurrentTheme].TextGrad; table.insert(UI_Elements.AnimatedGradients, btnGrad)
        return btn
    end
    local minBtn = CreateWinBtn("--", -105); local maxBtn = CreateWinBtn("▢", -70); local closeBtn = CreateWinBtn("X", -35)
    
    -- Draggable
    local dragStart, startPos, dragging
    titleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = m.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; m.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    
    local Sidebar = Instance.new("ScrollingFrame", m)
    Sidebar.Size = UDim2.new(0, 180, 1, -65); Sidebar.Position = UDim2.new(0, 5, 0, 60); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 0; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.ZIndex = 2
    local sideLayout = Instance.new("UIListLayout", Sidebar); sideLayout.Padding = UDim.new(0, 5); sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local PagesList, TabsList = {}, {}
    
    function Window:CreateTab(name, isFirstPage)
        local Tab = {}
        local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(1, -20, 0, 35); btn.BackgroundTransparency = 1; btn.Font = Enum.Font.GothamMedium; btn.Text = "      " .. name; btn.TextColor3 = Color3.new(1, 1, 1); btn.TextSize = 15; btn.TextXAlignment = Enum.TextXAlignment.Left
        local indicator = Instance.new("Frame", btn); indicator.Size = UDim2.new(0, 4, 0, 18); indicator.Position = UDim2.new(0, 8, 0.5, 0); indicator.AnchorPoint = Vector2.new(0, 0.5); indicator.BackgroundColor3 = Color3.new(1, 1, 1); indicator.BorderSizePixel = 0; indicator.Visible = isFirstPage; Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
        local tabGrad = Instance.new("UIGradient", btn); tabGrad.Color = Themes[CurrentTheme].TabGrad; table.insert(UI_Elements.TabGradients, tabGrad); table.insert(UI_Elements.AnimatedGradients, tabGrad); table.insert(TabsList, btn)
        
        local page = Instance.new("ScrollingFrame", m); page.Name = name .. "Page"; page.Size = UDim2.new(1, -235, 1, -85); page.Position = UDim2.new(0, 215, 0, 70); page.BackgroundTransparency = 1; page.ScrollBarThickness = 0; page.ZIndex = 2; page.Visible = isFirstPage; page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        applyPadding(page, 10, 20, 5, 0); local contentLayout = Instance.new("UIListLayout", page); contentLayout.Padding = UDim.new(0, 8); table.insert(PagesList, page)
        
        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(PagesList) do p.Visible = false end
            for _, t in pairs(TabsList) do if t:FindFirstChild("Indicator") then t.Indicator.Visible = false end end
            page.Visible = true; indicator.Visible = true
            Library:SendNotification("Tab Selected", name)
        end)

        function Tab:CreatePageTitle(text)
            local h = Instance.new("Frame", page); h.Size = UDim2.new(1, 0, 0, 45); h.BackgroundTransparency = 1
            local t = Instance.new("TextLabel", h); t.Size = UDim2.new(1, 0, 1, 0); t.Position = UDim2.new(0, 10, 0, 0); t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamBold; t.Text = text; t.TextColor3 = Color3.new(1, 1, 1); t.TextSize = 26; t.TextXAlignment = Enum.TextXAlignment.Left
            local s = Instance.new("UIStroke", t); s.Thickness = 1.5; s.Color = Themes[CurrentTheme].TitleStroke; table.insert(UI_Elements.AnimatedStrokes, {Obj = s, Type = "TitleStroke"})
            local g = Instance.new("UIGradient", t); g.Color = Themes[CurrentTheme].TextGrad; table.insert(UI_Elements.AnimatedGradients, g)
        end

        function Tab:CreateSwitch(text, default, callback)
            local row = Instance.new("Frame", page); row.Size = UDim2.new(1, -4, 0, 42); row.BackgroundColor3 = Color3.fromRGB(255, 255, 255); row.BackgroundTransparency = 0.8; Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            local s = Instance.new("UIStroke", row); s.Color = Themes[CurrentTheme].RowStroke; s.Thickness = 1.2; table.insert(UI_Elements.RowStrokes, s)
            local g = Instance.new("UIGradient", s); g.Color = Themes[CurrentTheme].RowStrokeGrad; table.insert(UI_Elements.AnimatedGradients, g)
            local l = Instance.new("TextLabel", row); l.Size = UDim2.new(0.7, -10, 1, 0); l.Position = UDim2.new(0, 15, 0, 0); l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamMedium; l.Text = text; l.TextColor3 = Color3.new(1, 1, 1); l.TextSize = 14.5; l.TextXAlignment = Enum.TextXAlignment.Left
            local tf = Instance.new("TextButton", row); tf.Size = UDim2.new(0, 40, 0, 20); tf.Position = UDim2.new(1, -55, 0.5, 0); tf.AnchorPoint = Vector2.new(0, 0.5); tf.BackgroundColor3 = default and Themes[CurrentTheme].ToggleActive or Color3.fromRGB(150, 150, 150); tf.Text = ""; Instance.new("UICorner", tf).CornerRadius = UDim.new(1, 0)
            local ball = Instance.new("Frame", tf); ball.Size = UDim2.new(0, 16, 0, 16); ball.Position = default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0); ball.AnchorPoint = Vector2.new(0, 0.5); ball.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
            local active = default
            tf.MouseButton1Click:Connect(function()
                active = not active
                TweenService:Create(tf, TweenInfo.new(0.2), {BackgroundColor3 = active and Themes[CurrentTheme].ToggleActive or Color3.fromRGB(150, 150, 150)}):Play()
                TweenService:Create(ball, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}):Play()
                pcall(callback, active); Library:SendNotification("Switch Toggled", text .. ": " .. (active and "Enabled" or "Disabled"))
            end)
        end

        function Tab:CreateButton(text, callback)
            local row = Instance.new("Frame", page); row.Size = UDim2.new(1, -4, 0, 42); row.BackgroundColor3 = Color3.fromRGB(255, 255, 255); row.BackgroundTransparency = 0.8; Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            local rs = Instance.new("UIStroke", row); rs.Color = Themes[CurrentTheme].RowStroke; rs.Thickness = 1.2; table.insert(UI_Elements.RowStrokes, rs)
            local rg = Instance.new("UIGradient", rs); rg.Color = Themes[CurrentTheme].RowStrokeGrad; table.insert(UI_Elements.AnimatedGradients, rg)
            local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Font = Enum.Font.GothamBold; btn.Text = text; btn.TextColor3 = Color3.new(1, 1, 1); btn.TextSize = 15
            btn.MouseButton1Click:Connect(function() pcall(callback); Library:SendNotification("Button Clicked", text) end)
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            local row = Instance.new("Frame", page); row.Size = UDim2.new(1, -4, 0, 60); row.BackgroundColor3 = Color3.fromRGB(255, 255, 255); row.BackgroundTransparency = 0.8; Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
            local rs = Instance.new("UIStroke", row); rs.Color = Themes[CurrentTheme].RowStroke; rs.Thickness = 1.2; table.insert(UI_Elements.RowStrokes, rs)
            local rg = Instance.new("UIGradient", rs); rg.Color = Themes[CurrentTheme].RowStrokeGrad; table.insert(UI_Elements.AnimatedGradients, rg)
            local l = Instance.new("TextLabel", row); l.Size = UDim2.new(0.6, 0, 0, 30); l.Position = UDim2.new(0, 15, 0, 5); l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamMedium; l.Text = text; l.TextColor3 = Color3.new(1, 1, 1); l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left
            local inp = Instance.new("TextBox", row); inp.Size = UDim2.new(0, 50, 0, 22); inp.Position = UDim2.new(1, -65, 0, 10); inp.BackgroundColor3 = Color3.fromRGB(255, 255, 255); inp.BackgroundTransparency = 0.9; inp.Font = Enum.Font.GothamBold; inp.Text = tostring(default); inp.TextColor3 = Color3.new(1, 1, 1); inp.TextSize = 12; Instance.new("UICorner", inp).CornerRadius = UDim.new(0, 5)
            local sbg = Instance.new("Frame", row); sbg.Size = UDim2.new(1, -30, 0, 6); sbg.Position = UDim2.new(0, 15, 0, 45); sbg.BackgroundColor3 = Color3.fromRGB(255, 255, 255); sbg.BackgroundTransparency = 0.9; Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)
            local fil = Instance.new("Frame", sbg); fil.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fil.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", fil).CornerRadius = UDim.new(1, 0)
            local g = Instance.new("UIGradient", fil); g.Color = Themes[CurrentTheme].TextGrad; table.insert(UI_Elements.AnimatedGradients, g)
            local cir = Instance.new("Frame", fil); cir.Size = UDim2.fromOffset(14, 14); cir.Position = UDim2.fromScale(1, 0.5); cir.AnchorPoint = Vector2.new(0.5, 0.5); cir.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", cir).CornerRadius = UDim.new(1, 0)
            
            local drag = false
            local function move(i) local a = math.clamp((i.Position.X - sbg.AbsolutePosition.X)/sbg.AbsoluteSize.X, 0, 1); local v = math.floor(min + (max-min)*a); fil.Size = UDim2.fromScale(a, 1); inp.Text = tostring(v); pcall(callback, v) end
            cir.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
            UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then move(i) end end)
            inp.FocusLost:Connect(function() local v = math.clamp(tonumber(inp.Text) or default, min, max); inp.Text = tostring(v); TweenService:Create(fil, TweenInfo.new(0.2), {Size = UDim2.fromScale((v-min)/(max-min), 1)}):Play(); pcall(callback, v) end)
        end

        return Tab
    end

    function Window:ApplyTheme(name)
        local t = Themes[name] if not t then return end CurrentTheme = name
        for _, i in pairs(UI_Elements.AnimatedStrokes) do i.Obj.Color = t[i.Type] end
        for _, s in pairs(UI_Elements.RowStrokes) do s.Color = t.RowStroke end
        for _, g in pairs(UI_Elements.AnimatedGradients) do g.Color = t.TextGrad end
        waveGrad.Color = t.Wave
    end
    
    local rot = 0
    RunService.RenderStepped:Connect(function()
        rot = (rot + 1.5) % 360
        e.Rotation = rot; e.Color = Themes[CurrentTheme].LoopSeq
        if waveGrad then waveGrad.Offset = Vector2.new(math.sin(tick() * 1.2) * 0.5, 0) end
    end)
    
    m.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(m, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 700, 0, 500)}):Play()
    return Window
end

return Library
