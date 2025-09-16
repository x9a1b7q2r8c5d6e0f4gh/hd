local Players = game:GetService( 'Players' )
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Trove = require(ReplicatedStorage.Packages.Trove)
local Config = require(ReplicatedStorage.Shared.Config)

--

local module = {}


function module.construct( settings )
    local object = {}
    
    object.settings = ( typeof(settings) == 'table' and settings ) or {}
    object.funcs = {}

    object.trove = Trove.new()

    --[[
        all functions are networked, non-networked functions must start with _.
        in case of any arguments to send to client, return desired arguments
    ]]

    local function toggle(player: Player, enabled: boolean)
        local hum = player.Character and player.Character:FindFirstChild('Humanoid')
        if not hum then return end
        
        hum.WalkSpeed = enabled and hum.WalkSpeed / ( settings.modifier or 2 ) or hum.WalkSpeed * ( settings.modifier or 2 )
    end

    object.funcs.Slow = function( player: Player )
        toggle(player, true)

        object.trove:Connect(player.CharacterAdded, function()
            task.defer(toggle, player, true)
        end)

        object.trove:Add(function()
            toggle(player, false)
        end)

        return true, player
    end

    function object:Run()
        for _, v in Players:GetPlayers() do
            if v == settings.player then warn(`Skipping {v.Name} because they are the initiating player`) continue end
            object.funcs.Slow( v )
        end

        task.wait(Config.Game.PowerupDuration)
        object:Destroy()
    end

    --[[
        you can define a custom destroy function to override the default destroy function
    ]]
    function object:Destroy()
        object.trove:Destroy()
    end

    --

    return object
end

return module