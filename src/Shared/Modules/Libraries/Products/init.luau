local List = {}

List.Content = {
	Gamepass = require(script.Gamepass),
	DevProduct = require(script.DevProduct)
}

--[[
	Returns the ProductInfo, ProductCategory and the parent ProductId if it is a gift
]]
function List:Get(product_id: number)
	local function iter(content)
		for id, info in content do
			if id == product_id then
				return info, false
			elseif info.gift == product_id then
				return info, id
			end
		end
	end

	for _, category in List.Content do
		local item, is_gift = iter(category.Content)

		if item then
			return item, category, is_gift
		end
	end
end

function List:GetByName(product_name: string)
	local function iter(content)
		for id, info in content do
			if info.name == product_name then
				return info, id
			end
		end
	end

	for _, category in List.Content do
		local item, id = iter(category.Content)

		if item then
			return item, id, category
		end
	end
	
	warn(debug.traceback(`failed finding product "{product_name}"`))
end

return List