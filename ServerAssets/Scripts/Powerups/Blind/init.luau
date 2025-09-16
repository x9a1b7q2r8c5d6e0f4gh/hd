local Players = game:GetService( 'Players' )
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Config = require(ReplicatedStorage.Shared.Config)

--

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
        print('Clientside effect')
        task.wait(Config.Game.PowerupDuration) -- could derive from settings :^)
        object:Destroy()
    end

    --[[
        you can define a custom destroy function to override the default destroy function
    ]]
    function object:Destroy()
        warn( 'server: destroyed' )
    end

    --

    return object
end

return module