getgenv().deletewhendupefound = true

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Zombies Vs Humans",
    Icon = "lucide-skull",
    Folder = "ZVH_CN",
    Size = UDim2.fromOffset(640, 500),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = false,
})

local MainTab     = Window:Tab({ Title = "主菜单",   Icon = "lucide-home" })
local MovementTab = Window:Tab({ Title = "移动",     Icon = "lucide-move-3d" })
local EspTab      = Window:Tab({ Title = "ESP",      Icon = "lucide-eye" })
local HitboxTab   = Window:Tab({ Title = "碰撞箱",   Icon = "lucide-box" })
local AntiTab     = Window:Tab({ Title = "防封",     Icon = "lucide-shield" })
local WeldTab     = Window:Tab({ Title = "人体焊接", Icon = "lucide-link" })
local OtherTab    = Window:Tab({ Title = "其他脚本", Icon = "lucide-file-code" })

local localplr = game.Players.LocalPlayer
local on = true
local toc = {}
local CurrentWeld = nil

local function setPara(obj, title, desc)
    if not obj then return end
    local ok = pcall(function() obj:SetTitle(title) end)
    if not ok then ok = pcall(function() obj:SetDesc(title) end) end
    if not ok then pcall(function() obj:Update({ Title = title }) end) end
    if desc ~= nil then pcall(function() obj:SetDesc(desc) end) end
end

MainTab:Section({ Title = "警告" })
MainTab:Paragraph({
    Title = "⚠️ 警告",
    Desc = "所有这些功能都可能导致你被封禁！该游戏在 Discord 上有举报系统，如果你有大量进度，请勿作弊！",
})

MainTab:Section({ Title = "状态" })
local currposl = MainTab:Paragraph({ Title = "当前位置：等待中...", Desc = "" })
local cfrcheckl = MainTab:Paragraph({ Title = "死亡幅度（达到 0 = 反作弊死亡）：", Desc = "..." })

MainTab:Section({ Title = "攻击" })

local ha = false
MainTab:Toggle({ Title = "攻击光环", Default = false, Callback = function(b) ha = b end })

local bha = false
local bhas = 20
local newprt = Instance.new("Part")
newprt.Size = Vector3.new(bhas * 2, bhas * 2, bhas * 2)
newprt.Anchored = true
newprt.Transparency = 1
newprt.CanCollide = false
newprt.Shape = Enum.PartType.Ball
newprt.Parent = workspace

MainTab:Toggle({
    Title = "方块攻击光环（掘墓人）",
    Default = false,
    Callback = function(b)
        bha = b
        newprt.Transparency = b and 0.8 or 1
    end,
})

MainTab:Slider({
    Title = "方块攻击光环大小", Step = 1,
    Value = { Min = 0, Max = 20, Default = 20 },
    Callback = function(n) bhas = n; newprt.Size = Vector3.new(n*2, n*2, n*2) end,
})

local gha = false
MainTab:Toggle({ Title = "充能攻击光环（角斗士）（已损坏）", Default = false, Callback = function(b) gha = b end })

MainTab:Section({ Title = "其他" })

MainTab:Input({
    Title = "设置剑冷却时间", Value = "", Placeholder = "输入数字，如 0.1",
    Callback = function(txt)
        txt = tonumber(txt)
        if not txt then return end
        pcall(function()
            for _, v in pairs(game:GetService("ReplicatedStorage").Modules.ItemData:GetChildren()) do
                if v:IsA("ModuleScript") then
                    local r = require(v)
                    if r.Swings then
                        for _, v2 in pairs(r.Swings) do v2.SwingCooldown = txt end
                    end
                end
            end
        end)
    end,
})

local nofog = false
MainTab:Toggle({ Title = "无雾", Default = false, Callback = function(b) nofog = b end })

local comb = 0
function addcomb() comb = comb + 1; if comb > 3 then comb = 1 end end

function getmelee()
    local sword = nil
    for _, v in pairs(localplr.Backpack:GetChildren()) do
        if v:IsA("Tool") and (string.find(v.Name, "Sword") or string.find(v.Name:lower(), "axe") or string.find(v.Name, "Dagger") or string.find(v.Name, "Hammer") or v.Name == "Trident") then
            sword = v; v.Parent = localplr.Character
        end
    end
    if not sword and localplr.Character then
        for _, v in pairs(localplr.Character:GetChildren()) do
            if v:IsA("Tool") and (string.find(v.Name, "Sword") or string.find(v.Name:lower(), "axe") or string.find(v.Name, "Dagger") or string.find(v.Name, "Hammer") or v.Name == "Trident") then
                sword = v
            end
        end
    end
    return sword
end

local swordcooldowns = {
    WoodenSword=0.35, Trident=0.85, StoneSword=0.425, GravediggersPickaxe=2.2,
    ObsidianHammer=1.4, IronSword=0.525, GladiatorsSword=2, FlintDagger=0.2,
    EmeraldAxe=1.5, DiamondSword=0.8,
}
local partdelays = {}
function adelay(part, checksword)
    partdelays[part] = true
    if typeof(checksword) == "Instance" then
        checksword = swordcooldowns[checksword.Name] and swordcooldowns[checksword.Name]/9
    end
    task.delay((typeof(checksword) == "Number" and checksword) or 0.1, function() partdelays[part] = nil end)
end
function checkdelay(part) return partdelays[part] == nil end

local ii = game.ReplicatedStorage.Remotes.ItemInteract
local proj = workspace.Projectiles
local graves = workspace.Graves
local blocks = workspace.Blocks
local supportsgpip = workspace.GetPartsInPart ~= nil
local speed = nil

local ors = game:GetService("RunService").RenderStepped:Connect(function()
    debug.profilebegin("ZVHRenderStepped")
    if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
        local pos = localplr.Character.HumanoidRootPart.Position
        pos = Vector3.new(math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
        setPara(currposl, "当前位置：" .. tostring(pos))

        local v1 = (750 - math.abs(pos.X))
        local v2 = (800 - math.abs(pos.Y))
        local v3 = (900 - math.abs(pos.Z))
        local dm = math.min(v1, v2, v3)
        setPara(cfrcheckl, "死亡幅度（达到 0 = 反作弊死亡）：" .. tostring(dm) .. " | " .. v1 .. ", " .. v2 .. ", " .. v3)
    end
    if speed and localplr.Character and localplr.Character:FindFirstChild("Humanoid") then
        localplr.Character.Humanoid.WalkSpeed = speed
    end
    if nofog and game.Lighting:FindFirstChild("Atmosphere") then
        game.Lighting.Atmosphere.Density = 0
    end
    if ha or bha then
        local sword = getmelee()
        if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
            if ha and sword then
                if not gha or sword.Name ~= "GladiatorsSword" then
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v ~= localplr and v.Team ~= localplr.Team and v.Character and checkdelay(v.Character)
                        and v.Character:FindFirstChild("HumanoidRootPart")
                        and (v.Character.HumanoidRootPart.Position - localplr.Character.HumanoidRootPart.Position).Magnitude < 20
                        and v.Character.Humanoid.Health > 0 then
                            adelay(v.Character, sword)
                            -- 修复卡顿：将等待放入协程中
                            coroutine.wrap(function() 
                                addcomb()
                                ii:InvokeServer(sword, "Hit", v.Character, comb) 
                                task.wait(0.05)
                            end)()
                        end
                    end
                end
                for _, v in pairs(proj:GetChildren()) do
                    if v:IsA("BasePart") and checkdelay(v)
                    and (v.Position - localplr.Character.HumanoidRootPart.Position).Magnitude < 40 then
                        if v.Name ~= "Cannonball" then continue end
                        adelay(v, 0.05)
                        coroutine.wrap(function() addcomb(); ii:InvokeServer(sword, "ProjectileHit", v, comb) end)()
                    end
                end
                for _, v in pairs(graves:GetChildren()) do
                    if checkdelay(v) and (((v:IsA("BasePart") and v.CFrame) or (v:IsA("Model") and v:GetPivot())).Position - localplr.Character.HumanoidRootPart.Position).Magnitude < 20 then
                        adelay(v, sword)
                        coroutine.wrap(function() addcomb(); ii:InvokeServer(sword, "GraveHit", v, comb) end)()
                    end
                end
            end
            if bha and sword and sword.Name == "GravediggersPickaxe" then
                if supportsgpip then
                    newprt.CFrame = localplr.Character.HumanoidRootPart.CFrame
                    for _, v in pairs(workspace:GetPartsInPart(newprt)) do
                        if v:IsDescendantOf(blocks) and v:IsA("BasePart") and checkdelay(v) then
                            adelay(v, 0.5)
                            if v.Name == "Root" then v = v.Parent end
                            coroutine.wrap(function() addcomb(); pcall(function() ii:InvokeServer(sword, "BlockHit", v, comb) end) end)()
                        end
                    end
                else
                    for _, v in pairs(blocks:GetChildren()) do
                        if v:IsA("BasePart") and (v.Position - localplr.Character.HumanoidRootPart.Position).Magnitude < bhas and checkdelay(v) then
                            adelay(v, 0.5); addcomb()
                            coroutine.wrap(function() ii:InvokeServer(sword, "BlockHit", v, comb) end)()
                        end
                    end
                end
            end
        end
    end
    debug.profileend()
end)

MovementTab:Button({
    Title = "反卡住（向上传送）",
    Callback = function()
        if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
            localplr.Character.HumanoidRootPart.CFrame = localplr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 40, 0)
            localplr.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end,
})
MovementTab:Paragraph({ Title = "人类最快速度：26（建造回合：30）" })
MovementTab:Paragraph({ Title = "僵尸最快速度：28（冲锋者为 32）" })

local speedInited = false
MovementTab:Slider({
    Title = "速度（已修补）", Step = 1,
    Value = { Min = 18, Max = 32, Default = 18 },
    Callback = function(n)
        if not speedInited then speedInited = true; return end
        speed = math.floor(n)
    end,
})

local zesp, hesp = false, false
local phl = {}
local hlf = Instance.new("Folder"); hlf.Name = "hls"; hlf.Parent = game.CoreGui

function doplr(plr)
    local dochar
    if plr == localplr then
        dochar = function(c)
            local h = c:WaitForChild("Humanoid")
            h.Died:Connect(function()
                if CurrentWeld then
                    task.wait(3); CurrentWeld:Destroy()
                    if c and c:FindFirstChild("Humanoid") then workspace.Camera.CameraSubject = c.Humanoid end
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
            highlight.OutlineColor = plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255,255,255)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = c
            local bbgui = nil
            if team == game.Teams.Humans and hesp then
                highlight.Enabled = true
            elseif team == game.Teams.Monsters and zesp then
                highlight.Enabled = true
                bbgui = Instance.new("BillboardGui")
                bbgui.Size = UDim2.new(10,0,1.5,0); bbgui.StudsOffset = Vector3.new(0,3.5,0)
                bbgui.Adornee = c:WaitForChild("Head",10); bbgui.AlwaysOnTop = true; bbgui.Parent = highlight
                local txt = Instance.new("TextLabel")
                txt.TextScaled = true; txt.BackgroundTransparency = 1
                txt.Size = UDim2.new(0,100,0,20)
                txt.TextStrokeTransparency = 0; txt.TextStrokeColor3 = Color3.fromRGB(255,255,255)
                txt.Text = ""; txt.TextColor3 = Color3.fromRGB(255,255,255)
                txt.TextXAlignment = Enum.TextXAlignment.Center; txt.Parent = bbgui
                local function detect(toolName, label, color)
                    coroutine.wrap(function()
                        local t1 = c:WaitForChild(toolName, 5)
                        local t2
                        if not t1 then t2 = plr.Backpack:WaitForChild(toolName, 5) end
                        if t1 or t2 then txt.Text = label; txt.TextColor3 = color end
                    end)()
                end
                detect("Bomb", "炸弹人", Color3.fromRGB(0,0,0))
                detect("Dynamite", "冲锋者", Color3.fromRGB(255,155,0))
                detect("Cannon", "炮手", Color3.fromRGB(60,60,60))
                detect("GravediggersPickaxe", "掘墓人", Color3.fromRGB(0,150,0))
                detect("GladiatorsSword", "角斗士", Color3.fromRGB(200,0,0))
                detect("HuntersBow", "猎人", Color3.fromRGB(0,200,200))
            else
                highlight.Enabled = false
            end
            phl[highlight] = { tn = team and team.Name, p = plr, c = c, bb = bbgui }
        end
    end
    if plr.Character then dochar(plr.Character) end
    table.insert(toc, plr.CharacterAdded:Connect(dochar))
    table.insert(toc, plr.CharacterRemoving:Connect(function(c)
        for i, v in pairs(phl) do
            if v.c == c then phl[i] = nil; i:Destroy() end
        end
    end))
end

for _, v in pairs(game.Players:GetPlayers()) do doplr(v) end
table.insert(toc, game.Players.PlayerAdded:Connect(doplr))

EspTab:Toggle({
    Title = "人类 ESP", Default = false,
    Callback = function(b)
        hesp = b
        for i, v in pairs(phl) do
            if v.tn == "Humans" then i.Enabled = hesp; if v.bb then v.bb.Enabled = hesp end end
        end
    end,
})
EspTab:Toggle({
    Title = "僵尸 ESP", Default = false,
    Callback = function(b)
        zesp = b
        for i, v in pairs(phl) do
            if v.tn == "Monsters" then i.Enabled = zesp; if v.bb then v.bb.Enabled = zesp end end
        end
    end,
})

local otc = localplr:GetPropertyChangedSignal("Team"):Connect(function()
    for i, v in pairs(phl) do
        i.FillColor = (v.p.Team ~= localplr.Team and Color3.fromRGB(255,0,0)) or Color3.fromRGB(0,255,0)
    end
end)

local HB_Players = game:GetService("Players")
local HB_RunService = game:GetService("RunService")
local HB_LP = HB_Players.LocalPlayer

local HB_CONFIG = {
    Size = 10,
    Transparency = 0.5,
    Color = Color3.fromRGB(150, 150, 150),
    TargetParts = {"HumanoidRootPart"}
}

local HitboxOrig = {}
local HitboxVisuals = {}
local hb_enabled = false
local hb_conn = nil

local function saveOrig(char)
    local data = HitboxOrig[char]
    if not data then
        data = {}
        HitboxOrig[char] = data
    end
    for _, name in ipairs(HB_CONFIG.TargetParts) do
        if data[name] then continue end
        local part = char:FindFirstChild(name)
        if part then
            data[name] = { Size = part.Size }
        end
    end
end

local function hbApply(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    saveOrig(char)
    
    local sz = Vector3.new(HB_CONFIG.Size, HB_CONFIG.Size, HB_CONFIG.Size)
    for _, name in ipairs(HB_CONFIG.TargetParts) do
        local part = char:FindFirstChild(name)
        if part then
            if part.Size ~= sz then
                part.Size = sz
            end
            
            local visual = HitboxVisuals[char]
            if not visual or not visual.Parent then
                visual = Instance.new("BoxHandleAdornment")
                visual.Adornee = part
                visual.AlwaysOnTop = false
                visual.ZIndex = 5
                visual.Parent = game.CoreGui
                HitboxVisuals[char] = visual
            end
            
            if visual.Size ~= sz then visual.Size = sz end
            if visual.Color3 ~= HB_CONFIG.Color then visual.Color3 = HB_CONFIG.Color end
            if visual.Transparency ~= HB_CONFIG.Transparency then visual.Transparency = HB_CONFIG.Transparency end
        end
    end
end

local function hbReset(char)
    local data = HitboxOrig[char]
    if data then
        for name, orig in pairs(data) do
            local part = char:FindFirstChild(name)
            if part then
                part.Size = orig.Size
            end
        end
        HitboxOrig[char] = nil
    end
    
    local visual = HitboxVisuals[char]
    if visual then
        visual:Destroy()
        HitboxVisuals[char] = nil
    end
end

local function hbRefresh()
    for _, plr in ipairs(HB_Players:GetPlayers()) do
        if plr ~= HB_LP and plr.Character then
            hbApply(plr.Character)
        end
    end
end

local function hbSetEnabled(on)
    hb_enabled = on
    if hb_conn then hb_conn:Disconnect(); hb_conn = nil end
    if not on then
        local chars = {}
        for char in pairs(HitboxOrig) do table.insert(chars, char) end
        for _, char in ipairs(chars) do hbReset(char) end
        return
    end
    hbRefresh()
    hb_conn = HB_RunService.RenderStepped:Connect(function()
        if not hb_enabled then return end
        for _, plr in ipairs(HB_Players:GetPlayers()) do
            if plr ~= HB_LP and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then
                    hbReset(plr.Character)
                else
                    hbApply(plr.Character)
                end
            end
        end
        for c, v in pairs(HitboxVisuals) do
            if not v.Parent or not v.Adornee or not v.Adornee.Parent or not c or not c.Parent then
                if v then v:Destroy() end
                HitboxVisuals[c] = nil
                HitboxOrig[c] = nil
            end
        end
    end)
end

local function hbPlayerAdded(player)
    if player == HB_LP then return end
    if hb_enabled and player.Character then
        task.spawn(function() hbApply(player.Character) end)
    end
    table.insert(toc, player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if hb_enabled then hbApply(char) end
    end))
    table.insert(toc, player.CharacterRemoving:Connect(function(char)
        hbReset(char)
    end))
end

for _, plr in ipairs(HB_Players:GetPlayers()) do hbPlayerAdded(plr) end
table.insert(toc, HB_Players.PlayerAdded:Connect(hbPlayerAdded))
table.insert(toc, HB_Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        hbReset(player.Character)
    end
end))

HitboxTab:Toggle({
    Title = "启用碰撞箱",
    Default = false,
    Callback = function(bool)
        hbSetEnabled(bool)
    end,
})

HitboxTab:Slider({
    Title = "碰撞箱大小",
    Step = 1,
    Value = { Min = 1, Max = 50, Default = 10 },
    Callback = function(n)
        HB_CONFIG.Size = n
        if hb_enabled then hbRefresh() end
    end,
})

HitboxTab:Slider({
    Title = "范围透明度",
    Step = 0.1,
    Value = { Min = 0, Max = 1, Default = 0.5 },
    Callback = function(n)
        HB_CONFIG.Transparency = n
        if hb_enabled then hbRefresh() end
    end,
})

HitboxTab:Colorpicker({
    Title = "范围颜色",
    Default = Color3.fromRGB(150, 150, 150),
    Callback = function(color)
        HB_CONFIG.Color = color
        if hb_enabled then hbRefresh() end
    end,
})

local oldfunc1, oldfunc2, oldfunc3, oldfunc4, oldfunc5 = nil, nil, nil, nil, nil
local antij, antiwh, antifm, antifd, antird, antisc, antikb = false, false, false, false, false, false, false

AntiTab:Toggle({
    Title = "反跳跃疲劳", Default = false,
    Callback = function(b)
        antij = b
        pcall(function()
            local r = require(localplr.PlayerScripts.Client.Character.JumpFatigue)
            if antij then oldfunc1 = r.GetCanFatigue; r.GetCanFatigue = function() end
            else r.GetCanFatigue = oldfunc1 end
        end)
    end,
})

AntiTab:Toggle({
    Title = "反反爬墙", Default = false,
    Callback = function(b)
        antiwh = b
        pcall(function()
            local r = require(localplr.PlayerScripts.Client.Game.NoWallhop)
            if antiwh then oldfunc2 = r.GetIsOnGround; r.GetIsOnGround = function() return true end
            else r.GetIsOnGround = oldfunc2 end
        end)
    end,
})

local deathreq = game.ReplicatedStorage.Remotes:WaitForChild("RequestThyDeath")
AntiTab:Toggle({
    Title = "反反飞行机器", Default = false,
    Callback = function(b)
        antifm = b
        if antifm then deathreq.Parent = workspace
        else deathreq.Parent = game.ReplicatedStorage.Remotes end
    end,
})

AntiTab:Toggle({
    Title = "反坠落伤害", Default = false,
    Callback = function(b)
        antifd = b
        pcall(function()
            local r = require(localplr.PlayerScripts.Client.Game.FallDamage)
            if antifd then oldfunc3 = r.GetFallDamage; r.GetFallDamage = function() return 0 end
            else r.GetFallDamage = oldfunc3 end
        end)
    end,
})

AntiTab:Toggle({
    Title = "反布娃娃（有时无效）", Default = false,
    Callback = function(b)
        antird = b
        pcall(function()
            local r = require(game.ReplicatedStorage.Packages.Ragdoll)
            if antird then
                oldfunc4 = r.EnableCharacterRagdoll; r.EnableCharacterRagdoll = function() end
                oldfunc5 = r.StunCharacter; r.StunCharacter = function() end
                task.spawn(function()
                    while antird do
                        task.wait()
                        if localplr.Character then
                            pcall(function() r:DisableCharacterRagdoll(localplr.Character) end)
                            pcall(function() r:CancelCharacterStun(localplr.Character) end)
                        end
                    end
                end)
            else
                r.EnableCharacterRagdoll = oldfunc4; r.StunCharacter = oldfunc5
            end
        end)
    end,
})

local scaffoldblocks = {}
AntiTab:Toggle({
    Title = "僵尸攀爬脚手架", Default = false,
    Callback = function(b)
        antisc = b
        for blk, o in pairs(scaffoldblocks) do
            if not blk or not blk.Parent then scaffoldblocks[blk] = nil
            else blk[o[1]] = (antisc and o[3]) or o[2] end
        end
    end,
})

function doblock(b)
    if not b or not b.Parent then return end
    if b.Name == "Scaffold" or b.Name == "Truss" then
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

AntiTab:Toggle({
    Title = "禁用击杀砖",
    Desc = "远离岛屿过远或在水中停留超过 3 秒将会死亡",
    Default = false,
    Callback = function(b)
        antikb = b
        for _, v in pairs(workspace.Map.KillZones:GetChildren()) do v.CanTouch = not antikb end
    end,
})

WeldTab:Paragraph({ Title = "⚠️ 注意", Desc = "此方法很可能会被修补，请尽快使用！" })
WeldTab:Paragraph({ Title = "焊接方法最初由 Failedmite 和 Janmandio 发现" })
WeldTab:Paragraph({ Title = "代码取自 Infinite Yield 中的 \"Welder V2\" 插件" })
WeldTab:Paragraph({ Title = "如果你使用的是 Xeno 或 Solara 之类的执行器，请开启低 sUNC 支持" })

local lss = false
WeldTab:Toggle({ Title = "低 sUNC 支持", Default = false, Callback = function(b) lss = b end })
local killweld = false
WeldTab:Toggle({ Title = "（几乎）瞬间击杀（不会获得分数）", Default = false, Callback = function(b) killweld = b end })

local weldoffsetx, weldoffsety, weldoffsetz = 0, 0, 0
WeldTab:Slider({ Title = "焊接偏移（X）", Step = 1, Value = { Min = -20, Max = 20, Default = 0 }, Callback = function(n) weldoffsetx = math.floor(n) end })
WeldTab:Slider({ Title = "焊接偏移（Y）", Step = 1, Value = { Min = -20, Max = 20, Default = 0 }, Callback = function(n) weldoffsety = math.floor(n) end })
WeldTab:Slider({ Title = "焊接偏移（Z）", Step = 1, Value = { Min = -20, Max = 20, Default = 0 }, Callback = function(n) weldoffsetz = math.floor(n) end })

local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Players = game.Players
local RenderStepped = RunService.RenderStepped

local WELD_GROUP = (function()
    local buff = buffer.create(20)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    for i = 1, 20 do
        buffer.writeu8(buff, i-1, string.byte(charset, math.random(1, #charset)))
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
        local H = Part.Parent:FindFirstChildWhichIsA("Humanoid")
        workspace.Camera.CameraSubject = H
        if H then H.RequiresNeck = false end
    end
    local Character = Speaker.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return nil end
    local Root = Character.HumanoidRootPart.AssemblyRootPart
    local Start = CFrame.new(Root.Position)
    local Weld = {}; local Enabled = false
    local PartJoints = {}; local OldProps = {}; local OldCharProps = {}; local AnimTrack = nil
    if AnimationId then
        local Animator = Character:FindFirstChildWhichIsA("Animator", true)
        if Animator then
            local Animation = Instance.new("Animation")
            Animation.AnimationId = "rbxassetid://" .. tostring(AnimationId)
            AnimTrack = Animator:LoadAnimation(Animation); AnimTrack:Play()
        end
    end
    Weld.Velocity = (killweld and Vector3.new(0,10000,0)) or Vector3.zero
    function Weld:Enable(t)
        Enabled = t
        if not t then
            for _, J in next, PartJoints do J.Enabled = true end
            for P, V in next, OldProps do Part[P] = V end
            for part, props in next, OldCharProps do
                if part and part.Parent then part.CollisionGroup = props.Group; part.CanCollide = props.Collide end
            end
            return
        end
        PartJoints = Part:GetJoints()
        for _, P in next, { "Size","CanCollide","Anchored","Parent","CollisionGroup" } do OldProps[P] = Part[P] end
        for _, p in next, Character:GetDescendants() do
            if p:IsA("BasePart") then
                OldCharProps[p] = { Group = p.CollisionGroup, Collide = p.CanCollide }
                p.CollisionGroup = WELD_GROUP; p.CanCollide = true
            end
        end
        Part.Size = Vector3.new(25,3,25); Part.Anchored = false; Part.CanCollide = true
        Part.CollisionGroup = WELD_GROUP; Part.Parent = workspace.Terrain
        for _, J in next, PartJoints do J.Enabled = false end
    end
    local thread = nil
    function Weld:Destroy()
        task.cancel(thread); Weld:Enable(false)
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
            Root.CFrame = Start * CFrame.new(0,4,0)
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
    if not Root then return nil end
    local AnimTrack = nil
    if AnimationId then
        local Animator = Character:FindFirstChildWhichIsA("Animator", true)
        if Animator then
            local Animation = Instance.new("Animation")
            Animation.AnimationId = "rbxassetid://" .. tostring(AnimationId)
            AnimTrack = Animator:LoadAnimation(Animation); AnimTrack:Play()
        end
    end
    local Weld = {}; local Connection = nil
    local OldCharProps = {}
    for _, v in pairs(Character:GetDescendants()) do
        if v:IsA("BasePart") then 
            OldCharProps[v] = { Collide = v.CanCollide }
            v.CanCollide = false; v.Massless = true 
        end
    end
    Connection = RunService.Heartbeat:Connect(function()
        if not Character.Parent or not TargetPart.Parent then
            if Weld.Destroy then Weld:Destroy() end; return
        end
        Root.CFrame = TargetPart.CFrame * CFrame.new(weldoffsetx, weldoffsety, weldoffsetz)
        Root.AssemblyLinearVelocity = (killweld and Vector3.new(0,10000,0)) or Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
        if sethiddenproperty then pcall(function() sethiddenproperty(Root, "PhysicsRepRootPart", TargetPart) end) end
    end)
    function Weld:Destroy()
        if Connection then Connection:Disconnect() end
        if AnimTrack then AnimTrack:Stop(); AnimTrack:Destroy() end
        if Root then Root.AssemblyLinearVelocity = Vector3.zero; Root.AssemblyAngularVelocity = Vector3.zero end
        -- 修复解除焊接后卡地板的 Bug
        for part, props in pairs(OldCharProps) do
            if part and part.Parent then
                part.CanCollide = props.Collide
            end
        end
    end
    return Weld
end

WeldTab:Button({
    Title = "焊接到随机人类",
    Callback = function()
        if CurrentWeld then CurrentWeld:Destroy() end
        local hrp = nil
        repeat
            task.wait()
            if #game.Teams.Humans:GetPlayers() > 0 + ((localplr.Team == game.Teams.Humans and 1) or 0) then
                local rp = game.Teams.Humans:GetPlayers()[math.random(1, #game.Teams.Humans:GetPlayers())]
                if rp ~= localplr and rp.Character and rp.Character:FindFirstChild("HumanoidRootPart") then hrp = rp.Character.HumanoidRootPart end
            else break end
        until hrp
        if hrp then CurrentWeld = (lss and LowsUNCWeldTo or WeldTo)(hrp, localplr, 0) end
    end,
})
WeldTab:Button({
    Title = "焊接到随机僵尸",
    Callback = function()
        if CurrentWeld then CurrentWeld:Destroy() end
        local hrp = nil
        repeat
            task.wait()
            if #game.Teams.Monsters:GetPlayers() > 0 + ((localplr.Team == game.Teams.Monsters and 1) or 0) then
                local rp = game.Teams.Monsters:GetPlayers()[math.random(1, #game.Teams.Monsters:GetPlayers())]
                if rp ~= localplr and rp.Character and rp.Character:FindFirstChild("HumanoidRootPart") then hrp = rp.Character.HumanoidRootPart end
            else break end
        until hrp
        if hrp then CurrentWeld = (lss and LowsUNCWeldTo or WeldTo)(hrp, localplr, 0) end
    end,
})
WeldTab:Input({
    Title = "焊接到玩家", Value = "", Placeholder = "输入玩家名字前缀",
    Callback = function(plrname)
        if not plrname or plrname == "" then return end
        if CurrentWeld then CurrentWeld:Destroy() end
        local hrp = nil
        for _, v in pairs(game.Players:GetPlayers()) do
            if (string.sub(v.DisplayName,1,#plrname):lower() == plrname:lower() or string.sub(v.Name,1,#plrname):lower() == plrname:lower())
            and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                hrp = v.Character.HumanoidRootPart
            end
        end
        if hrp then CurrentWeld = (lss and LowsUNCWeldTo or WeldTo)(hrp, localplr, 0) end
    end,
})
WeldTab:Button({
    Title = "取消焊接",
    Callback = function()
        if CurrentWeld then
            CurrentWeld:Destroy()
            if localplr.Character and localplr.Character:FindFirstChild("Humanoid") then
                workspace.Camera.CameraSubject = localplr.Character.Humanoid
            end
        end
    end,
})

OtherTab:Button({
    Title = "执行 Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
})
OtherTab:Button({
    Title = "执行念力脚本",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Telekinesis-WIP-240257"))()
    end,
})

if game:GetService("ReplicatedStorage").Remotes:FindFirstChild("ConsoleLog") then
    game:GetService("ReplicatedStorage").Remotes.ConsoleLog:Destroy()
    local fcl = Instance.new("RemoteFunction"); fcl.Name = "ConsoleLog"
    fcl.Parent = game:GetService("ReplicatedStorage").Remotes
end

local function cleanup()
    on = false
    ha = false; bha = false; gha = false
    antisc = false; antird = false
    hb_enabled = false
    if hb_conn then hb_conn:Disconnect() end
    local chars = {}
    for char in pairs(HitboxOrig) do table.insert(chars, char) end
    for _, char in ipairs(chars) do hbReset(char) end
    for c, v in pairs(HitboxVisuals) do
        if v then v:Destroy() end
    end
    HitboxVisuals = {}
    HitboxOrig = {}
    if hlf then hlf:Destroy() end
    if otc then otc:Disconnect() end
    if ors then ors:Disconnect() end
    for _, v in pairs(toc) do pcall(function() v:Disconnect() end) end
    for _, v in pairs(workspace.Map.KillZones:GetChildren()) do v.CanTouch = true end
    if localplr.PlayerGui:FindFirstChild("Overlay") then localplr.PlayerGui.Overlay.Enabled = true end
    newprt:Destroy()
    deathreq.Parent = game.ReplicatedStorage.Remotes
    if CurrentWeld then
        CurrentWeld:Destroy()
        if localplr.Character and localplr.Character:FindFirstChild("Humanoid") then
            workspace.Camera.CameraSubject = localplr.Character.Humanoid
        end
    end
    if oldfunc1 then pcall(function() require(localplr.PlayerScripts.Client.Character.JumpFatigue).GetCanFatigue = oldfunc1 end) end
    if oldfunc2 then pcall(function() require(localplr.PlayerScripts.Client.Game.NoWallhop).GetIsOnGround = oldfunc2 end) end
    if oldfunc3 then pcall(function() require(localplr.PlayerScripts.Client.Game.FallDamage).GetFallDamage = oldfunc3 end) end
    if oldfunc4 then pcall(function() require(game.ReplicatedStorage.Packages.Ragdoll).EnableCharacterRagdoll = oldfunc4 end) end
    if oldfunc5 then pcall(function() require(game.ReplicatedStorage.Packages.Ragdoll).StunCharacter = oldfunc5 end) end
end

if not pcall(function() Window:OnDestroy(cleanup) end) then
    if not pcall(function() Window:OnClose(cleanup) end) then
        if not pcall(function() Window:OnDestroying(cleanup) end) then
            pcall(function() game.CoreGui.ChildRemoved:Connect(function(c) if c:IsDescendantOf(Window.Gui or workspace) then cleanup() end end) end)
        end
    end
end
