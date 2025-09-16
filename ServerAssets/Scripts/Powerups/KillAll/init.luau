local Players = game:GetService( 'Players' )

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
    object.funcs.Kill = function( player )
        if player.Character then player.Character:BreakJoints() end

        print( `{player.Name} has been killed!` )

        return player
    end

    function object:Run()
        for _, v in Players:GetPlayers() do
            if v == settings.player then warn(`Skipping {v.Name} because they are the initiating player`) continue end

            object.funcs.Kill( v )
        end

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