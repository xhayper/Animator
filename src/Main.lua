local pathToGithub = "https://raw.githubusercontent.com/xhayper/Animator/main/src/"

getgenv().HttpRequire = function(path)
	if string.sub(path, 1, 8) == "https://" or string.sub(path, 1, 7) == "http://" then
		return loadstring(game:HttpGet(path))()
	else
		return require(path)
	end
end

getgenv().myRequire = function(path)
	return HttpRequire(pathToGithub..path)
end

getgenv().Animator = myRequire("Animator.lua")