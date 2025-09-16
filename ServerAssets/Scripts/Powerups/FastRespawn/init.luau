local Players = game:GetService( 'Players' )
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local Config = require(ReplicatedStorage.Shared.Config)
local Trove = require(ReplicatedStorage.Packages.Trove)

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

    local function toggle(player: Player, enabled: boolean)
        local hum = player.Character and player.Character:FindFirstChild('Humanoid')
        if not hum then return end

        object.trove:Connect(hum.Died, function()
            task.wait(1)
            player:LoadCharacter()
        end)
    end

    object.funcs.FastRespawn = function( player: Player )
        toggle( player, true )

        object.trove:Connect(player.CharacterAdded, function()
            toggle( player, true )
        end)

        return true, player
    end

    function object:Run()
        if typeof(Bases) == 'table' then
            for _, base in Bases do
                if LoopService:GetPlayerBase(settings.player) ~= base then continue end
                for player, _ in base.players do
                    object.funcs.FastRespawn( player )
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