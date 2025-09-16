local Players = game:GetService( 'Players' )
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local Trove = require(ReplicatedStorage.Packages.Trove)
local Config = require(ReplicatedStorage.Shared.Config)

--

local LoopService = require(ServerScriptService.Server.Core.Loop)
local Bases = LoopService.Bases

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

    -- TODO: make these work only for team players, lightwork but too lazy rn :^)

    local function toggle(player: Player, enabled: boolean)
        local hum = player.Character and player.Character:FindFirstChild('Humanoid')
        if not hum then return end
        
        hum.WalkSpeed = enabled and hum.WalkSpeed * ( settings.modifier or 2 ) or hum.WalkSpeed / ( settings.modifier or 2 )
    end

    object.funcs.Fast = function( player: Player )
        toggle( player, true )

        object.trove:Connect(player.CharacterAdded, function()
            task.defer( toggle, player, true )
        end)

        object.trove:Add(function()
            toggle( player, false )
        end)

        return true, player
    end

    function object:Run()
        if typeof(Bases) == 'table' then
            for _, base in Bases do
                if LoopService:GetPlayerBase(settings.player) ~= base then continue end
                for player, _ in base.players do
                    object.funcs.Fast( player )
                end
            end 
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