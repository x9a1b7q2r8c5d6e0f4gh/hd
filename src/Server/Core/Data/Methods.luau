local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local PathUtil = require(ReplicatedStorage.Packages.PathUtil)

local Methods = {}
Methods.__index = Methods

Methods.Navigate = PathUtil.Navigate

function Methods:SetValue(path: string, new_value: any)
	local path_array = PathUtil.ToArray(`{path}`)
	
	local current = self
	local old_value
	
	for i = 1, #path_array - 1 do
		current = current[path_array[i]]
	end
	
	old_value = current[path_array[#path_array]]
	current[path_array[#path_array]] = new_value
	
	self.Changed:Fire(path, new_value, old_value)
end

function Methods:GetValue(path: string)
	local path_array = PathUtil.ToArray(`{path}`)

	local current = self
	local old_value

	for i = 1, #path_array - 1 do
		current = current[path_array[i]]
	end

	old_value = current[path_array[#path_array]]
	
	return old_value
end

function Methods:InsertValue(path: string, value: any) -- meant for tables
	local path_array = PathUtil.ToArray(`{path}`)

	local current = self
	local old_value

	for i = 1, #path_array - 1 do
		current = current[path_array[i]]
	end
	
	local array = current[path_array[#path_array]]
	array[#array + 1] = value
	
	
	self.Inserted:Fire(path, value)
end

function Methods:ListenToChange(path: string, callback: (new_value: any, old_value: any) -> ()): Signal.Signal
	return self.Changed:Connect(function(p: string, ...)
		if p == path then
			callback(...)
		end
	end)
end

function Methods:ListenToInsertion(path: string, callback: (inserted_value: any) -> ())
	return self.Inserted:Connect(function(p: string, ...)
		if p == path then
			callback(...)
		end
	end)
end

return Methods
