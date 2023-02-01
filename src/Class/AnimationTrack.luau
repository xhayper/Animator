local AnimationParser = require(script.Parent.Parent.Utility.AnimationParser)

type AnimationTrackProps = {
	Animation: AnimationParser.AnimationData,
	IsPlaying: boolean,
	Length: number,
	Looped: boolean,
	Priority: number,
	Speed: number,
	TimePosition: number,
	Weight: number,

	_animator: any,
	_needToPlay: boolean,
	_previousUpdate: number,
	_fadeOut: {
		Duration: number,
		Elapsed: number,
	}?,
	_fadeIn: {
		Duration: number,
		Elapsed: number,
	}?,
}

local AnimationTrack = {}
AnimationTrack.__index = AnimationTrack

export type AnimationTrack = typeof(setmetatable({} :: AnimationTrackProps, AnimationTrack))

function AnimationTrack.new(animator, animationData: AnimationParser.AnimationData): AnimationTrack
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
	self._removed = false

	return self
end

function AnimationTrack:AdjustSpeed(speed: number?)
	speed = speed or 1
	self.Speed = speed
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
