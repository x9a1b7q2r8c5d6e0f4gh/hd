require(game:GetService("ReplicatedStorage").Shared.Framework)(script.Core):andThen(function(delta: number)
	print(`client loaded in {math.floor(delta * 1000) / 1000}s`)
end)