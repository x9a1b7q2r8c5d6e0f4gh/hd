local Math = {}

function Math.getWeightedRandom(pool: {[any]: number})
	local totalWeight = 0

	for _, weight in pool do
		totalWeight += weight
	end

	local randomValue = math.random() * totalWeight
	local currentWeight = 0

	for key, weight in pool do
		currentWeight += weight
		if randomValue <= currentWeight then
			return key
		end
	end
end

return Math