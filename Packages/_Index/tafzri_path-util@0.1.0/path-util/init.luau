--[[
	Path Module
	A utility module for handling path operations in Roblox, supporting both string paths
	(e.g. "Parent.Child.GrandChild") and array paths (e.g. {"Parent", "Child", "GrandChild"}).
	Useful for navigating through Instance hierarchies and table structures.
]]

local Path = {}

--[[
	Converts a dot-separated path string into an array of path segments.
	
	@param path string - The dot-separated path string (e.g. "Parent.Child.GrandChild")
	@return {string} - Array of path segments
]]
function Path.ToArray(path: string)
	local path_array = {}

	if path ~= "" then
		for s in string.gmatch(path, "[^%.]+") do
			table.insert(path_array, s)
		end
	end

	return path_array
end

--[[
	Converts an array of path segments into a dot-separated string.
	
	@param path {string} - Array of path segments
	@return string - Dot-separated path string
]]
function Path.ToString(path: {string})
	local str = ''
	
	for i, v in path do
		str = `str.{v}`
	end
	
	return str
end

--[[
	Navigates through a pointer (Instance or table) using the provided path.
	For Instances, uses WaitForChild to handle async loading.
	For tables, uses direct indexing.
	
	@param pointer any - The starting point (Instance or table) to navigate from
	@param path string|{string} - Path to navigate, either as string or array
	@return any - The value found at the end of the path
]]
function Path.Navigate(pointer: any, path: string | {})
	local path_array

	if type(path) == 'table' then
		path_array = path
	elseif type(path) == 'string' then
		path_array = Path.ToArray(path)
	end

	local i = pointer

	for _, dir in path_array do
		i = (typeof(pointer) == 'Instance' and i:WaitForChild(dir)) or i[dir]
	end

	return i
end

--[[
	Searches through all descendants of an Instance to find the first one of a specific class.
	
	@param ancestor Instance - The root Instance to search from
	@param class string - The class name to search for
	@return Instance? - The first descendant found of the specified class, or nil if none found
]]
function Path.FindFirstDescendantOfClass(ancestor: Instance, class: string): Instance?
	for _, descendant in ancestor:GetDescendants() do
		if descendant:IsA(class) then
			return descendant
		end
	end
end

return Path