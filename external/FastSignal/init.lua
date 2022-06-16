local IsDeferred: boolean do
	IsDeferred = false

	local bindable = Instance.new("BindableEvent")

	local handlerRun = false
	bindable.Event:Connect(function()
		handlerRun = true
	end)

	bindable:Fire()
	bindable:Destroy()

	if handlerRun == false then
		IsDeferred = true
	end
end

local DeferredSignal = AnimatorUtility.httpRequire(AnimatorUtility.formatUrl("external/FastSignal/Deferred.lua"), true)
local ImmediateSignal = AnimatorUtility.httpRequire(AnimatorUtility.formatUrl("external/FastSignal/Immediate.lua"), true)

export type Class = DeferredSignal.Class
export type ScriptConnection = DeferredSignal.ScriptConnection

local ChosenSignal = IsDeferred
	and DeferredSignal
	or ImmediateSignal

ChosenSignal.Deferred = DeferredSignal
ChosenSignal.Immediate = ImmediateSignal

return ChosenSignal :: typeof(DeferredSignal)