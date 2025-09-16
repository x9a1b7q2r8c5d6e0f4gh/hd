local Chunk = {}
Chunk.__index = Chunk

function Chunk.new(position, size)
    local self = setmetatable({}, Chunk)
   
    return self
end

return Chunk