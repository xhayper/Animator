local AnimationParser = {}

export type PoseData = {
	Time: number,
    CFrame: CFrame,
	EasingStyle: Enum.PoseEasingStyle,
	EasingDirection: Enum.PoseEasingDirection,
}

export type KeyframeData = {
	Pose: { PoseData },
	Marker: { string },
}

export type AnimationData = {
	Priority: number,
	Length: number,
	Loop: boolean,
	Keyframes: { [string]: KeyframeData },
}

function AnimationParser.parse(sequence: KeyframeSequence): AnimationData
	assert(typeof(sequence) == "Instance", "sequence is not an Instance")
	assert(sequence.ClassName == "KeyframeSequence", "sequence is not a KeyframeSequence")

	local keyframes: { Keyframe } = (sequence:GetKeyframes() :: { any }) :: { Keyframe }

	table.sort(keyframes, function(a: Keyframe, b: Keyframe)
		return a.Time < b.Time
	end)

	local priority = sequence.Priority ~= nil and sequence.Priority.Value or 1000

	local animationData: AnimationData = {
		Priority = (priority == 1000 and -1 or priority) + 1,
		Length = keyframes[#keyframes].Time,
		Loop = not not sequence.Loop,
		Keyframes = {},
	}

	for _, keyframe in ipairs(keyframes) do
		for _, rootPose in ipairs(keyframe:GetChildren()) do
			if rootPose.ClassName ~= "Pose" then
				continue
			end
			for _, pose in ipairs(rootPose:GetChildren()) do
				AnimationParser.parsePose(animationData, pose, keyframe)
			end
		end
	end

	return animationData
end

--[[
    THIS MUTATE `keyframeData`
]]
--
function AnimationParser.parsePose(animationData: AnimationData, pose: Pose, keyframe: Keyframe)
	if pose.ClassName == "Pose" then
		if pose.Weight > 0 then
			local name = pose.Name
			local cf = pose.CFrame

			if not animationData.Keyframes[name] then
				animationData.Keyframes[name] = {
					Pose = {},
					Marker = {},
				}
			end

			table.insert(animationData.Keyframes[name].Pose, {
				Time = keyframe.Time,
                CFrame = cf,
				EasingDirection = pose.EasingDirection,
				EasingStyle = pose.EasingStyle,
			})
		end

		for _, child in ipairs(pose:GetChildren()) do
			AnimationParser.parsePose(animationData, child, keyframe)
		end
	end
end

return AnimationParser
