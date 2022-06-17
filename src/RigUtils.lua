local RigUtils = {}

type Array<V> = {[number]: V}
type Map<K, V> = {[K]: V}

function RigUtils.getRigInfo(rig: Instance): (Array<Instance>, Map<string, Motor6D>, Map<string, Bone>)
	local parts = {}
	local motors = RigUtils.getMotors(rig)

	local partNameToMotorMap = {}

	local descendants = rig:GetDescendants()

	for _, child in ipairs(descendants) do
		if child:IsA("BasePart") then
			for _, motor in ipairs(motors) do
				if motor.Part1 == child then
					partNameToMotorMap[child.Name] = motor
					table.insert(parts, child)
					break
				end
			end
		elseif child:IsA("Bone") then
			table.insert(parts, child)
		end
	end

	local bones = RigUtils.getBones(rig)
	local boneNameToBoneInstanceMap = {}

	for _, bone in ipairs(bones) do
		boneNameToBoneInstanceMap[bone.Name] = bone
	end

	return parts, partNameToMotorMap, boneNameToBoneInstanceMap
end

function RigUtils.getMotors(rig: Instance): Array<Motor6D>
    local motors = {}

    local descendants = rig:GetDescendants()

    for _, child in ipairs(descendants) do
        if child:IsA("Motor6D") then
            table.insert(motors, child)
        end
    end
    return motors
end

function RigUtils.getBones(rig: Instance): Array<Bone>
    local bones = {}

    local descendants = rig:GetDescendants()

    for _, child in ipairs(descendants) do
        if child:IsA("Bone") then
            table.insert(bones, child)
        end
    end
    return bones
end

return RigUtils