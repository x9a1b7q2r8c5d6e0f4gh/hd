local Players = game:GetService( 'Players' )

--[[
    powerup format is the same for both client and server, so you can just copy and paste the powerup folder to the client
    --
    object:Destroy() is called automatically on clients whenever server calls it
    --
    creating a powerup class on the client is optional in case you don't want to use the powerup on the client
]]--

local module = {}

function module.construct( settings )
    local object = {}
    
    object.settings = ( typeof(settings) == 'table' and settings ) or {}
    object.funcs = {}

    --[[
        all functions are networked, non-networked functions must start with _.
        in case of any arguments to send to client, return desired arguments

        at the moment, the communication is one-way, meaning you can only call these functions to client but not vice versa
    ]]--

    object.funcs.Test = function()
        return { "Test" }, "Test"
    end

    object.funcs._Test = function()
        print("I am not networked, meaning this function will not be called on the client")
    end

    function object:Run()
        object.funcs.Test() -- will also be called on client if it exists

        task.wait(1)
        object:Destroy() -- when done, clean up the powerup using Destroy()
    end

    --[[
        you can define a custom destroy function to override the default destroy function
        powerup is automatically cleaned up after Destroy is called
    ]]--
    function object:Destroy()
        warn( 'server: destroyed' )
    end

    --

    return object
end

return module