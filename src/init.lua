local RunService = game:GetService("RunService")

local AnimatorUtility = loadstring((game :: any):HttpGet("https://raw.githubusercontent.com/xhayper/Animator/dev/src/AnimationUtility.lua", true))()

-- selene: allow(unscoped_variables)
getgenv().AnimatorUtility = AnimatorUtility

local AnimationTrack = AnimatorUtility.httpRequire(AnimatorUtility.formatUrl("src/AnimationTrack.lua"), true)
local Animator = AnimatorUtility.httpRequire(AnimatorUtility.formatUrl("src/AnimationTrack.lua"), true)

-- selene: allow(unscoped_variables)
getgenv().AnimationTrack = AnimationTrack
-- selene: allow(unscoped_variables)
getgenv().Animator = Animator

RunService.RenderStepped:Connect(function(deltaTime)
    
end)