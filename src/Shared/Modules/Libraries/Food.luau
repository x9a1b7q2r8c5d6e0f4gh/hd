local Names = require(script.Parent.Names)

export type FoodConfig = {
    name: string, -- an array of names
}

return {
    [1] = {
        name = "Burger",
        price = 5,
    },
}