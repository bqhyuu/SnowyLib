-- SnowyLib V3 — High Fidelity Website Edition
-- Hoàn hảo về thẩm mỹ, ổn định về tính năng.

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local localPlayer      = Players.LocalPlayer

local THEME = {
	Background = Color3.fromRGB(8, 8, 10),
	Sidebar    = Color3.fromRGB(12, 12, 15),
	Accent     = Color3.fromRGB(255, 255, 255),
	Card       = Color3.fromRGB(20, 20, 25),
	Stroke     = Color3.fromRGB(45, 45, 50),
	Text       = Color3.fromRGB(255, 255, 255),
	Muted      = Color3.fromRGB(130, 130, 140)
}

-- ── Utilities ──────────────────────────────────────────────────────────────

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	return inst
end

local function applyCorner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = inst
end

local function applyStroke(inst, color, thickness, trans)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness or 1.5
	s.Color = color or THEME.Stroke
	s.Transparency = trans or 0.7
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

function SnowyLib.CreateWindow(config)
	config = config or {}
	local self = setmetatable({
		_activeTab = nil,
		_tabs = {},
		Options = {}
	}, SnowyLib)

	local screen = create("ScreenGui", { Name = "SnowyLib", Parent = localPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false, IgnoreGuiInset = true })
	self._screen = screen

	-- Window
	local main = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(620, 440),
		BackgroundColor3 = THEME.Background,
		Parent = screen
	})
	applyCorner(main, 24)
	local mainStroke = applyStroke(main, Color3.new(1,1,1), 2, 0.8)
	self._main = main

	-- Hiệu ứng Glow nhịp thở (Website style)
	task.spawn(function()
		while main.Parent do
			tween(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.5 })
			task.wait(2)
			tween(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.9 })
			task.wait(2)
		end
	end)

	-- Header
	local header = create("Frame", {
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundTransparency = 1,
		Parent = main
	})
	applyPadding(header, 25, 25, 0, 0)
	makeDraggable(header, main)

	local title = create("TextLabel", {
		Text = (config.Title or "SNOWY HUB"):upper(),
		Size = UDim2.new(0.5, 0, 1, 0),
		Font = Enum.Font.GothamBlack,
		TextSize = 14,
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = header
	})

	local closeBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = Color3.fromRGB(255, 60, 60),
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextColor3 = Color3.new(1,1,1),
		AutoButtonColor = false,
		Parent = header
	})
	applyCorner(closeBtn, 10)
	
	-- Sidebar
	local sidebar = create("Frame", {
		Position = UDim2.fromOffset(0, 60),
		Size = UDim2.new(0, 160, 1, -60),
		BackgroundColor3 = THEME.Sidebar,
		BackgroundTransparency = 0.5,
		Parent = main
	})
	applyCorner(sidebar, 24)
	applyPadding(sidebar, 12, 12, 15, 12)
	
	local tabContainer = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		Parent = sidebar
	})
	create("UIListLayout", { Padding = UDim.new(0, 5), Parent = tabContainer })

	-- Content
	local content = create("Frame", {
		Position = UDim2.fromOffset(160, 60),
		Size = UDim2.new(1, -160, 1, -60),
		BackgroundTransparency = 1,
		Parent = main
	})
	self._content = content

	-- Bảng thông báo xác nhận đóng (Dialog)
	local dialogOverlay = create("Frame", {
		Visible = false,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 0.4,
		ZIndex = 100,
		Parent = screen
	})
	local dialog = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(300, 160),
		BackgroundColor3 = THEME.Background,
		Parent = dialogOverlay
	})
	applyCorner(dialog, 20)
	applyStroke(dialog)
	applyPadding(dialog, 20, 20, 20, 20)
	
	local diagTitle = create("TextLabel", {
		Text = "XÁC NHẬN",
		Size = UDim2.new(1, 0, 0, 20),
		Font = Enum.Font.GothamBlack,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(255, 60, 60),
		BackgroundTransparency = 1,
		Parent = dialog
	})
	local diagBody = create("TextLabel", {
		Text = "Bạn có chắc chắn muốn đóng menu không? Mọi thay đổi chưa lưu sẽ mất.",
		Position = UDim2.fromOffset(0, 30),
		Size = UDim2.new(1, 0, 0, 50),
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = THEME.Muted,
		TextWrapped = true,
		BackgroundTransparency = 1,
		Parent = dialog
	})
	
	local diagButtons = create("Frame", {
		Position = UDim2.new(0, 0, 1, -35),
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundTransparency = 1,
		Parent = dialog
	})
	local diagLayout = create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 10), Parent = diagButtons })

	local function createDiagBtn(txt, color, callback)
		local b = create("TextButton", {
			Text = txt:upper(),
			Size = UDim2.fromOffset(110, 32),
			BackgroundColor3 = color,
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextColor3 = Color3.new(1,1,1),
			Parent = diagButtons
		})
		applyCorner(b, 8)
		b.MouseButton1Click:Connect(callback)
	end

	createDiagBtn("HỦY", THEME.Card, function() dialogOverlay.Visible = false end)
	createDiagBtn("ĐÓNG", Color3.fromRGB(255, 60, 60), function() screen:Destroy() end)

	closeBtn.MouseButton1Click:Connect(function() dialogOverlay.Visible = true end)

	-- Tabs Logic
	function self:CreateTab(name)
		local tabBtn = create("TextButton", {
			Text = name:upper(),
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Color3.new(1,1,1),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			TextSize = 10,
			TextColor3 = THEME.Muted,
			AutoButtonColor = false,
			Parent = tabContainer
		})
		applyCorner(tabBtn, 10)
		local accentBar = create("Frame", {
			Size = UDim2.new(0, 3, 0, 18),
			Position = UDim2.new(0, 2, 0.5, -9),
			BackgroundColor3 = THEME.Accent,
			Visible = false,
			Parent = tabBtn
		})
		applyCorner(accentBar, 2)

		local page = create("ScrollingFrame", {
			Visible = false,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = THEME.Accent,
			Parent = content
		})
		applyPadding(page, 20, 20, 10, 20)
		local layout = create("UIListLayout", { Padding = UDim.new(0, 10), Parent = page })
		
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 20)
		end)

		local tabObj = { _page = page, _btn = tabBtn, _accent = accentBar }

		tabBtn.MouseButton1Click:Connect(function()
			if self._activeTab then
				self._activeTab._page.Visible = false
				self._activeTab._btn.TextColor3 = THEME.Muted
				self._activeTab._btn.BackgroundTransparency = 1
				self._activeTab._accent.Visible = false
			end
			page.Visible = true
			tabBtn.TextColor3 = THEME.Text
			tabBtn.BackgroundTransparency = 0.9
			accentBar.Visible = true
			self._activeTab = tabObj
		end)

		if not self._activeTab then
			page.Visible = true
			tabBtn.TextColor3 = THEME.Text
			tabBtn.BackgroundTransparency = 0.9
			accentBar.Visible = true
			self._activeTab = tabObj
		end

		-- Components
		local components = {}

		function components:AddButton(text, callback)
			local btn = create("TextButton", {
				Text = text:upper(),
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = THEME.Card,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = THEME.Text,
				AutoButtonColor = true,
				Parent = page
			})
			applyCorner(btn, 12)
			applyStroke(btn)
			btn.MouseButton1Click:Connect(function() pcall(callback) end)
		end

		function components:AddToggle(text, default, callback)
			local state = default or false
			local card = create("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = THEME.Card,
				AutoButtonColor = false,
				Parent = page
			})
			applyCorner(card, 12)
			applyStroke(card)
			applyPadding(card, 15, 15, 0, 0)

			local label = create("TextLabel", {
				Text = text,
				Size = UDim2.new(1, -50, 1, 0),
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = THEME.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Parent = card
			})

			local toggler = create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(36, 20),
				BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(40, 40, 45),
				Parent = card
			})
			applyCorner(toggler, 10)
			
			local knob = create("Frame", {
				Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2),
				Size = UDim2.fromOffset(16, 16),
				BackgroundColor3 = Color3.new(1,1,1),
				Parent = toggler
			})
			applyCorner(knob, 10)

			card.MouseButton1Click:Connect(function()
				state = not state
				tween(toggler, TweenInfo.new(0.2), { BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(40, 40, 45) })
				tween(knob, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2) })
				pcall(callback, state)
			end)
		end

		return components
	end

	return self
end

return SnowyLib
