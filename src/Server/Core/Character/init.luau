-- dependencies

local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Component = require(ReplicatedStorage.Packages.Component)
local Remo = require(ReplicatedStorage.Packages.Remo)

local Service = setmetatable({ Name = script.Name }, require(ReplicatedStorage.Shared.Framework.Server))

-- private

local DataService

-- methods

function Service:Teleport(player: Player, position: Vector3)
	local character = player.Character
	if not character then return end
	
	player.Position.Value = position
	character:PivotTo(CFrame.new(position))
end

local function onPlayerAdded(player: Player)
	local function onCharacterAppearanceLoaded(character: Model) end

	local function onCharacterAdded(character: Model)
		character:AddTag("Character")
	end

	if player.Character then
		onCharacterAdded(player.Character)
	end

	player.CharacterAppearanceLoaded:Connect(onCharacterAppearanceLoaded)
	player.CharacterAdded:Connect(onCharacterAdded)
end

function Service:Init()
	DataService = require(script.Parent.Data)
end

function Service:Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
end

return Service
