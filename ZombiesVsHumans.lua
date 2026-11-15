local ZvmUI={}
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local PresetThemes={Purple={Accent=Color3.fromRGB(124,108,255),AccentSoft=Color3.fromRGB(162,136,255)},Blue={Accent=Color3.fromRGB(65,145,255),AccentSoft=Color3.fromRGB(120,180,255)},Green={Accent=Color3.fromRGB(65,200,115),AccentSoft=Color3.fromRGB(120,230,160)},Red={Accent=Color3.fromRGB(240,75,75),AccentSoft=Color3.fromRGB(255,120,120)},Orange={Accent=Color3.fromRGB(255,150,50),AccentSoft=Color3.fromRGB(255,190,110)}}
local Theme={Background=Color3.fromRGB(19,19,27),BackgroundTop=Color3.fromRGB(31,30,45),Surface=Color3.fromRGB(31,31,44),SurfaceHover=Color3.fromRGB(44,44,62),Track=Color3.fromRGB(48,48,68),Accent=PresetThemes.Purple.Accent,AccentSoft=PresetThemes.Purple.AccentSoft,Text=Color3.fromRGB(238,238,248),SubText=Color3.fromRGB(150,150,180),Stroke=Color3.fromRGB(58,58,84)}
ZvmUI.Theme=Theme
local Animator={} Animator.__index=Animator
local animators={} local loopConnection=nil
local function stepAnimators(dt)
dt=math.min(dt,1/30) local dead=nil
for a in pairs(animators) do
if not a.Object or not a.Object.Parent then dead=dead or {} dead[#dead+1]=a continue end
if not a.Active then continue end
local moving=false local springs=a.Springs
for i=1,#springs do
local s=springs[i] local diff=s.Target-s.Value
if math.abs(diff)>0.00005 or math.abs(s.Velocity)>0.00005 then local accel=diff*a.Stiffness-s.Velocity*a.Damping s.Velocity=s.Velocity+accel*dt s.Value=s.Value+s.Velocity*dt moving=true else s.Value=s.Target s.Velocity=0 end
end
a:Write() if not moving then a.Active=false end
end
if dead then for _,a in ipairs(dead) do animators[a]=nil end end
end
function Animator.new(object,property,stiffness,damping,clampMin)
local self=setmetatable({},Animator) self.Object=object self.Property=property self.Stiffness=stiffness or 340 self.Damping=damping or 22 self.ClampMin=clampMin self.Active=false
local value=object[property] local kind=typeof(value) self.Kind=kind
if kind=="number" then self.Springs={{Value=value,Target=value,Velocity=0}}
elseif kind=="Color3" then self.Springs={{Value=value.R,Target=value.R,Velocity=0},{Value=value.G,Target=value.G,Velocity=0},{Value=value.B,Target=value.B,Velocity=0}}
elseif kind=="UDim2" then self.Springs={{Value=value.X.Scale,Target=value.X.Scale,Velocity=0},{Value=value.X.Offset,Target=value.X.Offset,Velocity=0},{Value=value.Y.Scale,Target=value.Y.Scale,Velocity=0},{Value=value.Y.Offset,Target=value.Y.Offset,Velocity=0}}
else self.Springs={{Value=0,Target=0,Velocity=0}} end
if not loopConnection then loopConnection=RunService.Heartbeat:Connect(stepAnimators) end
animators[self]=true return self
end
function Animator:Write()
local s=self.Springs
if self.Kind=="number" then local v=s[1].Value if self.ClampMin and v<self.ClampMin then v=self.ClampMin end self.Object[self.Property]=v
elseif self.Kind=="Color3" then self.Object[self.Property]=Color3.new(s[1].Value,s[2].Value,s[3].Value)
elseif self.Kind=="UDim2" then self.Object[self.Property]=UDim2.new(s[1].Value,s[2].Value,s[3].Value,s[4].Value) end
end
function Animator:Set(target)
local s=self.Springs
if self.Kind=="number" then s[1].Target=target
elseif self.Kind=="Color3" then s[1].Target=target.R s[2].Target=target.G s[3].Target=target.B
elseif self.Kind=="UDim2" then s[1].Target=target.X.Scale s[2].Target=target.X.Offset s[3].Target=target.Y.Scale s[4].Target=target.Y.Offset end
self.Active=true
end
function Animator:Snap(target)
self:Set(target) local s=self.Springs
for i=1,#s do s[i].Value=s[i].Target s[i].Velocity=0 end
self:Write() self.Active=false
end
local function createUICorner(parent,radius)
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,radius) corner.Parent=parent return corner
end
local function createUIStroke(parent,color,thickness,transparency)
local stroke=Instance.new("UIStroke") stroke.Color=color or Theme.Stroke stroke.Thickness=thickness or 1 stroke.Transparency=transparency or 0 stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Parent=parent return stroke
end
local function createBall(parent,size,colorA,colorB)
local ball=Instance.new("Frame") ball.Size=UDim2.fromOffset(size,size) ball.AnchorPoint=Vector2.new(0.5,0.5) ball.BackgroundColor3=colorA ball.BorderSizePixel=0 ball.ZIndex=500 ball.Parent=parent
createUICorner(ball,size) local gradient=Instance.new("UIGradient") gradient.Color=ColorSequence.new(colorA,colorB) gradient.Rotation=45 gradient.Parent=ball return ball
end
local function flyBalls(parent,origin,target,duration,onDone)
local ballA=createBall(parent,24,Theme.Accent,Theme.AccentSoft) local ballB=createBall(parent,15,Theme.AccentSoft,Theme.Accent)
local elapsed=0 local conn
conn=RunService.Heartbeat:Connect(function(dt)
if not ballA.Parent or not ballB.Parent then conn:Disconnect() return end
elapsed=elapsed+dt local raw=math.clamp(elapsed/duration,0,1) local t=1-(1-raw)^3
local cx=origin.X+(target.X-origin.X)*t local cy=origin.Y+(target.Y-origin.Y)*t
local envelope=math.sin(raw*math.pi) local amp=54*envelope local spin=raw*math.pi*2.8
local ax=math.cos(spin)*amp local ay=math.sin(spin)*amp*0.55
ballA.Position=UDim2.fromOffset(cx+ax,cy+ay) ballB.Position=UDim2.fromOffset(cx-ax,cy-ay)
local shrink=raw>0.82 and (1-(raw-0.82)/0.18) or 1
ballA.Size=UDim2.fromOffset(24*math.max(shrink,0.01),24*math.max(shrink,0.01)) ballB.Size=UDim2.fromOffset(15*math.max(shrink,0.01),15*math.max(shrink,0.01))
if raw>=1 then conn:Disconnect() ballA:Destroy() ballB:Destroy() if onDone then onDone() end end
end)
end
local function makeTitleButton(parent,text,xOffset,hoverColor)
local btn=Instance.new("TextButton") btn.Size=UDim2.fromOffset(30,30) btn.Position=UDim2.new(1,xOffset,0,17) btn.BackgroundColor3=Theme.Surface btn.Text=text btn.TextColor3=Theme.SubText btn.TextSize=13 btn.Font=Enum.Font.GothamBold btn.AutoButtonColor=false btn.BorderSizePixel=0 btn.Parent=parent
createUICorner(btn,10) local scale=Instance.new("UIScale") scale.Parent=btn
local scaleAnim=Animator.new(scale,"Scale",620,14) local bgAnim=Animator.new(btn,"BackgroundColor3",340,24) local colorAnim=Animator.new(btn,"TextColor3",340,24)
btn.MouseEnter:Connect(function() bgAnim:Set(hoverColor) colorAnim:Set(Theme.Text) scaleAnim:Set(1.08) end)
btn.MouseLeave:Connect(function() bgAnim:Set(Theme.Surface) colorAnim:Set(Theme.SubText) scaleAnim:Set(1) end)
btn.MouseButton1Down:Connect(function() scaleAnim:Set(0.86) end)
btn.MouseButton1Up:Connect(function() scaleAnim:Set(1) end)
return btn
end
local Window={} Window.__index=Window
function Window:_registerText(target,value,property,transform)
property=property or "Text" transform=transform or function(s) return s end
if type(value)=="table" then table.insert(self._localizers,{target=target,value=value,property=property,transform=transform}) target[property]=transform(value[self._locale] or value.zh or value.en or "")
else target[property]=transform(value or "") end
end
function Window:SetLocale(locale)
if locale~="zh" and locale~="en" then return end
self._locale=locale
for _,entry in ipairs(self._localizers) do
if entry.target and entry.target.Parent then entry.target[entry.property]=entry.transform(entry.value[locale] or entry.value.zh or entry.value.en or "") end
end
if self._langButton and self._langButton.Parent then self._langButton.Text=(locale=="zh") and "中" or "EN" end
end
function Window:_register(element)
self._index=self._index+1 element.LayoutOrder=self._index
local scale=Instance.new("UIScale") scale.Scale=0.8 scale.Parent=element
local anim=Animator.new(scale,"Scale",560,15)
task.delay(self._index*0.03,function() if element.Parent then anim:Set(1) end end)
return anim
end
function Window:SetTheme(themeName)
local t=PresetThemes[themeName] if not t then return end
Theme.Accent=t.Accent Theme.AccentSoft=t.AccentSoft
if self.TabHighlight then Animator.new(self.TabHighlight,"BackgroundColor3",340,24):Set(Theme.Accent) end
end
function Window:Tab(options)
options=options or {} local tabId=options.Id or tostring(math.random(1,100000))
local page=Instance.new("ScrollingFrame") page.Size=UDim2.fromScale(1,1) page.BackgroundTransparency=1 page.BorderSizePixel=0 page.ScrollBarThickness=3 page.ScrollBarImageColor3=Theme.Accent page.ScrollBarImageTransparency=0.5 page.CanvasSize=UDim2.new() page.AutomaticCanvasSize=Enum.AutomaticSize.Y page.ScrollingDirection=Enum.ScrollingDirection.Y page.Visible=false page.Parent=self.ContentContainer
self.Pages[tabId]=page
local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,10) layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=page
local padding=Instance.new("UIPadding") padding.PaddingLeft=UDim.new(0,4) padding.PaddingRight=UDim.new(0,16) padding.PaddingTop=UDim.new(0,4) padding.PaddingBottom=UDim.new(0,20) padding.Parent=page
if not self._pageAnimCache[tabId] then local pageScale=Instance.new("UIScale") pageScale.Parent=page self._pageAnimCache[tabId]={Scale=Animator.new(pageScale,"Scale",500,20),Pos=Animator.new(page,"Position",500,20)} end
local tabBtn=Instance.new("TextButton") tabBtn.Size=UDim2.new(1,-16,0,42) tabBtn.BackgroundTransparency=1 tabBtn.Text="" tabBtn.AutoButtonColor=false tabBtn.Parent=self.TabButtonsContainer
createUICorner(tabBtn,10)
local tabLabel=Instance.new("TextLabel") tabLabel.Size=UDim2.fromScale(1,1) tabLabel.BackgroundTransparency=1 tabLabel.TextColor3=Theme.SubText tabLabel.TextSize=14 tabLabel.Font=Enum.Font.GothamMedium tabLabel.TextXAlignment=Enum.TextXAlignment.Left tabLabel.Parent=tabBtn
local textPad=Instance.new("UIPadding") textPad.PaddingLeft=UDim.new(0,16) textPad.Parent=tabLabel
self:_registerText(tabLabel,options.Text or "Tab") self._tabCount=self._tabCount+1 tabBtn.LayoutOrder=self._tabCount
local textColorAnim=Animator.new(tabLabel,"TextColor3",340,24)
local function updateHighlight(instant)
if not tabBtn.Parent or not self.Sidebar.Parent then return end
local targetY=tabBtn.AbsolutePosition.Y-self.Sidebar.AbsolutePosition.Y
if instant then self.TabHighlightAnim:Snap(UDim2.fromOffset(8,targetY)) else self.TabHighlightAnim:Set(UDim2.fromOffset(8,targetY)) end
end
tabBtn.MouseButton1Click:Connect(function()
if self.ActiveTab==tabId then return end
for id,p in pairs(self.Pages) do p.Visible=false p.Position=UDim2.fromOffset(0,5) if self._pageAnimCache[id] then self._pageAnimCache[id].Scale:Set(0.95) end end
page.Visible=true self.ActiveTab=tabId self.Content=page
if self._pageAnimCache[tabId] then self._pageAnimCache[tabId].Scale:Set(1) self._pageAnimCache[tabId].Pos:Set(UDim2.fromOffset(0,0)) end
for _,otherBtn in ipairs(self.TabButtonsContainer:GetChildren()) do
if otherBtn:IsA("TextButton") then
local lbl=otherBtn:FindFirstChildOfClass("TextLabel")
if lbl then local anim=Animator.new(lbl,"TextColor3",340,24) if otherBtn==tabBtn then anim:Set(Theme.Text) else anim:Set(Theme.SubText) end end
end
end
updateHighlight(false)
if self.TabHighlight.BackgroundTransparency>0 then Animator.new(self.TabHighlight,"BackgroundTransparency",340,24):Set(0) end
end)
tabBtn.MouseEnter:Connect(function() if self.ActiveTab~=tabId then textColorAnim:Set(Theme.Text) end end)
tabBtn.MouseLeave:Connect(function() if self.ActiveTab~=tabId then textColorAnim:Set(Theme.SubText) end end)
if self._tabCount==1 then
task.defer(function()
local conn
conn=tabBtn:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
if tabBtn.AbsolutePosition.Y>0 then conn:Disconnect() updateHighlight(true) tabBtn.MouseButton1Click:Fire() self.TabHighlight.BackgroundTransparency=0 end
end)
end)
end
self.Content=page
return setmetatable({Content=page,Gui=self.Gui,_index=0,_locale=self._locale,_localizers=self._localizers,_langButton=self._langButton,_rootScaleAnim=self._rootScaleAnim,_connections=self._connections,_destroyCallbacks=self._destroyCallbacks,_registerText=self._registerText,_register=self._register},{__index=Window})
end
function Window:Button(options)
options=options or {}
local button=Instance.new("TextButton") button.Size=UDim2.new(1,0,0,42) button.BackgroundColor3=Theme.Surface button.Text="" button.AutoButtonColor=false button.BorderSizePixel=0 button.Parent=self.Content
createUICorner(button,12) local stroke=createUIStroke(button,Theme.Stroke,1)
local label=Instance.new("TextLabel") label.Size=UDim2.new(1,-28,1,0) label.Position=UDim2.fromOffset(16,0) label.BackgroundTransparency=1 label.TextColor3=Theme.Text label.TextSize=14 label.Font=Enum.Font.GothamMedium label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=button
self:_registerText(label,options.Text or "Button")
local bgAnim=Animator.new(button,"BackgroundColor3",340,24) local strokeAnim=Animator.new(stroke,"Color",340,24) local scaleAnim=self:_register(button)
button.MouseEnter:Connect(function() bgAnim:Set(Theme.SurfaceHover) strokeAnim:Set(Theme.Accent) scaleAnim:Set(1.025) end)
button.MouseLeave:Connect(function() bgAnim:Set(Theme.Surface) strokeAnim:Set(Theme.Stroke) scaleAnim:Set(1) end)
button.MouseButton1Down:Connect(function() scaleAnim:Set(0.92) end)
button.MouseButton1Up:Connect(function() scaleAnim:Set(1) end)
button.MouseButton1Click:Connect(function() if options.Callback then task.spawn(options.Callback) end end)
return button
end
function Window:Toggle(options)
options=options or {}
local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=Theme.Surface row.BorderSizePixel=0 row.Parent=self.Content
createUICorner(row,12) local stroke=createUIStroke(row,Theme.Stroke,1)
local label=Instance.new("TextLabel") label.Size=UDim2.new(1,-96,1,0) label.Position=UDim2.fromOffset(16,0) label.BackgroundTransparency=1 label.TextColor3=Theme.Text label.TextSize=14 label.Font=Enum.Font.GothamMedium label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=row
self:_registerText(label,options.Text or "Toggle")
local track=Instance.new("Frame") track.Size=UDim2.fromOffset(46,24) track.Position=UDim2.new(1,-62,0.5,-12) track.BackgroundColor3=Theme.Track track.BorderSizePixel=0 track.Parent=row
createUICorner(track,12)
local knob=Instance.new("Frame") knob.Size=UDim2.fromOffset(18,18) knob.Position=UDim2.fromOffset(3,3) knob.BackgroundColor3=Theme.SubText knob.BorderSizePixel=0 knob.Parent=track
createUICorner(knob,9)
local knobScale=Instance.new("UIScale") knobScale.Parent=knob
local bgAnim=Animator.new(row,"BackgroundColor3",340,24) local trackAnim=Animator.new(track,"BackgroundColor3",380,20) local knobPosAnim=Animator.new(knob,"Position",460,17) local knobColorAnim=Animator.new(knob,"BackgroundColor3",380,20) local knobScaleAnim=Animator.new(knobScale,"Scale",560,12) local rowScaleAnim=self:_register(row)
local value=options.Default or false
local function apply(state,instant)
if instant then trackAnim:Snap(state and Theme.Accent or Theme.Track) knobPosAnim:Snap(state and UDim2.fromOffset(25,3) or UDim2.fromOffset(3,3)) knobColorAnim:Snap(state and Color3.fromRGB(255,255,255) or Theme.SubText)
else trackAnim:Set(state and Theme.Accent or Theme.Track) knobPosAnim:Set(state and UDim2.fromOffset(25,3) or UDim2.fromOffset(3,3)) knobColorAnim:Set(state and Color3.fromRGB(255,255,255) or Theme.SubText) end
end
apply(value,true)
row.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
rowScaleAnim:Set(0.955) knobScaleAnim:Set(1.32)
task.delay(0.11,function() if row.Parent then rowScaleAnim:Set(1) end if knob.Parent then knobScaleAnim:Set(1) end end)
value=not value apply(value,false)
if options.Callback then task.spawn(options.Callback,value) end
end
end)
row.MouseEnter:Connect(function() bgAnim:Set(Theme.SurfaceHover) stroke.Color=Theme.Accent end)
row.MouseLeave:Connect(function() bgAnim:Set(Theme.Surface) stroke.Color=Theme.Stroke end)
return row
end
function Window:Slider(options)
options=options or {}
local minValue,maxValue,defaultValue=options.Min or 0,options.Max or 100,options.Default or options.Min or 0
local suffix=options.Suffix or "" local step=options.Step or 0
local container=Instance.new("Frame") container.Size=UDim2.new(1,0,0,64) container.BackgroundColor3=Theme.Surface container.BorderSizePixel=0 container.Parent=self.Content
createUICorner(container,12) local stroke=createUIStroke(container,Theme.Stroke,1)
local label=Instance.new("TextLabel") label.Size=UDim2.new(1,-110,0,20) label.Position=UDim2.fromOffset(16,12) label.BackgroundTransparency=1 label.TextColor3=Theme.Text label.TextSize=14 label.Font=Enum.Font.GothamMedium label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=container
self:_registerText(label,options.Text or "Slider")
local valueLabel=Instance.new("TextLabel") valueLabel.Size=UDim2.new(0,90,0,20) valueLabel.Position=UDim2.new(1,-106,0,12) valueLabel.BackgroundTransparency=1 valueLabel.Text=tostring(defaultValue)..suffix valueLabel.TextColor3=Theme.AccentSoft valueLabel.TextSize=14 valueLabel.Font=Enum.Font.GothamBold valueLabel.TextXAlignment=Enum.TextXAlignment.Right valueLabel.Parent=container
local track=Instance.new("Frame") track.Size=UDim2.new(1,-32,0,8) track.Position=UDim2.fromOffset(16,44) track.BackgroundColor3=Theme.Track track.BorderSizePixel=0 track.Parent=container
createUICorner(track,4)
local fill=Instance.new("Frame") fill.Size=UDim2.fromScale(0,1) fill.BackgroundColor3=Theme.Accent fill.BorderSizePixel=0 fill.Parent=track
createUICorner(fill,4)
local knob=Instance.new("Frame") knob.Size=UDim2.fromOffset(18,18) knob.AnchorPoint=Vector2.new(0.5,0.5) knob.Position=UDim2.new(0,0,0.5,0) knob.BackgroundColor3=Color3.fromRGB(255,255,255) knob.BorderSizePixel=0 knob.ZIndex=3 knob.Parent=track
createUICorner(knob,9)
local knobScale=Instance.new("UIScale") knobScale.Parent=knob
local fillAnim=Animator.new(fill,"Size",720,46) local knobAnim=Animator.new(knob,"Position",720,46) local knobScaleAnim=Animator.new(knobScale,"Scale",520,14)
self:_register(container)
local dragging=false
local function setValue(value,instant)
value=math.clamp(value,minValue,maxValue)
if step>0 then value=math.floor(value/step+0.5)*step end
local rel=(maxValue==minValue) and 0 or (value-minValue)/(maxValue-minValue)
if instant then fillAnim:Snap(UDim2.fromScale(rel,1)) knobAnim:Snap(UDim2.new(rel,0,0.5,0)) else fillAnim:Set(UDim2.fromScale(rel,1)) knobAnim:Set(UDim2.new(rel,0,0.5,0)) end
local display=(step>=1) and math.floor(value) or math.floor(value*10+0.5)/10
valueLabel.Text=tostring(display)..suffix
if options.Callback then task.spawn(options.Callback,value) end
end
setValue(defaultValue,true)
local function fromX(x) local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1) setValue(minValue+(maxValue-minValue)*rel,false) end
container.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true knobScaleAnim:Set(1.36) fromX(input.Position.X) end end)
local changedConn=UserInputService.InputChanged:Connect(function(input) if not dragging then return end if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then fromX(input.Position.X) end end)
local endedConn=UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then if dragging then dragging=false knobScaleAnim:Set(1) end end end)
container.Destroying:Connect(function() changedConn:Disconnect() endedConn:Disconnect() end)
container.MouseEnter:Connect(function() stroke.Color=Theme.Accent if not dragging then knobScaleAnim:Set(1.14) end end)
container.MouseLeave:Connect(function() stroke.Color=Theme.Stroke if not dragging then knobScaleAnim:Set(1) end end)
return container
end
function Window:Paragraph(options)
options=options or {}
local container=Instance.new("Frame") container.Size=UDim2.new(1,0,0,0) container.AutomaticSize=Enum.AutomaticSize.Y container.BackgroundTransparency=1 container.Parent=self.Content
local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,2) layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=container
local titleLabel=Instance.new("TextLabel") titleLabel.Size=UDim2.new(1,0,0,0) titleLabel.AutomaticSize=Enum.AutomaticSize.Y titleLabel.BackgroundTransparency=1 titleLabel.TextColor3=Theme.Text titleLabel.TextSize=13 titleLabel.Font=Enum.Font.GothamMedium titleLabel.TextWrapped=true titleLabel.TextXAlignment=Enum.TextXAlignment.Left titleLabel.LayoutOrder=1 titleLabel.Parent=container
local descLabel=Instance.new("TextLabel") descLabel.Size=UDim2.new(1,0,0,0) descLabel.AutomaticSize=Enum.AutomaticSize.Y descLabel.BackgroundTransparency=1 descLabel.TextColor3=Theme.SubText descLabel.TextSize=12 descLabel.Font=Enum.Font.Gotham descLabel.TextWrapped=true descLabel.TextXAlignment=Enum.TextXAlignment.Left descLabel.LayoutOrder=2 descLabel.Parent=container
if options.Title then self:_registerText(titleLabel,options.Title) end
if options.Desc then self:_registerText(descLabel,options.Desc) end
local locale=self._locale
local function pick(value) if type(value)=="table" then return value[locale] or value.zh or value.en or "" end return tostring(value or "") end
local obj={} obj.SetTitle=function(_,text) titleLabel.Text=pick(text) end obj.SetDesc=function(_,text) descLabel.Text=pick(text) end
self:_register(container) return obj
end
function Window:Colorpicker(options)
options=options or {} local currentColor=options.Default or Color3.fromRGB(150,150,150)
local row=Instance.new("TextButton") row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=Theme.Surface row.Text="" row.AutoButtonColor=false row.BorderSizePixel=0 row.Parent=self.Content
createUICorner(row,12) local stroke=createUIStroke(row,Theme.Stroke,1)
local label=Instance.new("TextLabel") label.Size=UDim2.new(1,-80,1,0) label.Position=UDim2.fromOffset(16,0) label.BackgroundTransparency=1 label.TextColor3=Theme.Text label.TextSize=14 label.Font=Enum.Font.GothamMedium label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=row
self:_registerText(label,options.Text or "Color")
local preview=Instance.new("Frame") preview.Size=UDim2.fromOffset(24,24) preview.Position=UDim2.new(1,-40,0.5,-12) preview.BackgroundColor3=currentColor preview.BorderSizePixel=0 preview.Parent=row
createUICorner(preview,6) createUIStroke(preview,Color3.fromRGB(255,255,255),1,0.6)
local bgAnim=Animator.new(row,"BackgroundColor3",340,24) self:_register(row)
row.MouseEnter:Connect(function() bgAnim:Set(Theme.SurfaceHover) stroke.Color=Theme.Accent end) row.MouseLeave:Connect(function() bgAnim:Set(Theme.Surface) stroke.Color=Theme.Stroke end)
local gui=self.Gui local overlay,popup
local function closePopup() if overlay then overlay:Destroy() overlay=nil end if popup then popup:Destroy() popup=nil end end
local function openPopup()
if popup or not gui then return end
overlay=Instance.new("TextButton") overlay.Size=UDim2.fromScale(1,1) overlay.BackgroundColor3=Color3.new(0,0,0) overlay.BackgroundTransparency=0.45 overlay.Text="" overlay.AutoButtonColor=false overlay.BorderSizePixel=0 overlay.ZIndex=600 overlay.Parent=gui overlay.MouseButton1Click:Connect(closePopup)
popup=Instance.new("Frame") popup.Size=UDim2.fromOffset(340,250) popup.AnchorPoint=Vector2.new(0.5,0.5) popup.Position=UDim2.fromScale(0.5,0.5) popup.BackgroundColor3=Theme.Surface popup.BorderSizePixel=0 popup.ZIndex=601 popup.Parent=gui
createUICorner(popup,16) createUIStroke(popup,Theme.Accent,1,0.5)
local pt=Instance.new("TextLabel") pt.Size=UDim2.new(1,-32,0,28) pt.Position=UDim2.fromOffset(16,12) pt.BackgroundTransparency=1 pt.Text="选择颜色" pt.TextColor3=Theme.Text pt.TextSize=14 pt.Font=Enum.Font.GothamBold pt.TextXAlignment=Enum.TextXAlignment.Left pt.ZIndex=602 pt.Parent=popup
local grid=Instance.new("Frame") grid.Size=UDim2.new(1,-32,1,-64) grid.Position=UDim2.fromOffset(16,48) grid.BackgroundTransparency=1 grid.ZIndex=602 grid.Parent=popup
local gl=Instance.new("UIGridLayout") gl.CellSize=UDim2.fromOffset(32,32) gl.CellPadding=UDim2.fromOffset(6,6) gl.SortOrder=Enum.SortOrder.LayoutOrder gl.Parent=grid
local PRESET_COLORS={Color3.fromRGB(255,80,80),Color3.fromRGB(255,140,80),Color3.fromRGB(255,200,80),Color3.fromRGB(200,255,80),Color3.fromRGB(140,255,120),Color3.fromRGB(80,255,180),Color3.fromRGB(80,220,255),Color3.fromRGB(120,160,255),Color3.fromRGB(160,120,255),Color3.fromRGB(220,120,255),Color3.fromRGB(255,120,200),Color3.fromRGB(255,120,140),Color3.fromRGB(255,255,255),Color3.fromRGB(220,220,220),Color3.fromRGB(180,180,180),Color3.fromRGB(140,140,140),Color3.fromRGB(100,100,100),Color3.fromRGB(60,60,60),Color3.fromRGB(30,30,30),Color3.fromRGB(0,0,0),Color3.fromRGB(255,60,180),Color3.fromRGB(60,255,220),Color3.fromRGB(255,220,60),Color3.fromRGB(160,60,255)}
for i,c in ipairs(PRESET_COLORS) do
local sw=Instance.new("TextButton") sw.Size=UDim2.fromOffset(32,32) sw.BackgroundColor3=c sw.Text="" sw.AutoButtonColor=false sw.BorderSizePixel=0 sw.ZIndex=602 sw.LayoutOrder=i sw.Parent=grid
createUICorner(sw,6) createUIStroke(sw,Color3.fromRGB(255,255,255),1,0.7)
local hoverScale=Instance.new("UIScale") hoverScale.Scale=1 hoverScale.Parent=sw
local hsAnim=Animator.new(hoverScale,"Scale",620,14)
sw.MouseEnter:Connect(function() hsAnim:Set(1.12) end) sw.MouseLeave:Connect(function() hsAnim:Set(1) end)
sw.MouseButton1Click:Connect(function() currentColor=c preview.BackgroundColor3=c if options.Callback then task.spawn(options.Callback,c) end closePopup() end)
end
end
row.MouseButton1Click:Connect(openPopup) return row
end
function Window:Label(options)
options=options or {}
local label=Instance.new("TextLabel") label.Size=UDim2.new(1,0,0,24) label.BackgroundTransparency=1 label.TextColor3=options.Color or Theme.SubText label.TextSize=options.TextSize or 13 label.Font=Enum.Font.GothamMedium label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=self.Content
self:_registerText(label,options.Text or "Label") self:_register(label) return label
end
function Window:Section(options)
options=options or {}
local frame=Instance.new("Frame") frame.Size=UDim2.new(1,0,0,28) frame.BackgroundTransparency=1 frame.Parent=self.Content
local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.TextColor3=Theme.SubText label.TextSize=11 label.Font=Enum.Font.GothamBold label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=frame
self:_registerText(label,options.Text or "SECTION","Text",string.upper) self:_register(frame) return frame
end
function Window:TextBox(options)
options=options or {}
local box=Instance.new("TextBox") box.Size=UDim2.new(1,0,0,42) box.BackgroundColor3=Theme.Surface box.BorderSizePixel=0 box.Text="" box.PlaceholderColor3=Theme.SubText box.TextColor3=Theme.Text box.TextSize=14 box.Font=Enum.Font.GothamMedium box.ClearTextOnFocus=false box.TextXAlignment=Enum.TextXAlignment.Left box.Parent=self.Content
createUICorner(box,12) local stroke=createUIStroke(box,Theme.Stroke,1)
local padding=Instance.new("UIPadding") padding.PaddingLeft=UDim.new(0,16) padding.PaddingRight=UDim.new(0,16) padding.Parent=box
self:_registerText(box,options.Placeholder or "Input...","PlaceholderText")
local bgAnim=Animator.new(box,"BackgroundColor3",340,24) local strokeAnim=Animator.new(stroke,"Color",340,24) local boxScaleAnim=self:_register(box)
box.Focused:Connect(function() bgAnim:Set(Theme.SurfaceHover) strokeAnim:Set(Theme.Accent) boxScaleAnim:Set(1.014) end)
box.FocusLost:Connect(function(enterPressed) bgAnim:Set(Theme.Surface) strokeAnim:Set(Theme.Stroke) boxScaleAnim:Set(1) if options.Callback then task.spawn(options.Callback,box.Text,enterPressed) end end)
return box
end
function Window:Divider()
local line=Instance.new("Frame") line.Size=UDim2.new(1,0,0,1) line.BackgroundColor3=Theme.Stroke line.BorderSizePixel=0 line.Parent=self.Content self:_register(line) return line
end
function Window:OnDestroy(fn) table.insert(self._destroyCallbacks,fn) end
function ZvmUI.CreateWindow(config)
config=config or {} local titleText=config.Title or "ZvmUI" local subtitleText=config.Subtitle or "" local pillText=config.PillTitle or titleText
local windowSize=config.Size or UDim2.fromOffset(600,460) local initialLocale=config.Locale or "zh"
local playerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui",10) if not playerGui then error("PlayerGui not available") end
local gui=Instance.new("ScreenGui") gui.Name="ZvmUI" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.DisplayOrder=999 gui.Parent=playerGui
local root=Instance.new("Frame") root.AnchorPoint=Vector2.new(0.5,0.5) root.Position=UDim2.fromScale(0.5,0.5) root.Size=windowSize root.BackgroundTransparency=1 root.Parent=gui
local rootScale=Instance.new("UIScale") rootScale.Scale=0 rootScale.Parent=root local rootScaleAnim=Animator.new(rootScale,"Scale",220,15,0)
local main=Instance.new("Frame") main.Size=UDim2.fromScale(1,1) main.BackgroundColor3=Theme.Background main.BorderSizePixel=0 main.ClipsDescendants=true main.Parent=root
createUICorner(main,18) createUIStroke(main,Theme.Stroke,1)
local bgGradient=Instance.new("UIGradient") bgGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Theme.BackgroundTop),ColorSequenceKeypoint.new(1,Theme.Background)}) bgGradient.Rotation=90 bgGradient.Parent=main
local titleBar=Instance.new("Frame") titleBar.Size=UDim2.new(1,0,0,64) titleBar.BackgroundTransparency=1 titleBar.Parent=main
local accentBar=Instance.new("Frame") accentBar.Size=UDim2.fromOffset(3,26) accentBar.Position=UDim2.fromOffset(14,20) accentBar.BackgroundColor3=Theme.Accent accentBar.BorderSizePixel=0 accentBar.Parent=titleBar
createUICorner(accentBar,2)
local isNoSub=(subtitleText=="" or (type(subtitleText)=="table" and subtitleText.zh==""))
local titleLabel=Instance.new("TextLabel") titleLabel.Position=isNoSub and UDim2.fromOffset(26,21) or UDim2.fromOffset(26,14) titleLabel.Size=UDim2.new(1,-156,0,22) titleLabel.BackgroundTransparency=1 titleLabel.TextColor3=Theme.Text titleLabel.TextSize=17 titleLabel.Font=Enum.Font.GothamBold titleLabel.TextXAlignment=Enum.TextXAlignment.Left titleLabel.Parent=titleBar
local subtitleLabel=Instance.new("TextLabel") subtitleLabel.Position=UDim2.fromOffset(26,36) subtitleLabel.Size=UDim2.new(1,-156,0,16) subtitleLabel.BackgroundTransparency=1 subtitleLabel.TextColor3=Theme.SubText subtitleLabel.TextSize=12 subtitleLabel.Font=Enum.Font.Gotham subtitleLabel.TextXAlignment=Enum.TextXAlignment.Left subtitleLabel.Visible=not isNoSub subtitleLabel.Parent=titleBar
local langButton=makeTitleButton(titleBar,"中",-116,Theme.Accent) local minimizeButton=makeTitleButton(titleBar,"−",-80,Theme.SurfaceHover) local closeButton=makeTitleButton(titleBar,"X",-44,Color3.fromRGB(90,40,60))
local sidebar=Instance.new("Frame") sidebar.Size=UDim2.new(0,140,1,-80) sidebar.Position=UDim2.fromOffset(12,64) sidebar.BackgroundTransparency=1 sidebar.Parent=main
local tabButtonsContainer=Instance.new("Frame") tabButtonsContainer.Size=UDim2.fromScale(1,1) tabButtonsContainer.BackgroundTransparency=1 tabButtonsContainer.ZIndex=2 tabButtonsContainer.Parent=sidebar
local sidebarLayout=Instance.new("UIListLayout") sidebarLayout.Padding=UDim.new(0,8) sidebarLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center sidebarLayout.Parent=tabButtonsContainer
local contentContainer=Instance.new("Frame") contentContainer.Size=UDim2.new(1,-168,1,-80) contentContainer.Position=UDim2.fromOffset(164,64) contentContainer.BackgroundTransparency=1 contentContainer.Parent=main
local tabHighlight=Instance.new("Frame") tabHighlight.Size=UDim2.new(1,-16,0,42) tabHighlight.Position=UDim2.fromOffset(8,8) tabHighlight.BackgroundColor3=Theme.Accent tabHighlight.BackgroundTransparency=1 tabHighlight.ZIndex=1 tabHighlight.Parent=sidebar
createUICorner(tabHighlight,10) local tabHighlightAnim=Animator.new(tabHighlight,"Position",400,22)
local window=setmetatable({Gui=gui,Root=root,Main=main,Sidebar=sidebar,TabButtonsContainer=tabButtonsContainer,ContentContainer=contentContainer,TabHighlight=tabHighlight,TabHighlightAnim=tabHighlightAnim,Pages={},ActiveTab=nil,Content=nil,_index=0,_tabCount=0,_pageAnimCache={},_locale=initialLocale,_localizers={},_langButton=langButton,_rootScaleAnim=rootScaleAnim,_connections={},_destroyCallbacks={}},Window)
window:_registerText(titleLabel,titleText) if not isNoSub then window:_registerText(subtitleLabel,subtitleText) end langButton.Text=(initialLocale=="zh") and "中" or "EN"
local pill=Instance.new("Frame") pill.Name="MinimizedPill" pill.Size=UDim2.fromOffset(180,44) pill.AnchorPoint=Vector2.new(0.5,0) pill.Position=UDim2.new(0.5,0,0,16) pill.BackgroundColor3=Theme.Surface pill.BorderSizePixel=0 pill.Visible=false pill.Active=true pill.ZIndex=150 pill.Parent=gui
createUICorner(pill,22) createUIStroke(pill,Theme.Accent,1)
local pillScale=Instance.new("UIScale") pillScale.Parent=pill local pillScaleAnim=Animator.new(pillScale,"Scale",280,13) local pillBgAnim=Animator.new(pill,"BackgroundColor3",340,24)
local pillDot=Instance.new("Frame") pillDot.Size=UDim2.fromOffset(10,10) pillDot.Position=UDim2.fromOffset(18,17) pillDot.BackgroundColor3=Theme.Accent pillDot.BorderSizePixel=0 pillDot.ZIndex=151 pillDot.Parent=pill
createUICorner(pillDot,5)
local pillLabel=Instance.new("TextLabel") pillLabel.Size=UDim2.new(1,-50,1,0) pillLabel.Position=UDim2.fromOffset(38,0) pillLabel.BackgroundTransparency=1 pillLabel.TextColor3=Theme.Text pillLabel.TextSize=14 pillLabel.Font=Enum.Font.GothamMedium pillLabel.TextXAlignment=Enum.TextXAlignment.Left pillLabel.ZIndex=151 pillLabel.Parent=pill
window:_registerText(pillLabel,pillText)
local minimized,animating,closing=false,false,false local savedCenter=Vector2.new(0,0)
local function getRootCenter() return Vector2.new(root.AbsolutePosition.X+root.AbsoluteSize.X/2,root.AbsolutePosition.Y+root.AbsoluteSize.Y/2) end
local function getPillCenter() local guiAbs=gui.AbsoluteSize return Vector2.new(guiAbs.X/2,16+22) end
local function doMinimize()
if minimized or animating or closing then return end
animating=true minimized=true savedCenter=getRootCenter() local targetCenter=getPillCenter()
rootScaleAnim:Set(0)
task.delay(0.06,function() if not gui.Parent then return end flyBalls(gui,savedCenter,targetCenter,0.6,function() if not gui.Parent then return end pill.Visible=true pillScaleAnim:Set(1) animating=false end) end)
end
local function doRestore()
if not minimized or animating or closing then return end
animating=true minimized=false local startCenter=getPillCenter() local targetCenter=savedCenter
pillScaleAnim:Set(0)
task.delay(0.08,function() if not gui.Parent then return end flyBalls(gui,startCenter,targetCenter,0.6,function() if not gui.Parent then return end rootScaleAnim:Set(1) pill.Visible=false animating=false end) end)
end
pill.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then doRestore() end end)
pill.MouseEnter:Connect(function() pillBgAnim:Set(Theme.SurfaceHover) end) pill.MouseLeave:Connect(function() pillBgAnim:Set(Theme.Surface) end)
minimizeButton.MouseButton1Click:Connect(function() if minimized then doRestore() else doMinimize() end end)
langButton.MouseButton1Click:Connect(function() window:SetLocale(window._locale=="zh" and "en" or "zh") end)
local confirmModal=Instance.new("Frame") confirmModal.Size=UDim2.fromScale(1,1) confirmModal.BackgroundColor3=Color3.fromRGB(0,0,0) confirmModal.BackgroundTransparency=1 confirmModal.Visible=false confirmModal.ZIndex=400 confirmModal.Parent=gui
local modalBox=Instance.new("Frame") modalBox.Size=UDim2.fromOffset(260,140) modalBox.AnchorPoint=Vector2.new(0.5,0.5) modalBox.Position=UDim2.fromScale(0.5,0.5) modalBox.BackgroundColor3=Theme.Surface modalBox.BorderSizePixel=0 modalBox.ZIndex=401 modalBox.Parent=confirmModal
createUICorner(modalBox,16) createUIStroke(modalBox,Theme.Stroke,1)
local modalScale=Instance.new("UIScale") modalScale.Parent=modalBox local modalScaleAnim=Animator.new(modalScale,"Scale",380,18) local modalBgAnim=Animator.new(confirmModal,"BackgroundTransparency",340,24)
local modalTitle=Instance.new("TextLabel") modalTitle.Size=UDim2.new(1,0,0,40) modalTitle.Position=UDim2.fromOffset(0,15) modalTitle.BackgroundTransparency=1 modalTitle.Text="确定要关闭吗？" modalTitle.TextColor3=Theme.Text modalTitle.TextSize=16 modalTitle.Font=Enum.Font.GothamBold modalTitle.ZIndex=402 modalTitle.Parent=modalBox
local btnYes=Instance.new("TextButton") btnYes.Size=UDim2.fromOffset(100,36) btnYes.Position=UDim2.fromOffset(30,80) btnYes.BackgroundColor3=Theme.Accent btnYes.Text="确定" btnYes.TextColor3=Theme.Text btnYes.Font=Enum.Font.GothamBold btnYes.TextSize=14 btnYes.AutoButtonColor=false btnYes.ZIndex=402 btnYes.Parent=modalBox
createUICorner(btnYes,10)
local btnNo=Instance.new("TextButton") btnNo.Size=UDim2.fromOffset(100,36) btnNo.Position=UDim2.fromOffset(130,80) btnNo.BackgroundColor3=Theme.BackgroundTop btnNo.Text="取消" btnNo.TextColor3=Theme.SubText btnNo.Font=Enum.Font.GothamBold btnNo.TextSize=14 btnNo.AutoButtonColor=false btnNo.ZIndex=402 btnNo.Parent=modalBox
createUICorner(btnNo,10)
local function openModal() confirmModal.Visible=true modalBgAnim:Set(0.6) modalScaleAnim:Set(1) end
local function closeModal() modalBgAnim:Set(1) modalScaleAnim:Set(0) task.delay(0.3,function() confirmModal.Visible=false end) end
closeButton.MouseButton1Click:Connect(openModal) btnNo.MouseButton1Click:Connect(closeModal)
btnYes.MouseButton1Click:Connect(function()
if closing then return end
closing=true confirmModal.Visible=false
for _,fn in ipairs(window._destroyCallbacks) do pcall(fn) end
window._destroyCallbacks={}
rootScaleAnim.Stiffness=450 rootScaleAnim.Damping=22 rootScaleAnim:Set(0)
task.delay(0.6,function() for _,c in ipairs(window._connections) do c:Disconnect() end if gui then gui:Destroy() end end)
end)
local dragging,dragStart,startPos=false,nil,nil
table.insert(window._connections,titleBar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=input.Position startPos=root.Position end end))
table.insert(window._connections,UserInputService.InputChanged:Connect(function(input) if not dragging then return end if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then local delta=input.Position-dragStart root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end))
table.insert(window._connections,UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end))
rootScaleAnim:Set(1)
return window
end

getgenv().deletewhendupefound=true
do
local coreGui=game:GetService("CoreGui")
local old=coreGui:FindFirstChild("ZvmUI")
if old then old:Destroy() end
local playerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui")
if playerGui then local old2=playerGui:FindFirstChild("ZvmUI") if old2 then old2:Destroy() end end
end

local Window=ZvmUI.CreateWindow({Title="Zombies Vs Humans (2AreYouMental110)",PillTitle="Zombies Vs Humans",Subtitle="",Size=UDim2.fromOffset(720,500)})
local MainTab=Window:Tab({Text="主菜单",LayoutOrder=1})
local MovementTab=Window:Tab({Text="移动",LayoutOrder=2})
local EspTab=Window:Tab({Text="ESP",LayoutOrder=3})
local HitboxTab=Window:Tab({Text="碰撞箱",LayoutOrder=4})
local AntiTab=Window:Tab({Text="防封",LayoutOrder=5})
local WeldTab=Window:Tab({Text="人体焊接",LayoutOrder=6})
local OtherTab=Window:Tab({Text="其他脚本",LayoutOrder=7})

local localplr=LocalPlayer
local toc={}
local CurrentWeld=nil
local function setPara(obj,title,desc)
if not obj then return end
if obj.SetTitle then pcall(function() obj:SetTitle(title) end) end
if desc~=nil and obj.SetDesc then pcall(function() obj:SetDesc(desc) end) end
end
MainTab:Section({Text="警告"})
MainTab:Paragraph({Title="⚠️ 警告",Desc="所有这些功能都可能导致你被封禁！该游戏在 Discord 上有举报系统，如果你有大量进度，请勿作弊！"})
MainTab:Section({Text="状态"})
local currposl=MainTab:Paragraph({Title="当前位置：等待中...",Desc=""})
local cfrcheckl=MainTab:Paragraph({Title="死亡幅度（达到 0 = 反作弊死亡）：",Desc="..."})
MainTab:Section({Text="攻击"})
local ha=false
MainTab:Toggle({Text="攻击光环",Default=false,Callback=function(b) ha=b end})
local bha=false
local bhas=20
local newprt=Instance.new("Part")
newprt.Size=Vector3.new(bhas*2,bhas*2,bhas*2)
newprt.Anchored=true
newprt.Transparency=1
newprt.CanCollide=false
newprt.Shape=Enum.PartType.Ball
newprt.Parent=workspace
MainTab:Toggle({Text="方块攻击光环（掘墓人）",Default=false,Callback=function(b)
bha=b
newprt.Transparency=b and 0.8 or 1
end})
MainTab:Slider({Text="方块攻击光环大小",Step=1,Min=0,Max=20,Default=20,Callback=function(n)
bhas=n
newprt.Size=Vector3.new(n*2,n*2,n*2)
end})
local gha=false
MainTab:Toggle({Text="充能攻击光环（角斗士）（已损坏）",Default=false,Callback=function(b) gha=b end})
MainTab:Section({Text="其他"})
MainTab:TextBox({Placeholder="输入数字设置剑冷却时间，如 0.1",Callback=function(txt)
txt=tonumber(txt)
if not txt then return end
pcall(function()
for _,v in pairs(game:GetService("ReplicatedStorage").Modules.ItemData:GetChildren()) do
if v:IsA("ModuleScript") then
local r=require(v)
if r.Swings then for _,v2 in pairs(r.Swings) do v2.SwingCooldown=txt end end
end
end
end)
end})
local nofog=false
MainTab:Toggle({Text="无雾",Default=false,Callback=function(b) nofog=b end})
local comb=0
local function addcomb()
comb=comb+1
if comb>3 then comb=1 end
end
local function getmelee()
local sword=nil
for _,v in pairs(localplr.Backpack:GetChildren()) do
if v:IsA("Tool") and (string.find(v.Name,"Sword") or string.find(v.Name:lower(),"axe") or string.find(v.Name,"Dagger") or string.find(v.Name,"Hammer") or v.Name=="Trident") then
sword=v
v.Parent=localplr.Character
end
end
if not sword and localplr.Character then
for _,v in pairs(localplr.Character:GetChildren()) do
if v:IsA("Tool") and (string.find(v.Name,"Sword") or string.find(v.Name:lower(),"axe") or string.find(v.Name,"Dagger") or string.find(v.Name,"Hammer") or v.Name=="Trident") then
sword=v
end
end
end
return sword
end
local swordcooldowns={WoodenSword=0.35,Trident=0.85,StoneSword=0.425,GravediggersPickaxe=2.2,ObsidianHammer=1.4,IronSword=0.525,GladiatorsSword=2,FlintDagger=0.2,EmeraldAxe=1.5,DiamondSword=0.8}
local partdelays={}
local function adelay(part,checksword)
partdelays[part]=true
if typeof(checksword)=="Instance" then checksword=swordcooldowns[checksword.Name] and swordcooldowns[checksword.Name]/9 end
task.delay((typeof(checksword)=="number" and checksword) or 0.1,function() partdelays[part]=nil end)
end
local function checkdelay(part) return partdelays[part]==nil end
local ii=game.ReplicatedStorage.Remotes.ItemInteract
local proj=workspace.Projectiles
local graves=workspace.Graves
local blocks=workspace.Blocks
local supportsgpip=workspace.GetPartsInPart~=nil
local speed=nil
local ors=RunService.RenderStepped:Connect(function()
debug.profilebegin("ZVHRenderStepped")
if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
local pos=localplr.Character.HumanoidRootPart.Position
pos=Vector3.new(math.floor(pos.X),math.floor(pos.Y),math.floor(pos.Z))
setPara(currposl,"当前位置："..tostring(pos))
local v1=(750-math.abs(pos.X))
local v2=(800-math.abs(pos.Y))
local v3=(900-math.abs(pos.Z))
local dm=math.min(v1,v2,v3)
setPara(cfrcheckl,"死亡幅度（达到 0 = 反作弊死亡）："..tostring(dm).." | "..v1..", "..v2..", "..v3)
end
if speed and localplr.Character and localplr.Character:FindFirstChild("Humanoid") then localplr.Character.Humanoid.WalkSpeed=speed end
if nofog and game.Lighting:FindFirstChild("Atmosphere") then game.Lighting.Atmosphere.Density=0 end
if ha or bha then
local sword=getmelee()
if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
if ha and sword then
if not gha or sword.Name~="GladiatorsSword" then
for _,v in pairs(game.Players:GetPlayers()) do
if v~=localplr and v.Team~=localplr.Team and v.Character and checkdelay(v.Character) and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character.HumanoidRootPart.Position-localplr.Character.HumanoidRootPart.Position).Magnitude<20 and v.Character.Humanoid.Health>0 then
adelay(v.Character,sword)
coroutine.wrap(function() addcomb() ii:InvokeServer(sword,"Hit",v.Character,comb) task.wait(0.05) end)()
end
end
end
for _,v in pairs(proj:GetChildren()) do
if v:IsA("BasePart") and checkdelay(v) and (v.Position-localplr.Character.HumanoidRootPart.Position).Magnitude<40 then
if v.Name~="Cannonball" then continue end
adelay(v,0.05)
coroutine.wrap(function() addcomb() ii:InvokeServer(sword,"ProjectileHit",v,comb) end)()
end
end
for _,v in pairs(graves:GetChildren()) do
if checkdelay(v) and (((v:IsA("BasePart") and v.CFrame) or (v:IsA("Model") and v:GetPivot())).Position-localplr.Character.HumanoidRootPart.Position).Magnitude<20 then
adelay(v,sword)
coroutine.wrap(function() addcomb() ii:InvokeServer(sword,"GraveHit",v,comb) end)()
end
end
end
if bha and sword and sword.Name=="GravediggersPickaxe" then
if supportsgpip then
newprt.CFrame=localplr.Character.HumanoidRootPart.CFrame
for _,v in pairs(workspace:GetPartsInPart(newprt)) do
if v:IsDescendantOf(blocks) and v:IsA("BasePart") and checkdelay(v) then
adelay(v,0.5)
if v.Name=="Root" then v=v.Parent end
coroutine.wrap(function() addcomb() pcall(function() ii:InvokeServer(sword,"BlockHit",v,comb) end) end)()
end
end
else
for _,v in pairs(blocks:GetChildren()) do
if v:IsA("BasePart") and (v.Position-localplr.Character.HumanoidRootPart.Position).Magnitude<bhas and checkdelay(v) then
adelay(v,0.5) addcomb()
coroutine.wrap(function() ii:InvokeServer(sword,"BlockHit",v,comb) end)()
end
end
end
end
end
end
debug.profileend()
end)
MovementTab:Button({Text="反卡住（向上传送）",Callback=function()
if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
localplr.Character.HumanoidRootPart.CFrame=localplr.Character.HumanoidRootPart.CFrame+Vector3.new(0,40,0)
localplr.Character.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero
end
end})
MovementTab:Paragraph({Title="人类最快速度：26（建造回合：30）"})
MovementTab:Paragraph({Title="僵尸最快速度：28（冲锋者为 32）"})
local speedInited=false
MovementTab:Slider({Text="速度（已修补）",Step=1,Min=18,Max=32,Default=18,Callback=function(n)
if not speedInited then speedInited=true return end
speed=math.floor(n)
end})
local zesp,hesp=false,false
local phl={}
local hlf=Instance.new("Folder")
hlf.Name="hls"
hlf.Parent=game.CoreGui
local function doplr(plr)
local dochar
if plr==localplr then
dochar=function(c)
local h=c:WaitForChild("Humanoid")
h.Died:Connect(function()
if CurrentWeld then
task.wait(3)
CurrentWeld:Destroy()
if c and c:FindFirstChild("Humanoid") then workspace.Camera.CameraSubject=c.Humanoid end
end
end)
end
else
dochar=function(c)
local team=plr.Team
local highlight=Instance.new("Highlight") highlight.Parent=hlf highlight.FillTransparency=0.5 highlight.FillColor=(plr.Team~=localplr.Team and Color3.fromRGB(255,0,0)) or Color3.fromRGB(0,255,0) highlight.OutlineColor=plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255,255,255) highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop highlight.Adornee=c
local bbgui=nil
if team==game.Teams.Humans and hesp then highlight.Enabled=true
elseif team==game.Teams.Monsters and zesp then
highlight.Enabled=true
bbgui=Instance.new("BillboardGui") bbgui.Size=UDim2.new(10,0,1.5,0) bbgui.StudsOffset=Vector3.new(0,3.5,0) bbgui.Adornee=c:WaitForChild("Head",10) bbgui.AlwaysOnTop=true bbgui.Parent=highlight
local txt=Instance.new("TextLabel") txt.TextScaled=true txt.BackgroundTransparency=1 txt.Size=UDim2.new(0,100,0,20) txt.TextStrokeTransparency=0 txt.TextStrokeColor3=Color3.fromRGB(255,255,255) txt.Text="" txt.TextColor3=Color3.fromRGB(255,255,255) txt.TextXAlignment=Enum.TextXAlignment.Center txt.Parent=bbgui
local function detect(toolName,label,color)
coroutine.wrap(function()
local t1=c:WaitForChild(toolName,5) local t2
if not t1 then t2=plr.Backpack:WaitForChild(toolName,5) end
if t1 or t2 then txt.Text=label txt.TextColor3=color end
end)()
end
detect("Bomb","炸弹人",Color3.fromRGB(0,0,0)) detect("Dynamite","冲锋者",Color3.fromRGB(255,155,0)) detect("Cannon","炮手",Color3.fromRGB(60,60,60)) detect("GravediggersPickaxe","掘墓人",Color3.fromRGB(0,150,0)) detect("GladiatorsSword","角斗士",Color3.fromRGB(200,0,0)) detect("HuntersBow","猎人",Color3.fromRGB(0,200,200))
else highlight.Enabled=false end
phl[highlight]={tn=team and team.Name,p=plr,c=c,bb=bbgui}
end
end
if plr.Character then dochar(plr.Character) end
table.insert(toc,plr.CharacterAdded:Connect(dochar))
table.insert(toc,plr.CharacterRemoving:Connect(function(c)
local toRemove={}
for i,v in pairs(phl) do if v.c==c then table.insert(toRemove,i) end end
for _,key in ipairs(toRemove) do if key then key:Destroy() end phl[key]=nil end
end))
end
for _,v in pairs(game.Players:GetPlayers()) do doplr(v) end
table.insert(toc,game.Players.PlayerAdded:Connect(doplr))
EspTab:Toggle({Text="人类 ESP",Default=false,Callback=function(b)
hesp=b
for i,v in pairs(phl) do if v.tn=="Humans" then i.Enabled=hesp if v.bb then v.bb.Enabled=hesp end end end
end})
EspTab:Toggle({Text="僵尸 ESP",Default=false,Callback=function(b)
zesp=b
for i,v in pairs(phl) do if v.tn=="Monsters" then i.Enabled=zesp if v.bb then v.bb.Enabled=zesp end end end
end})
local otc=localplr:GetPropertyChangedSignal("Team"):Connect(function()
for i,v in pairs(phl) do i.FillColor=(v.p.Team~=localplr.Team and Color3.fromRGB(255,0,0)) or Color3.fromRGB(0,255,0) end
end)
local HB_Players=game:GetService("Players")
local HB_LP=HB_Players.LocalPlayer
local HB_CONFIG={Size=10,Transparency=0.5,Color=Color3.fromRGB(150,150,150),TargetParts={"HumanoidRootPart"}}
local HitboxOrig={}
local HitboxVisuals={}
local hb_enabled=false
local hb_conn=nil
local function saveOrig(char)
local data=HitboxOrig[char]
if not data then data={} HitboxOrig[char]=data end
for _,name in ipairs(HB_CONFIG.TargetParts) do
if data[name] then continue end
local part=char:FindFirstChild(name)
if part then data[name]={Size=part.Size} end
end
end
local function hbApply(char)
if not char then return end
local hum=char:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health<=0 then return end
saveOrig(char)
local sz=Vector3.new(HB_CONFIG.Size,HB_CONFIG.Size,HB_CONFIG.Size)
for _,name in ipairs(HB_CONFIG.TargetParts) do
local part=char:FindFirstChild(name)
if part then
if part.Size~=sz then part.Size=sz end
local visual=HitboxVisuals[char]
if not visual or not visual.Parent then
visual=Instance.new("BoxHandleAdornment") visual.Adornee=part visual.AlwaysOnTop=false visual.ZIndex=5 visual.Parent=game.CoreGui HitboxVisuals[char]=visual
end
if visual.Size~=sz then visual.Size=sz end
if visual.Color3~=HB_CONFIG.Color then visual.Color3=HB_CONFIG.Color end
if visual.Transparency~=HB_CONFIG.Transparency then visual.Transparency=HB_CONFIG.Transparency end
end
end
end
local function hbReset(char)
local data=HitboxOrig[char]
if data then
for name,orig in pairs(data) do local part=char:FindFirstChild(name) if part then part.Size=orig.Size end end
HitboxOrig[char]=nil
end
local visual=HitboxVisuals[char]
if visual then visual:Destroy() HitboxVisuals[char]=nil end
end
local function hbRefresh()
for _,plr in ipairs(HB_Players:GetPlayers()) do if plr~=HB_LP and plr.Character then hbApply(plr.Character) end end
end
local function hbSetEnabled(state)
hb_enabled=state
if hb_conn then hb_conn:Disconnect() hb_conn=nil end
if not state then
local chars={}
for char in pairs(HitboxOrig) do table.insert(chars,char) end
for _,char in ipairs(chars) do hbReset(char) end
return
end
hbRefresh()
hb_conn=RunService.RenderStepped:Connect(function()
if not hb_enabled then return end
for _,plr in ipairs(HB_Players:GetPlayers()) do
if plr~=HB_LP and plr.Character then
local hum=plr.Character:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health<=0 then hbReset(plr.Character) else hbApply(plr.Character) end
end
end
for c,v in pairs(HitboxVisuals) do
if not v.Parent or not v.Adornee or not v.Adornee.Parent or not c or not c.Parent then
if v then v:Destroy() end
HitboxVisuals[c]=nil
HitboxOrig[c]=nil
end
end
end)
end
local function hbPlayerAdded(player)
if player==HB_LP then return end
if hb_enabled and player.Character then task.spawn(function() hbApply(player.Character) end) end
table.insert(toc,player.CharacterAdded:Connect(function(char) task.wait(0.5) if hb_enabled then hbApply(char) end end))
table.insert(toc,player.CharacterRemoving:Connect(function(char) hbReset(char) end))
end
for _,plr in ipairs(HB_Players:GetPlayers()) do hbPlayerAdded(plr) end
table.insert(toc,HB_Players.PlayerAdded:Connect(hbPlayerAdded))
table.insert(toc,HB_Players.PlayerRemoving:Connect(function(player) if player.Character then hbReset(player.Character) end end))
HitboxTab:Toggle({Text="启用碰撞箱",Default=false,Callback=function(bool) hbSetEnabled(bool) end})
HitboxTab:Slider({Text="碰撞箱大小",Step=1,Min=1,Max=50,Default=10,Callback=function(n) HB_CONFIG.Size=n if hb_enabled then hbRefresh() end end})
HitboxTab:Slider({Text="范围透明度",Step=0.1,Min=0,Max=1,Default=0.5,Callback=function(n) HB_CONFIG.Transparency=n if hb_enabled then hbRefresh() end end})
HitboxTab:Colorpicker({Text="范围颜色",Default=Color3.fromRGB(150,150,150),Callback=function(color) HB_CONFIG.Color=color if hb_enabled then hbRefresh() end end})
local oldfunc1,oldfunc2,oldfunc3,oldfunc4,oldfunc5=nil,nil,nil,nil,nil
local antij,antiwh,antifm,antifd,antird,antisc,antikb=false,false,false,false,false,false,false
AntiTab:Toggle({Text="反跳跃疲劳",Default=false,Callback=function(b)
antij=b
pcall(function()
local r=require(localplr.PlayerScripts.Client.Character.JumpFatigue)
if antij then oldfunc1=r.GetCanFatigue r.GetCanFatigue=function() end else r.GetCanFatigue=oldfunc1 end
end)
end})
AntiTab:Toggle({Text="反反爬墙",Default=false,Callback=function(b)
antiwh=b
pcall(function()
local r=require(localplr.PlayerScripts.Client.Game.NoWallhop)
if antiwh then oldfunc2=r.GetIsOnGround r.GetIsOnGround=function() return true end else r.GetIsOnGround=oldfunc2 end
end)
end})
local deathreq=game.ReplicatedStorage.Remotes:WaitForChild("RequestThyDeath")
AntiTab:Toggle({Text="反反飞行机器",Default=false,Callback=function(b)
antifm=b
if antifm then deathreq.Parent=workspace else deathreq.Parent=game.ReplicatedStorage.Remotes end
end})
AntiTab:Toggle({Text="反坠落伤害",Default=false,Callback=function(b)
antifd=b
pcall(function()
local r=require(localplr.PlayerScripts.Client.Game.FallDamage)
if antifd then oldfunc3=r.GetFallDamage r.GetFallDamage=function() return 0 end else r.GetFallDamage=oldfunc3 end
end)
end})
AntiTab:Toggle({Text="反布娃娃（有时无效）",Default=false,Callback=function(b)
antird=b
pcall(function()
local r=require(game.ReplicatedStorage.Packages.Ragdoll)
if antird then
oldfunc4=r.EnableCharacterRagdoll r.EnableCharacterRagdoll=function() end
oldfunc5=r.StunCharacter r.StunCharacter=function() end
task.spawn(function() while antird do task.wait() if localplr.Character then pcall(function() r:DisableCharacterRagdoll(localplr.Character) end) pcall(function() r:CancelCharacterStun(localplr.Character) end) end end end)
else
r.EnableCharacterRagdoll=oldfunc4 r.StunCharacter=oldfunc5
end
end)
end})
local scaffoldblocks={}
AntiTab:Toggle({Text="僵尸攀爬脚手架",Default=false,Callback=function(b)
antisc=b
for blk,o in pairs(scaffoldblocks) do if not blk or not blk.Parent then scaffoldblocks[blk]=nil else blk[o[1]]=(antisc and o[3]) or o[2] end end
end})
local function doblock(b)
if not b or not b.Parent then return end
if b.Name=="Scaffold" or b.Name=="Truss" then
for _,v in pairs(b.Model:GetChildren()) do
if v.Name=="Truss" then scaffoldblocks[v]={"CollisionGroup",v.CollisionGroup,"BlockRoot"} if antisc then v.CollisionGroup="BlockRoot" end
elseif v.Name=="ZombieCollision" then scaffoldblocks[v]={"Parent",v.Parent,game.CoreGui} if antisc then v.Parent=game.CoreGui end end
end
end
end
local function doblockmodel(c)
table.insert(toc,c.ChildAdded:Connect(function(b) doblock(b) end))
for _,b in pairs(c:GetChildren()) do doblock(b) end
end
table.insert(toc,workspace.Blocks.ChildAdded:Connect(function(c) doblockmodel(c) end))
for _,c in pairs(workspace.Blocks:GetChildren()) do doblockmodel(c) end
AntiTab:Toggle({Text="禁用击杀砖",Desc="远离岛屿过远或在水中停留超过 3 秒将会死亡",Default=false,Callback=function(b)
antikb=b
pcall(function()
if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("KillZones") then
for _,v in pairs(workspace.Map.KillZones:GetChildren()) do v.CanTouch=not antikb end
end
end)
end})
WeldTab:Paragraph({Title="⚠️ 注意",Desc="此方法很可能会被修补，请尽快使用！"})
WeldTab:Paragraph({Title="焊接方法最初由 Failedmite 和 Janmandio 发现"})
WeldTab:Paragraph({Title="代码取自 Infinite Yield 中的 \"Welder V2\" 插件"})
WeldTab:Paragraph({Title="如果你使用的是 Xeno 或 Solara 之类的执行器，请开启低 sUNC 支持"})
local lss=false
WeldTab:Toggle({Text="低 sUNC 支持",Default=false,Callback=function(b) lss=b end})
local killweld=false
WeldTab:Toggle({Text="（几乎）瞬间击杀（不会获得分数）",Default=false,Callback=function(b) killweld=b end})
local weldoffsetx,weldoffsety,weldoffsetz=0,0,0
WeldTab:Slider({Text="焊接偏移（X）",Step=1,Min=-20,Max=20,Default=0,Callback=function(n) weldoffsetx=math.floor(n) end})
WeldTab:Slider({Text="焊接偏移（Y）",Step=1,Min=-20,Max=20,Default=0,Callback=function(n) weldoffsety=math.floor(n) end})
WeldTab:Slider({Text="焊接偏移（Z）",Step=1,Min=-20,Max=20,Default=0,Callback=function(n) weldoffsetz=math.floor(n) end})
local PhysicsService=game:GetService("PhysicsService")
local RenderStepped=RunService.RenderStepped
local WELD_GROUP=(function()
local buff=buffer.create(20)
local charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
for i=1,20 do buffer.writeu8(buff,i-1,string.byte(charset,math.random(1,#charset))) end
return buffer.tostring(buff)
end)()
pcall(function() PhysicsService:RegisterCollisionGroup(WELD_GROUP) PhysicsService:CollisionGroupSetCollidable(WELD_GROUP,WELD_GROUP,true) end)
local function LowsUNCWeldTo(Part,Speaker,AnimationId)
if not Part.Parent then return end
if Players:GetPlayerFromCharacter(Part.Parent) then
local H=Part.Parent:FindFirstChildWhichIsA("Humanoid")
workspace.Camera.CameraSubject=H if H then H.RequiresNeck=false end
end
local Character=Speaker.Character
if not Character or not Character:FindFirstChild("HumanoidRootPart") then return nil end
local Root=Character.HumanoidRootPart.AssemblyRootPart
local Start=CFrame.new(Root.Position)
local Weld={} local Enabled=false local PartJoints={} local OldProps={} local OldCharProps={} local AnimTrack=nil
if AnimationId then
local Animator=Character:FindFirstChildWhichIsA("Animator",true)
if Animator then
local Animation=Instance.new("Animation") Animation.AnimationId="rbxassetid://"..tostring(AnimationId)
AnimTrack=Animator:LoadAnimation(Animation) AnimTrack:Play()
end
end
Weld.Velocity=(killweld and Vector3.new(0,10000,0)) or Vector3.zero
function Weld:Enable(t)
Enabled=t
if not t then
for _,J in next,PartJoints do J.Enabled=true end
for P,V in next,OldProps do Part[P]=V end
for part,props in next,OldCharProps do if part and part.Parent then part.CollisionGroup=props.Group part.CanCollide=props.Collide end end
return
end
PartJoints=Part:GetJoints()
for _,P in next,{"Size","CanCollide","Anchored","Parent","CollisionGroup"} do OldProps[P]=Part[P] end
for _,p in next,Character:GetDescendants() do if p:IsA("BasePart") then OldCharProps[p]={Group=p.CollisionGroup,Collide=p.CanCollide} p.CollisionGroup=WELD_GROUP p.CanCollide=true end end
Part.Size=Vector3.new(25,3,25) Part.Anchored=false Part.CanCollide=true Part.CollisionGroup=WELD_GROUP Part.Parent=workspace.Terrain
for _,J in next,PartJoints do J.Enabled=false end
end
local thread=nil
function Weld:Destroy()
task.cancel(thread) Weld:Enable(false)
if AnimTrack then AnimTrack:Stop() AnimTrack:Destroy() end
end
thread=task.spawn(function()
while task.wait() do
if not Enabled then continue end
Part.CFrame=Start Root.CFrame=Start*CFrame.new(weldoffsetx,weldoffsety,weldoffsetz)
Part.AssemblyLinearVelocity=Vector3.zero Part.AssemblyAngularVelocity=Vector3.zero
Root.AssemblyLinearVelocity=Weld.Velocity Root.AssemblyAngularVelocity=Vector3.zero
RenderStepped:Wait()
Part.CFrame=Start Root.CFrame=Start*CFrame.new(0,4,0)
Part.AssemblyLinearVelocity=Vector3.zero Part.AssemblyAngularVelocity=Vector3.zero
end
end)
Weld:Enable(true)
return Weld
end
local function WeldTo(TargetPart,Speaker,AnimationId)
local Character=Speaker.Character
if not Character then return nil end
local Root=Character:FindFirstChild("HumanoidRootPart")
if not Root then return nil end
local AnimTrack=nil
if AnimationId then
local Animator=Character:FindFirstChildWhichIsA("Animator",true)
if Animator then
local Animation=Instance.new("Animation") Animation.AnimationId="rbxassetid://"..tostring(AnimationId)
AnimTrack=Animator:LoadAnimation(Animation) AnimTrack:Play()
end
end
local Weld={} local Connection=nil local OldCharProps={}
for _,v in pairs(Character:GetDescendants()) do
if v:IsA("BasePart") then OldCharProps[v]={Collide=v.CanCollide} v.CanCollide=false v.Massless=true end
end
Connection=RunService.Heartbeat:Connect(function()
if not Character.Parent or not TargetPart.Parent then if Weld.Destroy then Weld:Destroy() end return end
Root.CFrame=TargetPart.CFrame*CFrame.new(weldoffsetx,weldoffsety,weldoffsetz)
Root.AssemblyLinearVelocity=(killweld and Vector3.new(0,10000,0)) or Vector3.zero
Root.AssemblyAngularVelocity=Vector3.zero
if sethiddenproperty then pcall(function() sethiddenproperty(Root,"PhysicsRepRootPart",TargetPart) end) end
end)
function Weld:Destroy()
if Connection then Connection:Disconnect() end
if AnimTrack then AnimTrack:Stop() AnimTrack:Destroy() end
if Root then Root.AssemblyLinearVelocity=Vector3.zero Root.AssemblyAngularVelocity=Vector3.zero end
for part,props in pairs(OldCharProps) do if part and part.Parent then part.CanCollide=props.Collide end end
end
return Weld
end
WeldTab:Button({Text="焊接到随机人类",Callback=function()
if CurrentWeld then CurrentWeld:Destroy() end
local hrp=nil local attempts=0
repeat
task.wait(0.1) attempts=attempts+1
if #game.Teams.Humans:GetPlayers()>0+((localplr.Team==game.Teams.Humans and 1) or 0) then
local rp=game.Teams.Humans:GetPlayers()[math.random(1,#game.Teams.Humans:GetPlayers())]
if rp~=localplr and rp.Character and rp.Character:FindFirstChild("HumanoidRootPart") then hrp=rp.Character.HumanoidRootPart end
else break end
until hrp or attempts>10
if hrp then CurrentWeld=(lss and LowsUNCWeldTo or WeldTo)(hrp,localplr,0) end
end})
WeldTab:Button({Text="焊接到随机僵尸",Callback=function()
if CurrentWeld then CurrentWeld:Destroy() end
local hrp=nil local attempts=0
repeat
task.wait(0.1) attempts=attempts+1
if #game.Teams.Monsters:GetPlayers()>0+((localplr.Team==game.Teams.Monsters and 1) or 0) then
local rp=game.Teams.Monsters:GetPlayers()[math.random(1,#game.Teams.Monsters:GetPlayers())]
if rp~=localplr and rp.Character and rp.Character:FindFirstChild("HumanoidRootPart") then hrp=rp.Character.HumanoidRootPart end
else break end
until hrp or attempts>10
if hrp then CurrentWeld=(lss and LowsUNCWeldTo or WeldTo)(hrp,localplr,0) end
end})
WeldTab:TextBox({Placeholder="输入玩家名字前缀",Callback=function(plrname)
if not plrname or plrname=="" then return end
if CurrentWeld then CurrentWeld:Destroy() end
local hrp=nil
for _,v in pairs(game.Players:GetPlayers()) do
if (string.sub(v.DisplayName,1,#plrname):lower()==plrname:lower() or string.sub(v.Name,1,#plrname):lower()==plrname:lower()) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then hrp=v.Character.HumanoidRootPart end
end
if hrp then CurrentWeld=(lss and LowsUNCWeldTo or WeldTo)(hrp,localplr,0) end
end})
WeldTab:Button({Text="取消焊接",Callback=function()
if CurrentWeld then
CurrentWeld:Destroy()
if localplr.Character and localplr.Character:FindFirstChild("Humanoid") then workspace.Camera.CameraSubject=localplr.Character.Humanoid end
end
end})
OtherTab:Button({Text="执行 Infinite Yield",Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
OtherTab:Button({Text="执行念力脚本",Callback=function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Telekinesis-WIP-240257"))() end})
if game:GetService("ReplicatedStorage").Remotes:FindFirstChild("ConsoleLog") then
game:GetService("ReplicatedStorage").Remotes.ConsoleLog:Destroy()
local fcl=Instance.new("RemoteFunction") fcl.Name="ConsoleLog" fcl.Parent=game:GetService("ReplicatedStorage").Remotes
end
Window:OnDestroy(function()
ha=false bha=false gha=false antisc=false antird=false hb_enabled=false
if hb_conn then hb_conn:Disconnect() end
local chars={}
for char in pairs(HitboxOrig) do table.insert(chars,char) end
for _,char in ipairs(chars) do hbReset(char) end
for c,v in pairs(HitboxVisuals) do if v then v:Destroy() end end
HitboxVisuals={} HitboxOrig={}
if hlf then hlf:Destroy() end
if otc then otc:Disconnect() end
if ors then ors:Disconnect() end
for _,v in pairs(toc) do pcall(function() v:Disconnect() end) end
pcall(function() if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("KillZones") then for _,v in pairs(workspace.Map.KillZones:GetChildren()) do v.CanTouch=true end end end)
if localplr.PlayerGui:FindFirstChild("Overlay") then localplr.PlayerGui.Overlay.Enabled=true end
newprt:Destroy()
deathreq.Parent=game.ReplicatedStorage.Remotes
if CurrentWeld then CurrentWeld:Destroy() if localplr.Character and localplr.Character:FindFirstChild("Humanoid") then workspace.Camera.CameraSubject=localplr.Character.Humanoid end end
if oldfunc1 then pcall(function() require(localplr.PlayerScripts.Client.Character.JumpFatigue).GetCanFatigue=oldfunc1 end) end
if oldfunc2 then pcall(function() require(localplr.PlayerScripts.Client.Game.NoWallhop).GetIsOnGround=oldfunc2 end) end
if oldfunc3 then pcall(function() require(localplr.PlayerScripts.Client.Game.FallDamage).GetFallDamage=oldfunc3 end) end
if oldfunc4 then pcall(function() require(game.ReplicatedStorage.Packages.Ragdoll).EnableCharacterRagdoll=oldfunc4 end) end
if oldfunc5 then pcall(function() require(game.ReplicatedStorage.Packages.Ragdoll).StunCharacter=oldfunc5 end) end
end)
