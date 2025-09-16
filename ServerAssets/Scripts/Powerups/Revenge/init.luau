local Players = game:GetService( 'Players' )
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Config = require(ReplicatedStorage.Shared.Config)

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

    object.trove = Trove.new()

    --[[
        all functions are networked, non-networked functions must start with _.
        in case of any arguments to send to client, return desired arguments

        at the moment, the communication is one-way, meaning you can only call these functions to client but not vice versa
    ]]--

    object.funcs.Explode = function( player )
        local character = player.Character
        
        object.trove:Connect(character.Humanoid.Died, function()
            object:Destroy()
        end)

        object.trove:Connect(character:GetPropertyChangedSignal("Parent"), function()
            if character.Parent == nil then
                object:Destroy()
            end
        end)

        object.trove:Add(task.delay(5, function()
            Instance.new("Explosion", character).Position = character:GetPivot().Position
        end))

        return player
    end

    object.funcs._Test = function()
        print("I am not networked, meaning this function will not be called on the client")
    end

    function object:Run()
        if settings.player._LastTaggedBy.Value and settings.player._LastTaggedBy.Value.Character then
            object.funcs.Explode( settings.player._LastTaggedBy.Value )
            settings.player._LastTaggedBy.Value = nil
        end

        task.wait(Config.Game.PowerupDuration)
        object:Destroy() -- when done, clean up the powerup using Destroy()
    end

    --[[
        you can define a custom destroy function to override the default destroy function
        powerup is automatically cleaned up after Destroy is called
    ]]--
    function object:Destroy()
        warn( 'server: destroyed' )
        object.trove:Destroy()
    end

    --

    return object
end

return module