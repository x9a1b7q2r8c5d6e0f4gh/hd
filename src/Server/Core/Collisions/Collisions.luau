local Collosions = {}

local PhysicsService = game:GetService("PhysicsService")

do -- character
	PhysicsService:RegisterCollisionGroup("Character")
	PhysicsService:CollisionGroupSetCollidable("Character", "Character", false)
end

do -- Ragdolls
	PhysicsService:RegisterCollisionGroup("Ragdoll")
	PhysicsService:CollisionGroupSetCollidable("Ragdoll", "Ragdoll", false)
	PhysicsService:CollisionGroupSetCollidable("Ragdoll", "Character", false)

	PhysicsService:RegisterCollisionGroup("RagdollTorso")
	PhysicsService:CollisionGroupSetCollidable("RagdollTorso", "Ragdoll", false)
	PhysicsService:CollisionGroupSetCollidable("RagdollTorso", "Character", false)
end

do -- pickups
	PhysicsService:RegisterCollisionGroup("Pickup")
	PhysicsService:CollisionGroupSetCollidable("Pickup", "Pickup", false)
	PhysicsService:CollisionGroupSetCollidable("Pickup", "Character", false)
end

return Collosions
