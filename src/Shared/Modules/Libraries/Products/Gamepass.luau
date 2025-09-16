local List = {}

List.Name = script.Name
List.InfoType = Enum.InfoType.GamePass

--[[

[0] = {
		['name'] = '',
		['sort'] = 1,
		['gift'] = 0, -- Developer Product
		['description'] = 'l',
		['properties'] = {
			['economy'] = {
				rewards = {
					reward = { {name = 'Coins', arguments = {100}} },
					recurring_reward = { {name = 'Coins', arguments = {100}} }
				},
				purchasable = true, giftable = true, category = 'Robux
			}
		}
	},

]]

List.Content = {
	[1409916979] = {
		['name'] = '30 Blocks',
		['sort'] = 1,
		['properties'] = {
			['economy'] = {
				reward = {name = 'Item', arguments = { { id = 10, category = 'Blocks' } }},
				--recurring_reward = { }
				purchasable = true, giftable = false, category = nil,
			}
		}
	},
	[1409437597] = {
		['name'] = '40 Speed',
		['sort'] = 1,
		['properties'] = {
			['economy'] = {
				reward = {name = 'Item', arguments = { { id = 10, category = 'Speed' } }},
				--recurring_reward = { }
				purchasable = true, giftable = false, category = nil,
			}
		}
	},
	[1417512924] = {
		['name'] = 'Bombardiro Crocodilo',
		['sort'] = 1,
		['properties'] = {
			['economy'] = {
				reward = {name = 'Item', arguments = { { id = 7, category = 'RocketLauncher' } }},
				--recurring_reward = { }
				purchasable = true, giftable = false, category = nil,
			}
		}
	},
	[1434873689] = {
		['name'] = 'Starter Pack',
		['sort'] = 1,
		['properties'] = {
			['economy'] = {
				reward = {name = 'Rewards', arguments = {{
					{name = 'Item', arguments = {{id = 2, category = 'RocketLauncher'}}},
					{name = 'Cash', arguments = {100}},
				}}},
				purchasable = true, giftable = false, category = nil, sale = 79,
			}
		}
	},
}

return List