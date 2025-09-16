-- dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Controller = setmetatable({ Name = script.Name }, require(ReplicatedStorage.Shared.Framework.Client))

-- private

-- methods

function Controller:Init()
   
end

function Controller:Start()
    local function recur(container: Folder?)
        for _, component in container:GetChildren() do
            if component:IsA('ModuleScript') then
                if component:GetAttribute('Disabled') then continue end
                if component:IsA('Folder') then 
                    recur(component)
                    continue
                else
                    require(component)
                end
            end
         end
    end
    
    recur(script)
    script.ChildAdded:Connect(recur)
    
    return {}
    
end

return Controller

