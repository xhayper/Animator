local pathToGithub = "https://raw.githubusercontent.com/xhayper/Animator/main/Source/"

getgenv().HttpRequire = function(path)
	if string.sub(path, 1, 8) == "https://" or string.sub(path, 1, 7) == "http://" then
		return loadstring(syn and syn.request and syn.request(path).Body or game:HttpGet(path))()
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
		if not checkcaller() or Object.ClassName ~= "Humanoid" or NamecallMethod ~= "LoadAnimation" then return OldFunc(Object, ...) end
		local args = {...}
		if not args[2] or args[2] == true then return OldFunc(Object, ...) end
		return Animator.new(Object.Parent, ...)
	end)
	Utility:sendNotif("Hook Loaded\nby whited#4382", nil, 5)
end

Utility:sendNotif("API Loaded", nil, 5)

return "Nullware my beloved <3"
