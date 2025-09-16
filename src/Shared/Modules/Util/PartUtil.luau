local Part = {}

function Part.SetDescendantProperty(ancestor: Instance, class: string, property: string, value: any)
	local descendants = ancestor:GetDescendants()
	table.insert(descendants, ancestor)
	
	for _, v in descendants do
		if v:IsA(class) then
			v[property] = value
		end
	end
end

return Part