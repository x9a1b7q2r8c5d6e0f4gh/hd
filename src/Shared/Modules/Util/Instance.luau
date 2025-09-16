local Instance = {}

function Instance.getRandomChild(parent: Instance)
    local children = parent:GetChildren()
    return children[math.random(1, #children)]
end

return Instance