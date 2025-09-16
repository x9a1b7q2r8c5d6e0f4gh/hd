local List = {}

List.Name = script.Name
List.InfoType = Enum.InfoType.Product

--[[

[0] = {
		['name'] = 'Test',
		['sort'] = 0,
		['image'] = '',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Coins', arguments = {100}},
				purchasable = true, giftable = false, category = nil,
			}
		},
	},

]]

List.Content = {
	-- [3374928353] = {
	-- 	['name'] = 'Bombardiro Crocodilo',
	-- 	['properties'] = {
	-- 		['economy'] = {
	-- 			reward = {name = 'Item', arguments = {{id = 7, category = 'RocketLauncher'}}},
	-- 			purchasable = true, giftable = false,
	-- 		}
	-- 	},
	-- },

	[3376036916] = {
		['name'] = 'Kill Others',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Powerup', arguments = {'KillAll'}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3377730954] = {
		['name'] = 'Blind',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Powerup', arguments = {'Blind'}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3377730851] = {
		['name'] = 'Fling',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Powerup', arguments = {'Fling'}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3377731076] = {
		['name'] = 'Fast Respawn',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Powerup', arguments = {'FastRespawn'}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3377731149] = {
		['name'] = 'God Mode',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Powerup', arguments = {'God'}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3377731253] = {
		['name'] = '2x Speed',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Powerup', arguments = {'Speed'}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3377731319] = {
		['name'] = 'Slow Others',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Powerup', arguments = {'Slow'}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3377731430] = {
		['name'] = 'Destroy Bridges',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Powerup', arguments = {'DestroyBase'}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3376836321] = {
		['name'] = '10 Blocks',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Blocks', arguments = {10}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3376836215] = {
		['name'] = '25 Blocks',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Blocks', arguments = {25}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3376836105] = {
		['name'] = '50 Blocks',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Blocks', arguments = {50}},
				purchasable = true, giftable = false,
			}
		},
	},

	[3376836404] = {
		['name'] = '100 Blocks',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Blocks', arguments = {100}},
				purchasable = true, giftable = false,
			}
		},
	},

	-- cash

	[3377459122] = {
		['name'] = '+$50',
		['category'] = 'Cash',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Cash', arguments = {50}},
				purchasable = true, giftable = false,
			}
		},
	},
	[3377459301] = {
		['name'] = '+$100',
		['category'] = 'Cash',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Cash', arguments = {100}},
				purchasable = true, giftable = false,
			}
		},
	},
	[3377459418] = {
		['name'] = '+$250',
		['category'] = 'Cash',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Cash', arguments = {250}},
				purchasable = true, giftable = false,
			}
		},
	},
	[3377459542] = {
		['name'] = '+$500',
		['category'] = 'Cash',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Cash', arguments = {500}},
				purchasable = true, giftable = false,
			}
		},
	},
	[3377459668] = {
		['name'] = '+$1000',
		['category'] = 'Cash',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Cash', arguments = {1000}},
				purchasable = true, giftable = false,
			}
		},
	},
	[3377459757] = {
		['name'] = '+$5000',
		['category'] = 'Cash',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Cash', arguments = {5000}},
				purchasable = true, giftable = false,
			}
		},
	},
	[3378415300] = {
		['name'] = 'Revenge',
		['properties'] = {
			['economy'] = {
				reward = {name = 'Powerup', arguments = {'Revenge'}},
				purchasable = true, giftable = false,
			}
		},
	},
}

return List 