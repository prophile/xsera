import('Math')

function Think(object)
	
	local target = object.ai.objectives.target or object.ai.objectives.dest
	local dist
	if target ~= nil then
		dist = find_hypot(object.physics.position, target.physics.position)
		if dist < 350
		and target.ai.owner ~= object.ai.owner
		and target.base.attributes["hated"] == true then
			object.ai.mode = "engage"
		elseif dist > 200 and object.ai.mode == "wait" then
			object.ai.mode = "goto"
		elseif dist < 150 and object.ai.mode == "goto" then
			object.ai.mode = "wait"
		end
	else
		object.ai.mode = "wait"
	end
		
		if object.ai.mode ~= "engage" then
			object.control.beam = false
			object.control.pulse = false
			object.control.special = false
		end
		
		if object.ai.mode == "wait" then
			object.control.accel = false
			object.control.decel = true
			object.control.left = false
			object.control.right = false
		elseif object.ai.mode == "goto" then
			object.control.accel = true
			object.control.decel = false
			TurnToward(object,target)
		elseif object.ai.mode == "evade" then
			TurnAway(object, target)
		elseif object.ai.mode == "engage" then
			object.control.accel = true
			object.control.decel = false
			object.control.beam = true
			object.control.pulse = true
			object.control.special = true
			TurnToward(object,target)
		end
		
--[[	else	
		object.control.accel = false
		object.control.decel = true
		object.control.left = false
		object.control.right = false
		object.control.beam = false
		object.control.pulse = false
		object.control.special = false
		object.ai.mode = "wait"]]
		
--	end
end

function TurnAway(object, target)
	--NO CODE!!!
end

function TurnToward(object, target)

	local ang = find_angle(target.physics.position,object.physics.position) - object.physics.angle

	ang = radian_range(ang)
--[[	if ang < math.pi / 2 then
		object.control.accel = true 
		object.control.decel = false
	else 
		object.control.accel = false
		object.control.decel = true
	end]]
	
	if math.abs(ang) < 0.2 then
		object.control.left = false
		object.control.right = false
	elseif ang <= math.pi then
		object.control.left = true
		object.control.right = false
	else
		object.control.left = false
		object.control.right = true
	end
	
end