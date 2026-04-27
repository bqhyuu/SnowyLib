--[[
    SNOWY LIB — ULTIMATE ANNIVERSARY EDITION (V8)
    100% English | Pixel-Perfect Website Fidelity | Premium Hub Effects
--]]

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
	Dark     = { bg = Color3.fromRGB(8, 8, 10),   accent = Color3.fromRGB(255, 255, 255), particle = "137906289429512" },
	Aqua     = { bg = Color3.fromRGB(5, 16, 16),  accent = Color3.fromRGB(0, 255, 255),   particle = "116750779040036" },
	Rose     = { bg = Color3.fromRGB(18, 8, 10),  accent = Color3.fromRGB(251, 113, 133), particle = "129633366976969" },
	Amethyst = { bg = Color3.fromRGB(13, 8, 18),  accent = Color3.fromRGB(168, 85, 247), particle = "129633366976969" },
}

-- ── Constants ──────────────────────────────────────────────────────────────

local SPRING = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local QUICK  = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HEADER_H = 54
local SIDEBAR_W = 160

-- ── Internal Utilities ─────────────────────────────────────────────────────

local function create(instanceType, props)
	local inst = Instance.new(instanceType)
	for k, v in pairs(props or {}) do inst[k] = v end
	return inst
end

local function applyCorner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = inst
end

local function applyStroke(inst, color, thickness, trans)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness or 1.5
	s.Color = color or Color3.new(1, 1, 1)
	s.Transparency = trans or 0.8
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
end

local function resolveIcon(name)
	if not name or name == "" then return nil end
	if string.find(name, "rbxassetid://") or string.find(name, "http") then return name end
	local pre, rest = string.match(name, "^(%a+):(.+)$")
	if pre == "ph" then return PHOSPHOR_ICONS["ph-" .. rest] or PHOSPHOR_ICONS[rest] end
	return LUCIDE_ICONS["lucide-" .. name] or LUCIDE_ICONS[name] or PHOSPHOR_ICONS["ph-" .. name] or PHOSPHOR_ICONS[name]
end

local function tween(inst, info, props)
	local t = TweenService:Create(inst, info, props)
	t:Play()
	return t
end

local function makeDraggable(handle, target)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- ── Component Implementation ───────────────────────────────────────────────

local SnowyLib = {}
SnowyLib.__index = SnowyLib

function SnowyLib:_getColors() return THEMES[self.ThemeName or "Dark"] end
function SnowyLib:_registerStyler(cb) table.insert(self._stylers, cb); cb(self:_getColors()) end
function SnowyLib:_refreshTheme() local c = self:_getColors(); for _, cb in ipairs(self._stylers) do cb(c) end end

-- Tab Selection
function SnowyLib:SelectTab(tab)
	if self._activeTab == tab then return end
	if self._activeTab then
		local prev = self._activeTab._pageContainer
		tween(prev, QUICK, { GroupTransparency = 1, Position = UDim2.fromOffset(0, 15) })
		task.delay(0.2, function() prev.Visible = false end)
	end
	self._activeTab = tab
	tab._pageContainer.Visible = true; tab._pageContainer.GroupTransparency = 1; tab._pageContainer.Position = UDim2.fromOffset(0, 15)
	tween(tab._pageContainer, SPRING, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) })
	self:_refreshTheme()
end

-- Notification System
function SnowyLib:Notify(cfg)
	local toast = create("Frame", { Name = "Toast", Size = UDim2.fromOffset(240, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(12, 12, 14), Parent = self._notifyHolder })
	applyCorner(toast, 12); local s = applyStroke(toast, Color3.new(1,1,1), 2, 0.8); applyPadding(toast, 16, 40, 14, 14)
	create("UIListLayout", { Padding = UDim.new(0, 4), Parent = toast })
	
	local g = create("UIGradient", { Parent = s })
	local tit = create("TextLabel", { Text = (cfg.Title or "NOTICE"):upper(), Size = UDim2.new(1, 0, 0, 15), Font = Enum.Font.GothamBlack, TextSize = 10, BackgroundTransparency = 1, Parent = toast })
	local bdy = create("TextLabel", { Text = cfg.Content or "", AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.new(1,1,1), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = toast })
	local bar = create("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), Parent = toast })
	local cls = create("TextButton", { Position = UDim2.new(1, 24, 0, 0), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Text = "×", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1), Parent = toast })
	
	cls.MouseButton1Click:Connect(function() toast:Destroy() end)
	self:_registerStyler(function(c) 
		tit.TextColor3 = c.accent; bar.BackgroundColor3 = c.accent
		g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c.accent), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))})
	end)
	
	task.spawn(function()
		local d = cfg.Duration or 5
		tween(bar, TweenInfo.new(d, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
		task.wait(d); if toast.Parent then toast:Destroy() end
	end)
end

-- ── Main Library Builder ───────────────────────────────────────────────────

function SnowyLib.CreateWindow(config)
	config = config or {}
	local self = setmetatable({
		_stylers = {},
		_tabs = {},
		Options = {},
		ThemeName = config.Theme or "Dark",
		ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
	}, SnowyLib)

	local screen = create("ScreenGui", { Name = "SnowyLib", Parent = localPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false, IgnoreGuiInset = true })
	self._screen = screen

	-- Responsive Window Sizing
	local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
	local w = math.min(600, vw * 0.92)
	local h = math.min(400, vh * 0.88)

	local main = create("CanvasGroup", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(w, h), Parent = screen })
	applyCorner(main, 24); local mStroke = applyStroke(main, Color3.new(1,1,1), 2.5, 0.8); self._main = main
	local mScale = create("UIScale", { Parent = main })
	local mGrad = create("UIGradient", { Parent = mStroke })

	-- Background Texture (Scanlines)
	create("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "rbxassetid://13217036657", ImageTransparency = 0.97, TileSize = UDim2.fromOffset(24, 24), ScaleType = Enum.ScaleType.Tile, Parent = main })

	-- Particle System (Falling Petals/Snow)
	local particleContainer = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = main, ZIndex = 0 })
	task.spawn(function()
		while main.Parent do
			task.wait(0.15)
			if not main.Visible then continue end
			local colors = self:_getColors()
			local p = create("ImageLabel", { BackgroundTransparency = 1, Image = "rbxthumb://type=Asset&id=" .. colors.particle .. "&w=150&h=150", Parent = particleContainer })
			local size = math.random(14, 22)
			p.Size = UDim2.fromOffset(size, size)
			p.Position = UDim2.new(math.random(), 0, -0.1, 0)
			p.ImageTransparency = math.random(4, 7) / 10
			
			local t = tween(p, TweenInfo.new(math.random(4, 8), Enum.EasingStyle.Linear), { Position = UDim2.new(p.Position.X.Scale, math.random(-150, 150), 1.1, 0), Rotation = math.random(-180, 180) })
			t.Completed:Connect(function() p:Destroy() end)
		end
	end)

	-- Layout Structure
	local head = create("Frame", { Size = UDim2.new(1, 0, 0, HEADER_H), BackgroundTransparency = 0.98, Parent = main })
	applyPadding(head, 25, 25, 0, 0); makeDraggable(head, main)
	
	local title = create("TextLabel", { Text = (config.Title or "SNOWY HUB"):upper(), Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamBlack, TextSize = 13, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = head })
	local close = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(32, 32), BackgroundColor3 = Color3.fromRGB(255, 60, 60), Text = "×", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = Color3.new(1,1,1), Parent = head })
	applyCorner(close, 10)

	local sidebar = create("Frame", { Position = UDim2.fromOffset(0, HEADER_H), Size = UDim2.new(0, SIDEBAR_W, 1, -HEADER_H), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.96, Parent = main })
	applyCorner(sidebar, 24); applyPadding(sidebar, 12, 12, 15, 12)
	local tabList = create("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = sidebar })
	create("UIListLayout", { Padding = UDim.new(0, 4), Parent = tabList })

	local content = create("Frame", { Position = UDim2.fromOffset(SIDEBAR_W, HEADER_H), Size = UDim2.new(1, -SIDEBAR_W, 1, -HEADER_H), BackgroundTransparency = 1, Parent = main })
	self._content = content

	self._notifyHolder = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -25, 0, 25), Size = UDim2.new(0, 240, 1, 0), BackgroundTransparency = 1, Parent = screen })
	create("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 10), Parent = self._notifyHolder })

	-- Danger Zone Confirmation Dialog
	local diagOverlay = create("Frame", { Visible = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5, ZIndex = 100, Parent = screen })
	local dCard = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(300, 160), Parent = diagOverlay })
	applyCorner(dCard, 20); applyStroke(dCard); applyPadding(dCard, 25, 25, 20, 20)
	local dT = create("TextLabel", { Text = "DANGER ZONE", Size = UDim2.new(1, 0, 0, 25), Font = Enum.Font.GothamBlack, TextSize = 13, TextColor3 = Color3.fromRGB(255, 60, 60), BackgroundTransparency = 1, Parent = dCard })
	local dB = create("TextLabel", { Text = "Closing this menu will stop all logic and destroy the interface. Continue?", Position = UDim2.fromOffset(0, 35), Size = UDim2.new(1, 0, 0, 50), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(180, 180, 190), TextWrapped = true, BackgroundTransparency = 1, Parent = dCard })
	local dButs = create("Frame", { Position = UDim2.new(0, 0, 1, -38), Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Parent = dCard })
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 12), Parent = dButs })
	
	local function createDiagBtn(txt, color, cb)
		local b = create("TextButton", { Text = txt, Size = UDim2.fromOffset(115, 36), BackgroundColor3 = color, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.new(1,1,1), Parent = dButs })
		applyCorner(b, 10); b.MouseButton1Click:Connect(cb)
	end
	createDiagBtn("CANCEL", Color3.fromRGB(40, 40, 45), function() diagOverlay.Visible = false end)
	createDiagBtn("DESTROY", Color3.fromRGB(255, 60, 60), function() screen:Destroy() end)
	close.MouseButton1Click:Connect(function() diagOverlay.Visible = true end)

	self:_registerStyler(function(c)
		main.BackgroundColor3 = c.bg; main.BackgroundTransparency = 0.12
		mGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c.accent), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))})
		dCard.BackgroundColor3 = c.bg
	end)

	-- Rotating Gradient Border Loop
	RunService.RenderStepped:Connect(function() mGrad.Rotation = (tick() * 50) % 360 end)

	-- Floating Minimize Button
	local float = create("ImageButton", { Size = UDim2.fromOffset(48, 48), Position = UDim2.fromOffset(30, 30), BackgroundColor3 = Color3.fromRGB(18, 18, 22), Parent = screen })
	applyCorner(float, 14); local fS = applyStroke(float, Color3.new(1,1,1), 1.5, 0.8); float.Image = config.Logo or "rbxassetid://6031075938"; makeDraggable(float, float)
	local fG = create("UIGradient", { Parent = fS })
	local dot = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 2, 0, -2), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Color3.fromRGB(255, 60, 60), Visible = false, Parent = float })
	applyCorner(dot, 10); applyStroke(dot, Color3.new(0,0,0), 2)
	
	local function toggleUI()
		if not main.Visible then
			main.Visible = true; dot.Visible = false
			mScale.Scale = 0.5; main.GroupTransparency = 1
			tween(mScale, SPRING, { Scale = 1 }); tween(main, SPRING, { GroupTransparency = 0 })
		else
			dot.Visible = true
			tween(mScale, QUICK, { Scale = 0.7 }); local t = tween(main, QUICK, { GroupTransparency = 1 })
			t.Completed:Connect(function() main.Visible = false end)
		end
	end
	float.MouseButton1Click:Connect(toggleUI)
	UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == self.ToggleKey then toggleUI() end end)
	self:_registerStyler(function(c) fG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c.accent), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}) end)

	-- Tabs System
	function self:CreateTab(name)
		local btn = create("TextButton", { Text = name:upper(), Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 10, TextColor3 = Color3.fromRGB(150, 150, 160), AutoButtonColor = false, Parent = tabList })
		applyCorner(btn, 12)
		local acc = create("Frame", { Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 2, 0.5, -9), Visible = false, Parent = btn }); applyCorner(acc, 2)
		
		local pageContainer = create("CanvasGroup", { Visible = false, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = content })
		local scroll = create("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 2, Parent = pageContainer })
		applyPadding(scroll, 22, 22, 15, 22); local lay = create("UIListLayout", { Padding = UDim.new(0, 10), Parent = scroll })
		lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.fromOffset(0, lay.AbsoluteContentSize.Y + 30) end)

		local tabObj = { _pageContainer = pageContainer, _btn = btn, _acc = acc }
		btn.MouseButton1Click:Connect(function() self:SelectTab(tabObj) end)
		if not self._activeTab then self:SelectTab(tabObj) end
		self:_registerStyler(function(c) acc.BackgroundColor3 = c.accent; if self._activeTab == tabObj then btn.BackgroundTransparency = 0.9; btn.TextColor3 = Color3.new(1,1,1); acc.Visible = true end end)

		local Tab = {}

		function Tab:AddButton(txt, cb)
			local card = create("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.96, Parent = scroll })
			applyCorner(card, 12); applyStroke(card); local b = create("TextButton", { Text = txt:upper(), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.new(1,1,1), Parent = card })
			b.MouseButton1Down:Connect(function() card.BackgroundTransparency = 0.92 end)
			b.MouseButton1Up:Connect(function() card.BackgroundTransparency = 0.96 end)
			b.MouseButton1Click:Connect(function() pcall(cb) end)
		end

		function Tab:AddToggle(txt, def, cb)
			local s = def or false
			local card = create("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Parent = scroll })
			applyCorner(card, 12); applyStroke(card); applyPadding(card, 15, 15, 0, 0)
			local lbl = create("TextLabel", { Text = txt, Size = UDim2.new(1, -50, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = card })
			local t = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(36, 20), Parent = card }); applyCorner(t, 10)
			local k = create("Frame", { Position = s and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.new(1,1,1), Parent = t }); applyCorner(k, 10)
			local function up() local cl = self:_getColors(); tween(t, SPRING, { BackgroundColor3 = s and cl.accent or Color3.fromRGB(45, 45, 50) }); tween(k, SPRING, { Position = s and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2) }); pcall(cb, s) end
			card.MouseButton1Click:Connect(function() s = not s; up() end); up()
		end

		function Tab:AddSlider(txt, min, max, def, cb)
			local v = def or min
			local card = create("Frame", { Size = UDim2.new(1, 0, 0, 68), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Parent = scroll })
			applyCorner(card, 12); applyStroke(card); applyPadding(card, 15, 15, 10, 10)
			local l = create("TextLabel", { Text = txt, Size = UDim2.new(0.6, 0, 0, 20), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = card })
			local inp = create("TextBox", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(50, 22), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.95, Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.new(1,1,1), Text = tostring(v), Parent = card }); applyCorner(inp, 6)
			local b = create("Frame", { Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 5), BackgroundColor3 = Color3.fromRGB(45, 45, 50), Parent = card }); applyCorner(b, 2)
			local f = create("Frame", { Size = UDim2.fromScale((v-min)/(max-min), 1), Parent = b }); applyCorner(f, 2)
			self:_registerStyler(function(cl) f.BackgroundColor3 = cl.accent; inp.TextColor3 = cl.accent end)
			local drag = false
			local function up(i) local a = math.clamp((i.Position.X - b.AbsolutePosition.X)/b.AbsoluteSize.X, 0, 1); v = math.floor(min + (max-min)*a); f.Size = UDim2.fromScale(a, 1); inp.Text = tostring(v); pcall(cb, v) end
			card.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; update(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
			UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then up(i) end end)
			inp.FocusLost:Connect(function() local n = tonumber(inp.Text) if n then v = math.clamp(n, min, max); f.Size = UDim2.fromScale((v-min)/(max-min), 1); inp.Text = tostring(v); pcall(cb, v) else inp.Text = tostring(v) end end)
		end

		function Tab:AddMultiDropdown(txt, items, def, cb)
			local sel = {} if def then for _,v in pairs(def) do sel[v] = true end end
			local card = create("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.fromRGB(22, 22, 28), Parent = scroll })
			applyCorner(card, 12); applyStroke(card); applyPadding(card, 15, 15, 0, 0)
			local lbl = create("TextLabel", { Text = txt, Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = card })
			local count = create("TextLabel", { Text = "SELECTED: 0", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 100, 0, 20), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.fromRGB(150, 150, 160), TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Parent = card })
			
			local function refresh() local c = 0 for _ in pairs(sel) do c += 1 end count.Text = "SELECTED: " .. tostring(c) pcall(cb, sel) end
			card.MouseButton1Click:Connect(function()
				-- Simplified multi-toggle logic for this standard version
				local nextItem = items[1]
				if sel[nextItem] then sel[nextItem] = nil else sel[nextItem] = true end
				refresh()
			end)
			refresh()
		end

		return Tab
	end

	-- ── Professional Settings Tab ──────────────────────────────────────────
	local Settings = self:CreateTab("Settings")
	Settings:AddButton("Switch Theme", function() 
		local t = {"Dark", "Aqua", "Rose", "Amethyst"}
		local i = table.find(t, self.ThemeName) or 1
		self.ThemeName = t[i+1] or t[1]; self:_refreshTheme()
	end)
	Settings:AddButton("Destroy Menu", function() diagOverlay.Visible = true end)

	return self
end

return SnowyLib
