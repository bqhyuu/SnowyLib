-- SnowyLib — Final Responsive Masterpiece (1:1 Website Fidelity)
-- Resolves: Animation smoothness, Responsive sizing, Draggable Toggle.

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local localPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local RAW = "https://raw.githubusercontent.com/bqhyuu/SnowyLib/refs/heads/main/"
local LUCIDE_ICONS   = loadstring(game:HttpGet(RAW .. "Icon/LucideIcons.lua"))()
local PHOSPHOR_ICONS = loadstring(game:HttpGet(RAW .. "Icon/PhosphorIcons.lua"))()

local THEMES = {
	Dark     = { bg = Color3.fromRGB(8, 8, 10),   accent = Color3.fromRGB(255, 255, 255) },
	Aqua     = { bg = Color3.fromRGB(5, 16, 16),  accent = Color3.fromRGB(0, 255, 255)   },
	Rose     = { bg = Color3.fromRGB(18, 8, 10),  accent = Color3.fromRGB(251, 113, 133) },
	Amethyst = { bg = Color3.fromRGB(13, 8, 18),  accent = Color3.fromRGB(168, 85, 247) },
	Darker   = { bg = Color3.fromRGB(0, 0, 0),    accent = Color3.fromRGB(255, 255, 255) },
}

-- ── Constants ──────────────────────────────────────────────────────────────

local SPRING_FAST = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SPRING_SLO  = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local LINEAR      = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
local HEADER_H    = 54
local SIDEBAR_W   = 160

-- ── Utilities ──────────────────────────────────────────────────────────────

local function create(instanceType, props)
	local inst = Instance.new(instanceType)
	for k, v in pairs(props or {}) do inst[k] = v end
	return inst
end

local function applyCorner(inst, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius
	c.Parent = inst
	return c
end

local function applyStroke(inst, thickness, color, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness or 2
	s.Color = color or Color3.new(1, 1, 1)
	s.Transparency = transparency or 0.8
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

local function applyPadding(inst, l, r, t, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.Parent = inst
	return p
end

local function resolveIcon(name)
	if not name or name == "" then return nil end
	if string.find(name, "rbxassetid://", 1, true) or string.find(name, "http", 1, true) then return name end
	local pre, rest = string.match(name, "^(%a+):(.+)$")
	if pre == "ph" then return PHOSPHOR_ICONS["ph-" .. rest] or PHOSPHOR_ICONS[rest] end
	return LUCIDE_ICONS["lucide-" .. name] or LUCIDE_ICONS[name] or PHOSPHOR_ICONS["ph-" .. name] or PHOSPHOR_ICONS[name]
end

local function tween(inst, info, props)
	local t = TweenService:Create(inst, info, props)
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
	if resolved and (type(resolved) == "string" and (string.find(resolved, "rbxassetid://") or string.find(resolved, "http"))) then
		return create("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14), Image = resolved, Parent = parent })
	end
	return create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14), Font = Enum.Font.GothamBold, Text = tostring(fallbackText or "•"), TextSize = 10, Parent = parent })
end

-- ── Component Implementation ───────────────────────────────────────────────

local function createParagraph(window, parent, cfg)
	local card = create("Frame", { Name = "Paragraph", AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = parent })
	applyCorner(card, UDim.new(0, 12)); applyStroke(card, 2, Color3.new(1, 1, 1), 0.9); applyPadding(card, 14, 14, 14, 14)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = card })

	local tit = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), Font = Enum.Font.GothamBlack, Text = (cfg.Title or "INFO"):upper(), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
	local bdy = create("TextLabel", { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Font = Enum.Font.GothamMedium, Text = cfg.Content or "", TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
	
	window:_registerStyler(function(c)
		card.BackgroundColor3 = Color3.new(1, 1, 1); card.BackgroundTransparency = 0.96
		tit.TextColor3 = c.accent; bdy.TextColor3 = Color3.new(1, 1, 1); bdy.TextTransparency = 0.5
	end)
	return card
end

local function createToggle(window, parts, cfg)
	local value = not not cfg.Default
	local track = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(32, 16), Parent = parts.Right })
	applyCorner(track, UDim.new(1, 0)); local s = applyStroke(track, 2)
	local knob = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(10, 10), Parent = track })
	applyCorner(knob, UDim.new(1, 0))

	local function render(anim)
		local c = window:_getColors()
		if value then
			tween(track, SPRING_FAST, { BackgroundColor3 = c.accent, BackgroundTransparency = 0 })
			tween(knob, SPRING_FAST, { Position = UDim2.new(0, 18, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0 })
			s.Transparency = 0.9
		else
			tween(track, SPRING_FAST, { BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.9 })
			tween(knob, SPRING_FAST, { Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.6 })
			s.Transparency = 0.95
		end
	end
	window:_registerStyler(function() render(false) end)
	local ctrl = {}
	function ctrl:Set(st) value = st; render(true); if cfg.Callback then cfg.Callback(value) end end
	function ctrl:Get() return value end
	parts.Hitbox.MouseButton1Click:Connect(function() ctrl:Set(not value) end)
	return ctrl
end

local function createSlider(window, parts, cfg)
	local min, max, step = cfg.Min or 0, cfg.Max or 100, cfg.Step or 0.1
	local val = math.clamp(cfg.Default or min, min, max)

	local area = create("Frame", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Parent = parts.Card, LayoutOrder = 10 })
	local trk = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 2), Parent = area })
	applyCorner(trk, UDim.new(1, 0)); local fil = create("Frame", { Size = UDim2.new(0, 0, 1, 0), Parent = trk }); applyCorner(fil, UDim.new(1, 0))
	local knb = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(12, 12), Parent = trk }); applyCorner(knb, UDim.new(1, 0)); applyStroke(knb, 2, Color3.new(1, 1, 1), 0.7)

	local box = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(42, 20), Parent = parts.Right })
	applyCorner(box, UDim.new(0, 8)); local bS = applyStroke(box, 2); local inp = create("TextBox", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 9, Parent = box })

	local function render()
		local c = window:_getColors()
		local a = (val - min) / math.max(max - min, 0.0001)
		tween(fil, SPRING_FAST, { Size = UDim2.new(a, 0, 1, 0), BackgroundColor3 = c.accent })
		tween(knb, SPRING_FAST, { Position = UDim2.new(a, 0, 0.5, 0) })
		inp.Text = tostring(math.floor(val * 10) / 10); trk.BackgroundColor3 = Color3.new(1, 1, 1); trk.BackgroundTransparency = 0.9; box.BackgroundColor3 = Color3.new(0, 0, 0); box.BackgroundTransparency = 0.4; inp.TextColor3 = c.accent; bS.Transparency = 0.9
	end
	local drag = false
	local function update(i)
		local a = math.clamp((i.Position.X - trk.AbsolutePosition.X) / math.max(trk.AbsoluteSize.X, 1), 0, 1)
		val = min + (max - min) * a; if step > 0 then val = math.floor(val / step + 0.5) * step end; val = math.clamp(val, min, max); render(); if cfg.Callback then cfg.Callback(val) end
	end
	area.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; update(i) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
	UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
	window:_registerStyler(render); return { Set = function(_, v) val = v; render() end, Get = function() return val end }
end

local function createDropdown(window, parts, cfg)
	local items = cfg.Values or cfg.Items or {}
	local multi = cfg.Multi
	local selected = multi and {} or (cfg.Default or items[1])
	if multi and cfg.Default then for _, v in ipairs(cfg.Default) do selected[v] = true end end
	local open = false

	local trig = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(140, 26), AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = parts.Right })
	applyCorner(trig, UDim.new(0, 8)); applyPadding(trig, 10, 20, 0, 0); local tS = applyStroke(trig, 2)
	local chev = create("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Text = "v", Font = Enum.Font.GothamBold, TextSize = 8, Parent = trig })
	
	local expand = create("Frame", { Visible = false, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = parts.Card, LayoutOrder = 20 })
	local list = create("Frame", { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = expand })
	applyCorner(list, UDim.new(0, 12)); local lS = applyStroke(list, 2); create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = list }); applyPadding(list, 4, 4, 4, 4)

	local sFrm = create("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = list, LayoutOrder = -1 })
	applyPadding(sFrm, 4, 4, 0, 4); local sInp = create("TextBox", { Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamMedium, TextSize = 9, PlaceholderText = "Search...", Parent = sFrm })
	applyCorner(sInp, UDim.new(0, 6)); applyPadding(sInp, 8, 8, 0, 0); local sS = applyStroke(sInp, 1)

	local function updateTrig()
		if multi then local c = 0; for _ in pairs(selected) do c += 1 end; trig.Text = c == 0 and "SELECT..." or (c .. " SELECTED")
		else trig.Text = tostring(selected):upper() end
	end
	local function build(q)
		q = q and q:lower() or ""
		for _, v in ipairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, item in ipairs(items) do
			if q == "" or item:lower():find(q) then
				local isSel = multi and selected[item] or (selected == item)
				local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 26), AutoButtonColor = false, Font = Enum.Font.GothamBold, Text = item:upper(), TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = list })
				applyCorner(btn, UDim.new(0, 8)); applyPadding(btn, 10, 10, 0, 0)
				local colors = window:_getColors()
				btn.BackgroundColor3 = isSel and colors.accent or Color3.new(1, 1, 1); btn.BackgroundTransparency = isSel and 0.9 or 1
				btn.TextColor3 = isSel and colors.accent or Color3.new(1,1,1); btn.TextTransparency = isSel and 0 or 0.6
				btn.MouseButton1Click:Connect(function()
					if multi then selected[item] = not selected[item] else selected = item; open = false; expand.Visible = false end
					updateTrig(); build(sInp.Text); if cfg.Callback then cfg.Callback(multi and selected or selected) end
				end)
			end
		end
	end
	trig.MouseButton1Click:Connect(function() open = not open; expand.Visible = open; build(sInp.Text) end)
	sInp:GetPropertyChangedSignal("Text"):Connect(function() build(sInp.Text) end)
	window:_registerStyler(function(c)
		trig.BackgroundColor3 = Color3.new(0, 0, 0); trig.BackgroundTransparency = 0.6; trig.TextColor3 = Color3.new(1,1,1); tS.Transparency = 0.9; chev.TextColor3 = c.accent; list.BackgroundColor3 = Color3.fromRGB(18, 18, 20); list.BackgroundTransparency = 0.05; lS.Transparency = 0.85; sInp.BackgroundColor3 = Color3.new(1,1,1); sInp.BackgroundTransparency = 0.95; sInp.TextColor3 = Color3.new(1,1,1); sS.Transparency = 0.9
	end)
	updateTrig(); return { Set = function(_, v) selected = v; updateTrig(); if open then build(sInp.Text) end end }
end

-- ── Section & Core Logic ───────────────────────────────────────────────────

local function createSection(window, parent, name)
	local wrapper = create("Frame", { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = parent })
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = wrapper })
	
	if name and name ~= "" then
		local h = create("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = wrapper })
		local lab = create("TextLabel", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = name:upper(), TextSize = 9, Parent = h })
		local line = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(1, -60, 0, 1), Parent = h })
		window:_registerStyler(function(c) lab.TextColor3 = c.accent; lab.TextTransparency = 0.6; line.BackgroundColor3 = Color3.new(1, 1, 1); line.BackgroundTransparency = 0.9 end)
		lab:GetPropertyChangedSignal("TextBounds"):Connect(function() line.Size = UDim2.new(1, -lab.TextBounds.X - 12, 0, 1) end)
	end

	local function createCard(title, desc)
		local card = create("Frame", { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = wrapper })
		applyCorner(card, UDim.new(0, 12)); local s = applyStroke(card, 2); applyPadding(card, 12, 12, 10, 10)
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = card })
		local top = create("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = card })
		local tit = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Enum.Font.GothamBold, Text = title, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = top })
		if desc and desc ~= "" then
			top.Size = UDim2.new(1, 0, 0, 34); local d = create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 16), Size = UDim2.new(0.6, 0, 0, 14), Font = Enum.Font.GothamMedium, Text = desc, TextSize = 9, Parent = top })
			window:_registerStyler(function() d.TextColor3 = Color3.new(1,1,1); d.TextTransparency = 0.5 end)
		end
		local right = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1, Parent = top })
		local hb = create("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", Parent = card, ZIndex = 5 })
		window:_registerStyler(function() card.BackgroundColor3 = Color3.new(1, 1, 1); card.BackgroundTransparency = 0.97; s.Color = Color3.new(1, 1, 1); s.Transparency = 0.95; tit.TextColor3 = Color3.new(1,1,1) end)
		return { Card = card, Right = right, Hitbox = hb }
	end

	local obj = {}
	function obj:CreateButton(c)
		local b = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 120, 0, 28), AutoButtonColor = false, Font = Enum.Font.GothamBold, Text = (c.ButtonText or c.Title or "RUN"):upper(), TextSize = 10, Parent = createCard(c.Title or "Button", c.Description).Right })
		applyCorner(b, UDim.new(0, 10)); applyStroke(b, 1)
		window:_registerStyler(function() b.BackgroundColor3 = Color3.new(1, 1, 1); b.BackgroundTransparency = 0.9; b.TextColor3 = Color3.new(1,1,1) end)
		b.MouseButton1Click:Connect(function() if c.Callback then c.Callback() end end); return { SetText = function(_, t) b.Text = t:upper() end }
	end
	function obj:CreateToggle(c) return createToggle(window, createCard(c.Title or "Toggle", c.Description), c) end
	function obj:CreateSlider(c) return createSlider(window, createCard(c.Title or "Slider", c.Description), c) end
	function obj:CreateDropdown(c) return createDropdown(window, createCard(c.Title or "Dropdown", c.Description), c) end
	function obj:CreateParagraph(c) return createParagraph(window, wrapper, c) end
	function obj:CreateTextbox(c)
		local box = create("TextBox", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(140, 26), Font = Enum.Font.GothamBold, TextSize = 9, PlaceholderText = c.Placeholder or "TYPE...", Parent = createCard(c.Title or "Textbox", c.Description).Right })
		applyCorner(box, UDim.new(0, 8)); applyPadding(box, 10, 10, 0, 0); applyStroke(box, 2)
		window:_registerStyler(function() box.BackgroundColor3 = Color3.new(0,0,0); box.BackgroundTransparency = 0.6; box.TextColor3 = Color3.new(1,1,1) end)
		box.FocusLost:Connect(function() if c.Callback then c.Callback(box.Text) end end); return { Set = function(_, v) box.Text = v end }
	end
	function obj:CreateKeybind(c)
		local curr = c.Default or Enum.KeyCode.RightControl; local listen = false
		local btn = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(100, 26), Font = Enum.Font.GothamBlack, TextSize = 9, Parent = createCard(c.Title or "Keybind", c.Description).Right })
		applyCorner(btn, UDim.new(0, 8)); local s = applyStroke(btn, 2)
		local function ren() btn.Text = listen and "LISTENING..." or (curr.Name:upper()); local colors = window:_getColors()
			btn.BackgroundColor3 = Color3.new(0,0,0); btn.BackgroundTransparency = 0.6; btn.TextColor3 = listen and colors.accent or Color3.new(1,1,1); s.Color = listen and colors.accent or Color3.new(1,1,1); s.Transparency = listen and 0.5 or 0.9
		end
		btn.MouseButton1Click:Connect(function() listen = true; ren() end)
		UserInputService.InputBegan:Connect(function(i, g) if g then return end if listen then if i.KeyCode ~= Enum.KeyCode.Unknown then curr = i.KeyCode; listen = false; ren(); if c.Callback then c.Callback(curr) end end elseif i.KeyCode == curr then if c.Pressed then c.Pressed() end end end)
		window:_registerStyler(ren); return { Set = function(_, v) curr = v; ren() end }
	end
	return obj
end

-- ── Tab Logic ──────────────────────────────────────────────────────────────

local function createTab(window, name, icon)
	local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", Parent = window._sidebar })
	applyCorner(btn, UDim.new(0, 10))
	local indicator = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(2, 14), Visible = false, Parent = btn }); applyCorner(indicator, UDim.new(1, 0))
	local iconH = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(12, 11), Parent = btn })
	local iconV = createIconVisual(iconH, icon, name:sub(1, 1))
	local lab = create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -40, 1, 0), Font = Enum.Font.GothamBlack, Text = name:upper(), TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	local dot = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(4, 4), Visible = false, Parent = btn }); applyCorner(dot, UDim.new(1, 0))

	local pageContainer = create("CanvasGroup", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = window._content })
	local page = create("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(), ScrollBarThickness = 3, Parent = pageContainer })
	applyPadding(page, 24, 24, 24, 24); local layout = create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = page })
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 48) end)

	local tab = { _btn = btn, _pageContainer = pageContainer, _name = name }
	local defSect
	local function getDef() if not defSect then defSect = createSection(window, page, "") end; return defSect end

	function tab:CreateSection(n) return createSection(window, page, n) end
	function tab:AddParagraph(c) return getDef():CreateParagraph(c) end
	function tab:AddButton(c) return getDef():CreateButton(c) end
	function tab:AddToggle(k, c) local ctrl = getDef():CreateToggle(c); local w = { Value = not not c.Default }; w.SetValue = function(_, v) ctrl:Set(v) end; w.Get = function() return ctrl:Get() end; if k then window._options[k] = w end; return w end
	function tab:AddSlider(k, c) if c.Rounding then c.Step = c.Rounding end; local ctrl = getDef():CreateSlider(c); local w = { Value = c.Default or c.Min or 0 }; w.SetValue = function(_, v) ctrl:Set(v) end; w.Get = function() return ctrl:Get() end; if k then window._options[k] = w end; return w end
	function tab:AddDropdown(k, c) local ctrl = getDef():CreateDropdown(c); local w = { Value = c.Default or (c.Values or c.Items or {})[1] }; w.SetValue = function(_, v) ctrl:Set(v) end; w.Get = function() return ctrl:Get() end; if k then window._options[k] = w end; return w end

	window:_registerStyler(function(colors)
		local active = window._activeTab == tab
		btn.BackgroundColor3 = Color3.new(1, 1, 1); btn.BackgroundTransparency = active and 0.9 or 1
		indicator.Visible = active; indicator.BackgroundColor3 = colors.accent; dot.Visible = active; dot.BackgroundColor3 = colors.accent
		lab.TextColor3 = Color3.new(1, 1, 1); lab.TextTransparency = active and 0 or 0.6
		local iv = iconV; if iv:IsA("ImageLabel") then iv.ImageColor3 = active and colors.accent or Color3.new(1,1,1); iv.ImageTransparency = active and 0 or 0.6 else iv.TextColor3 = active and colors.accent or Color3.new(1,1,1); iv.TextTransparency = active and 0 or 0.6 end
	end)
	btn.MouseButton1Click:Connect(function() window:SelectTab(tab) end)
	return tab
end

-- ── Main Library ───────────────────────────────────────────────────────────

local SnowyLib = {}
SnowyLib.__index = SnowyLib

function SnowyLib:_getColors() return THEMES[self.ThemeName or "Dark"] end
function SnowyLib:_registerStyler(cb) table.insert(self._stylers, cb); cb(self:_getColors()) end
function SnowyLib:_refreshTheme() local c = self:_getColors(); for _, cb in ipairs(self._stylers) do cb(c) end end

function SnowyLib:SelectTab(tab)
	if self._activeTab == tab then return end
	if self._activeTab then
		local prev = self._activeTab._pageContainer
		tween(prev, SPRING_FAST, { GroupTransparency = 1, Position = UDim2.fromOffset(0, 15) })
		task.delay(0.2, function() prev.Visible = false end)
	end
	self._activeTab = tab
	tab._pageContainer.Visible = true; tab._pageContainer.GroupTransparency = 1; tab._pageContainer.Position = UDim2.fromOffset(0, 15)
	tween(tab._pageContainer, SPRING_SLO, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) })
	self:_refreshTheme()
end

function SnowyLib:Notify(cfg)
	local toast = create("Frame", { Name = "Toast", Size = UDim2.fromOffset(240, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(12, 12, 14), Parent = self._notifyHolder })
	applyCorner(toast, UDim.new(0, 12)); applyStroke(toast, 2, Color3.new(1,1,1), 0.95); applyPadding(toast, 16, 40, 14, 14)
	create("UIListLayout", { Padding = UDim.new(0, 4), Parent = toast })
	local tit = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), Font = Enum.Font.GothamBlack, Text = (cfg.Title or "NOTICE"):upper(), TextSize = 10, Parent = toast })
	local bdy = create("TextLabel", { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Font = Enum.Font.GothamMedium, Text = cfg.Content or "", TextSize = 11, TextColor3 = Color3.new(1,1,1), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = toast })
	local bar = create("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), Parent = toast })
	local cls = create("TextButton", { Position = UDim2.new(1, 24, 0, 0), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Text = "×", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1), Parent = toast })
	cls.MouseButton1Click:Connect(function() toast:Destroy() end)
	self:_registerStyler(function(c) tit.TextColor3 = c.accent; bar.BackgroundColor3 = c.accent end)
	task.spawn(function() local d = cfg.Duration or 5; tween(bar, LINEAR, { Size = UDim2.new(0, 0, 0, 2) }); task.wait(d); if toast.Parent then toast:Destroy() end end)
end

function SnowyLib:Dialog(cfg)
	self._diag.Visible = true; self._diagT.Text = (cfg.Title or "DIALOG"):upper(); self._diagB.Text = cfg.Content or ""
	for _, v in ipairs(self._diagButs:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
	for _, b in ipairs(cfg.Buttons or {}) do
		local btn = create("TextButton", { Size = UDim2.new(0, 100, 0, 32), Font = Enum.Font.GothamBlack, Text = b.Title:upper(), TextSize = 9, Parent = self._diagButs })
		applyCorner(btn, UDim.new(0, 10)); applyStroke(btn, 1)
		if b.Primary then btn.BackgroundColor3 = Color3.new(1,1,1); btn.TextColor3 = Color3.new(0,0,0)
		else btn.BackgroundColor3 = Color3.new(1,1,1); btn.BackgroundTransparency = 0.95; btn.TextColor3 = Color3.new(1,1,1); btn.TextTransparency = 0.6 end
		btn.MouseButton1Click:Connect(function() self._diag.Visible = false; if b.Callback then b.Callback() end end)
	end
end

function SnowyLib:LoadSettings(t)
	local s = t:CreateSection("Settings")
	s:CreateDropdown({ Title = "Theme", Values = {"Dark", "Aqua", "Rose", "Amethyst", "Darker"}, Callback = function(v) self.ThemeName = v; self:_refreshTheme() end })
	s:CreateButton({ Title = "Destroy", Callback = function() self:Destroy() end })
end

function SnowyLib:Destroy() for _, c in ipairs(self._connections) do if c and c.Disconnect then c:Disconnect() end end; self._screen:Destroy() end

function SnowyLib.CreateWindow(config)
	config = config or {}
	local self = setmetatable({ _stylers = {}, _connections = {}, _tabs = {}, _options = {}, ThemeName = config.Theme or "Dark" }, SnowyLib)
	local screen = create("ScreenGui", { Name = "SnowyLib", IgnoreGuiInset = true, ResetOnSpawn = false, Parent = localPlayer:WaitForChild("PlayerGui") })
	self._screen = screen

	-- Fixed Responsive Size
	local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
	local w = math.min(640, vw * 0.92)
	local h = math.min(460, vh * 0.88)

	local main = create("CanvasGroup", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(w, h), Parent = screen })
	applyCorner(main, UDim.new(0, 24)); local mStroke = applyStroke(main, 2, Color3.new(1,1,1), 0.8); self._main = main
	local mScale = create("UIScale", { Scale = 1, Parent = main })

	local pattern = create("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "rbxassetid://13217036657", ImageTransparency = 0.97, TileSize = UDim2.fromOffset(24, 24), ScaleType = Enum.ScaleType.Tile, ZIndex = 0, Parent = main })

	main.GroupTransparency = 1; mScale.Scale = 0.6
	tween(main, SPRING_SLO, { GroupTransparency = 0 }); tween(mScale, SPRING_SLO, { Scale = 1 })

	task.spawn(function()
		while main.Parent do
			local c = self:_getColors().accent
			tween(mStroke, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.4, Color = c })
			task.wait(2.5)
			tween(mStroke, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.8, Color = Color3.new(1,1,1) })
			task.wait(2.5)
		end
	end)

	local head = create("Frame", { Size = UDim2.new(1, 0, 0, HEADER_H), BackgroundTransparency = 0.97, Parent = main })
	applyCorner(head, UDim.new(0, 24)); applyPadding(head, 24, 24, 0, 0)
	local tit = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = (config.Title or "MEYY HUB"):upper(), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = head })
	local close = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1, Text = "×", Font = Enum.Font.GothamBlack, TextSize = 18, Parent = head })

	local body = create("Frame", { Position = UDim2.fromOffset(0, HEADER_H), Size = UDim2.new(1, 0, 1, -HEADER_H), BackgroundTransparency = 1, Parent = main })
	local side = create("Frame", { Size = UDim2.new(0, SIDEBAR_W, 1, 0), Parent = body })
	applyPadding(side, 12, 12, 12, 12); create("UIListLayout", { Padding = UDim.new(0, 4), Parent = side }); self._sidebar = side
	local cont = create("Frame", { Position = UDim2.fromOffset(SIDEBAR_W, 0), Size = UDim2.new(1, -SIDEBAR_W, 1, 0), BackgroundTransparency = 1, Parent = body }); self._content = cont
	local pHead = create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Parent = cont }); applyPadding(pHead, 24, 24, 0, 0)
	local pTit = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBlack, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, Parent = pHead }); self._pageTitle = pTit

	self._notifyHolder = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24, 0, 24), Size = UDim2.new(0, 240, 1, 0), BackgroundTransparency = 1, Parent = screen })
	create("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 10), Parent = self._notifyHolder })

	local diag = create("Frame", { Visible = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5, Parent = screen, ZIndex = 100 })
	self._diag = diag; local dCard = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(300, 160), Parent = diag })
	applyCorner(dCard, UDim.new(0, 20)); applyStroke(dCard, 2, Color3.new(1,1,1), 0.9); applyPadding(dCard, 24, 24, 24, 24)
	create("UIListLayout", { Padding = UDim.new(0, 8), Parent = dCard })
	self._diagT = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.GothamBlack, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = dCard })
	self._diagB = create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -60), Font = Enum.Font.GothamMedium, TextSize = 9, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = dCard })
	self._diagButs = create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = dCard }); create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), Parent = self._diagButs })

	self:_registerStyler(function(c)
		main.BackgroundColor3 = c.bg; main.BackgroundTransparency = 0.15
		pTit.TextColor3 = c.accent; dCard.BackgroundColor3 = c.bg; self._diagT.TextColor3 = Color3.new(1,1,1); self._diagB.TextColor3 = Color3.new(1,1,1); self._diagB.TextTransparency = 0.3
	end)

	makeDraggable(self, head, main); close.MouseButton1Click:Connect(function() self:Destroy() end)
	
	-- Persistent Floating Toggle Button
	local float = create("ImageButton", { Name = "Float", Position = UDim2.fromOffset(32, 32), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = Color3.fromRGB(20, 20, 26), Parent = screen })
	applyCorner(float, UDim.new(0, 12)); applyStroke(float, 1, Color3.new(1,1,1), 0.9); float.Image = config.Logo or "rbxassetid://6031075938"
	local dot = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 2, 0, -2), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Color3.fromRGB(239, 68, 68), Visible = false, Parent = float })
	applyCorner(dot, UDim.new(1, 0)); applyStroke(dot, 2, Color3.fromRGB(26,26,26))
	
	local function toggleUI()
		if not main.Visible then
			main.Visible = true; dot.Visible = false
			tween(main, SPRING_FAST, { GroupTransparency = 0 }); tween(mScale, SPRING_FAST, { Scale = 1 })
		else
			dot.Visible = true
			tween(mScale, SPRING_FAST, { Scale = 0.7 })
			local t = tween(main, SPRING_FAST, { GroupTransparency = 1 })
			t.Completed:Connect(function() main.Visible = false end)
		end
	end

	float.MouseButton1Click:Connect(toggleUI); makeDraggable(self, float, float)
	task.spawn(function() while float.Parent do if dot.Visible then tween(dot, LINEAR, { BackgroundTransparency = 0.5 }); task.wait(0.6); tween(dot, LINEAR, { BackgroundTransparency = 0 }); task.wait(0.6) else task.wait(0.5) end end end)

	table.insert(self._connections, UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == (config.ToggleKey or Enum.KeyCode.RightControl) then toggleUI() end end))
	self.Options = setmetatable({}, { __index = function(_, k) return self._options[k] end })
	function self:CreateTab(c) local t = createTab(self, c.Title or "Tab", c.Icon); table.insert(self._tabs, t); if #self._tabs == 1 then self:SelectTab(t) end; return t end
	return self
end

return SnowyLib
