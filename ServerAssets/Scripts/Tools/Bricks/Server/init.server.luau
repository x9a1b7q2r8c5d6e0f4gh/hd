local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sound = require(ReplicatedStorage.Shared.Assets.Sounds)
local Config = require(ReplicatedStorage.Shared.Config)

local RATE = .035
local DELAY = 0.1

local Tool = script.Parent
local Equipped = false
local Amount = 1
local Last = -math.huge
local LastEquipped = -math.huge

local LoopService = require(ServerScriptService.Server.Core.Loop)
local EconomyService = require(ServerScriptService.Server.Core.Economy)

local Player = if Tool.Parent:IsA("Model") then Players:GetPlayerFromCharacter(Tool.Parent) else Tool.Parent.Parent -- if tool is in character, get player from character, otherwise get player from tool in backpack
local Base = LoopService:GetPlayerBase(Player)

local function createBrick(index)
    local brick = Tool.Handle:Clone()
    brick.Name = tostring(index)
    brick.Parent = Tool.Stack
    brick.Color = Tool.Handle.Color:Lerp(Color3.new(0, 0, 0), index % 2 == 0 and 0.25 or 0)
    brick.CanCollide = false

    brick.CFrame = Tool.Handle.CFrame *
     CFrame.new(0, (index - 1) * brick.Size.Y, 0) *
     CFrame.Angles(math.rad(math.random(-2, 2)), math.rad(math.random(-10, 10)), 0)
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = index == 2 and Tool.Handle or Tool.Stack[tostring(index-1)]
    weld.Part1 = brick
    weld.Parent = brick
    
    return brick
end

local function update()
    local new_count = script.Parent:GetAttribute('Count')

    if new_count <= 0 then
        script.Parent:Destroy()
        return
    end

    if new_count > Amount then
        for i = Amount + 1, new_count do
            createBrick(i)
        end
   
    elseif new_count < Amount then
        for i = Amount, new_count + 1, -1 do
            local brick = Tool.Stack:FindFirstChild(tostring(i))
            if brick then
                brick:Destroy()
            end
        end
    end
    
    Amount = new_count
end

update()
script.Parent:GetAttributeChangedSignal('Count'):Connect(update)

local function onEquipped()
    Equipped = true
    LastEquipped = os.clock()
end

local function onUnequipped()
    Equipped = false
end

script.Parent.Equipped:Connect(onEquipped)
script.Parent.Unequipped:Connect(onUnequipped)

local function onHeartbeat()
    if not Equipped then return end
    if os.clock() - LastEquipped < DELAY then return end
    if os.clock() - Last < RATE then return end
    if not Player.Character then return end
    if not Player.Character:FindFirstChild('Bridge') then return end
    
    Last = os.clock()

    local bridge = Base.bridges[Player.Character.Bridge.Value or '']
    if not bridge then return end

    local nearest_block, nearest_distance = bridge:FindNearestBlock(Player.Character.HumanoidRootPart.Position, function(instance: BasePart)
        return not instance:GetAttribute('Enabled')
    end)

    if nearest_block then
        Sound.playSound(Sound.Miscellaneous.Ploop, {Parent = nearest_block, RollOffMaxDistance = 30, PlaybackSpeed = 1 + (math.random(-5, 10) / 30)})

        nearest_block:SetAttribute('Enabled', true)
        Tool:SetAttribute('Count', Tool:GetAttribute('Count') - 1)

        local bricks = Base.players[Player].bricks
        bricks(bricks() + 1)

        LoopService.Placed:Fire(Player, nearest_block)
        
        EconomyService:ApplyReward(Player, {name = 'Cash', arguments = {Config.Game.CashFromPlacing}})
        EconomyService:ApplyReward(Player, {name = 'Placed', arguments = {1}})
    end
end

RunService.Heartbeat:Connect(onHeartbeat)