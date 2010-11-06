--import('Math')
--import('GlobalVars')

function Think(object)
	
	if CanThink(object.base.attributes) then
	local target = object.ai.objectives.target or object.ai.objectives.dest
	local dist
	if target ~= nil then
		dist = hypot2(object.physics.position, target.physics.position)
		if object.base.attributes.isGuided == true then
			object.ai.mode = "goto"
		elseif dist < 350
		and target.ai.owner ~= object.ai.owner
		and target.base.attributes.hated == true then
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
		if target ~= nil then
			TurnToward(object, target)
			if dist > 200 then
				object.control.accel = true
				object.control.decel = false
			else
				object.control.accel = false
				object.control.decel = true
			end
		else
			object.control.accel = true
			object.control.decel = false
		end
	
		
		object.control.beam = true
		object.control.pulse = true
		object.control.special = true
	end
	
	else
		object.control.accel = true
	end
end

function CanThink(attr)
	return attr.canEngange or attr.canEvade or attr.canAcceptDestination
end


function TurnAway(object, target)
	local ang = findAngle(target.physics.position,object.physics.position) - object.physics.angle
	ang = normalizeAngle(ang)
	
	if ang <= 0.95 * math.pi then
		object.control.left = false
		object.control.right = true
	elseif ang >= 1.05 * math.pi then
		object.control.left = true
		object.control.right = false
	else
		object.control.left = false
		object.control.right = false
	end
end

function TurnToward(object, target)

	local ang = AimFixed(object.physics,target.physics, hypot1(object.physics.velocity)) - object.physics.angle

	ang = normalizeAngle(ang)
	
	if math.abs(ang-math.pi) >= math.pi * 0.95 then
		object.control.left = false
		object.control.right = false
	elseif ang <= math.pi * 0.95 then
		object.control.left = true
		object.control.right = false
	else
		object.control.left = false
		object.control.right = true
	end
end


function AimFixed(parent, target, bulletVel)
	--Grrrr
	if getmetatable(target.position) == nil then
		return parent.angle
	end

	local distance = hypot2(parent.position,target.position)
	local time = distance/bulletVel


	local initialOffset = target.position - parent.position
	local velocityDiff = target.velocity - parent.velocity

	local finalOffset = initialOffset + velocityDiff * time

	local absAngle = math.atan2(finalOffset.y,finalOffset.x)

	return absAngle
end

--Used to calculate absolute angle at which to fire the turret.
function AimTurret(gun, target, bulletVel)
	local gPos = gun.position
	local tPos = target.position

	local rPos = tPos - gPos
	local rVel = target.velocity - gun.velocity

	local A = -bulletVel^2 + rVel * rVel
	local B = 2 * (rPos * rVel)
	local C = rPos * rPos

	--Assumes bullet is faster than target
	--use -b + math.sqrt(...
	--if target is faster

	local t = (-B - math.sqrt(B^2 - 4 * A * C))/(2*A)

	local slope = rPos + rVel * t

	local theta = math.atan2(slope.y, slope.x)

	return theta
end





