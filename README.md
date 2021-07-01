# Animator

## Features

* Easy To Use
* Can play Non-Trusted Animation
* R6, R15, Custom Rig Support

## Planned Feature

* Priority Support (Idk how)
* Weight System (Idk how)

## Installation

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/src/Main.lua"))()
```

## Documentation

```lua
-- Constructor --

Animator.new(Player, AnimationData) -- Animation Data Should Be AnimationID as String/Number or KeyfraneSequnce or Raw Animation Data (Converter will be provied in next update)

-- Functions --

Animator:Play() -- Play the Animation
Animator:Stop() -- Stop the Animation
Animator:GetPlayer() -- Get assigned Player
Animator.isPlaying -- Is the animation playing?

-- Globals --

HttpRequire("HttpLink") -- Require the module using GET Request, Must start with 'http://' or 'https://'
animatorRequire("Path") -- Used by Animator, Same as HttpRequire but with this repo link as the prefix
```

## Example

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/src/Main.lua"))()

local Player = game:GetService("Players").LocalPlayer

local AnimationData = 5806573931 -- Can also be KeyframeSequnce Instance, Table of data or ID as string

local Anim = Animator.new(Player, AnimationData)
Anim.Looped = false -- True by default
Anim:Start()
wait(5)
Anim:Stop()
```

## GUI Version

* Work best with Nullware

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/src/Main.lua"))()

-- Main --

local plr = game:GetService("Players").LocalPlayer

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

local Main = UI.New({
	Title = "Animator"
})

local Nullware = UI.New({
	Title = "Nullware"
})

-- PLAYER --

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
		if currentAnim ~= nil and currentAnim.isPlaying == true then
			currentAnim:Stop()
			wait()
		end
		currentAnim = Animator.new(plr, Animation:GetText())
		currentAnim.Looped = Loop:GetState()
		currentAnim:Start()
	end
})

local Stop = Main.Button({
	Text = "Stop",
	Callback = function()
		if currentAnim.isPlaying == true then
			currentAnim:Stop()
		end
	end
})

-- REANIMATE --

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
