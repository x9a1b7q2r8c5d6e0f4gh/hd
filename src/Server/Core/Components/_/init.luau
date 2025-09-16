local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local MyComponent = Component.new({ Tag = script.Name, Ancestors = {  } })

function MyComponent:Construct()
	local trove = Trove.new()
	self.trove = trove
end

function MyComponent:Start()
	local instance = self.Instance
	local trove = self.trove
end

function MyComponent:Stop()
	self.trove:Destroy()
end

return MyComponent