local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Comm = require(ReplicatedStorage.Packages.Comm)

local methods = {}
methods.__index = methods

function methods:Log(callback, message, ...)
	callback(`[{self.Name}]: {message}`, ...)
end

function methods:GetService(name: string?)
	local name = name or self.Name
	return Comm.ClientComm.new(ReplicatedStorage:WaitForChild('Container'), true, name):BuildObject()
end

return methods