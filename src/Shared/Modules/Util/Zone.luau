--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Zone = {}
Zone.__index = Zone

export type Zone = typeof(Zone)
export type ZoneParams = {
	IgnoreNonPlayerCharacters: boolean,
	
	FilterPartNames: boolean,
	FilteredPartNames: {string}
}

function Zone.new(part: BasePart, params: ZoneParams)
	assert(typeof(part) == 'Instance' and part:IsA('BasePart'), 'argument #1 must be a BasePart representing the zone')
	
	local self = setmetatable({}, Zone)
	
	self.trove = Trove.new()
	self.params = params
	self.characters = {}
	
	self.Entered = Signal.new()
	self.Exited = Signal.new()
	
	----------------------
	
	self.trove:AttachToInstance(part)
	self.trove:Add(function() 
		self.Entered:Destroy() 
		self.Exited:Destroy() 
	end)
	
	----------------------
	
	self.trove:Connect(part.Touched, function(otherPart: BasePart)
		if otherPart.Name ~= 'HumanoidRootPart' then return end
	
		for _, player in Players:GetPlayers() do
			if otherPart:IsDescendantOf(player.Character) then
				self:_onCharacterEntered(player.Character)
			end
		end
	end)
	
	self.trove:Connect(part.TouchEnded, function(otherPart: BasePart) 
		if otherPart.Name ~= 'HumanoidRootPart' then return end
		
		for _, player in Players:GetPlayers() do
			if otherPart:IsDescendantOf(player.Character) then
				self:_onCharacterExited(player.Character)
			end
		end
	end)
	
	return table.freeze(self)
end

function Zone:_onCharacterEntered(character: Model)
	if not character or character.Parent == nil then return end
	if self.characters[character] then return end
	
	local data = {
		['trove'] = self.trove:Extend()
	}
	
	data.trove:Connect(character.Changed, function(prop)
		if prop == 'Parent' and character.Parent == nil then
			data.trove:Destroy()
		end
	end)
	
	data.trove:Add(function()
		self.characters[character] = nil
		self.Exited:Fire(character)
	end)

	self.characters[character] = data
	self.Entered:Fire(character)
end

function Zone:_onCharacterExited(character: Model)
	local data = self.characters[character]
	if not data then return end

	data.trove:Destroy()
end

function Zone:GetTouchingCharacters()
	return table.clone(self.characters)
end

function Zone:Destroy()
	return self.trove:Destroy()
end

return Zone