---------------------------------------
---- Dependencies ----
local ServerStorage = game:GetService("ServerStorage")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage.Shared.Config)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

---------------------------------------
---- Constructor ----

local Service = setmetatable({Name = script.Name}, require(ReplicatedStorage.Shared.Framework.Server))

---------------------------------------
---- Private ----

local Server = ServerScriptService.Server

local RewardList = require(Server.Modules.Libraries.Rewards)

---------------------------------------

function Service:ApplyReward(player: Player, reward: RewardList.Reward)
	--Service:Log(warn, `applying reward: {reward.name} ({table.unpack(reward.arguments)}) to {player.Name}`)
	return Promise.new(function(resolve, reject)
		if not reward then
			resolve()
		else
			resolve(RewardList[reward.name](player, table.unpack(reward.arguments)))
		end
	end)
end

function Service:ApplyRewards(player: Player, rewards: {RewardList.Reward})
	return Promise.new(function(resolve, reject)
		for _, reward in rewards do
			self:ApplyReward(player, reward):catch(error)
		end

		resolve()
	end)
end

function Service:Start()
	
end

function Service:Init()

end

return Service