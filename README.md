# Animator

Alternative Roblox animation player to fit your "Animating/Whatever" need

## Features

* Easy To Use
* Can play Non-Trusted Animation / Raw Animation Data (Use [Converter](https://github.com/xhayper/Animator/tree/main/Converter))
* R6, R15, Custom Rig/Animation Support
* Compatible with Nullware Reanimate (Used to replicate Animation)
* Replicate AnimationTrack's API

## Planned Feature

* Priority Support (Idk how)
* Weight System (Idk how)
* Seeking froward, Backward (Idl how)

## Credits
* Whited - Metatable Hook

## Installation

```lua
if getgenv()["Animator"] == nil then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
end
```

## Documentation

```lua
-- Constructor --

Animator.new(Player, AnimationData) -- Animation Data Should Be AnimationID as String/Number or KeyframeSequnce or Raw Animation Data or Animation Instance

-- Functions --

Animator:Play(fadeTime, weight, speed) -- Play the Animation with spefic fadeTime and speed, (Deault - fadeTime = 0.100000001, weight = 1, speed = 1)
Animator:Stop(fadeTime) -- Stop the Animation with spefic fadeTime, (Default - fadeTime = 0.100000001)
Animator:Destroy() -- Stop current animation and destroy the instance
Animator:GetMarkerReachedSignal(name) -- Return a signal that will fire when an marker with same name has been reached, (Args - Value)
Animator:GetTimeOfKeyframe(keyframeName) -- Get time position of the given frame name (first one)
Animator:AdjustSpeed(speed) -- Set playback Speed

-- Properties --

Animator.Looped -- Do you want the animation to Loop?
Animator.IsPlaying -- Is the animation playing?
Animator.Length -- Animation Length
Animator.Speed -- Playback Speed
Animator.Player -- The player that the animator is assigned to

-- Signals --

Animator.Stopped:Connect() -- Run when the animation ended
Animator.DidLooped:Connect() -- Run when the animation loop
Animator.KeyframeReached:Connect(keyframeName) -- On keyframe reached (Only trigger if the keyframe name isn't Keyframe

-- Globals --

HttpRequire("HttpLink") -- Require the module using GET Request, Must start with 'http://' or 'https://'
animatorRequire("Path") -- Used by Animator, Same as HttpRequire but with this repo link as the prefix
hookAnimatorFunction() -- Hook animator to Humanoid:LoadAnimation()
```

## Example

```lua
if getgenv()["Animator"] == nil then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
end

local Player = game:GetService("Players").LocalPlayer

local AnimationData = 123456789 -- Can also be KeyframeSequnce Instance, Table of data or ID as string

local Anim = Animator.new(Player, AnimationData)
Anim:Play()
Anim.Stopped:Wait()
print("Done!")
```

```lua
if getgenv()["Animator"] == nil then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
end

hookAnimatorFunction() -- Hook animator to Humanoid:LoadAnimation()

local Player = game:GetService("Players").LocalPlayer

local AnimationData = 123456789 -- Can also be KeyframeSequnce Instance, Table of data or ID as string

local Anim = Player.Character.Humanoid:LoadAnimation(AnimationData)
Anim:Play()
Anim.Stopped:Wait()
print("Done!")
```

## Animator with UI

* Note: UI Only support Animation ID

```lua
if getgenv()["Animator"] == nil then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
end

-- Main --
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer


local currentAnim

-- UI --

local Material = HttpRequire("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua")

local UI = Material.Load({
	Title = "Animator",
	Style = 3,
	SizeX = 200,
	SizeY = 230,
	Theme = "Dark"
})

-- MAIN --

local Main = UI.New({
	Title = "Animator"
})

local Animation = Main.TextField({
	Text = "Animation"
})

local Loop = Main.Toggle({
	Text = "Loop",
	Enabled = true
})

local Play = Main.Button({
	Text = "Play",
	Callback = function()
		if currentAnim ~= nil and currentAnim.IsPlaying == true then
			currentAnim:Destroy()
		end
		currentAnim = Animator.new(Player, Animation:GetText())
		currentAnim.Looped = Loop:GetState()
		currentAnim:Play()
		spawn(function()
			currentAnim.Stopped:Wait()
			currentAnim:Destroy()
		end)
	end
})

local Stop = Main.Button({
	Text = "Stop",
	Callback = function()
		if currentAnim ~= nil and currentAnim.IsPlaying == true then
			currentAnim:Stop()
		end
	end
})

-- REANIMATE --

local Nullware = UI.New({
	Title = "Nullware"
})

local NullwareLink = Nullware.TextField({
	Text = "Nullware Reanimate Link",
	Type = "Password"
})

local ReanimateConfiguration = Nullware.ChipSet({
	Text = "ReanimateConfiguration",
	Options = {
		["Anti-Fling"] = false,
		["R15 To R6"] = true,
		["Godmode"] = true
	}
})

Nullware.Button({
	Text = "Reanimate",
	Callback = function()
		if getgenv()["NullwareAPI"] == nil then
			local options = ReanimateConfiguration:GetOptions()
			options["Hats To Align"] = {}
			options["Netless"] = true
			options["Head Movement"] = true
			getgenv().Nullware_ReanimateConfiguration = options
			HttpRequire(NullwareLink:GetText())
		end
	end
})
```

## Note
* I did this for fun, if you get banned for this, it's your fault
* I am bored so i make this
