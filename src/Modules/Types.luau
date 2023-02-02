--!strict

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

export type AnimationParser = {
	parse: (sequence: KeyframeSequence) -> AnimationData,
}

----------------------------------------------------------------------------------------

export type AnimationTrackProto = {
	Animation: AnimationData,
	IsPlaying: boolean,
	Length: number,
	Looped: boolean,
	Priority: number,
	Speed: number,
	TimePosition: number,
	Weight: number,

	DidLoop: RBXScriptSignal,
	Ended: RBXScriptSignal,
	Stopped: RBXScriptSignal,

	_animator: Animator,
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

export type AnimationTrackImpl = {
	__index: AnimationTrackImpl,
	new: (animator: Animator, animation: AnimationData) -> AnimationTrack,

	-- TODO: KeyframeReached: (self: AnimationTrack, keyframeName: string) -> RBXScriptSignal,

	AdjustSpeed: (self: AnimationTrack, speed: number?) -> (),
	Play: (self: AnimationTrack, fadeTime: number?, weight: number?, speed: number?) -> (),
	Stop: (self: AnimationTrack, fadeTime: number?) -> (),
}

export type AnimationTrack = typeof(setmetatable({} :: AnimationTrackProto, {} :: AnimationTrackImpl))

----------------------------------------------------------------------------------------

export type AnimatorTransform = {
	CFrame: CFrame,
	Weight: number,
	Working: {
		CFrame: CFrame,
		Weight: number,
		Priority: number,
	},
}

export type AnimatorProto = {
	ClassName: string,

	_loadedAnimationTrack: { AnimationTrack },
	_tempCF: CFrame,
	_transforms: { [string]: AnimatorTransform },
}

export type AnimatorImpl = {
	__index: AnimatorImpl,
	new: () -> Animator,

	LoadAnimation: (self: Animator, animation: KeyframeSequence) -> AnimationTrack,
	GetPlayingAnimationTracks: (self: Animator) -> { AnimationTrack },

	--Private functions
	Stop: (self: Animator, track: AnimationTrack, fadeOut: number?) -> (),
	Update: (self: Animator) -> (),
}

export type Animator = typeof(setmetatable({} :: AnimatorProto, {} :: AnimatorImpl))

return {}
