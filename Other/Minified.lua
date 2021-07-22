if getgenv()["Animator"]==nil then local a=game:GetService("HttpService")local b=false;local c={}c.__index=c;c.ClassName="Signal"function c.new()local self=setmetatable({},c)self._bindableEvent=Instance.new("BindableEvent")self._argMap={}self._source=b and debug.traceback()or""self._bindableEvent.Event:Connect(function(d)self._argMap[d]=nil;if not self._bindableEvent and not next(self._argMap)then self._argMap=nil end end)return self end;function c:Fire(...)if not self._bindableEvent then warn(("Signal is already destroyed. %s"):format(self._source))return end;local e=table.pack(...)local d=a:GenerateGUID(false)self._argMap[d]=e;self._bindableEvent:Fire(d)end;function c:Connect(f)if not(type(f)=="function")then error(("connect(%s)"):format(typeof(f)),2)end;return self._bindableEvent.Event:Connect(function(d)local e=self._argMap[d]if e then f(table.unpack(e,1,e.n))else error("Missing arg data, probably due to reentrance.")end end)end;function c:Wait()local d=self._bindableEvent.Event:Wait()local e=self._argMap[d]if e then return table.unpack(e,1,e.n)else error("Missing arg data, probably due to reentrance.")return nil end end;function c:Destroy()if self._bindableEvent then self._bindableEvent:Destroy()self._bindableEvent=nil end;setmetatable(self,nil)end;local g={}local h=string.format;function g:sendNotif(i,j,k,l,m,n)game:GetService("StarterGui"):SetCore("SendNotification",{Title="Animator",Text=i.."\nBy hayper#0001"or nil,Icon=j or nil,Duration=k or nil,Button1=l or nil,Button2=m or nil,Callback=n or nil})end;function g:convertEnum(o)local p=tostring(o):split(".")if p[1]=="Enum"then local q=p[2]local r=p[3]local s={["PoseEasingDirection"]="EasingDirection",["PoseEasingStyle"]="EasingStyle"}if s[q]then return Enum[s[q]][r]else return o end else return o end end;function g:getBones(t,u)u=u or{}if typeof(t)~="Instance"then error(h("invalid argument 1 to 'getBones' (Instance expected, got %s)",typeof(t)))end;if typeof(u)~="table"then error(h("invalid argument 1 to 'getBones' (Table expected, got %s)",typeof(u)))end;local v={}for w,x in next,t:GetDescendants()do if x:IsA("Bone")then local y=false;for w,z in next,u do if typeof(z)=="Instance"and x:IsDescendantOf(z)then y=true;break end end;if y~=true then table.insert(v,x)end end end;return v end;function g:getMotors(t,u)u=u or{}if typeof(t)~="Instance"then error(h("invalid argument 1 to 'getMotors' (Instance expected, got %s)",typeof(t)))end;if typeof(u)~="table"then error(h("invalid argument 1 to 'getMotors' (Table expected, got %s)",typeof(u)))end;local A={}for w,x in next,t:GetDescendants()do if x:IsA("Motor6D")and x.Part0~=nil and x.Part1~=nil then local y=false;for w,z in next,u do if typeof(z)=="Instance"and x:IsDescendantOf(z)then y=true;break end end;if y~=true then table.insert(A,x)end end end;return A end;local B={}function B:parsePoseData(C)if not C:IsA("Pose")then error(h("invalid argument 1 to '_parsePoseData' (Pose expected, got %s)",C.ClassName))end;local D={Name=C.Name,CFrame=C.CFrame,EasingDirection=g:convertEnum(C.EasingDirection),EasingStyle=g:convertEnum(C.EasingStyle),Weight=C.Weight}if#C:GetChildren()>0 then D.Subpose={}for w,q in next,C:GetChildren()do if q:IsA("Pose")then table.insert(D.Subpose,B:parsePoseData(q))end end end;return D end;function B:parseKeyframeData(E)if not E:IsA("Keyframe")then error(h("invalid argument 1 to '_parseKeyframeData' (Keyframe expected, got %s)",E.ClassName))end;local F={Name=E.Name,Time=E.Time,Pose={}}for w,q in next,E:GetChildren()do if q:IsA("Pose")then table.insert(F.Pose,B:parsePoseData(q))elseif q:IsA("KeyframeMarker")then if not F["Marker"]then F.Marker={}end;if not F.Marker[q.Name]then F.Marker[q.Name]={}end;table.insert(F.Marker,q.Name)end end;return F end;function B:parseAnimationData(G)if not G:IsA("KeyframeSequence")then error(h("invalid argument 1 to 'parseAnimationData' (KeyframeSequence expected, got %s)",G.ClassName))end;local H={Loop=G.Loop,Priority=G.Priority,Frames={}}for w,I in next,G:GetChildren()do if I:IsA("Keyframe")then table.insert(H.Frames,B:parseKeyframeData(I))end end;table.sort(H.Frames,function(J,K)return J.Time<K.Time end)return H end;local L=game:GetService("RunService")local M=game:GetService("TweenService")local N={AnimationData={},handleVanillaAnimator=true,Character=nil,Looped=false,Length=0,Speed=1,IsPlaying=false,_motorIgnoreList={},_stopFadeTime=0.100000001,_playing=false,_stopped=false,_isLooping=false,_markerSignal={},_boneIgnoreList={}}N.__index=N;function N.new(t,O)if typeof(t)~="Instance"then error(h("invalid argument 1 to 'new' (Instace expected, got %s)",typeof(t)))end;local P=setmetatable({},N)P.Character=t;if typeof(O)=="string"or typeof(O)=="number"then local Q=game:GetObjects("rbxassetid://"..tostring(O))[1]if not Q:IsA("KeyframeSequence")then error("invalid argument 1 to 'new' (AnimationID expected)")end;P.AnimationData=B:parseAnimationData(Q)elseif typeof(O)=="table"then P.AnimationData=O elseif typeof(O)=="Instance"and O:IsA("KeyframeSequence")then P.AnimationData=B:parseAnimationData(O)elseif typeof(O)=="Instance"and O:IsA("Animation")then local Q=game:GetObjects(O.AnimationId)[1]if not Q:IsA("KeyframeSequence")then error("invalid argument 1 to 'new' (AnimationID inside Animation expected)")end;P.AnimationData=B:parseAnimationData(Q)else error(h("invalid argument 2 to 'new' (number,string,table,KeyframeSequence,Animation expected, got %s)",typeof(O)))end;P.Looped=P.AnimationData.Loop;P.Length=P.AnimationData.Frames[#P.AnimationData.Frames].Time;P.DidLoop=c.new()P.Stopped=c.new()P.KeyframeReached=c.new()return P end;function N:IgnoreMotorIn(R)if typeof(R)~="table"then error(h("invalid argument 1 to 'IgnoreMotorIn' (Table expected, got %s)",typeof(R)))end;self._motorIgnoreList=R end;function N:GetMotorIgnoreList()return self._motorIgnoreList end;function N:IgnoreBoneIn(R)if typeof(R)~="table"then error(h("invalid argument 1 to 'IgnoreBoneIn' (Table expected, got %s)",typeof(R)))end;self._boneIgnoreList=R end;function N:GetBoneIgnoreList()return self._boneIgnoreList end;function N:_playPose(C,S,T)local A=g:getMotors(self.Character,self._motorIgnoreList)local v=g:getBones(self.Character,self._boneIgnoreList)if C.Subpose then for w,U in next,C.Subpose do self:_playPose(U,C,T)end end;if S then local V=TweenInfo.new(T,C.EasingStyle,C.EasingDirection)for w,W in next,A do if W.Part0.Name==S.Name and W.Part1.Name==C.Name then if T>0 then if self._stopped~=true then M:Create(W,V,{Transform=C.CFrame}):Play()end else W.Transform=C.CFrame end end end;for w,X in next,v do if S.Name==X.Parent.Name and X.Name==C.Name then if T>0 then if self._stopped~=true then M:Create(X,V,{Transform=C.CFrame}):Play()end else X.Transform=C.CFrame end end end else if self.Character:FindFirstChild(C.Name)then self.Character[C.Name].CFrame=self.Character[C.Name].CFrame*C.CFrame end end end;function N:Play(Y,Z,_)Y=Y or 0.100000001;if self._playing==false or self._isLooping==true then self._playing=true;self._isLooping=false;self.IsPlaying=true;if self.Character:FindFirstChild("Humanoid")and self.Character.Humanoid:FindFirstChild("Animator")and self.handleVanillaAnimator==true then self.Character.Humanoid.Animator:Destroy()end;local a0;a0=self.Character:GetPropertyChangedSignal("Parent"):Connect(function()if self.Character.Parent==nil then self=nil;a0:Disconnect()end end)if self~=nil then local a1=os.clock()coroutine.wrap(function()for x,I in next,self.AnimationData.Frames do I.Time=I.Time/self.Speed;if x~=1 and I.Time>os.clock()-a1 then repeat L.RenderStepped:Wait()until os.clock()-a1>I.Time or self._stopped==true end;if self==nil or self._stopped==true then break end;if I.Name~="Keyframe"then self.KeyframeReached:Fire(I.Name)end;if I["Marker"]then for a2,r in next,I["Marker"]do if self._markerSignal[a2]then self._markerSignal[a2]:Fire(r)end end end;if I.Pose then for w,q in next,I.Pose do Y=Y+I.Time;if x~=1 then Y=(I.Time*self.Speed-self.AnimationData.Frames[x-1].Time)/(_ or self.Speed)end;self:_playPose(q,nil,Y)end end end;if self~=nil then if self.Looped==true and self._stopped~=true then self.DidLoop:Fire()self._isLooping=true;return self:Play(Y,Z,_)end;L.RenderStepped:Wait()local V=TweenInfo.new(self._stopFadeTime,Enum.EasingStyle.Quad,Enum.EasingDirection.In)for w,K in next,g:getMotors(self.Character,self._motorIgnoreList)do if self._stopFadeTime>0 then M:Create(K,V,{Transform=CFrame.new(),CurrentAngle=0}):Play()else K.CurrentAngle=0;K.Transform=CFrame.new()end end;for w,a3 in next,g:getBones(self.Character,self._boneIgnoreList)do if self._stopFadeTime>0 then M:Create(a3,V,{Transform=CFrame.new(0,0,0)*CFrame.Angles(0,0,0)}):Play()else a3.Transform=CFrame.new(0,0,0)*CFrame.Angles(0,0,0)end end;if self.Character:FindFirstChildOfClass("Humanoid")and not self.Character.Humanoid:FindFirstChildOfClass("Animator")and self.handleVanillaAnimator==true then Instance.new("Animator",self.Character.Humanoid)end;a0:Disconnect()self._stopped=false;self._playing=false;self.IsPlaying=false;self.Stopped:Fire()end end)()end end end;function N:GetTimeOfKeyframe(a4)for w,I in next,self.AnimationData.Frames do if I.Name==a4 then return I.Time end end;return math.huge end;function N:GetMarkerReachedSignal(a5)if not self._markerSignal[a5]then self._markerSignal[a5]=c.new()end;return self._markerSignal[a5]end;function N:AdjustSpeed(_)self.Speed=_ end;function N:Stop(Y)self._stopFadeTime=Y or 0.100000001;self._stopped=true end;function N:Destroy()self:Stop(0)self.Stopped:Wait()self.DidLoop:Destroy()self.DidLoop=nil;self.Stopped:Destroy()self.Stopped=nil;self.KeyframeReached:Destroy()self.KeyframeReached=nil;for w,a6 in next,self._markerSignal do a6:Destroy()a6=nil end;self=nil end;getgenv().Animator=N;getgenv().hookAnimatorFunction=function()local a7;a7=hookmetamethod(game,"__namecall",function(a8,...)local a9=getnamecallmethod()if a8.ClassName=="Humanoid"and a9=="LoadAnimation"and checkcaller()then local e={...}if not e[2]or e[2]and e[2]~=true then return N.new(a8.Parent,...)end end;return a7(a8,...)end)g:sendNotif("Hook Loaded\nby whited#4382",nil,5)end;g:sendNotif("API Loaded",nil,5)end