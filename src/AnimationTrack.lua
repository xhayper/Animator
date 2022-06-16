--[=[
    @class AnimationTrack

    Controls the playback of an animation on a [Humanoid] or [AnimationController]. This object cannot be created, instead it is returned by the [Humanoid:LoadAnimation] method.
]=]
local AnimationTrack = {}
AnimationTrack.ClassName = "AnimationTrack"
AnimationTrack.__index = AnimationTrack

local AnimationTrackDefaults = {}

--[=[
    @prop KeyframeSequence KeyframeSequence
    @within AnimationTrack
    The [KeyframeSequence] object that was used to create this [AnimationTrack]. To create an [AnimationTrack] the developer must load an [KeyframeSequence] object onto a [Humanoid] or [AnimationController] using the [Humanoid:LoadAnimation] method.
    The KeyframeSequence property is used to identify the underlying [KeyframeSequence] of an [AnimationTrack].
]=]
AnimationTrackDefaults.KeyframeSequence = nil

--[=[
    @prop IsPlaying bool
    @within AnimationTrack
    @readonly
    A read only property that returns true when the [AnimationTrack] is playing.
    This property can be used by developers to check if an animation is already playing before playing it (as that would cause it to restart). If a developer wishes to obtain all playing [AnimationTrack]s on a [Humanoid] or [AnimationController] they should use [Humanoid:GetPlayingAnimationTracks]
]=]
AnimationTrackDefaults.IsPlaying = false

--[=[
    @prop Length float
    @within AnimationTrack
    @readonly
    A read only property that returns the length (in seconds) of an [AnimationTrack]. This will return 0 until the animation has fully loaded and thus may not be immediately available.
    When the [AnimationTrack.Speed] of an AnimationTrack is equal to 1, the animation will take [AnimationTrack.Length] (in seconds) to complete.
]=]
AnimationTrackDefaults.Length = 0

--[=[
    @prop Looped bool
    @within AnimationTrack
    This property sets whether the animation will repeat after finishing. If it is changed while playing the result will take effect after the animation finishes.
    The Looped property for [AnimationTrack] defaults to how it was set in the animation editor. However this property can be changed, allowing control over the AnimationTrack while the game is running. Looped also correctly handles animations played in reverse (negative [AnimationTrack.Speed]). After the first keyframe is reached, it will restart at the last keyframe.
    This property allows the developer to have a looping and non looping variant of the same animation, without needing to upload two versions to Roblox.
]=]
AnimationTrackDefaults.Looped = false

--[=[
    @prop Priority AnimationPriority
    @within AnimationTrack
    This property sets the priority of an [AnimationTrack]. Depending on what this is set to, playing multiple animations at once will look to this property to figure out which [Keyframe] [Pose]s should be played over one another.
    The Priority property for [AnimationTrack] defaults to how it was set in the editor. It uses the [AnimationPriority] Enum, which as four priority levels.
        1. Core (lowest priority)
        2. Idle
        3. Movement
        4. Action (highest priority)
    Correctly set animation priorities, either through the editor or through this property allow multiple animations to be played without them clashing. Where two playing animations direct the target to move the same limb in different ways, the AnimationTrack with the highest priority will show. If both animations have the same priority, the weight of both tracks will be used to combine the animations.
    This property also allows the developer to play the same animation at different priorities, without needing to upload additional versions to Roblox.
]=]
AnimationTrackDefaults.AnimationPriority = Enum.AnimationPriority.Core

--[=[
    @prop Speed float
    @within AnimationTrack
    @readonly
    The Speed of an [AnimationTrack] is a read only property that gives the current playback speed of the [AnimationTrack]. This has a default value of 1. When speed is equal to 1, the amount of time an animation takes to complete is equal to [AnimationTrack.Length] (in seconds).
    If the speed is adjusted, then the actual time it will take a track to play can be computed by dividing the length by the speed. Speed is a unitless quantity.
    Speed can be used to link the length of an animation to different game events (for example recharging an ability) without having to upload different variants of the same animation.
    This property is read only and is changed using [AnimationTrack:AdjustSpeed].
]=]
AnimationTrackDefaults.Speed = 1

--[=[
    @prop TimePosition float
    @within AnimationTrack
    Returns the position in time in seconds that an [AnimationTrack] is through playing its source animation. Can be set to make the track jump to a specific moment in the animation.
    TimePosition can be set to go to a specific point in the animation, but the AnimationTrack must be playing to do so. It can also be used in combination with [AnimationTrack:AdjustSpeed] to freeze the animation at a desired point (by setting speed to 0).
]=]
AnimationTrackDefaults.TimePosition = 0

--[=[
    @prop WeightCurrent float
    @within AnimationTrack
    @readonly
    When weight is set in an [AnimationTrack] it does not change instantaneously but moves from WeightCurrent to [AnimationTrack.WeightTarget]. The time it takes to do this is determined by the fadeTime parameter given when the animation is played, or the weight is adjusted.
    WeightCurrent can be checked against [AnimationTrack.WeightTarget] to see if the desired weight has been reached. Note that these values should not be checked for equality with the == operator, as both of these values are floats. To see if WeightCurrent has reached the target weight, it is recommended to see if the distance between those values is sufficiently small.
    The animation weighting system is used to determine how [AnimationTrack]s playing at the same priority are blended together. The default weight is one, and no movement will be visible on an [AnimationTrack] with a weight of zero. The pose that is shown at any point in time is determined by the weighted average of all the [Pose]s and the WeightCurrent of each [AnimationTrack]. See below for an example of animation blending in practice.

    In most cases blending animations is not required and using [AnimationTrack.Priority] is more suitable.
]=]
AnimationTrackDefaults.WeightCurrent = 1

--[=[
    @prop WeightTarget float
    @within AnimationTrack
    @readonly
    When weight is set in an [AnimationTrack] it does not change instantaneously but moves from WeightCurrent to [AnimationTrack.WeightTarget]. The time it takes to do this is determined by the fadeTime parameter given when the animation is played, or the weight is adjusted.
    WeightCurrent can be checked against [AnimationTrack.WeightTarget] to see if the desired weight has been reached. Note that these values should not be checked for equality with the == operator, as both of these values are floats. To see if WeightCurrent has reached the target weight, it is recommended to see if the distance between those values is sufficiently small.
    The animation weighting system is used to determine how [AnimationTrack]s playing at the same priority are blended together. The default weight is one, and no movement will be visible on an [AnimationTrack] with a weight of zero. The pose that is shown at any point in time is determined by the weighted average of all the [Pose]s and the WeightCurrent of each [AnimationTrack]. See below for an example of animation blending in practice.

    In most cases blending animations is not required and using [AnimationTrack.Priority] is more suitable.
]=]
AnimationTrackDefaults.WeightTarget = 1

--- @ignore
function AnimationTrack.new()
    return setmetatable(AnimationTrackDefaults, AnimationTrack)
end

--[=[
    Returns true if an [Instance]’s class matches or inherits from a given class

    @param className string -- The class against which the [Instance]’s class will be checked. Case-sensitive.

    @return bool -- Describes whether the [Instance]’s class matched or is a subclass of the given class
]=]
function AnimationTrack:IsA(className)
    return className == "AnimationTrack"
end

return AnimationTrack