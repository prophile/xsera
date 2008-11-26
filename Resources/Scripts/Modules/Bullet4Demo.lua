-- Bullet handling for demo. Initial versions will only allow one bullet, subsequent
-- versions should allow more.

bullet = { x = 0, y = 0, dest = { x = 100, y = 50 }, velocity = 1, beta = 0, theta = 0, size = { x = 0, y = 0 }, turn_rate = 0.01, ammo = 5 }
bullet.size.x, bullet.size.y = graphics.sprite_dimensions("Weapons/WhiteYellowMissile")
firebullet = false
bulletfired = false

function fire_bullet( x, y, angle)
	if bullet.ammo > 0 then
		bullet.x = x
		bullet.y = y
		bullet.dest.x = 100
		bullet.dest.y = 50
		bullet.beta = math.atan2(bullet.dest.y - bullet.y, bullet.dest.x - bullet.x)
		bullet.theta = angle
		bullet.ammo = bullet.ammo - 1
		sound.play("RocketLaunchr")
		-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included in git for troubleshooting)
		graphics.draw_sprite("Gaitori/Carrier", 500, 450, carrierSize[1], carrierSize[2], carrierRotation)
		graphics.draw_sprite("Weapons/WhiteYellowMissile", x, y, bullet.size.x, bullet.size.y, bullet.theta)
	end
end

function moving_bullet()
	bullet.beta = math.atan2(bullet.dest.y - bullet.y, bullet.dest.x - bullet.x)
	if bullet.beta >= bullet.turn_rate then --this if chain changes the angle at which the bullet is going, if necessary
		bullet.theta = bullet.theta - bullet.turn_rate
	elseif bullet.beta <= bullet.turn_rate then
		bullet.theta = bullet.theta + bullet.turn_rate
	elseif bullet.beta < bullet.turn_rate then 
		if bullet.beta > 0 then
			bullet.theta = bullet.theta - bullet.beta
		end
	elseif bullet.beta > bullet.turn_rate then
		if bullet.beta < 0 then
			bullet.theta = bullet.theta + bullet.beta
		end
	end
	bullet.x = bullet.x + math.cos(bullet.theta) * velocity
	bullet.y = bullet.y + math.sin(bullet.theta) * velocity
	graphics.draw_sprite("Weapons/WhiteYellowMissile", bullet.x, bullet.y, bullet.size.x, bullet.size.y, bullet.theta)
end

