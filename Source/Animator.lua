local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Parser = animatorRequire("Parser.lua")
local Utility = animatorRequire("Utility.lua")

local Signal = animatorRequire("Nevermore/Signal.lua")

local Animator = {IsPlaying = false, Looped = false, Speed = 1, _Looping = false}
Animator.__index = Animator

local format = string.format

function Animator.new(plr, Animation)
	local c = setmetatable({}, Animator)

	if plr:IsA("Player") ~= true then
		return error(format("invalid argument 1 to 'new' (Player expected, got %s)", plr.ClassName))
	else
		c.Player = plr
	end

	if typeof(Animation) == "table" then
		c.AnimationData = Animation
	elseif typeof(Animation) ~= "number" and typeof(Animation) ~= "string" and Animation:IsA("KeyframeSequence") then
		c.AnimationData = Parser:parseAnimationData(Animation)
	else
		c.AnimationData = Parser:parseAnimationData(game:GetObjects("rbxassetid://"..tostring(Animation))[1])
	end
	table.sort(c.AnimationData.Frames, function(l, r)
		return l.Time < r.Time
	end)
	c.Length = c.AnimationData.Frames[#c.AnimationData.Frames].Time
	c.Looped = c.AnimationData.Loop

	-- SIGNALS --
	c.Stopped = Signal.new()
	c.DidLooped = Signal.new()
	c.KeyframeReached = Signal.new()
	return c
end

function Animator:GetTimeOfKeyframe(keyframeName)
	for _,i in pairs(self.AnimationData.Frames) do
		if i.Name == keyframeName then
			return i.Time
		end
	end
end

function Animator:Play()
	if self.IsPlaying == false or self._Looping == true then
		self.IsPlaying = true
		self._Looping = false
		local chr = self.Player.Character
		if not chr then return end
		spawn(function()
			if chr:FindFirstChild("Humanoid") and chr.Humanoid:FindFirstChild("Animator") and chr.Humanoid.Animator:IsA("Animator") then
				chr.Humanoid.Animator:Destroy()
			end
			if chr:FindFirstChild("Animate") and chr.Animate:IsA("LocalScript") then
				chr.Animate.Disabled = true
			end
			local RigMotor = Utility:getRigData(self.Player)
			local lastFrameTime = 0
			local startTick = tick()
			for _,Frame in pairs(self.AnimationData.Frames) do
				local FrameTime = Frame.Time/self.Speed 
				if FrameTime ~= 0 and tick() - startTick < FrameTime then
					repeat RunService.Heartbeat:Wait() until tick() - startTick >= FrameTime
				end
				if self.IsPlaying == false then break end
				if Frame.Name ~= "Keyframe" then
					spawn(function()
						self.KeyframeReached:Fire(Frame.Name)
					end)
				end
				for PartName,Pose in pairs(Frame.Poses) do
					local Tweeninfo = TweenInfo.new(FrameTime - lastFrameTime, Pose.EasingStyle, Pose.EasingDirection)
					if PartName == "HumanoidRootPart" then
						--chr.HumanoidRootPart.CFrame *= Pose.CFrame
					else
						local Motor = RigMotor[PartName]
						if Motor then
							TweenService:Create(Motor, Tweeninfo, {
								Transform = Pose.CFrame
							}):Play()
						end
					end
				end
				lastFrameTime = FrameTime
			end
			if self.Looped == true and self.IsPlaying == true then
				self.DidLooped:Fire()
				self._Looping = true
				return self:Play()
			end
			self.IsPlaying = false
			wait()
			local defaultCF = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			for _,Motor in pairs(RigMotor) do
				Motor.Transform = defaultCF
			end
			if chr:FindFirstChild("Humanoid") then
				Instance.new("Animator", chr.Humanoid)
			end
			if chr:FindFirstChild("Animate") then
				chr.Animate.Disabled = false
			end
			self.Stopped:Fire()
		end)
	end
end

function Animator:AdjustSpeed(speed)
	self.Speed = speed
end

function Animator:Stop()
	self.IsPlaying = false
end

function Animator:GetPlayer()
	return self.Player
end

function Animator:Destroy()
	self:Stop()
	self.Stopped:Wait()
	self = nil
end

return Animator