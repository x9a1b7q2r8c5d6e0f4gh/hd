local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Remo = require(ReplicatedStorage.Packages.Remo)
local Comm = require(ReplicatedStorage.Packages.Comm)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local PathUtil = require(ReplicatedStorage.Packages.PathUtil)

local Ragdoll = require(script.Ragdoll)

local MyComponent = Component.new({ Tag = script.Name, Ancestors = { workspace } })

function MyComponent:Construct()
	local character = self.Instance

	local trove = Trove.new()
	trove:AttachToInstance(character)
	self.trove = trove
end

function MyComponent:Start()
	local character: Model = self.Instance
	local trove = self.trove

	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	trove:Connect(RunService.PreSimulation, function(dt)
		
	end)
end

function MyComponent:Stop()
	self.trove:Destroy()
end

return MyComponent
