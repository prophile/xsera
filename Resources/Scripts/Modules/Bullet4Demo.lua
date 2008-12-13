-- Bullet handling for demo. Initial versions will only allow one bullet, subsequent
-- versions should allow more.

bullet = { x = 0, y = 0, dest = { x = 100, y = 50 }, force = { x = 0, y = 0 }, power = 5, velocity = 1, alpha = 0, beta = 0, theta = 0, size = { x = 0, y = 0 }, turn_rate = 0.04, ammo = 50 }
bullet.size.x, bullet.size.y = graphics.sprite_dimensions("Weapons/WhiteYellowMissile")
firebullet = false

local dt = 0

function fire_bullet(dt)
	if bullet.ammo > 0 then
		physbullet = PhysicsObject(0.005)
		physbullet:set_top_speed(600.0)
		physbullet:set_top_angular_velocity(bullet.turn_rate)
		physbullet:set_rotational_drag(0.0)
		physbullet:set_drag(0.0)
		
		bullet.x = shipLocation.x + math.cos(ship:angle()) * 1000
		bullet.y = shipLocation.y + math.sin(ship:angle()) * 1000
		bullet.dest.x = 700
		bullet.dest.y = 500
		bullet.beta = find_angle(bullet.dest, physbullet:location())
		bullet.theta = ship:angle()
		-- theta is the true angle of the bullet, and beta is the desired angle
		
		--[[ I'm taking out initial angle calculations, because I'm working on the routine
		if bullet.theta ~= bullet.beta then -- if the angles are the same, don't go through this if nest
			if bullet.beta >= bullet.theta + bullet.turn_rate then
				bullet.theta = bullet.theta + bullet.turn_rate
			else -- if bullet.beta < bullet.theta + bullet.turn_rate then
				if bullet.beta > bullet.theta then -- the difference between the two is less than the turn rate
					bullet.theta = bullet.beta -- make them equal
				elseif bullet.beta > bullet.theta - bullet.turn_rate then -- the difference between the two is less than the turn rate, on the other side
					bullet.theta = bullet.beta -- make them equal
				end
			end
			if bullet.beta < bullet.theta - bullet.turn_rate then -- theta is less than beta by a difference more than the turn rate
				bullet.theta = bullet.theta - bullet.turn_rate
			end
		end
		--]]
		
		bullet.theta = bullet.theta % (math.pi * 2)
		bullet.force.x = math.cos(bullet.theta) * bullet.power
		bullet.force.y = math.sin(bullet.theta) * bullet.power

		physbullet:set_angle(bullet.theta)
		physbullet:update(dt, bullet.force, 0.0)

		bullet.ammo = bullet.ammo - 1
		sound.play("RocketLaunchr")
		-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included in git for troubleshooting)
	end
end
