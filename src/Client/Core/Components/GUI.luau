local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local UserInputService = game:GetService("UserInputService")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local MyComponent = Component.new({ Tag = script.Name, Ancestors = { Players.LocalPlayer } })

function MyComponent:Construct()
	local trove = Trove.new()
	self.trove = trove
end

function MyComponent:Start()
	local instance = self.Instance
	local trove = self.trove

	local MOBILE_HEIGHT = 720
	local DESKTOP_HEIGHT = 1080

	local is_mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local is_mobile_only_scaling = instance:GetAttribute('_mobile_only') or false

	local target_height
	local uiscale = Instance.new('UIScale')

	uiscale.Parent = instance
	
	if is_mobile then
		target_height = MOBILE_HEIGHT
		target_height *= instance:GetAttribute('_mobile_intensity') or 1
	else
		target_height = DESKTOP_HEIGHT
		target_height *= instance:GetAttribute('_desktop_intensity') or 1
	end

	local function updateScale()
		local viewport_size = workspace.CurrentCamera.ViewportSize
		uiscale.Scale = viewport_size.Y / (target_height)
	end

	if not is_mobile and is_mobile_only_scaling then 
		return
	end

	updateScale()
	workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(updateScale)
end

function MyComponent:Stop()
	self.trove:Destroy()
end

return MyComponent