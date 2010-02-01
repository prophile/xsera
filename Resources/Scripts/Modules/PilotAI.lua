import('Math')

function DumbSeek(object, target)
	object.control.accel = true
	object.control.decel = false
	local ang = find_angle(target.position,object.physics.position) - object.physics.angle

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