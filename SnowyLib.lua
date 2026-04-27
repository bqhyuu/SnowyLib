-- SnowyLib V2 — Simple & Stable Edition
-- Mục tiêu: Hoạt động trơn tru, không lỗi, UI tối giản chuyên nghiệp.

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer
local Mouse            = localPlayer:GetMouse()

local SnowyLib = {
	Tabs = {},
	Options = {},
	Theme = {
		Main = Color3.fromRGB(20, 20, 23),
		Sidebar = Color3.fromRGB(25, 25, 28),
		Accent = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(255, 255, 255),
		Muted = Color3.fromRGB(160, 160, 165),
		Card = Color3.fromRGB(30, 30, 35),
		Stroke = Color3.fromRGB(45, 45, 50)
	}
}

-- ── Utilities ──────────────────────────────────────────────────────────────

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	return inst
end

local function applyCorner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = inst
end

local function applyStroke(inst, color, trans)
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Color = color or Color3.fromRGB(60, 60, 65)
	s.Transparency = trans or 0.8
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
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

-- ── Window ─────────────────────────────────────────────────────────────────

function SnowyLib.CreateWindow(config)
	config = config or {}
	local Title = config.Title or "Snowy Hub"
	
	local screen = create("ScreenGui", { Name = "SnowyLib", Parent = localPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false })
	
	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(550, 380),
		BackgroundColor3 = SnowyLib.Theme.Main,
		Parent = screen
	})
	applyCorner(main, 8)
	applyStroke(main)
	
	local side = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 150, 1, 0),
		BackgroundColor3 = SnowyLib.Theme.Sidebar,
		Parent = main
	})
	applyCorner(side, 8)
	
	local sideCover = create("Frame", { -- Che góc bo tròn bên phải sidebar
		Size = UDim2.new(0, 10, 1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		BackgroundColor3 = SnowyLib.Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = side
	})
	
	local sideTitle = create("TextLabel", {
		Text = Title:upper(),
		Size = UDim2.new(1, 0, 0, 40),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = SnowyLib.Theme.Accent,
		BackgroundTransparency = 1,
		Parent = side
	})

	local tabList = create("ScrollingFrame", {
		Name = "TabList",
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.new(1, 0, 1, -50),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		Parent = side
	})
	create("UIListLayout", { Padding = UDim.new(0, 2), Parent = tabList })
	
	local content = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(150, 0),
		Size = UDim2.new(1, -150, 1, 0),
		BackgroundTransparency = 1,
		Parent = main
	})
	
	makeDraggable(main, main)
	
	local Window = { _activeTab = nil }
	
	function Window:CreateTab(name)
		local tabBtn = create("TextButton", {
			Text = name,
			Size = UDim2.new(1, -20, 0, 30),
			Position = UDim2.fromOffset(10, 0),
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = SnowyLib.Theme.Muted,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Parent = tabList
		})
		
		local page = create("ScrollingFrame", {
			Visible = false,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = SnowyLib.Theme.Accent,
			Parent = content
		})
		applyPadding(page, 15, 15, 15, 15)
		local layout = create("UIListLayout", { Padding = UDim.new(0, 8), Parent = page })
		
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 20)
		end)
		
		local Tab = {}
		
		function Tab:AddButton(text, callback)
			local btn = create("TextButton", {
				Text = text,
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = SnowyLib.Theme.Card,
				Font = Enum.Font.GothamMedium,
				TextSize = 12,
				TextColor3 = SnowyLib.Theme.Text,
				AutoButtonColor = true,
				Parent = page
			})
			applyCorner(btn, 6)
			applyStroke(btn)
			btn.MouseButton1Click:Connect(function() pcall(callback) end)
		end
		
		function Tab:AddToggle(text, default, callback)
			local value = default or false
			local card = create("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = SnowyLib.Theme.Card,
				AutoButtonColor = false,
				Parent = page
			})
			applyCorner(card, 6)
			applyStroke(card)
			
			local label = create("TextLabel", {
				Text = text,
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -50, 1, 0),
				Font = Enum.Font.GothamMedium,
				TextSize = 12,
				TextColor3 = SnowyLib.Theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Parent = card
			})
			
			local toggler = create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(30, 16),
				BackgroundColor3 = value and SnowyLib.Theme.Accent or Color3.fromRGB(50, 50, 55),
				Parent = card
			})
			applyCorner(toggler, 10)
			
			local knob = create("Frame", {
				Position = value and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2),
				Size = UDim2.fromOffset(12, 12),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = toggler
			})
			applyCorner(knob, 10)
			
			local function toggle()
				value = not value
				TweenService:Create(toggler, TweenInfo.new(0.2), { BackgroundColor3 = value and SnowyLib.Theme.Accent or Color3.fromRGB(50, 50, 55) }):Play()
				TweenService:Create(knob, TweenInfo.new(0.2), { Position = value and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2) }):Play()
				pcall(callback, value)
			end
			
			card.MouseButton1Click:Connect(toggle)
		end

		tabBtn.MouseButton1Click:Connect(function()
			if Window._activeTab then
				Window._activeTab.Page.Visible = false
				Window._activeTab.Btn.TextColor3 = SnowyLib.Theme.Muted
			end
			page.Visible = true
			tabBtn.TextColor3 = SnowyLib.Theme.Accent
			Window._activeTab = { Page = page, Btn = tabBtn }
		end)
		
		if not Window._activeTab then
			page.Visible = true
			tabBtn.TextColor3 = SnowyLib.Theme.Accent
			Window._activeTab = { Page = page, Btn = tabBtn }
		end
		
		return Tab
	end
	
	return Window
end

-- Helper để padding
function applyPadding(inst, l, r, t, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.Parent = inst
end

return SnowyLib
