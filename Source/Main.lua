local RunService = game:GetService("RunService")

local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local pathToGithub = "https://raw.githubusercontent.com/xhayper/Animator/main/Source/"

getgenv().HttpRequire = function(path)
	if string.sub(path, 1, 8) == "https://" or string.sub(path, 1, 7) == "http://" then
		return loadstring(game:HttpGet(path))()
	else
		return require(path)
	end
end

getgenv().animatorRequire = function(path)
	return HttpRequire(pathToGithub..path)
end

getgenv().Animator = animatorRequire("Animator.lua")

local Utility = animatorRequire("Utility.lua")

getgenv().hookAnimatorFunction = function()
	local OldFunc
	OldFunc = hookmetamethod(game, "__namecall", function(Object, ...)
		local NamecallMethod = getnamecallmethod()
		if Object.ClassName == "Humanoid" and Object.Parent == Player.Character and NamecallMethod == "LoadAnimation" and checkcaller() then
			return Animator.new(Player, ...)
		end
		return OldFunc(Object, ...)
	end)
	Utility:sendNotif("Hook Loaded\nby whited#4382", nil, 5)
end

Utility:sendNotif("API Loaded", nil, 5)

return "Nullware my beloved <3"