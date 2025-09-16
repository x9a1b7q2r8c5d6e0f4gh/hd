-- dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Controller = setmetatable({ Name = script.Name }, require(ReplicatedStorage.Shared.Framework.Client))

-- private

-- methods

function Controller:Init()
   
end

function Controller:Start()
   
end

return Controller

