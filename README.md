# Animator

Basiclly

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/xhayper/Animator/main/src/Main.lua"))()
```

Usage

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
