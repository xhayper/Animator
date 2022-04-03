# Animator

Alternative Roblox animation player to fit your "Animating/Whatever" need

## Features

* Easy To Use
* Can play Trusted/Non-Trusted Animation (AnimationID, KeyframeSequence Instance and Animation Instance) / Raw Animation Data (Use [KeyframeSequence-To-AnimationData](https://github.com/xhayper/Animator/tree/main/Utility))
* R6, R15, Custom Rig Support
* Mesh Deformation Support
* Simillar to Roblox's [AnimationTrack](https://developer.roblox.com/en-us/api-reference/class/AnimationTrack) API

## Note
* If you gonna obfuscate your script, it's highly recommended to obfuscate the animator's script as it can broke the script
* This doesn't replicate, you will need to re-animate with nullware

## Planned Feature
* Seeking froward, Backward (Idk how)

## Contributor
Whited

## Installation

```lua
if getgenv()["Animator"] == nil then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
end
```

## Documentation

# Reference

[Signal](https://github.com/Quenty/NevermoreEngine/blob/version2/Modules/Shared/Events/Signal.lua)

```lua
-- Types --

PoseData = {
	Name: string,
	CFrame: CFrame,
	EasingDirection: Enum.EasingDirection,
	EasingStyle: Enum.EasingStyle,
	Weight: number,
	Subpose?: PoseData[]
}

FrameData = {
	Name:string,
	Time:number,
	Pose:PoseData[],
	Marker?:{[string]: string[]}
}

AnimationData = {
	Loop:bool,
	Priority:Enum.AnimationPriority,
	Frames:FrameData[]
}

AnimationResolvable = string | number | AnimationData | KeyframeSequence | Animation

-- Constructor --

Animator.new(Character:Instance, AnimationResolvable:AnimationResolvable): Animator

-- Functions --

Animator:Play(FadeTime:number = 0.100000001, Weight:number?, Speed:number?): void -- Play the Animation with spefic FadeTime and Speed
Animator:Stop(FadeTime:number = 0.100000001): void -- Stop the Animation with spefic FadeTime
Animator:Destroy(): void -- Stop current animation and destroy the instance
Animator:GetMarkerReachedSignal(Name:string): Signal -- Return a signal that will fire when an marker with same name has been reached
Animator:GetTimeOfKeyframe(KeyframeName:string): number -- Get time position of the first frame with given frame name
Animator:AdjustSpeed(Speed:number): void -- Set playback Speed
Animator:IgnoreMotorIn(Instance:Instance): void -- Ignore all Motor6D in the instance
Animator:IgnoreBoneIn(Instance:Instance): void -- Ignore all Bone in the instance
Animator:IgnoreMotor(Motor6D:Motor6D): void -- Ignore a Motor6D instance
Animator:IgnoreBone(Bone:Bone): void -- Ignore a Bone instance

-- Properties --

Animator.BoneIgnoreInList: {[number]: Instance} -- Table of instance, If a motor is a descendant of instace in the table, It will be ignored
Animator.MotorIgnoreInList: {[number]: Instance} -- Table of instance, If a bone is a descendant of instace in the table, It will be ignored
Animator.BoneIgnoreList: {[number]: Instance} -- Table of instance, If a motor is in the table, It will be ignored
Animator.MotorIgnoreList: {[number]: Instance} -- Table of instance, If a bone is in the table, It will be ignored
Animator.handleVanillaAnimator: boolean -- Should the animator delete humanoid's animator on play and add it back on stop
Animator.Looped: boolean -- Do you want the animation to Loop?
Animator.IsPlaying: boolean -- Is the animation playing?
Animator.Length: number -- Animation Length
Animator.Speed: number -- Playback Speed
Animator.Character: Instance -- The Character that the animator is assigned to

-- Signals --

Animator.Stopped:Connect(): Signal -- Run when the animation ended
Animator.DidLooped:Connect(): Signal -- Run when the animation loop
Animator.KeyframeReached:Connect(KeyframeName:string): Signal -- On keyframe reached (Only trigger if the keyframe name isn't Keyframe

-- Global --

HttpRequire(HttpLink:string, noCache:boolean?): any -- Require the module using GET Request, Must start with 'http://' or 'https://', if noCache is true, cache the respond for future use
animatorRequire(Path:string): any -- Used by Animator, Same as HttpRequire but with this repo link as the prefix
hookAnimatorFunction(): void -- Hook animator to Humanoid:LoadAnimation()

httpRequireCache: {[string]: any} -- Cache table for HttpRequire

-- Hooks --
-- This will only work if you call hookAnimatorFunction() before

Humanoid:LoadAnimation(AnimationResolvable:AnimationResolvable, UseDefaultLoadAnimation:boolean?): Animator
```

## Example

```lua
if not getgenv()["Animator"] then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
end

local Player = game:GetService("Players").LocalPlayer

local Anim = Animator.new(Player.Character, 123456789)
Anim:Play()
Anim.Stopped:Wait()
print("Done!")
```

```lua
if not getgenv()["Animator"] then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
	hookAnimatorFunction() -- Hook animator to Humanoid:LoadAnimation()
end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Anim = ((Player.Character) or (Player.CharacterAdded:Wait()).Humanoid:LoadAnimation(123456789)
Anim:Play()
Anim.Stopped:Wait()
print("Done!")
```

## Animator with UI

* Note: UI Only support Animation ID

```lua
if not getgenv()["Animator"] then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/Source/Main.lua"))()
end

-- Main --
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
			task.wait()
		end
		currentAnim = Animator.new(Player.Character or Player.CharacterAdded:Wait(), Animation:GetText())
		if getgenv()["NullwareAPI"] then -- Nullware Complatible
			currentAnim:IgnoreMotorIn(NullwareAPI:GetCharacter("MainChar"))
			currentAnim:IgnoreBoneIn(NullwareAPI:GetCharacter("MainChar"))
		end
		currentAnim.Looped = Loop:GetState()
		currentAnim:Play()
		task.spawn(function()
			currentAnim.Stopped:Wait()
			currentAnim:Destroy()
		end)
	end
})

local Stop = Main.Button({
	Text = "Stop",
	Callback = function()
		if currentAnim and currentAnim.IsPlaying then
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
			["Anti-Fling"] = true,
			["Head Movement Without Godmode"] = true,
			["Enable Limb Collisions"] = true,
			["Disable Torso Collisions"] = false,
			["R15 To R6"] = true,
			["Godmode"] = false
	}
})

Nullware.Button({
	Text = "Reanimate",
	Callback = function()
		if not getgenv()["NullwareAPI"] then
			local options = ReanimateConfiguration:GetOptions()
			options["Hats To Align"] = {"All"}
			options["Netless"] = true
			getgenv().Nullware_ReanimateConfiguration = options
			HttpRequire(NullwareLink:GetText())
		end
	end
})
```
