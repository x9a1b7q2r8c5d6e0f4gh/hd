export type Reward = {
	name: string,
	arguments: {},
}

local rewards: { [string]: (player: Player, ...any) -> () } = {}

for _, module in script:GetChildren() do
	if module:IsA('ModuleScript') then
		rewards[module.Name] = require(module)
	end
end

return rewards