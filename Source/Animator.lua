local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local TweenService = game:GetService("TweenService")

local Parser = animatorRequire("Parser.lua")
local Utility = animatorRequire("Utility.lua")

local Signal = animatorRequire("Nevermore/Signal.lua")
local Maid = animatorRequire("Nevermore/Maid.lua")

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
local move = table.move
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
	if type == "string" or type == "number" then
		local keyframeSequence = KeyframeSequenceProvider:GetKeyframeSequenceAsync(tostring(AnimationResolvable))
		self.AnimationData = Parser:parseAnimationData(keyframeSequence)
	elseif type == "table" then
		self.AnimationData = AnimationResolvable
	elseif type == "Instance" then
		if AnimationResolvable.ClassName == "KeyframeSequence" then
			self.AnimationData = Parser:parseAnimationData(AnimationResolvable)
		elseif AnimationResolvable.ClassName == "Animation" then
			local keyframeSequence = KeyframeSequenceProvider:GetKeyframeSequenceAsync(
				tostring(AnimationResolvable.AnimationId)
			)
			self.AnimationData = Parser:parseAnimationData(keyframeSequence)
		end
	else
		error(
			format(
				"invalid argument 2 to 'new' (number,string,table,Instance expected, got %s)",
				typeof(AnimationResolvable)
			)
		)
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
	self.MotorIgnoreList[#self.MotorIgnoreList + 1] = inst
end

function Animator:IgnoreBone(inst)
	if typeof(inst) ~= "Instance" then
		error(format("invalid argument 1 to 'IgnoreBone' (Instance expected, got %s)", typeof(inst)))
	end
	if inst.ClassName ~= "Bone" then
		error(format("invalid argument 1 to 'IgnoreBone' (Bone expected, got %s)", inst.ClassName))
	end
	self.BoneIgnoreList[#self.BoneIgnoreList + 1] = inst
end

function Animator:IgnoreMotorIn(inst)
	if typeof(inst) ~= "Instance" then
		error(format("invalid argument 1 to 'IgnoreMotorIn' (Instance expected, got %s)", typeof(inst)))
	end
	self.MotorIgnoreInList[#self.MotorIgnoreInList + 1] = inst
end

function Animator:IgnoreBoneIn(inst)
	if typeof(inst) ~= "Instance" then
		error(format("invalid argument 1 to 'IgnoreBoneIn' (Instance expected, got %s)", typeof(inst)))
	end
	self.BoneIgnoreInList[#self.BoneIgnoreInList + 1] = inst
end

function Animator:_playPose(pose, parent, fade)
	local MotorMap = Utility:getMotorMap(self.Character, {
		IgnoreIn = self.MotorIgnoreInList,
		IgnoreList = self.MotorIgnoreList,
	})
	local BoneMap = Utility:getBoneMap(self.Character, {
		IgnoreIn = self.BoneIgnoreInList,
		IgnoreList = self.BoneIgnoreList,
	})
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
	local TI = TweenInfo.new(fade, pose.EasingStyle, pose.EasingDirection)
	local Target = { Transform = pose.CFrame }
	local M = MotorMap[parent.Name]
	local B = BoneMap[parent.Name]
	local C = {}
	if M then
		local MM = M[pose.Name]
		move(MM, 1, #MM, 1, C)
	end
	if B then
		local BB = B[pose.Name]
		move(BB, 1, #BB, #C + 1, C)
	end
	for count = 1, #C do
		local motor = C[count]
		if self == nil or self._stopped then
			break
		end
		if fade > 0 then
			TweenService:Create(motor, TI, Target):Play()
		else
			motor.Transform = pose.CFrame
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
	local con
	local con2
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
		if self ~= nil and self.Character.Parent ~= nil then
			return
		end
		self:Destroy()
		con2:Disconnect()
	end)
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
		if con then
			con:Disconnect()
		end
		if con2 then
			con2:Disconnect()
		end
		if self.Looped and not self._stopped then
			self.DidLoop:Fire()
			self._isLooping = true
			return self:Play(fadeTime, weight, speed)
		end
		wait()
		local TI = TweenInfo.new(self._stopFadeTime or fadeTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
		if self.Character then
			local MotorList = Utility:getMotors(self.Character, {
				IgnoreIn = self.MotorIgnoreInList,
				IgnoreList = self.MotorIgnoreList,
			})
			local BoneList = Utility:getBones(self.Character, {
				IgnoreIn = self.BoneIgnoreInList,
				IgnoreList = self.BoneIgnoreList,
			})
			for count = 1, #MotorList do
				local r = MotorList[count]
				if (self._stopFadeTime or fadeTime) > 0 then
					TweenService
						:Create(r, TI, {
							Transform = DefaultMotorCF,
							CurrentAngle = 0,
						})
						:Play()
				else
					r.CurrentAngle = 0
					r.Transform = DefaultMotorCF
				end
			end
			for count = 1, #BoneList do
				local b = BoneList[count]
				if (self._stopFadeTime or fadeTime) > 0 then
					TweenService:Create(b, TI, { Transform = DefaultBoneCF }):Play()
				else
					b.Transform = DefaultBoneCF
				end
			end
			if
				self.handleVanillaAnimator
				and self.Character:FindFirstChild("Humanoid")
				and not self.Character.Humanoid:FindFirstChildOfClass("Animator")
			then
				Instance.new("Animator").Parent = self.Character.Humanoid
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
		self._maid["Marker_" .. name] = self._markerSignal[name]
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
