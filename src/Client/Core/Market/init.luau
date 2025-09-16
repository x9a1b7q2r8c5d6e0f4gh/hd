---------------------------------------
---- Dependencies ----

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ReplicaClient = require(ReplicatedStorage.Packages.Replica)

---------------------------------------
---- Constructor ----

local Controller = setmetatable({Name = script.Name}, require(ReplicatedStorage.Shared.Framework.Client))

---------------------------------------
---- Private ----

local Replica = nil

---------------------------------------

function Controller:GetProductInfo(product_id: number, info_type: Enum.InfoType)
	repeat task.wait() until Replica
    
	local info = Replica.Data.ProductInfo[tostring(product_id)]
	
	if not info then
		Controller:Log(print, `Product {product_id} not found in replica.. signaling server`)
		Controller:GetService('Market'):GetProductInfo(product_id, info_type):andThen(function(response)
			info = response
		end):catch(function(response)
			warn(response)
		end):await()
	end
	
	return info
end

function Controller:GetReplica()
	return Replica
end

function Controller:Start()
	ReplicaClient.OnNew('Market', function(replica)
		Replica = replica
	end)
end

function Controller:Init()
	
end

return Controller