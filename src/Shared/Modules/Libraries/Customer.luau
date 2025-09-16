local Names = require(script.Parent.Names)

export type CustomerConfig = {
    name: string, -- an array of names
    chance: number, -- the chance to spawn (0-100)
    patience: {min: number, max: number}, -- an array with the minimum and maximum patience in seconds
    reward: number -- reward multiplier
}

return {
    ['Civilian'] = {
        name = Names.Civilian,
        weight = 70,
        patience = {30, 60},
        reward = 1
    },
    ['Delivery'] = {
        name = Names.Civilian,
        weight = 20,
        patience = {10, 20},
        reward = 2
    },
    ['Rich'] = {
        name = Names.Rich,
        weight = 10,
        patience = {15, 30},
        reward = 3
    },
}