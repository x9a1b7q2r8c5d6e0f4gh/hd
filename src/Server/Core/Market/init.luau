---------------------------------------
---- Dependencies ----

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Replica = require(ReplicatedStorage.Packages.Replica)

---------------------------------------
---- Constructor ----

local Service = setmetatable({Name = script.Name}, require(ReplicatedStorage.Shared.Framework.Server))

---------------------------------------
---- Private ----

local Server = ServerScriptService.Server

local Config = require(ReplicatedStorage.Shared.Config)
local ProductList = require(ReplicatedStorage.Shared.Modules.Libraries.Products)

local ReplicaToken = Replica.Token('Market')
local Replica = Replica.New({
	['Token'] = ReplicaToken,
	['Data'] = {ProductInfo = {}}
})

local function getProductInfo(product_id: number, info_type: Enum.InfoType)
	return Promise.new(function(resolve, reject)
		resolve(MarketplaceService:GetProductInfo(product_id, info_type))
	end)
end

local function onPlayerDataLoaded(player: Player)
	local data_service = require(Server.Core.Data)
	local economy_service = require(Server.Core.Economy)

	local player_data = player and data_service:Get(player)
	local player_data_replica = player_data.replica

	local new_gamepasses = {}

	for gamepass_id, gamepass_info in ProductList.Content.Gamepass.Content do
		local success, response = pcall(function()
			if MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass_id) and not table.find(player_data.profile.Data.market.Gamepasses, gamepass_id)  then
				table.insert(new_gamepasses, gamepass_id)
				table.insert(player_data.profile.Data.market.Gamepasses, gamepass_id)
			end
		end)

		if not success then
			warn(response)
		end
	end

	if not player.Parent then
		warn('player left before initializing market data')
		return
	end

	if not player_data.active then 
		return
	end

	player_data_replica:Set({'Market'}, {
		Gamepasses = player_data.profile.Data.market.Gamepasses
	})

	for _, gamepass_id in new_gamepasses do
		local gamepass_info = ProductList:Get(gamepass_id)

		if gamepass_info.properties.economy.reward then
			economy_service:ApplyReward(player, gamepass_info.properties.economy.reward):catch(warn)
		end
	end
	
	for _, gamepass_id in player_data_replica.Data.Market.Gamepasses do
		local gamepass_info = ProductList:Get(gamepass_id)
		if not gamepass_info then Service:Log(warn, `Gamepass info for {gamepass_id} not found`) continue end

		if gamepass_info.properties.economy.recurring_reward then
			economy_service:ApplyReward(player, gamepass_info.properties.economy.recurring_reward):catch(warn)
		end
	end

	player_data.profile:MessageHandler(function(message, processed)
		if message.type == 'Gift' then
			economy_service:ApplyReward(player, message.arguments.reward):andThen(function(result)
				processed()
			end):catch(function(response) 
				Service:Log(warn, `error applying gift: {response}`)
			end):await()	
		end
	end)
end

local function processReceipt(receipt_info: {})
	local data_service = require(Server.Core.Data)
	local economy_service = require(Server.Core.Economy)

	local player = Players:GetPlayerByUserId(receipt_info.PlayerId)

	local player_store = data_service:GetStore()
	local player_data = player and data_service:Get(player)
	local player_data_replica = player_data.replica
	local product_info, product_category, product_is_gift = ProductList:Get(receipt_info.ProductId)

	if not player then
		Service:Log(warn, `ProcessReceipt Error {receipt_info.PurchaseId}: Player not found while processing receipt`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if product_info then
		local decision = Enum.ProductPurchaseDecision.NotProcessedYet
		local giftee = player_data.data.Market.Giftee

		if giftee then
			player_store:MessageAsync(`{giftee}`, {
				['type'] = 'Gift',
				['arguments'] = {
					from = player.UserId, at = os.time(),
					reward = {name = 'Product', arguments = {product_category.InfoType.Name == 'Gamepass' and product_is_gift or receipt_info.ProductId}},
				}
			})

			decision = Enum.ProductPurchaseDecision.PurchaseGranted
		else
			if product_category.Name == 'Gamepass' then
				player_data_replica:TableInsert({'Market', 'Gamepasses'}, receipt_info.ProductId)
			end

			economy_service:ApplyReward(player, product_info.properties.economy.reward):andThen(function(result)
				decision = Enum.ProductPurchaseDecision.PurchaseGranted
			end):catch(function(response) 
				Service:Log(warn, `ProcessReceipt Error {receipt_info.PurchaseId}: {response}`)
			end):await()
		end

		return decision
	else
		Service:Log(warn, `ProcessReceipt Error {receipt_info.PurchaseId}: Product data for {receipt_info.ProductId} not found`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

---------------------------------------

function Service:GetProductInfo(product_id: number, info_type: Enum.InfoType)
	product_id = tostring(product_id)

	if not Replica.Data.ProductInfo[product_id] then
		Promise.retryWithDelay(getProductInfo, 10, 1, product_id, info_type):andThen(function(result)
			Replica:Set({'ProductInfo', product_id}, result)
			--Service:Log(print, `{product_id} added to ProductInfo cache`)

			task.delay(Config.Market.ProductInfoLifetime, function() 
				Replica:Set({'ProductInfo', product_id}, nil)
				--Service:Log(print, `{product_id} removed from ProductInfo cache`)
			end)
		end):catch(warn):await()
	end

	return Replica.Data.ProductInfo[product_id]
end

function Service:PromptPurchase(player: Player, target_product_id: number)
	local product_data, product_category, product_is_gift = ProductList:Get(target_product_id)

	if (product_category.InfoType == Enum.InfoType.Product) or product_is_gift then
		MarketplaceService:PromptProductPurchase(player, target_product_id)
	elseif product_category.InfoType == Enum.InfoType.GamePass then
		MarketplaceService:PromptGamePassPurchase(player, target_product_id)
	end
end

function Service:Start()
	local data_service = require(Server.Core.Data)

	Replica:Replicate()

	data_service.PlayerDataLoaded:Connect(onPlayerDataLoaded)

	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, gamePassId: number, wasPurchased: boolean) 
		local player_data = data_service:Get(player)

		if wasPurchased then 
			processReceipt({
				['PlayerId'] = player.UserId,
				['ProductId'] = gamePassId,
				['PurchaseId'] = 'GamepassPurchase',
			})
		end

		player_data.data.Market.Busy = false
	end)

	MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId: number, productId: number, isPurchased: boolean) 
		local player_data = data_service:Get(Players:GetPlayerByUserId(userId))
		player_data.data.Market.Busy = false
	end)

	Service:BindFunction('GetProductInfo', function(player: Player, product_id: number, info_type: Enum.InfoType)
		return Service:GetProductInfo(product_id, info_type)
	end)

	Service:BindFunction('Purchase', function(player: Player, product_id: number, giftee: number)
		local player_data = data_service:Get(player)

		if player_data.data.Market.Busy then return end
		player_data.data.Market.Busy = true

		local product_info, product_category = ProductList:Get(product_id)

		assert(product_info, `invalid product {product_id}`)

		player_data.data.Market.Giftee = giftee

		if giftee then
			if product_category.Name == 'Gamepass' then
				Service:PromptPurchase(player, product_info.gift) -- It is a gamepass gift, so use the "gift" devproduct attached to the gamepass for the purchase
			elseif product_category.Name == 'DevProduct' then
				Service:PromptPurchase(player, product_id)
			end
		else
			Service:PromptPurchase(player, product_id)
		end
	end)
end

function Service:Init()

end

return Service