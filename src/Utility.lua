local Utility = {}

local sub,len = string.sub, string.len

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
		if I:IsA("Motor6D") and (chrClone == nil or chrClone and I:IsDescendantOf(chrClone) ~= true) then
			local Part1Name = I.Part1.Name
			if RigMotor[Part1Name] then
				return error("Rig Error! Found 2 Motor6D with same Part1!")
			end
			RigMotor[Part1Name] = I
		end
	end
	return RigMotor
end

return Utility