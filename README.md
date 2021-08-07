# Animator

Alternative Roblox animation player to fit your "Animating/Whatever" need

[Discord](https://discord.gg/D6A4WUe7hj)

## Features

* Easy To Use
* Can play Trusted/Non-Trusted Animation (AnimationID, KeyframeSequence Instance and Animation Instance) / Raw Animation Data (Use [KeyframeSequence-To-AnimationData](https://github.com/xhayper/Animator/tree/main/Utility))
* R6, R15, Custom Rig/Animation Support
* Mesh Deformation Support
* Simillar to Roblox's AnimationTrack Instance

## Note

* I gonna be real with you, this code is not that optimized
* This will lag a lot in some game, Until heavy optimization can be made, don't play that game if it lag

## Planned Feature

* Priority Support (Idk how)
* Weight System (Idk how)
* Seeking froward, Backward (Idk how)
* Heavy Optimization
* ~~Character instead of Player~~ Completed!

## Credits
* Whited - Metatable Hook

## Limitation
* Part need to be linked with Motor6D
* Can only do up to n (Usually 2) Character, more than that, it will lag like hell
* If your obfuscator do metatable stuff, it have a high chance of crashing the AIO verson, if that's the case, do not obfuscate the animator, obfuscate your code and put animator code at the top

## Resources

* AIO - [Here](https://github.com/xhayper/Animator/blob/main/Other/AIO.lua)

## Installation

```lua
if getgenv()["Animator"] == nil then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
end
```

## Documentation

```lua
-- Constructor --

Animator.new(Character, AnimationResolvable) -- AnimationResolvable Should Be AnimationID as String/Number or KeyframeSequnce or Raw Animation Data or Animation Instance

-- Functions --

Animator:Play(fadeTime, weight, speed) -- Play the Animation with spefic fadeTime and speed, (Deault - fadeTime = 0.100000001, weight = 1, speed = 1)
Animator:Stop(fadeTime) -- Stop the Animation with spefic fadeTime, (Default - fadeTime = 0.100000001)
Animator:Destroy() -- Stop current animation and destroy the instance
Animator:GetMarkerReachedSignal(name) -- Return a signal that will fire when an marker with same name has been reached, (Args - Value)
Animator:GetTimeOfKeyframe(keyframeName) -- Get time position of the given frame name (first one)
Animator:AdjustSpeed(speed) -- Set playback Speed
Animator:IgnoreMotorIn(tableOfInstance) -- Ignore motor that's a descendant of instance inside the table (must be table of Instance)
Animator:GetMotorIgnoreList() -- Return Table of Instance that the animator will use as Ignore list for Motor
Animator:IgnoreBoneIn(tableOfInstance) -- Ignore Bone that's a descendant of instance inside the table (must be table of Instance)
Animator:GetBoneIgnoreList() -- Return Table of Instance that the animator will use as Ignore list for Bone

-- Properties --

Animator.handleVanillaAnimator -- Should the animator delete humanoid's animator on play and add it back on stop
Animator.Looped -- Do you want the animation to Loop?
Animator.IsPlaying -- Is the animation playing?
Animator.Length -- Animation Length
Animator.Speed -- Playback Speed
Animator.Character -- The Character that the animator is assigned to

-- Signals --

Animator.Stopped:Connect() -- Run when the animation ended
Animator.DidLooped:Connect() -- Run when the animation loop
Animator.KeyframeReached:Connect(keyframeName) -- On keyframe reached (Only trigger if the keyframe name isn't Keyframe

-- Globals --

HttpRequire("HttpLink") -- Require the module using GET Request, Must start with 'http://' or 'https://'
animatorRequire("Path") -- Used by Animator, Same as HttpRequire but with this repo link as the prefix
hookAnimatorFunction() -- Hook animator to Humanoid:LoadAnimation()

-- Hooks --
-- This will only work if you call hookAnimatorFunction()

Humanoid:LoadAnimation(AnimationResolvable, UseDefaultLoadAnimation) -- AnimationResolvable - Should Be AnimationID as String/Number or KeyframeSequnce or Raw Animation Data or Animation Instance, UseDefaultLoadAnimation - Boolean
```

## Example

```lua
if getgenv()["Animator"] == nil then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
end

local Player = game:GetService("Players").LocalPlayer

local AnimationData = 123456789 -- Can also be KeyframeSequnce Instance, Table of data or ID as string

local Anim = Animator.new(Player.Character, AnimationData)
Anim:Play()
Anim.Stopped:Wait()
print("Done!")
```

```lua
if getgenv()["Animator"] == nil then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
	hookAnimatorFunction() -- Hook animator to Humanoid:LoadAnimation()
end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

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
			currentAnim:Stop(0) -- Honestly, :Destroy() might work better, but i can't seem to get it to work
			currentAnim.Stopped:Wait()
			RunService.Heartbeat:Wait()
		end
		currentAnim = Animator.new(Player.Character, Animation:GetText())
		if getgenv()["NullwareAPI"] then -- Nullware Complatible
			currentAnim:IgnoreMotorIn({NullwareAPI:GetCharacter("MainChar")})
			currentAnim:IgnoreBoneIn({NullwareAPI:GetCharacter("MainChar")})
		end
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
		["Godmode"] = false,
		["Disable Torso Collisions"] = false,
		["Enable Limb Collisions"] = false
	}
})

Nullware.Button({
	Text = "Reanimate",
	Callback = function()
		if getgenv()["NullwareAPI"] == nil then
			local options = ReanimateConfiguration:GetOptions()
			options["Hats To Align"] = {"All"}
			options["Netless"] = true
			options["Head Movement Without Godmode"] = true
			getgenv().Nullware_ReanimateConfiguration = options
			HttpRequire(NullwareLink:GetText())
		end
	end
})
```

## Note
* I did this for fun, if you get banned for this, it's your fault
* I am bored so i make this
