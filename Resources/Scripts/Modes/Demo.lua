-- demo script = Player is Ishiman Heavy Cruiser, opponent is Gaitori Carrier.
-- Carrier has no AI, so it just sits there. Player must warp to Carrier's position
-- and can destroy it using both seeking and non-seeking weapons. Script ends when
-- Carrier is destroyed.

-- Future possible script variations =
-- Using autopilot to find Carrier.
-- Carrier has a "fleeing" AI, and runs away when attacked, possibly warping away.
-- Carrier has other AIs.
-- Implement planets.
-- Use other Heavy Cruisers (possibly built on planets) to destroy Carrier, using attack command.

-- import('Physics')
-- import('Bullet4Demo')

ships = {}
camera = { width = 1000, height = 1000 }
carrierLocation = { 100, 50 }
carrierRotation = 0
carrierSize = {}
carrierSize[1], carrierSize[2] = graphics.sprite_dimensions("Gaitori/Carrier")
hCruiserRotation = 0
hCruiserSize = {}
hCruiserSize[1], hCruiserSize[2] = graphics.sprite_dimensions("Ishiman/HeavyCruiser")
velocity = { increment = { x = 0, y = 0 }, real = { speed = 0, x = 0, y = 0, rot = 0 }, increase = 0.1, decrease = -0.2, max = 5 }
ship = { x = 0, y = 0 }

function render ()
    graphics.begin_frame()
	
	velocity.real.x = velocity.increment.x + velocity.real.x
	velocity.real.y = velocity.increment.y + velocity.real.y
	
	ship.x = ship.x + velocity.real.x
	ship.y = ship.y + velocity.real.y
	
	velocity.increment.x = 0
	velocity.increment.y = 0
	
	if velocity.real.speed > velocity.max then
		velocity.real.speed = velocity.max
	end
	
	graphics.set_camera(ship.x - (camera.width / 2.0), ship.y - (camera.height / 2.0), ship.x + (camera.width / 2.0), ship.y + (camera.width / 2.0))
    graphics.draw_sprite("Gaitori/Carrier", carrierLocation[1], carrierLocation[2], carrierSize[1], carrierSize[2], carrierRotation)
    graphics.draw_sprite("Ishiman/HeavyCruiser", ship.x, ship.y, hCruiserSize[1], hCruiserSize[2], hCruiserRotation)
	
	graphics.set_camera(ship.x - (camera.width / 2.0), ship.y - (camera.height / 2.0), ship.x + (camera.width / 2.0), ship.y + (camera.width / 2.0), hCruiserRotation * 180 / math.pi)
	graphics.draw_line(ship.x + 112, ship.y, ship.x + 94, ship.y - (6 * math.sqrt(3)), 2)
	graphics.draw_line(ship.x + 94, ship.y - (6 * math.sqrt(3)), ship.x + 94, ship.y + (6 * math.sqrt(3)), 2)
	graphics.draw_line(ship.x + 94, ship.y + (6 * math.sqrt(3)), ship.x + 112, ship.y, 2)
	graphics.set_camera(ship.x - (camera.width / 2.0), ship.y - (camera.height / 2.0), ship.x + (camera.width / 2.0), ship.y + (camera.width / 2.0))	
    graphics.draw_image("Panels/SideLeft", -435 + ship.x, 3 + ship.y, 129, 1000)
    graphics.draw_image("Panels/SideRight", 487 + ship.x, 2 + ship.y, 27, 1000)
    graphics.end_frame()
end



bullet = { x = 0, y = 0, destination = { x = 100, y = 50 }, velocity = 5, theta = 0, size = { x = 0, y = 0 }, turn_rate = 0.1, ammo = 5 }
bullet.size.x, bullet.size.y = graphics.sprite_dimensions("Weapons/WhiteYellowMissile")

function fire_bullet(x, y, angle)
	if bullet.ammo > 0 then
		bullet.x = x
		bullet.y = y
		bullet.theta = angle
		bullet.ammo = bullet.ammo - 1
		sound.play("RocketLaunchr")
		-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included in git for troubleshooting)
		graphics.draw_sprite("Weapons/WhiteYellowMissile", x, y, bullet.size.x, bullet.size.y, bullet.theta)
	end
end




function key ( k )
	if k == "w" then
		velocity.increment.x = math.cos(hCruiserRotation) * velocity.increase
		velocity.increment.y = math.sin(hCruiserRotation) * velocity.increase
	elseif k == "s" then
		velocity.real.rot = math.atan2(velocity.real.y, velocity.real.x)
		velocity.increment.x = math.cos(velocity.real.rot) * velocity.decrease
		velocity.increment.y = math.sin(velocity.real.rot) * velocity.decrease
		if math.abs(velocity.increment.x) > math.abs(velocity.real.x) then
			velocity.real.x = 0
			velocity.increment.x = 0
		end
		if (math.abs(velocity.increment.y)) > (math.abs(velocity.real.y)) then
			velocity.real.y = 0
			velocity.increment.y = 0
		end
	elseif k == "a" then
		hCruiserRotation = (hCruiserRotation + .2) % (2 * math.pi)
	elseif k == "d" then
		hCruiserRotation = (hCruiserRotation - .2) % (2 * math.pi)
	elseif k == "q" then
		hCruiserRotation = math.pi / 2
	elseif k == "z" then
		fire_bullet (ship.x, ship.y, hCruiserRotation)
	elseif k == "x" then
		sound.play("Warp1")
	elseif k == "c" then
		sound.play("Warp2")
	elseif k == "v" then
		sound.play("Warp3")
	elseif k == "b" then
		sound.play("Warp4")
	elseif k == "n" then
		sound.play("WarpIn")
	elseif k == "m" then
		sound.play("WarpOut")
	elseif k == " " then
		sound.play("ShotC")
		-- graphics.draw_line(ship.x + 50, ship.y + 50, ship.x + 100, ship.y + 100, 20)
	end
end
