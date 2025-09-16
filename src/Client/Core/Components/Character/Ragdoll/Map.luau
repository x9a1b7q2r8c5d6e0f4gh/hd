return {
	["Default"] = {
		ClassName = "BallSocketConstraint",
	},
	["Neck"] = {
		ClassName = "BallSocketConstraint",
		LimitsEnabled = {
			UpperAngle = 45,
			TwistLimitsEnabled = true,
			TwistLowerAngle = -60,
			TwistUpperAngle = 60,
		},
	},
	["Shoulder"] = {
		ClassName = "BallSocketConstraint",
		LimitsEnabled = {
			UpperAngle = 15,
			TwistLimitsEnabled = true,
			TwistLowerAngle = -45,
			TwistUpperAngle = 0,
		},
	},
	["Hip"] = {
		ClassName = "BallSocketConstraint",
		LimitsEnabled = {
			UpperAngle = 15,
			TwistLimitsEnabled = true,
			TwistLowerAngle = -45,
			TwistUpperAngle = 0,
		},
	},
}
