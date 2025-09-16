local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Tool = script.Parent

local Remote = Tool:WaitForChild("MouseLoc")

local camera = workspace.CurrentCamera
local mouse = game.Players.LocalPlayer:GetMouse()

local ignored = {Players.LocalPlayer.Character}

local function addIgnored(child)
	if child:HasTag('RocketIgnore') then
		table.insert(ignored, child)
	elseif (child:IsA('BasePart')) and (child.Transparency == 1) and (not child:HasTag('BridgeBlock')) then
		table.insert(ignored, child)
	end
end

for _, instance in CollectionService:GetTagged("RocketIgnore") do addIgnored(instance) end
for _, child in workspace.Map:GetDescendants() do addIgnored(child) end

local params = RaycastParams.new()
params.FilterDescendantsInstances = ignored
params.FilterType = Enum.RaycastFilterType.Exclude

workspace.Map.DescendantAdded:Connect(function(child)
	addIgnored(child)
	params.FilterDescendantsInstances = ignored
end)

CollectionService:GetInstanceAddedSignal("RocketIgnore"):Connect(function(child)
	addIgnored(child)
	params.FilterDescendantsInstances = ignored
end)

CollectionService:GetInstanceRemovedSignal("RocketIgnore"):Connect(function(child)
	if table.find(ignored, child) then
		table.remove(ignored, table.find(ignored, child))
		params.FilterDescendantsInstances = ignored
	end
end)

function Remote.OnClientInvoke()
	local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, params)

	if result then
		return result.Position
	else
		return unitRay.Origin + unitRay.Direction * 500
	end
end