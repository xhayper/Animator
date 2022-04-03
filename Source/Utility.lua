local Utility = {}

local format = string.format
local find = table.find

function Utility:sendNotif(Text, Icon, Duration, Button1, Button2, Callback)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Animator",
		Text = (Text .. "\nBy hayper#0001") or nil,
		Icon = Icon or nil,
		Duration = Duration or nil,
		Button1 = Button1 or nil,
		Button2 = Button2 or nil,
		Callback = Callback or nil,
	})
end

local EnumTable = {
	["PoseEasingDirection"] = "EasingDirection",
	["PoseEasingStyle"] = "EasingStyle",
}

function Utility:convertEnum(enum)
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

function Utility:getBoneMap(Character, IgnoreObject)
	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'getBoneMap' (Instance expected, got %s)", typeof(Character)))
	end

	local BoneMap = {}
	local Descendants = Character:GetDescendants()

	for count = 1, #Descendants do
		local i = Descendants[count]
		local parent = i.Parent
		if
			parent == nil
			or i.ClassName ~= "Bone"
			or (IgnoreObject and IgnoreObject.IgnoreList and find(IgnoreObject.IgnoreList, i))
		then
			continue
		end
		if IgnoreObject and IgnoreObject.IgnoreIn and #IgnoreObject.IgnoreIn > 0 then
			local IsTained = false
			for count2 = 1, #IgnoreObject.IgnoreIn do
				local i2 = IgnoreObject.IgnoreIn[count2]
				if typeof(i2) == "Instance" and i:IsDescendantOf(i2) then
					IsTained = true
					break
				end
			end
			if IsTained then
				continue
			end
		end
		local T = BoneMap[parent.Name]
		if not T then
			T = {}
		end
		T[i.Name] = i
	end

	return BoneMap
end

function Utility:getMotorMap(Character, IgnoreObject)
	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'getMotorMap' (Instance expected, got %s)", typeof(Character)))
	end

	local MotorMap = {}
	local Descendants = Character:GetDescendants()

	for count = 1, #Descendants do
		local i = Descendants[count]
		if
			i.ClassName ~= "Motor6D"
			or (i.Part0 == nil or i.Part1 == nil)
			or (IgnoreObject and IgnoreObject.IgnoreList and find(IgnoreObject.IgnoreList, i))
		then
			continue
		end
		if IgnoreObject and IgnoreObject.IgnoreIn and #IgnoreObject.IgnoreIn > 0 then
			local IsTained = false
			for count2 = 1, #IgnoreObject.IgnoreIn do
				local i2 = IgnoreObject.IgnoreIn[count2]
				if typeof(i2) == "Instance" and i:IsDescendantOf(i2) then
					IsTained = true
					break
				end
			end
			if IsTained then
				continue
			end
		end
		local T = MotorMap[i.Part0.Name]
		if not T then
			T = {}
		end
		local TT = T[i.Part1.Name]
		if not TT then
			TT = {}
		end
		TT[#TT + 1] = i
	end

	return MotorMap
end

return Utility
