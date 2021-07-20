if getgenv()["Animator"] == nil then
	---------------------------- NEVERMORE ----------------------------

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

	-------------------------------------------------------------------

	---------------------------- UTILITY ----------------------------

	local Utility = {}

	local format = string.format

	function Utility:sendNotif(Text, Icon, Duration, Button1, Button2, Callback)
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

	function Utility:convertEnum(enum)
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

	function Utility:getMotors(Player, IgnoreList)
		IgnoreList = IgnoreList or {}
		if not Player:IsA("Player") then
			error(format("invalid argument 1 to 'getMotors' (Player expected, got %s)", Player.ClassName))
		end

		if typeof(IgnoreList) ~= "table" then
			error(format("invalid argument 1 to 'getMotors' (Table expected, got %s)", typeof(IgnoreList)))
		end

		local MotorList = {}

		for _,i in next, Player.Character:GetDescendants() do
			if i:IsA("Motor6D") and i.Part0 ~= nil and i.Part1 ~= nil then
				local IsTained = false
				for _,i2 in next, IgnoreList do
					if typeof(i2) == "Instance" then
						if i:IsDescendantOf(i2) then
							IsTained = true
							break
						end
					end
				end
				if IsTained ~= true then
					table.insert(MotorList, i)
				end
			end
		end

		return MotorList
	end

	-----------------------------------------------------------------

	---------------------------- PRASER ----------------------------

	local Parser = {}

	function Parser:parsePoseData(pose)
		if not pose:IsA("Pose") then
			error(format("invalid argument 1 to '_parsePoseData' (Pose expected, got %s)", pose.ClassName))
		end
		local poseData = {Name = pose.Name, CFrame = pose.CFrame, EasingDirection = Utility:convertEnum(pose.EasingDirection), EasingStyle = Utility:convertEnum(pose.EasingStyle), Weight = pose.Weight}
		if #pose:GetChildren() > 0 then
			poseData.Subpose = {}
			for _,p in next, pose:GetChildren() do
				if p:IsA("Pose") then
					table.insert(poseData.Subpose, Parser:parsePoseData(p))
				end
			end
		end
		return poseData
	end

	function Parser:parseKeyframeData(keyframe)
		if not keyframe:IsA("Keyframe") then
			error(format("invalid argument 1 to '_parseKeyframeData' (Keyframe expected, got %s)", keyframe.ClassName))
		end
		local keyframeData = {Name = keyframe.Name, Time = keyframe.Time, Pose = {}}
		for _,p in next, keyframe:GetChildren() do
			if p:IsA("Pose") then
				table.insert(keyframeData.Pose, Parser:parsePoseData(p))
			elseif p:IsA("KeyframeMarker") then
				if not keyframeData.Marker then
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

	function Parser:parseAnimationData(keyframeSequence)
		if not keyframeSequence:IsA("KeyframeSequence") then
			error(format("invalid argument 1 to 'parseAnimationData' (KeyframeSequence expected, got %s)", keyframeSequence.ClassName))
		end
		local animationData = {Loop = keyframeSequence.Loop, Priority = keyframeSequence.Priority, Frames = {}}
		for _,f in next, keyframeSequence:GetChildren() do
			if f:IsA("Keyframe") then
				table.insert(animationData.Frames, Parser:parseKeyframeData(f))
			end
		end

		table.sort(animationData.Frames, function(l, r)
			return l.Time < r.Time
		end)

		return animationData
	end

	---------------------------- ANIMATOR ----------------------------

    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")

    local Animator = {AnimationData = {}, Player = nil, Looped = false, Length = 0, Speed = 1, IsPlaying = false, _stopFadeTime = 0.100000001, _motorIgnoreList = {}, _playing = false, _stopped = false, _isLooping = false, _markerSignal = {}}
    Animator.__index = Animator
    
    function Animator.new(Player, AnimationResolvable)
        if not Player:IsA("Player") then
            error(format("invalid argument 1 to 'new' (Player expected, got %s)", Player.ClassName))
        end
    
        local c = setmetatable({}, Animator)
        c.Player = Player
    
        if typeof(AnimationResolvable) == "string" or typeof(AnimationResolvable) == "number" then -- Assuming that Resolvable is animation id
            local animationInstance = game:GetObjects("rbxassetid://"..tostring(AnimationResolvable))[1]
            if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID expected)") end
            c.AnimationData = Parser:parseAnimationData(animationInstance)
        elseif typeof(AnimationResolvable) == "table" then -- Assuming that Resolvable is animation data table
            c.AnimationData = AnimationResolvable
        elseif typeof(AnimationResolvable) == "Instance" and AnimationResolvable:IsA("KeyframeSequence") then -- Assuming that Resolvable is KeyframeSequence
            c.AnimationData = Parser:parseAnimationData(AnimationResolvable)
        elseif typeof(AnimationResolvable) == "Instance" and AnimationResolvable:IsA("Animation") then -- Assuming that Resolvable is Animation
            local animationInstance = game:GetObjects(AnimationResolvable.AnimationId)[1]
            if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID inside Animation expected)") end
            c.AnimationData = Parser:parseAnimationData(animationInstance)
        else
            error(format("invalid argument 2 to 'new' (number,string,KeyframeSequence expected, got %s)", Player.ClassName))
        end
    
        c.Looped = c.AnimationData.Loop
        c.Length = c.AnimationData.Frames[#c.AnimationData.Frames].Time
    
        c.DidLoop = Signal.new()
        c.Stopped = Signal.new()
        c.KeyframeReached = Signal.new()
        return c
    end
    
    function Animator:_playPose(pose, parent, fade)
        local RigList = Utility:getMotors(self.Player, self._motorIgnoreList)
        if pose.Subpose then
            for _,sp in next, pose.Subpose do
                self:_playPose(sp, pose, fade)
            end
        end
        if parent then
            for _,motor in next, RigList do
                if motor.Part0.Name == parent.Name and motor.Part1.Name == pose.Name then
                    if fade > 0 then
                        local TI = TweenInfo.new(fade, pose.EasingStyle, pose.EasingDirection)
                        if self._stopped ~= true then
                            TweenService:Create(motor, TI, {Transform = pose.CFrame}):Play()
                        end
                    else
                        motor.Transform = pose.CFrame
                    end
                end
            end
        else
            if self.Player.Character[pose.Name] then
                self.Player.Character[pose.Name].CFrame = self.Player.Character[pose.Name].CFrame * pose.CFrame
            end
        end
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
    
    function Animator:Play(fadeTime, weight, speed)
        fadeTime = fadeTime or 0.100000001
        if self._playing == false or self._isLooping == true then
            self._playing = true
            self._isLooping = false
            self.IsPlaying = true
            local Character = self.Player.Character
            if Character:FindFirstChildOfClass("Humanoid") then
                if Character.Humanoid:FindFirstChildOfClass("Animator") then
                    Character.Humanoid.Animator:Destroy()
                end
            end
            local con
            con = Character:GetPropertyChangedSignal("Parent"):Connect(function()
                if Character.Parent == nil then
                    con:Disconnect()
                    self:Destroy()
                end
            end)
            local start = os.clock()
            coroutine.wrap(function()
                for i,f in next, self.AnimationData.Frames do
                    f.Time = f.Time / self.Speed
                    if i ~= 1 and f.Time > os.clock()-start then
                        repeat RunService.RenderStepped:Wait() until os.clock()-start > f.Time or self._stopped == true
                    end
                    if self._stopped == true then
                        break;
                    end
                    if f.Name ~= "Keyframe" then
                        self.KeyframeReached:Fire(f.Name)
                    end
                    if f["Marker"] then
                        for k,v in next, f["Marker"] do
                            if self._markerSignal[k] then
                                self._markerSignal[k]:Fire(v)
                            end
                        end
                    end
                    if f.Pose then
                        for _,p in next, f.Pose do
                            fadeTime = fadeTime + f.Time
                            if i ~= 1 then
                                fadeTime = (f.Time*self.Speed-self.AnimationData.Frames[i-1].Time)/(speed or self.Speed)
                            end
                            self:_playPose(p, nil, fadeTime)
                        end
                    end
                end
                if self.Looped == true and self._stopped ~= true then
                    self.DidLoop:Fire()
                    self._isLooping = true
                    return self:Play(fadeTime, weight, speed)
                end
                RunService.RenderStepped:Wait()
                for _,r in next, Utility:getMotors(self.Player, self._motorIgnoreList) do
                    if self._stopFadeTime > 0 then
                        TweenService:Create(r, TweenInfo.new(self._stopFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                            Transform = CFrame.new(),
                            CurrentAngle = 0
                        }):Play()
                    else
                        r.CurrentAngle = 0
                        r.Transform = CFrame.new()
                    end
                end
                if Character:FindFirstChildOfClass("Humanoid") and not Character.Humanoid:FindFirstChildOfClass("Animator") then
                    Instance.new("Animator", Character.Humanoid)
                else
                    self:Destroy()
                end
                con:Disconnect()
                self._stopped = false
                self._playing = false
                self.IsPlaying = false
                self.Stopped:Fire()
            end)()
        end
    end
    
    function Animator:GetTimeOfKeyframe(keyframeName)
        for _,f in next, self.AnimationData.Frames do
            if f.Name == keyframeName then
                return f.Time
            end
        end
        return math.huge
    end
    
    function Animator:GetMarkerReachedSignal(name)
        if not self._markerSignal[name] then
            self._markerSignal[name] = Signal.new()
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
    
        -- Maid won't work properly so.
        self.DidLoop:Destroy()
        self.Stopped:Destroy()
        self.KeyframeReached:Destroy()
        for _,s in next, self._markerSignal do
            s:Destroy()
        end
        self = nil
    end

	------------------------------------------------------------------

	---------------------------- MAIN ----------------------------

	local Players = game:GetService("Players")

	local Player = Players.LocalPlayer

	getgenv().Animator = Animator

	getgenv().hookAnimatorFunction = function()
		local OldFunc
		OldFunc = hookmetamethod(game, "__namecall", function(Object, ...)
			local NamecallMethod = getnamecallmethod()
			if Object.ClassName == "Humanoid" and Object.Parent == Player.Character and NamecallMethod == "LoadAnimation" and checkcaller() then
				return Animator.new(Player, ...)
			end
			return OldFunc(Object, ...)
		end)
		Utility:sendNotif("Hook Loaded\nby whited#4382", nil, 5)
	end

	Utility:sendNotif("API Loaded", nil, 5)

	--------------------------------------------------------------
end