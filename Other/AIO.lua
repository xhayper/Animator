---------------------------------------------------------------------------------------------------------------------------

---	Manages the cleaning of events and other things.
-- Useful for encapsulating state and make deconstructors easy
-- @classmod Maid
-- @see Signal

local Maid = {}
Maid.ClassName = "Maid"

--- Returns a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid)
end

function Maid.isMaid(value)
	return type(value) == "table" and value.ClassName == "Maid"
end

--- Returns Maid[key] if not part of Maid metatable
-- @return Maid[key] value
function Maid:__index(index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

--- Add a task to clean up. Tasks given to a maid will be cleaned when
--  maid[index] is set to a different value.
-- @usage
-- Maid[key] = (function)         Adds a task to perform
-- Maid[key] = (event connection) Manages an event connection
-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
--                                it is destroyed.
function Maid:__newindex(index, newTask)
	if Maid[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]

	if oldTask == newTask then
		return
	end

	tasks[index] = newTask

	if oldTask then
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect()
		elseif oldTask.Destroy then
			oldTask:Destroy()
		end
	end
end

--- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(task)
	if not task then
		error("Task cannot be false or nil", 2)
	end

	local taskId = #self._tasks+1
	self[taskId] = task

	if type(task) == "table" and (not task.Destroy) then
		warn("[Maid.GiveTask] - Gave table task without .Destroy\n\n" .. debug.traceback())
	end

	return taskId
end

function Maid:GivePromise(promise)
	if not promise:IsPending() then
		return promise
	end

	local newPromise = promise.resolved(promise)
	local id = self:GiveTask(newPromise)

	-- Ensure GC
	newPromise:Finally(function()
		self[id] = nil
	end)

	return newPromise
end

--- Cleans up all tasks.
-- @alias Destroy
function Maid:DoCleaning()
	local tasks = self._tasks

	-- Disconnect all events first as we know this is safe
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			task:Destroy()
		end
		index, task = next(tasks)
	end
end

--- Alias for DoCleaning()
-- @function Destroy
Maid.Destroy = Maid.DoCleaning

--- Lua-side duplication of the API of events on Roblox objects.
-- Signals are needed for to ensure that for local events objects are passed by
-- reference rather than by value where possible, as the BindableEvent objects
-- always pass signal arguments by value, meaning tables will be deep copied.
-- Roblox's deep copy method parses to a non-lua table compatable format.
-- @classmod Signal

local HttpService = game:GetService("HttpService")

local ENABLE_TRACEBACK = false

local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

--- Constructs a new signal.
-- @constructor Signal.new()
-- @treturn Signal
function Signal.new()
	local self = setmetatable({}, Signal)

	self._bindableEvent = Instance.new("BindableEvent")
	self._argMap = {}
	self._source = ENABLE_TRACEBACK and debug.traceback() or ""

	-- Events in Roblox execute in reverse order as they are stored in a linked list and
	-- new connections are added at the head. This event will be at the tail of the list to
	-- clean up memory.
	self._bindableEvent.Event:Connect(function(key)
		self._argMap[key] = nil

		-- We've been destroyed here and there's nothing left in flight.
		-- Let's remove the argmap too.
		-- This code may be slower than leaving this table allocated.
		if (not self._bindableEvent) and (not next(self._argMap)) then
			self._argMap = nil
		end
	end)

	return self
end

--- Fire the event with the given arguments. All handlers will be invoked. Handlers follow
-- Roblox signal conventions.
-- @param ... Variable arguments to pass to handler
-- @treturn nil
function Signal:Fire(...)
	if not self._bindableEvent then
		warn(("Signal is already destroyed. %s"):format(self._source))
		return
	end

	local args = table.pack(...)

	-- TODO: Replace with a less memory/computationally expensive key generation scheme
	local key = HttpService:GenerateGUID(false)
	self._argMap[key] = args

	-- Queues each handler onto the queue.
	self._bindableEvent:Fire(key)
end

--- Connect a new handler to the event. Returns a connection object that can be disconnected.
-- @tparam function handler Function handler called with arguments passed when `:Fire(...)` is called
-- @treturn Connection Connection object that can be disconnected
function Signal:Connect(handler)
	if not (type(handler) == "function") then
		error(("connect(%s)"):format(typeof(handler)), 2)
	end

	return self._bindableEvent.Event:Connect(function(key)
		-- note we could queue multiple events here, but we'll do this just as Roblox events expect
		-- to behave.

		local args = self._argMap[key]
		if args then
			handler(table.unpack(args, 1, args.n))
		else
			error("Missing arg data, probably due to reentrance.")
		end
	end)
end

--- Wait for fire to be called, and return the arguments it was given.
-- @treturn ... Variable arguments from connection
function Signal:Wait()
	local key = self._bindableEvent.Event:Wait()
	local args = self._argMap[key]
	if args then
		return table.unpack(args, 1, args.n)
	else
		error("Missing arg data, probably due to reentrance.")
		return nil
	end
end

--- Disconnects all connected events to the signal. Voids the signal as unusable.
-- @treturn nil
function Signal:Destroy()
	if self._bindableEvent then
		-- This should disconnect all events, but in-flight events should still be
		-- executed.

		self._bindableEvent:Destroy()
		self._bindableEvent = nil
	end

	-- Do not remove the argmap. It will be cleaned up by the cleanup connection.

	setmetatable(self, nil)
end

--------------------------------------------------------------------------------------------

local format = string.format

function sendNotif(Text, Icon, Duration, Button1, Button2, Callback)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Animator";
		Text = (Text .. "\nBy hayper#0001") or nil;
		Icon = Icon or nil;
		Duration = Duration or nil;
		Button1 = Button1 or nil;
		Button2 = Button2 or nil;
		Callback = Callback or nil;
	})
end

function convertEnum(enum)
	local a = tostring(enum):split(".")
	if a[1] == "Enum" then
		local p = a[2]
		local v = a[3]
		local EnumTable = {
			["PoseEasingDirection"] = "EasingDirection",
			["PoseEasingStyle"] = "EasingStyle"
		}
		if EnumTable[p] then
			return Enum[EnumTable[p]][v]
		else
			return enum
		end
	else
		return enum
	end
end

function getBones(Character, IgnoreList)
	IgnoreList = IgnoreList or {}
	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'getBones' (Instance expected, got %s)", typeof(Character)))
	end

	if typeof(IgnoreList) ~= "table" then
		error(format("invalid argument 1 to 'getBones' (Table expected, got %s)", typeof(IgnoreList)))
	end

	local BoneList = {}
	local Descendants = Character:GetDescendants() 

	for count=1, #Descendants do
		local i = Descendants[count]
		if not i:IsA("Bone") then continue end
		local IsTained = false
		for count2=1, #IgnoreList do
			local i2 = IgnoreList[count2]
			if typeof(i2) == "Instance" and i:IsDescendantOf(i2) then
				IsTained = true
				break
			end
		end
		if IsTained ~= true then
			table.insert(BoneList, i)
		end
	end

	return BoneList
end

function getMotors(Character, IgnoreList)
	IgnoreList = IgnoreList or {}
	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'getMotors' (Instance expected, got %s)", typeof(Character)))
	end

	if typeof(IgnoreList) ~= "table" then
		error(format("invalid argument 1 to 'getMotors' (Table expected, got %s)", typeof(IgnoreList)))
	end

	local MotorList = {}
	local Descendants = Character:GetDescendants() 

	for count=1, #Descendants do
		local i = Descendants[count]
		if not i:IsA("Motor6D") or i.Part0 == nil or i.Part1 == nil then continue end
		local IsTained = false
		for count2=1, #IgnoreList do
			local i2 = IgnoreList[count2]
			if typeof(i2) == "Instance" and i:IsDescendantOf(i2) then
				IsTained = true
				break
			end
		end
		if IsTained ~= true then
			table.insert(MotorList, i)
		end
	end
	return MotorList
end

function parsePoseData(pose)
	if not pose:IsA("Pose") then
		error(format("invalid argument 1 to 'parsePoseData' (Pose expected, got %s)", pose.ClassName))
	end
	local poseData = {Name = pose.Name, CFrame = pose.CFrame, EasingDirection = convertEnum(pose.EasingDirection), EasingStyle = convertEnum(pose.EasingStyle), Weight = pose.Weight}
	if #pose:GetChildren() > 0 then
		poseData.Subpose = {}
		local Children = pose:GetChildren()
		for count=1, #Children do
			local p = Children[count]
			if not p:IsA("Pose") then continue end
			table.insert(poseData.Subpose, parsePoseData(p))
		end
	end
	return poseData
end

function parseKeyframeData(keyframe)
	if not keyframe:IsA("Keyframe") then
		error(format("invalid argument 1 to 'parseKeyframeData' (Keyframe expected, got %s)", keyframe.ClassName))
	end
	local keyframeData = {Name = keyframe.Name, Time = keyframe.Time, Pose = {}}
	local Children = keyframe:GetChildren()
	for count=1, #Children do
		local p = Children[count]
		if p:IsA("Pose") then
			table.insert(keyframeData.Pose, parsePoseData(p))
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

function parseAnimationData(keyframeSequence)
	if not keyframeSequence:IsA("KeyframeSequence") then
		error(format("invalid argument 1 to 'parseAnimationData' (KeyframeSequence expected, got %s)", keyframeSequence.ClassName))
	end
	local animationData = {Loop = keyframeSequence.Loop, Priority = keyframeSequence.Priority, Frames = {}}
	local Children = keyframeSequence:GetChildren()
	for count=1, #Children do
		local f = Children[count]
		if not f:IsA("Keyframe") then continue end
		table.insert(animationData.Frames, parseKeyframeData(f))
	end

	table.sort(animationData.Frames, function(l, r)
		return l.Time < r.Time
	end)

	return animationData
end

local TweenService = game:GetService("TweenService")

local Animator = {
	AnimationData = {},
	handleVanillaAnimator = true,
	Character = nil,
	Looped = false, 
	Length = 0,
	Speed = 1,
	IsPlaying = false,
	_motorIgnoreList = {},
	_stopFadeTime = 0.100000001,
	_playing = false,
	_stopped = false,
	_isLooping = false,
	_markerSignal = {},
	_boneIgnoreList = {}
}

local CF,Angles = CFrame.new, CFrame.Angles
local deg = math.deg
local clock = os.clock
local format = string.format

local DefaultMotorCF = CF()
local DefaultBoneCF = CF(0,0,0)*Angles(deg(0),deg(0),deg(0))

Animator.__index = Animator

function Animator.new(Character, AnimationResolvable)
	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'new' (Instace expected, got %s)", typeof(Character)))
	end

	local self = setmetatable({}, Animator)

	if typeof(AnimationResolvable) == "string" or typeof(AnimationResolvable) == "number" then
		local animationInstance = game:GetObjects("rbxassetid://"..tostring(AnimationResolvable))[1]
		if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID expected)") end
		self.AnimationData = Parser:parseAnimationData(animationInstance)
	elseif typeof(AnimationResolvable) == "table" then
		self.AnimationData = AnimationResolvable
	elseif typeof(AnimationResolvable) == "Instance" then
		if AnimationResolvable:IsA("KeyframeSequence") then
			self.AnimationData = Parser:parseAnimationData(AnimationResolvable)
		elseif AnimationResolvable:IsA("Animation") then
			local animationInstance = game:GetObjects(AnimationResolvable.AnimationId)[1]
			if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID inside Animation expected)") end
			self.AnimationData = Parser:parseAnimationData(animationInstance)
		end
	else
		error(format("invalid argument 2 to 'new' (number,string,table,Instance expected, got %s)", typeof(AnimationResolvable)))
	end

	self.Character = Character

	self.Looped = self.AnimationData.Loop
	self.Length = self.AnimationData.Frames[#self.AnimationData.Frames].Time

	self._maid = Maid.new()

	self.DidLoop = Signal.new()
	self.Stopped = Signal.new()
	self.KeyframeReached = Signal.new()
	
	self._maid.DidLoop = self.DidLoop 
	self._maid.Stopped = self.Stopped
	self._maid.KeyframeReached = self.KeyframeReached
	return self
end

function Animator:IgnoreMotorIn(ignoreList)
	if typeof(ignoreList) ~= "table" then
		error(format("invalid argument 1 to 'IgnoreMotorIn' (Table expected, got %s)", typeof(ignoreList)))
	end
	self._motorIgnoreList = ignoreList
end

function Animator:GetMotorIgnoreList()
	return self._motorIgnoreList
end

function Animator:IgnoreBoneIn(ignoreList)
	if typeof(ignoreList) ~= "table" then
		error(format("invalid argument 1 to 'IgnoreBoneIn' (Table expected, got %s)", typeof(ignoreList)))
	end
	self._boneIgnoreList = ignoreList
end

function Animator:GetBoneIgnoreList()
	return self._boneIgnoreList
end

function Animator:_playPose(pose, parent, fade)
	local MotorList = Utility:getMotors(self.Character, self._motorIgnoreList)
	local BoneList = Utility:getBones(self.Character, self._boneIgnoreList)
	if pose.Subpose then
		local SubPose = pose.Subpose
		for count=1, #SubPose do
			local sp = SubPose[count]
			self:_playPose(sp, pose, fade)
		end
	end
	if not parent then return end
	local TI = TweenInfo.new(fade, pose.EasingStyle, pose.EasingDirection)
	task.spawn(function()
		for count=1, #MotorList do
			local motor = MotorList[count]
			if motor.Part0.Name ~= parent.Name or motor.Part1.Name ~= pose.Name then continue end
			if self == nil or self._stopped then break end
			if fade > 0 then
				TweenService:Create(motor, TI, {Transform = pose.CFrame}):Play()
			else
				motor.Transform = pose.CFrame
			end
		end
	end)
	task.spawn(function()
		for count=1, #BoneList do
			local bone = BoneList[count]
			if parent.Name ~= bone.Parent.Name or bone.Name ~= pose.Name then continue end
			if self == nil or self._stopped then break end
			if fade > 0 then
				TweenService:Create(bone, TI, {Transform = pose.CFrame}):Play()
			else
				bone.Transform = pose.CFrame
			end
		end
	end)
end

function Animator:Play(fadeTime, weight, speed)
	fadeTime = fadeTime or 0.100000001
	if self._playing and not self._isLooping then return end
	self._playing = true
	self._isLooping = false
	self.IsPlaying = true
	local con
	local con2
	if not self.Character then return end
	if self.Character:FindFirstChild("Humanoid") then
		con = self.Character.Humanoid.Died:Connect(function()
			self:Destroy()
			con:Disconnect()
		end)
		if self.handleVanillaAnimator and self.Character.Humanoid:FindFirstChild("Animator") then
			self.Character.Humanoid.Animator:Destroy()
		end
	end
	con2 = self.Character:GetPropertyChangedSignal("Parent"):Connect(function()
		if self ~= nil and self.Character.Parent ~= nil then return end
		self:Destroy()
		con2:Disconnect()
	end)
	if self == nil or self.Character.Parent == nil then return end
	local start = clock()
	task.spawn(function()
		for i=1, #self.AnimationData.Frames do
			local f = self.AnimationData.Frames[i]
			if self == nil or self._stopped then break end
			local t = f.Time / (speed or self.Speed)
			if f.Name ~= "Keyframe" then
				self.KeyframeReached:Fire(f.Name)
			end
			if f["Marker"] then
				for k,v in next, f.Marker do
					if not self._markerSignal[k] then continue end
					self._markerSignal[k]:Fire(v)
				end
			end
			if f.Pose then
				local Pose = f.Pose
				for count=1, #Pose do
					local p = Pose[count]
					local ft = fadeTime
					if i ~= 1 then
						ft = (t*(speed or self.Speed)-self.AnimationData.Frames[i-1].Time)/(speed or self.Speed)
					end
					self:_playPose(p, nil, ft)
				end
			end
			if t > clock()-start then
				repeat task.wait() until self == nil or self._stopped or clock()-start >= t
			end
		end
		if self == nil then return end
		if self.Looped and not self._stopped then
			self.DidLoop:Fire()
			self._isLooping = true
			return self:Play(fadeTime, weight, speed)
		end
		task.wait()
		local TI = TweenInfo.new(self._stopFadeTime or fadeTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
		if self.Character then
			local MotorList = Utility:getMotors(self.Character, self._motorIgnoreList)
			local BoneList = Utility:getBones(self.Character, self._boneIgnoreList)
			for count=1, #MotorList do
				local r = MotorList[count]
				if (self._stopFadeTime or fadeTime) > 0 then
					TweenService:Create(r, TI, {
						Transform = DefaultMotorCF,
						CurrentAngle = 0
					}):Play()
				else
					r.CurrentAngle = 0
					r.Transform = DefaultMotorCF
				end
			end
			for count=1, #BoneList do
				local b = BoneList[count]
				if (self._stopFadeTime or fadeTime) > 0 then
					TweenService:Create(b, TI, {Transform = DefaultBoneCF}):Play()
				else
					b.Transform = DefaultBoneCF
				end
			end
			if self.handleVanillaAnimator and self.Character:FindFirstChild("Humanoid") and not self.Character.Humanoid:FindFirstChildOfClass("Animator") then
				Instance.new("Animator", self.Character.Humanoid)
			end
		end
		if con then
			con:Disconnect()
		end
		con2:Disconnect()
		self._stopped = false
		self._playing = false
		self.IsPlaying = false
		self.Stopped:Fire()
	end)
end

function Animator:GetTimeOfKeyframe(keyframeName)
	for count=1, #self.AnimationData.Frames do
		local f = self.AnimationData.Frames[count]
		if f.Name ~= keyframeName then continue end
		return f.Time
	end
	return math.huge
end

function Animator:GetMarkerReachedSignal(name)
	if not self._markerSignal[name] then
		self._markerSignal[name] = Signal.new()
		self._maid["Marker_"..name] = self._markerSignal[name]
	end
	return self._markerSignal[name]
end

function Animator:AdjustSpeed(speed)
	self.Speed = speed
end

function Animator:Stop(fadeTime)
	self._stopFadeTime = fadeTime or 0.100000001
	self._stopped = true
end

function Animator:Destroy()
	self:Stop(0)
	self.Stopped:Wait()
	self._maid:DoCleaning()
	setmetatable(self, nil)
end

getgenv().Animator = Animator

getgenv().hookAnimatorFunction = function()
	local OldFunc
	OldFunc = hookmetamethod(game, "__namecall", function(Object, ...)
		local NamecallMethod = getnamecallmethod()
		if not checkcaller() or Object.ClassName ~= "Humanoid" or NamecallMethod ~= "LoadAnimation" then return OldFunc(Object, ...) end
		local args = {...}
		if not args[2] or args[2] == true then return OldFunc(Object, ...) end
		return Animator.new(Object.Parent, ...)
	end)
	sendNotif("Hook Loaded\nby whited#4382", nil, 5)
end

sendNotif("API Loaded", nil, 5)
