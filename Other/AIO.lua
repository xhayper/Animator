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

	function Utility:getBones(Character, IgnoreList)
		IgnoreList = IgnoreList or {}
		if typeof(Character) ~= "Instance" then
			error(format("invalid argument 1 to 'getBones' (Instance expected, got %s)", typeof(Character)))
		end

		if typeof(IgnoreList) ~= "table" then
			error(format("invalid argument 1 to 'getBones' (Table expected, got %s)", typeof(IgnoreList)))
		end

		local BoneList = {}

		for _,i in next, Character:GetDescendants() do
			if i:IsA("Bone") then
				local IsTained = false
				for _,i2 in next, IgnoreList do
					if typeof(i2) == "Instance" and i:IsDescendantOf(i2) then
						IsTained = true
						break
					end
				end
				if IsTained ~= true then
					table.insert(BoneList, i)
				end
			end
		end

		return BoneList
	end

	function Utility:getMotors(Character, IgnoreList)
		IgnoreList = IgnoreList or {}
		if typeof(Character) ~= "Instance" then
			error(format("invalid argument 1 to 'getMotors' (Instance expected, got %s)", typeof(Character)))
		end

		if typeof(IgnoreList) ~= "table" then
			error(format("invalid argument 1 to 'getMotors' (Table expected, got %s)", typeof(IgnoreList)))
		end

		local MotorList = {}

		for _,i in next, Character:GetDescendants() do
			if i:IsA("Motor6D") and i.Part0 ~= nil and i.Part1 ~= nil then
				local IsTained = false
				for _,i2 in next, IgnoreList do
					if typeof(i2) == "Instance" and i:IsDescendantOf(i2) then
						IsTained = true
						break
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

	local DefaultMotorCF = CF()
	local DefaultBoneCF = CF(0,0,0)*Angles(deg(0),deg(0),deg(0))

	Animator.__index = Animator

	function Animator.new(Character, AnimationResolvable)
		if typeof(Character) ~= "Instance" then
			error(format("invalid argument 1 to 'new' (Instace expected, got %s)", typeof(Character)))
		end

		local c = setmetatable({}, Animator)
		c.Character = Character

		if typeof(AnimationResolvable) == "string" or typeof(AnimationResolvable) == "number" then
			local animationInstance = game:GetObjects("rbxassetid://"..tostring(AnimationResolvable))[1]
			if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID expected)") end
			c.AnimationData = Parser:parseAnimationData(animationInstance)
		elseif typeof(AnimationResolvable) == "table" then
			c.AnimationData = AnimationResolvable
		elseif typeof(AnimationResolvable) == "Instance" and AnimationResolvable:IsA("KeyframeSequence") then
			c.AnimationData = Parser:parseAnimationData(AnimationResolvable)
		elseif typeof(AnimationResolvable) == "Instance" and AnimationResolvable:IsA("Animation") then
			local animationInstance = game:GetObjects(AnimationResolvable.AnimationId)[1]
			if not animationInstance:IsA("KeyframeSequence") then error("invalid argument 1 to 'new' (AnimationID inside Animation expected)") end
			c.AnimationData = Parser:parseAnimationData(animationInstance)
		else
			error(format("invalid argument 2 to 'new' (number,string,table,Instance expected, got %s)", typeof(AnimationResolvable)))
		end

		c.Looped = c.AnimationData.Loop
		c.Length = c.AnimationData.Frames[#c.AnimationData.Frames].Time

		c.DidLoop = Signal.new()
		c.Stopped = Signal.new()
		c.KeyframeReached = Signal.new()
		return c
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
			for _,sp in next, pose.Subpose do
				self:_playPose(sp, pose, fade)
			end
		end
		if not parent then return end
		local TI = TweenInfo.new(fade, pose.EasingStyle, pose.EasingDirection)
		coroutine.wrap(function()
			for _,motor in next, MotorList do
				if motor.Part0.Name == parent.Name and motor.Part1.Name == pose.Name then
					if self == nil or self._stopped == true then break end
					if fade > 0 then
						TweenService:Create(motor, TI, {Transform = pose.CFrame}):Play()
					else
						motor.Transform = pose.CFrame
					end
				end
			end
		end)()
		coroutine.wrap(function()
			for _, bone in next, BoneList do
				if parent.Name == bone.Parent.Name and bone.Name == pose.Name then
					if self == nil or self._stopped == true then break end
					if fade > 0 then
						TweenService:Create(bone, TI, {Transform = pose.CFrame}):Play()
					else
						bone.Transform = pose.CFrame
					end
				end
			end
		end)
	end

	function Animator:Play(fadeTime, weight, speed)
		fadeTime = fadeTime or 0.100000001
		if self._playing == false or self._isLooping == true then
			self._playing = true
			self._isLooping = false
			self.IsPlaying = true
			local con
			if self.Character:FindFirstChild("Humanoid") then
				con = self.Character.Humanoid.Died:Connect(function()
					self = nil
					con:Disconnect()
				end)
				if self.Character.Humanoid:FindFirstChild("Animator") and self.handleVanillaAnimator == true then
					self.Character.Humanoid.Animator:Destroy()
				end
			end
			local con2
			con2 = self.Character:GetPropertyChangedSignal("Parent"):Connect(function()
				if self == nil or self.Character.Parent == nil then
					self = nil
					con2:Disconnect()
				end
			end)
			if self ~= nil and self.Character.Parent ~= nil then
				local start = clock()
				coroutine.wrap(function()
					for i,f in next, self.AnimationData.Frames do
						if self == nil or self._stopped == true then break end
						local t = f.Time / (speed or self.Speed)
						if f.Name ~= "Keyframe" then
							self.KeyframeReached:Fire(f.Name)
						end
						if f["Marker"] then
							for k,v in next, f.Marker do
								if self._markerSignal[k] then
									self._markerSignal[k]:Fire(v)
								end
							end
						end
						if f.Pose then
							for _,p in next, f.Pose do
								local ft = 0
								if i ~= 1 then
									ft = (t*(speed or self.Speed)-self.AnimationData.Frames[i-1].Time)/(speed or self.Speed)
								end
								self:_playPose(p, nil, ft)
							end
						end
						if t > clock()-start then
							repeat RunService.RenderStepped:Wait() until self == nil or self._stopped == true or clock()-start >= t
						end
					end
					if self == nil then return end
					RunService.RenderStepped:Wait()
					if self.Looped == true and self._stopped ~= true then
						self.DidLoop:Fire()
						self._isLooping = true
						return self:Play(fadeTime, weight, speed)
					end
					local TI = TweenInfo.new(self._stopFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					for _,r in next, Utility:getMotors(self.Character, self._motorIgnoreList) do
						if self._stopFadeTime > 0 then
							TweenService:Create(r, TI, {
								Transform = DefaultMotorCF,
								CurrentAngle = 0
							}):Play()
						else
							r.CurrentAngle = 0
							r.Transform = DefaultMotorCF
						end
					end
					for _, b in next, Utility:getBones(self.Character, self._boneIgnoreList) do
						if self._stopFadeTime > 0 then
							TweenService:Create(b, TI, {Transform = DefaultBoneCF}):Play()
						else
							b.Transform = DefaultBoneCF
						end
					end
					if self.Character:FindFirstChildOfClass("Humanoid") and not self.Character.Humanoid:FindFirstChildOfClass("Animator") and self.handleVanillaAnimator == true then
						Instance.new("Animator", self.Character.Humanoid)
					end
					if con then
						con:Disconnect()
					end
					con2:Disconnect()
					self._stopped = false
					self._playing = false
					self.IsPlaying = false
					self.Stopped:Fire()
				end)()
			end
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
		self.DidLoop = nil
		self.Stopped:Destroy()
		self.Stopped = nil
		self.KeyframeReached:Destroy()
		self.KeyframeReached = nil
		for _,s in next, self._markerSignal do
			s:Destroy()
			s = nil
		end
		self = nil
	end

	------------------------------------------------------------------

	---------------------------- MAIN ---------------------------

	getgenv().Animator = Animator

	getgenv().hookAnimatorFunction = function()
		local OldFunc
		OldFunc = hookmetamethod(game, "__namecall", function(Object, ...)
			local NamecallMethod = getnamecallmethod()
			if Object.ClassName == "Humanoid" and NamecallMethod == "LoadAnimation" and checkcaller() then
				local args = {...}
				if not args[2] or args[2] and args[2] ~= true then
					return Animator.new(Object.Parent, ...)
				end
			end
			return OldFunc(Object, ...)
		end)
		Utility:sendNotif("Hook Loaded\nby whited#4382", nil, 5)
	end

	Utility:sendNotif("API Loaded", nil, 5)

	--------------------------------------------------------------
end