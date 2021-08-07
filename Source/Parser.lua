local Utility = animatorRequire("Utility.lua")

local format = string.format

local Parser = {}

function Parser:parsePoseData(pose)
	if not pose:IsA("Pose") then
		error(format("invalid argument 1 to 'parsePoseData' (Pose expected, got %s)", pose.ClassName))
	end
	local poseData = {Name = pose.Name, CFrame = pose.CFrame, EasingDirection = Utility:convertEnum(pose.EasingDirection), EasingStyle = Utility:convertEnum(pose.EasingStyle), Weight = pose.Weight}
	if #pose:GetChildren() > 0 then
		poseData.Subpose = {}
		local Children = pose:GetChildren()
		for count=1, #Children do
			local p = Children[count]
			if not p:IsA("Pose") then continue end
			table.insert(poseData.Subpose, Parser:parsePoseData(p))
		end
	end
	return poseData
end

function Parser:parseKeyframeData(keyframe)
	if not keyframe:IsA("Keyframe") then
		error(format("invalid argument 1 to 'parseKeyframeData' (Keyframe expected, got %s)", keyframe.ClassName))
	end
	local keyframeData = {Name = keyframe.Name, Time = keyframe.Time, Pose = {}}
	local Children = keyframe:GetChildren()
	for count=1, #Children do
		local p = Children[count]
		if p:IsA("Pose") then
			table.insert(keyframeData.Pose, Parser:parsePoseData(p))
		elseif p:IsA("KeyframeMarker") then
			if not keyframeData["Marker"] then
				keyframeData.Marker = {}
			end
			if not keyframeData.Marker[p.Name] then
				keyframeData.Marker[p.Name] = {}
			end
			table.insert(keyframeData.Marker, p.Name)
		end
	end
	return keyframeData
end

function Parser:parseAnimationData(keyframeSequence)
	if not keyframeSequence:IsA("KeyframeSequence") then
		error(format("invalid argument 1 to 'parseAnimationData' (KeyframeSequence expected, got %s)", keyframeSequence.ClassName))
	end
	local animationData = {Loop = keyframeSequence.Loop, Priority = keyframeSequence.Priority, Frames = {}}
	local Children = keyframeSequence:GetChildren()
	for count=1, #Children do
		local f = Children[count]
		if not f:IsA("Keyframe") then continue end
		table.insert(animationData.Frames, Parser:parseKeyframeData(f))
	end

	table.sort(animationData.Frames, function(l, r)
		return l.Time < r.Time
	end)

	return animationData
end

return Parser