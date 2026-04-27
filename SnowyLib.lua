-- SnowyLib V5 — Ultra-Compact & Pro (Final Standard)
-- Fix: UI size, Default Settings Tab, Toggle Key, Layout stability.

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local SnowyLib = {
	Theme = {
		Main = Color3.fromRGB(13, 13, 15),
		Sidebar = Color3.fromRGB(18, 18, 22),
		Accent = Color3.fromRGB(255, 255, 255),
		Card = Color3.fromRGB(22, 22, 26),
		Stroke = Color3.fromRGB(40, 40, 45),
		Text = Color3.fromRGB(255, 255, 255),
		Muted = Color3.fromRGB(140, 140, 150)
	}
}

-- ── Internal Utilities ─────────────────────────────────────────────────────

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	return inst
end

local function applyCorner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = inst
end

local function applyStroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness or 1
	s.Color = color or SnowyLib.Theme.Stroke
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
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

function SnowyLib.CreateWindow(config)
	config = config or {}
	local Title = config.Title or "Snowy Hub"
	local ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
	
	local screen = create("ScreenGui", { Name = "SnowyLib", Parent = localPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false, IgnoreGuiInset = true })
	
	-- Main Frame (Ultra Compact: 480x300)
	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(480, 310),
		BackgroundColor3 = SnowyLib.Theme.Main,
		ClipsDescendants = true,
		Parent = screen
	})
	applyCorner(main, 12)
	local mStroke = applyStroke(main, Color3.new(1,1,1), 1.5)
	mStroke.Transparency = 0.8
	
	-- Header
	local header = create("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = main })
	makeDraggable(header, main)
	
	local title = create("TextLabel", {
		Text = Title:upper(),
		Position = UDim2.fromOffset(15, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = SnowyLib.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = header
	})

	local closeBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Color3.fromRGB(255, 60, 60),
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Color3.new(1,1,1),
		Parent = header
	})
	applyCorner(closeBtn, 6)

	-- Sidebar
	local sidebar = create("Frame", {
		Position = UDim2.fromOffset(0, 45),
		Size = UDim2.new(0, 130, 1, -45),
		BackgroundColor3 = SnowyLib.Theme.Sidebar,
		Parent = main
	})
	applyCorner(sidebar, 12)
	
	local tabList = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -10),
		Position = UDim2.fromOffset(0, 5),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		Parent = sidebar
	})
	local tabLayout = create("UIListLayout", { Padding = UDim.new(0, 2), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = tabList })

	-- Content Area
	local content = create("Frame", {
		Position = UDim2.fromOffset(130, 45),
		Size = UDim2.new(1, -130, 1, -45),
		BackgroundTransparency = 1,
		Parent = main
	})

	-- Dialog Confirmation
	local dialogOverlay = create("Frame", { Visible = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5, ZIndex = 100, Parent = screen })
	local dialog = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(260, 130), BackgroundColor3 = SnowyLib.Theme.Main, Parent = dialogOverlay })
	applyCorner(dialog, 10); applyStroke(dialog)
	local diagT = create("TextLabel", { Text = "ĐÓNG MENU?", Size = UDim2.new(1, 0, 0, 30), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 60, 60), BackgroundTransparency = 1, Parent = dialog })
	local diagB = create("TextLabel", { Text = "Bạn có chắc chắn muốn thoát không?", Position = UDim2.fromOffset(10, 35), Size = UDim2.new(1, -20, 0, 40), Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = SnowyLib.Theme.Muted, TextWrapped = true, BackgroundTransparency = 1, Parent = dialog })
	local diagBtnHold = create("Frame", { Position = UDim2.new(0, 0, 1, -40), Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = dialog })
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 10), Parent = diagBtnHold })
	
	local function createDiagBtn(txt, color, cb)
		local b = create("TextButton", { Text = txt, Size = UDim2.fromOffset(100, 28), BackgroundColor3 = color, Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.new(1,1,1), Parent = diagBtnHold })
		applyCorner(b, 6); b.MouseButton1Click:Connect(cb)
	end
	createDiagBtn("HỦY", SnowyLib.Theme.Card, function() dialogOverlay.Visible = false end)
	createDiagBtn("THOÁT", Color3.fromRGB(255, 60, 60), function() screen:Destroy() end)
	closeBtn.MouseButton1Click:Connect(function() dialogOverlay.Visible = true end)

	-- Toggle Logic
	UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == ToggleKey then
			main.Visible = not main.Visible
		end
	end)

	local Window = { _activeTab = nil, _tabs = {} }

	function Window:CreateTab(name)
		local tabBtn = create("TextButton", {
			Text = name:upper(),
			Size = UDim2.new(1, -15, 0, 32),
			BackgroundColor3 = Color3.new(1,1,1),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			TextSize = 9,
			TextColor3 = SnowyLib.Theme.Muted,
			AutoButtonColor = false,
			Parent = tabList
		})
		applyCorner(tabBtn, 6)

		local page = create("ScrollingFrame", {
			Visible = false,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = SnowyLib.Theme.Accent,
			Parent = content
		})
		local pPadding = create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 12), Parent = page })
		local pLayout = create("UIListLayout", { Padding = UDim.new(0, 6), Parent = page })
		pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.fromOffset(0, pLayout.AbsoluteContentSize.Y + 20)
		end)

		local tabObj = { Page = page, Btn = tabBtn }

		local function select()
			if Window._activeTab then
				Window._activeTab.Page.Visible = false
				Window._activeTab.Btn.TextColor3 = SnowyLib.Theme.Muted
				Window._activeTab.Btn.BackgroundTransparency = 1
			end
			page.Visible = true
			tabBtn.TextColor3 = SnowyLib.Theme.Text
			tabBtn.BackgroundTransparency = 0.9
			Window._activeTab = tabObj
		end

		tabBtn.MouseButton1Click:Connect(select)
		if not Window._activeTab then select() end

		-- Elements API
		local Tab = {}

		function Tab:AddButton(text, callback)
			local btn = create("TextButton", {
				Text = text:upper(),
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = SnowyLib.Theme.Card,
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextColor3 = SnowyLib.Theme.Text,
				Parent = page
			})
			applyCorner(btn, 8); applyStroke(btn)
			btn.MouseButton1Click:Connect(function() pcall(callback) end)
			return btn
		end

		function Tab:AddToggle(text, default, callback)
			local state = default or false
			local card = create("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = SnowyLib.Theme.Card, Parent = page })
			applyCorner(card, 8); applyStroke(card)
			local label = create("TextLabel", { Text = text, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -50, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = SnowyLib.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = card })
			local toggler = create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(30, 16), BackgroundColor3 = state and SnowyLib.Theme.Accent or Color3.fromRGB(45, 45, 50), Parent = card })
			applyCorner(toggler, 10)
			local knob = create("Frame", { Position = state and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.new(1,1,1), Parent = toggler })
			applyCorner(knob, 10)

			local function update()
				TweenService:Create(toggler, TweenInfo.new(0.2), { BackgroundColor3 = state and SnowyLib.Theme.Accent or Color3.fromRGB(45, 45, 50) }):Play()
				TweenService:Create(knob, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2) }):Play()
				pcall(callback, state)
			end
			card.MouseButton1Click:Connect(function() state = not state; update() end)
			return { SetValue = function(_, v) state = v; update() end }
		end

		return Tab
	end

	-- Tự động thêm Tab Settings mặc định
	local SettingsTab = Window:CreateTab("Settings")
	SettingsTab:AddButton("Hủy bỏ UI (Destroy)", function() screen:Destroy() end)
	SettingsTab:AddButton("Copy Discord Link", function() setclipboard("https://discord.gg/snowylib") end)
	
	return Window
end

return SnowyLib
