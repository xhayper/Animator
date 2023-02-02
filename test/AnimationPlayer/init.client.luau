local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Animator = require(script:WaitForChild("Animator")).new()

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

Character.Animate:Destroy()
Character.Humanoid.Animator:Destroy()

local Track = Animator:LoadAnimation(script:WaitForChild("Test"))
Track.Looped = true
Track:Play()

local RigList = {} :: { [string]: { [string]: Motor6D } }

for _, i in ipairs(Character:GetDescendants()) do
	if not i:IsA("Motor6D") then
		continue
	end
	RigList[i.Part0.Name] = RigList[i.Part0.Name] or {}
	RigList[i.Part0.Name][i.Part1.Name] = i
end

RunService.PreAnimation:Connect(function()
	task.desynchronize()
	Animator:Update()
	task.synchronize()

	for parentPoseName, childPoses in pairs(Animator._transforms) do
		for childPoseName, transform in pairs(childPoses) do
			if not RigList[parentPoseName] then
				continue
			end
			if not RigList[parentPoseName][childPoseName] then
				continue
			end
			RigList[parentPoseName][childPoseName].Transform = transform.CFrame
		end
	end
end)
