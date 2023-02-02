local Types = require(script.Parent.Parent.Modules.Types)

local AnimationParser = {} :: Types.AnimationParser

function AnimationParser.parse(sequence: KeyframeSequence): Types.AnimationData
	assert(typeof(sequence) == "Instance", "sequence is not an Instance")
	assert(sequence.ClassName == "KeyframeSequence", "sequence is not a KeyframeSequence")

	local keyframes: { Keyframe } = (sequence:GetKeyframes() :: { any }) :: { Keyframe }

	table.sort(keyframes, function(a: Keyframe, b: Keyframe)
		return a.Time < b.Time
	end)

	local priority = sequence.Priority ~= nil and sequence.Priority.Value or 1000

	local animationData: Types.AnimationData = {
		Priority = (priority == 1000 and -1 or priority) + 1,
		Length = keyframes[#keyframes].Time,
		Loop = not not sequence.Loop,
		Keyframes = {},
	}

	for _, keyframe in ipairs(keyframes) do
		local keyframeData: Types.KeyframeData = {
			Name = keyframe.Name,
			Time = keyframe.Time,
			Pose = {},
			Marker = {},
		}

		for _, pose in ipairs(keyframe:GetChildren()) do
			AnimationParser.parsePose(keyframeData, nil, pose)
		end

		table.insert(animationData.Keyframes, keyframeData)
	end

	return animationData
end

--[[
    THIS MUTATE `keyframeData`
]]
--
function AnimationParser.parsePose(keyframe: Types.KeyframeData, parent: Pose, pose: Pose)
	if pose.ClassName == "Pose" then
		if parent then
			if pose.Weight > 0 then
				local parentName = parent.Name
				local name = pose.Name
				local cf = pose.CFrame

				if not keyframe.Pose[parentName] then
					keyframe.Pose[parentName] = {}
				end

				keyframe.Pose[parentName][name] = {
					CFrame = cf,
					EasingDirection = pose.EasingDirection,
					EasingStyle = pose.EasingStyle,
				}
			end
		end

		for _, child in ipairs(pose:GetChildren()) do
			AnimationParser.parsePose(keyframe, pose, child)
		end
	elseif pose.ClassName == "KeyframeMarker" then
		local marker = (pose :: any) :: KeyframeMarker
		table.insert(keyframe.Marker, marker.Name)
	end
end

return AnimationParser
