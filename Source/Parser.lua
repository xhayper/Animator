local Utility = animatorRequire("Utility.lua")

local format = string.format

local Parser = {}

function Parser:parsePoseData(Pose)
	if not Pose:IsA("Pose") then
		return warn(format("invalid argument 1 to 'parsePoseData' (Pose expected, got %s)", Pose.ClassName))
	end
	return {Weight = Pose.Weight, CFrame = Pose.CFrame, EasingDirection = Utility:convertEnum(Pose.EasingDirection);  EasingStyle = Utility:convertEnum(Pose.EasingStyle)}
end

function Parser:parseAnimationData(KeyframeSequence)
	if not KeyframeSequence:IsA("KeyframeSequence") then
		return warn(format("invalid argument 1 to 'parseAnimationData' (KeyframeSequence expected, got %s)", KeyframeSequence.ClassName))
	end

	local AnimationData = {Loop = KeyframeSequence.Loop, Priority = KeyframeSequence.Priority, AuthoredHipHeight = KeyframeSequence.AuthoredHipHeight, Frames = {}}

	for i,Frame in pairs(KeyframeSequence:GetChildren()) do
		if Frame:IsA("Keyframe") then
			local FrameData = {Time = Frame.Time, Poses = {}}
			for _,I in pairs(Frame:GetDescendants()) do
				if I:IsA("Pose") then
					local PartName = I.Name
					if FrameData.Poses[PartName] then return warn("Animation have duplicated Pose with same name") end
					FrameData.Poses[PartName] = Parser:parsePoseData(I)
				end
			end
			table.insert(AnimationData.Frames, FrameData)
		end
	end

	table.sort(AnimationData.Frames, function(l, r)
		return l.Time < r.Time
	end)

	return AnimationData
end

return Parser
