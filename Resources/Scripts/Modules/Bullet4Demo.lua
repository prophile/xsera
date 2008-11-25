-- Bullet handling for demo. Initial versions will only allow one bullet, subsequent
-- versions should allow more.

-- This file does not work! see Demo.lua for real code...

bullet = { x = 0, y = 0, destination = { x = 100, y = 50 }, velocity = 5, theta = 0, turn_rate = 0.1, ammo = 5 }

function fire_bullet(ship = { x, y }, angle)
	if bullet.ammo < 0 then
		bullet.x = ship.x
		bullet.y = ship.y
		bullet.theta = angle
		bullet.ammo = bullet.ammo - 1
		sound.play("RocketLaunch")
	end
end

function move_bullet()
	
end