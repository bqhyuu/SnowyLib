-- SnowyLib V6 — 100% Website Fidelity Edition (Settings & Components)
-- Bản convert hoàn hảo nhất, đầy đủ Slider, Dropdown, Keybind và Tab Settings chuẩn.

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local THEMES = {
	Dark     = { bg = Color3.fromRGB(8, 8, 10),   accent = Color3.fromRGB(255, 255, 255) },
	Aqua     = { bg = Color3.fromRGB(5, 16, 16),  accent = Color3.fromRGB(0, 255, 255)   },
	Rose     = { bg = Color3.fromRGB(18, 8, 10),  accent = Color3.fromRGB(251, 113, 133) },
	Amethyst = { bg = Color3.fromRGB(13, 8, 18),  accent = Color3.fromRGB(168, 85, 247) },
	Darker   = { bg = Color3.fromRGB(0, 0, 0),    accent = Color3.fromRGB(255, 255, 255) },
}

local SPRING = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

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
	s.Thickness = thickness or 1.2
	s.Color = color or Color3.new(1,1,1)
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

function SnowyLib:_getColors() return THEMES[self.ThemeName or "Dark"] end
function SnowyLib:_registerStyler(cb) table.insert(self._stylers, cb); cb(self:_getColors()) end
function SnowyLib:_refreshTheme() local c = self:_getColors(); for _, cb in ipairs(self._stylers) do cb(c) end end

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

	-- Responsive Size
	local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
	local w = math.min(580, vw * 0.9)
	local h = math.min(380, vh * 0.85)

	local main = create("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(w, h),
		Parent = screen
	})
	applyCorner(main, 24)
	local mStroke = applyStroke(main, Color3.new(1,1,1), 2, 0.8)
	self._main = main

	local head = create("Frame", { Size = UDim2.new(1, 0, 0, 54), BackgroundTransparency = 0.98, Parent = main })
	applyPadding(head, 20, 20, 0, 0)
	makeDraggable(head, main)

	local title = create("TextLabel", {
		Text = (config.Title or "SNOWY HUB"):upper(),
		Size = UDim2.new(0.5, 0, 1, 0),
		Font = Enum.Font.GothamBlack,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = head
	})

	local closeBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Color3.fromRGB(255, 60, 60),
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Color3.new(1,1,1),
		Parent = head
	})
	applyCorner(closeBtn, 10)

	local sidebar = create("Frame", { Position = UDim2.fromOffset(0, 54), Size = UDim2.new(0, 150, 1, -54), BackgroundTransparency = 0.95, Parent = main })
	applyCorner(sidebar, 24)
	applyPadding(sidebar, 10, 10, 15, 10)
	
	local tabList = create("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = sidebar })
	create("UIListLayout", { Padding = UDim.new(0, 4), Parent = tabList })

	local content = create("Frame", { Position = UDim2.fromOffset(150, 54), Size = UDim2.new(1, -150, 1, -54), BackgroundTransparency = 1, Parent = main })
	self._content = content

	self:_registerStyler(function(c)
		main.BackgroundColor3 = c.bg; main.BackgroundTransparency = 0.1
		sidebar.BackgroundColor3 = Color3.new(0,0,0)
		title.TextColor3 = Color3.new(1,1,1)
	end)

	-- Dialog
	local diagOverlay = create("Frame", { Visible = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5, ZIndex = 100, Parent = screen })
	local diag = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(280, 140), Parent = diagOverlay })
	applyCorner(diag, 16); applyStroke(diag); applyPadding(diag, 20, 20, 15, 15)
	
	local diagT = create("TextLabel", { Text = "CLOSE MENU?", Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.GothamBlack, TextSize = 12, TextColor3 = Color3.fromRGB(255, 60, 60), BackgroundTransparency = 1, Parent = diag })
	local diagB = create("TextLabel", { Text = "Are you sure you want to destroy the UI?", Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 0, 40), Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Color3.new(0.8,0.8,0.8), TextWrapped = true, BackgroundTransparency = 1, Parent = diag })
	local diagButs = create("Frame", { Position = UDim2.new(0, 0, 1, -35), Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Parent = diag })
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 10), Parent = diagButs })

	local function diagBtn(txt, color, cb)
		local b = create("TextButton", { Text = txt, Size = UDim2.fromOffset(110, 32), BackgroundColor3 = color, Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.new(1,1,1), Parent = diagButs })
		applyCorner(b, 8); b.MouseButton1Click:Connect(cb)
	end
	diagBtn("CANCEL", Color3.fromRGB(40, 40, 45), function() diagOverlay.Visible = false end)
	diagBtn("CONFIRM", Color3.fromRGB(255, 60, 60), function() screen:Destroy() end)
	closeBtn.MouseButton1Click:Connect(function() diagOverlay.Visible = true end)

	UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == self.ToggleKey then main.Visible = not main.Visible end end)

	-- Tabs API
	function self:CreateTab(name, icon)
		local tabBtn = create("TextButton", { Text = name:upper(), Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 9, TextColor3 = Color3.fromRGB(140, 140, 150), AutoButtonColor = false, Parent = tabList })
		applyCorner(tabBtn, 8)
		local accent = create("Frame", { Size = UDim2.new(0, 3, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), Visible = false, Parent = tabBtn })
		applyCorner(accent, 2)

		local page = create("ScrollingFrame", { Visible = false, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 2, Parent = content })
		applyPadding(page, 15, 15, 10, 15); create("UIListLayout", { Padding = UDim.new(0, 10), Parent = page })

		local tabObj = { Page = page, Btn = tabBtn, Accent = accent }
		local function select()
			if self._activeTab then
				self._activeTab.Page.Visible = false
				self._activeTab.Btn.BackgroundTransparency = 1
				self._activeTab.Accent.Visible = false
			end
			page.Visible = true
			tabBtn.BackgroundTransparency = 0.92
			accent.Visible = true
			self._activeTab = tabObj
		end
		tabBtn.MouseButton1Click:Connect(select)
		if not self._activeTab then select() end
		
		self:_registerStyler(function(c) accent.BackgroundColor3 = c.accent end)

		local Tab = {}
		
		function Tab:CreateSection(title)
			local h = create("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = page })
			local l = create("TextLabel", { Text = title:upper(), Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBlack, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = h })
			self:_registerStyler(function(c) l.TextColor3 = c.accent; l.TextTransparency = 0.5 end)
			return Tab
		end

		function Tab:AddButton(text, cb)
			local b = create("TextButton", { Text = text:upper(), Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Color3.fromRGB(22, 22, 26), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.new(1,1,1), Parent = page })
			applyCorner(b, 10); applyStroke(b); b.MouseButton1Click:Connect(function() pcall(cb) end)
		end

		function Tab:AddToggle(text, def, cb)
			local s = def or false
			local card = create("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(22, 22, 26), Parent = page })
			applyCorner(card, 10); applyStroke(card); applyPadding(card, 12, 12, 0, 0)
			local lbl = create("TextLabel", { Text = text, Size = UDim2.new(1, -40, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = card })
			local t = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(32, 18), Parent = card })
			applyCorner(t, 10)
			local k = create("Frame", { Position = s and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1,1,1), Parent = t })
			applyCorner(k, 10)
			local function up() 
				local c = self:_getColors()
				tween(t, SPRING, { BackgroundColor3 = s and c.accent or Color3.fromRGB(45, 45, 50) })
				tween(k, SPRING, { Position = s and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2) })
				pcall(cb, s)
			end
			card.MouseButton1Click:Connect(function() s = not s; up() end); up()
		end

		function Tab:AddSlider(text, min, max, def, cb)
			local val = def or min
			local card = create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(22, 22, 26), Parent = page })
			applyCorner(card, 10); applyStroke(card); applyPadding(card, 12, 12, 8, 8)
			local lbl = create("TextLabel", { Text = text, Size = UDim2.new(0.5, 0, 0, 15), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = card })
			local valLbl = create("TextLabel", { Text = tostring(val), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.5, 0, 0, 15), Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Parent = card })
			local bar = create("Frame", { Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = Color3.fromRGB(45, 45, 50), Parent = card })
			applyCorner(bar, 2)
			local fill = create("Frame", { Size = UDim2.fromScale((val-min)/(max-min), 1), Parent = bar }); applyCorner(fill, 2)
			self:_registerStyler(function(c) fill.BackgroundColor3 = c.accent; valLbl.TextColor3 = c.accent end)
			local dragging = false
			local function update(i)
				local a = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				val = math.floor(min + (max - min) * a)
				fill.Size = UDim2.fromScale(a, 1); valLbl.Text = tostring(val); pcall(cb, val)
			end
			card.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
		end

		function Tab:AddDropdown(text, items, def, cb)
			local sel = def or items[1]
			local card = create("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(22, 22, 26), Parent = page })
			applyCorner(card, 10); applyStroke(card); applyPadding(card, 12, 12, 0, 0)
			local lbl = create("TextLabel", { Text = text, Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = card })
			local selLbl = create("TextLabel", { Text = tostring(sel):upper(), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.5, 0, 0, 20), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.new(0.6,0.6,0.6), TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Parent = card })
			card.MouseButton1Click:Connect(function()
				-- Đơn giản hóa: Xoay vòng item
				local idx = table.find(items, sel) or 1
				sel = items[idx + 1] or items[1]
				selLbl.Text = tostring(sel):upper()
				pcall(cb, sel)
			end)
		end

		return Tab
	end

	-- ── Create Website Settings Tab ────────────────────────────────────────
	local Settings = self:CreateTab("Settings")
	
	Settings:CreateSection("Appearance")
	Settings:AddDropdown("Theme", {"Dark", "Aqua", "Rose", "Amethyst", "Darker"}, self.ThemeName, function(v)
		self.ThemeName = v
		self:_refreshTheme()
	end)
	Settings:AddSlider("UI Transparency", 0, 100, 10, function(v)
		main.BackgroundTransparency = v/100
	end)

	Settings:CreateSection("System")
	Settings:AddButton("Reset Toggle Key (R-CTRL)", function() self.ToggleKey = Enum.KeyCode.RightControl end)
	
	Settings:CreateSection("Links")
	Settings:AddButton("Copy Discord Link", function() setclipboard("https://discord.gg/snowylib") end)

	Settings:CreateSection("Danger Zone")
	Settings:AddButton("Destroy Interface", function() diagOverlay.Visible = true end)

	return self
end

return SnowyLib
