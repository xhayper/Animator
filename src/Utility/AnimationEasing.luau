local sin = math.sin

export type EasingFunction = (t: number) -> number

local function bounce(x: number): number
	return x < 0.36363636 and 7.5625 * x ^ 2
		or x < 0.72727272 and 7.5625 * (x - 0.54545454) ^ 2 + 0.75
		or x < 0.90909090 and 7.5625 * (x - 0.81818181) ^ 2 + 0.9375
		or 7.5625 * (x - 0.95454545) ^ 2 + 0.984375
end

local EasingStylesFunction: { [Enum.PoseEasingStyle]: { [Enum.PoseEasingDirection]: EasingFunction } } = {}

EasingStylesFunction[Enum.PoseEasingStyle.Linear] = {
	[Enum.PoseEasingDirection.In] = function(x)
		return x
	end,
	[Enum.PoseEasingDirection.Out] = function(x)
		return x
	end,
	[Enum.PoseEasingDirection.InOut] = function(x)
		return x
	end,
}

EasingStylesFunction[Enum.PoseEasingStyle.Constant] = {
	[Enum.PoseEasingDirection.In] = function(x)
		return x > 0 and 1 or 0
	end,
	[Enum.PoseEasingDirection.Out] = function(x)
		return x >= 1 and 1 or 0
	end,
	[Enum.PoseEasingDirection.InOut] = function(x)
		return x >= 0.5 and 1 or 0
	end,
}

EasingStylesFunction[Enum.PoseEasingStyle.Elastic] = {
	[Enum.PoseEasingDirection.In] = function(x)
		return -(2 ^ (-10 * (1 - x))) * sin(20.944 * (0.925 - x))
	end,
	[Enum.PoseEasingDirection.Out] = function(x)
		return (2 ^ (-10 * x)) * sin(20.944 * (x - 0.075)) + 1
	end,
	[Enum.PoseEasingDirection.InOut] = function(x)
		return x < 0.5 and -0.5 * (2 ^ (-10 * (1 - 2 * x))) * sin(13.9626 * (0.8875 - 2 * x))
			or 1 + 0.5 * (2 ^ (-10 * (2 * x - 1))) * sin(13.9626 * (2 * x - 1.1125))
	end,
}

EasingStylesFunction[Enum.PoseEasingStyle.Cubic] = {
	[Enum.PoseEasingDirection.In] = function(x)
		return 1 - (1 - x) ^ 3
	end,
	[Enum.PoseEasingDirection.Out] = function(x)
		return x ^ 3
	end,
	[Enum.PoseEasingDirection.InOut] = function(x)
		return x < 0.5 and 4 * x ^ 3 or 1 - 4 * (1 - x) ^ 3
	end,
}

EasingStylesFunction[Enum.PoseEasingStyle.Bounce] = {
	[Enum.PoseEasingDirection.In] = function(x)
		return 1 - bounce(1 - x)
	end,
	[Enum.PoseEasingDirection.Out] = function(x)
		return bounce(x)
	end,
	[Enum.PoseEasingDirection.InOut] = function(x)
		return x < 0.5 and 0.5 - 0.5 * bounce(1 - 2 * x) or 1 - 0.5 * bounce(2 - 2 * x)
	end,
}

return EasingStylesFunction
