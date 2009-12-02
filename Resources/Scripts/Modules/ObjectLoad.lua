function NewObject(id)
	local newObj = gameData["Objects"][id]
	newObj.sprite = "Ships/Ishiman/Destroyer"
	if newObj.mass == nil then
		newObj.mass = 1000.0 --We should add a way for objects to me immobile
	end
	newObj.physics = physics.new_object(newObj.mass)
	newObj.physics.angular_velocity = 1.00
	return newObj
end