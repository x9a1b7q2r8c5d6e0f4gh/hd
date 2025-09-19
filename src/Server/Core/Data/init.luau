local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ProfileStore = require(ServerScriptService.Packages.ProfileStore)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local PathUtil = require(ReplicatedStorage.Packages.PathUtil)
local Replica = require(ReplicatedStorage.Packages.Replica)

local PlayerStore = ProfileStore.New(Config.Data.PlayerStoreName, require(script.Templates.Profile))
local PlayerDataMethods = require(script.Methods)

local PlayerProfiles = {}

local PlayerReplicaToken = Replica.Token('Player')


local Service = setmetatable({Name = script.Name}, require(ReplicatedStorage.Shared.Framework.Server))
Service.PlayerDataLoaded = Signal.new()

function Service:Load(player: Player)
	local data = setmetatable({trove = Trove.new(), data = {}}, PlayerDataMethods)

	data.data = TableUtil.Copy(require(script.Templates.Server), true)
	data.active = true

	-- signals --

	data.Changed = data.trove:Add(Signal.new())
	data.Inserted = data.trove:Add(Signal.new())

	-- profile --

	local store = Config.Data.PlayerStoreMockEnabled and PlayerStore.Mock or PlayerStore

	local profile = store:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	data.trove:Add(function()
		data.active = false
		PlayerProfiles[player] = nil
		-- player:Kick('duplicate session detected - please rejoin')
	end)

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			data.trove:Clean()
			print(`profile saved for {player.Name}!`)
		end)

		if player.Parent == Players then
			data.profile = profile
			PlayerProfiles[player] = data
			print(`profile loaded for {player.Name}!`)
		else
			profile:EndSession()
		end
	else
		data.trove:Clean()
	end

	-- replica --

	local replica = Replica.New({
		Token = PlayerReplicaToken,
		Data = {},
	})

	data.replica = replica
	data.trove:Add(replica)

	-- leaderstats --

	local function initStat(path: string, folder: Folder)
		local instance
		local intial_value = PathUtil.Navigate(data, path)
		local path_array = PathUtil.ToArray(path)

		if type(intial_value) == 'number' then
			instance = Instance.new('NumberValue')
		elseif type(intial_value) == 'string' then
			instance = Instance.new('StringValue')
		elseif type(intial_value) == 'boolean' then
			instance = Instance.new('BoolValue')
		else
			error(`invalid type for stat {path}`, 2)
		end

		instance.Name = path_array[#path_array]
		instance.Value = intial_value
		instance.Parent = folder

		data:SetValue(path, intial_value)
		data:ListenToChange(path, function(new_value, old_value) 
			instance.Value = new_value
		end)

		return instance
	end

	local leaderstats_folder = Instance.new('Folder')
	leaderstats_folder.Name = 'leaderstats'
	leaderstats_folder.Parent = player

	for stat_name, _ in profile.Data.leaderstats do
		initStat(`profile.Data.leaderstats.{stat_name}`, leaderstats_folder)
	end

	local privatestats_folder = Instance.new('Folder')
	privatestats_folder.Name = 'privatestats'
	privatestats_folder.Parent = player

	for stat_name, _ in profile.Data.privatestats do
		initStat(`profile.Data.privatestats.{stat_name}`, privatestats_folder)
	end

	-- 

	Service.PlayerDataLoaded:Fire(player, data)
	data.trove:Add(leaderstats_folder)
end

function Service:Release(player: Player)
	assert(typeof(player) == 'Instance' and player:IsA('Player'), 'argument #1 must be a player object, got', player)

	local player_data = PlayerProfiles[player]

	if not player_data then
		return
	end

	if player_data.profile.Data.properties.new then
		player_data.profile.Data.properties.new = false
	end

	if player_data then
		player_data.profile:EndSession()
	end
end

function Service:Get(player: Player, timeout: number?)
	assert(typeof(player) == 'Instance', 'argument #1 must be a player object, got', player)

	local start = os.clock()
	local data = PlayerProfiles[player]

	if not data and timeout then
		repeat
			task.wait()
			data = PlayerProfiles[player]
		until data or os.clock() - start >= timeout
	end

	return data
end

function Service:Start()
	for _, player in Players:GetPlayers() do
		Service:Load(player)
	end

	Players.PlayerAdded:Connect(function(...) Service:Load(...) end)
	Players.PlayerRemoving:Connect(function(...) Service:Release(...) end)

	Replica.NewReadyPlayer:Connect(function(player)
		Service:Get(player, 60).replica:Subscribe(player)
	end)
end

function Service:Init()
		
end

return Service