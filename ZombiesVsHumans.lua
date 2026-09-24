--[[
	警告：此脚本未经 ScriptBlox 验证。使用风险自负！
	UI：固定居中 · 纯淡入淡出 · 无文字灵动岛 · DeepSeek 配色 · 图片背景水印
	最终优化版
]]
getgenv().deletewhendupefound = true

-- ============================================================
-- UI 库
-- ============================================================
local lib = (function()
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")

	local C = {
		Bg         = Color3.fromRGB(26, 29, 38),
		BgDeep     = Color3.fromRGB(18, 20, 28),
		Element    = Color3.fromRGB(37, 41, 54),
		ElementHov = Color3.fromRGB(48, 53, 68),
		Accent     = Color3.fromRGB(77, 107, 254),
		Accent2    = Color3.fromRGB(100, 180, 255),
		Text       = Color3.fromRGB(236, 240, 248),
		TextDim    = Color3.fromRGB(138, 148, 168),
		TextMute   = Color3.fromRGB(94, 102, 122),
		Track      = Color3.fromRGB(45, 50, 65),
		Stroke     = Color3.fromRGB(48, 53, 68),
		StrokeHov  = Color3.fromRGB(77, 107, 254),
	}

	local EASE, DIR = Enum.EasingStyle, Enum.EasingDirection
	local function tw(obj, t, props, s, d)
		local a = TweenService:Create(obj,
			TweenInfo.new(t or 0.22, s or EASE.Quart, d or DIR.Out), props)
		a:Play(); return a
	end
	local function new(cls, props)
		local i = Instance.new(cls)
		for k, v in pairs(props or {}) do i[k] = v end
		return i
	end
	local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = p }) end
	local function stroke(p, c, t) return new("UIStroke", { Color = c or C.Stroke, Thickness = t or 1, Parent = p }) end
	local function grad(p, c1, c2, rot)
		return new("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rot or 0, Parent = p })
	end

	-- 通用 hover 效果
	local function hoverFx(trigger, holder, st, isActive)
		trigger.MouseEnter:Connect(function()
			if isActive and isActive() then return end
			tw(holder, 0.22, { BackgroundColor3 = C.ElementHov })
			tw(st, 0.22, { Color = C.StrokeHov })
		end)
		trigger.MouseLeave:Connect(function()
			if isActive and isActive() then return end
			tw(holder, 0.22, { BackgroundColor3 = C.Element })
			tw(st, 0.22, { Color = C.Stroke })
		end)
	end

	local lib = {}
	local gui = new("ScreenGui", {
		Name = "ZVH_UI", ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true, DisplayOrder = 100,
		Parent = (gethui and gethui()) or game:GetService("CoreGui"),
	})

	local WIN_W, WIN_H = 600, 400
	local FULL_SIZE = UDim2.new(0, WIN_W, 0, WIN_H)

	local shadow = new("Frame", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 8),
		Size = UDim2.new(0, WIN_W + 12, 0, WIN_H + 12),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 0,
		Parent = gui,
	})
	corner(shadow, 18)

	local main = new("CanvasGroup", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = FULL_SIZE, BackgroundColor3 = C.Bg,
		BorderSizePixel = 0, ClipsDescendants = true,
		GroupTransparency = 1, Parent = gui,
	})
	corner(main, 14)
	stroke(main, C.Stroke, 1.4)

	local topGlow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = C.Accent, BorderSizePixel = 0, ZIndex = 5,
		Parent = main,
	})
	grad(topGlow, C.Accent, C.Accent2, 0)

	local ambientGlow = new("Frame", {
		Size = UDim2.new(0, 280, 0, 280),
		Position = UDim2.new(0, -140, 0, -200),
		BackgroundColor3 = C.Accent, BackgroundTransparency = 0.9,
		BorderSizePixel = 0, ZIndex = 1, Parent = main,
	})
	corner(ambientGlow, 999)

	-- 背景 logo
	local LOGO_URL = "https://mdn.alipayobjects.com/afts/img/A*sRVAS7lcD0UAAAAAX9AAAAgAegAAAQ/original?bz=APM_20002117"
	local LOGO_FILE = "zvh_bg_logo2.png"
	local logoAsset = nil
	pcall(function()
		if getcustomasset then
			if isfile and not isfile(LOGO_FILE) then
				writefile(LOGO_FILE, game:HttpGet(LOGO_URL))
			end
			logoAsset = getcustomasset(LOGO_FILE)
		elseif getsynasset then
			if isfile and not isfile(LOGO_FILE) then
				writefile(LOGO_FILE, game:HttpGet(LOGO_URL))
			end
			logoAsset = getsynasset(LOGO_FILE)
		else
			logoAsset = LOGO_URL
		end
	end)

	local bgLogo = new("ImageLabel", {
		Name = "BgLogo",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 380, 0, 380),
		BackgroundTransparency = 1,
		Image = logoAsset or LOGO_URL,
		ImageTransparency = 0.92,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 2, Parent = main,
	})
	task.spawn(function()
		while bgLogo.Parent do
			tw(bgLogo, 3.2, { ImageTransparency = 0.88 }, EASE.Sine, DIR.InOut)
			task.wait(3.2)
			if not bgLogo.Parent then break end
			tw(bgLogo, 3.2, { ImageTransparency = 0.94 }, EASE.Sine, DIR.InOut)
			task.wait(3.2)
		end
	end)

	-- 顶栏
	local topbar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1, ZIndex = 10, Parent = main,
	})

	local logoDot = new("Frame", {
		Size = UDim2.new(0, 10, 0, 10),
		Position = UDim2.new(0, 18, 0.5, -5),
		BackgroundColor3 = C.Accent, BorderSizePixel = 0, ZIndex = 11,
		Parent = topbar,
	})
	corner(logoDot, 5)
	stroke(logoDot, C.Accent2, 1)

	task.spawn(function()
		while logoDot.Parent do
			tw(logoDot, 1.6, { BackgroundColor3 = C.Accent2 }, EASE.Sine, DIR.InOut)
			task.wait(1.6)
			if not logoDot.Parent then break end
			tw(logoDot, 1.6, { BackgroundColor3 = C.Accent }, EASE.Sine, DIR.InOut)
			task.wait(1.6)
		end
	end)

	local titleLbl = new("TextLabel", {
		Size = UDim2.new(1, -140, 1, 0), Position = UDim2.new(0, 36, 0, 0),
		BackgroundTransparency = 1, Text = "Zombies Vs Humans (Deepseek)",
		Font = Enum.Font.GothamBold, TextSize = 14,
		TextColor3 = C.Text, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 11, Parent = topbar,
	})

	local function makeTopBtn(text, xOff, hoverColor)
		local b = new("TextButton", {
			Size = UDim2.new(0, 28, 0, 28),
			Position = UDim2.new(1, xOff, 0.5, -14),
			BackgroundColor3 = C.Element, BorderSizePixel = 0,
			Text = text, Font = Enum.Font.GothamBold,
			TextSize = 15, TextColor3 = C.TextDim,
			AutoButtonColor = false, ZIndex = 11, Parent = topbar,
		})
		corner(b, 7)
		local st = stroke(b, C.Stroke, 1)
		b.MouseEnter:Connect(function()
			tw(b, 0.2, { BackgroundColor3 = C.ElementHov, TextColor3 = hoverColor or C.Text })
			tw(st, 0.2, { Color = hoverColor or C.StrokeHov })
		end)
		b.MouseLeave:Connect(function()
			tw(b, 0.2, { BackgroundColor3 = C.Element, TextColor3 = C.TextDim })
			tw(st, 0.2, { Color = C.Stroke })
		end)
		return b
	end
	local minBtn   = makeTopBtn("–", -68)
	local closeBtn = makeTopBtn("×", -34, Color3.fromRGB(255, 106, 106))

	local sidebar = new("Frame", {
		Size = UDim2.new(0, 150, 1, -56),
		Position = UDim2.new(0, 10, 0, 48),
		BackgroundTransparency = 1, ZIndex = 5, Parent = main,
	})
	local sidebarScroll = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 2,
		ScrollBarImageColor3 = C.Accent, ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = sidebar,
	})
	new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sidebarScroll })
	new("UIPadding", { PaddingRight = UDim.new(0, 4), Parent = sidebarScroll })

	local sep = new("Frame", {
		Size = UDim2.new(0, 1, 1, -66),
		Position = UDim2.new(0, 166, 0, 56),
		BackgroundColor3 = C.Stroke, BackgroundTransparency = 0.3,
		BorderSizePixel = 0, ZIndex = 4, Parent = main,
	})
	grad(sep, C.Stroke, C.Bg, 90)

	local content = new("Frame", {
		Size = UDim2.new(1, -190, 1, -56),
		Position = UDim2.new(0, 178, 0, 48),
		BackgroundTransparency = 1, ZIndex = 5, Parent = main,
	})

	tw(main, 0.45, { GroupTransparency = 0 }, EASE.Quart, DIR.Out)
	tw(shadow, 0.45, { BackgroundTransparency = 0.75 }, EASE.Quart, DIR.Out)

	-- 灵动岛
	local ISLAND_W, ISLAND_H = 132, 36
	local ISLAND_POS = UDim2.new(0.5, 0, 0, 14)

	local islandShadow = new("Frame", {
		Name = "IslandShadow",
		AnchorPoint = Vector2.new(0.5, 0), Position = ISLAND_POS,
		Size = UDim2.new(0, ISLAND_W + 8, 0, ISLAND_H + 8),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Visible = false, ZIndex = 19, Parent = gui,
	})
	corner(islandShadow, (ISLAND_H + 8) / 2)

	local island = new("Frame", {
		Name = "DynamicIsland",
		AnchorPoint = Vector2.new(0.5, 0), Position = ISLAND_POS,
		Size = UDim2.new(0, 0, 0, ISLAND_H),
		BackgroundColor3 = C.Bg, BorderSizePixel = 0,
		ClipsDescendants = true, Visible = false,
		ZIndex = 21, Parent = gui,
	})
	corner(island, ISLAND_H / 2)
	stroke(island, C.Stroke, 1.3)

	local islandDot = new("Frame", {
		Size = UDim2.new(0, 8, 0, 8),
		Position = UDim2.new(0, 12, 0.5, -4),
		BackgroundColor3 = C.Accent, BorderSizePixel = 0, Parent = island,
	})
	corner(islandDot, 4)

	local islandBtn = new("TextButton", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Parent = island,
	})

	task.spawn(function()
		while islandDot.Parent do
			tw(islandDot, 1.1, { BackgroundColor3 = C.Accent2 }, EASE.Sine, DIR.InOut)
			task.wait(1.1)
			if not islandDot.Parent then break end
			tw(islandDot, 1.1, { BackgroundColor3 = C.Accent }, EASE.Sine, DIR.InOut)
			task.wait(1.1)
		end
	end)

	local busy, minimized = false, false

	local function minimize()
		if minimized or busy then return end
		busy, minimized = true, true
		tw(main, 0.22, { GroupTransparency = 1 }, EASE.Quart, DIR.In)
		tw(shadow, 0.22, { BackgroundTransparency = 1 }, EASE.Quart, DIR.In)
		task.delay(0.22, function()
			if not gui.Parent then busy = false; return end
			main.Visible, shadow.Visible = false, false
			island.Visible, islandShadow.Visible = true, true
			island.Size = UDim2.new(0, 0, 0, ISLAND_H)
			islandShadow.Size = UDim2.new(0, 0, 0, ISLAND_H + 8)
			islandShadow.BackgroundTransparency = 1
			tw(island, 0.42, { Size = UDim2.new(0, ISLAND_W, 0, ISLAND_H) }, EASE.Back, DIR.Out)
			tw(islandShadow, 0.42, {
				Size = UDim2.new(0, ISLAND_W + 8, 0, ISLAND_H + 8),
				BackgroundTransparency = 0.72,
			}, EASE.Quart, DIR.Out)
			task.delay(0.44, function() busy = false end)
		end)
	end

	local function restore()
		if not minimized or busy then return end
		busy, minimized = true, false
		tw(island, 0.26, { Size = UDim2.new(0, 0, 0, ISLAND_H) }, EASE.Quart, DIR.In)
		tw(islandShadow, 0.26, {
			Size = UDim2.new(0, 0, 0, ISLAND_H + 8),
			BackgroundTransparency = 1,
		}, EASE.Quart, DIR.In)
		task.delay(0.26, function()
			if not gui.Parent then busy = false; return end
			island.Visible, islandShadow.Visible = false, false
			main.Visible, shadow.Visible = true, true
			main.GroupTransparency, shadow.BackgroundTransparency = 1, 1
			tw(main, 0.32, { GroupTransparency = 0 }, EASE.Quart, DIR.Out)
			tw(shadow, 0.32, { BackgroundTransparency = 0.75 }, EASE.Quart, DIR.Out)
			task.delay(0.32, function() busy = false end)
		end)
	end

	minBtn.MouseButton1Click:Connect(function()
		if minimized then restore() else minimize() end
	end)
	islandBtn.MouseButton1Click:Connect(restore)
	islandBtn.MouseEnter:Connect(function()
		if minimized then
			tw(island, 0.25, { Size = UDim2.new(0, ISLAND_W + 18, 0, ISLAND_H) }, EASE.Back, DIR.Out)
		end
	end)
	islandBtn.MouseLeave:Connect(function()
		if minimized then
			tw(island, 0.25, { Size = UDim2.new(0, ISLAND_W, 0, ISLAND_H) }, EASE.Quart, DIR.Out)
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		tw(main, 0.25, { GroupTransparency = 1 }, EASE.Quart, DIR.In)
		tw(shadow, 0.25, { BackgroundTransparency = 1 }, EASE.Quart, DIR.In)
		task.wait(0.26)
		if lib.ondestroyedfunc then pcall(lib.ondestroyedfunc) end
		gui:Destroy()
	end)

	-- =====================================================
	-- API
	-- =====================================================
	local activeTab, firstTabSet = nil, false
	function lib.makelib(name) if name then titleLbl.Text = name end end

	function lib.maketab(name)
		local tab = {}
		local btn = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = C.Element, BackgroundTransparency = 1,
			BorderSizePixel = 0, Text = "     " .. name,
			Font = Enum.Font.GothamMedium, TextSize = 12,
			TextColor3 = C.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = sidebarScroll,
		})
		corner(btn, 8)
		local indicator = new("Frame", {
			Size = UDim2.new(0, 3, 0, 0),
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = C.Accent, BorderSizePixel = 0, Parent = btn,
		})
		corner(indicator, 2)

		local frame = new("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
			BorderSizePixel = 0, ScrollBarThickness = 2,
			ScrollBarImageColor3 = C.Accent, ScrollBarImageTransparency = 0.5,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false, Parent = content,
		})
		new("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame })
		new("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8), Parent = frame })

		tab.button, tab.frame = btn, frame

		local function activate()
			if activeTab == tab then return end
			if activeTab then
				tw(activeTab.button, 0.22, { BackgroundTransparency = 1, TextColor3 = C.TextDim })
				tw(activeTab.button:FindFirstChildOfClass("Frame"), 0.22, { Size = UDim2.new(0, 3, 0, 0) }, EASE.Quart, DIR.In)
				activeTab.frame.Visible = false
			end
			activeTab = tab
			tw(btn, 0.25, { BackgroundTransparency = 0, TextColor3 = C.Text })
			tw(indicator, 0.4, { Size = UDim2.new(0, 3, 0, 20) }, EASE.Back, DIR.Out)
			frame.Visible = true
			local idx = 0
			for _, el in ipairs(frame:GetChildren()) do
				if el:GetAttribute("UIElement") then
					idx = idx + 1
					local d = idx * 0.025
					el.BackgroundTransparency = 1
					task.delay(d, function()
						if el and el.Parent then
							tw(el, 0.32, { BackgroundTransparency = 0 }, EASE.Quart, DIR.Out)
						end
					end)
				end
			end
		end

		btn.MouseButton1Click:Connect(activate)
		btn.MouseEnter:Connect(function()
			if activeTab ~= tab then
				tw(btn, 0.2, { BackgroundTransparency = 0.35, TextColor3 = C.Text })
				tw(indicator, 0.25, { Size = UDim2.new(0, 3, 0, 10) }, EASE.Back, DIR.Out)
			end
		end)
		btn.MouseLeave:Connect(function()
			if activeTab ~= tab then
				tw(btn, 0.2, { BackgroundTransparency = 1, TextColor3 = C.TextDim })
				tw(indicator, 0.2, { Size = UDim2.new(0, 3, 0, 0) })
			end
		end)

		if not firstTabSet then
			firstTabSet = true
			task.defer(activate)
		end
		return tab
	end

	local function element(tab, h)
		local el = new("Frame", {
			Size = UDim2.new(1, 0, 0, h),
			BackgroundColor3 = C.Element, BorderSizePixel = 0, Parent = tab.frame,
		})
		el:SetAttribute("UIElement", true)
		corner(el, 9)
		return el, stroke(el, C.Stroke, 1)
	end

	function lib.makelabel(text, tab)
		local holder = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Parent = tab.frame,
		})
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3),
			Parent = holder,
		})
		return new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Text = text,
			Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
			Parent = holder,
		})
	end

	function lib.maketoggle(text, tab, callback)
		local holder, st = element(tab, 38)
		new("TextLabel", {
			Size = UDim2.new(1, -66, 1, 0), Position = UDim2.new(0, 14, 0, 0),
			BackgroundTransparency = 1, Text = text,
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = holder,
		})
		local track = new("Frame", {
			Size = UDim2.new(0, 40, 0, 22),
			Position = UDim2.new(1, -54, 0.5, -11),
			BackgroundColor3 = C.Track, BorderSizePixel = 0, Parent = holder,
		})
		corner(track, 11)
		local knob = new("Frame", {
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0, 2, 0.5, -9),
			BackgroundColor3 = C.Text, BorderSizePixel = 0, Parent = track,
		})
		corner(knob, 9)
		local btn = new("TextButton", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
			Text = "", AutoButtonColor = false, Parent = holder,
		})

		local state = false
		local function setState(v, fire)
			state = v
			if state then
				tw(track, 0.25, { BackgroundColor3 = C.Accent })
				tw(knob, 0.42, { Position = UDim2.new(1, -20, 0.5, -9) }, EASE.Back, DIR.Out)
			else
				tw(track, 0.25, { BackgroundColor3 = C.Track })
				tw(knob, 0.35, { Position = UDim2.new(0, 2, 0.5, -9) })
			end
			if fire and callback then task.spawn(callback, state) end
		end

		btn.MouseButton1Click:Connect(function() setState(not state, true) end)
		hoverFx(btn, holder, st)
		return { Set = setState, Get = function() return state end }
	end

	function lib.makeslider(text, tab, min, max, callback)
		local holder, st = element(tab, 56)
		new("TextLabel", {
			Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 14, 0, 7),
			BackgroundTransparency = 1, Text = text,
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = holder,
		})
		local valueLabel = new("TextLabel", {
			Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -74, 0, 7),
			BackgroundTransparency = 1, Text = tostring(min),
			Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.Accent,
			TextXAlignment = Enum.TextXAlignment.Right, Parent = holder,
		})
		local track = new("Frame", {
			Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 40),
			BackgroundColor3 = C.Track, BorderSizePixel = 0, Parent = holder,
		})
		corner(track, 3)
		local fill = new("Frame", {
			Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.Accent,
			BorderSizePixel = 0, Parent = track,
		})
		corner(fill, 3)
		grad(fill, C.Accent, C.Accent2, 0)
		local knob = new("Frame", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 0, 0.5, -8),
			BackgroundColor3 = C.Text, BorderSizePixel = 0, ZIndex = 3, Parent = track,
		})
		corner(knob, 8)

		local value = min
		local function setValue(v, fire)
			v = math.clamp(v, min, max)
			value = v
			local p = (max == min) and 0 or (v - min) / (max - min)
			fill.Size = UDim2.new(p, 0, 1, 0)
			knob.Position = UDim2.new(p, -16 * p, 0.5, -8)
			local shown = math.floor(v + 0.5)
			valueLabel.Text = tostring(shown)
			if fire and callback then task.spawn(callback, shown) end
		end

		local drag = false
		local hitbox = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 26),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1, Text = "",
			AutoButtonColor = false, Parent = holder,
		})
		local function update()
			local mx = UserInputService:GetMouseLocation().X
			local tx, tw2 = track.AbsolutePosition.X, track.AbsoluteSize.X
			if tw2 <= 0 then return end
			local p = math.clamp((mx - tx) / tw2, 0, 1)
			setValue(min + p * (max - min), true)
		end
		hitbox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
				drag = true
				tw(knob, 0.2, { Size = UDim2.new(0, 20, 0, 20) }, EASE.Back, DIR.Out)
				update()
			end
		end)
		local function release()
			if drag then
				drag = false
				local p = (max == min) and 0 or (value - min) / (max - min)
				tw(knob, 0.3, {
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(p, -16 * p, 0.5, -8),
				}, EASE.Back, DIR.Out)
			end
		end
		hitbox.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then release() end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if drag and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then update() end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then release() end
		end)
		hoverFx(hitbox, holder, st)
		setValue(min, false)
		return { Set = setValue, Get = function() return value end }
	end

	function lib.maketextbox(text, tab, callback)
		local holder = element(tab, 38)
		new("TextLabel", {
			Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 14, 0, 0),
			BackgroundTransparency = 1, Text = text,
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = holder,
		})
		local box = new("TextBox", {
			Size = UDim2.new(0.45, -14, 0, 24),
			Position = UDim2.new(0.55, 0, 0.5, -12),
			BackgroundColor3 = C.BgDeep, BorderSizePixel = 0, Text = "",
			PlaceholderText = "输入...", Font = Enum.Font.Gotham,
			TextSize = 11, TextColor3 = C.Text, PlaceholderColor3 = C.TextMute,
			ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Center,
			Parent = holder,
		})
		corner(box, 6)
		local boxStroke = stroke(box, C.Stroke, 1)
		box.Focused:Connect(function()
			tw(box, 0.2, { BackgroundColor3 = C.ElementHov })
			tw(boxStroke, 0.2, { Color = C.Accent })
		end)
		box.FocusLost:Connect(function()
			tw(box, 0.2, { BackgroundColor3 = C.BgDeep })
			tw(boxStroke, 0.2, { Color = C.Stroke })
			if callback then task.spawn(callback, box.Text) end
		end)
	end

	function lib.makebutton(text, tab, callback)
		local btn = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = C.Element, BorderSizePixel = 0,
			Text = text, Font = Enum.Font.GothamMedium,
			TextSize = 12, TextColor3 = C.Text,
			AutoButtonColor = false, Parent = tab.frame,
		})
		btn:SetAttribute("UIElement", true)
		corner(btn, 9)
		local st = stroke(btn, C.Stroke, 1)
		btn.MouseButton1Down:Connect(function()
			tw(btn, 0.1, { Size = UDim2.new(1, -6, 0, 30), BackgroundColor3 = C.Accent })
			tw(st, 0.1, { Color = C.Accent2 })
		end)
		btn.MouseButton1Up:Connect(function()
			tw(btn, 0.38, { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.ElementHov }, EASE.Back, DIR.Out)
			tw(st, 0.3, { Color = C.StrokeHov })
		end)
		btn.MouseButton1Click:Connect(function()
			if callback then task.spawn(callback) end
		end)
		hoverFx(btn, btn, st)
	end

	return lib
end)()

-- ============================================================
-- 脚本逻辑
-- ============================================================
lib.makelib("Zombies Vs Humans (Deepseek)")
local main = lib.maketab("主要")
local movement = lib.maketab("移动")
local esp = lib.maketab("透视")
local anti = lib.maketab("反制")
local hw = lib.maketab("人类焊接")
local oscr = lib.maketab("其他脚本")

local localplr = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local on = true
local toc = {}
local CurrentWeld = nil

lib.makelabel("\u{26A0}\u{FE0F} 警告：所有这些功能都可能导致你被封禁！此游戏在 Discord 上有举报系统，如果你有大量进度，请勿作弊！", main)
local currposl = lib.makelabel("当前位置：", main)
local cfrcheckl = lib.makelabel("死亡幅度（达到 0 = 反作弊死亡）：", main)

local ha = false
lib.maketoggle("攻击光环", main, function(bool) ha = bool end)

local bha = false
local bhas = 20
local newprt = Instance.new("Part")
newprt.Size = Vector3.new(bhas * 2, bhas * 2, bhas * 2)
newprt.Anchored = true
newprt.Transparency = 1
newprt.CanCollide = false
newprt.Shape = Enum.PartType.Ball
newprt.Parent = workspace

lib.maketoggle("方块攻击光环（掘墓人）", main, function(bool)
	bha = bool
	newprt.Transparency = bha and 0.8 or 1
end)
lib.makeslider("方块攻击光环范围", main, 0, 20, function(n)
	bhas = n
	newprt.Size = Vector3.new(n * 2, n * 2, n * 2)
end)

local gha = false
lib.maketoggle("充能攻击光环（角斗士）（已失效）", main, function(bool) gha = bool end)

local comb = 0
function addcomb()
	comb = comb + 1
	if comb > 3 then comb = 1 end
end

function getmelee()
	local sword = nil
	local back = localplr.Backpack and localplr.Backpack:GetChildren() or {}
	for i = 1, #back do
		local v = back[i]
		if v:IsA("Tool") and (string.find(v.Name, "Sword") or string.find(v.Name:lower(), "axe")
			or string.find(v.Name, "Dagger") or string.find(v.Name, "Hammer") or v.Name == "Trident") then
			sword = v
			v.Parent = localplr.Character
		end
	end
	if not sword and localplr.Character then
		local ch = localplr.Character:GetChildren()
		for i = 1, #ch do
			local v = ch[i]
			if v:IsA("Tool") and (string.find(v.Name, "Sword") or string.find(v.Name:lower(), "axe")
				or string.find(v.Name, "Dagger") or string.find(v.Name, "Hammer") or v.Name == "Trident") then
				sword = v
			end
		end
	end
	return sword
end

local swordcooldowns = {
	WoodenSword = 0.35, Trident = 0.85, StoneSword = 0.425,
	GravediggersPickaxe = 2.2, ObsidianHammer = 1.4, IronSword = 0.525,
	GladiatorsSword = 2, FlintDagger = 0.2, EmeraldAxe = 1.5, DiamondSword = 0.8,
}
local partdelays = {}
function adelay(part, checksword)
	partdelays[part] = true
	if typeof(checksword) == "Instance" then
		checksword = swordcooldowns[checksword.Name] and swordcooldowns[checksword.Name] / 9
	end
	task.delay((typeof(checksword) == "Number" and checksword) or 0.1, function()
		partdelays[part] = nil
	end)
end
function checkdelay(part) return partdelays[part] == nil end

local ii = game.ReplicatedStorage.Remotes.ItemInteract
local proj = workspace.Projectiles
local graves = workspace.Graves
local blocks = workspace.Blocks
local supportsgpip = workspace.GetPartsInPart ~= nil
local speed, speedEnabled, speedLabel, savedWalkSpeed, nofog = nil, false, nil, nil, false

local ors = game:GetService("RunService").RenderStepped:Connect(function()
	debug.profilebegin("ZVHRenderStepped")

	if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
		local pos = localplr.Character.HumanoidRootPart.Position
		pos = Vector3.new(math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
		currposl.Text = "当前位置：" .. tostring(pos)
		local v1 = 750 - math.abs(pos.X)
		local v2 = 800 - math.abs(pos.Y)
		local v3 = 900 - math.abs(pos.Z)
		cfrcheckl.Text = "死亡幅度：" .. tostring(math.min(v1, v2, v3)) .. " | " .. v1 .. ", " .. v2 .. ", " .. v3
	end

	if localplr.Character then
		local hum = localplr.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			if speedEnabled and speed then hum.WalkSpeed = speed end
			if speedLabel then
				speedLabel.Text = "当前移速：" .. tostring(math.floor(hum.WalkSpeed + 0.5))
			end
		end
	end

	if nofog and game.Lighting:FindFirstChild("Atmosphere") then
		game.Lighting.Atmosphere.Density = 0
	end

	if ha or bha then
		local sword = getmelee()
		local myHRP = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
		if myHRP then
			if ha and sword and (not gha or sword.Name ~= "GladiatorsSword") then
				for _, v in pairs(game.Players:GetPlayers()) do
					if v ~= localplr and v.Team ~= localplr.Team then
						local c = v.Character
						local hrp = c and c:FindFirstChild("HumanoidRootPart")
						local hum = c and c:FindFirstChildOfClass("Humanoid")
						if c and hrp and hum and hum.Health > 0
							and checkdelay(c)
							and (hrp.Position - myHRP.Position).Magnitude < 20 then
							adelay(c, sword)
							coroutine.wrap(function()
								addcomb()
								pcall(function() ii:InvokeServer(sword, "Hit", c, comb) end)
							end)()
							task.wait()
						end
					end
				end
			end
			if ha and sword then
				for _, v in pairs(proj:GetChildren()) do
					if v:IsA("BasePart") and checkdelay(v) and v.Name == "Cannonball"
						and (v.Position - myHRP.Position).Magnitude < 40 then
						adelay(v, 0.05)
						coroutine.wrap(function()
							addcomb()
							pcall(function() ii:InvokeServer(sword, "ProjectileHit", v, comb) end)
						end)()
					end
				end
				for _, v in pairs(graves:GetChildren()) do
					local pos
					if v:IsA("BasePart") then pos = v.CFrame.Position
					elseif v:IsA("Model") then pos = v:GetPivot().Position end
					if pos and checkdelay(v) and (pos - myHRP.Position).Magnitude < 20 then
						adelay(v, sword)
						coroutine.wrap(function()
							addcomb()
							pcall(function() ii:InvokeServer(sword, "GraveHit", v, comb) end)
						end)()
					end
				end
			end

			if bha and sword and sword.Name == "GravediggersPickaxe" then
				if supportsgpip then
					newprt.CFrame = myHRP.CFrame
					for _, v in pairs(workspace:GetPartsInPart(newprt)) do
						if v:IsDescendantOf(blocks) and v:IsA("BasePart") and checkdelay(v) then
							adelay(v, 0.5)
							local target = v.Name == "Root" and v.Parent or v
							coroutine.wrap(function()
								addcomb()
								pcall(function() ii:InvokeServer(sword, "BlockHit", target, comb) end)
							end)()
						end
					end
				else
					for _, v in pairs(blocks:GetChildren()) do
						if v:IsA("BasePart") and checkdelay(v)
							and (v.Position - myHRP.Position).Magnitude < bhas then
							adelay(v, 0.5)
							addcomb()
							coroutine.wrap(function()
								pcall(function() ii:InvokeServer(sword, "BlockHit", v, comb) end)
							end)()
						end
					end
				end
			end
		end
	end

	debug.profileend()
end)

-- ---------- 反制 ----------
local antij, oldfunc1 = false, nil
lib.maketoggle("防跳跃疲劳", anti, function(bool)
	antij = bool
	local ok, r = pcall(require, localplr.PlayerScripts.Client.Character.JumpFatigue)
	if not ok or not r then return end
	if antij then
		if not oldfunc1 then oldfunc1 = r.GetCanFatigue end
		r.GetCanFatigue = function() end
	elseif oldfunc1 then
		r.GetCanFatigue = oldfunc1
	end
end)

local antiwh, oldfunc2 = false, nil
lib.maketoggle("防反墙壁跳", anti, function(bool)
	antiwh = bool
	local ok, r = pcall(require, localplr.PlayerScripts.Client.Game.NoWallhop)
	if not ok or not r then return end
	if antiwh then
		if not oldfunc2 then oldfunc2 = r.GetIsOnGround end
		r.GetIsOnGround = function() return true end
	elseif oldfunc2 then
		r.GetIsOnGround = oldfunc2
	end
end)

local deathreq = game.ReplicatedStorage.Remotes:WaitForChild("RequestThyDeath")
local antifm = false
lib.maketoggle("防反飞行机器", anti, function(bool)
	antifm = bool
	deathreq.Parent = antifm and workspace or game.ReplicatedStorage.Remotes
end)

local antifd, oldfunc3 = false, nil
lib.maketoggle("防摔落伤害", anti, function(bool)
	antifd = bool
	local ok, r = pcall(require, localplr.PlayerScripts.Client.Game.FallDamage)
	if not ok or not r then return end
	if antifd then
		if not oldfunc3 then oldfunc3 = r.GetFallDamage end
		r.GetFallDamage = function() return 0 end
	elseif oldfunc3 then
		r.GetFallDamage = oldfunc3
	end
end)

local antird, oldfunc4, oldfunc5 = false, nil, nil
lib.maketoggle("防布娃娃（有时无效）", anti, function(state)
	antird = state
	local ok, r = pcall(require, game.ReplicatedStorage.Packages.Ragdoll)
	if not ok or not r then return end
	if antird then
		if not oldfunc4 then oldfunc4 = r.EnableCharacterRagdoll end
		if not oldfunc5 then oldfunc5 = r.StunCharacter end
		r.EnableCharacterRagdoll = function() end
		r.StunCharacter = function() end
		task.spawn(function()
			while antird and on do
				task.wait()
				if localplr.Character then
					pcall(function() r:DisableCharacterRagdoll(localplr.Character) end)
					pcall(function() r:CancelCharacterStun(localplr.Character) end)
				end
			end
		end)
	else
		if oldfunc4 then r.EnableCharacterRagdoll = oldfunc4 end
		if oldfunc5 then r.StunCharacter = oldfunc5 end
	end
end)

local scaffoldblocks = {}
local antisc = false
lib.maketoggle("作为僵尸攀爬脚手架", anti, function(bool)
	antisc = bool
	for b, o in pairs(scaffoldblocks) do
		if not b or not b.Parent then scaffoldblocks[b] = nil
		else b[o[1]] = antisc and o[3] or o[2] end
	end
end)

function doblock(b)
	if not b or not b.Parent then return end
	if (b.Name == "Scaffold" or b.Name == "Truss") and b:FindFirstChild("Model") then
		for _, v in pairs(b.Model:GetChildren()) do
			if v.Name == "Truss" then
				scaffoldblocks[v] = { "CollisionGroup", v.CollisionGroup, "BlockRoot" }
				if antisc then v.CollisionGroup = "BlockRoot" end
			elseif v.Name == "ZombieCollision" then
				scaffoldblocks[v] = { "Parent", v.Parent, game.CoreGui }
				if antisc then v.Parent = game.CoreGui end
			end
		end
	end
end
function doblockmodel(c)
	table.insert(toc, c.ChildAdded:Connect(function(b) doblock(b) end))
	for _, b in pairs(c:GetChildren()) do doblock(b) end
end
table.insert(toc, workspace.Blocks.ChildAdded:Connect(function(c) doblockmodel(c) end))
for _, c in pairs(workspace.Blocks:GetChildren()) do doblockmodel(c) end

local antikb = false
lib.maketoggle("禁用击杀砖块（当你离岛太远或在水中停留超过 3 秒时你会死亡）", anti, function(bool)
	antikb = bool
	local kz = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("KillZones")
	if kz then
		for _, v in pairs(kz:GetChildren()) do v.CanTouch = not antikb end
	end
end)

lib.maketextbox("设置剑冷却时间", main, function(txt)
	txt = tonumber(txt)
	if not txt then return end
	local mod = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
	local items = mod and mod:FindFirstChild("ItemData")
	if not items then return end
	for _, v in pairs(items:GetChildren()) do
		if v:IsA("ModuleScript") then
			local ok, r = pcall(require, v)
			if ok and r and r.Swings then
				for _, s in pairs(r.Swings) do s.SwingCooldown = txt end
			end
		end
	end
end)

lib.maketoggle("无雾", main, function(bool) nofog = bool end)

lib.makebutton("防卡住（向上传送）", movement, function()
	local hrp = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = hrp.CFrame + Vector3.new(0, 40, 0)
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
end)
lib.makelabel("人类最快速度：26（建造回合：30）", movement)
lib.makelabel("僵尸最快速度：28（突击者则为 32）", movement)
speedLabel = lib.makelabel("当前移速：--", movement)
lib.maketoggle("启用移速修改", movement, function(bool)
	speedEnabled = bool
	local hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		if bool then
			savedWalkSpeed = hum.WalkSpeed
		elseif savedWalkSpeed then
			hum.WalkSpeed = savedWalkSpeed
			savedWalkSpeed = nil
		end
	end
end)
lib.makeslider("速度（已修复）", movement, 18, 32, function(n) speed = math.floor(n) end)

-- ---------- 透视 ----------
local zesp, hesp = false, false
local phl = {}
local hlf = Instance.new("Folder")
hlf.Name = "hls"
hlf.Parent = game.CoreGui

local function waitForChildSafe(parent, name, timeout)
	if not parent then return nil end
	local ok, res = pcall(function() return parent:WaitForChild(name, timeout) end)
	return ok and res or nil
end

function doplr(plr)
	local dochar
	if plr == localplr then
		dochar = function(c)
			local h = c:WaitForChild("Humanoid", 10)
			if not h then return end
			h.Died:Connect(function()
				if CurrentWeld then
					task.wait(3)
					if CurrentWeld then
						CurrentWeld:Destroy()
						CurrentWeld = nil
					end
					local hum = c:FindFirstChildOfClass("Humanoid")
					if hum and Camera then Camera.CameraSubject = hum end
				end
			end)
		end
	else
		dochar = function(c)
			local team = plr.Team
			local highlight = Instance.new("Highlight")
			highlight.Parent = hlf
			highlight.FillTransparency = 0.5
			highlight.FillColor = (plr.Team ~= localplr.Team and Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(0, 255, 0)
			if plr.Team then highlight.OutlineColor = plr.Team.TeamColor.Color end
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Adornee = c

			local bbgui = nil
			if team == game.Teams.Humans and hesp then
				highlight.Enabled = true
			elseif team == game.Teams.Monsters and zesp then
				highlight.Enabled = true
				bbgui = Instance.new("BillboardGui")
				bbgui.Size = UDim2.new(10, 0, 1.5, 0)
				bbgui.StudsOffset = Vector3.new(0, 3.5, 0)
				bbgui.Adornee = waitForChildSafe(c, "Head", 10)
				bbgui.AlwaysOnTop = true
				bbgui.Parent = highlight

				local txt = Instance.new("TextLabel")
				txt.TextScaled = true
				txt.BackgroundTransparency = 1
				txt.Size = UDim2.new(0, 100, 0, 20)
				txt.TextStrokeTransparency = 0
				txt.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
				txt.Text = ""
				txt.TextColor3 = Color3.fromRGB(255, 255, 255)
				txt.TextXAlignment = Enum.TextXAlignment.Center
				txt.Parent = bbgui

				local function watch(toolName, label, color)
					coroutine.wrap(function()
						local inChar = waitForChildSafe(c, toolName, 5)
						local inBack = (not inChar) and plr.Backpack and waitForChildSafe(plr.Backpack, toolName, 5)
						if inChar or inBack then
							txt.Text = label
							txt.TextColor3 = color
						end
					end)()
				end
				watch("Bomb", "爆破手", Color3.fromRGB(0, 0, 0))
				watch("Dynamite", "突击者", Color3.fromRGB(255, 155, 0))
				watch("Cannon", "炮手", Color3.fromRGB(60, 60, 60))
				watch("GravediggersPickaxe", "掘墓人", Color3.fromRGB(0, 150, 0))
				watch("GladiatorsSword", "角斗士", Color3.fromRGB(200, 0, 0))
				watch("HuntersBow", "猎人", Color3.fromRGB(0, 200, 200))
			else
				highlight.Enabled = false
			end
			phl[highlight] = { tn = team and team.Name or "", p = plr, c = c, bb = bbgui }
		end
	end

	if plr.Character then dochar(plr.Character) end
	table.insert(toc, plr.CharacterAdded:Connect(dochar))
	table.insert(toc, plr.CharacterRemoving:Connect(function(c)
		for i, v in pairs(phl) do
			if v.c == c then
				phl[i] = nil
				i:Destroy()
			end
		end
	end))
end
for _, v in pairs(game.Players:GetPlayers()) do doplr(v) end
table.insert(toc, game.Players.PlayerAdded:Connect(doplr))

lib.maketoggle("人类透视", esp, function(bool)
	hesp = bool
	for i, v in pairs(phl) do
		if v.tn == "Humans" then
			i.Enabled = hesp
			if v.bb then v.bb.Enabled = hesp end
		end
	end
end)
lib.maketoggle("僵尸透视", esp, function(bool)
	zesp = bool
	for i, v in pairs(phl) do
		if v.tn == "Monsters" then
			i.Enabled = zesp
			if v.bb then v.bb.Enabled = zesp end
		end
	end
end)
local otc = localplr:GetPropertyChangedSignal("Team"):Connect(function()
	for i, v in pairs(phl) do
		i.FillColor = (v.p.Team ~= localplr.Team and Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(0, 255, 0)
	end
end)

-- ---------- 人类焊接 ----------
lib.makelabel("此方法很可能会被修复。趁还能用赶紧用！", hw)
lib.makelabel("焊接方法最初由 Failedmite 和 Janmandio 发现。", hw)
lib.makelabel("代码取自 Infinite Yield 中的 Welder V2 插件", hw)
lib.makelabel("如果你使用的是 Xeno 或 Solara 等执行器，请开启低 sUNC 支持。", hw)
local lss, killweld = false, false
lib.maketoggle("低 sUNC 支持", hw, function(bool) lss = bool end)
lib.maketoggle("（几乎）秒杀（不会给分）", hw, function(bool) killweld = bool end)
local weldoffsetx, weldoffsety, weldoffsetz = 0, 0, 0
lib.makeslider("焊接偏移（X）", hw, -20, 20, function(n) weldoffsetx = math.floor(n) end)
lib.makeslider("焊接偏移（Y）", hw, -20, 20, function(n) weldoffsety = math.floor(n) end)
lib.makeslider("焊接偏移（Z）", hw, -20, 20, function(n) weldoffsetz = math.floor(n) end)

local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Players = game.Players
local RenderStepped = RunService.RenderStepped

local WELD_GROUP = (function()
	local buff = buffer.create(20)
	local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	for i = 1, 20 do
		buffer.writeu8(buff, i - 1, string.byte(charset, math.random(1, #charset)))
	end
	return buffer.tostring(buff)
end)()

pcall(function()
	PhysicsService:RegisterCollisionGroup(WELD_GROUP)
	PhysicsService:CollisionGroupSetCollidable(WELD_GROUP, WELD_GROUP, true)
end)

function LowsUNCWeldTo(Part, Speaker, AnimationId)
	if not Part or not Part.Parent then return end
	if Players:GetPlayerFromCharacter(Part.Parent) then
		local Humanoid = Part.Parent:FindFirstChildWhichIsA("Humanoid")
		if Camera then Camera.CameraSubject = Humanoid end
		if Humanoid then Humanoid.RequiresNeck = false end
	end
	local Character = Speaker.Character
	if not Character or not Character:FindFirstChild("HumanoidRootPart") then return nil end
	local Root = Character.HumanoidRootPart.AssemblyRootPart
	local Start = CFrame.new(Root.Position)
	local Weld = {}
	local Enabled = false
	local PartJoints, OldProps, OldCharProps, AnimTrack = {}, {}, {}, nil

	if AnimationId then
		local Animator = Character:FindFirstChildWhichIsA("Animator", true)
		if Animator then
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://" .. tostring(AnimationId)
			AnimTrack = Animator:LoadAnimation(Animation)
			AnimTrack:Play()
		end
	end
	Weld.Velocity = killweld and Vector3.new(0, 10000, 0) or Vector3.zero

	function Weld:Enable(toggle)
		Enabled = toggle
		if not toggle then
			for _, Joint in next, PartJoints do Joint.Enabled = true end
			for PropName, Value in next, OldProps do Part[PropName] = Value end
			for part, props in next, OldCharProps do
				if part and part.Parent then
					part.CollisionGroup = props.Group
					part.CanCollide = props.Collide
				end
			end
			return
		end
		PartJoints = Part:GetJoints()
		for _, PropName in next, { "Size", "CanCollide", "Anchored", "Parent", "CollisionGroup" } do
			OldProps[PropName] = Part[PropName]
		end
		for _, p in next, Character:GetDescendants() do
			if p:IsA("BasePart") then
				OldCharProps[p] = { Group = p.CollisionGroup, Collide = p.CanCollide }
				p.CollisionGroup = WELD_GROUP
				p.CanCollide = true
			end
		end
		Part.Size = Vector3.new(25, 3, 25)
		Part.Anchored = false
		Part.CanCollide = true
		Part.CollisionGroup = WELD_GROUP
		Part.Parent = workspace.Terrain
		for _, Joint in next, PartJoints do Joint.Enabled = false end
	end

	local thread
	function Weld:Destroy()
		if thread then task.cancel(thread) end
		Weld:Enable(false)
		if AnimTrack then AnimTrack:Stop(); AnimTrack:Destroy() end
	end

	thread = task.spawn(function()
		while task.wait() do
			if not Enabled or not Character.Parent then
				if not Character.Parent then break end
				continue
			end
			Part.CFrame = Start
			Root.CFrame = Start * CFrame.new(weldoffsetx, weldoffsety, weldoffsetz)
			Part.AssemblyLinearVelocity = Vector3.zero
			Part.AssemblyAngularVelocity = Vector3.zero
			Root.AssemblyLinearVelocity = Weld.Velocity
			Root.AssemblyAngularVelocity = Vector3.zero
			RenderStepped:Wait()
			Part.CFrame = Start
			Root.CFrame = Start * CFrame.new(0, 4, 0)
			Part.AssemblyLinearVelocity = Vector3.zero
			Part.AssemblyAngularVelocity = Vector3.zero
		end
	end)
	Weld:Enable(true)
	return Weld
end

local function WeldTo(TargetPart, Speaker, AnimationId)
	local Character = Speaker.Character
	if not Character then return nil end
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if not Root or not Humanoid then return nil end

	local AnimTrack = nil
	if AnimationId then
		local Animator = Character:FindFirstChildWhichIsA("Animator", true)
		if Animator then
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://" .. tostring(AnimationId)
			AnimTrack = Animator:LoadAnimation(Animation)
			AnimTrack:Play()
		end
	end

	local Weld = {}
	local Connection
	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Massless = true
		end
	end

	Connection = RunService.Heartbeat:Connect(function()
		if not Character.Parent or not TargetPart.Parent then
			if Weld.Destroy then Weld:Destroy() end
			return
		end
		Root.CFrame = TargetPart.CFrame * CFrame.new(weldoffsetx, weldoffsety, weldoffsetz)
		Root.AssemblyLinearVelocity = killweld and Vector3.new(0, 10000, 0) or Vector3.zero
		Root.AssemblyAngularVelocity = Vector3.zero
		if sethiddenproperty then
			pcall(function() sethiddenproperty(Root, "PhysicsRepRootPart", TargetPart) end)
		end
	end)

	function Weld:Destroy()
		if Connection then Connection:Disconnect() end
		if AnimTrack then AnimTrack:Stop(); AnimTrack:Destroy() end
		if Root then
			Root.AssemblyLinearVelocity = Vector3.zero
			Root.AssemblyAngularVelocity = Vector3.zero
		end
	end
	return Weld
end

local function doWeldTo(hrp)
	if CurrentWeld then
		pcall(function() CurrentWeld:Destroy() end)
		CurrentWeld = nil
	end
	if not hrp then return end
	local fn = lss and LowsUNCWeldTo or WeldTo
	local ok, w = pcall(fn, hrp, localplr, 0)
	if ok then CurrentWeld = w end
end

lib.makebutton("焊接到随机人类", hw, function()
	local pool = {}
	for _, p in ipairs(game.Teams.Humans:GetPlayers()) do
		if p ~= localplr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			table.insert(pool, p)
		end
	end
	if #pool > 0 then doWeldTo(pool[math.random(1, #pool)].Character.HumanoidRootPart) end
end)

lib.makebutton("焊接到随机僵尸", hw, function()
	local pool = {}
	for _, p in ipairs(game.Teams.Monsters:GetPlayers()) do
		if p ~= localplr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			table.insert(pool, p)
		end
	end
	if #pool > 0 then doWeldTo(pool[math.random(1, #pool)].Character.HumanoidRootPart) end
end)

lib.maketextbox("焊接到指定玩家", hw, function(plrname)
	if not plrname or plrname == "" then return end
	local q = plrname:lower()
	for _, v in pairs(game.Players:GetPlayers()) do
		local dn = string.sub(v.DisplayName:lower(), 1, #q)
		local nn = string.sub(v.Name:lower(), 1, #q)
		if (dn == q or nn == q) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			doWeldTo(v.Character.HumanoidRootPart)
			return
		end
	end
end)

lib.makebutton("解除焊接", hw, function()
	if CurrentWeld then
		pcall(function() CurrentWeld:Destroy() end)
		CurrentWeld = nil
	end
	local h = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
	if h and Camera then Camera.CameraSubject = h end
end)

lib.makebutton("碰撞箱拓展器", oscr, function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ujerald789/Alien/refs/heads/main/UN"))()
end)

if game:GetService("ReplicatedStorage").Remotes:FindFirstChild("ConsoleLog") then
	game:GetService("ReplicatedStorage").Remotes.ConsoleLog:Destroy()
	local fcl = Instance.new("RemoteFunction")
	fcl.Name = "ConsoleLog"
	fcl.Parent = game:GetService("ReplicatedStorage").Remotes
end

-- ---------- 关闭清理 ----------
lib.ondestroyedfunc = function()
	on = false
	ha, bha, gha = false, false, false
	antisc, antird, nofog = false, false, false
	speed, speedEnabled = nil, false
	local hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
	if hum and savedWalkSpeed then hum.WalkSpeed = savedWalkSpeed end
	savedWalkSpeed = nil

	if hlf then pcall(function() hlf:Destroy() end) end
	if otc then pcall(function() otc:Disconnect() end) end
	if ors then pcall(function() ors:Disconnect() end) end
	for _, c in pairs(toc) do
		pcall(function() c:Disconnect() end)
	end

	local kz = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("KillZones")
	if kz then
		for _, v in pairs(kz:GetChildren()) do v.CanTouch = true end
	end

	if localplr.PlayerGui then
		local ov = localplr.PlayerGui:FindFirstChild("Overlay")
		if ov then ov.Enabled = true end
	end

	if newprt and newprt.Parent then pcall(function() newprt:Destroy() end) end

	if deathreq and deathreq.Parent ~= game.ReplicatedStorage.Remotes then
		pcall(function() deathreq.Parent = game.ReplicatedStorage.Remotes end)
	end

	if CurrentWeld then
		pcall(function() CurrentWeld:Destroy() end)
		CurrentWeld = nil
	end
	local h = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
	if h and Camera then Camera.CameraSubject = h end

	if oldfunc1 then
		pcall(function() require(localplr.PlayerScripts.Client.Character.JumpFatigue).GetCanFatigue = oldfunc1 end)
	end
	if oldfunc2 then
		pcall(function() require(localplr.PlayerScripts.Client.Game.NoWallhop).GetIsOnGround = oldfunc2 end)
	end
	if oldfunc3 then
		pcall(function() require(localplr.PlayerScripts.Client.Game.FallDamage).GetFallDamage = oldfunc3 end)
	end
	if oldfunc4 then
		pcall(function() require(game.ReplicatedStorage.Packages.Ragdoll).EnableCharacterRagdoll = oldfunc4 end)
	end
	if oldfunc5 then
		pcall(function() require(game.ReplicatedStorage.Packages.Ragdoll).StunCharacter = oldfunc5 end)
	end
end
