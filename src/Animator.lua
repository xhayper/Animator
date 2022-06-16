local Janitor = AnimatorUtility.httpRequire(AnimatorUtility.formatUrl("external/Janitor/init.lua"), true)
local FastSignal = AnimatorUtility.httpRequire(AnimatorUtility.formatUrl("external/FastSignal/init.lua"), true)

local HttpService = game:GetService("HttpService")

--[=[
    @class Animator

    The main class responsible for the playback and replication of [Animation]s. All replication of playing [AnimationTrack]s is handled through the Animator instance.

    It is created when [Humanoid:LoadAnimation] or [AnimationController:LoadAnimation] is called under a [Humanoid] or [AnimationController] for the first time.

    For animation replication to function it is important for the Animator to be first created on the server.
]=]
local Animator = {}
Animator.ClassName = "Animator"
Animator.__index = Animator

--[=[
    @prop AnimationPlayed RBXScriptSignal
    @within Animator
]=]

type Animator = typeof(Animator.new())

type Map<K ,V> = {[K]: V}
type Array<V> = {[number]: V}

-- K: UUID
-- V: Animator
local animatorMap: Map<string, Animator> = {}

local function generateUniqueUUID(): string
    local UUID = HttpService:GenerateGUID(false)
    while animatorMap[UUID] do
        UUID = HttpService:GenerateGUID(false)
    end
    return UUID
end

function Animator.new()
    local self = setmetatable({}, Animator)

    local ghostInstance = Instance.new("StringValue")
    ghostInstance.Name = "Animator"
    ghostInstance.Value = generateUniqueUUID()

    local janitor = Janitor.new()

    self.__internal = {
        animationTracks = {} :: Array<AnimationTrack>,
        instanceGhost = ghostInstance,
        janitor = janitor
    }

    self.AnimationPlayed = FastSignal.new()

    janitor.Add(self, "Destroy")
    janitor.Add(self.AnimationPlayed, "DisconnectAll")
    janitor.Add(ghostInstance, "Destroy")
    janitor:LinkToInstance(ghostInstance)

    return self
end

--[=[
    Given the current set of [AnimationTrack]s playing, and their current times and play speeds, compute relative velocities between the parts and apply them to Motor6D.Part1 (the part which [Animator] considers the “child” part). These relative velocity calculations and assignments happen in the order provided.
    This method doesn’t apply velocities for a given joint if both of the joint’s parts are currently part of the same assembly, for example, if they are still connected directly or indirectly by Motors or Welds.
    This method doesn’t disable or remove the joints for you. You must disable or otherwise remove the rigid joints from the assembly before calling this method.
    The given Motor6Ds are not required to be descendants of the the [DataModel]. Removing the joints from the [DataModel] before calling this method is supported.
]=]
function Animator:ApplyJointVelocities(motors: Variant)
    -- TODO: Implement this
end

--[=[
    Returns the list of currently playing AnimationTracks|AnimationTracks.
]=]
function Animator:GetPlayingAnimationTracks(): Array<AnimationTrack>
    return self.__internal.animationTracks
end

--[=[
    @param keyframeSequence KeyframeSequence -- The [KeyframeSequence] to be used.

    LoadAnimation will load the given [KeyframeSequence] onto an [Animator], returning a playable [AnimationTrack]. When called on Animators within models that the client has network ownership of, ie. the local player’s character or from [BasePart:SetNetworkOwner], this function also loads the animation for the server as well.
    You should use this function directly instead of the similarly-named [Humanoid:LoadAnimation] and [AnimationController:LoadAnimation] functions. These are deprecated proxies of this function which also create an Animator if one does not exist; this can cause replication issues if you are not careful. For more information, see this [announcement post](https://devforum.roblox.com/t/deprecating-loadanimation-on-humanoid-and-animationcontroller/857129)
]=]
function Animator:LoadAnimation(keyframeSequence: KeyframeSequence): AnimationTrack
    local animationTrack = AnimationTrack.new(keyframeSequence)
    self.__internal.animationTracks:push(animationTrack)
    return animationTrack
end

--[=[
    @param deltaTime float -- The amount of time in seconds animation playback is to be incremented by.

    Increments the [AnimationTrack.TimePosition] of all playing [AnimationTrack]s that are loaded onto the [Animator], applying the offsets to the model associated with the [Animator]. For use in the command bar or by plugins only.
    The deltaTime paramater determines the number of seconds to increment on the animation’s progress. Typically this function will be called in a loop to preview the length of an animation (see example).
    Note that once animations have stopped playing, the model’s joints will need to be manually reset to their original positions (see example).
    This function is used to simulate playback of [Animation]s when the game isn’t running. This allows animations to be previewed without the consequences of running the game, such as scripts executing. If the function is called whilst the game is running, or by [Script]s or [LocalScript]s, it will return an error.
    Developers designing their own custom animation editors are advised to use this function to preview animations, as it is the method the official Roblox Animation Editor plugin uses.
]=]
function Animator:StepAnimations(deltaTime: number)
    -- TODO: Implement this
end

-------------------

--[=[
    Sets the [Instance.Parent] property to nil, locks the [Instance.Parent] property, disconnects all connections, and calls Destroy on all children. This function is the correct way to dispose of objects that are no longer required. Disposing of unneeded objects is important, since unnecessary objects and connections in a place use up memory (this is called a memory leak) which can lead to serious performance issues over time.
    ```lua title=" Tip: After calling Destroy on an object, set any variables referencing the object (or its descendants) to nil. This prevents your code from accessing anything to do with the object."
    local part = Instance.new("Part")
    part.Name = "Hello, world"
    part:Destroy()
    -- Don't do this:
    print(part.Name) --> "Hello, world"
    -- Do this to prevent the above line from working:
    part = nil
    ```
    Once an [Instance] has been destroyed by this method it cannot be reused because the [Instance.Parent] property is locked. To temporarily remove an object, set [Parent] it to nil instead. For example:
    ```lua
    object.Parent = nil
    wait(2)
    object.Parent = workspace
    ```
    To Destroy an object after a set amount of time, use [Debris:AddItem].
]=]
function Animator:Destroy()
    for _, animationTrack in ipairs(self.__internal.animationTracks) do
        animationTrack:Stop(0)
    end

    self.__internal.janitor:Destroy()
    table.clear(self)
	setmetatable(self, nil)
end

--[=[
    Returns true if an [Instance]’s class matches or inherits from a given class

    @param className string -- The class against which the [Instance]’s class will be checked. Case-sensitive.

    @return bool -- Describes whether the [Instance]’s class matched or is a subclass of the given class
]=]
function Animator:IsA(className)
    return className == "Animator"
end

-----------------

function Animator.__tostring()
    return "Animator"
end

function Animator.__index(self, index)
    return rawget(self, index) or rawget(self, "__internal").instanceGhost[index]
end

function Animator.__newindex(table, index, value)
    if index == "Parent" then
        rawget(table, "__internal").instanceGhost.Parent = value
    elseif index == "Name" then
        rawget(table, "__internal").instanceGhost.Name = value
    elseif index == "Archivable" then
        rawget(table, "__internal").instanceGhost.Archivable = value
    else
        rawset(table, index, value)
    end
end

return Animator