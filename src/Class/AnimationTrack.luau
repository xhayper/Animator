local Types = require(script.Parent.Parent.Modules.Types)

--[[
TODO: GetMarkerReachedSignal(name: string): RBXScriptSignal  
TODO: Returns an event that fires when a specified KeyframeMarker has been hit in an animation.
]]
--

local function findIndex<V>(table: { V }, predicate: (element: V, index: number) -> boolean): number
	for index, value in ipairs(table) do
		if predicate(value, index) then
			return index
		end
	end

	return -1
end

local AnimationTrack = {} :: Types.AnimationTrackProto & Types.AnimationTrackImpl
AnimationTrack.__index = AnimationTrack

function AnimationTrack.new(animator, animationData: Types.AnimationData): AnimationTrack
	local self = setmetatable({}, AnimationTrack)

	self.Animation = animationData
	self.IsPlaying = false
	self.Length = animationData.Length
	self.Looped = false
	self.Priority = animationData.Priority
	self.Speed = 1
	self.TimePosition = 0
	self.Weight = 1

	self._needToPlay = true
	self._animator = animator
	self._previousUpdate = DateTime.now().UnixTimestampMillis

	return self
end

function AnimationTrack:AdjustSpeed(speed: number?)
	speed = speed or 1
	self.Speed = speed
end

function AnimationTrack:GetTimeOfKeyframe(name: string): number
	local index = findIndex(self.Animation.Keyframes, function(x)
		return x.Name == name
	end)

	if 0 > index then
		return error("Invalid keyframe name!")
	end

	return self.Animation.Keyframes[index].Time
end

function AnimationTrack:Play(fadeTime: number?, weight: number?, speed: number?)
	fadeTime = fadeTime or 0.100000001

	self._previousUpdate = DateTime.now().UnixTimestampMillis

	if fadeTime and fadeTime > 0 then
		self._fadeIn = {
			Duration = fadeTime,
			Elapsed = 0,
		}
	end

	self.Weight = weight or 1
	self.Speed = speed or 1

	self._needToPlay = false
	self.IsPlaying = true
end

function AnimationTrack:Stop(fadeTime: number?)
	self._animator:Stop(self, fadeTime)
end

return AnimationTrack
