import('GlobalVars')

first_play = true

function ai_pathfind(dt, object, destination, computerShip)
	if find_hypot(object.physicsObject.position, destination) >= 50 then
		print(object.physicsObject.angle, math.atan2(destination.y - object.physicsObject.position.y, destination.x - object.physicsObject.position.x))
		angle_diff = math.atan2(destination.y - object.physicsObject.position.y, destination.x - object.physicsObject.position.x) - object.physicsObject.angle
		if math.abs(angle_diff) <= math.pi / 36 then
			object.physicsObject.angular_velocity = 0
			object.physicsObject.angle = object.physicsObject.angle + angle_diff
			object.force = { x = math.cos(object.physicsObject.angle) * object.thrust, y = math.sin(object.physicsObject.angle) * object.thrust }
			object.physicsObject:apply_force(object.force)
			if hypot (object.physicsObject.velocity.x, object.physicsObject.velocity.y) > object.maxSpeed then
				object.physicsObject.velocity = { x = object.maxSpeed * normalize(object.physicsObject.velocity.x, object.physicsObject.velocity.y), y = object.maxSpeed * normalize(object.physicsObject.velocity.y, object.physicsObject.velocity.x) }
			end
		else
			if angle_diff ~= 0 then
				if math.abs(angle_diff) > math.pi then -- need to go through 0
					if angle_diff > 0.0 then
						angle_diff = 2 * math.pi - angle_diff
					else
						angle_diff = 2 * math.pi + angle_diff
					end
				end
				if math.abs(angle_diff) > object.turningRate * dt then
					if angle_diff > object.turningRate * dt then
						object.physicsObject.angular_velocity = object.turningRate
					else
						object.physicsObject.angular_velocity = -object.turningRate
					end
				end
			end
		end
	else
        local force = object.physicsObject.velocity
		if force.x ~= 0 or force.y ~= 0 then
			if hypot(object.physicsObject.velocity.x, object.physicsObject.velocity.y) <= 10 then
				object.physicsObject.velocity = { x = 0, y = 0 }
			else
				local velocityMag = hypot(force.x, force.y)
				force.x = -force.x / velocityMag
				force.y = -force.y / velocityMag
				force.x = force.x * object.reverseThrust
				force.y = force.y * object.reverseThrust
				object.physicsObject:apply_force(force)
			end
		else
			if object.landed == false then
				if object.landing == false then
					sound.play("ISpaceWoosh")
					object.physicsObject.angular_velocity = 0
					object.landing = true
				end
				object.landing_size = object.landing_size - dt * 0.5
				if object.landing_size < 0 then
					object.landing_size = 0
					if computerShip == nil then
						victory_timer = 0
						object.landed = true
					else
						errLog("You must destroy the Carrier first.", 6)
					end
				end
			end
		end
	end
end