-- Progress circle

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Charm = require(ReplicatedStorage.Packages.Charm)
local t = require(ReplicatedStorage.Packages.t)
local Spr = require(ReplicatedStorage.Packages.Spr)

local Sweep = {}
Sweep.__index = Sweep

function Sweep.mount(instance: GuiObject)
    local self = setmetatable({}, Sweep)

    self.trove = Trove.new()
    self.instance = instance
    self.value = Charm.atom(t.number)

    assert(instance:IsA('GuiObject'), 'instance must be a GuiObject')

    local left = assert(instance:FindFirstChild('Left'), 'instance missing Left container'):FindFirstChild('ImageLabel')
    local right = assert(instance:FindFirstChild('Right'), 'instance missing Right container'):FindFirstChild('ImageLabel')

    local function update(value: number)
        local angle = math.clamp(value * 360, 0, 360)
		
		left.UIGradient.Rotation = math.clamp(angle, 180, 360)
		right.UIGradient.Rotation = math.clamp(angle, 0, 180)
    end

    update(0)
    self.trove:Add(Charm.subscribe(self.value, update))

    return self
end

function Sweep:Set(value: number)
    self.value(value)
end

function Sweep:Destroy()
    self.trove:Destroy()
end

return Sweep