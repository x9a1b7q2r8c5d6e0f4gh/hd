--[[
	TODO:
	- R15 Support
]]

-- Services
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Modules
local Trove = require(ReplicatedStorage.Packages.Trove)
local Sounds = require(ReplicatedStorage.Shared.Assets.Sounds)

local Joints = require(script.Joints)

local Ragdoll = {}
Ragdoll.__index = Ragdoll

--// Constructor
function Ragdoll.new(character: Model, component)
	local self = setmetatable({}, Ragdoll)

	local CameraController = require(Players.LocalPlayer.PlayerScripts.Client.Core.Camera)

	self.trove = Trove.new()
	self.character = character
	self.component = component

	self.ragdolled = false
	self.ragdoll_tasks = {}
	self.ragdoll_tasks_to_end = {}
	self.ragdoll_linear_forces = {}
	self.ragdoll_angular_forces = {}

	local player = Players:GetPlayerFromCharacter(character)

	-- Create ragdoll model
	local model = ReplicatedStorage.Shared.Assets[`Ragdoll{character:WaitForChild('Humanoid').RigType.Name}`]:Clone()
	model.Name = `{character.Name}'s Ragdoll`
	model.Parent = ReplicatedStorage
	model.Humanoid.AutoRotate = false

	model:AddTag("Ragdoll")
	model:RemoveTag("Character")
	self.trove:Add(model)

	-- Set CollisionGroups of ragdoll model
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Ragdoll"
		end
	end

	if player then
		model.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(math.clamp(player.UserId, 1, math.huge)))
	else
		model.Humanoid:ApplyDescription(character.Humanoid:GetAppliedDescription())
	end

	local fall_raycast_params = RaycastParams.new()
	fall_raycast_params.FilterDescendantsInstances = { model }
	fall_raycast_params.FilterType = Enum.RaycastFilterType.Exclude

	-- Create constraints for each Motor6D using JointCreator
	local joints = Joints.create(model, self.trove)

	self.model = model
	self.joints = joints

	-- Add ragdoll fall task
	self:AddRagdollTask("Fall", function()
		local trove = self.trove:Extend()
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		local sudden_stop_detected = false

		trove:Connect(RunService.Heartbeat, function(dt)
			for _, direction in { 2, -2 } do
				local rayOrigin = model.Head.Position
				local rayDirection = model.Head.CFrame.LookVector * direction
				local rayResult = workspace:Raycast(rayOrigin, rayDirection, fall_raycast_params)

				if rayResult and not model:IsAncestorOf(rayResult.Instance) and not character:IsAncestorOf(rayResult.Instance) then
					sudden_stop_detected = true
					trove:Clean()
				end
			end
		end)

		trove:Add(function()
			if sudden_stop_detected then
				if Players.LocalPlayer.Character == character then
					CameraController:Shake({
						Frequency = 0.12,
						Amplitude = .3,
						PositionInfluence = Vector3.one,
						RotationInfluence = Vector3.new(0, 0, 0.08),
						FadeInTime = 0,
						FadeOutTime = 0.6,
					})
				end

				Sounds.playSound(Sounds.Miscellaneous.FallThud, {
					RollOffMaxDistance = 30,
					Parent = humanoid.RootPart,
				}, SoundService:FindFirstChild("FallThud", true))
			end
		end)

		return trove
	end)

	return self
end

--// Add force to ragdoll
function Ragdoll:AddForce(linear: Vector3?, angular: Vector3?)
	if self.ragdolled then
		self.model.HumanoidRootPart.AssemblyAngularVelocity += angular or Vector3.zero
		self.model.HumanoidRootPart.AssemblyLinearVelocity += linear or Vector3.zero
	else
		table.insert(self.ragdoll_linear_forces, linear)
		table.insert(self.ragdoll_angular_forces, angular)
	end
end

--// Add a ragdoll task
function Ragdoll:AddRagdollTask(name: string, callback: () -> typeof(Trove))
	if self.ragdoll_tasks[name] then
		error(`task "{name}" already exists`)
	end
	self.ragdoll_tasks[name] = callback
end

--// Remove a ragdoll task
function Ragdoll:RemoveRagdollTask(name: string)
	self.ragdoll_tasks[name] = nil
end

--// Enable or disable ragdoll
function Ragdoll:SetEnabled(enabled: boolean)
	local character = self.character
	local model = self.model

	local character_humanoid: Humanoid = character:FindFirstChildOfClass("Humanoid")
	local model_humanoid: Humanoid = model:FindFirstChildOfClass("Humanoid")

	model.Parent = if enabled then workspace else ReplicatedStorage
	model_humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	character_humanoid.AutoRotate = not enabled
	character_humanoid.WalkSpeed = enabled and 0 or StarterPlayer.CharacterWalkSpeed

	-- If ragdolling ends, move the character to the model's position and clear stored forces
	if not enabled then
		character_humanoid.Parent:MoveTo(model.HumanoidRootPart.Position)
		table.clear(self.ragdoll_linear_forces)
		table.clear(self.ragdoll_angular_forces)
	end

	-- Pivot parts to main character and set physical properties to ragdoll
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
		--	part.CustomPhysicalProperties = PhysicalProperties.new(1, 1, 0, 1, 1)
			part.CFrame = character:FindFirstChild(part.Name).CFrame
		end
	end

	-- Set properties of main character
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			if not part:GetAttribute("Transparency") then
				part:SetAttribute("Transparency", part.Transparency)
			end
			part.Transparency = enabled and 0.9 or part:GetAttribute("Transparency")
		end
	end

	-- Set camera subject if the character is the local player's
	if character == Players.LocalPlayer.Character then
		workspace.CurrentCamera.CameraSubject = (enabled and (model:FindFirstChild("Head") or model.Humanoid)) or character.Humanoid
	end

	-- Move fake character to main character position
	model:PivotTo(character:GetPivot())

	self.ragdolled = enabled

	-- Apply all pending forces if ragdoll was enabled
	if enabled then
		for _, force in self.ragdoll_linear_forces do
			model.HumanoidRootPart.AssemblyLinearVelocity += force
		end

		table.clear(self.ragdoll_linear_forces)

		for _, angular in self.ragdoll_angular_forces do
			model.HumanoidRootPart.AssemblyAngularVelocity += angular
		end

		table.clear(self.ragdoll_angular_forces)
	end

	-- Start ragdoll tasks
	if enabled then
		for name, task in self.ragdoll_tasks do
			table.insert(self.ragdoll_tasks_to_end, task())
		end

	else
		for _, task in self.ragdoll_tasks_to_end do
			task:Destroy()
		end

		table.clear(self.ragdoll_tasks_to_end)
	end
end

--// Cleanup
function Ragdoll:Destroy()
	self.trove:Destroy()
end

return Ragdoll
