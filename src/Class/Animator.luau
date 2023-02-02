local AnimationEasing = require(script.Parent.Parent.Utility.AnimationEasing)
local AnimationParser = require(script.Parent.Parent.Utility.AnimationParser)
local AnimationTrack = require(script.Parent.AnimationTrack)
local Types = require(script.Parent.Parent.Modules.Types)

local max, min = math.max, math.min

local function findIndex<V>(table: { V }, predicate: (element: V, index: number) -> boolean): number
	for index, value in ipairs(table) do
		if predicate(value, index) then
			return index
		end
	end

	return -1
end

local Animator = {} :: Types.AnimatorProto & Types.AnimatorImpl
Animator.ClassName = "Animator"
Animator.__index = Animator

function Animator.new(): Types.Animator
	local self = setmetatable({}, Animator)

	self._loadedAnimationTrack = {}

	self._tempCF = CFrame.new()

	self._transforms = {}

	return self
end

function Animator:Stop(track: Types.AnimationTrack, fadeOut: number?)
	local index = table.find(self._loadedAnimationTrack, track)

	if not index then
		return
	end

	if fadeOut and fadeOut > 0 then
		track._fadeOut = {
			Duration = fadeOut,
			Elapsed = 0,
		}
	else
		track._needToPlay = true
	end

	if track.IsPlaying then
		track.IsPlaying = false
	end
end

function Animator:LoadAnimation(animation: KeyframeSequence): Types.AnimationTrack
	local animationData = AnimationParser.parse(animation)

	local track = AnimationTrack.new(self, animationData)

	local index = findIndex(self._loadedAnimationTrack, function(x)
		return x.Priority >= track.Priority
	end)

	table.insert(self._loadedAnimationTrack, index ~= -1 and index or #self._loadedAnimationTrack + 1, track)

	return track
end

function Animator:GetPlayingAnimationTracks(): { Types.AnimationTrack }
	return self._loadedAnimationTrack
end

function Animator:Update()
	local time = DateTime.now().UnixTimestampMillis

	for _, track: Types.AnimationTrack in ipairs(self._loadedAnimationTrack) do
		if track._needToPlay then
			continue
		end

		local delta = (time - track._previousUpdate) / 1E3
		track._previousUpdate = time

		if not track.IsPlaying then
			if track._fadeOut then
				track._fadeOut.Elapsed += delta

				if track._fadeOut.Elapsed >= track._fadeOut.Duration then
					self:Stop(track, 0)
				end
			end

			continue
		end

		track.TimePosition += delta * track.Speed

		if track.TimePosition > track.Animation.Length then
			if track.Looped then
				track.TimePosition %= track.Animation.Length
				-- track._didLoop:Invoke()
			else
				self:Stop(track, track._fadeOut and track._fadeOut.Duration or nil)
				continue
			end
		end

		if track._fadeIn then
			track._fadeIn.Elapsed += delta

			if track._fadeIn.Elapsed >= track._fadeIn.Duration then
				track._fadeIn = nil
			end
		end
	end

	local transforms = {} :: { [string]: { [string]: Types.AnimatorTransform } }

	for _, track: Types.AnimationTrack in ipairs(self._loadedAnimationTrack) do
		if track._needToPlay then
			continue
		end

		local weight = max(0, min(1, track.Weight))
			* (track._fadeIn and (track._fadeIn.Elapsed / track._fadeIn.Duration) or 1)
			* (track._fadeOut and (1 - track._fadeOut.Elapsed / track._fadeOut.Duration) or 1)

		if weight == 0 then
			continue
		end

		local index = findIndex(track.Animation.Keyframes, function(x)
			return x.Time > track.TimePosition
		end)

		local prevFrame = (
			index >= #track.Animation.Keyframes and track.Animation.Keyframes[#track.Animation.Keyframes]
			or track.Animation.Keyframes[index - 1]
		) :: Types.KeyframeData

		for parentPoseName, childrenPoses in pairs(prevFrame.Pose) do
			for childrenPoseName, prevPose in pairs(childrenPoses) do
				local transform = transforms[parentPoseName] and transforms[parentPoseName][childrenPoseName]
					or nil :: Types.AnimatorTransform?

				if
					transform
					and (
						transform.Weight >= 1
						or (transform.Working.Weight >= 1 and transform.Working.Priority ~= track.Priority)
					)
				then
					continue
				end

				if index == 1 then
					continue
				end

				if not transform then
					transform = self._transforms[parentPoseName] and self._transforms[parentPoseName][childrenPoseName]
						or nil :: Types.AnimatorTransform?

					if transform then
						transform.CFrame = CFrame.new()
						transform.Weight = 0
					else
						transform = {
							CFrame = CFrame.new(),
							Weight = 0,
							Working = {
								CFrame = CFrame.new(),
								Weight = 0,
								Priority = -1,
							},
						}
					end

					if not transforms[parentPoseName] then
						transforms[parentPoseName] = {}
					end

					transforms[parentPoseName][childrenPoseName] = transform
				end

				if transform.Working.Priority ~= track.Priority then
					if transform.Working.Weight > 0 then
						local newWeight = 1 - (1 - transform.Weight) * (1 - min(1, transform.Working.Weight))
						local theta = (newWeight - transform.Weight) / newWeight

						transform.CFrame = transform.CFrame:Lerp(transform.Working.CFrame, theta)
						transform.Weight = newWeight

						transform.Working.CFrame = CFrame.new()
						transform.Working.Weight = 0
					end

					transform.Working.Priority = track.Priority
				end

				local nextFrameIndex = findIndex(track.Animation.Keyframes, function(x)
					return x.Pose[parentPoseName]
						and x.Pose[parentPoseName][childrenPoseName]
						and x.Time > track.TimePosition
				end)

				local nextFrame: Types.KeyframeData?
				local nextPose: Types.PoseData?

				if nextFrameIndex == 1 then
					nextFrame = nil
					nextPose = nil
				else
					nextFrame = track.Animation.Keyframes[nextFrameIndex]
					nextPose = nextFrame
							and nextFrame.Pose[parentPoseName]
							and nextFrame.Pose[parentPoseName][childrenPoseName]
						or nil :: Types.PoseData?
				end

				if not nextFrame or not nextPose or track.TimePosition == prevFrame.Time then
					self._tempCF = prevPose.CFrame
				else
					local theta = AnimationEasing[prevPose.EasingStyle][prevPose.EasingDirection](
						(track.TimePosition - prevFrame.Time) / (nextFrame.Time - prevFrame.Time)
					)

					self._tempCF = prevPose.CFrame:Lerp(nextPose.CFrame, theta)
				end

				local newWeight = transform.Working.Weight + weight
				local theta = (newWeight - transform.Working.Weight) / newWeight

				transform.Working.CFrame = transform.Working.CFrame:Lerp(self._tempCF, theta)
				transform.Working.Weight = newWeight
			end
		end
	end

	self._transforms = {}

	for parentName, childrenData in pairs(transforms) do
		for childrenName, transform in pairs(childrenData) do
			if transform.Working.Weight > 0 then
				local newWeight = 1 - (1 - transform.Weight) * (1 - min(1, transform.Working.Weight))
				local theta = (newWeight - transform.Weight) / newWeight

				transform.CFrame = transform.CFrame:Lerp(transform.Working.CFrame, theta)
				transform.Weight = newWeight

				transform.Working.CFrame = CFrame.new()
				transform.Working.Weight = 0
				transform.Working.Priority = -1
			end

			self._tempCF = CFrame.new()
			transform.CFrame = transform.CFrame:Lerp(self._tempCF, 1 - transform.Weight)

			self._transforms[parentName] = self._transforms[parentName] or {}
			self._transforms[parentName][childrenName] = transform
		end
	end
end

return Animator
