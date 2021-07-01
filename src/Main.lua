local pathToGithub = "https://raw.githubusercontent.com/xhayper/Animator/main/src"

local origRequire = require

getgenv().require = function(path)
	if string.sub(path, 1, 8) == "https://" or string.sub(path, 1, 7) == "http://" then
		return loadstring(game:HttpGet(path))()
	else
		return origRequire(path)
	end
end

getgenv().myRequire = function(path)
	return require(pathToGithub..path)
end

getgenv().Animator = myRequire(pathToGithub.."Animator.lua")