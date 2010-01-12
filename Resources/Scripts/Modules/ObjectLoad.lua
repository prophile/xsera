function NewObject(id)
	
	function CopyActions(obj)
		obj.trigger = {}
		if obj.action ~= nil then
			local id
			print(obj.name)
			for id = 1, #obj.action do
				if obj.action[id] ~= nil then
					obj.trigger[obj.action[id].trigger] = obj.action[id]
				end
			end
		end
	end
	
	local newObj = deepcopy(gameData["Objects"][id])
	
	if newObj["sprite-id"] ~= nil then
		newObj.sprite = newObj["sprite-id"]
		
		x, y = graphics.sprite_dimensions("Id/" .. newObj.sprite)
		newObj.spriteDim = {x=x,y=y}
	end
	
	if newObj.mass == nil then
		newObj.mass = 1000.0 --We should add a way for objects to me immobile
	end
	
	
	--Generalize controls for the AI
	newObj.control = {
	accel = false;
	decel = false;
	left = false;
	right = false;
	beam = false;
	pulse = false;
	special = false;
	warp = false;
	}

	newObj.physics = physics.new_object(newObj.mass)
	newObj.physics.angular_velocity = 0.00	

	--Prepare devices
	if newObj.weapon ~= nil then
		local wid
		for wid=1, #newObj.weapon do
			if newObj.weapon[newObj.weapon[wid].type] ~= nil then
				error("More than one weapon of type '" .. newObj.weapon[wid].type .. "' defined.")
			end
			local weap = deepcopy(gameData["Objects"][newObj.weapon[wid].id])
			weap.position = deepcopy(newObj.weapon[wid].position)
			weap.position.last = 1
			weap.ammo = deepcopy(weap.device.ammo)
			weap.parent = newObj
			
			CopyActions(weap)

			newObj.weapon[newObj.weapon[wid].type] = weap
		
		
		end
	end
	
	CopyActions(newObj)
	
	return newObj
end