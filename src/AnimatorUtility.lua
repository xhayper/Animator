--[=[
    @class AnimatorUtility

    Utility class used by Animator to drive the animations
]=]
local AnimatorUtility = {}
AnimatorUtility.__index = AnimatorUtility

type Map<K, V> = {[K]: V}

--[=[
    @type RequireResult {[any]: any} | any
    @within AnimatorUtility
]=]
type RequireResult = Map<any, any> | any

local requireCache: Map<string, RequireResult> = {}

--[=[
    Return the result of a require call from the url.

    @param url string -- The url to require
    @param useCache boolean? -- Whether to use the cached result or not

    @return RequireResult -- The result of the require calls
]=]
function AnimatorUtility.httpRequire(url: string, useCache: boolean?): RequireResult
    if useCache then
        local cache = requireCache[url]
        if cache then return requireCache[url] end
    end

    local result: RequireResult = loadstring((game :: any):HttpGet(url, true))()

    if useCache then
        requireCache[url] = result
    end

    return result
end

return AnimatorUtility