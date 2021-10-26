--- repr - Version 1.1 (MODIFIED)
-- Ozzypig - ozzypig.com - http://twitter.com/Ozzypig
-- Check out this thread for more info:
-- https://devforum.roblox.com/t/repr-function-for-printing-tables/276575

local HttpService = game:GetService("HttpService")

local defaultSettings = {
	pretty = false;
	robloxFullName = false;
	robloxProperFullName = true;
	robloxClassName = true;
	tabs = false;
	semicolons = false;
	spaces = 3;
	sortKeys = true;
}

-- lua keywords
local keywords = {["and"]=true, ["break"]=true, ["do"]=true, ["else"]=true,
	["elseif"]=true, ["end"]=true, ["false"]=true, ["for"]=true, ["function"]=true,
	["if"]=true, ["in"]=true, ["local"]=true, ["nil"]=true, ["not"]=true, ["or"]=true,
	["repeat"]=true, ["return"]=true, ["then"]=true, ["true"]=true, ["until"]=true, ["while"]=true}

local function isLuaIdentifier(str)
	if type(str) ~= "string" then return false end
	-- must be nonempty
	if str:len() == 0 then return false end
	-- can only contain a-z, A-Z, 0-9 and underscore
	if str:find("[^%d%a_]") then return false end
	-- cannot begin with digit
	if tonumber(str:sub(1, 1)) then return false end
	-- cannot be keyword
	if keywords[str] then return false end
	return true
end

-- works like Instance:GetFullName(), but invalid Lua identifiers are fixed (e.g. workspace["The Dude"].Humanoid)
local function properFullName(object, usePeriod)
	if object == nil or object == game then return "" end

	local s = object.Name
	local usePeriod = true
	if not isLuaIdentifier(s) then
		s = ("[%q]"):format(s)
		usePeriod = false
	end

	if not object.Parent or object.Parent == game then
		return s
	else
		return properFullName(object.Parent) .. (usePeriod and "." or "") .. s 
	end
end

local depth = 0
local shown
local INDENT
local reprSettings

local function repr(value, reprSettings)
	reprSettings = reprSettings or defaultSettings
	INDENT = (" "):rep(reprSettings.spaces or defaultSettings.spaces)
	if reprSettings.tabs then
		INDENT = "\t"
	end

	local v = value --args[1]
	local tabs = INDENT:rep(depth)

	if depth == 0 then
		shown = {}
	end
	if type(v) == "string" then
		return ("%q"):format(v)
	elseif type(v) == "number" then
		if v == math.huge then return "math.huge" end
		if v == -math.huge then return "-math.huge" end
		return tonumber(v)
	elseif type(v) == "boolean" then
		return tostring(v)
	elseif type(v) == "nil" then
		return "nil"
	elseif type(v) == "table" and type(v.__tostring) == "function" then
	    	local success,string = pcall(function()
			return tostring(v.__tostring(v)) 
	    	end)
		return success and string or "\"Error while calling \\\"__tostring\\\"\""
	elseif type(v) == "table" and getmetatable(v) and type(getmetatable(v).__tostring) == "function" then
	    	local success,string = pcall(function()
	        	return tostring(getmetatable(v).__tostring(v))
	    	end)
		return success and string or "\"Error while calling \\\"getmetatable(v).__tostring(v)\\\"\""
	elseif type(v) == "table" then
		if shown[v] then return "\"{CYCLIC}\"" end
		shown[v] = true
		local str = "{" .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or "")
		local isArray = true
		for k, v in pairs(v) do
			if type(k) ~= "number" then
				isArray = false
				break
			end
		end
		if isArray then
			for i = 1, #v do
				if i ~= 1 then
					str = str .. (reprSettings.semicolons and ";" or ",") .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or " ")
				end
				depth = depth + 1
				str = str .. repr(v[i], reprSettings)
				depth = depth - 1
			end
		else
			local keyOrder = {}
			local keyValueStrings = {}
			for k, v in pairs(v) do
				depth = depth + 1
				local kStr = isLuaIdentifier(k) and k or ("[" .. repr(k, reprSettings) .. "]")
				local vStr = repr(v, reprSettings)
				--[[str = str .. ("%s = %s"):format(
					isLuaIdentifier(k) and k or ("[" .. repr(k, reprSettings) .. "]"),
					repr(v, reprSettings)
				)]]
				table.insert(keyOrder, kStr)
				keyValueStrings[kStr] = vStr
				depth = depth - 1
			end
			if reprSettings.sortKeys then table.sort(keyOrder) end
			local first = true
			for _, kStr in pairs(keyOrder) do
				if not first then
					str = str .. (reprSettings.semicolons and ";" or ",") .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or " ")
				end
				str = str .. ("%s = %s"):format(kStr, keyValueStrings[kStr])
				first = false
			end
		end
		shown[v] = false
		if reprSettings.pretty then
			str = str .. "\n" .. tabs
		end
		str = str .. "}"
		return str
	elseif typeof then
		-- Check Roblox types
		if typeof(v) == "Instance" then
			return  "\""..(reprSettings.robloxFullName
				and (reprSettings.robloxProperFullName and properFullName(v) or v:GetFullName())
				or v.Name) .. (reprSettings.robloxClassName and ((" (%s)"):format(v.ClassName)) or "").."\""
		elseif typeof(v) == "Axes" then
			local s = {}
			if v.X then table.insert(s, repr(Enum.Axis.X, reprSettings)) end
			if v.Y then table.insert(s, repr(Enum.Axis.Y, reprSettings)) end
			if v.Z then table.insert(s, repr(Enum.Axis.Z, reprSettings)) end
			return ("Axes.new(%s)"):format(table.concat(s, ", "))
		elseif typeof(v) == "BrickColor" then
			return ("BrickColor.new(%q)"):format(v.Name)
		elseif typeof(v) == "CFrame" then
			return ("CFrame.new(%s)"):format(table.concat({v:GetComponents()}, ", "))
		elseif typeof(v) == "Color3" then
			return ("Color3.new(%d, %d, %d)"):format(v.r, v.g, v.b)
		elseif typeof(v) == "ColorSequence" then
			if #v.Keypoints > 2 then
				return ("ColorSequence.new(%s)"):format(repr(v.Keypoints, reprSettings))
			else
				if v.Keypoints[1].Value == v.Keypoints[2].Value then
					return ("ColorSequence.new(%s)"):format(repr(v.Keypoints[1].Value, reprSettings))
				else
					return ("ColorSequence.new(%s, %s)"):format(
					repr(v.Keypoints[1].Value, reprSettings),
					repr(v.Keypoints[2].Value, reprSettings)
					)
				end
			end
		elseif typeof(v) == "ColorSequenceKeypoint" then
			return ("ColorSequenceKeypoint.new(%d, %s)"):format(v.Time, repr(v.Value, reprSettings))
		elseif typeof(v) == "DockWidgetPluginGuiInfo" then
			return ("DockWidgetPluginGuiInfo.new(%s, %s, %s, %s, %s, %s, %s)"):format(
			repr(v.InitialDockState, reprSettings),
			repr(v.InitialEnabled, reprSettings),
			repr(v.InitialEnabledShouldOverrideRestore, reprSettings),
			repr(v.FloatingXSize, reprSettings),
			repr(v.FloatingYSize, reprSettings),
			repr(v.MinWidth, reprSettings),
			repr(v.MinHeight, reprSettings)
			)
		elseif typeof(v) == "Enums" then
			return "Enums"
		elseif typeof(v) == "Enum" then
			return ("Enum.%s"):format(tostring(v))
		elseif typeof(v) == "EnumItem" then
			return ("Enum.%s.%s"):format(tostring(v.EnumType), v.Name)
		elseif typeof(v) == "Faces" then
			local s = {}
			for _, enumItem in pairs(Enum.NormalId:GetEnumItems()) do
				if v[enumItem.Name] then
					table.insert(s, repr(enumItem, reprSettings))
				end
			end
			return ("Faces.new(%s)"):format(table.concat(s, ", "))
		elseif typeof(v) == "NumberRange" then
			if v.Min == v.Max then
				return ("NumberRange.new(%d)"):format(v.Min)
			else
				return ("NumberRange.new(%d, %d)"):format(v.Min, v.Max)
			end
		elseif typeof(v) == "NumberSequence" then
			if #v.Keypoints > 2 then
				return ("NumberSequence.new(%s)"):format(repr(v.Keypoints, reprSettings))
			else
				if v.Keypoints[1].Value == v.Keypoints[2].Value then
					return ("NumberSequence.new(%d)"):format(v.Keypoints[1].Value)
				else
					return ("NumberSequence.new(%d, %d)"):format(v.Keypoints[1].Value, v.Keypoints[2].Value)
				end
			end
		elseif typeof(v) == "NumberSequenceKeypoint" then
			if v.Envelope ~= 0 then
				return ("NumberSequenceKeypoint.new(%d, %d, %d)"):format(v.Time, v.Value, v.Envelope)
			else
				return ("NumberSequenceKeypoint.new(%d, %d)"):format(v.Time, v.Value)
			end
		elseif typeof(v) == "PathWaypoint" then
			return ("PathWaypoint.new(%s, %s)"):format(
			repr(v.Position, reprSettings),
			repr(v.Action, reprSettings)
			)
		elseif typeof(v) == "PhysicalProperties" then
			return ("PhysicalProperties.new(%d, %d, %d, %d, %d)"):format(
			v.Density, v.Friction, v.Elasticity, v.FrictionWeight, v.ElasticityWeight
			)
		elseif typeof(v) == "Random" then
			return "\"<Random>\""
		elseif typeof(v) == "Ray" then
			return ("Ray.new(%s, %s)"):format(
			repr(v.Origin, reprSettings),
			repr(v.Direction, reprSettings)
			)
		elseif typeof(v) == "RBXScriptConnection" then
			return "\"<RBXScriptConnection>\""
		elseif typeof(v) == "RBXScriptSignal" then
			return "\"<RBXScriptSignal>\""
		elseif typeof(v) == "Rect" then
			return ("Rect.new(%d, %d, %d, %d)"):format(
			v.Min.X, v.Min.Y, v.Max.X, v.Max.Y
			)
		elseif typeof(v) == "Region3" then
			local min = v.CFrame.p + v.Size * -.5
			local max = v.CFrame.p + v.Size * .5
			return ("Region3.new(%s, %s)"):format(
			repr(min, reprSettings),
			repr(max, reprSettings)
			)
		elseif typeof(v) == "Region3int16" then
			return ("Region3int16.new(%s, %s)"):format(
			repr(v.Min, reprSettings),
			repr(v.Max, reprSettings)
			)
		elseif typeof(v) == "TweenInfo" then
			return ("TweenInfo.new(%d, %s, %s, %d, %s, %d)"):format(
			v.Time, repr(v.EasingStyle, reprSettings), repr(v.EasingDirection, reprSettings),
			v.RepeatCount, repr(v.Reverses, reprSettings), v.DelayTime
			)
		elseif typeof(v) == "UDim" then
			return ("UDim.new(%d, %d)"):format(
			v.Scale, v.Offset
			)
		elseif typeof(v) == "UDim2" then
			return ("UDim2.new(%d, %d, %d, %d)"):format(
			v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset
			)
		elseif typeof(v) == "Vector2" then
			return ("Vector2.new(%d, %d)"):format(v.X, v.Y)
		elseif typeof(v) == "Vector2int16" then
			return ("Vector2int16.new(%d, %d)"):format(v.X, v.Y)
		elseif typeof(v) == "Vector3" then
			return ("Vector3.new(%d, %d, %d)"):format(v.X, v.Y, v.Z)
		elseif typeof(v) == "Vector3int16" then
			return ("Vector3int16.new(%d, %d, %d)"):format(v.X, v.Y, v.Z)
		else
			return "\"<Roblox:" .. typeof(v) .. ">\""
		end
	else
		return "\"<" .. type(v) .. ">\""
	end
end
------------------------------------------------------------------------------------------------------------------------------

local format = string.format

local EnumTable = {
	["PoseEasingDirection"] = "EasingDirection",
	["PoseEasingStyle"] = "EasingStyle"
}

function convertEnum(enum)
	local a = tostring(enum):split(".")
	if a[1] == "Enum" then
		local p = a[2]
		local v = a[3]
		v = v == "Constant" and "Linear" or v
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
		if not IsTained then
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
		if not IsTained then
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

local KeyframeSequnce = path.to.KeyframeSequnce
local AnimationData = repr(parseAnimationData(KeyframeSequnce))
local stringValue = Instance.new("StringValue", KeyframeSequnce)
stringValue.Name = "AnimationData"
stringValue.Value = "local AnimationData = " .. AnimationData
