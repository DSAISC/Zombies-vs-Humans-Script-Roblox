--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
getgenv().deletewhendupefound = true
local lib = loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Lib-18698"))()

-- 创建主界面并保存引用（用于最小化）
local mainGui = lib.makelib("僵尸 vs 人类 (2AreYouMental110)")

local main = lib.maketab("主要")
local movement = lib.maketab("移动")
local esp = lib.maketab("ESP")
local anti = lib.maketab("反作弊")
local hw = lib.maketab("人体焊接")
local oscr = lib.maketab("其他脚本")

local localplr = game.Players.LocalPlayer
local on = true
local toc = {}

-- ===== 最小化圆球 =====
local ballGui = Instance.new("ScreenGui")
ballGui.Name = "MinimizeBall"
ballGui.Parent = game.CoreGui

local ballButton = Instance.new("TextButton")
ballButton.Size = UDim2.new(0, 45, 0, 45)
ballButton.Position = UDim2.new(1, -55, 1, -55)  -- 右下角
ballButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ballButton.Text = ""
ballButton.AutoButtonColor = false
ballButton.Visible = false
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = ballButton
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Parent = ballButton
ballButton.Parent = ballGui

ballButton.MouseButton1Click:Connect(function()
	ballButton.Visible = false
	mainGui.Enabled = true
end)

-- ===== 普通攻击光环可视化 =====
local hitAuraRange = 20
local showHitAuraCircle = false
local hitAuraTransparency = 0.5
local hitAuraCircle = Instance.new("Part")
hitAuraCircle.Name = "HitAuraCircle"
hitAuraCircle.Shape = Enum.PartType.Ball
hitAuraCircle.Anchored = true
hitAuraCircle.CanCollide = false
hitAuraCircle.Material = Enum.Material.Neon
hitAuraCircle.Color = Color3.fromRGB(255, 0, 0)
hitAuraCircle.Transparency = 1  -- 默认隐藏
hitAuraCircle.Parent = workspace

-- ===== 蓄力攻击光环可视化 =====
local gladAuraRange = 20
local showGladAuraCircle = false
local gladAuraTransparency = 0.5
local gladCircle = Instance.new("Part")
gladCircle.Name = "GladAuraCircle"
gladCircle.Shape = Enum.PartType.Ball
gladCircle.Anchored = true
gladCircle.CanCollide = false
gladCircle.Material = Enum.Material.Neon
gladCircle.Color = Color3.fromRGB(255, 165, 0)  -- 橙色区分
gladCircle.Transparency = 1
gladCircle.Parent = workspace

-- ===== 方块破坏光环球体 =====
local bha = false
local bhas = 20
local blockAuraTransparency = 0.8
local newprt = Instance.new("Part")
newprt.Size = Vector3.new(bhas*2, bhas*2, bhas*2)
newprt.Anchored = true
newprt.Transparency = 1
newprt.CanCollide = false
newprt.Shape = Enum.PartType.Ball
newprt.Parent = workspace

-- ===== 警告 =====
lib.makelabel("⚠️ 警告：所有功能都有封号风险！此游戏有 Discord 举报系统，若你有很多游戏进度，请勿作弊！", main)

local currposl = lib.makelabel("当前位置：", main)
local cfrcheckl = lib.makelabel("死亡距离（达到0则触发反作弊死亡）：", main)

lib.makelabel("", main)
lib.makelabel("—— 攻击辅助 ——", main)

-- 普通攻击光环
local ha = false
lib.maketoggle("自动攻击光环", main, function(bool)
	ha = bool
end)

lib.makeslider("攻击光环范围", main, 5, 50, function(n)
	hitAuraRange = n
	hitAuraCircle.Size = Vector3.new(n*2, n*2, n*2)
end)

lib.maketoggle("显示攻击光环红圈", main, function(bool)
	showHitAuraCircle = bool
end)

lib.makeslider("攻击光环透明度", main, 0, 100, function(n)
	hitAuraTransparency = n / 100
end)

-- 蓄力攻击光环（角斗士）
local gha = false
lib.maketoggle("蓄力攻击光环（角斗士）", main, function(bool)
	gha = bool
end)

lib.makeslider("蓄力攻击范围", main, 5, 50, function(n)
	gladAuraRange = n
	gladCircle.Size = Vector3.new(n*2, n*2, n*2)
end)

lib.maketoggle("显示蓄力攻击橙圈", main, function(bool)
	showGladAuraCircle = bool
end)

lib.makeslider("蓄力攻击透明度", main, 0, 100, function(n)
	gladAuraTransparency = n / 100
end)

-- 方块破坏光环
lib.maketoggle("方块破坏光环（掘墓者）", main, function(bool)
	bha = bool
end)
lib.makeslider("方块破坏光环范围", main, 0, 20, function(n)
	bhas = n
	newprt.Size = Vector3.new(n*2, n*2, n*2)
end)

lib.makeslider("方块破坏光环透明度", main, 0, 100, function(n)
	blockAuraTransparency = n / 100
end)

-- 连击计数
local comb = 0
function addcomb()
	comb = comb + 1
	if comb > 3 then comb = 1 end
end

function getmelee()
	local sword = nil
	for i,v in pairs(localplr.Backpack:GetChildren()) do
		if v:IsA("Tool") and (string.find(v.Name,"Sword") or string.find(v.Name:lower(),"axe") or string.find(v.Name,"Dagger") or string.find(v.Name,"Hammer") or v.Name == "Trident") then
			sword = v
			v.Parent = localplr.Character
		end
	end
	if not sword and localplr.Character then
		for i,v in pairs(localplr.Character:GetChildren()) do
			if v:IsA("Tool") and (string.find(v.Name,"Sword") or string.find(v.Name:lower(),"axe") or string.find(v.Name,"Dagger") or string.find(v.Name,"Hammer") or v.Name == "Trident") then
				sword = v
			end
		end
	end
	return sword
end

local swordcooldowns = {
	WoodenSword = 0.35,
	Trident = 0.85,
	StoneSword = 0.425,
	GravediggersPickaxe = 2.2,
	ObsidianHammer = 1.4,
	IronSword = 0.525,
	GladiatorsSword = 2,
	FlintDagger = 0.2,
	EmeraldAxe = 1.5,
	DiamondSword = 0.8,
}

local partdelays = {}
function adelay(part, checksword)
	partdelays[part] = true
	if typeof(checksword) == "Instance" then
		checksword = swordcooldowns[checksword.Name] and swordcooldowns[checksword.Name]/8
	end
	task.delay((typeof(checksword) == "Number" and checksword) or 0.1, function()
		partdelays[part] = nil
	end)
end
function checkdelay(part)
	return partdelays[part] == nil
end

local ii = game.ReplicatedStorage.Remotes.ItemInteract
local proj = workspace.Projectiles
local graves = workspace.Graves
local blocks = workspace.Blocks
local supportsgpip = workspace.GetPartsInPart ~= nil
local charged = false
local speed = nil

local ors = game:GetService("RunService").RenderStepped:Connect(function()
	debug.profilebegin("ZVHRenderStepped")
	if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = localplr.Character.HumanoidRootPart
		local pos = hrp.Position
		pos = Vector3.new(math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
		currposl.Text = "当前位置： "..tostring(pos)
		local dm = 99999
		local v1 = (750 - math.abs(pos.X))
		local v2 = (800 - math.abs(pos.Y))
		local v3 = (900 - math.abs(pos.Z))
		if v1 < dm then dm = v1 end
		if v2 < dm then dm = v2 end
		if v3 < dm then dm = v3 end
		cfrcheckl.Text = "死亡距离（反作弊）： "..tostring(dm).." | X:"..v1.." Y:"..v2.." Z:"..v3

		-- 更新攻击光环显示
		if showHitAuraCircle and ha then
			hitAuraCircle.CFrame = hrp.CFrame
			hitAuraCircle.Transparency = hitAuraTransparency
		else
			hitAuraCircle.Transparency = 1
		end
		if showGladAuraCircle and gha then
			gladCircle.CFrame = hrp.CFrame
			gladCircle.Transparency = gladAuraTransparency
		else
			gladCircle.Transparency = 1
		end
		if bha then
			newprt.Transparency = blockAuraTransparency
		else
			newprt.Transparency = 1
		end

		-- 更新移动速度显示
		local humanoid = localplr.Character:FindFirstChild("Humanoid")
		if humanoid then
			speedLabel.Text = "当前速度：" .. math.floor(humanoid.WalkSpeed)
		else
			speedLabel.Text = "当前速度：--"
		end
	end

	-- 更新身份显示
	if localplr.Team == game.Teams.Monsters then
		identityLabel.Text = "当前身份：僵尸"
	else
		identityLabel.Text = "当前身份：人类"
	end

	if speed and localplr.Character and localplr.Character:FindFirstChild("Humanoid") then
		localplr.Character.Humanoid.WalkSpeed = speed
	end

	if ha or bha then
		local sword = getmelee()
		if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
			-- 蓄力攻击光环 (角斗士)
			if gha and sword then
				for i,v in pairs(game.Players:GetPlayers()) do
					if v ~= localplr and v.Team ~= localplr.Team and v.Character and checkdelay(v.Character) and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character.HumanoidRootPart.Position - localplr.Character.HumanoidRootPart.Position).Magnitude < gladAuraRange then
						if not charged then
							charged = true
							ii:InvokeServer(sword, "StartChargeUp")
							task.wait(.5)
							ii:InvokeServer(sword, "StartCharge")
							task.delay(10, function()
								charged = false
							end)
						end
						adelay(v.Character, sword)
						coroutine.wrap(function()
							ii:InvokeServer(sword, "ChargeHit", v.Character)
						end)()
						task.wait()
					end
				end
			end
			-- 普通攻击光环
			if ha and sword then
				if not gha or sword.Name ~= "GladiatorsSword" then
					for i,v in pairs(game.Players:GetPlayers()) do
						if v ~= localplr and v.Team ~= localplr.Team and v.Character and checkdelay(v.Character) and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character.HumanoidRootPart.Position - localplr.Character.HumanoidRootPart.Position).Magnitude < hitAuraRange and v.Character.Humanoid.Health > 0 then
							adelay(v.Character, sword)
							coroutine.wrap(function()
								addcomb()
								ii:InvokeServer(sword, "Hit", v.Character, comb)
							end)()
							task.wait()
						end
					end
				end
				for i,v in pairs(proj:GetChildren()) do
					if v:IsA("BasePart") and checkdelay(v) and (v.Position - localplr.Character.HumanoidRootPart.Position).Magnitude < 40 then
						if v.Name ~= "Cannonball" then continue end
						adelay(v, 0.05)
						coroutine.wrap(function()
							addcomb()
							ii:InvokeServer(sword, "ProjectileHit", v, comb)
						end)()
					end
				end
				for i,v in pairs(graves:GetChildren()) do
					if checkdelay(v) and (((v:IsA("BasePart") and v.CFrame) or (v:IsA("Model") and v:GetPivot())).Position - localplr.Character.HumanoidRootPart.Position).Magnitude < 20 then
						adelay(v, sword)
						coroutine.wrap(function()
							addcomb()
							ii:InvokeServer(sword, "GraveHit", v, comb)
						end)()
					end
				end
			end
			-- 方块破坏光环
			if bha and sword and sword.Name == "GravediggersPickaxe" then
				if supportsgpip then
					newprt.CFrame = localplr.Character.HumanoidRootPart.CFrame
					local parts = workspace:GetPartsInPart(newprt)
					for i,v in pairs(parts) do
						if v:IsDescendantOf(blocks) and v:IsA("BasePart") and checkdelay(v) then
							adelay(v, 0.5)
							if v.Name == "Root" then v = v.Parent end
							coroutine.wrap(function()
								addcomb()
								pcall(function()
									ii:InvokeServer(sword, "BlockHit", v, comb)
								end)
							end)()
						end
					end
				else
					for i,v in pairs(blocks:GetChildren()) do
						if v:IsA("BasePart") and (v.Position - localplr.Character.HumanoidRootPart.Position).Magnitude < bhas and checkdelay(v) then
							adelay(v, 0.5)
							addcomb()
							coroutine.wrap(function()
								ii:InvokeServer(sword, "BlockHit", v, comb)
							end)()
						end
					end
				end
			end
		end
	end
	debug.profileend()
end)

-- ===== 移动 =====
lib.makelabel("", movement)
lib.makelabel("—— 移动辅助 ——", movement)
lib.makebutton("脱困（向上传送）", movement, function()
	localplr.Character.HumanoidRootPart.CFrame = localplr.Character.HumanoidRootPart.CFrame + Vector3.new(0,40,0)
	localplr.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
end)
lib.makelabel("人类最快速度：26（建筑模式：30）", movement)
lib.makelabel("僵尸最快速度：28（冲锋者32）", movement)
lib.makeslider("移动速度", movement, 18, 32, function(n)
	speed = math.floor(n)
end)

-- 新增动态显示
speedLabel = lib.makelabel("当前速度：--", movement)
identityLabel = lib.makelabel("当前身份：--", movement)

-- ===== 反作弊 =====
local antij = false
local oldfunc1 = nil
lib.maketoggle("移除跳跃疲劳", anti, function(bool)
	antij = bool
	local r = require(localplr.PlayerScripts.Client.Character.JumpFatigue)
	if antij then
		oldfunc1 = r.GetCanFatigue
		r.GetCanFatigue = function() end
	else
		r.GetCanFatigue = oldfunc1
	end
end)

local antiwh = false
local oldfunc2 = nil
lib.maketoggle("解除爬墙限制", anti, function(bool)
	antiwh = bool
	local r = require(localplr.PlayerScripts.Client.Game.NoWallhop)
	if antiwh then
		oldfunc2 = r.GetIsOnGround
		r.GetIsOnGround = function()
			return true
		end
	else
		r.GetIsOnGround = oldfunc2
	end
end)

local deathreq = game.ReplicatedStorage.Remotes:WaitForChild("RequestThyDeath")
local antifm = false
lib.maketoggle("防飞行检测", anti, function(bool)
	antifm = bool
	if antifm then
		deathreq.Parent = workspace
	else
		deathreq.Parent = game.ReplicatedStorage.Remotes
	end
end)

local antifd = false
local oldfunc3 = nil
lib.maketoggle("免疫掉落伤害", anti, function(bool)
	antifd = bool
	local r = require(localplr.PlayerScripts.Client.Game.FallDamage)
	if antifd then
		oldfunc3 = r.GetFallDamage
		r.GetFallDamage = function() return 0 end
	else
		r.GetFallDamage = oldfunc3
	end
end)

local antird = false
local oldfunc4, oldfunc5 = nil, nil
lib.maketoggle("防布娃娃/眩晕（有时失效）", anti, function(bool)
	antird = bool
	local r = require(game.ReplicatedStorage.Packages.Ragdoll)
	if antird then
		oldfunc4 = r.EnableCharacterRagdoll
		r.EnableCharacterRagdoll = function() end
		oldfunc5 = r.StunCharacter
		r.StunCharacter = function() end
		while antird do
			task.wait()
			r:DisableCharacterRagdoll(localplr.Character)
			r:CancelCharacterStun(localplr.Character)
		end
	else
		r.EnableCharacterRagdoll = oldfunc4
		r.StunCharacter = oldfunc5
	end
end)

local scaffoldblocks = {}
local antisc = false
lib.maketoggle("僵尸攀爬脚手架", anti, function(bool)
	antisc = bool
	for b, o in pairs(scaffoldblocks) do
		if not b or not b.Parent then
			scaffoldblocks[b] = nil
		else
			b[o[1]] = (antisc and o[3]) or o[2]
		end
	end
end)

function doblock(b)
	if not b or not b.Parent then return end
	if b.Name == "Scaffold" or b.Name == "Truss" then
		for i,v in pairs(b.Model:GetChildren()) do
			if v.Name == "Truss" then
				scaffoldblocks[v] = {"CollisionGroup", v.CollisionGroup, "BlockRoot"}
				if antisc then v.CollisionGroup = "BlockRoot" end
			elseif v.Name == "ZombieCollision" then
				scaffoldblocks[v] = {"Parent", v.Parent, game.CoreGui}
				if antisc then v.Parent = game.CoreGui end
			end
		end
	end
end

function doblockmodel(c)
	table.insert(toc, c.ChildAdded:Connect(function(b) doblock(b) end))
	for i,b in pairs(c:GetChildren()) do doblock(b) end
end

table.insert(toc, workspace.Blocks.ChildAdded:Connect(function(c) doblockmodel(c) end))
for i,c in pairs(workspace.Blocks:GetChildren()) do doblockmodel(c) end

local antikb = false
lib.maketoggle("关闭必死区域（水/边界）", anti, function(bool)
	antikb = bool
	for i,v in pairs(workspace.Map.KillZones:GetChildren()) do
		v.CanTouch = not antikb
	end
end)

-- ===== ESP =====
local zesp = false
local hesp = false
local phl = {}
local hlf = Instance.new("Folder")
hlf.Name = "hls"
hlf.Parent = game.CoreGui

function doplr(plr)
	local function dochar(c) end
	if plr == localplr then
		dochar = function(c)
			local h = c:WaitForChild("Humanoid")
			h.Died:Connect(function()
				if CurrentWeld then
					task.wait(3)
					CurrentWeld:Destroy()
					workspace.Camera.CameraSubject = localplr.Character and localplr.Character.Humanoid
				end
			end)
		end
	else
		dochar = function(c)
			local team = plr.Team
			local highlight = Instance.new("Highlight")
			highlight.Parent = hlf
			highlight.FillTransparency = 0.5
			highlight.FillColor = (plr.Team ~= localplr.Team and Color3.fromRGB(255,0,0)) or Color3.fromRGB(0,255,0)
			highlight.OutlineColor = plr.Team.TeamColor.Color
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Adornee = c
			local bbgui = nil
			if team == game.Teams.Humans and hesp then
				highlight.Enabled = true
			elseif team == game.Teams.Monsters and zesp then
				highlight.Enabled = true
				bbgui = Instance.new("BillboardGui")
				bbgui.Size = UDim2.new(10,0,1.5,0)
				bbgui.StudsOffset = Vector3.new(0,3.5,0)
				bbgui.Adornee = c:WaitForChild("Head",10)
				bbgui.AlwaysOnTop = true
				bbgui.Parent = highlight
				local txt = Instance.new("TextLabel")
				txt.TextScaled = true
				txt.BackgroundTransparency = 1
				txt.Size = UDim2.new(0,100,0,20)
				txt.Position = UDim2.new(0,0,0,0)
				txt.TextStrokeTransparency = 0
				txt.TextStrokeColor3 = Color3.fromRGB(255,255,255)
				txt.Text = ""
				txt.TextColor3 = Color3.fromRGB(255,255,355)
				txt.TextXAlignment = Enum.TextXAlignment.Center
				txt.Parent = bbgui
				coroutine.wrap(function()
					if c:FindFirstChild("Bomb") or plr.Backpack:FindFirstChild("Bomb") then
						txt.Text = "炸弹人"
						txt.TextColor3 = Color3.fromRGB(0,0,0)
					end
				end)()
				coroutine.wrap(function()
					if c:FindFirstChild("Dynamite") or plr.Backpack:FindFirstChild("Dynamite") then
						txt.Text = "冲锋者"
						txt.TextColor3 = Color3.fromRGB(255,155,0)
					end
				end)()
				coroutine.wrap(function()
					if c:FindFirstChild("Cannon") or plr.Backpack:FindFirstChild("Cannon") then
						txt.Text = "炮手"
						txt.TextColor3 = Color3.fromRGB(60,60,60)
					end
				end)()
				coroutine.wrap(function()
					if c:FindFirstChild("GravediggersPickaxe") or plr.Backpack:FindFirstChild("GravediggersPickaxe") then
						txt.Text = "掘墓者"
						txt.TextColor3 = Color3.fromRGB(0,150,0)
					end
				end)()
				coroutine.wrap(function()
					if c:FindFirstChild("GladiatorsSword") or plr.Backpack:FindFirstChild("GladiatorsSword") then
						txt.Text = "角斗士"
						txt.TextColor3 = Color3.fromRGB(200,0,0)
					end
				end)()
				coroutine.wrap(function()
					if c:FindFirstChild("HuntersBow") or plr.Backpack:FindFirstChild("HuntersBow") then
						txt.Text = "猎人"
						txt.TextColor3 = Color3.fromRGB(0,200,200)
					end
				end)()
			else
				highlight.Enabled = false
			end
			phl[highlight] = {tn = team.Name, p = plr, c = c, bb = bbgui}
		end
	end
	if plr.Character then dochar(plr.Character) end
	table.insert(toc, plr.CharacterAdded:Connect(dochar))
	table.insert(toc, plr.CharacterRemoving:Connect(function(c)
		for i,v in pairs(phl) do
			if v.c == c then phl[i] = nil i:Destroy() end
		end
	end))
end

for i,v in pairs(game.Players:GetPlayers()) do doplr(v) end
table.insert(toc, game.Players.PlayerAdded:Connect(doplr))

lib.maketoggle("显示人类", esp, function(bool)
	hesp = bool
	for i,v in pairs(phl) do
		if v.tn == "Humans" then
			i.Enabled = hesp
			if v.bb then v.bb.Enabled = hesp end
		end
	end
end)
lib.maketoggle("显示僵尸", esp, function(bool)
	zesp = bool
	for i,v in pairs(phl) do
		if v.tn == "Monsters" then
			i.Enabled = zesp
			if v.bb then v.bb.Enabled = zesp end
		end
	end
end)

local otc = localplr:GetPropertyChangedSignal("Team"):Connect(function()
	for i,v in pairs(phl) do
		i.FillColor = (v.p.Team ~= localplr.Team and Color3.fromRGB(255,0,0)) or Color3.fromRGB(0,255,0)
	end
end)

-- ===== 人体焊接 =====
lib.makelabel("此方法可能很快被修复，请尽快使用！", hw)
lib.makelabel("焊接方法最初由 Failedmite 和 Janmandio 发现", hw)
lib.makelabel("代码来自 Infinite Yield 的 “Welder V2” 插件", hw)
lib.makelabel("使用 Xeno 或 Solara 等执行器时，请开启低兼容模式", hw)

local lss = false
lib.maketoggle("低 sUNC 支持", hw, function(bool) lss = bool end)

local killweld = false
lib.maketoggle("瞬间杀死（不获得积分）", hw, function(bool) killweld = bool end)

local weldoffsetx, weldoffsety, weldoffsetz = 0, 0, 0
lib.makeslider("焊接偏移 X", hw, -20, 20, function(n) weldoffsetx = math.floor(n) end)
lib.makeslider("焊接偏移 Y", hw, -20, 20, function(n) weldoffsety = math.floor(n) end)
lib.makeslider("焊接偏移 Z", hw, -20, 20, function(n) weldoffsetz = math.floor(n) end)

local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Players = game.Players
local RenderStepped = RunService.RenderStepped
local CurrentWeld = nil

local WELD_GROUP = (function()
	local buff = buffer.create(20)
	local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local clen = #charset
	for i = 1, 20 do
		local c = string.byte(charset, math.random(1, clen))
		buffer.writeu8(buff, i - 1, c)
	end
	return buffer.tostring(buff)
end)()

pcall(function()
	PhysicsService:RegisterCollisionGroup(WELD_GROUP)
	PhysicsService:CollisionGroupSetCollidable(WELD_GROUP, WELD_GROUP, true)
end)

function LowsUNCWeldTo(Part, Speaker, AnimationId)
	if not Part.Parent then return end
	if Players:GetPlayerFromCharacter(Part.Parent) then
		local Humanoid = Part.Parent:FindFirstChildWhichIsA("Humanoid")
		workspace.Camera.CameraSubject = Humanoid
		if Humanoid then Humanoid.RequiresNeck = false end
	end
	local Character = Speaker.Character
	if not Character or not Character:FindFirstChild("HumanoidRootPart") then return nil end
	local Root = Character.HumanoidRootPart
	local Start = CFrame.new(Root.Position)
	local Weld = {}
	local Enabled = false
	local PartJoints = {}
	local OldProps = {}
	local OldCharProps = {}
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
	Weld.Velocity = (killweld and (Vector3.new(0,10000,0))) or Vector3.zero
	function Weld:Enable(toggle)
		Enabled = toggle
		if not toggle then
			for _, Joint in next, PartJoints do Joint.Enabled = true end
			for PropName, Value in next, OldProps do (Part :: any)[PropName] = Value end
			for part, props in next, OldCharProps do
				if not part or not part.Parent then continue end
				part.CollisionGroup = props.Group
				part.CanCollide = props.Collide
			end
			return
		end
		PartJoints = Part:GetJoints()
		for _, PropName in next, {"Size", "CanCollide", "Anchored", "Parent", "CollisionGroup"} do
			OldProps[PropName] = (Part :: any)[PropName]
		end
		for _, p in next, Character:GetDescendants() do
			if not p:IsA("BasePart") then continue end
			OldCharProps[p] = {Group = p.CollisionGroup, Collide = p.CanCollide}
			p.CollisionGroup = WELD_GROUP
			p.CanCollide = true
		end
		Part.Size = Vector3.new(25, 3, 25)
		Part.Anchored = false
		Part.CanCollide = true
		Part.CollisionGroup = WELD_GROUP
		Part.Parent = workspace.Terrain
		for _, Joint in next, PartJoints do Joint.Enabled = false end
	end
	local thread = nil
	function Weld:Destroy()
		task.cancel(thread)
		Weld:Enable(false)
		if AnimTrack then AnimTrack:Stop(); AnimTrack:Destroy() end
	end
	thread = task.spawn(function()
		while task.wait() do
			if not Enabled then continue end
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
	local Connection = nil
	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Massless = true
		end
	end
	Connection = RunService.Heartbeat:Connect(function()
		if not (Character and Character.Parent) or not (TargetPart and TargetPart.Parent) then
			if Weld.Destroy then Weld:Destroy() end
			return
		end
		Root.CFrame = TargetPart.CFrame * CFrame.new(weldoffsetx, weldoffsety, weldoffsetz)
		Root.AssemblyLinearVelocity = (killweld and (Vector3.new(0,10000,0))) or Vector3.zero
		Root.AssemblyAngularVelocity = Vector3.zero
		if sethiddenproperty then
			pcall(function()
				sethiddenproperty(Root, "PhysicsRepRootPart", TargetPart)
			end)
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

lib.makebutton("焊接到随机人类", hw, function()
	if CurrentWeld then CurrentWeld:Destroy() end
	local hrp = nil
	repeat
		task.wait()
		if #game.Teams.Humans:GetPlayers() > 0 + ((localplr.Team == game.Teams.Humans and 1) or 0) then
			randomplr = game.Teams.Humans:GetPlayers()[math.random(1, #game.Teams.Humans:GetPlayers())]
			if randomplr ~= localplr and randomplr.Character and randomplr.Character:FindFirstChild("HumanoidRootPart") then
				hrp = randomplr.Character.HumanoidRootPart
			end
		else break end
	until hrp
	if hrp then
		CurrentWeld = (lss and LowsUNCWeldTo or WeldTo)(hrp, localplr, 0)
	end
end)

lib.makebutton("焊接到随机僵尸", hw, function()
	if CurrentWeld then CurrentWeld:Destroy() end
	local hrp = nil
	repeat
		task.wait()
		if #game.Teams.Monsters:GetPlayers() > 0 + ((localplr.Team == game.Teams.Monsters and 1) or 0) then
			randomplr = game.Teams.Monsters:GetPlayers()[math.random(1, #game.Teams.Monsters:GetPlayers())]
			if randomplr ~= localplr and randomplr.Character and randomplr.Character:FindFirstChild("HumanoidRootPart") then
				hrp = randomplr.Character.HumanoidRootPart
			end
		else break end
	until hrp
	if hrp then
		CurrentWeld = (lss and LowsUNCWeldTo or WeldTo)(hrp, localplr, 0)
	end
end)

lib.maketextbox("焊接到指定玩家", hw, function(plrname)
	if CurrentWeld then CurrentWeld:Destroy() end
	local hrp = nil
	for i,v in pairs(game.Players:GetPlayers()) do
		if (string.sub(v.DisplayName,1,#plrname):lower() == plrname or string.sub(v.Name,1,#plrname):lower() == plrname) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			hrp = v.Character.HumanoidRootPart
		end
	end
	if hrp then
		CurrentWeld = (lss and LowsUNCWeldTo or WeldTo)(hrp, localplr, 0)
	end
end)

lib.makebutton("解除焊接", hw, function()
	if CurrentWeld then
		CurrentWeld:Destroy()
		workspace.Camera.CameraSubject = localplr.Character and localplr.Character.Humanoid
	end
end)

-- ===== 其他脚本 =====
lib.makebutton("加载 Infinite Yield", oscr, function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)
lib.makebutton("加载念力脚本", oscr, function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Telekinesis-WIP-240257"))()
end)

-- 破坏 ConsoleLog 反作弊
if game:GetService("ReplicatedStorage").Remotes:FindFirstChild("ConsoleLog") then
	game:GetService("ReplicatedStorage").Remotes.ConsoleLog:Destroy()
	local fcl = Instance.new("RemoteFunction")
	fcl.Name = "ConsoleLog"
	fcl.Parent = game:GetService("ReplicatedStorage").Remotes
end

-- ===== 最小化功能 =====
local UIS = game:GetService("UserInputService")
local minimizeConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		if mainGui.Enabled then
			mainGui.Enabled = false
			ballButton.Visible = true
		else
			ballButton.Visible = false
			mainGui.Enabled = true
		end
	end
end)
table.insert(toc, minimizeConnection)

lib.makebutton("最小化界面", main, function()
	mainGui.Enabled = false
	ballButton.Visible = true
end)

-- ===== 清理函数 =====
lib.ondestroyedfunc = function()
	on = false
	ha = false
	bha = false
	gha = false
	antifm = false
	antisc = false
	antird = false
	hlf:Destroy()
	otc:Disconnect()
	ors:Disconnect()
	for i,v in pairs(toc) do v:Disconnect() end
	for i,v in pairs(workspace.Map.KillZones:GetChildren()) do v.CanTouch = true end
	localplr.PlayerGui.Overlay.Enabled = true
	newprt:Destroy()
	hitAuraCircle:Destroy()
	gladCircle:Destroy()
	deathreq.Parent = game.ReplicatedStorage.Remotes
	if CurrentWeld then
		CurrentWeld:Destroy()
		workspace.Camera.CameraSubject = localplr.Character and localplr.Character.Humanoid
	end
	if oldfunc1 then require(localplr.PlayerScripts.Client.Character.JumpFatigue).GetCanFatigue = oldfunc1 end
	if oldfunc2 then require(localplr.PlayerScripts.Client.Game.NoWallhop).GetIsOnGround = oldfunc2 end
	if oldfunc3 then require(localplr.PlayerScripts.Client.Game.FallDamage).GetFallDamage = oldfunc3 end
	if oldfunc4 then require(game.ReplicatedStorage.Packages.Ragdoll).EnableCharacterRagdoll = oldfunc4 end
	if oldfunc5 then require(game.ReplicatedStorage.Packages.Ragdoll).StunCharacter = oldfunc5 end
	ballGui:Destroy()
end
