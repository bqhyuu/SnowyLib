-- SnowyLib — Bundled single-file version
-- Usage: local SnowyLib = loadstring(game:HttpGet("RAW_URL"))()

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer

local RAW = "https://raw.githubusercontent.com/bqhyuu/SnowyLib/refs/heads/main/"
local LUCIDE_ICONS   = loadstring(game:HttpGet(RAW .. "Icon/LucideIcons.lua"))()
local PHOSPHOR_ICONS = loadstring(game:HttpGet(RAW .. "Icon/PhosphorIcons.lua"))()


local THEMES = {
	Dark     = loadstring(game:HttpGet(RAW .. "Themes/Dark.lua"))(),
	Aqua     = loadstring(game:HttpGet(RAW .. "Themes/Aqua.lua"))(),
	Rose     = loadstring(game:HttpGet(RAW .. "Themes/Rose.lua"))(),
	Darker   = loadstring(game:HttpGet(RAW .. "Themes/Darker.lua"))(),
	Amethyst = loadstring(game:HttpGet(RAW .. "Themes/Amethyst.lua"))(),
	Midnight = loadstring(game:HttpGet(RAW .. "Themes/Midnight.lua"))(),
	Emerald  = loadstring(game:HttpGet(RAW .. "Themes/Emerald.lua"))(),
}

-- ── Util ───────────────────────────────────────────────────────────────────


local function safeCall(callback, ...)
	if type(callback) ~= "function" then
		return
	end

	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[SnowyLib] Callback error:", err)
	end
end

local function create(instanceType, props)
	local instance = Instance.new(instanceType)
	for key, value in pairs(props or {}) do
		instance[key] = value
	end
	return instance
end

local function applyCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = instance
	return corner
end

local function applyStroke(instance, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 1
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

-- resolveIcon: hỗ trợ
--   "ph:gear"          → Phosphor
--   "lucide:settings"  → Lucide
--   "settings"         → auto-detect (Lucide trước, Phosphor sau)
--   "rbxassetid://..."  → trả thẳng
--   "https://..."       → trả thẳng
local function resolveIcon(name)
	if not name or name == "" then return nil end
	if string.find(name, "rbxassetid://", 1, true) or string.find(name, "http", 1, true) then
		return name
	end

	local prefix, rest = string.match(name, "^(%a+):(.+)$")
	if prefix == "ph" then
		return PHOSPHOR_ICONS["ph-" .. rest] or PHOSPHOR_ICONS[rest]
	elseif prefix == "lucide" or prefix == "lu" then
		return LUCIDE_ICONS["lucide-" .. rest] or LUCIDE_ICONS[rest]
	end

	-- auto-detect: Lucide first, then Phosphor
	return LUCIDE_ICONS["lucide-" .. name] or LUCIDE_ICONS[name]
		or PHOSPHOR_ICONS["ph-" .. name] or PHOSPHOR_ICONS[name]
end

-- keep old name as alias for backwards compat
local resolveLucideIcon = resolveIcon

local function isAsset(value)
	return type(value) == "string"
		and (string.find(value, "rbxassetid://", 1, true) ~= nil or string.find(value, "http", 1, true) ~= nil)
end

local function shallowCopy(list)
	local copy = {}
	for index, value in ipairs(list or {}) do
		copy[index] = value
	end
	return copy
end

local function contains(list, value)
	for _, item in ipairs(list) do
		if item == value then
			return true
		end
	end
	return false
end

local function removeValue(list, value)
	for index = #list, 1, -1 do
		if list[index] == value then
			table.remove(list, index)
		end
	end
end

local function roundToStep(value, minValue, step)
	local base = step > 0 and step or 1
	local steps = math.floor(((value - minValue) / base) + 0.5)
	return minValue + (steps * base)
end

local function clampToRange(value, minValue, maxValue, step)
	local rounded = roundToStep(value, minValue, step)
	return math.clamp(rounded, minValue, maxValue)
end

local function keyCodeFromValue(value, fallback)
	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value
	end

	if type(value) == "string" and Enum.KeyCode[value] then
		return Enum.KeyCode[value]
	end

	return fallback or Enum.KeyCode.RightControl
end

local function keyCodeLabel(keyCode)
	local name = keyCode.Name
	if string.sub(name, 1, 3) == "Key" then
		return string.sub(name, 4)
	end
	return name
end

local function tween(instance, info, props)
	local tweenObject = TweenService:Create(instance, info, props)
	tweenObject:Play()
	return tweenObject
end

local function makeDraggable(windowObject, handle, target)
	local dragging = false
	local dragInput
	local dragStart
	local startPosition

	table.insert(windowObject._connections, handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = target.Position

		local endedConnection
		endedConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if endedConnection then
					endedConnection:Disconnect()
				end
			end
		end)

		table.insert(windowObject._connections, endedConnection)
	end))

	table.insert(windowObject._connections, handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))

	table.insert(windowObject._connections, UserInputService.InputChanged:Connect(function(input)
		if not dragging or input ~= dragInput then
			return
		end

		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end))
end

local function autoCanvasSize(scroller, layout, extraPadding)
	local function update()
		scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + (extraPadding or 0))
	end

	update()
	return layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
end

local function createIconVisual(parent, icon, fallbackText)
	local resolved = resolveLucideIcon(icon)
	if resolved and isAsset(resolved) then
		local image = create("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			Image = resolved,
			Parent = parent,
		})
		return image, nil
	end

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(16, 16),
		Font = Enum.Font.GothamBold,
		Text = tostring(fallbackText or "•"),
		TextSize = 12,
		Parent = parent,
	})
	return nil, label
end



-- Util exports (used by components below)
local _Util = {
	safeCall         = safeCall,
	create           = create,
	applyCorner      = applyCorner,
	applyStroke      = applyStroke,
	applyPadding     = applyPadding,
	resolveLucideIcon = resolveLucideIcon,
	resolveIcon      = resolveIcon,
	isAsset          = isAsset,
	shallowCopy      = shallowCopy,
	contains         = contains,
	removeValue      = removeValue,
	clampToRange     = clampToRange,
	keyCodeFromValue = keyCodeFromValue,
	keyCodeLabel     = keyCodeLabel,
	tween            = tween,
	makeDraggable    = makeDraggable,
	autoCanvasSize   = autoCanvasSize,
	createIconVisual = createIconVisual,
}

-- ── Component: Paragraph ───────────────────────────────────────────────────
local _comp_Paragraph = function(window, content, config)
	config = config or {}

	local card = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BorderSizePixel = 0,
		Parent = content,
	})
	applyCorner(card, UDim.new(0, 12))
	local stroke = applyStroke(card, 1)
	applyPadding(card, 12, 12, 10, 10)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = card,
	})

	local titleLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 12),
		Font = Enum.Font.GothamBold,
		Text = string.upper(config.Title or "PARAGRAPH"),
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local body = create("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Font = Enum.Font.GothamMedium,
		Text = config.Content or "",
		TextSize = 10,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = card,
	})

	window:_registerStyler(function(colors)
		card.BackgroundColor3 = colors.Surface
		stroke.Color = colors.Stroke
		titleLabel.TextColor3 = colors.Accent
		body.TextColor3 = colors.MutedText
	end)

	return card
end


-- ── Component: Button ──────────────────────────────────────────────────────
local _comp_Button = function(window, parts, config)
	config = config or {}

	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 124, 0, 28),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = config.ButtonText or string.upper(config.Title or "RUN"),
		TextSize = 10,
		Parent = parts.Right,
	})
	applyCorner(button, UDim.new(0, 10))
	local stroke = applyStroke(button, 1)

	window:_registerStyler(function(colors)
		button.BackgroundColor3 = colors.SurfaceAlt
		button.TextColor3 = colors.Text
		stroke.Color = colors.Stroke
	end)

	table.insert(window._connections, button.MouseButton1Click:Connect(function()
		safeCall(config.Callback)
	end))

	return {
		SetText = function(_, text)
			button.Text = text
		end,
	}
end


-- ── Component: Toggle ──────────────────────────────────────────────────────
local _comp_Toggle = function(window, parts, config)
	config = config or {}
	local value = not not config.Default

	local hitbox = create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		Parent = parts.Card,
	})

	local track = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(36, 18),
		BorderSizePixel = 0,
		Parent = parts.Right,
	})
	applyCorner(track, UDim.new(1, 0))
	local trackStroke = applyStroke(track, 1)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BorderSizePixel = 0,
		Parent = track,
	})
	applyCorner(knob, UDim.new(1, 0))

	local function render(animate)
		local colors = window:_getColors()
		if value then
			track.BackgroundColor3 = colors.Accent
			trackStroke.Color = colors.Accent
			knob.BackgroundColor3 = Color3.new(1, 1, 1)
			if animate then
				tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, 20, 0.5, 0) })
			else
				knob.Position = UDim2.new(0, 20, 0.5, 0)
			end
		else
			track.BackgroundColor3 = colors.SurfaceAlt
			trackStroke.Color = colors.Stroke
			knob.BackgroundColor3 = Color3.fromRGB(190, 190, 190)
			if animate then
				tween(knob, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0, 2, 0.5, 0) })
			else
				knob.Position = UDim2.new(0, 2, 0.5, 0)
			end
		end
	end

	window:_registerStyler(function()
		render(false)
	end)

	local control = {}

	function control:Set(state)
		value = not not state
		render(true)
		safeCall(config.Callback, value)
	end
	function control:Get()
		return value
	end
	table.insert(window._connections, hitbox.MouseButton1Click:Connect(function()
		control:Set(not value)
	end))
	return control 
end


-- ── Component: Slider ──────────────────────────────────────────────────────
local _comp_Slider = function(window, parts, config)
	config = config or {}
	local minValue = tonumber(config.Min) or 0
	local maxValue = tonumber(config.Max) or 100
	local step     = tonumber(config.Step) or 1
	local value    = clampToRange(tonumber(config.Default) or minValue, minValue, maxValue, step)
	local decimals = tonumber(config.Decimals)

	local sliderArea = create("Frame", {
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parts.Card,
	})

	local bar = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, -68, 0, 4),
		BorderSizePixel = 0,
		Parent = sliderArea,
	})
	applyCorner(bar, UDim.new(1, 0))

	local fill = create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0,
		Parent = bar,
	})
	applyCorner(fill, UDim.new(1, 0))

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BorderSizePixel = 0,
		Parent = bar,
	})
	applyCorner(knob, UDim.new(1, 0))

	local input = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(56, 24),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Code,
		Text = tostring(value),
		TextSize = 10,
		Parent = sliderArea,
	})
	applyCorner(input, UDim.new(0, 8))
	local inputStroke = applyStroke(input, 1)

	local function formatValue(number)
		if decimals then
			return string.format("%." .. tostring(decimals) .. "f", number)
		end
		if step >= 1 then
			return tostring(math.floor(number + 0.5))
		end
		return string.format("%.2f", number)
	end

	local function render()
		local colors = window:_getColors()
		local alpha = (value - minValue) / math.max(maxValue - minValue, 0.001)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		input.Text = formatValue(value)
		bar.BackgroundColor3 = colors.SurfaceAlt
		fill.BackgroundColor3 = colors.Accent
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		input.BackgroundColor3 = colors.SurfaceAlt
		input.TextColor3 = colors.Accent
		inputStroke.Color = colors.Stroke
	end

	local control = {}

	function control:Set(newValue)
		value = clampToRange(tonumber(newValue) or value, minValue, maxValue, step)
		render()
		safeCall(config.Callback, value)
	end

	function control:Get()
		return value
	end

	local dragging = false
	local function setFromInputPosition(positionX)
		local alpha = math.clamp((positionX - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		control:Set(minValue + ((maxValue - minValue) * alpha))
	end

	table.insert(window._connections, bar.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromInputPosition(inputObject.Position.X)
		end
	end))

	table.insert(window._connections, bar.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	table.insert(window._connections, UserInputService.InputChanged:Connect(function(inputObject)
		if dragging and (inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch) then
			setFromInputPosition(inputObject.Position.X)
		end
	end))

	table.insert(window._connections, input.FocusLost:Connect(function()
		control:Set(tonumber(input.Text) or value)
	end))

	window:_registerStyler(function()
		render()
	end)

	return control
end


-- ── Component: Dropdown ────────────────────────────────────────────────────
local _comp_Dropdown = function(window, parts, config)
	config = config or {}
	local items    = shallowCopy(config.Items or config.Values or {})
	local isMulti  = not not config.Multi
	local selected = isMulti and shallowCopy(config.Default or {}) or (config.Default or items[1] or "")

	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(132, 28),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parts.Right,
	})
	applyCorner(button, UDim.new(0, 10))
	applyPadding(button, 10, 26, 0, 0)
	local buttonStroke = applyStroke(button, 1)

	local chevron = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "v",
		TextSize = 10,
		Parent = button,
	})

	local expand = create("Frame", {
		LayoutOrder = 2,
		Visible = false,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parts.Card,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = expand,
	})

	local search = create("TextBox", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		PlaceholderText = "Search...",
		Text = "",
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = expand,
	})
	applyCorner(search, UDim.new(0, 10))
	applyPadding(search, 10, 10, 0, 0)
	local searchStroke = applyStroke(search, 1)

	local listFrame = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 132),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 2,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = expand,
	})
	applyCorner(listFrame, UDim.new(0, 10))
	local listStroke = applyStroke(listFrame, 1)
	applyPadding(listFrame, 6, 6, 6, 6)
	local itemLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = listFrame,
	})
	table.insert(window._connections, autoCanvasSize(listFrame, itemLayout, 8))

	local open = false
	local optionCache = {}

	local function isSelected(item)
		return isMulti and contains(selected, item) or selected == item
	end

	local function getSummary()
		if isMulti then
			local n = #selected
			if n == 0 then return "Select items..." end
			if n == #items then return "All Selected" end
			if n > 2 then return tostring(selected[1]) .. " +" .. tostring(n - 1) end
			return table.concat(selected, ", ")
		end
		return tostring(selected)
	end

	local function getValue()
		return isMulti and shallowCopy(selected) or selected
	end

	local function styleItems()
		local colors = window:_getColors()
		for item, p in pairs(optionCache) do
			local chosen = isSelected(item)
			p.btn.BackgroundColor3 = chosen and colors.SurfaceAlt or colors.Surface
			p.btn.TextColor3 = chosen and colors.Accent or colors.Text
			p.check.Text = chosen and "✓" or ""
			p.check.TextColor3 = colors.Accent
		end
	end

	local lastQuery = ""
	local function buildList()
		local colors = window:_getColors()
		local query = string.lower(search.Text)
		if query == lastQuery then styleItems() return end
		lastQuery = query

		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
		end
		optionCache = {}

		local visibleCount = 0
		for _, item in ipairs(items) do
			if query == "" or string.find(string.lower(item), query, 1, true) then
				visibleCount += 1
				local opt = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Font = Enum.Font.GothamBold,
					Text = string.upper(item),
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = listFrame,
				})
				applyCorner(opt, UDim.new(0, 8))
				applyPadding(opt, 10, 10, 0, 0)
				local chk = create("TextLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(12, 12),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = "",
					TextSize = 10,
					Parent = opt,
				})
				optionCache[item] = { btn = opt, check = chk }

				table.insert(window._connections, opt.MouseButton1Click:Connect(function()
					if isMulti then
						if contains(selected, item) then removeValue(selected, item)
						else table.insert(selected, item) end
					else
						selected = item
						open = false
						expand.Visible = false
					end
					button.Text = getSummary()
					styleItems()
					safeCall(config.Callback, getValue())
				end))
			end
		end

		if visibleCount == 0 then
			create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				Text = "NO RESULTS",
				TextSize = 10,
				TextColor3 = colors.MutedText,
				Parent = listFrame,
			})
		end

		styleItems()
	end

	local control = {}

	function control:Set(newValue)
		selected = isMulti and shallowCopy(newValue or {}) or tostring(newValue or "")
		button.Text = getSummary()
		styleItems()
		safeCall(config.Callback, getValue())
	end

	function control:Get()
		return getValue()
	end

	table.insert(window._connections, button.MouseButton1Click:Connect(function()
		open = not open
		expand.Visible = open
	end))

	table.insert(window._connections, search:GetPropertyChangedSignal("Text"):Connect(function()
		buildList()
	end))

	window:_registerStyler(function(colors)
		button.BackgroundColor3 = colors.SurfaceAlt
		button.TextColor3 = colors.Text
		buttonStroke.Color = colors.Stroke
		chevron.TextColor3 = colors.Accent
		search.BackgroundColor3 = colors.SurfaceAlt
		search.TextColor3 = colors.Text
		search.PlaceholderColor3 = colors.MutedText
		searchStroke.Color = colors.Stroke
		listFrame.BackgroundColor3 = colors.SurfaceAlt
		listStroke.Color = colors.Stroke
		listFrame.ScrollBarImageColor3 = colors.Accent
		styleItems()
	end)

	button.Text = getSummary()
	buildList()

	return control
end


-- ── Component: Textbox ─────────────────────────────────────────────────────
local _comp_Textbox = function(window, parts, config)
	config = config or {}
	local value = tostring(config.Default or "")

	local box = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(136, 28),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		PlaceholderText = config.Placeholder or "",
		Text = value,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parts.Right,
	})
	applyCorner(box, UDim.new(0, 10))
	applyPadding(box, 10, 10, 0, 0)
	local stroke = applyStroke(box, 1)

	local control = {}

	function control:Set(newValue)
		value = tostring(newValue or "")
		box.Text = value
		safeCall(config.Callback, value)
	end

	function control:Get()
		return value
	end

	table.insert(window._connections, box:GetPropertyChangedSignal("Text"):Connect(function()
		value = box.Text
		safeCall(config.Callback, value)
	end))

	window:_registerStyler(function(colors)
		box.BackgroundColor3 = colors.SurfaceAlt
		box.TextColor3 = colors.Text
		box.PlaceholderColor3 = colors.MutedText
		stroke.Color = colors.Stroke
	end)

	return control
end


-- ── Component: Keybind ─────────────────────────────────────────────────────
local _comp_Keybind = function(window, parts, config)
	config = config or {}
	local current  = keyCodeFromValue(config.Default, Enum.KeyCode.C)
	local listening = false

	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(104, 28),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		Parent = parts.Right,
	})
	applyCorner(button, UDim.new(0, 10))
	local stroke = applyStroke(button, 1)

	local function render()
		local colors = window:_getColors()
		button.BackgroundColor3 = colors.SurfaceAlt
		button.TextColor3 = listening and colors.Accent or colors.Text
		button.Text = listening and "LISTENING" or string.upper(keyCodeLabel(current))
		stroke.Color = listening and colors.Accent or colors.Stroke
	end

	local control = {}

	function control:Set(newKey)
		current = keyCodeFromValue(newKey, current)
		listening = false
		render()
		safeCall(config.Callback, current)
	end

	function control:Get()
		return current
	end

	table.insert(window._connections, button.MouseButton1Click:Connect(function()
		listening = true
		render()
	end))

	table.insert(window._connections, UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
		if gameProcessed then return end
		if listening then
			if inputObject.KeyCode ~= Enum.KeyCode.Unknown then
				control:Set(inputObject.KeyCode)
			end
			return
		end
		if inputObject.KeyCode == current then
			safeCall(config.Pressed, current)
		end
	end))

	window:_registerStyler(function()
		render()
	end)

	return control
end


-- ── Section ────────────────────────────────────────────────────────────────


local function createSectionObject(window, parent, name)
	local section = {}

	local wrapper = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parent,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = wrapper,
	})

	if name and name ~= "" then
		local header = create("Frame", {
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = wrapper,
		})

		local sectionTitle = create("TextLabel", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = string.upper(name),
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = header,
		})

		local line = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(1, -8, 0, 1),
			BorderSizePixel = 0,
			Parent = header,
		})

		window:_registerStyler(function(colors)
			sectionTitle.TextColor3 = colors.Accent
			line.BackgroundColor3 = colors.Stroke
		end)
	end

	local content = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = wrapper,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = content,
	})

	local function createCard(titleText, descriptionText)
		local card = create("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			BorderSizePixel = 0,
			Parent = content,
		})
		applyCorner(card, UDim.new(0, 10))
		local stroke = applyStroke(card, 1)
		applyPadding(card, 12, 12, 10, 10)
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
			Parent = card,
		})

		-- top row: justify-between (title left, control right)
		local top = create("Frame", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = card,
		})

		local titleLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(0.55, 0, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = titleText or "Control",
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Parent = top,
		})

		local descriptionLabel
		if descriptionText and descriptionText ~= "" then
			top.Size = UDim2.new(1, 0, 0, 36)
			descriptionLabel = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 16),
				Size = UDim2.new(0.55, 0, 0, 14),
				Font = Enum.Font.GothamMedium,
				Text = descriptionText,
				TextSize = 9,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Parent = top,
			})
		end

		-- right side: control goes here (AnchorPoint 1,0.5 Position 1,0,0.5,0)
		local right = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0.42, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = top,
		})

		window:_registerStyler(function(colors)
			card.BackgroundColor3 = colors.Surface
			stroke.Color = colors.Stroke
			titleLabel.TextColor3 = colors.Text
			if descriptionLabel then
				descriptionLabel.TextColor3 = colors.MutedText
			end
		end)

		return { Card = card, Top = top, Inner = nil, Left = nil, LeftList = nil, Right = right }
	end

	function section:CreateParagraph(config)
		return _comp_Paragraph(window, content, config)
	end

	function section:CreateButton(config)
		return _comp_Button(window, createCard((config or {}).Title or "Button", (config or {}).Description), config)
	end

	function section:CreateToggle(config)
		return _comp_Toggle(window, createCard((config or {}).Title or "Toggle", (config or {}).Description), config)
	end

	function section:CreateSlider(config)
		return _comp_Slider(window, createCard((config or {}).Title or "Slider", (config or {}).Description), config)
	end

	function section:CreateDropdown(config)
		return _comp_Dropdown(window, createCard((config or {}).Title or "Dropdown", (config or {}).Description), config)
	end

	function section:CreateTextbox(config)
		return _comp_Textbox(window, createCard((config or {}).Title or "Textbox", (config or {}).Description), config)
	end

	function section:CreateKeybind(config)
		return _comp_Keybind(window, createCard((config or {}).Title or "Keybind", (config or {}).Description), config)
	end

	return section
end



-- ── Tab ────────────────────────────────────────────────────────────────────


local function createTabObject(window, name, icon)
	local tab = {}

	local button = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = window._sidebar,
	})
	applyCorner(button, UDim.new(0, 10))
	local stroke = applyStroke(button, 1)

	-- left accent bar
	local indicator = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 3, 0, 18),
		Visible = false,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = button,
	})
	applyCorner(indicator, UDim.new(1, 0))

	local iconHolder = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(14, 11),
		Parent = button,
	})

	local iconImage, iconLabel = createIconVisual(iconHolder, icon, string.sub(name or "T", 1, 1))

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(36, 0),
		Size = UDim2.new(1, -50, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = name or "Tab",
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button,
	})

	-- active dot right side
	local activeDot = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(5, 5),
		BorderSizePixel = 0,
		Visible = false,
		Parent = button,
	})
	applyCorner(activeDot, UDim.new(1, 0))

	local page = create("ScrollingFrame", {
		Name = tostring(name or "Tab") .. "Page",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = window._content,
	})

	applyPadding(page, 20, 20, 12, 20)
	local pageLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12),
		Parent = page,
	})
	table.insert(window._connections, autoCanvasSize(page, pageLayout, 16))

	tab._button = button
	tab._page = page
	tab._name = name or "Tab"
	tab._defaultSection = nil

	local function getDefaultSection()
		if not tab._defaultSection then
			tab._defaultSection = createSectionObject(window, page, "")
		end
		return tab._defaultSection
	end

	function tab:CreateSection(sectionName)
		return createSectionObject(window, page, sectionName)
	end

	-- Add* API — shorthand trực tiếp trên tab, không cần CreateSection
	function tab:AddParagraph(config)
		return getDefaultSection():CreateParagraph(config)
	end

	function tab:AddButton(config)
		return getDefaultSection():CreateButton(config)
	end

	-- AddToggle(key, config) — đăng ký vào Options[key]
	function tab:AddToggle(key, config)
		local listeners = {}
		local origCallback = config.Callback
		local wrapped = { Value = not not config.Default }

		-- inject trước khi tạo control
		config.Callback = function(value)
			wrapped.Value = value
			for _, cb in ipairs(listeners) do safeCall(cb) end
			if origCallback then safeCall(origCallback, value) end
		end

		local control = getDefaultSection():CreateToggle(config)

		wrapped.OnChanged = function(_, callback) table.insert(listeners, callback) end
		wrapped.SetValue = function(_, value) control:Set(value) end
		wrapped.Get = function(_) return control:Get() end

		if key then window._options[key] = wrapped end
		return wrapped
	end

	-- AddSlider(key, config)
	function tab:AddSlider(key, config)
		local listeners = {}
		local origCallback = config.Callback
		-- handle Rounding alias for Decimals
		if config.Rounding ~= nil and config.Decimals == nil then
			config.Decimals = config.Rounding
		end
		local wrapped = { Value = tonumber(config.Default) or tonumber(config.Min) or 0 }

		config.Callback = function(value)
			wrapped.Value = value
			for _, cb in ipairs(listeners) do safeCall(cb, value) end
			if origCallback then safeCall(origCallback, value) end
		end

		local control = getDefaultSection():CreateSlider(config)

		wrapped.OnChanged = function(_, callback) table.insert(listeners, callback) end
		wrapped.SetValue = function(_, value) control:Set(value) end
		wrapped.Get = function(_) return control:Get() end

		if key then window._options[key] = wrapped end
		return wrapped
	end

	-- AddDropdown(key, config)
	-- Multi mode: SetValue nhận { key = bool }, OnChanged trả về { key = bool }
	function tab:AddDropdown(key, config)
		local items = config.Values or config.Items or {}
		config.Items = items
		if type(config.Default) == "number" then
			config.Default = items[config.Default]
		end

		local isMulti = not not config.Multi
		local listeners = {}
		local origCallback = config.Callback

		local function normalizeValue(raw)
			if isMulti then
				local map = {}
				for _, v in ipairs(type(raw) == "table" and raw or {}) do map[v] = true end
				return map
			end
			return raw
		end

		local wrapped = { Value = normalizeValue(isMulti and shallowCopy(config.Default or {}) or (config.Default or items[1] or "")) }

		config.Callback = function(raw)
			wrapped.Value = normalizeValue(raw)
			for _, cb in ipairs(listeners) do safeCall(cb, wrapped.Value) end
			if origCallback then safeCall(origCallback, raw) end
		end

		local control = getDefaultSection():CreateDropdown(config)

		wrapped.OnChanged = function(_, callback) table.insert(listeners, callback) end
		wrapped.SetValue = function(_, value)
			if isMulti then
				local current = control:Get()
				for k, state in pairs(value) do
					if state then
						if not contains(current, k) then table.insert(current, k) end
					else
						removeValue(current, k)
					end
				end
				control:Set(current)
			else
				control:Set(value)
			end
		end
		wrapped.Get = function(_) return control:Get() end

		if key then window._options[key] = wrapped end
		return wrapped
	end

	window:_registerStyler(function(colors)
		local active = window._activeTab == tab
		button.BackgroundColor3 = active and colors.SurfaceAlt or colors.Sidebar
		button.BackgroundTransparency = active and 0 or 0
		stroke.Color = active and colors.Accent or colors.Stroke
		stroke.Transparency = active and 0 or 1
		indicator.Visible = active
		indicator.BackgroundColor3 = colors.Accent
		activeDot.Visible = active
		activeDot.BackgroundColor3 = colors.Accent
		label.TextColor3 = active and colors.Text or colors.MutedText
		label.TextTransparency = active and 0 or 0.4
		label.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
		page.ScrollBarImageColor3 = colors.Accent
		if iconImage then
			iconImage.ImageColor3 = active and colors.Accent or colors.MutedText
			iconImage.ImageTransparency = active and 0 or 0.3
		end
		if iconLabel then
			iconLabel.TextColor3 = active and colors.Accent or colors.MutedText
			iconLabel.TextTransparency = active and 0 or 0.4
		end
	end)

	-- hover effect
	table.insert(window._connections, button.MouseEnter:Connect(function()
		if window._activeTab ~= tab then
			local colors = window:_getColors()
			tween(button, TweenInfo.new(0.1), { BackgroundColor3 = colors.SurfaceAlt })
		end
	end))
	table.insert(window._connections, button.MouseLeave:Connect(function()
		if window._activeTab ~= tab then
			local colors = window:_getColors()
			tween(button, TweenInfo.new(0.1), { BackgroundColor3 = colors.Sidebar })
		end
	end))

	table.insert(window._connections, button.MouseButton1Click:Connect(function()
		window:SelectTab(tab)
	end))

	return tab
end



-- ── Window / SnowyLib ──────────────────────────────────────────────────────
local SnowyLib = {}
SnowyLib.__index = SnowyLib

function SnowyLib:_getColors()
	local base = THEMES[self.ThemeName] or THEMES.Dark
	return {
		Background = self.BackgroundOverride or base.Background,
		Surface = base.Surface,
		SurfaceAlt = base.SurfaceAlt,
		Sidebar = base.Sidebar,
		Text = base.Text,
		MutedText = base.MutedText,
		Stroke = base.Stroke,
		Accent = self.AccentOverride or base.Accent,
	}
end

function SnowyLib:_registerStyler(callback)
	table.insert(self._stylers, callback)
	callback(self:_getColors())
end

function SnowyLib:_refreshTheme()
	local colors = self:_getColors()
	for _, callback in ipairs(self._stylers) do
		callback(colors)
	end
end

function SnowyLib:_updateFloatingState()
	local colors = self:_getColors()
	self._floatingButton.BackgroundTransparency = self.Visible and 0.1 or 0.25
	if self._floatingRedDot then
		self._floatingRedDot.Visible = not self.Visible
	end
end

function SnowyLib:SetTheme(themeName)
	if THEMES[themeName] then
		self.ThemeName = themeName
		self:_refreshTheme()
	end
end

function SnowyLib:SetAccent(color)
	self.AccentOverride = color
	self:_refreshTheme()
end

function SnowyLib:SetBackground(color)
	self.BackgroundOverride = color
	self:_refreshTheme()
end

function SnowyLib:SetToggleKey(keyCode)
	self.ToggleKey = keyCodeFromValue(keyCode, self.ToggleKey)
end

function SnowyLib:SetVisible(state)
	self.Visible = state
	if state then
		self._main.Visible = true
		self._main.Size = UDim2.fromOffset(0, 0)
		tween(self._main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(self._windowSizeX, self._windowSizeY),
		})
	else
		local tw = tween(self._main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(0, 0),
		})
		tw.Completed:Connect(function()
			self._main.Visible = false
			self._main.Size = UDim2.fromOffset(self._windowSizeX, self._windowSizeY)
		end)
	end
	self:_updateFloatingState()
end

function SnowyLib:Toggle()
	self:SetVisible(not self.Visible)
end

function SnowyLib:Notify(config)
	config = config or {}
	local colors = self:_getColors()

	-- Anti-spam: same title+content within 2s → skip
	local now = os.clock()
	local key = (config.Title or "") .. "|" .. (config.Content or "")
	if self._lastNotify and self._lastNotify.key == key and (now - self._lastNotify.time) < 2 then
		return
	end
	self._lastNotify = { key = key, time = now }

	local toast = create("Frame", {
		Name = "Toast",
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		-- start off-screen below for slide-up
		Position = UDim2.new(0, 0, 0, 60),
		BackgroundColor3 = colors.Surface,
		Parent = self._notificationHolder,
	})
	applyCorner(toast, UDim.new(0, 12))
	local toastStroke = applyStroke(toast, 1)
	toastStroke.Color = colors.Stroke

	-- Slide up from bottom
	tween(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
	})

	local content = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = toast,
	})
	applyPadding(content, 12, 40, 10, 10)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = content,
	})

	local titleLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 12),
		Font = Enum.Font.GothamBold,
		Text = string.upper(config.Title or "NOTICE"),
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = colors.Accent,
		Parent = content,
	})

	local body = create("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Font = Enum.Font.GothamMedium,
		Text = config.Content or "",
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = colors.Text,
		Parent = content,
	})

	if config.SubContent and config.SubContent ~= "" then
		create("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			Font = Enum.Font.GothamMedium,
			Text = config.SubContent,
			TextSize = 9,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = colors.MutedText,
			Parent = content,
		})
	end

	local closeBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 8),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		Text = "×",
		TextSize = 14,
		TextColor3 = colors.MutedText,
		Parent = toast,
	})

	local progress = create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = colors.Accent,
		Parent = toast,
	})

	local function dismiss()
		if not toast.Parent then return end
		tween(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0, 0, 0, 60),
		})
		task.delay(0.2, function()
			if toast.Parent then toast:Destroy() end
		end)
	end

	closeBtn.MouseButton1Click:Connect(dismiss)

	local duration = config.Duration and tonumber(config.Duration)
	if duration then
		task.spawn(function()
			tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
			task.wait(duration)
			dismiss()
		end)
	else
		progress.Visible = false
	end
end

function SnowyLib:Dialog(config)
	config = config or {}
	local colors = self:_getColors()
	self._dialogTitle.Text = config.Title or "Dialog"
	self._dialogBody.Text = config.Content or ""

	for _, child in ipairs(self._dialogButtons:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for index, buttonConfig in ipairs(config.Buttons or {}) do
		local button = create("TextButton", {
			Size = UDim2.new(1 / math.max(1, #(config.Buttons or {})), -6, 0, 34),
			BackgroundTransparency = buttonConfig.Primary and 0 or 0.15,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = string.upper(buttonConfig.Title or ("BUTTON " .. index)),
			TextSize = 10,
			Parent = self._dialogButtons,
		})
		applyCorner(button, UDim.new(0, 10))
		local stroke = applyStroke(button, 1)

		if buttonConfig.Primary then
			button.BackgroundColor3 = Color3.new(1, 1, 1)
			button.TextColor3 = colors.Background
			stroke.Color = Color3.new(1, 1, 1)
		else
			button.BackgroundColor3 = colors.SurfaceAlt
			button.TextColor3 = colors.MutedText
			stroke.Color = colors.Stroke
		end

		table.insert(self._connections, button.MouseButton1Click:Connect(function()
			-- Scale out dialog
			tween(self._dialogCard, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.fromOffset(self._dialogCardBaseW * 0.95, 0),
			})
			task.delay(0.12, function()
				self._dialog.Visible = false
				self._dialogCard.Size = UDim2.fromOffset(self._dialogCardBaseW, 0)
			end)
			safeCall(buttonConfig.Callback)
		end))
	end

	-- Scale in dialog
	self._dialogCard.Size = UDim2.fromOffset(self._dialogCardBaseW * 0.95, 0)
	self._dialog.Visible = true
	tween(self._dialogCard, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(self._dialogCardBaseW, 0),
	})
end

function SnowyLib:Destroy()
	for _, connection in ipairs(self._connections) do
		if connection and connection.Disconnect then
			connection:Disconnect()
		end
	end
	self._connections = {}

	if self._screenGui then
		self._screenGui:Destroy()
	end
end

function SnowyLib:SelectTab(tab)
	if self._activeTab == tab then
		return
	end

	-- Fade out current page
	if self._activeTab and self._activeTab._page then
		local prev = self._activeTab._page
		tween(prev, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			GroupTransparency = 1,
		})
		task.delay(0.1, function()
			prev.Visible = false
			prev.GroupTransparency = 0
		end)
	end

	self._activeTab = tab
	self._pageTitle.Text = string.upper(tab._name)
	if self._pageSubtitle then
		local desc = tab._description or ""
		self._pageSubtitle.Text = desc
		self._pageSubtitle.Visible = desc ~= ""
	end

	-- Fade + slide in new page
	tab._page.Position = UDim2.new(0, 12, 0, 0)
	tab._page.GroupTransparency = 1
	tab._page.Visible = true
	tween(tab._page, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 0,
		Position = UDim2.new(0, 0, 0, 0),
	})

	self:_refreshTheme()
end

function SnowyLib:CreateTab(config)
	config = config or {}
	local tab = createTabObject(self, config.Title or config.Name or "Tab", config.Icon)
	tab._description = config.Description or ""
	table.insert(self._tabs, tab)

	if not self._activeTab then
		self:SelectTab(tab)
	end

	return tab
end

-- Tự động build toàn bộ Settings tab với đầy đủ chức năng như web preview
-- Gọi: window:LoadSettings(settingsTab)
function SnowyLib:LoadSettings(tab)
	local appearance = tab:CreateSection("Appearance")

	appearance:CreateDropdown({
		Title = "Theme",
		Description = "Color theme",
		Items = { "Dark", "Midnight", "Amethyst", "Rose", "Aqua", "Emerald", "Darker" },
		Default = self.ThemeName,
		Callback = function(value)
			self.AccentOverride = nil
			self:SetTheme(value)
			self:Notify({ Title = "Theme", Content = value .. " applied", Duration = 3 })
		end,
	})

	local visualStyle = tab:CreateSection("Visual Style")

	visualStyle:CreateButton({
		Title = "Glass Style",
		Description = "Semi-transparent background",
		ButtonText = "APPLY",
		Callback = function()
			self:SetAccent(Color3.fromRGB(120, 190, 255))
			self:Notify({ Title = "Style", Content = "Glass style applied", Duration = 3 })
		end,
	})

	visualStyle:CreateButton({
		Title = "Opaque Style",
		Description = "Restore solid background",
		ButtonText = "RESET",
		Callback = function()
			self:SetAccent(nil)
			self:SetBackground(nil)
			self:Notify({ Title = "Style", Content = "Defaults restored", Duration = 3 })
		end,
	})

	local windowSize = tab:CreateSection("Window Size")

	windowSize:CreateDropdown({
		Title = "Preset",
		Description = "Window size preset",
		Items = { "Auto (660x480)", "Mobile (560x360)", "Desktop (780x520)" },
		Default = "Auto (660x480)",
		Callback = function(value)
			local presets = {
				["Auto (660x480)"] = Vector2.new(660, 480),
				["Mobile (560x360)"] = Vector2.new(560, 360),
				["Desktop (780x520)"] = Vector2.new(780, 520),
			}
			local size = presets[value]
			if size then
				self._main.Size = UDim2.fromOffset(size.X, size.Y)
				self:Notify({ Title = "Window", Content = "Size set to " .. value, Duration = 3 })
			end
		end,
	})

	windowSize:CreateKeybind({
		Title = "Menu Toggle",
		Description = "Menu visibility key",
		Default = self.ToggleKey,
		Callback = function(keyCode)
			self:SetToggleKey(keyCode)
		end,
	})
end

function SnowyLib.CreateWindow(config)
	config = config or {}

	-- Auto-detect device size nếu không truyền config.Size
	local function getAutoSize()
		local vp = workspace.CurrentCamera.ViewportSize
		local w, h = vp.X, vp.Y
		-- Mobile: màn hình nhỏ hoặc portrait
		if w < 600 or h < w then
			return Vector2.new(math.clamp(math.floor(w * 0.92), 300, 520), math.clamp(math.floor(h * 0.72), 340, 420))
		-- Tablet
		elseif w < 1024 then
			return Vector2.new(math.clamp(math.floor(w * 0.75), 520, 680), math.clamp(math.floor(h * 0.65), 400, 480))
		-- Desktop
		else
			return Vector2.new(math.clamp(math.floor(w * 0.5), 620, 780), math.clamp(math.floor(h * 0.6), 440, 540))
		end
	end

	local resolvedSize = config.Size or getAutoSize()

	local self = setmetatable({
		_stylers = {},
		_connections = {},
		_tabs = {},
		_activeTab = nil,
		_options = {},
		_windowSizeX = resolvedSize.X,
		_windowSizeY = resolvedSize.Y,
		ThemeName = config.Theme or "Dark",
		AccentOverride = config.Accent,
		BackgroundOverride = config.Background,
		ToggleKey = keyCodeFromValue(config.ToggleKey, Enum.KeyCode.RightControl),
		Visible = true,
	}, SnowyLib)

	local parent = config.Parent or localPlayer:WaitForChild("PlayerGui")
	local windowSize = resolvedSize

	local screenGui = create("ScreenGui", {
		Name = config.Name or "SnowyLib",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = parent,
	})
	self._screenGui = screenGui

	local floatingButton = create("TextButton", {
		Name = "FloatingButton",
		Position = UDim2.fromOffset(24, 24),
		Size = UDim2.fromOffset(46, 46),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = screenGui,
	})
	applyCorner(floatingButton, UDim.new(0, 12))
	local floatingStroke = applyStroke(floatingButton, 1)

	local floatingImage, floatingText = createIconVisual(floatingButton, config.IconLogo or config.Logo, string.sub(config.Title or "M", 1, 1))
	if floatingImage then
		floatingImage.AnchorPoint = Vector2.new(0.5, 0.5)
		floatingImage.Position = UDim2.fromScale(0.5, 0.5)
		floatingImage.Size = UDim2.fromOffset(26, 26)
	end
	if floatingText then
		floatingText.AnchorPoint = Vector2.new(0.5, 0.5)
		floatingText.Position = UDim2.fromScale(0.5, 0.5)
		floatingText.Size = UDim2.fromScale(1, 1)
		floatingText.Font = Enum.Font.GothamBlack
		floatingText.TextSize = 16
	end

	-- Red dot (visible when minimized)
	local redDot = create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 2, 0, -2),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = Color3.fromRGB(239, 68, 68),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 5,
		Parent = floatingButton,
	})
	applyCorner(redDot, UDim.new(1, 0))

	-- Tooltip "Open Meyy Hub" (visible on hover when minimized)
	local tooltip = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(1, 10, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 26),
		BackgroundColor3 = Color3.fromRGB(8, 8, 10),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 10,
		Parent = floatingButton,
	})
	applyCorner(tooltip, UDim.new(0, 8))
	applyStroke(tooltip, 1)
	applyPadding(tooltip, 10, 10, 0, 0)
	local tooltipLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.GothamBold,
		Text = "Open " .. (config.Title or "Meyy Hub"),
		TextSize = 9,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tooltip,
	})
	local _tooltipLabel = tooltipLabel

	table.insert(self._connections, floatingButton.MouseEnter:Connect(function()
		if not self.Visible then
			tooltip.Visible = true
		end
	end))
	table.insert(self._connections, floatingButton.MouseLeave:Connect(function()
		tooltip.Visible = false
	end))

	self._floatingButton = floatingButton
	self._floatingRedDot = redDot
	self._floatingImage  = floatingImage
	self._floatingText   = floatingText

	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(windowSize.X, windowSize.Y),
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	applyCorner(main, UDim.new(0, 22))
	local mainStroke = applyStroke(main, 1)
	self._main = main

	local SIDEBAR_W = 180
	local HEADER_H  = 64

	local header = create("Frame", {
		Size = UDim2.new(1, 0, 0, HEADER_H),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Parent = main,
	})
	applyCorner(header, UDim.new(0, 22))

	local headerMask = create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 26),
		BorderSizePixel = 0,
		Parent = header,
	})

	local headerDivider = create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		Parent = header,
	})

	-- title + version (left side)
	local titleStack = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -120, 1, 0),
		Parent = header,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = titleStack,
	})

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		Font = Enum.Font.GothamBlack,
		Text = config.Title or config.Name or "MEYY HUB",
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleStack,
	})

	local versionLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "v" .. tostring(config.Version or "1.0.0"),
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleStack,
	})

	local close = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBlack,
		Text = "×",
		TextSize = 16,
		Parent = header,
	})
	applyCorner(close, UDim.new(0, 8))

	local body = create("Frame", {
		Position = UDim2.fromOffset(0, HEADER_H),
		Size = UDim2.new(1, 0, 1, -HEADER_H),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = main,
	})

	local sidebar = create("Frame", {
		Size = UDim2.new(0, SIDEBAR_W, 1, 0),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Parent = body,
	})
	applyPadding(sidebar, 10, 10, 14, 14)
	local sidebarLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = sidebar,
	})
	local _sidebarLayout = sidebarLayout
	self._sidebar = sidebar

	-- sidebar right divider
	local sidebarDivider = create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, SIDEBAR_W, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BorderSizePixel = 0,
		Parent = body,
	})

	local contentWrapper = create("Frame", {
		Position = UDim2.fromOffset(SIDEBAR_W + 1, 0),
		Size = UDim2.new(1, -(SIDEBAR_W + 1), 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = body,
	})

	-- page header area
	local pageHeader = create("Frame", {
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = contentWrapper,
	})
	applyPadding(pageHeader, 20, 20, 0, 0)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 3),
		Parent = pageHeader,
	})

	local pageTitle = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Font = Enum.Font.GothamBlack,
		Text = "MAIN",
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = pageHeader,
	})
	self._pageTitle = pageTitle

	local pageSubtitle = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 11),
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = false,
		Parent = pageHeader,
	})
	self._pageSubtitle = pageSubtitle

	-- page header bottom divider
	local pageHeaderDivider = create("Frame", {
		Position = UDim2.fromOffset(0, 58),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		Parent = contentWrapper,
	})

	local content = create("Frame", {
		Position = UDim2.fromOffset(0, 59),
		Size = UDim2.new(1, 0, 1, -59),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = contentWrapper,
	})
	self._content = content

	local notificationHolder = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Size = UDim2.new(0, 320, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	local notificationLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = notificationHolder,
	})
	local _notificationLayout = notificationLayout
	self._notificationHolder = notificationHolder

	local dialog = create("Frame", {
		Visible = false,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	self._dialog = dialog

	local dialogCard = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(320, 0),
		BorderSizePixel = 0,
		Parent = dialog,
	})
	applyCorner(dialogCard, UDim.new(0, 16))
	self._dialogCard = dialogCard
	self._dialogCardBaseW = 320
	local dialogStroke = applyStroke(dialogCard, 1)
	applyPadding(dialogCard, 16, 16, 16, 16)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = dialogCard,
	})

	local dialogTitle = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Font = Enum.Font.GothamBlack,
		Text = "DIALOG",
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = dialogCard,
	})
	self._dialogTitle = dialogTitle

	local dialogBody = create("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextSize = 10,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = dialogCard,
	})
	self._dialogBody = dialogBody

	local dialogButtons = create("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = dialogCard,
	})
	local buttonsLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = dialogButtons,
	})
	local _buttonsLayout = buttonsLayout
	self._dialogButtons = dialogButtons

	self:_registerStyler(function(colors)
		screenGui.DisplayOrder = config.DisplayOrder or 20
		main.BackgroundColor3 = colors.Background
		mainStroke.Color = colors.Stroke
		header.BackgroundColor3 = colors.Surface
		headerMask.BackgroundColor3 = colors.Surface
		headerDivider.BackgroundColor3 = colors.Stroke
		title.TextColor3 = colors.Text
		versionLabel.TextColor3 = colors.MutedText
		close.BackgroundColor3 = colors.SurfaceAlt
		close.TextColor3 = colors.MutedText
		sidebar.BackgroundColor3 = colors.Sidebar
		sidebarDivider.BackgroundColor3 = colors.Stroke
		pageHeaderDivider.BackgroundColor3 = colors.Stroke
		pageTitle.TextColor3 = colors.Accent
		pageSubtitle.TextColor3 = colors.MutedText
		dialog.BackgroundColor3 = Color3.new(0, 0, 0)
		dialogCard.BackgroundColor3 = colors.Surface
		dialogStroke.Color = colors.Stroke
		dialogTitle.TextColor3 = colors.Text
		dialogBody.TextColor3 = colors.MutedText
		floatingStroke.Color = colors.Accent
		if floatingImage then floatingImage.ImageColor3 = colors.Accent end
		if floatingText then floatingText.TextColor3 = colors.Accent end
	end)

	makeDraggable(self, header, main)
	makeDraggable(self, floatingButton, floatingButton)

	table.insert(self._connections, close.MouseButton1Click:Connect(function()
		self:Dialog({
			Title = "Are you sure?",
			Content = "Are you sure you want to close the UI?",
			Buttons = {
				{
					Title = "Close UI",
					Primary = true,
					Callback = function()
						self:SetVisible(false)
					end,
				},
				{
					Title = "Cancel",
					Callback = function() end,
				},
			},
		})
	end))

	table.insert(self._connections, floatingButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end))

	table.insert(self._connections, UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
		if gameProcessed then
			return
		end

		if inputObject.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end))

	self:_updateFloatingState()

	-- Floating button intro animation
	floatingButton.BackgroundTransparency = 1
	tween(floatingButton, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.15,
	})

	-- Red dot pulse loop
	task.spawn(function()
		while floatingButton.Parent do
			if self._floatingRedDot and self._floatingRedDot.Visible then
				tween(self._floatingRedDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					BackgroundTransparency = 0.5,
				})
				task.wait(0.6)
				tween(self._floatingRedDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					BackgroundTransparency = 0,
				})
				task.wait(0.6)
			else
				task.wait(0.5)
			end
		end
	end)

	-- Window border glow pulse loop
	task.spawn(function()
		while main.Parent do
			tween(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Transparency = 0.5,
			})
			task.wait(2)
			tween(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Transparency = 0,
			})
			task.wait(2)
		end
	end)

	-- Options proxy: Options.MyKey.Value / Options.MyKey:SetValue(...)
	self.Options = setmetatable({}, {
		__index = function(_, key)
			return self._options[key]
		end,
	})

	return self
end


return SnowyLib
