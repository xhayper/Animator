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

return Utility