--[[
    The key represents goal the plot needs to reach to progress to the next difficulty
]]

export type Difficulty = {
    name: string,
    customers: {string},
    config: {
        max_orders: number,
        max_quantity: number,
    }
}

local List = {}

function List:Get(orders: number) : Difficulty
    local closestDifficulty = nil
    local closestDistance = math.huge

    for max, difficulty in List.Content do
        local distance = math.abs(orders - max)
        if distance < closestDistance then
            closestDistance = distance
            closestDifficulty = difficulty
        end
    end

    return closestDifficulty or List.Content[50]
end

List.Content = {
    [20] = {
        name = 'Easy',
        customers = {'Civilian'},
        config = {
            max_orders = 1,
            max_quantity = 1,
        }
    },
    [30] = {
        name = 'Medium',
        customers = {'Rich', 'Delivery'},
        config = {
            max_orders = 2,
            max_quantity = 2,
        }
    },
    [40] = {
        name = 'Hard',
        customers = {'Rich', 'Delivery'},
        config = {
            max_orders = 3,
            max_quantity = 3,
        }
    },
    [50] = {
        name = 'Very Hard',
        customers = {'Rich', 'Delivery'},
        config = {
            max_orders = 3,
            max_quantity = 5,
        }
    }
}

return List