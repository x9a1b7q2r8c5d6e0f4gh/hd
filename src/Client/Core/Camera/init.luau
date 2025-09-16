-- dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Shake = require(ReplicatedStorage.Packages.Shake)

local Controller = setmetatable({ Name = script.Name }, require(ReplicatedStorage.Shared.Framework.Client))

-- private

local Camera = workspace.CurrentCamera

-- methods

function Controller:Shake(properties: {any?})
	local shake_priority = Enum.RenderPriority.Last.Value

	local shake = Shake.new()
	shake.FadeInTime = 0
	shake.Frequency = 0.1
	shake.Amplitude = 5
	shake.RotationInfluence = Vector3.new(0.1, 0.1, 0.1)

	for key, value in properties do
		shake[key] = value
	end

	shake:Start()

	local last = os.clock()

	shake:BindToRenderStep(Shake.NextRenderName(), shake_priority, function(shake_position, shake_rotation, is_shake_done)
		local delta_time = os.clock() - last
		local delta_influence = delta_time * 60

		last = os.clock()
		Camera.CFrame *= CFrame.new(shake_position) * CFrame.Angles(shake_rotation.X * delta_influence, shake_rotation.Y * delta_influence, shake_rotation.Z)
	end)

    return shake
end

function Controller:Init() end

function Controller:Start() end

return Controller
