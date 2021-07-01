# Converter

## Usage

1. Copy the Converter soruce
2. Change the path
3. Run it in the Command Bar
4. There will be a StringValue dropped inside of the Instance, The value is the AnimationData.

## Data

```lua
{
	Priority = Enum.AnimationPriority, -- Animation Priority
	Loop = Boolean, -- Does the animation loop?
	AuthoredHipHeight = Number, -- Hip Height
	Frames = {
		{
			["Part Name"] = { -- Name of the part, For example, "HumanoidRootPart"
				CFrame = CFrame -- CFrame of the Animation
				EasingDirection = Enum.EasingDirection, -- Tween Easing Direction
				EasingStyle = Enum.EasingStyle, -- Tween Easing Style
				Weight = Number -- Animation Weight
			},
			Time = Number -- Timestamp of the animation
		}
	}
}
```
