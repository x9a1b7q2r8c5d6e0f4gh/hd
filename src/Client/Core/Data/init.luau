-- dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Replica = require(ReplicatedStorage.Packages.Replica)

local Controller = setmetatable({ Name = script.Name }, require(ReplicatedStorage.Shared.Framework.Client))

-- private

local PlayerReplica = nil

-- methods

function Controller:Get()
   while not PlayerReplica do task.wait() end
   return PlayerReplica
end

function Controller:Init()
   
end

function Controller:Start()
   Replica.OnNew('Player', function(replica)
      PlayerReplica = replica
   end)

   Replica.RequestData()
end

return Controller

