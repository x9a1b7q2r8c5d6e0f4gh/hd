local Players = game:GetService( 'Players' )
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

--

local LoopService = require(ServerScriptService.Server.Core.Loop)
local Bases = LoopService.Bases

local module = {}


function module.construct( settings )
    local object = {}
    
    object.settings = ( typeof(settings) == 'table' and settings ) or {}
    object.funcs = {}

    --[[
        all functions are networked, non-networked functions must start with _.
        in case of any arguments to send to client, return desired arguments
    ]]

    function object:Run()
        if typeof(Bases) == 'table' then
            for _, base in Bases do
                if settings.player.Team == base.team then continue end
                for _, bridge in base.bridges do
                    bridge:Clear()
                end
            end 
        end

        object:Destroy()
    end

    --[[
        you can define a custom destroy function to override the default destroy function
    ]]
    function object:Destroy()
    end

    --

    return object
end

return module