-----------------
--| Constants |--
-----------------

local GRAVITY_ACCELERATION = workspace.Gravity

local RELOAD_TIME = 3 -- Seconds until tool can be used again

local MISSILE_MESH_ID = 'http://www.roblox.com/asset/?id=2251534'
local MISSILE_MESH_SCALE = Vector3.new(0.35, 0.35, 0.25)
local ROCKET_PART_SIZE = Vector3.new(1.2, 1.2, 3.27)

-----------------
--| Variables |--
-----------------

local DebrisService = game:GetService('Debris')
local PlayersService = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Sound = require(ReplicatedStorage.Shared.Assets.Sounds)

local Tool = script.Parent
local ToolHandle = Tool:WaitForChild("Handle")
local MyPlayer = Tool.Parent:IsA('Backpack') and Tool.Parent.Parent or PlayersService:GetPlayerFromCharacter(Tool.Parent)

local MouseLoc = Instance.new('RemoteFunction')
MouseLoc.Name = 'MouseLoc'
MouseLoc.Parent = Tool

local RocketScript = script:WaitForChild('Rocket')

--NOTE: We create the rocket once and then clone it when the player fires
local Rocket = Instance.fromExisting(script.Parent.Rocket) do
	-- Set up the rocket part
	Rocket.Name = 'Rocket'
	Rocket.CanCollide = false
	Tool.Configuration:Clone().Parent = Rocket
	
	-- Add fire
	local fire = Instance.new('Fire', Rocket)
	fire.Heat = 5
	fire.Size = 2

	-- Add a force to counteract gravity
	local bodyForce = Instance.new('BodyForce', Rocket)
	bodyForce.Name = 'Antigravity'
	bodyForce.Force = Vector3.new(0, Rocket:GetMass() * GRAVITY_ACCELERATION, 0)

	-- Clone the sounds and set Boom to PlayOnRemove

	Sound.playSound(Sound.Miscellaneous.Swoosh, {
		Parent = Rocket,
		RollOffMaxDistance = 10000
	})

	local boom_sound = Sound.playSound(Sound.Miscellaneous.Boom, {
		Parent = Rocket,
		RollOffMaxDistance = 10000
	})

	boom_sound:Stop()
	boom_sound.PlayOnRemove = true

	local special_sound = Instance.new('Sound')
	special_sound.Name = 'SpecialSound'
	special_sound.Parent = Rocket
	special_sound.SoundId = Tool.Configuration.Sound.Value
	special_sound.RollOffMaxDistance = 10000

	local special_sound_distortion = Instance.new('DistortionSoundEffect')
	special_sound_distortion.Parent = special_sound
	special_sound_distortion.Level = .5
	special_sound_distortion.Enabled = true

	-- Attach creator tags to the rocket early on
	local creatorTag = Instance.new('ObjectValue', Rocket)
	creatorTag.Value = MyPlayer
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
	local iconTag = Instance.new('StringValue', creatorTag)
	iconTag.Value = Tool.TextureId
	iconTag.Name = 'icon'

	-- Finally, clone the rocket script and enable it
	local rocketScriptClone = RocketScript:Clone()
	rocketScriptClone.Parent = Rocket
	rocketScriptClone.Disabled = false
end

-----------------
--| Functions |--
-----------------

local function OnActivated()
	local myModel = MyPlayer.Character
	if Tool.Enabled and myModel and myModel:FindFirstChildOfClass("Humanoid") and myModel.Humanoid.Health > 0 then
		Tool.Enabled = false
		local Pos = MouseLoc:InvokeClient(MyPlayer)
		-- Create a clone of Rocket and set its color
		local rocketClone = Rocket:Clone()
		DebrisService:AddItem(rocketClone, 30)
		rocketClone.BrickColor = MyPlayer.TeamColor

		-- Position the rocket clone and launch!
		local spawnPosition = Tool.Rocket.CFrame.Position
		local unit = (Pos-spawnPosition).unit
		rocketClone.CFrame = CFrame.lookAlong(spawnPosition, unit) --NOTE: This must be done before assigning Parent
		rocketClone.Velocity = rocketClone.CFrame.LookVector * Tool.Configuration.Speed.Value --NOTE: This should be done before assigning Parent
		rocketClone.Parent = workspace
		rocketClone:SetNetworkOwner(nil)

		script.Parent.Rocket.Transparency = 1
		task.wait(RELOAD_TIME)
		script.Parent.Rocket.Transparency = 0

		Tool.Enabled = true
	end
end

--------------------
--| Script Logic |--
--------------------

Tool.Activated:Connect(OnActivated)
