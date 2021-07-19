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

function Utility:getMotors(Player)
	if not Player:IsA("Player") then
		error(format("invalid argument 1 to 'getMotors' (Player expected, got %s)", Player.ClassName))
	end

	local MotorList = {}

	for _,i in next, Player.Character:GetDescendants() do
		if i:IsA("Motor6D") and i.Part0 ~= nil and i.Part1 ~= nil then
			MotorList:insert(i)
		end
	end

	return MotorList
end

return Utility
