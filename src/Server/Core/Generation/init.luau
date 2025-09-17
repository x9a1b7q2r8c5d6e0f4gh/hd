-- lame ass mountain generation w biomes 

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

local TILE_COUNT = 100 -- how many tiles to generate (50x50)
local TILE_SIZE = 75 -- size of each tile
local HEIGHT_SCALE = 200 -- how much the height changes based on noise

local Scope = Trove.new()
local Chunk = require(script.Chunk)

local frequency = 0.05 -- current frequency of the noise

-- biome mappingz
local BIOMES = {
    DESERT = {
        name = "Desert",
        color = Color3.fromRGB(255, 200, 100),
        material = Enum.Material.Sand,
        minHeight = 0,
        maxHeight = 100,
        minDistance = 0,
        maxDistance = 10000
    },
    FOREST = {
        name = "Forest", 
        color = Color3.fromRGB(50, 150, 50),
        material = Enum.Material.Grass,
        minHeight = 100,
        maxHeight = 500,
        minDistance = 0,
        maxDistance = 10000
    },
    MOUNTAINS = {
        name = "Mountains",
        color = Color3.fromRGB(120, 120, 120),
        material = Enum.Material.Rock,
        minHeight = 500,
        maxHeight = 600,
        minDistance = 0,
        maxDistance = 10000
    },
    TUNDRA = {
        name = "Tundra",
        color = Color3.fromRGB(200, 220, 255),
        material = Enum.Material.Snow,
        minHeight = 600,
        maxHeight = 10000,
        minDistance = 0,
        maxDistance = 10000
    },
}

-- generates height variation using perlin noise
local function calculateNoiseHeight(x, y, seed, currentFrequency)
    local noiseX = x * currentFrequency
    local noiseY = y * currentFrequency
    local noiseSeed = seed / 1000
    local rawNoise = math.noise(noiseX, noiseY, noiseSeed)
    local scaledNoise = rawNoise * HEIGHT_SCALE
    return scaledNoise
end

-- makes terrain higher as you move away from center
local function calculateDistanceHeight(distance)
    local baseSlopeHeight = distance * SLOPE_FACTOR
    return baseSlopeHeight
end

-- combines noise and distance to get final tile height
local function getHeight(x, y, seed: number, distance: number)
    local noiseHeight = calculateNoiseHeight(x, y, seed, frequency)
    local distanceHeight = calculateDistanceHeight(distance)
    local totalHeight = noiseHeight + distanceHeight
    return totalHeight
end

-- grabs all assets of a specific type from assets
local function getAssetPool(assetType: string)
    local sharedAssets = ReplicatedStorage.Shared.Assets
    local assetFolder = sharedAssets:WaitForChild(assetType)
    local assetPool = assetFolder:GetChildren()
    return assetPool
end

-- picks a random asset from the pool and clones it
local function selectRandomAsset(pool)
    local poolSize = #pool
    local randomIndex = math.random(1, poolSize)
    local selectedAsset = pool[randomIndex]
    local clonedAsset = selectedAsset:Clone()
    return clonedAsset
end

-- gets a random terrain chunk for tile generation
local function getChunk(): Model
    local chunkPool = getAssetPool("Chunks")
    local selectedChunk = selectRandomAsset(chunkPool)
    return selectedChunk
end

-- 1 in 3 chance to spawn debris on a tile
local function shouldSpawnDebris()
    local debrisChance = 3
    local randomRoll = math.random(1, debrisChance)
    local shouldSpawn = randomRoll == 1
    return shouldSpawn
end

-- maybe spawns some random debris, maybe doesn't
local function getDebris()
    local canSpawnDebris = shouldSpawnDebris()
    if not canSpawnDebris then 
        return nil 
    end

    local debrisPool = getAssetPool("Debris")
    local selectedDebris = selectRandomAsset(debrisPool)
    return selectedDebris
end

-- checks if height fits within biome requirements
local function checkHeightRange(height, minHeight, maxHeight)
    local isAboveMin = height >= minHeight
    local isBelowMax = height <= maxHeight
    local isInRange = isAboveMin and isBelowMax
    return isInRange
end

-- checks if distance from center fits biome requirements
local function checkDistanceRange(distance, minDistance, maxDistance)
    local isAboveMin = distance >= minDistance
    local isBelowMax = distance <= maxDistance
    local isInRange = isAboveMin and isBelowMax
    return isInRange
end

-- figures out which biome this tile should be based on height and distance
local function getBiome(height, distance)
    for biomeName, biome in pairs(BIOMES) do
        local heightInRange = checkHeightRange(height, biome.minHeight, biome.maxHeight)
        local distanceInRange = checkDistanceRange(distance, biome.minDistance, biome.maxDistance)
        local biomeMatches = heightInRange and distanceInRange

        if biomeMatches then
            return biome
        end
    end
    return BIOMES.FOREST -- default biome
end

-- makes the tile look like its biome (color and material)
local function applyBiomeToTile(tile, biome)
    local topPart = tile.Top
    local biomeColor = biome.color
    local biomeMaterial = biome.material

    topPart.Color = biomeColor
    topPart.Material = biomeMaterial
end

-- calculates how far a tile is from the center
local function calculateTileDistance(gx, gy)
    local absoluteX = math.abs(gx)
    local absoluteY = math.abs(gy)
    local dist = absoluteX + absoluteY
    return dist
end

-- packages up tile coordinates with distance info
local function createTileData(gx, gy)
    local tileDistance = calculateTileDistance(gx, gy)
    local tileData = {gx, gy, tileDistance}
    return tileData
end

-- generates all the tile coordinates we need for the world
local function generateTileCoordinates()
    local halfCount = math.floor(TILE_COUNT / 2)
    local tiles = {}
    
    local startX = -halfCount
    local endX = halfCount
    local startY = -halfCount
    local endY = halfCount
    
    for gx = startX, endX do
        for gy = startY, endY do
            local tileData = createTileData(gx, gy)
            table.insert(tiles, tileData)
        end
    end
    
    return tiles
end

-- sorts tiles so we generate from center outward (looks cooler)
local function sortTilesByDistance(tiles)
    local function compareDistance(tileA, tileB)
        local distanceA = tileA[3]
        local distanceB = tileB[3]
        local isACloser = distanceA < distanceB
        return isACloser
    end
    
    table.sort(tiles, compareDistance)
    return tiles
end

-- converts grid coordinates to world position
local function calculateWorldPosition(gx, gy)
    local worldX = gx * TILE_SIZE
    local worldZ = gy * TILE_SIZE
    return worldX, worldZ
end

-- gets distance from center
local function getDistance(x, z)
    local positionVector = Vector3.new(x, 0, z)
    local distance3D = positionVector.Magnitude
    return distance3D
end

-- creates a unique index for each tile
local function createTileIndex(gx, gy)
    local indexString = `{gx},{gy}`
    return indexString
end

-- adds the height offset to world origin to get final position
local function calculateFinalPosition(x, height, z)
    local heightOffset = Vector3.new(x, height, z)
    local finalPosition = ORIGIN + heightOffset
    return finalPosition
end

-- stretches the bottom part down to fill gaps between tiles
local function extendBottomPart(tile, height)
    local bottomPart = tile:FindFirstChild("Bottom")
    local hasBottomPart = bottomPart ~= nil
    
    if not hasBottomPart then
        return
    end
    
    local currentSize = bottomPart.Size
    local currentSizeX = currentSize.X
    local currentSizeY = currentSize.Y
    local currentSizeZ = currentSize.Z
    
    local extendAmount = math.abs(height)
    local newSizeY = currentSizeY + extendAmount
    local newSize = Vector3.new(currentSizeX, newSizeY, currentSizeZ)
    
    bottomPart.Size = newSize
    
    local offsetAmount = -extendAmount / 2
    local offset = Vector3.new(0, offsetAmount, 0)
    local newCFrame = bottomPart.CFrame + offset
    bottomPart.CFrame = newCFrame
end

-- finds a random spot on the tile to place debris
local function getDebrisPosition(tile)
    local tileRadius = TILE_SIZE / 2
    local minOffset = -tileRadius
    local maxOffset = tileRadius
    
    local randomX = math.random(minOffset, maxOffset)
    local randomZ = math.random(minOffset, maxOffset)
    
    local tileTopAttachment = tile.Top.Attachment
    local tileTopPosition = tileTopAttachment.WorldPosition
    local positionOffset = Vector3.new(randomX, 0, randomZ)
    local finalDebrisPosition = tileTopPosition + positionOffset
    
    return finalDebrisPosition
end

-- gives debris a random rotation so it looks natural
local function getDebrisRotation()
    local minAngle = 0
    local maxAngle = 360
    local randomAngle = math.random(minAngle, maxAngle)
    local rotationCFrame = CFrame.Angles(0, randomAngle, 0)
    return rotationCFrame
end

-- puts the debris on the tile with random position and rotation
local function placeDebrisOnTile(tile, debris)
    local debrisPosition = getDebrisPosition(tile)
    local debrisRotation = getDebrisRotation()
    local finalDebrisCFrame = CFrame.new(debrisPosition) * debrisRotation
    
    debris:PivotTo(finalDebrisCFrame)
    debris.Parent = tile
end

-- main function that generates the entire world
function Service:Generate()
    Scope:Clean()

    local cells = {}
    local tiles = generateTileCoordinates()
    local sortedTiles = sortTilesByDistance(tiles)

    -- gen tiles in order
    for _, tileData in sortedTiles do
        local gx = tileData[1]
        local gy = tileData[2]
        local tile = getChunk()
        local index = createTileIndex(gx, gy)

        local x, z = calculateWorldPosition(gx, gy)
        local distance = getDistance(x, z)
        local height = getHeight(gx, gy, SEED, distance)
        local position = calculateFinalPosition(x, height, z)

        -- determine biome and apply it
        local biome = getBiome(height, distance)
        applyBiomeToTile(tile, biome)

        local tileName = `{index}_{biome.name}`
        tile.Name = tileName
        tile.Parent = workspace
        
        local tileCFrame = CFrame.new(position)
        tile:PivotTo(tileCFrame)

        extendBottomPart(tile, height) -- stretch the bottom part down to fill gaps between tiles

        cells[index] = tile
        Scope:Add(tile)
        frequency = frequency + 0.00001 -- slowly change noise frequency to add variation over time

        local debris = getDebris()
        local hasDebris = debris ~= nil
        if hasDebris then
            placeDebrisOnTile(tile, debris)
        end

        local biomeName = biome.name
        print(biomeName, height)

        task.wait()
    end
end

-- called when the service initializes (nothing to do here)
function Service:Init()
	
end

-- called when the service starts up
function Service:Start()
    self:Generate() -- regenerate the world
end

return Service