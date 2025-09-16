local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Comm = require(ReplicatedStorage.Packages.Comm)

local methods = {}
methods.__index = methods

local function getComm(self)
	local comm 

	if self._comm then
		comm = self._comm
	else
		comm = Comm.ServerComm.new(ReplicatedStorage:WaitForChild('Container'), self.Name)
		self._comm = comm
	end
	
	return comm
end

function methods:Log(callback, message, ...)
	callback(`[{self.Name}]: {message}`, ...)
end

function methods:CreateSignal(name: string, unreliable: boolean?)
	local comm = getComm(self)
	return comm:CreateSignal(name, unreliable)
end

function methods:BindFunction(name: string, callback: (Player, ...any) -> ())
	local comm = getComm(self)
	return comm:BindFunction(name, callback)
end

return methods