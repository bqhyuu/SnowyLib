--[[
    SNOWY LIB — ULTIMATE ANNIVERSARY EDITION
    Merging Website Fidelity with Premium Hub Effects
    100% English | Pixel-Perfect Parity | Optimized Logic
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
	Sakura = {
		bg = Color3.fromRGB(15, 10, 12),
		accent = Color3.fromRGB(255, 180, 200),
		secondary = Color3.fromRGB(255, 220, 230),
		particle = "129633366976969"
	},
	Moonlight = {
		bg = Color3.fromRGB(8, 8, 15),
		accent = Color3.fromRGB(180, 200, 255),
		secondary = Color3.fromRGB(220, 230, 255),
		particle = "116750779040036"
	},
	Aqua = {
		bg = Color3.fromRGB(5, 15, 15),
		accent = Color3.fromRGB(0, 255, 255),
		secondary = Color3.fromRGB(200, 255, 255),
		particle = "137906289429512"
	}
}

-- ── Animation Presets ──────────────────────────────────────────────────────

local SPRING = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local QUICK  = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HEADER_H = 55
local SIDEBAR_W = 170

-- ── Utilities ──────────────────────────────────────────────────────────────

local function create(class, props)
	local inst = Instance.new(class)
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

-- ── Library Core ───────────────────────────────────────────────────────────

local SnowyLib = {}
 SnowyLib.__index = SnowyLib

function SnowyLib:_getColors() return THEMES[self.ThemeName or "Sakura"] end
function SnowyLib:_registerStyler(cb) table.insert(self._stylers, cb); cb(self:_getColors()) end
function SnowyLib:_refreshTheme() local c = self:_getColors(); for _, cb in ipairs(self._stylers) do cb(c) end end

-- Notifications
function SnowyLib:Notify(cfg)
	local colors = self:_getColors()
	local toast = create("Frame", { Size = UDim2.fromOffset(240, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(15, 15, 18), Parent = self._notifyHolder })
	applyCorner(toast, 12); local s = applyStroke(toast, Color3.new(1,1,1), 2, 0.7); applyPadding(toast, 15, 35, 12, 12)
	create("UIListLayout", { Padding = UDim.new(0, 4), Parent = toast })
	
	local g = create("UIGradient", { Parent = s })
	local tit = create("TextLabel", { Text = (cfg.Title or "SYSTEM"):upper(), Size = UDim2.new(1, 0, 0, 15), Font = Enum.Font.GothamBlack, TextSize = 10, BackgroundTransparency = 1, Parent = toast })
	local bdy = create("TextLabel", { Text = cfg.Content or "", AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.new(1,1,1), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = toast })
	local bar = create("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), Parent = toast })
	
	self:_registerStyler(function(c) tit.TextColor3 = c.accent; bar.BackgroundColor3 = c.accent; g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c.accent), ColorSequenceKeypoint.new(1, c.secondary)}) end)
	
	task.spawn(function()
		local d = cfg.Duration or 5
		tween(bar, TweenInfo.new(d, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
		task.wait(d); toast:Destroy()
	end)
end

function SnowyLib:SelectTab(tab)
	if self._activeTab == tab then return end
	if self._activeTab then
		local prev = self._activeTab._page
		tween(prev, QUICK, { GroupTransparency = 1, Position = UDim2.fromOffset(0, 20) })
		task.delay(0.2, function() prev.Visible = false end)
	end
	self._activeTab = tab
	tab._page.Visible = true; tab._page.GroupTransparency = 1; tab._page.Position = UDim2.fromOffset(0, 20)
	tween(tab._page, SPRING, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) })
	self:_refreshTheme()
end

function SnowyLib.CreateWindow(config)
	config = config or {}
	local self = setmetatable({
		_stylers = {},
		_tabs = {},
		Options = {},
		ThemeName = config.Theme or "Sakura",
		ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
	}, SnowyLib)

	local screen = create("ScreenGui", { Name = "SnowyLib", Parent = localPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false, IgnoreGuiInset = true })
	self._screen = screen

	-- Window Setup
	local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
	local w = math.min(640, vw * 0.95)
	local h = math.min(460, vh * 0.9)

	local main = create("CanvasGroup", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(w, h), Parent = screen })
	applyCorner(main, 24); local mStroke = applyStroke(main, Color3.new(1,1,1), 3, 0.6); self._main = main
	local mGrad = create("UIGradient", { Parent = mStroke })

	-- Particles
	local ParticleFrame = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = main, ZIndex = 0 })
	task.spawn(function()
		while main.Parent do
			task.wait(0.2)
			if not main.Visible then continue end
			local c = self:_getColors()
			local p = create("ImageLabel", { BackgroundTransparency = 1, Image = "rbxthumb://type=Asset&id=" .. c.particle .. "&w=150&h=150", Parent = ParticleFrame })
			p.Size = UDim2.fromOffset(math.random(14, 22), math.random(14, 22))
			p.Position = UDim2.new(math.random(), 0, -0.1, 0)
			p.ImageTransparency = math.random(4, 7) / 10
			local t = tween(p, TweenInfo.new(math.random(4, 8), Enum.EasingStyle.Linear), { Position = UDim2.new(p.Position.X.Scale, math.random(-150, 150), 1.1, 0), Rotation = math.random(-180, 180) })
			t.Completed:Connect(function() p:Destroy() end)
		end
	end)

	-- Header Controls
	local head = create("Frame", { Size = UDim2.new(1, 0, 0, HEADER_H), BackgroundTransparency = 1, Parent = main })
	applyPadding(head, 25, 25, 0, 0); makeDraggable(head, main)
	
	local tit = create("TextLabel", { Text = (config.Title or "PREMIUM HUB"):upper(), Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamBlack, TextSize = 14, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = head })
	local close = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(34, 34), BackgroundColor3 = Color3.fromRGB(255, 60, 60), Text = "×", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = Color3.new(1,1,1), Parent = head })
	applyCorner(close, 10)

	local sidebar = create("Frame", { Position = UDim2.fromOffset(0, HEADER_H), Size = UDim2.new(0, SIDEBAR_W, 1, -HEADER_H), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.95, Parent = main })
	applyCorner(sidebar, 24); applyPadding(sidebar, 12, 12, 15, 12)
	local tabList = create("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = sidebar })
	create("UIListLayout", { Padding = UDim.new(0, 5), Parent = tabList })

	local content = create("Frame", { Position = UDim2.fromOffset(SIDEBAR_W, HEADER_H), Size = UDim2.new(1, -SIDEBAR_W, 1, -HEADER_H), BackgroundTransparency = 1, Parent = main })
	self._content = content

	self._notifyHolder = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -25, 0, 25), Size = UDim2.new(0, 240, 1, 0), BackgroundTransparency = 1, Parent = screen })
	create("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 10), Parent = self._notifyHolder })

	-- Dynamic Styling
	self:_registerStyler(function(c)
		main.BackgroundColor3 = c.bg; main.BackgroundTransparency = 0.1
		mGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c.accent), ColorSequenceKeypoint.new(1, c.secondary)})
	end)

	RunService.RenderStepped:Connect(function() mGrad.Rotation = (tick() * 60) % 360 end)

	-- Tabs API
	function self:CreateTab(name)
		local tabBtn = create("TextButton", { Text = name:upper(), Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 10, TextColor3 = Color3.fromRGB(150, 150, 160), AutoButtonColor = false, Parent = tabList })
		applyCorner(tabBtn, 12)
		local acc = create("Frame", { Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 2, 0.5, -9), Visible = false, Parent = tabBtn }); applyCorner(acc, 2)
		local page = create("CanvasGroup", { Visible = false, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = content })
		local scroll = create("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 2, Parent = page })
		applyPadding(scroll, 20, 20, 15, 20); local lay = create("UIListLayout", { Padding = UDim.new(0, 10), Parent = scroll })
		lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.fromOffset(0, lay.AbsoluteContentSize.Y + 30) end)

		local tabObj = { _page = page, _btn = tabBtn, _acc = acc }
		tabBtn.MouseButton1Click:Connect(function() self:SelectTab(tabObj) end)
		if not self._activeTab then self:SelectTab(tabObj) end
		self:_registerStyler(function(c) acc.BackgroundColor3 = c.accent; if self._activeTab == tabObj then tabBtn.BackgroundTransparency = 0.9; tabBtn.TextColor3 = Color3.new(1,1,1); acc.Visible = true end end)

		local Tab = {}
		function Tab:AddButton(txt, cb)
			local c = create("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Parent = scroll })
			applyCorner(c, 12); local s = applyStroke(c); applyPadding(c, 15, 15, 0, 0)
			local g = create("UIGradient", { Parent = s })
			local l = create("TextLabel", { Text = txt:upper(), Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.new(1,1,1), BackgroundTransparency = 1, Parent = c })
			self:_registerStyler(function(cl) g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, cl.accent), ColorSequenceKeypoint.new(1, cl.secondary)}) end)
			c.MouseButton1Click:Connect(function() pcall(cb) end)
		end

		function Tab:AddToggle(txt, def, cb)
			local s = def or false
			local c = create("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Parent = scroll })
			applyCorner(c, 12); applyStroke(c); applyPadding(c, 15, 15, 0, 0)
			local l = create("TextLabel", { Text = txt, Size = UDim2.new(1, -50, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = c })
			local t = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(36, 20), Parent = c }); applyCorner(t, 10)
			local k = create("Frame", { Position = s and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.new(1,1,1), Parent = t }); applyCorner(k, 10)
			local function up() local cl = self:_getColors(); tween(t, SPRING, { BackgroundColor3 = s and cl.accent or Color3.fromRGB(45, 45, 50) }); tween(k, SPRING, { Position = s and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2) }); pcall(cb, s) end
			c.MouseButton1Click:Connect(function() s = not s; up() end); up()
		end

		function Tab:AddSlider(txt, min, max, def, cb)
			local v = def or min
			local c = create("Frame", { Size = UDim2.new(1, 0, 0, 68), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Parent = scroll })
			applyCorner(c, 12); applyStroke(c); applyPadding(c, 15, 15, 12, 12)
			local l = create("TextLabel", { Text = txt, Size = UDim2.new(0.6, 0, 0, 20), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = c })
			local inp = create("TextBox", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(50, 22), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.95, Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.new(1,1,1), Text = tostring(v), Parent = c }); applyCorner(inp, 6); applyStroke(inp)
			local b = create("Frame", { Position = UDim2.new(0, 0, 1, -8), Size = UDim2.new(1, 0, 0, 5), BackgroundColor3 = Color3.fromRGB(45, 45, 50), Parent = c }); applyCorner(b, 3)
			local f = create("Frame", { Size = UDim2.fromScale((v-min)/(max-min), 1), Parent = b }); applyCorner(f, 3)
			self:_registerStyler(function(cl) f.BackgroundColor3 = cl.accent; inp.TextColor3 = cl.accent end)
			local drag = false
			local function up(i) local a = math.clamp((i.Position.X - b.AbsolutePosition.X)/b.AbsoluteSize.X, 0, 1); v = math.floor(min + (max-min)*a); f.Size = UDim2.fromScale(a, 1); inp.Text = tostring(v); pcall(cb, v) end
			c.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; up(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
			UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then up(i) end end)
			return Tab
		end

		function Tab:AddDropdown(txt, items, def, cb)
			local sel = def or items[1]
			local c = create("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Parent = scroll })
			applyCorner(c, 12); applyStroke(c); applyPadding(c, 15, 15, 0, 0)
			local l = create("TextLabel", { Text = txt, Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = c })
			local v = create("TextLabel", { Text = tostring(sel):upper(), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamBlack, TextSize = 10, TextColor3 = Color3.fromRGB(150, 150, 160), TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Parent = c })
			c.MouseButton1Click:Connect(function()
				local idx = table.find(items, sel) or 1
				sel = items[idx+1] or items[1]
				v.Text = tostring(sel):upper()
				pcall(cb, sel)
			end)
		end

		return Tab
	end

	-- Minimize System
	local float = create("ImageButton", { Size = UDim2.fromOffset(48, 48), Position = UDim2.fromOffset(30, 30), BackgroundColor3 = Color3.fromRGB(20, 20, 25), Parent = screen })
	applyCorner(float, 14); local fS = applyStroke(float); float.Image = config.Logo or "rbxassetid://6031075938"; makeDraggable(float, float)
	local fG = create("UIGradient", { Parent = fS })
	float.MouseButton1Click:Connect(function()
		if main.Visible then
			tween(mScale, QUICK, { Scale = 0.7 }); local t = tween(main, QUICK, { GroupTransparency = 1 })
			t.Completed:Connect(function() main.Visible = false end)
		else
			main.Visible = true; mScale.Scale = 0.6; main.GroupTransparency = 1
			tween(mScale, SPRING, { Scale = 1 }); tween(main, SPRING, { GroupTransparency = 0 })
		end
	end)
	self:_registerStyler(function(cl) fG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, cl.accent), ColorSequenceKeypoint.new(1, cl.secondary)}) end)

	close.MouseButton1Click:Connect(function() screen:Destroy() end)

	return self
end

return SnowyLib
