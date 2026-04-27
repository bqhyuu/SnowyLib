--[[
    SNOWY LIB — ULTIMATE WEBSITE CONVERSION
    100% English | Pixel-Perfect Fidelity | Stable API
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
	Dark     = { bg = Color3.fromRGB(8, 8, 10),   accent = Color3.fromRGB(255, 255, 255) },
	Aqua     = { bg = Color3.fromRGB(5, 16, 16),  accent = Color3.fromRGB(0, 255, 255)   },
	Rose     = { bg = Color3.fromRGB(18, 8, 10),  accent = Color3.fromRGB(251, 113, 133) },
	Amethyst = { bg = Color3.fromRGB(13, 8, 18),  accent = Color3.fromRGB(168, 85, 247) },
	Darker   = { bg = Color3.fromRGB(0, 0, 0),    accent = Color3.fromRGB(255, 255, 255) },
}

-- ── Animation Presets ──────────────────────────────────────────────────────

local SPRING = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local QUICK  = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local LINEAR = TweenInfo.new(0.3, Enum.EasingStyle.Linear)

-- ── Core Utilities ─────────────────────────────────────────────────────────

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
	s.Thickness = thickness or 1.2
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

-- ── Component Factories ────────────────────────────────────────────────────

local SnowyLib = {}
SnowyLib.__index = SnowyLib

function SnowyLib:_getColors() return THEMES[self.ThemeName or "Dark"] end
function SnowyLib:_registerStyler(cb) table.insert(self._stylers, cb); cb(self:_getColors()) end
function SnowyLib:_refreshTheme() local c = self:_getColors(); for _, cb in ipairs(self._stylers) do cb(c) end end

-- Notification System
function SnowyLib:Notify(cfg)
	local toast = create("Frame", { Name = "Toast", Size = UDim2.fromOffset(240, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(12, 12, 14), Parent = self._notifyHolder })
	applyCorner(toast, 12); applyStroke(toast, Color3.new(1,1,1), 1.5, 0.9); applyPadding(toast, 15, 35, 12, 12)
	create("UIListLayout", { Padding = UDim.new(0, 4), Parent = toast })
	
	local tit = create("TextLabel", { Text = (cfg.Title or "NOTICE"):upper(), Size = UDim2.new(1, 0, 0, 15), Font = Enum.Font.GothamBlack, TextSize = 10, BackgroundTransparency = 1, Parent = toast })
	local bdy = create("TextLabel", { Text = cfg.Content or "", AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.new(1,1,1), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = toast })
	local bar = create("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), Parent = toast })
	local cls = create("TextButton", { Position = UDim2.new(1, 20, 0, 0), Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1, Text = "×", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1), Parent = toast })
	
	cls.MouseButton1Click:Connect(function() toast:Destroy() end)
	self:_registerStyler(function(c) tit.TextColor3 = c.accent; bar.BackgroundColor3 = c.accent end)
	task.spawn(function()
		local d = cfg.Duration or 5
		TweenService:Create(bar, TweenInfo.new(d, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()
		task.wait(d); if toast.Parent then toast:Destroy() end
	end)
end

-- Tab Management
function SnowyLib:SelectTab(tab)
	if self._activeTab == tab then return end
	if self._activeTab then
		local prev = self._activeTab._page
		TweenService:Create(prev, QUICK, { GroupTransparency = 1, Position = UDim2.fromOffset(0, 15) }):Play()
		task.delay(0.2, function() prev.Visible = false end)
	end
	self._activeTab = tab
	tab._page.Visible = true; tab._page.GroupTransparency = 1; tab._page.Position = UDim2.fromOffset(0, 15)
	TweenService:Create(tab._page, SPRING, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) }):Play()
	self:_refreshTheme()
end

-- ── Main Builder ───────────────────────────────────────────────────────────

function SnowyLib.CreateWindow(config)
	config = config or {}
	local self = setmetatable({
		_activeTab = nil,
		_tabs = {},
		_stylers = {},
		Options = {},
		ThemeName = config.Theme or "Dark",
		ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
	}, SnowyLib)

	local screen = create("ScreenGui", { Name = "SnowyLib", Parent = localPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false, IgnoreGuiInset = true })
	self._screen = screen

	-- Responsive Logic
	local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
	local w = math.min(600, vw * 0.9)
	local h = math.min(400, vh * 0.85)

	local main = create("CanvasGroup", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(w, h), Parent = screen })
	applyCorner(main, 24); local mStroke = applyStroke(main, Color3.new(1,1,1), 2, 0.8); self._main = main
	local mScale = create("UIScale", { Parent = main })

	-- Scanline Texture
	create("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "rbxassetid://13217036657", ImageTransparency = 0.97, TileSize = UDim2.fromOffset(24, 24), ScaleType = Enum.ScaleType.Tile, Parent = main })

	local head = create("Frame", { Size = UDim2.new(1, 0, 0, 54), BackgroundTransparency = 1, Parent = main })
	applyPadding(head, 20, 20, 0, 0); makeDraggable(head, main)
	
	local title = create("TextLabel", { Text = (config.Title or "SNOWY HUB"):upper(), Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamBlack, TextSize = 13, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = head })
	local close = create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = Color3.fromRGB(255, 60, 60), Text = "×", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.new(1,1,1), Parent = head })
	applyCorner(close, 10)

	local sidebar = create("Frame", { Position = UDim2.fromOffset(0, 54), Size = UDim2.new(0, 150, 1, -54), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.95, Parent = main })
	applyCorner(sidebar, 24); applyPadding(sidebar, 10, 10, 15, 10)
	local tabList = create("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = sidebar })
	create("UIListLayout", { Padding = UDim.new(0, 4), Parent = tabList })

	local content = create("Frame", { Position = UDim2.fromOffset(150, 54), Size = UDim2.new(1, -150, 1, -54), BackgroundTransparency = 1, Parent = main })
	self._content = content

	self._notifyHolder = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 20), Size = UDim2.new(0, 240, 1, 0), BackgroundTransparency = 1, Parent = screen })
	create("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8), Parent = self._notifyHolder })

	self:_registerStyler(function(c) main.BackgroundColor3 = c.bg; main.BackgroundTransparency = 0.1 end)

	-- Minimize System
	local float = create("ImageButton", { Size = UDim2.fromOffset(44, 44), Position = UDim2.fromOffset(25, 25), BackgroundColor3 = Color3.fromRGB(15, 15, 18), Parent = screen })
	applyCorner(float, 12); applyStroke(float); float.Image = config.Logo or "rbxassetid://6031075938"; makeDraggable(float, float)
	local dot = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 2, 0, -2), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Color3.fromRGB(255, 60, 60), Parent = float })
	applyCorner(dot, 10); applyStroke(dot, Color3.new(0,0,0), 2)
	
	local function toggle()
		if not main.Visible then
			main.Visible = true; dot.Visible = false
			mScale.Scale = 0.6; main.GroupTransparency = 1
			TweenService:Create(mScale, SPRING, { Scale = 1 }):Play()
			TweenService:Create(main, SPRING, { GroupTransparency = 0 }):Play()
		else
			dot.Visible = true
			TweenService:Create(mScale, QUICK, { Scale = 0.7 }):Play()
			local t = TweenService:Create(main, QUICK, { GroupTransparency = 1 })
			t:Play(); t.Completed:Connect(function() main.Visible = false end)
		end
	end
	float.MouseButton1Click:Connect(toggle)
	UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == self.ToggleKey then toggle() end end)

	-- Tabs Creation
	function self:CreateTab(name)
		local tabBtn = create("TextButton", { Text = name:upper(), Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 9, TextColor3 = Color3.fromRGB(130, 130, 140), AutoButtonColor = false, Parent = tabList })
		applyCorner(tabBtn, 10)
		local acc = create("Frame", { Size = UDim2.new(0, 3, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), Visible = false, Parent = tabBtn }); applyCorner(acc, 2)
		local page = create("CanvasGroup", { Visible = false, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = content })
		local scroll = create("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 2, Parent = page })
		applyPadding(scroll, 15, 15, 10, 15); local lay = create("UIListLayout", { Padding = UDim.new(0, 8), Parent = scroll })
		lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.fromOffset(0, lay.AbsoluteContentSize.Y + 20) end)

		local tabObj = { _page = page, _btn = tabBtn, _acc = acc }
		tabBtn.MouseButton1Click:Connect(function() self:SelectTab(tabObj) end)
		if not self._activeTab then self:SelectTab(tabObj) end
		self:_registerStyler(function(c) acc.BackgroundColor3 = c.accent; if self._activeTab == tabObj then tabBtn.BackgroundTransparency = 0.92; tabBtn.TextColor3 = Color3.new(1,1,1); acc.Visible = true end end)

		local Tab = {}
		function Tab:CreateSection(txt)
			local h = create("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = scroll })
			local l = create("TextLabel", { Text = txt:upper(), Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBlack, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = h })
			self:_registerStyler(function(c) l.TextColor3 = c.accent; l.TextTransparency = 0.5 end); return Tab
		end

		function Tab:AddButton(txt, cb)
			local b = create("TextButton", { Text = txt:upper(), Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(22, 22, 26), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.new(1,1,1), Parent = scroll })
			applyCorner(b, 12); applyStroke(b); b.MouseButton1Click:Connect(function() pcall(cb) end)
		end

		function Tab:AddToggle(txt, def, cb)
			local s = def or false
			local c = create("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(22, 22, 26), Parent = scroll })
			applyCorner(c, 12); applyStroke(c); applyPadding(c, 12, 12, 0, 0)
			local l = create("TextLabel", { Text = txt, Size = UDim2.new(1, -40, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = c })
			local t = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(32, 18), Parent = c }); applyCorner(t, 10)
			local k = create("Frame", { Position = s and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1,1,1), Parent = t }); applyCorner(k, 10)
			local function up() local cl = self:_getColors(); tween(t, SPRING, { BackgroundColor3 = s and cl.accent or Color3.fromRGB(45, 45, 50) }); tween(k, SPRING, { Position = s and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2) }); pcall(cb, s) end
			c.MouseButton1Click:Connect(function() s = not s; up() end); up(); return Tab
		end

		function Tab:AddSlider(txt, min, max, def, cb)
			local v = def or min
			local c = create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(22, 22, 26), Parent = scroll })
			applyCorner(c, 12); applyStroke(c); applyPadding(c, 12, 12, 8, 8)
			local l = create("TextLabel", { Text = txt, Size = UDim2.new(0.5, 0, 0, 15), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = c })
			local vl = create("TextLabel", { Text = tostring(v), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.5, 0, 0, 15), Font = Enum.Font.Code, TextSize = 10, BackgroundTransparency = 1, Parent = c })
			local b = create("Frame", { Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = Color3.fromRGB(45, 45, 50), Parent = c }); applyCorner(b, 2)
			local f = create("Frame", { Size = UDim2.fromScale((v-min)/(max-min), 1), Parent = b }); applyCorner(f, 2)
			self:_registerStyler(function(cl) f.BackgroundColor3 = cl.accent; vl.TextColor3 = cl.accent end)
			local dragging = false
			local function up(i) local a = math.clamp((i.Position.X - b.AbsolutePosition.X)/b.AbsoluteSize.X, 0, 1); v = math.floor(min + (max-min)*a); f.Size = UDim2.fromScale(a, 1); vl.Text = tostring(v); pcall(cb, v) end
			c.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; up(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then up(i) end end)
			return Tab
		end

		return Tab
	end

	-- ── Auto-Generate Pro Settings ──────────────────────────────────────────
	local Settings = self:CreateTab("Settings")
	Settings:CreateSection("Appearance")
	Settings:AddButton("Switch Theme (Cycle)", function() 
		local t = {"Dark", "Aqua", "Rose", "Amethyst", "Darker"}
		local i = table.find(t, self.ThemeName) or 1
		self.ThemeName = t[i+1] or t[1]; self:_refreshTheme()
	end)
	Settings:CreateSection("Links")
	Settings:AddButton("Copy Discord Server", function() setclipboard("https://discord.gg/snowylib") end)
	Settings:CreateSection("Danger Zone")
	Settings:AddButton("Destroy Menu", function() screen:Destroy() end)

	return self
end

return SnowyLib
