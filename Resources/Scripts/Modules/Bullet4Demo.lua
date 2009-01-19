-- Bullet handling for demo. Initial versions will only allow one bullet, subsequent versions should allow more.
-- DEMOFINAL: Integrate into Demo.lua

cMissileLauncher = { ammo = 50 }

--[[ Treatise on Crystospheres - also known as bullet angle theory
There are three angles to any bullet - the angle it wants, the angle it has, the angle that it will change
The angle it has is referred to as simply 'angle'. That should REALLY simplify my life, you freaking moron (talking to myself of course).
The angle it wants will be referred to as theta. This is the angle between it and its target.
The angle that it will change will be referred to as delta. Because delta means "change" in Greek, or some such nonsense :P. Also, delta is equal to the difference of angle and theta (not necessarily in that order)
--]]

function fire_bullet()
--[[ here's what this function should look like when finished:
1- Find all possible targets in missile range
2- Select best target and seek it
(Update with new target if necessary when updating?)
--]]
	if cMissileLauncher.ammo > 0 then
		cMissileLauncher.ammo = cMissileLauncher.ammo - 1
		sound.play("RocketLaunchr")
		-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included for troubleshooting)
		cMissile.isSeeking = should_seek();
	--	cMissile.physicsObject.location = playerShip.physicsObject.location
	--	cMissile.physicsObject.angle = playerShip.physicsObject.angle
	end
end

function should_seek()
	if cMissile.isSeeking == false then
		return false
	end
	local partone = false -- test if it's within line one
	local parttwo = false -- test if it's within line two
	local partthree = false -- test if it's within line three
	local quad_angle_minus, quad_angle, quad_angle_plus = find_quadrant_range2(cMissile.physicsObject.angle, cMissile.max_seek_angle)
	if math.tan(cMissile.physicsObject.angle + cMissile.max_seek_angle / 2) > 0 then
		if cMissile.dest.y + playerShip.physicsObject.position.y <= math.tan(cMissile.physicsObject.angle + cMissile.max_seek_angle / 2) * cMissile.dest.x + playerShip.physicsObject.position.x then
			partone = true
		end
	else
		if cMissile.dest.y + playerShip.physicsObject.position.y >= math.tan(cMissile.physicsObject.angle + cMissile.max_seek_angle / 2) * cMissile.dest.x + playerShip.physicsObject.position.x then
			partone = true
		end
	end
	if math.sin(cMissile.physicsObject.angle) > 0 then
		if cMissile.dest.y + playerShip.physicsObject.position.y + math.sin(cMissile.physicsObject.angle) * cMissile.life <= (-1 / math.tan(cMissile.physicsObject.angle)) * cMissile.dest.x + playerShip.physicsObject.position.x + math.cos(cMissile.physicsObject.angle) * cMissile.life then
			parttwo = true
		end
	else
		if cMissile.dest.y + playerShip.physicsObject.position.y + math.sin(cMissile.physicsObject.angle) * cMissile.life >= (-1 / math.tan(cMissile.physicsObject.angle)) * cMissile.dest.x + playerShip.physicsObject.position.x + math.cos(cMissile.physicsObject.angle) * cMissile.life then
			parttwo = true
		end
	end
	if math.tan(cMissile.physicsObject.angle - cMissile.max_seek_angle / 2) < 0 then
		if cMissile.dest.y + playerShip.physicsObject.position.y >= math.tan(cMissile.physicsObject.angle - cMissile.max_seek_angle / 2) * cMissile.dest.x + playerShip.physicsObject.position.x then
			partthree = true
		end
	else
		if cMissile.dest.y + playerShip.physicsObject.position.y <= math.tan(cMissile.physicsObject.angle - cMissile.max_seek_angle / 2) * cMissile.dest.x + playerShip.physicsObject.position.x then
			partthree = true
		end
	end
	if partone == false then
		return false
	elseif parttwo == false then
		return false
	elseif partthree == false then
		return false
	else
		return true
	end
end

function guide_bullet()
	if cMissile.isSeeking == true then
		local big_angle = bigger_angle(cMissile.physicsObject.angle, cMissile.physicsObject.angle)
		local small_angle = smaller_angle(cMissile.physicsObject.angle, cMissile.physicsObject.angle)
		if big_angle - small_angle > math.pi then -- need to go through 0
			cMissile.delta = 2 * math.pi - big_angle + small_angle
		else
			cMissile.delta = big_angle - small_angle
		end
		
		if math.abs(cMissile.delta) > cMissile.turnrate then
			if cMissile.delta > cMissile.turnrate then
				cMissile.delta = -cMissile.turnrate
			else
				cMissile.delta = cMissile.turnrate
			end
		end
	else
		cMissile.delta = 0
	end
end

function bullet_collision(bulletObject, shipObject)
	cMissile.fired = true
	shipObject.health = shipObject.health - bulletObject.damage
end