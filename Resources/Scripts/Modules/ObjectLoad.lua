function NewObject(id)
	local newObj = deepcopy(gameData["Objects"][id])
	newObj.sprite = newObj["sprite-id"]
	if newObj.mass == nil then
		newObj.mass = 1000.0 --We should add a way for objects to me immobile
	end
	print("Creating new " .. newObj.name)
	newObj.physics = physics.new_object(newObj.mass)
	newObj.physics.angular_velocity = 1.00
	
	if newObj.weapon ~= nil then
		local wid
		for wid=1, #newObj.weapon do
			if newObj.weapon[newObj.weapon[wid].type] ~= nil then
				error("More than one weapon of type '" .. newObj.weapon[wid].type .. "' defined.")
			end
			local weap = deepcopy(gameData["Objects"][newObj.weapon[wid].id])
			weap.position = deepcopy(newObj.weapon[wid].position)
			weap.lastPos = 1
			weap.ammo = weap.device.ammo
--			print("TEST:" .. newObj.weapon[wid].type)
			newObj.weapon[newObj.weapon[wid].type] = weap
			
		end
	end
	return newObj
end