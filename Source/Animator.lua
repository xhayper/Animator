local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Parser = animatorRequire("Parser.lua")
local Utility = animatorRequire("Utility.lua")

local Signal = animatorRequire("Nevermore/Signal.lua")

local Animator = {
	AnimationData = {},
	handleVanillaAnimator = true, 
	Character = nil, 
	Looped = false, 
	Length = 0,
	Speed = 1,
	IsPlaying = false,
	_motorIgnoreList = {},
	_stopFadeTime = 0.100000001,
	_playing = false,
	_stopped = false,
	_isLooping = false,
	_markerSignal = {},
	_boneIgnoreList = {}
}

local CF,Angles = CFrame.new, CFrame.Angles
local deg = math.deg
local clock = os.clock
local format = string.format

local DefaultMotorCF = CF()
local DefaultBoneCF = CF(0,0,0)*Angles(deg(0),deg(0),deg(0))

Animator.__index = Animator

function Animator.new(Character, AnimationResolvable)
	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'new' (Instace expected, got %s)", typeof(Character)))
	end

	local c = setmetatable({}, Animator)
	c.Character = Character

	if typeof(AnimationResolvable) == "string" or typeof(AnimationResolvable) == "number" then
		local animationInstance = game:GetObjects("rbxassetid://"..tostring(AnimationResolvable))[1]
		if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID expected)") end
		c.AnimationData = Parser:parseAnimationData(animationInstance)
	elseif typeof(AnimationResolvable) == "table" then
		c.AnimationData = AnimationResolvable
	elseif typeof(AnimationResolvable) == "Instance" and AnimationResolvable:IsA("KeyframeSequence") then
		c.AnimationData = Parser:parseAnimationData(AnimationResolvable)
	elseif typeof(AnimationResolvable) == "Instance" and AnimationResolvable:IsA("Animation") then
		local animationInstance = game:GetObjects(AnimationResolvable.AnimationId)[1]
		if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID inside Animation expected)") end
		c.AnimationData = Parser:parseAnimationData(animationInstance)
	else
		error(format("invalid argument 2 to 'new' (number,string,table,Instance expected, got %s)", typeof(AnimationResolvable)))
	end

	c.Looped = c.AnimationData.Loop
	c.Length = c.AnimationData.Frames[#c.AnimationData.Frames].Time

	c.DidLoop = Signal.new()
	c.Stopped = Signal.new()
	c.KeyframeReached = Signal.new()
	return c
end

function Animator:IgnoreMotorIn(ignoreList)
	if typeof(ignoreList) ~= "table" then
		error(format("invalid argument 1 to 'IgnoreMotorIn' (Table expected, got %s)", typeof(ignoreList)))
	end
	self._motorIgnoreList = ignoreList
end

function Animator:GetMotorIgnoreList()
	return self._motorIgnoreList
end

function Animator:IgnoreBoneIn(ignoreList)
	if typeof(ignoreList) ~= "table" then
		error(format("invalid argument 1 to 'IgnoreBoneIn' (Table expected, got %s)", typeof(ignoreList)))
	end
	self._boneIgnoreList = ignoreList
end

function Animator:GetBoneIgnoreList()
	return self._boneIgnoreList
end

function Animator:_playPose(pose, parent, fade)
	local MotorList = Utility:getMotors(self.Character, self._motorIgnoreList)
	local BoneList = Utility:getBones(self.Character, self._boneIgnoreList)
	if pose.Subpose then
		for _,sp in next, pose.Subpose do
			self:_playPose(sp, pose, fade)
		end
	end
	if not parent then return end
	local TI = TweenInfo.new(fade, pose.EasingStyle, pose.EasingDirection)
	for _,motor in next, MotorList do
		if motor.Part0.Name == parent.Name and motor.Part1.Name == pose.Name then
			if fade > 0 then
				if self._stopped ~= true then
					TweenService:Create(motor, TI, {Transform = pose.CFrame}):Play()
				end
			else
				motor.Transform = pose.CFrame
			end
		end
	end
	for _, bone in next, BoneList do
		if parent.Name == bone.Parent.Name and bone.Name == pose.Name then
			if fade > 0 then
				if self._stopped ~= true then
					TweenService:Create(bone, TI, {Transform = pose.CFrame}):Play()
				end
			else
				bone.Transform = pose.CFrame
			end
		end
	end
end

function Animator:Play(fadeTime, weight, speed)
	fadeTime = fadeTime or 0.100000001
	if self._playing == false or self._isLooping == true then
		self._playing = true
		self._isLooping = false
		self.IsPlaying = true
		local con
		if self.Character:FindFirstChild("Humanoid") then
			con = self.Character.Humanoid.Died:Connect(function()
				self = nil
				con:Disconnect()
			end)
			if self.Character.Humanoid:FindFirstChild("Animator") and self.handleVanillaAnimator == true then
				self.Character.Humanoid.Animator:Destroy()
			end
		end
		local con2
		con2 = self.Character:GetPropertyChangedSignal("Parent"):Connect(function()
			if self == nil or self.Character.Parent == nil then
				self = nil
				con2:Disconnect()
			end
		end)
		if self ~= nil and self.Character.Parent ~= nil then
			local start = clock()
			spawn(function()
				for i,f in next, self.AnimationData.Frames do
					if self == nil or self._stopped == true then break end
					local t = f.Time / (speed or self.Speed)
					if f.Name ~= "Keyframe" then
						self.KeyframeReached:Fire(f.Name)
					end
					if f["Marker"] then
						for k,v in next, f.Marker do
							if self._markerSignal[k] then
								self._markerSignal[k]:Fire(v)
							end
						end
					end
					if f.Pose then
						for _,p in next, f.Pose do
							local ft = 0
							if i ~= 1 then
								ft = (t*(speed or self.Speed)-self.AnimationData.Frames[i-1].Time)/(speed or self.Speed)
							end
							self:_playPose(p, nil, ft)
						end
					end
					if t > clock()-start then
						repeat RunService.RenderStepped:Wait() until self == nil or self._stopped == true or clock()-start >= t
					end
				end
				if self == nil then return end
					if self.Looped == true and self._stopped ~= true then
						self.DidLoop:Fire()
						self._isLooping = true
						return self:Play(fadeTime, weight, speed)
					end
					RunService.RenderStepped:Wait()
					local TI = TweenInfo.new(self._stopFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					for _,r in next, Utility:getMotors(self.Character, self._motorIgnoreList) do
						if self._stopFadeTime > 0 then
							TweenService:Create(r, TI, {
								Transform = DefaultMotorCF,
								CurrentAngle = 0
							}):Play()
						else
							r.CurrentAngle = 0
							r.Transform = DefaultMotorCF
						end
					end
					for _, b in next, Utility:getBones(self.Character, self._boneIgnoreList) do
						if self._stopFadeTime > 0 then
							TweenService:Create(b, TI, {Transform = DefaultBoneCF}):Play()
						else
							b.Transform = DefaultBoneCF
						end
					end
					if self.Character:FindFirstChildOfClass("Humanoid") and not self.Character.Humanoid:FindFirstChildOfClass("Animator") and self.handleVanillaAnimator == true then
						Instance.new("Animator", self.Character.Humanoid)
					end
					if con then
						con:Disconnect()
					end
					con2:Disconnect()
					self._stopped = false
					self._playing = false
					self.IsPlaying = false
					self.Stopped:Fire()
			end)
		end
	end
end

function Animator:GetTimeOfKeyframe(keyframeName)
	for _,f in next, self.AnimationData.Frames do
		if f.Name == keyframeName then
			return f.Time
		end
	end
	return math.huge
end

function Animator:GetMarkerReachedSignal(name)
	if not self._markerSignal[name] then
		self._markerSignal[name] = Signal.new()
	end
	return self._markerSignal[name]
end

function Animator:AdjustSpeed(speed)
	self.Speed = speed
end

function Animator:Stop(fadeTime)
	self._stopFadeTime = fadeTime or 0.100000001
	self._stopped = true
end

function Animator:Destroy()
	self:Stop(0)
	self.Stopped:Wait()

	-- Maid won't work properly so.
	self.DidLoop:Destroy()
	self.DidLoop = nil
	self.Stopped:Destroy()
	self.Stopped = nil
	self.KeyframeReached:Destroy()
	self.KeyframeReached = nil
	for _,s in next, self._markerSignal do
		s:Destroy()
		s = nil
	end
	self = nil
end

return Animator