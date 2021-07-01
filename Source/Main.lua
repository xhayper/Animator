local pathToGithub = "https://raw.githubusercontent.com/xhayper/Animator/main/Source/"
--[[
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

Utility:sendNotif("API Loaded", nil, 5)
]]--
print("Scrapped, Due to now having enough Knowledge")