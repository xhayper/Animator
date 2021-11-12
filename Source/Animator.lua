local TweenService = game:GetService("TweenService")

local Parser = animatorRequire("Parser.lua")
local Utility = animatorRequire("Utility.lua")

local Signal = animatorRequire("Nevermore/Signal.lua")
local Maid = animatorRequire("Nevermore/Maid.lua")

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
local DefaultBoneCF = DefaultMotorCF*Angles(deg(0),deg(0),deg(0))

Animator.__index = Animator

function Animator.new(Character, AnimationResolvable)
	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'new' (Instace expected, got %s)", typeof(Character)))
	end

	local self = setmetatable({}, Animator)

	if typeof(AnimationResolvable) == "string" or typeof(AnimationResolvable) == "number" then
		local animationInstance = game:GetObjects("rbxassetid://"..tostring(AnimationResolvable))[1]
		if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID expected)") end
		self.AnimationData = Parser:parseAnimationData(animationInstance)
	elseif typeof(AnimationResolvable) == "table" then
		self.AnimationData = AnimationResolvable
	elseif typeof(AnimationResolvable) == "Instance" then
		if AnimationResolvable:IsA("KeyframeSequence") then
			self.AnimationData = Parser:parseAnimationData(AnimationResolvable)
		elseif AnimationResolvable:IsA("Animation") then
			local animationInstance = game:GetObjects(AnimationResolvable.AnimationId)[1]
			if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID inside Animation expected)") end
			self.AnimationData = Parser:parseAnimationData(animationInstance)
		end
	else
		error(format("invalid argument 2 to 'new' (number,string,table,Instance expected, got %s)", typeof(AnimationResolvable)))
	end

	self.Character = Character

	self.Looped = self.AnimationData.Loop
	self.Length = self.AnimationData.Frames[#self.AnimationData.Frames].Time

	self._maid = Maid.new()

	self.DidLoop = Signal.new()
	self.Stopped = Signal.new()
	self.KeyframeReached = Signal.new()
	
	self._maid.DidLoop = self.DidLoop 
	self._maid.Stopped = self.Stopped
	self._maid.KeyframeReached = self.KeyframeReached
	self._table = self
	return self
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
		local SubPose = pose.Subpose
		for count=1, #SubPose do
			local sp = SubPose[count]
			self:_playPose(sp, pose, fade)
		end
	end
	if not parent then return end
	local TI = TweenInfo.new(fade, pose.EasingStyle, pose.EasingDirection)
	task.spawn(function()
		for count=1, #MotorList do
			local motor = MotorList[count]
			if motor.Part0.Name ~= parent.Name or motor.Part1.Name ~= pose.Name then continue end
			if self == nil or self._stopped then break end
			if fade > 0 then
				TweenService:Create(motor, TI, {Transform = pose.CFrame}):Play()
			else
				motor.Transform = pose.CFrame
			end
		end
	end)
	task.spawn(function()
		for count=1, #BoneList do
			local bone = BoneList[count]
			if parent.Name ~= bone.Parent.Name or bone.Name ~= pose.Name then continue end
			if self == nil or self._stopped then break end
			if fade > 0 then
				TweenService:Create(bone, TI, {Transform = pose.CFrame}):Play()
			else
				bone.Transform = pose.CFrame
			end
		end
	end)
end

function Animator:Play(fadeTime, weight, speed)
	fadeTime = fadeTime or 0.100000001
	if self._playing and not self._isLooping then return end
	self._playing = true
	self._isLooping = false
	self.IsPlaying = true
	local con
	local con2
	if not self.Character then return end
	if self.Character:FindFirstChild("Humanoid") then
		con = self.Character.Humanoid.Died:Connect(function()
			self:Destroy()
			con:Disconnect()
		end)
		if self.handleVanillaAnimator and self.Character.Humanoid:FindFirstChild("Animator") then
			self.Character.Humanoid.Animator:Destroy()
		end
	end
	con2 = self.Character:GetPropertyChangedSignal("Parent"):Connect(function()
		if self ~= nil and self.Character.Parent ~= nil then return end
		self:Destroy()
		con2:Disconnect()
	end)
	if self == nil or self.Character.Parent == nil then return end
	local start = clock()
	task.spawn(function()
		for i=1, #self.AnimationData.Frames do
			local f = self.AnimationData.Frames[i]
			if self == nil or self._stopped then break end
			local t = f.Time / (speed or self.Speed)
			if f.Name ~= "Keyframe" then
				self.KeyframeReached:Fire(f.Name)
			end
			if f["Marker"] then
				for k,v in next, f.Marker do
					if not self._markerSignal[k] then continue end
					self._markerSignal[k]:Fire(v)
				end
			end
			if f.Pose then
				local Pose = f.Pose
				for count=1, #Pose do
					local p = Pose[count]
					local ft = fadeTime
					if i ~= 1 then
						ft = (t*(speed or self.Speed)-self.AnimationData.Frames[i-1].Time)/(speed or self.Speed)
					end
					self:_playPose(p, nil, ft)
				end
			end
			if t > clock()-start then
				repeat task.wait() until self == nil or self._stopped or clock()-start >= t
			end
		end
		if self == nil then return end
		if self.Looped and not self._stopped then
			self.DidLoop:Fire()
			self._isLooping = true
			return self:Play(fadeTime, weight, speed)
		end
		task.wait()
		local TI = TweenInfo.new(self._stopFadeTime or fadeTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
		if self.Character then
			local MotorList = Utility:getMotors(self.Character, self._motorIgnoreList)
			local BoneList = Utility:getBones(self.Character, self._boneIgnoreList)
			for count=1, #MotorList do
				local r = MotorList[count]
				if (self._stopFadeTime or fadeTime) > 0 then
					TweenService:Create(r, TI, {
						Transform = DefaultMotorCF,
						CurrentAngle = 0
					}):Play()
				else
					r.CurrentAngle = 0
					r.Transform = DefaultMotorCF
				end
			end
			for count=1, #BoneList do
				local b = BoneList[count]
				if (self._stopFadeTime or fadeTime) > 0 then
					TweenService:Create(b, TI, {Transform = DefaultBoneCF}):Play()
				else
					b.Transform = DefaultBoneCF
				end
			end
			if self.handleVanillaAnimator and self.Character:FindFirstChild("Humanoid") and not self.Character.Humanoid:FindFirstChildOfClass("Animator") then
				Instance.new("Animator").Parent = self.Character.Humanoid
			end
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

function Animator:GetTimeOfKeyframe(keyframeName)
	for count=1, #self.AnimationData.Frames do
		local f = self.AnimationData.Frames[count]
		if f.Name ~= keyframeName then continue end
		return f.Time
	end
	return math.huge
end

function Animator:GetMarkerReachedSignal(name)
	if not self._markerSignal[name] then
		self._markerSignal[name] = Signal.new()
		self._maid["Marker_"..name] = self._markerSignal[name]
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
	self._maid:DoCleaning()
	setmetatable(self._table, nil)
end

return Animator
