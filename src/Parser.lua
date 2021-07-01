local Utility = myRequire("Utility.lua")

local sub,format = string.sub, string.format

local Parser = {}

function Parser:parsePoseData(Pose)
	if not Pose:IsA("Pose") then
		return error(format("invalid argument 1 to 'parsePoseData' (Pose expected, got %s)", Pose.ClassName))
	end
	return {Weight = Pose.Weight, CFrame = Pose.CFrame, EasingDirection = Utility:convertEnum(Pose.EasingDirection);  EasingStyle = Utility:convertEnum(Pose.EasingStyle)}
end

function Parser:parseAnimationData(KeyframeSequence)
	if not KeyframeSequence:IsA("KeyframeSequence") then
		return error(format("invalid argument 1 to 'parseAnimationData' (KeyframeSequence expected, got %s)", KeyframeSequence.ClassName))
	end

	local AnimationData = {Priority = KeyframeSequence.Priority, Frames = {}}

	for i,Frame in pairs(KeyframeSequence:GetChildren()) do
		local FrameData = {Time = Frame.Time, Poses = {}}
		for _,I in pairs(Frame:GetDescendants()) do
			if I:IsA("Pose") then
				local PartName = I.Name
				if FrameData.Poses[PartName] then
					return error("Animation have duplicated Pose with same name")
				else
					FrameData.Poses[PartName] = Parser:parsePoseData(I)
				end
			end
		end
		table.insert(AnimationData.Frames, FrameData)
	end

	table.sort(AnimationData.Frames, function(l, r)
		return l.Time < r.Time
	end)

	return AnimationData
end

return Parser