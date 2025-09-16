local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local t = require(ReplicatedStorage.Packages.t)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Remo = require(ReplicatedStorage.Packages.Remo)
local Signal = require(ReplicatedStorage.Packages.Signal)

local MyComponent = Component.new({ Tag = script.Name, Ancestors = { workspace } })

function MyComponent:Construct()
	local trove = Trove.new()
	self.trove = trove

	trove:AttachToInstance(self.Instance)
end

function MyComponent:Start()
	local instance = self.Instance
	local trove = self.trove

	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:WaitForChild("Humanoid") :: Humanoid

	for _, basePart in instance:GetChildren() do
        if basePart:IsA("BasePart") then
            basePart.CollisionGroup = "Character"
        end
    end
end

function MyComponent:Stop()
	self.trove:Destroy()
end

return MyComponent