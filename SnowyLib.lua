-- SnowyLib — Professional Website-Mirror Version (Optimized & Bug-Free)
-- Usage: local SnowyLib = loadstring(game:HttpGet("RAW_URL"))()

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local localPlayer      = Players.LocalPlayer

local RAW = "https://raw.githubusercontent.com/bqhyuu/SnowyLib/refs/heads/main/"
local LUCIDE_ICONS   = loadstring(game:HttpGet(RAW .. "Icon/LucideIcons.lua"))()
local PHOSPHOR_ICONS = loadstring(game:HttpGet(RAW .. "Icon/PhosphorIcons.lua"))()

local THEMES = {
	Dark     = { Background = Color3.fromRGB(8, 8, 10),   Surface = Color3.fromRGB(15, 15, 18),   SurfaceAlt = Color3.fromRGB(25, 25, 30),  Sidebar = Color3.fromRGB(12, 12, 15),  Text = Color3.fromRGB(255, 255, 255), MutedText = Color3.fromRGB(120, 120, 130), Stroke = Color3.fromRGB(40, 40, 45),   Accent = Color3.fromRGB(255, 255, 255) },
	Aqua     = { Background = Color3.fromRGB(5, 16, 16),  Surface = Color3.fromRGB(8, 24, 24),    SurfaceAlt = Color3.fromRGB(12, 36, 36),  Sidebar = Color3.fromRGB(6, 20, 20),   Text = Color3.fromRGB(255, 255, 255), MutedText = Color3.fromRGB(100, 140, 140), Stroke = Color3.fromRGB(30, 60, 60),   Accent = Color3.fromRGB(0, 255, 255) },
	Rose     = { Background = Color3.fromRGB(18, 8, 10),  Surface = Color3.fromRGB(26, 12, 15),   SurfaceAlt = Color3.fromRGB(38, 18, 22),  Sidebar = Color3.fromRGB(22, 10, 12),  Text = Color3.fromRGB(255, 255, 255), MutedText = Color3.fromRGB(160, 110, 120), Stroke = Color3.fromRGB(60, 30, 35),   Accent = Color3.fromRGB(251, 113, 133) },
	Amethyst = { Background = Color3.fromRGB(13, 8, 18),  Surface = Color3.fromRGB(20, 12, 28),   SurfaceAlt = Color3.fromRGB(30, 18, 42),  Sidebar = Color3.fromRGB(16, 10, 22),  Text = Color3.fromRGB(255, 255, 255), MutedText = Color3.fromRGB(140, 110, 170), Stroke = Color3.fromRGB(50, 30, 70),   Accent = Color3.fromRGB(168, 85, 247) },
	Midnight = { Background = Color3.fromRGB(5, 5, 8),    Surface = Color3.fromRGB(10, 10, 15),   SurfaceAlt = Color3.fromRGB(18, 18, 28),  Sidebar = Color3.fromRGB(7, 7, 11),    Text = Color3.fromRGB(255, 255, 255), MutedText = Color3.fromRGB(100, 100, 130), Stroke = Color3.fromRGB(30, 30, 45),   Accent = Color3.fromRGB(100, 150, 255) },
	Emerald  = { Background = Color3.fromRGB(5, 14, 10),  Surface = Color3.fromRGB(8, 22, 16),    SurfaceAlt = Color3.fromRGB(12, 32, 24),  Sidebar = Color3.fromRGB(6, 18, 12),   Text = Color3.fromRGB(255, 255, 255), MutedText = Color3.fromRGB(100, 150, 130), Stroke = Color3.fromRGB(30, 50, 40),   Accent = Color3.fromRGB(16, 185, 129) },
	Darker   = { Background = Color3.fromRGB(0, 0, 0),    Surface = Color3.fromRGB(8, 8, 8),      SurfaceAlt = Color3.fromRGB(16, 16, 16),  Sidebar = Color3.fromRGB(4, 4, 4),     Text = Color3.fromRGB(255, 255, 255), MutedText = Color3.fromRGB(100, 100, 100), Stroke = Color3.fromRGB(25, 25, 25),   Accent = Color3.fromRGB(255, 255, 255) },
}

-- ── Util ───────────────────────────────────────────────────────────────────

local function safeCall(callback, ...)
	if type(callback) ~= "function" then return end
	local ok, err = pcall(callback, ...)
	if not ok then warn("[SnowyLib] Callback error:", err) end
end

local function create(instanceType, props)
	local instance = Instance.new(instanceType)
	for key, value in pairs(props or {}) do instance[key] = value end
	return instance
end

local function applyCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = instance
	return corner
end

local function applyStroke(instance, thickness, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 1
	stroke.Color = color or Color3.new(1, 1, 1)
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

local function applyPadding(instance, left, right, top, bottom)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.Parent = instance
	return padding
end

local function resolveIcon(name)
	if not name or name == "" then return nil end
	if string.find(name, "rbxassetid://", 1, true) or string.find(name, "http", 1, true) then return name end

	local prefix, rest = string.match(name, "^(%a+):(.+)$")
	if prefix == "ph" then return PHOSPHOR_ICONS["ph-" .. rest] or PHOSPHOR_ICONS[rest]
	elseif prefix == "lucide" or prefix == "lu" then return LUCIDE_ICONS["lucide-" .. rest] or LUCIDE_ICONS[rest] end

	return LUCIDE_ICONS["lucide-" .. name] or LUCIDE_ICONS[name] or PHOSPHOR_ICONS["ph-" .. name] or PHOSPHOR_ICONS[name]
end

local function isAsset(value)
	return type(value) == "string" and (string.find(value, "rbxassetid://", 1, true) ~= nil or string.find(value, "http", 1, true) ~= nil)
end

local function tween(instance, info, props)
	local t = TweenService:Create(instance, info, props)
	t:Play()
	return t
end

local function makeDraggable(windowObject, handle, target)
	local dragging, dragInput, dragStart, startPosition
	table.insert(windowObject._connections, handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPosition = target.Position
			local ended; ended = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false; ended:Disconnect() end
			end)
		end
	end))
	table.insert(windowObject._connections, handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end))
	table.insert(windowObject._connections, UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end))
end

local function createIconVisual(parent, icon, fallbackText)
	local resolved = resolveIcon(icon)
	if resolved and isAsset(resolved) then
		return create("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14), Image = resolved, Parent = parent })
	end
	return create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14), Font = Enum.Font.GothamBold, Text = tostring(fallbackText or "•"), TextSize = 10, Parent = parent })
end

-- ── Component: Paragraph ───────────────────────────────────────────────────
local _comp_Paragraph = function(window, content, config)
	config = config or {}
	local card = create("Frame", { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), BorderSizePixel = 0, Parent = content })
	applyCorner(card, UDim.new(0, 12)); local stroke = applyStroke(card, 2); applyPadding(card, 14, 14, 14, 14)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = card })
	local titleLabel = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), Font = Enum.Font.GothamBlack, Text = (config.Title or "PARAGRAPH"):upper(), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
	local body = create("TextLabel", { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Font = Enum.Font.GothamMedium, Text = config.Content or "", TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
	window:_registerStyler(function(colors)
		card.BackgroundColor3 = colors.Surface; card.BackgroundTransparency = 0.96; stroke.Color = colors.Stroke; stroke.Transparency = 0.9; titleLabel.TextColor3 = colors.Accent; body.TextColor3 = colors.Text; body.TextTransparency = 0.5
	end)
	return card
end

-- ── Component: Button ──────────────────────────────────────────────────────
local _comp_Button = function(window, parts, config)
	config = config or {}
	local button = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 120, 0, 28), AutoButtonColor = false, BorderSizePixel = 0, Font = Enum.Font.GothamBold, Text = (config.ButtonText or config.Title or "RUN"):upper(), TextSize = 10, Parent = parts.Right })
	applyCorner(button, UDim.new(0, 10)); local stroke = applyStroke(button, 1)
	window:_registerStyler(function(colors) button.BackgroundColor3 = colors.SurfaceAlt; button.TextColor3 = colors.Text; stroke.Color = colors.Stroke end)
	table.insert(window._connections, button.MouseButton1Click:Connect(function() safeCall(config.Callback) end))
	return { SetText = function(_, text) button.Text = text:upper() end }
end

-- ── Component: Toggle ──────────────────────────────────────────────────────
local _comp_Toggle = function(window, parts, config)
	config = config or {}
	local value = not not config.Default
	local track = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(32, 16), BorderSizePixel = 0, Parent = parts.Right })
	applyCorner(track, UDim.new(1, 0)); local stroke = applyStroke(track, 2)
	local knob = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(10, 10), BorderSizePixel = 0, Parent = track })
	applyCorner(knob, UDim.new(1, 0))

	local function render(animate)
		local colors = window:_getColors()
		if value then
			track.BackgroundColor3 = colors.Accent; stroke.Color = Color3.new(1, 1, 1); stroke.Transparency = 0.9; knob.BackgroundColor3 = Color3.new(1, 1, 1)
			if animate then tween(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Position = UDim2.new(0, 18, 0.5, 0) }) else knob.Position = UDim2.new(0, 18, 0.5, 0) end
		else
			track.BackgroundColor3 = Color3.new(1, 1, 1); track.BackgroundTransparency = 0.9; stroke.Color = Color3.new(1, 1, 1); stroke.Transparency = 0.95; knob.BackgroundColor3 = Color3.new(1, 1, 1); knob.BackgroundTransparency = 0.6
			if animate then tween(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Position = UDim2.new(0, 2, 0.5, 0) }) else knob.Position = UDim2.new(0, 2, 0.5, 0) end
		end
	end
	window:_registerStyler(function() render(false) end)
	local control = {}
	function control:Set(state) value = not not state; render(true); safeCall(config.Callback, value) end
	function control:Get() return value end
	table.insert(window._connections, parts.Hitbox.MouseButton1Click:Connect(function() control:Set(not value) end))
	return control 
end

-- ── Component: Slider ──────────────────────────────────────────────────────
local _comp_Slider = function(window, parts, config)
	config = config or {}
	local min, max, step = config.Min or 0, config.Max or 100, config.Step or 1
	local value = math.clamp(config.Default or min, min, max)
	local sliderArea = create("Frame", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Parent = parts.Card, LayoutOrder = 5 })
	local track = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 2), Parent = sliderArea })
	applyCorner(track, UDim.new(1, 0))
	local fill = create("Frame", { Size = UDim2.new(0, 0, 1, 0), Parent = track })
	applyCorner(fill, UDim.new(1, 0))
	local knob = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(12, 12), Parent = track })
	applyCorner(knob, UDim.new(1, 0)); applyStroke(knob, 2, Color3.new(1, 1, 1), 0.7)
	local input = create("TextBox", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(40, 20), Font = Enum.Font.Code, TextSize = 9, Parent = parts.Right })
	applyCorner(input, UDim.new(0, 8)); local inStroke = applyStroke(input, 2)

	local function render()
		local colors = window:_getColors()
		local alpha = (value - min) / math.max(max - min, 0.001)
		fill.Size = UDim2.new(alpha, 0, 1, 0); knob.Position = UDim2.new(alpha, 0, 0.5, 0); input.Text = tostring(math.floor(value * 10) / 10)
		track.BackgroundColor3 = Color3.new(1, 1, 1); track.BackgroundTransparency = 0.9; fill.BackgroundColor3 = colors.Accent; knob.BackgroundColor3 = Color3.new(1, 1, 1); input.BackgroundColor3 = Color3.new(0, 0, 0); input.BackgroundTransparency = 0.4; input.TextColor3 = colors.Accent; inStroke.Color = Color3.new(1, 1, 1); inStroke.Transparency = 0.9
	end
	local dragging = false
	local function update(i)
		local a = math.clamp((i.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		value = min + (max - min) * a; if step > 0 then value = math.floor(value / step + 0.5) * step end; value = math.clamp(value, min, max); render(); safeCall(config.Callback, value)
	end
	table.insert(window._connections, sliderArea.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i) end end))
	table.insert(window._connections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
	table.insert(window._connections, UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end))
	window:_registerStyler(render); return { Set = function(_, v) value = v; render() end, Get = function() return value end }
end

-- ── Component: Dropdown ────────────────────────────────────────────────────
local _comp_Dropdown = function(window, parts, config)
	config = config or {}
	local items = config.Values or config.Items or {}
	local isMulti = config.Multi
	local selected = isMulti and {} or (config.Default or items[1])
	if isMulti and config.Default then for _, v in ipairs(config.Default) do selected[v] = true end end
	local isOpen = false

	local trigger = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(140, 26), AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = parts.Right })
	applyCorner(trigger, UDim.new(0, 8)); applyPadding(trigger, 10, 20, 0, 0); local tStroke = applyStroke(trigger, 2)
	local chevron = create("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Text = "v", Font = Enum.Font.GothamBold, TextSize = 8, Parent = trigger })
	local expand = create("Frame", { Visible = false, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = parts.Card, LayoutOrder = 10 })
	local list = create("Frame", { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = expand })
	applyCorner(list, UDim.new(0, 12)); local lStroke = applyStroke(list, 2); create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = list }); applyPadding(list, 4, 4, 4, 4)

	local function updateTrig()
		if isMulti then local c = 0; for _ in pairs(selected) do c += 1 end; trigger.Text = c == 0 and "SELECT..." or (c .. " SELECTED")
		else trigger.Text = tostring(selected):upper() end
	end
	local function build()
		for _, v in ipairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, item in ipairs(items) do
			local isSel = isMulti and selected[item] or (selected == item)
			local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 24), AutoButtonColor = false, Font = Enum.Font.GothamBold, Text = item:upper(), TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = list })
			applyCorner(btn, UDim.new(0, 8)); applyPadding(btn, 10, 10, 0, 0)
			local colors = window:_getColors()
			btn.BackgroundColor3 = isSel and colors.Accent or Color3.new(1, 1, 1); btn.BackgroundTransparency = isSel and 0.9 or 1; btn.TextColor3 = isSel and colors.Accent or colors.Text; btn.TextTransparency = isSel and 0 or 0.6
			btn.MouseButton1Click:Connect(function()
				if isMulti then selected[item] = not selected[item] else selected = item; isOpen = false; expand.Visible = false end
				updateTrig(); build(); safeCall(config.Callback, isMulti and selected or selected)
			end)
		end
	end
	trigger.MouseButton1Click:Connect(function() isOpen = not isOpen; expand.Visible = isOpen end)
	window:_registerStyler(function(colors)
		trigger.BackgroundColor3 = Color3.new(0, 0, 0); trigger.BackgroundTransparency = 0.6; trigger.TextColor3 = colors.Text; tStroke.Color = Color3.new(1, 1, 1); tStroke.Transparency = 0.9; chevron.TextColor3 = colors.Accent; list.BackgroundColor3 = Color3.fromRGB(18, 18, 20); list.BackgroundTransparency = 0.05; lStroke.Color = Color3.new(1, 1, 1); lStroke.Transparency = 0.85
	end)
	updateTrig(); build(); return { Set = function(_, v) selected = v; updateTrig(); build() end, Get = function() return selected end }
end

-- ── Component: Textbox ─────────────────────────────────────────────────────
local _comp_Textbox = function(window, parts, config)
	config = config or {}
	local box = create("TextBox", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(140, 26), Font = Enum.Font.GothamBold, TextSize = 9, PlaceholderText = config.Placeholder or "ENTER...", Parent = parts.Right })
	applyCorner(box, UDim.new(0, 8)); applyPadding(box, 10, 10, 0, 0); local stroke = applyStroke(box, 2)
	window:_registerStyler(function(colors) box.BackgroundColor3 = Color3.new(0, 0, 0); box.BackgroundTransparency = 0.6; box.TextColor3 = colors.Text; box.PlaceholderColor3 = colors.MutedText; stroke.Color = Color3.new(1, 1, 1); stroke.Transparency = 0.9 end)
	box.FocusLost:Connect(function() safeCall(config.Callback, box.Text) end)
	return { Set = function(_, v) box.Text = v end, Get = function() return box.Text end }
end

-- ── Component: Keybind ─────────────────────────────────────────────────────
local _comp_Keybind = function(window, parts, config)
	config = config or {}
	local current = config.Default or Enum.KeyCode.RightControl; local listening = false
	local btn = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(100, 26), Font = Enum.Font.GothamBlack, TextSize = 9, Parent = parts.Right })
	applyCorner(btn, UDim.new(0, 8)); local stroke = applyStroke(btn, 2)
	local function render()
		local colors = window:_getColors()
		btn.Text = listening and "LISTENING..." or (typeof(current) == "EnumItem" and current.Name:upper() or tostring(current):upper())
		btn.BackgroundColor3 = Color3.new(0, 0, 0); btn.BackgroundTransparency = 0.6; btn.TextColor3 = listening and colors.Accent or colors.Text; stroke.Color = listening and colors.Accent or Color3.new(1, 1, 1); stroke.Transparency = listening and 0.5 or 0.9
	end
	btn.MouseButton1Click:Connect(function() listening = true; render() end)
	table.insert(window._connections, UserInputService.InputBegan:Connect(function(i, g)
		if g then return end
		if listening then
			if i.KeyCode ~= Enum.KeyCode.Unknown then current = i.KeyCode; listening = false; render(); safeCall(config.Callback, current) end
		elseif i.KeyCode == current then safeCall(config.Pressed) end
	end))
	window:_registerStyler(render); return { Set = function(_, v) current = v; render() end, Get = function() return current end }
end

-- ── Section ────────────────────────────────────────────────────────────────
local function createSectionObject(window, parent, name)
	local wrapper = create("Frame", { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = parent })
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = wrapper })
	if name and name ~= "" then
		local head = create("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = wrapper })
		local lab = create("TextLabel", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = name:upper(), TextSize = 9, Parent = head })
		local line = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(1, -60, 0, 1), Parent = head })
		window:_registerStyler(function(colors) lab.TextColor3 = colors.Accent; lab.TextTransparency = 0.5; line.BackgroundColor3 = Color3.new(1, 1, 1); line.BackgroundTransparency = 0.9 end)
	end
	local content = create("Frame", { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = wrapper })
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = content })
	local function createCard(title, desc)
		local card = create("Frame", { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = content })
		applyCorner(card, UDim.new(0, 12)); local stroke = applyStroke(card, 2); applyPadding(card, 12, 12, 10, 10)
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = card })
		local top = create("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = card })
		local tit = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Enum.Font.GothamBold, Text = title, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = top })
		if desc and desc ~= "" then
			top.Size = UDim2.new(1, 0, 0, 34); local d = create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 16), Size = UDim2.new(0.6, 0, 0, 14), Font = Enum.Font.GothamMedium, Text = desc, TextSize = 9, TextTransparency = 0.7, Parent = top })
			window:_registerStyler(function(colors) d.TextColor3 = colors.Text end)
		end
		local right = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1, Parent = top })
		local hb = create("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", Parent = card })
		window:_registerStyler(function(colors) card.BackgroundColor3 = Color3.new(1, 1, 1); card.BackgroundTransparency = 0.97; stroke.Color = Color3.new(1, 1, 1); stroke.Transparency = 0.95; tit.TextColor3 = colors.Text end)
		return { Card = card, Right = right, Hitbox = hb }
	end
	local obj = {}
	function obj:CreateButton(cfg) return _comp_Button(window, createCard(cfg.Title or "Button", cfg.Description), cfg) end
	function obj:CreateToggle(cfg) return _comp_Toggle(window, createCard(cfg.Title or "Toggle", cfg.Description), cfg) end
	function obj:CreateSlider(cfg) return _comp_Slider(window, createCard(cfg.Title or "Slider", cfg.Description), cfg) end
	function obj:CreateDropdown(cfg) return _comp_Dropdown(window, createCard(cfg.Title or "Dropdown", cfg.Description), cfg) end
	function obj:CreateTextbox(cfg) return _comp_Textbox(window, createCard(cfg.Title or "Textbox", cfg.Description), cfg) end
	function obj:CreateKeybind(cfg) return _comp_Keybind(window, createCard(cfg.Title or "Keybind", cfg.Description), cfg) end
	function obj:CreateParagraph(cfg) return _comp_Paragraph(window, content, cfg) end
	return obj
end

-- ── Tab ────────────────────────────────────────────────────────────────────
local function createTabObject(window, name, icon)
	local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", Parent = window._sidebar })
	applyCorner(btn, UDim.new(0, 8)); local indicator = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(2, 14), Visible = false, Parent = btn }); applyCorner(indicator, UDim.new(1, 0))
	local iconH = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(12, 10), Parent = btn }); local iconV = createIconVisual(iconH, icon, name:sub(1, 1))
	local lab = create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -40, 1, 0), Font = Enum.Font.GothamBlack, Text = name:upper(), TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	local page = create("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(), ScrollBarThickness = 2, Visible = false, Parent = window._content }); applyPadding(page, 24, 24, 0, 24)
	local layout = create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = page }); layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 40) end)
	local tab = { _btn = btn, _page = page, _name = name, _defaultSection = nil }
	local function getDef() if not tab._defaultSection then tab._defaultSection = createSectionObject(window, page, "") end; return tab._defaultSection end
	function tab:CreateSection(sName) return createSectionObject(window, page, sName) end
	function tab:AddParagraph(cfg) return getDef():CreateParagraph(cfg) end
	function tab:AddButton(cfg) return getDef():CreateButton(cfg) end
	
	local function wrap(control, key, initialValue, cfg)
		local listeners = {}
		local origCallback = cfg.Callback
		local wrapped = { Value = initialValue }
		cfg.Callback = function(v)
			wrapped.Value = v
			for _, cb in ipairs(listeners) do safeCall(cb, v) end
			if origCallback then safeCall(origCallback, v) end
		end
		wrapped.OnChanged = function(_, cb) table.insert(listeners, cb); return { Disconnect = function() for k, v in pairs(listeners) do if v == cb then table.remove(listeners, k) break end end end } end
		wrapped.SetValue = function(_, v) control:Set(v) end
		wrapped.Get = function() return wrapped.Value end
		if key then window._options[key] = wrapped end
		return wrapped
	end

	function tab:AddToggle(key, cfg) return wrap(getDef():CreateToggle(cfg), key, not not cfg.Default, cfg) end
	function tab:AddSlider(key, cfg) if cfg.Rounding ~= nil then cfg.Step = cfg.Rounding end; return wrap(getDef():CreateSlider(cfg), key, cfg.Default or cfg.Min or 0, cfg) end
	function tab:AddDropdown(key, cfg) 
		local items = cfg.Values or cfg.Items or {}
		local def = cfg.Default
		if type(def) == "number" then def = items[def] end
		return wrap(getDef():CreateDropdown(cfg), key, def or items[1], cfg) 
	end

	window:_registerStyler(function(colors)
		local active = window._activeTab == tab; btn.BackgroundColor3 = Color3.new(1, 1, 1); btn.BackgroundTransparency = active and 0.9 or 1; indicator.Visible = active; indicator.BackgroundColor3 = colors.Accent; lab.TextColor3 = colors.Text; lab.TextTransparency = active and 0 or 0.6
		if iconV:IsA("ImageLabel") then iconV.ImageColor3 = active and colors.Accent or colors.Text; iconV.ImageTransparency = active and 0 or 0.6 else iconV.TextColor3 = active and colors.Accent or colors.Text; iconV.TextTransparency = active and 0 or 0.6 end
	end)
	btn.MouseButton1Click:Connect(function() window:SelectTab(tab) end)
	return tab
end

-- ── Window ─────────────────────────────────────────────────────────────────
local SnowyLib = {}
SnowyLib.__index = SnowyLib
function SnowyLib:_getColors() return THEMES[self.ThemeName or "Dark"] end
function SnowyLib:_registerStyler(cb) table.insert(self._stylers, cb); cb(self:_getColors()) end
function SnowyLib:_refreshTheme() local c = self:_getColors(); for _, cb in ipairs(self._stylers) do cb(c) end end
function SnowyLib:SelectTab(tab) if self._activeTab then self._activeTab._page.Visible = false end; self._activeTab = tab; self._pageTitle.Text = tab._name:upper(); tab._page.Visible = true; self:_refreshTheme() end
function SnowyLib:Notify(cfg)
	local colors = self:_getColors(); local toast = create("Frame", { Size = UDim2.fromOffset(240, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(12, 12, 14), BackgroundTransparency = 0.1, Parent = self._notifyHolder })
	applyCorner(toast, UDim.new(0, 12)); applyStroke(toast, 1, Color3.new(1, 1, 1), 0.95); applyPadding(toast, 16, 16, 14, 14); create("UIListLayout", { Padding = UDim.new(0, 4), Parent = toast })
	create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), Font = Enum.Font.GothamBlack, Text = (cfg.Title or "NOTICE"):upper(), TextSize = 10, TextColor3 = colors.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = toast })
	create("TextLabel", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Font = Enum.Font.GothamMedium, Text = cfg.Content or "", TextSize = 11, TextColor3 = colors.Text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = toast })
	local bar = create("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = colors.Accent, BackgroundTransparency = 0.4, Parent = toast })
	task.spawn(function() local dur = cfg.Duration or 5; tween(bar, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }); task.wait(dur); toast:Destroy() end)
end
function SnowyLib:Dialog(cfg)
	self._dialog.Visible = true; self._dialogTitle.Text = (cfg.Title or "DIALOG"):upper(); self._dialogBody.Text = cfg.Content or ""
	for _, v in ipairs(self._dialogButtons:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
	for _, bCfg in ipairs(cfg.Buttons or {}) do
		local btn = create("TextButton", { Size = UDim2.new(0, 100, 0, 30), Font = Enum.Font.GothamBold, Text = bCfg.Title:upper(), TextSize = 10, Parent = self._dialogButtons })
		applyCorner(btn, UDim.new(0, 8)); local s = applyStroke(btn, 1); local colors = self:_getColors()
		if bCfg.Primary then btn.BackgroundColor3 = Color3.new(1, 1, 1); btn.TextColor3 = Color3.new(0, 0, 0); s.Color = Color3.new(1, 1, 1)
		else btn.BackgroundColor3 = colors.SurfaceAlt; btn.TextColor3 = colors.Text; s.Color = colors.Stroke end
		btn.MouseButton1Click:Connect(function() self._dialog.Visible = false; safeCall(bCfg.Callback) end)
	end
end
function SnowyLib:LoadSettings(tab)
	local s = tab:CreateSection("Appearance")
	s:CreateDropdown({ Title = "Theme", Values = {"Dark", "Aqua", "Rose", "Amethyst", "Midnight", "Emerald", "Darker"}, Callback = function(v) self.ThemeName = v; self:_refreshTheme() end })
	s:CreateButton({ Title = "Destroy UI", Callback = function() self:Destroy() end })
end
function SnowyLib:Destroy()
	for _, connection in ipairs(self._connections) do if connection and connection.Disconnect then connection:Disconnect() end end
	self._screen:Destroy()
end

function SnowyLib.CreateWindow(config)
	local self = setmetatable({ _stylers = {}, _connections = {}, _tabs = {}, _options = {}, ThemeName = config.Theme or "Dark", Visible = true }, SnowyLib)
	local screen = create("ScreenGui", { Name = "SnowyLib", IgnoreGuiInset = true, ResetOnSpawn = false, Parent = localPlayer:WaitForChild("PlayerGui") })
	self._screen = screen; local main = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(640, 460), Parent = screen })
	applyCorner(main, UDim.new(0, 24)); local mStroke = applyStroke(main, 2); self._main = main
	local head = create("Frame", { Size = UDim2.new(1, 0, 0, 54), BackgroundTransparency = 0.97, Parent = main }); applyCorner(head, UDim.new(0, 24)); applyPadding(head, 24, 24, 0, 0)
	local title = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = (config.Title or "SNOWY LIB"):upper(), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = head })
	local close = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, Text = "×", TextSize = 18, Parent = head })
	local body = create("Frame", { Position = UDim2.fromOffset(0, 54), Size = UDim2.new(1, 0, 1, -54), BackgroundTransparency = 1, Parent = main })
	local side = create("Frame", { Size = UDim2.new(0, 160, 1, 0), BackgroundTransparency = 0.9, Parent = body }); applyPadding(side, 12, 12, 12, 12); create("UIListLayout", { Padding = UDim.new(0, 4), Parent = side }); self._sidebar = side
	local cont = create("Frame", { Position = UDim2.fromOffset(160, 0), Size = UDim2.new(1, -160, 1, 0), BackgroundTransparency = 1, Parent = body }); self._content = cont
	local pHead = create("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, Parent = cont }); applyPadding(pHead, 24, 24, 0, 0)
	local pTit = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBlack, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, Parent = pHead }); self._pageTitle = pTit
	self._notifyHolder = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24, 0, 24), Size = UDim2.new(0, 240, 1, 0), BackgroundTransparency = 1, Parent = screen }); create("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 10), Parent = self._notifyHolder })
	local diag = create("Frame", { Visible = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.4, Parent = screen }); self._dialog = diag
	local dCard = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(300, 160), Parent = diag }); applyCorner(dCard, UDim.new(0, 16)); applyStroke(dCard, 2, Color3.new(1,1,1), 0.9); applyPadding(dCard, 20, 20, 20, 20)
	create("UIListLayout", { Padding = UDim.new(0, 10), Parent = dCard }); local dT = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.GothamBlack, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = dCard }); self._dialogTitle = dT
	local dB = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 60), Font = Enum.Font.GothamMedium, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = dCard }); self._dialogBody = dB
	local dButs = create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = dCard }); create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), Parent = dButs }); self._dialogButtons = dButs
	self:_registerStyler(function(colors)
		main.BackgroundColor3 = colors.Background; main.BackgroundTransparency = 0.05; mStroke.Color = Color3.new(1,1,1); mStroke.Transparency = 0.8
		title.TextColor3 = colors.Text; close.TextColor3 = colors.Text; side.BackgroundColor3 = Color3.new(0,0,0); pTit.TextColor3 = colors.Accent
		dCard.BackgroundColor3 = colors.Background; dT.TextColor3 = colors.Accent; dB.TextColor3 = colors.Text
	end)
	makeDraggable(self, head, main); close.MouseButton1Click:Connect(function() self:Destroy() end)
	
	-- Floating Toggle (Website Style)
	local float = create("ImageButton", { Name = "Float", Position = UDim2.fromOffset(32, 32), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = Color3.fromRGB(20, 20, 26), BorderSizePixel = 0, AutoButtonColor = false, Image = config.Logo or "rbxassetid://6031075938", Parent = screen })
	applyCorner(float, UDim.new(0, 12)); applyStroke(float, 1, Color3.new(1,1,1), 0.9)
	local dot = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 1, 0, -1), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Color3.fromRGB(239, 68, 68), Visible = false, Parent = float })
	applyCorner(dot, UDim.new(1, 0)); applyStroke(dot, 2, Color3.fromRGB(26, 26, 26))
	local tip = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(1, 14, 0.5, 0), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 24), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.1, Visible = false, Parent = float })
	applyCorner(tip, UDim.new(0, 8)); applyStroke(tip, 1, Color3.new(1,1,1), 0.9); applyPadding(tip, 10, 10, 0, 0)
	create("TextLabel", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = "OPEN " .. (config.Title or "HUB"):upper(), TextSize = 9, TextColor3 = Color3.new(1,1,1), Parent = tip })

	float.MouseEnter:Connect(function() if not main.Visible then tip.Visible = true end end)
	float.MouseLeave:Connect(function() tip.Visible = false end)
	float.MouseButton1Click:Connect(function() main.Visible = not main.Visible; dot.Visible = not main.Visible; tip.Visible = false end)
	task.spawn(function() while float.Parent do if dot.Visible then tween(dot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.5 }); task.wait(0.6); tween(dot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0 }); task.wait(0.6) else task.wait(0.5) end end end)

	table.insert(self._connections, UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == (config.ToggleKey or Enum.KeyCode.RightControl) then main.Visible = not main.Visible; dot.Visible = not main.Visible end end))
	self.Options = setmetatable({}, { __index = function(_, k) return self._options[k] end })
	function self:CreateTab(cfg) local t = createTabObject(self, cfg.Title or "Tab", cfg.Icon); table.insert(self._tabs, t); if #self._tabs == 1 then self:SelectTab(t) end; return t end
	return self
end
return SnowyLib
