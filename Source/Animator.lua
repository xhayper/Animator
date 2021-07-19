local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Parser = animatorRequire("Parser.lua")
local Utility = animatorRequire("Utility.lua")

local Signal = animatorRequire("Nevermore/Signal.lua")
local Maid = animatorRequire("Nevermore/Maid.lua")

local format = string.format

local Animator = {AnimationData = {}, Player = nil, Looped = false, Length = 0, Speed = 1, IsPlaying = false, _playing = false, _stopped = false}
Animator.__index = Animator

function Animator.new(Player, AnimationResolvable)
	if not Player:IsA("Player") then
		error(format("invalid argument 1 to 'new' (Player expected, got %s)", Player.ClassName))
	end

	local c = setmetatable({}, Animator)
	c.Player = Player

	if typeof(AnimationResolvable) == "string" or typeof(AnimationResolvable) == "number" then -- Assuming that Resolvable is animation id
		local animationInstance = game:GetObjects("rbxassetid://"..tostring(AnimationResolvable))[1]:FindFirstChildWhichIsA("KeyframeSequence")
		if not animationInstance then error("invalid argument 1 to 'new' (AnimationID expected)") end
		c.AnimationData = Parser:parseAnimationData(animationInstance)
	elseif typeof(AnimationResolvable) == "table" then -- Assuming that Resolvable is animation data table
		c.AnimationData = {}
	elseif typeof(AnimationResolvable) == "Instance" and AnimationResolvable:IsA("KeyframeSequence") then -- Assuming that Resolvable is KeyframeSequence
		c.AnimationData = Parser:parseAnimationData(AnimationResolvable)
	else
		error(format("invalid argument 2 to 'new' (number,string,KeyframeSequence expected, got %s)", Player.ClassName))
	end

	c.Looped = c.AnimationData.Looped
	c.Length = c.AnimationData.Frames[#c.AnimationData.Frames].Time

	c.DidLoop = Signal.new()
	c.Stopped = Signal.new()
	return c
end

function Animator:_playPose(pose, parent, fade)
	local RigList = Utility:getMotors(self.Player)
	if pose.SubPose then
		for _,sp in next, pose.SubPose do
			self:_playPose(sp, pose, fade)
		end
	end
	if parent then
		for _,motor in next, RigList do
			if motor.Part0.Name == parent.Name and motor.Part1 == pose.Name then
				local TI = TweenInfo.new(fade, pose.EasingStyle, pose.EasingDirection)
				TweenService:Create(motor, TI, {Transform = pose.CFrame}):Play()
			end
		end
	end
end

function Animator:Play(force)
	if self._playing == false then
		self._playing = true
		self.IsPlaying = true
		local Character = self.Player.Character
		if Character.Humanoid:FindFirstChild("Animator") and Character.Humanoid.Animator:IsA("Animator") then
			Character.Humanoid.Animator:Destroy()
		end
		if Character:FindFirstChild("Animate") and Character.Animate:IsA("LocalScript") then
			Character.Animate.Disabled = true
		end
		local start = os.clock()
		for i,f in next, self.AnimationData.Frames do
			print(f.Time * self.Speed and self.Speed >= 1 or f.Time / self.Speed)
			if i ~= 1 and f.Time * self.Speed and self.Speed >= 1 or f.Time / self.Speed then
				repeat print(f.Time, os.clock()-start); RunService.RenderStepped:Wait() until os.clock()-start > f.Time * self.Speed and self.Speed >= 1 or f.Time / self.Speed
			end
			if self._stopped == true then
				break;
			end
			if f.Pose then
				local fadeTime = f.Time
				if i ~= 1 then
					fadeTime = f.Time-self.AnimationData.Frames[i-1]
				end
				self:_playPose(f.Pose, nil, fadeTime)
			end
		end
		if self.Looped then
			self.DidLoop:Fire()
			self:Play(true)
		end
		if not Character.Humanoid:FindFirstChild("Animator") or not Character.Humanoid.Animator:IsA("Animator") then
			Instance.new("Animator", Character.Humanoid)
		end
		if Character:FindFirstChild("Animate") and Character.Animate:IsA("LocalScript") and Character.Animate.Disabled == true then
			Character.Animate.Disabled = false
		end
		self.Stopped:Fire()
	end
end

function Animator:AdjustSpeed(speed)
	self.Speed = speed
end

function Animator:Stop()
	self._stopped = true
end

return Animator