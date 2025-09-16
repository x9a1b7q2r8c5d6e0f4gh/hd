local Joints = {}
local Map = require(script.Parent.Map)

function Joints.create(model, trove)
	local joints = {}

	

	for _, instance in model:GetDescendants() do
		if instance:IsA("Motor6D") then
			local motor_name = instance.Name
			motor_name = motor_name:gsub("Right", "")
			motor_name = motor_name:gsub("Left", "")
			motor_name = motor_name:gsub("Joint", "")
			motor_name = motor_name:gsub(" ", "")

			local attachment0 = Instance.new("Attachment")
			attachment0.Parent = instance.Part0
			attachment0.CFrame = instance.C0

			local attachment1 = Instance.new("Attachment")
			attachment1.Parent = instance.Part1
			attachment1.CFrame = instance.C1

			local constraint_info = Map[motor_name] or Map["Default"]
			local constraint = Instance.new(constraint_info.ClassName)
			constraint.Name = `{instance.Name}Constraint`
			constraint.Enabled = false
			constraint.Attachment0 = attachment0
			constraint.Attachment1 = attachment1
			constraint.Parent = instance.Parent

			if constraint_info.LimitsEnabled then
				constraint.LimitsEnabled = true
				for property, value in constraint_info.LimitsEnabled do
					constraint[property] = value
				end
			end

			instance.Enabled = false
			constraint.Enabled = true

			table.insert(joints, { instance, constraint })
			trove:Add(constraint)
		end
	end

	return joints
end

return Joints 