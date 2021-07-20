local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Parser = animatorRequire("Parser.lua")
local Utility = animatorRequire("Utility.lua")

local Signal = animatorRequire("Nevermore/Signal.lua")
local Maid = animatorRequire("Nevermore/Maid.lua")

local format = string.format

local Animator = {AnimationData = {}, Player = nil, Looped = false, Length = 0, Speed = 1, IsPlaying = false, _stopFadeTime = 0.100000001, _playing = false, _stopped = false, _isLooping = false, _markerSignal = {}}
Animator.__index = Animator

function Animator.new(Player, AnimationResolvable)
	if not Player:IsA("Player") then
		error(format("invalid argument 1 to 'new' (Player expected, got %s)", Player.ClassName))
	end

	local c = setmetatable({}, Animator)
	c.Player = Player

	if typeof(AnimationResolvable) == "string" or typeof(AnimationResolvable) == "number" then -- Assuming that Resolvable is animation id
		local animationInstance = game:GetObjects("rbxassetid://"..tostring(AnimationResolvable))[1]
		if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID expected)") end
		c.AnimationData = Parser:parseAnimationData(animationInstance)
	elseif typeof(AnimationResolvable) == "table" then -- Assuming that Resolvable is animation data table
		c.AnimationData = AnimationResolvable
	elseif typeof(AnimationResolvable) == "Instance" and AnimationResolvable:IsA("KeyframeSequence") then -- Assuming that Resolvable is KeyframeSequence
		c.AnimationData = Parser:parseAnimationData(AnimationResolvable)
	elseif typeof(AnimationResolvable) == "Instance" and AnimationResolvable:IsA("Animation") then -- Assuming that Resolvable is Animation
		local animationInstance = game:GetObjects("rbxassetid://"..tostring(AnimationResolvable.AnimationId))[1]
		if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID inside Animation expected)") end
		c.AnimationData = Parser:parseAnimationData(animationInstance)
	else
		error(format("invalid argument 2 to 'new' (number,string,KeyframeSequence expected, got %s)", Player.ClassName))
	end

	c.Looped = c.AnimationData.Looped
	c.Length = c.AnimationData.Frames[#c.AnimationData.Frames].Time

	c.DidLoop = Signal.new()
	c.Stopped = Signal.new()
	c.KeyframeReached = Signal.new()

	c._maid = Maid.new()
	c._maid:GiveTask(c.DidLoop)
	c._maid:GiveTask(c.Stopped)
	c._maid:GiveTask(c.KeyframeReached)
	return c
end

function Animator:_playPose(pose, parent, fade)
	local RigList = Utility:getMotors(self.Player)
	if pose.Subpose then
		for _,sp in next, pose.Subpose do
			self:_playPose(sp, pose, fade)
		end
	end
	if parent then
		for _,motor in next, RigList do
			if motor.Part0.Name == parent.Name and motor.Part1.Name == pose.Name then
				if fade > 0 then
					local TI = TweenInfo.new(fade, pose.EasingStyle, pose.EasingDirection)
					if self._stopped ~= true then
						TweenService:Create(motor, TI, {Transform = pose.CFrame}):Play()
					end
				else
					motor.Transform = pose.CFrame
				end
			end
		end
	else
		if self.Player.Character[pose.Name] then
			self.Player.Character[pose.Name].CFrame *= pose.CFrame
		end
	end
end

function Animator:Play(fadeTime, weight, speed)
	fadeTime = fadeTime or 0.100000001
	if self._playing == false or self._isLooping == true then
		self._playing = true
		self._isLooping = false
		self.IsPlaying = true
		local Character = self.Player.Character
		if Character.Humanoid:FindFirstChild("Animator") then
			Character.Humanoid.Animator:Destroy()
		end
		local start = os.clock()
		coroutine.wrap(function()
			for i,f in next, self.AnimationData.Frames do
				f.Time /= self.Speed
				if i ~= 1 and f.Time > os.clock()-start then
					repeat RunService.RenderStepped:Wait() until os.clock()-start > f.Time or self._stopped == true
				end
				if self._stopped == true then
					break;
				end
				if f.Name ~= "Keyframe" then
					self.KeyframeReached:Fire(f.Name)
				end
				if f["Marker"] then
					for k,v in next, f["Marker"] do
						if self._markerSignal[k] then
							self._markerSignal[k]:Fire(v)
						end
					end
				end
				if f.Pose then
					for _,p in next, f.Pose do
						fadeTime += f.Time
						if i ~= 1 then
							fadeTime = (f.Time*self.Speed-self.AnimationData.Frames[i-1].Time)/(speed or self.Speed)
						end
						self:_playPose(p, nil, fadeTime)
					end
				end
			end
			if self.Looped then
				self.DidLoop:Fire()
				self._isLooping = true
				self:Play(fadeTime, weight, speed)
			end
			RunService.RenderStepped:Wait()
			for _,r in next, Utility:getMotors(self.Player) do
				TweenService:Create(r, TweenInfo.new(self._stopFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				}):Play()
			end
			if not Character.Humanoid:FindFirstChild("Animator") then
				Instance.new("Animator", Character.Humanoid)
			end
			self.Stopped:Fire()
		end)()
	end
end

function Animator:GetTimeOfKeyframe(keyframeName)
	for i,f in next, self.AnimationData.Frames do
		if i.Name == keyframeName then
			return f.Time
		end
	end
	return math.huge
end

function Animator:GetMarkerReachedSignal(name)
	if not self._markerSignal[name] then
		self._markerSignal[name] = Signal.new()
		self._maid:GiveTask(self._markerSignal[name])
	end
	return self._markerSignal[name]
end

function Animator:AdjustSpeed(speed)
	self.Speed = speed
end

function Animator:Stop(fadeTime)
	self._stopped = true
	self._stopFadeTime = fadeTime or 0.100000001
end

function Animator:Destroy()
	self:Stop()
	self.Stopped:Wait()
	self._maid:Destroy()
	self = nil
end

return Animator
