-- dependencies

local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Service = setmetatable({Name = script.Name}, require(ReplicatedStorage.Shared.Framework.Server))

-- private

local ORIGIN = Vector3.new(0, 50, 0) -- origin of the world
local SEED = math.random(1, 100000) -- random seed for noise
local SLOPE_FACTOR = 0.3 -- how much the height changes based on distance from center

local TILE_COUNT = 50 -- how many tiles to generate (50x50)
local TILE_SIZE = 75 -- size of each tile
local HEIGHT_SCALE = 200 -- how much the height changes based on noise

local Scope = Trove.new()
local Chunk = require(script.Chunk)

local frequency = 0.05 -- current frequency of the noise

-- methods

function Service:Generate()
    Scope:Clean()

    local cells = {}

    local function getHeight(x, y, seed: number, distance: number) -- get the height of the tile using noise and distance from center
        local noiseHeight = math.noise(x * frequency, y * frequency, seed / 1000) * HEIGHT_SCALE
        local distanceHeight = distance * SLOPE_FACTOR -- how much the height changes based on distance from center
        return noiseHeight + distanceHeight
    end

    local function getChunk(): Model
        local pool = ReplicatedStorage.Shared.Assets:WaitForChild("Chunks"):GetChildren() -- get a random chunk from the pool
        return pool[math.random(1, #pool)]:Clone()
    end

    local function getDebris()
        if math.random(1, 3) ~= 1 then return end -- 33% chance to get debris

        local pool = ReplicatedStorage.Shared.Assets:WaitForChild("Debris"):GetChildren() -- get a random debrsi from the pool
        return pool[math.random(1, #pool)]:Clone()
    end

    local halfCount = math.floor(TILE_COUNT / 2) -- half of the tile count so i can start from the center

    -- gen tiles by distance from center
    local tiles = {}
    for gx = -halfCount, halfCount do
        for gy = -halfCount, halfCount do
            local distance = math.abs(gx) + math.abs(gy) 
            table.insert(tiles, {gx, gy, distance})
        end
    end

    -- sort by distance from center
    table.sort(tiles, function(a, b) return a[3] < b[3] end)

    -- gen tiles in order
    for _, tileData in tiles do
        local gx, gy = tileData[1], tileData[2]
        local tile = getChunk()
        local index = `{gx},{gy}`

        local x = gx * TILE_SIZE
        local z = gy * TILE_SIZE
        local distance = Vector3.new(x, 0, z).Magnitude
        local height = getHeight(gx, gy, SEED, distance)
        local position = ORIGIN + Vector3.new(x, height, z)

        tile.Name = index
        tile.Parent = workspace
        tile:PivotTo(CFrame.new(position))

        -- extend the bottom part of the tile based on the height
        local bottom = tile:FindFirstChild("Bottom")
        if bottom then
            local currentSize = bottom.Size
            local extendAmount = math.abs(height) -- extend based on the height value
      
            -- Extend the bottom part downward
            bottom.Size = Vector3.new(currentSize.X, currentSize.Y + extendAmount, currentSize.Z)

            -- Adjust position so the bottom extends downward from the attachment point
            local offset = Vector3.new(0, -extendAmount / 2, 0)
            bottom.CFrame = bottom.CFrame + offset
        end

        cells[index] = tile
        Scope:Add(tile)
        frequency = frequency + 0.00001 -- increase the frequency of the noise so it gets more intense the further away from the center

        local debris = getDebris() do
            if debris then
                local radius = TILE_SIZE / 2
                local x, z = math.random(-radius, radius), math.random(-radius, radius)
                local position: Vector3 = tile.Top.Attachment.WorldPosition + Vector3.new(x, 0, z)

                debris:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.random(0, 360), 0)) -- random angle for natural look
                debris.Parent = tile
            end
        end

        task.wait()
    end

    print(#cells)
end

function Service:Init()
	
end

function Service:Start()
    self:Generate() -- regenerate the world
end

return Service
