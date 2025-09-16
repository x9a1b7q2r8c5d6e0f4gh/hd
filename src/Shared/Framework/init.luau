local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Comm = require(ReplicatedStorage.Packages.Comm)

local Context = RunService:IsServer() and 'Server' or 'Client'
local Filtered = {'example', 'base'}

local Container = ReplicatedStorage:FindFirstChild('Container') or Instance.new('Folder', ReplicatedStorage)
Container.Name = 'Container'

return function(container)
	return Promise.new(function(resolve, reject)
		local start = os.clock()
		local modules = {}

		for _, module: ModuleScript in container:GetDescendants() do
			if not module:IsA('ModuleScript') then continue end
			if module:FindFirstAncestorOfClass('ModuleScript') then continue end
			if module:GetAttribute('Disabled') then continue end
			if table.find(Filtered, module.Parent.Name:lower()) then continue end
			
			local success, err = pcall(function()		
				local required_module = require(module)

				if module:GetAttribute('type') == 'Component' then
					return
				end
				
				if not required_module.Init then return reject(`[{Context}]: missing :Init() function for "{module.Name}"`) end
				if not required_module.Start then return reject(`[{Context}]: missing :Start() function for "{module.Name}"`) end
				
				if Context == 'Server' then
					if not required_module._comm then
						required_module._comm = Comm.ServerComm.new(Container, module.Name)
					end
				end
				
				Promise.new(function(resolve, reject)
					resolve(required_module:Init())
				end):andThen(function()
					table.insert(modules, required_module)
				end):catch(warn)
			end)

			if not success then warn(module.Name, debug.traceback(err)) end
		end
		
		for _, module in modules do
			Promise.new(function(resolve, reject)
				resolve(module:Start())
			end):catch(warn)
		end

		resolve(os.clock() - start)
	end)
end