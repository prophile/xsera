function NewObject(id)
	local newObj = deepcopy(gameData["Objects"][id])
	newObj.sprite = newObj["sprite-id"]
	if newObj.mass == nil then
		newObj.mass = 1000.0 --We should add a way for objects to me immobile
	end
	print("Creating new " .. newObj.name)
	newObj.physics = physics.new_object(newObj.mass)
	newObj.physics.angular_velocity = 1.00
	return newObj
end