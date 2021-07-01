local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Parser = animatorRequire("Parser.lua")
local Utility = animatorRequire("Utility.lua")

local Animator = {isPlaying = false, isStopped = false, Looped = true}
Animator.__index = Animator

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
	return c
end

function Animator:Start()
	if self.isPlaying == false then
		self.isPlaying = true
		self.isStopped = false
		local chr = self.Player.Character
		if chr then
			spawn(function()
				if chr:FindFirstChild("Humanoid") and chr.Humanoid:FindFirstChild("Animator") and chr.Humanoid.Animator:IsA("Animator") then
					chr.Humanoid.Animator:Destroy()
				end
				if chr:FindFirstChild("Animate") and chr.Animate:IsA("LocalScript") then
					chr.Animate.Disabled = true
				end
				local RigMotor = Utility:getRigData(self.Player)
				local lastTick = tick()
				local lastFrameTime = 0
				for frameNumber,Frame in pairs(self.AnimationData.Frames) do
					if Frame.Time ~= 0 then
						if tick() - lastTick < Frame.Time then
							repeat RunService.Heartbeat:Wait() until tick() - lastTick >= Frame.Time
						end
					end
					if self.isStopped == true then
						break;
					end
					for PartName,Pose in pairs(Frame.Poses) do
						local Tweeninfo = TweenInfo.new(Frame.Time - lastFrameTime, Pose.EasingStyle, Pose.EasingDirection)
						if PartName == "HumanoidRootPart" then
							chr.HumanoidRootPart.CFrame *= Pose.CFrame
						else
							local Motor = RigMotor[PartName]
							if Motor then
								TweenService:Create(Motor, Tweeninfo, {
									Transform = Pose.CFrame
								}):Play()
							end
						end
					end
					lastFrameTime = Frame.Time
				end
				self.isPlaying = false
				if self.Looped == true and self.isStopped ~= true then
					return self:Start()
				else
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
				end
			end)
		end
	end
end

function Animator:Stop()
	if self.isPlaying == true then
		self.isPlaying = false
		self.isStopped = true
	end
end

function Animator:GetPlayer()
	return self.Player	
end

return Animator
