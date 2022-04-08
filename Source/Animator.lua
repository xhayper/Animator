local TweenService = game:GetService("TweenService")

local Parser = animatorRequire("Parser.lua")
local Utility = animatorRequire("Utility.lua")

local Signal = animatorRequire("Nevermore/Signal.lua")
local Maid = animatorRequire("Nevermore/Maid.lua")

function merge(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				merge(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

local Animator = {
	AnimationData = {},
	BoneIgnoreInList = {},
	MotorIgnoreInList = {},
	BoneIgnoreList = {},
	MotorIgnoreList = {},
	handleVanillaAnimator = true,
	Character = nil,
	Looped = false,
	Length = 0,
	Speed = 1,
	IsPlaying = false,
	_stopFadeTime = 0.100000001,
	_playing = false,
	_stopped = false,
	_isLooping = false,
	_markerSignal = {},
}

local CF, Angles = CFrame.new, CFrame.Angles
local format = string.format
local spawn = task.spawn
local wait = task.wait
local clock = os.clock
local deg = math.deg

local DefaultMotorCF = CF()
local DefaultBoneCF = DefaultMotorCF * Angles(deg(0), deg(0), deg(0))

Animator.__index = Animator

function Animator.new(Character, AnimationResolvable)
	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'new' (Instace expected, got %s)", typeof(Character)))
	end

	local self = setmetatable({}, Animator)
	local type = typeof(AnimationResolvable)

	-- TODO: Optimize this by merging `AnimationResolvable.ClassName == "Animation"` with `type == "string" or type == "number"`
	if type == "string" or type == "number" then
		local keyframeSequence = game:GetObjects("rbxassetid://" .. tostring(AnimationResolvable))[1]
		if keyframeSequence.ClassName ~= "KeyframeSequence" then
			error("invalid argument 2 to 'new' (string,number expected)")
		end
		self.AnimationData = Parser:parseAnimationData(keyframeSequence)
	elseif type == "table" then
		self.AnimationData = AnimationResolvable
	elseif type == "Instance" then
		if AnimationResolvable.ClassName == "KeyframeSequence" then
			self.AnimationData = Parser:parseAnimationData(AnimationResolvable)
		elseif AnimationResolvable.ClassName == "Animation" then
			local keyframeSequence = game:GetObjects(AnimationResolvable.AnimationId)[1]
			if keyframeSequence.ClassName ~= "KeyframeSequence" then
				error("invalid argument 2 to 'new' (Content inside Animation expected)")
			end
			self.AnimationData = Parser:parseAnimationData(keyframeSequence)
		end
	else
		error(format("invalid argument 2 to 'new' (number,string,table,Instance expected, got %s)", type))
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
	return self
end

function Animator:IgnoreMotor(inst)
	if typeof(inst) ~= "Instance" then
		error(format("invalid argument 1 to 'IgnoreMotor' (Instance expected, got %s)", typeof(inst)))
	end
	if inst.ClassName ~= "Motor6D" then
		error(format("invalid argument 1 to 'IgnoreMotor' (Motor6D expected, got %s)", inst.ClassName))
	end
	table.insert(self.MotorIgnoreList, inst)
end

function Animator:IgnoreBone(inst)
	if typeof(inst) ~= "Instance" then
		error(format("invalid argument 1 to 'IgnoreBone' (Instance expected, got %s)", typeof(inst)))
	end
	if inst.ClassName ~= "Bone" then
		error(format("invalid argument 1 to 'IgnoreBone' (Bone expected, got %s)", inst.ClassName))
	end
	table.insert(self.BoneIgnoreList, inst)
end

function Animator:IgnoreMotorIn(inst)
	if typeof(inst) ~= "Instance" then
		error(format("invalid argument 1 to 'IgnoreMotorIn' (Instance expected, got %s)", typeof(inst)))
	end
	table.insert(self.MotorIgnoreInList, inst)
end

function Animator:IgnoreBoneIn(inst)
	if typeof(inst) ~= "Instance" then
		error(format("invalid argument 1 to 'IgnoreBoneIn' (Instance expected, got %s)", typeof(inst)))
	end
	table.insert(self.BoneIgnoreInList, inst)
end

function Animator:_playPose(pose, parent, fade)
	if pose.Subpose then
		local SubPose = pose.Subpose
		for count = 1, #SubPose do
			local sp = SubPose[count]
			self:_playPose(sp, pose, fade)
		end
	end
	if not parent then
		return
	end
	local MotorMap = Utility:getMotorMap(self.Character, {
		IgnoreIn = self.MotorIgnoreInList,
		IgnoreList = self.MotorIgnoreList,
	})
	local BoneMap = Utility:getBoneMap(self.Character, {
		IgnoreIn = self.BoneIgnoreInList,
		IgnoreList = self.BoneIgnoreList,
	})
	local TI = TweenInfo.new(fade, pose.EasingStyle, pose.EasingDirection)
	local Target = { Transform = pose.CFrame }
	local M = MotorMap[parent.Name]
	local B = BoneMap[parent.Name]
	local C = {}
	if M then
		local MM = M[pose.Name] or {}
		C = merge(C, MM)
	end
	if B then
		local BB = B[pose.Name] or {}
		C = merge(C, BB)
	end
	for count = 1, #C do
		local obj = C[count]
		if self == nil or self._stopped then
			break
		end
		if fade > 0 then
			TweenService:Create(obj, TI, Target):Play()
		else
			obj.Transform = pose.CFrame
		end
	end
end

function Animator:Play(fadeTime, weight, speed)
	fadeTime = fadeTime or 0.100000001
	if not self.Character or self.Character.Parent == nil or self._playing and not self._isLooping then
		return
	end
	self._playing = true
	self._isLooping = false
	self.IsPlaying = true
	local deathConnection
	local noParentConnection
	do
		local Humanoid = self.Character:FindFirstChild("Humanoid")
		if Humanoid then
			deathConnection = Humanoid.Died:Connect(function()
				self:Destroy()
				deathConnection:Disconnect()
			end)
		end
		if self.handleVanillaAnimator then
			local AnimateScript = self.Character:FindFirstChild("Animate")
			if AnimateScript then
				AnimateScript.Disabled = true
			end
			if Humanoid then
				local characterAnimator = Humanoid:FindFirstChild("Animator")
				if characterAnimator then
					do
						local animationTrack = characterAnimator:GetPlayingAnimationTracks()
						for i = 1, #animationTrack do
							animationTrack[i]:Stop()
						end
					end
					characterAnimator:Destroy()
				end
			end
		end
		noParentConnection = self.Character:GetPropertyChangedSignal("Parent"):Connect(function()
			if self ~= nil and self.Character.Parent ~= nil then
				return
			end
			self:Destroy()
			noParentConnection:Disconnect()
		end)
	end
	local start = clock()
	spawn(function()
		for i = 1, #self.AnimationData.Frames do
			if self._stopped then
				break
			end
			local f = self.AnimationData.Frames[i]
			local t = f.Time / (speed or self.Speed)
			if f.Name ~= "Keyframe" then
				self.KeyframeReached:Fire(f.Name)
			end
			if f["Marker"] then
				for k, v in next, f.Marker do
					if not self._markerSignal[k] then
						continue
					end
					for _, v2 in next, v do
						self._markerSignal[k]:Fire(v2)
					end
				end
			end
			if f.Pose then
				local Pose = f.Pose
				for count = 1, #Pose do
					local p = Pose[count]
					local ft = fadeTime
					if i ~= 1 then
						ft = (t * (speed or self.Speed) - self.AnimationData.Frames[i - 1].Time) / (speed or self.Speed)
					end
					self:_playPose(p, nil, ft)
				end
			end
			if t > clock() - start then
				repeat
					wait()
				until self._stopped or clock() - start >= t
			end
		end
		if deathConnection then
			deathConnection:Disconnect()
			deathConnection = nil
		end
		if noParentConnection then
			noParentConnection:Disconnect()
			noParentConnection = nil
		end
		if self.Looped and not self._stopped then
			self.DidLoop:Fire()
			self._isLooping = true
			return self:Play(fadeTime, weight, speed)
		end
		wait()
		if self.Character then
			local TI = TweenInfo.new(self._stopFadeTime or fadeTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
			local MotorMap = Utility:getMotorMap(self.Character, {
				IgnoreIn = self.MotorIgnoreInList,
				IgnoreList = self.MotorIgnoreList,
			})
			local BoneMap = Utility:getBoneMap(self.Character, {
				IgnoreIn = self.BoneIgnoreInList,
				IgnoreList = self.BoneIgnoreList,
			})
			for _, motors in pairs(MotorMap) do
				for _, motors in pairs(motors) do
					for _, motor in pairs(motors) do
						if (self._stopFadeTime or fadeTime) > 0 then
							TweenService
								:Create(motor, TI, {
									Transform = DefaultMotorCF,
									CurrentAngle = 0,
								})
								:Play()
						else
							motor.CurrentAngle = 0
							motor.Transform = DefaultMotorCF
						end
					end
				end
			end
			for _, bones in pairs(BoneMap) do
				for _, bones in pairs(bones) do
					for _, bone in pairs(bones) do
						if (self._stopFadeTime or fadeTime) > 0 then
							TweenService
								:Create(bone, TI, {
									Transform = DefaultBoneCF,
								})
								:Play()
						else
							bone.Transform = DefaultBoneCF
						end
					end
				end
			end
			if self.handleVanillaAnimator then
				local Humanoid = self.Character:FindFirstChild("Humanoid")
				if Humanoid and not Humanoid:FindFirstChildOfClass("Animator") then
					Instance.new("Animator").Parent = Humanoid
				end
				local AnimateScript = self.Character:FindFirstChild("Animate")
				if AnimateScript and AnimateScript.Disabled then
					AnimateScript.Disabled = false
				end
			end
		end
		self._stopped = false
		self._playing = false
		self.IsPlaying = false
		self.Stopped:Fire()
	end)
end

function Animator:GetTimeOfKeyframe(keyframeName)
	for count = 1, #self.AnimationData.Frames do
		local f = self.AnimationData.Frames[count]
		if f.Name ~= keyframeName then
			continue
		end
		return f.Time
	end
	return 0
end

function Animator:GetMarkerReachedSignal(name)
	if not self._markerSignal[name] then
		self._markerSignal[name] = Signal.new()
		self._maid["M_" .. name] = self._markerSignal[name]
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
end

return Animator
