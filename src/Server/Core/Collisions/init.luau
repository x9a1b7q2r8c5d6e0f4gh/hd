-- dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Service = setmetatable({Name = script.Name}, require(ReplicatedStorage.Shared.Framework.Server))

-- private

-- methods

function Service:Init()
	
end

function Service:Start()
	require(script.Collisions)
end

return Service
