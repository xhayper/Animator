local Utility = {}

local format = string.format

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

function Utility:getBones(Character, IgnoreList)
	IgnoreList = IgnoreList or {
		IgnoreIn = {},
		IgnoreList = {},
	}

	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'getBones' (Instance expected, got %s)", typeof(Character)))
	end

	local BoneList = {}
	local Descendants = Character:GetDescendants()

	for count = 1, #Descendants do
		local i = Descendants[count]
		if not i:IsA("Bone") then
			continue
		end
		local IsTained = false
		for count2 = 1, #IgnoreList.IgnoreList do
			local i2 = IgnoreList.IgnoreIn[count2]
			if typeof(i2) == "Instance" and (table.find(IgnoreList.IgnoreList, i) or i:IsDescendantOf(i2)) then
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

function Utility:getMotors(Character, IgnoreList)
	IgnoreList = IgnoreList or {
		IgnoreIn = {},
		IgnoreList = {},
	}

	if typeof(Character) ~= "Instance" then
		error(format("invalid argument 1 to 'getMotors' (Instance expected, got %s)", typeof(Character)))
	end

	local MotorList = {}
	local Descendants = Character:GetDescendants()
	for count = 1, #Descendants do
		local i = Descendants[count]
		if not i:IsA("Motor6D") then
			continue
		end
		local IsTained = false
		for count2 = 1, #IgnoreList.IgnoreList do
			local i2 = IgnoreList.IgnoreIn[count2]
			if typeof(i2) == "Instance" and (table.find(IgnoreList.IgnoreList, i) or i:IsDescendantOf(i2)) then
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

return Utility
