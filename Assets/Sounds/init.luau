local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tree = require(ReplicatedStorage.Packages.Tree)

return {
	Miscellaneous = require(script.Miscellaneous),
	Mobs = require(script.Mobs),
	Music = require(script.Music),

	playSound = function(id, props, ref: Sound?)
		local new_sound = ref and ref:Clone() or Instance.new("Sound")
		
		if not ref then
			new_sound.SoundId = id
		end

		if props then
			for property_key, property_value in props do
				if new_sound[property_key] and typeof(new_sound[property_key]) ~= "Instance" then
					new_sound[property_key] = property_value
				end
			end
		end

		new_sound.Parent = props.Parent or workspace
		new_sound:Play()
		new_sound.Ended:Connect(function()
			new_sound:Destroy()
		end)

		return new_sound
	end,
}
