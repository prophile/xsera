import('Math')

function Think(object)
	
	local target = object.ai.objectives.target or object.ai.objectives.dest

	if target ~= nil then
		local dist = find_hypot(object.physics.position, target.physics.position)
		if dist > 200 then --[HARDCODE]
			object.ai.mode = "goto"
		else
			object.ai.mode = "wait"
		end
		
		if object.ai.mode == "wait" then
			object.control.accel = false
			object.control.decel = true
			object.control.left = false
			object.control.right = false
		elseif object.ai.mode == "goto" then
			object.control.accel = true
			object.control.decel = false
			TurnToTarget(object,target)
		end
	end
end



function TurnToTarget(object, target)

	local ang = find_angle(target.physics.position,object.physics.position) - object.physics.angle

	ang = radian_range(ang)
--[[	if ang < math.pi / 2 then
		object.control.accel = true 
		object.control.decel = false
	else 
		object.control.accel = false
		object.control.decel = true
	end]]
	
	if math.abs(ang) < 0.1 then
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