local Utility = {}

local sub,len = string.sub, string.len

function Utility:sendNotif(Text, Icon, Duration, Button1, Button2, Callback)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Animator";
		Text = Text .. "\nBy hayper#0001" or nil;
		Icon = Icon or nil;
		Duration = Duration or nil;
		Button1 = Button1 or nil;
		Button2 = Button2 or nil;
		Callback = Callback or nil;
	})
end

function Utility:convertEnum(enum)
	local stringEnum = tostring(enum)
	local enumValue = stringEnum:split(".")[3]
	if (sub(stringEnum, 1, 24) == "Enum.PoseEasingDirection") then
		return Enum.EasingDirection[enumValue]
	elseif (sub(stringEnum, 1, 20) == "Enum.PoseEasingStyle") then
		return Enum.EasingStyle[enumValue]
	else
		return enum
	end
end

function Utility:getRigData(plr)
	local RigMotor = {}

	local chr = plr.Character
	local chrClone

	if chr:FindFirstChild(plr.Name) then
		chrClone = chr[plr.Name]
	end

	for _,I in pairs(chr:GetDescendants()) do
		if I:IsA("Motor6D") and (chrClone == nil or chrClone ~= nil and I:IsDescendantOf(chrClone) ~= true) then
			if I.Part0 ~= nil and I.Part1 ~= nil then
				local Part1Name = I.Part1.Name
				if RigMotor[Part1Name] then
					warn("Rig Error! Found 2 Motor6D with same Part1!")
				else
					RigMotor[Part1Name] = I
				end
			end
		end
	end
	return RigMotor
end

return Utility
