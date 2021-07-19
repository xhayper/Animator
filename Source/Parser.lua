local Utility = animatorRequire("Utility.lua")

local format = string.format

local Parser = {}

function Parser:parsePoseData(pose)
	if not pose:IsA("Pose") then
		error(format("invalid argument 1 to '_parsePoseData' (Pose expected, got %s)", pose.ClassName))
	end
	local poseData = {Name = pose.Name, CFrame = pose.CFrame, EasingDirection = Utility:convertEnum(pose.EasingDirection), EasingStyle = Utility:convertEnum(pose.EasingStyle), Weight = pose.Weight}
	print(#pose:GetChildren())
	if #pose:GetChildren() > 0 then
		poseData.Subpose = {}
		for _,p in next, pose:GetChildren() do
			if p:IsA("Pose") then
				table.insert(poseData.Subpose, Parser:parsePoseData(p))
			end
		end
	end
	return poseData
end

function Parser:parseKeyframeData(keyframe)
	if not keyframe:IsA("Keyframe") then
		error(format("invalid argument 1 to '_parseKeyframeData' (Keyframe expected, got %s)", keyframe.ClassName))
	end
	local keyframeData = {Name = keyframe.Name, Time = keyframe.Time, Pose = {}}
	for _,p in next, keyframe:GetChildren() do
		if p:IsA("Pose") then
			table.insert(keyframeData.Pose, Parser:parsePoseData(p))
		end
	end
	return keyframeData
end

function Parser:parseAnimationData(keyframeSequence)
	if not keyframeSequence:IsA("KeyframeSequence") then
		error(format("invalid argument 1 to 'parseAnimationData' (KeyframeSequence expected, got %s)", keyframeSequence.ClassName))
	end
	local animationData = {Loop = keyframeSequence.Loop, Priority = keyframeSequence.Priority, Frames = {}}
	for _,f in next, keyframeSequence:GetChildren() do
		if f:IsA("Keyframe") then
			table.insert(animationData.Frames, Parser:parseKeyframeData(f))
		end
	end

	table.sort(animationData.Frames, function(l, r)
		return l.Time < r.Time
	end)

	return animationData
end

return Parser