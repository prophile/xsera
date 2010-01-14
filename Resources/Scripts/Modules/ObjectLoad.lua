import('GlobalVars')
import('Actions')

function NewObject(id)
	
	function CopyActions(obj)
		obj.trigger = {}
		if obj.action ~= nil then
			local id
			for id = 1, #obj.action do
				if obj.action[id] ~= nil then
					obj.trigger[obj.action[id].trigger] = obj.action[id]
				end
			end
		end
		
		if obj.trigger.activate ~= nil and obj.trigger.activate.count > 255 then
			obj.trigger.activate.activateInterval = math.floor(obj.trigger.activate.count/2^23)
			obj.trigger.activate.intervalRange = math.floor(obj.trigger.activate.count/2^15)%2^7
--			math.floor(c/2^7)%7 --No decernable use.
			obj.trigger.activate.count = obj.trigger.activate.count%2^7
			
			obj.trigger.activateInterval = obj.trigger.activate.activateInterval / TIME_FACTOR
			obj.trigger.activateRange = obj.trigger.activate.intervalRange / TIME_FACTOR
			obj.trigger.nextActivate = mode_manager.time() + obj.trigger.activateInterval + math.random(0,obj.trigger.activateRange)
		else
			obj.trigger.activateInterval = 0
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
	
	if newObj.spriteDim ~= nil then
		newObj.physics.collision_radius = hypot1(newObj.spriteDim)/32
	else
		newObj.physics.collision_radius = 1
	end
	
	if newObj["initial-age"] ~= nil then
		newObj.created = mode_manager.time()
		newObj.age = newObj["initial-age"] / TIME_FACTOR
		--the documentation for Hera says that initial-age is in 20ths of a second but it appears to be 60ths
	end

	if newObj.animation ~= nil then
		newObj.animation.start = mode_manager.time()
		newObj.animation.frameTime = newObj.animation["frame-speed"] / TIME_FACTOR / 30.0 --Is the ratio here 1:1800?		
	end

	newObj.dead = false

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
			
			weap.device.lastActivated = -weap.device["fire-time"] / TIME_FACTOR
			
			CopyActions(weap)

			newObj.weapon[newObj.weapon[wid].type] = weap
		
		
		end
	end
	
	CopyActions(newObj)
	CreateTrigger(newObj)
	return newObj
end