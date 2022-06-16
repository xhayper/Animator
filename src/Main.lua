local function formatUrl(path: string): string
    return "https://raw.githubusercontent.com/xhayper/Animator/dev/" .. path
end

local AnimatorUtility = loadstring((game :: any):HttpGet(formatUrl("src/AnimationTrack.lua"), true))()
local AnimationTrack = AnimatorUtility.httpRequire(formatUrl("src/AnimationTrack.lua"), true)
local Animator = AnimatorUtility.httpRequire(formatUrl("src/AnimationTrack.lua"), true)

local getgenv: () -> {[string]: any} = getgenv or nil

getgenv().Animator = Animator;
getgenv().AnimatorUtility = AnimatorUtility;
getgenv().AnimationTrack = AnimationTrack;