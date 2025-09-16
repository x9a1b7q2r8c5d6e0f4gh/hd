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

    -- TODO: make these work only for team players, lightwork but too lazy rn :^)

    local function toggle(player: Player, enabled: boolean)
        local hum = player.Character
        if not hum then return end
        
        if enabled then
            Instance.new( 'ForceField' ).Parent = hum
        else
            for _, v in hum:GetChildren() do
                if v:IsA( 'ForceField' ) then
                    v:Destroy()
                end
            end
        end
    end

    object.funcs.God = function( player: Player )
        print(player)
        toggle( player, true )

        object.trove:Connect(player.CharacterAdded, function()
            toggle( player, true )
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
                    object.funcs.God( player )
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