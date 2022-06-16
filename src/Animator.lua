--[=[
    @class Animator

    The main class responsible for the playback and replication of [Animation]s. All replication of playing [AnimationTrack]s is handled through the Animator instance.

    It is created when [Humanoid:LoadAnimation] or [AnimationController:LoadAnimation] is called under a [Humanoid] or [AnimationController] for the first time.

    For animation replication to function it is important for the Animator to be first created on the server.
]=]
local Animator = {}
Animator.ClassName = "Animator"
Animator.__index = Animator

return Animator