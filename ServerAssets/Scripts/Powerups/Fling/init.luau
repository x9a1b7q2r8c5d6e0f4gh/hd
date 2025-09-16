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

    object.funcs.Fling = function( player: Player )
        local playerCharacter = player.Character
        local hrp = playerCharacter and playerCharacter.PrimaryPart
        if not hrp then return end

        local hum = playerCharacter and playerCharacter:FindFirstChild('Humanoid')

        local fling = Instance.new('BodyVelocity')
		fling.MaxForce = Vector3.new(100000, 100000, 100000)
			--fling.Velocity = Vector3.new(0, 0, 0)
		fling.Velocity = Vector3.new(math.random(0, 10000), math.random(0, 10000), math.random(0, 10000))
		fling.Parent = hrp

		if hum then
			hum.Sit = true
		end

        task.spawn(function()
            task.wait(0.1)
            fling:Destroy()
        end)

        return true, player
    end

    function object:Run()
        for _, v in Players:GetPlayers() do
            if v == settings.player then warn(`Skipping {v.Name} because they are the initiating player`) continue end
            object.funcs.Fling( v )
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