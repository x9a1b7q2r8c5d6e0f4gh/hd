local module = {}

function module:EmitDescendants(instance: Instance)
	for _, v in instance:GetDescendants() do
		if v:IsA('ParticleEmitter') then
			local duration = v:GetAttribute('EmitDuration')
			local delay = v:GetAttribute('EmitDelay')
			local count = v:GetAttribute('EmitCount')
			
			if duration and (typeof(duration) == 'number' and duration > 0) then
				v.Enabled = true
				task.delay(duration, function() v.Enabled = false end)
			end
			
			task.delay(delay or 0, function()
				v:Emit(count or 1)
			end)
		end
	end
end




return module