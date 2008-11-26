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

import('Physics')
-- import('Bullet4Demo')

ships = {}
camera = { width = 1000, height = 1000 }
carrierLocation = { 100, 50 }
carrierRotation = 0
carrierSize = {}
carrierSize[1], carrierSize[2] = graphics.sprite_dimensions("Gaitori/Carrier")
carrierHealth = 10
carrierExploded = false
hCruiserRotation = 0
hCruiserSize = {}
hCruiserSize[1], hCruiserSize[2] = graphics.sprite_dimensions("Ishiman/HeavyCruiser")
--velocity = { increment = { x = 0, y = 0 }, real = { speed = 0, x = 0, y = 0, rot = 0 }, increase = 0.1, decrease = -0.2, max = 5 }
ship = PhysicsObject(1000.0) -- a one thousand tonne ship
twothirdspi = 2.0 / 3.0 * math.pi
fivesqrt3 = (5 * math.sqrt(3))
drawshot = false
shotrot = 0
shotfired = 0
shot = { x = 0, y = 0, move = 0 }

keysDown = { accelerate = false, reverse = false, left = false, right = false }

lastTime = 0.0

function init ()
    lastTime = mode_manager.time()
    ship:set_top_speed(400.0)
    ship:set_top_angular_velocity(math.pi * 2 * 100)
    ship:set_rotational_drag(0.5)
    ship:set_drag(0.0)
end

function hypot(x, y)
    return math.sqrt(x*x + y*y)
end

function update ()
    local newTime = mode_manager.time()
    local dt = newTime - lastTime
    lastTime = newTime
    
    local angularVelocity = 0.0
    if keysDown.left then
        angularVelocity = 4.0
    elseif keysDown.right then
        angularVelocity = -4.0
    end
    local thrust = 0.0
    if keysDown.accelerate then
        thrust = 1000000.0
    elseif keysDown.reverse then
        thrust = -1000.0
    end
    
    local opposeMotionWithThrust = false
    local shipSpeed = ship:speed()
    
    if thrust < 0.0 then
        if shipSpeed < 10.0 then
            -- short circuit and just deny thrusting
            thrust = 0
        else
            print("BRAKE")
            opposeMotionWithThrust = true
        end
    end
    
    local angle = ship:angle()
    local force = {}
    if opposeMotionWithThrust then
        local unitVector = ship:velocity()
        unitVector.x = unitVector.x / shipSpeed
        unitVector.y = unitVector.y / shipSpeed
        force = { x = unitVector.x * thrust, y = unitVector.y * thrust }
    else
        force = { x = thrust * math.cos(angle), y = thrust * math.sin(angle) }
    end
    
    ship:set_angular_velocity(angularVelocity)
    ship:update(dt, force, 0.0)
end

function render ()
    graphics.begin_frame()
	
--	heavy_cruiser_rotation = ship:angle()
	local shipLocation = ship:location()
	graphics.set_camera(shipLocation.x - (camera.width / 2.0), shipLocation.y - (camera.height / 2.0), shipLocation.x + (camera.width / 2.0), shipLocation.y + (camera.width / 2.0))
    if carrierHealth ~= 0 then
		graphics.draw_sprite("Gaitori/Carrier", carrierLocation[1], carrierLocation[2], carrierSize[1], carrierSize[2], carrierRotation)
    else
		if carrierExploded == false then -- I need a wait() or timer or something to delay the flash of the explosion
			sound.play("New/ExplosionCombo")
			local explosion = {}
			explosion[1], explosion[2] = graphics.sprite_dimensions("Explosions/BestExplosion")
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 0)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 1 / 6 * math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 1 / 3 * math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 1 / 2 * math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 2 / 3 * math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 5 / 6 * math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 7 / 6 * math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 4 / 3 * math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 3 / 2 * math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 5 / 3 * math.pi)
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], 11 / 6 * math.pi)
			carrierExploded = true
		end
	end
	graphics.draw_sprite("Ishiman/HeavyCruiser", shipLocation.x, shipLocation.y, hCruiserSize[1], hCruiserSize[2], ship:angle())

--	these three lines cause errors???
--	graphics.draw_line(100 + fivesqrt3, 0, 100 - fivesqrt3, -10, 3, ship:angle())
--	graphics.draw_line(100 - fivesqrt3, -10, 100 - fivesqrt3, 10, 3, ship:angle())
--	graphics.draw_line(100 - fivesqrt3, 10, 100 + fivesqrt3, 0, 3, ship:angle())
	
	--[[ship.shift.x = ship.x + math.cos(hCruiserRotation) * 100
	ship.shift.y = ship.y + math.sin(hCruiserRotation) * 100
	ship.shift.a.x = ship.x + math.cos(hCruiserRotation) * 100 + math.cos(hCruiserRotation) * 6
	ship.shift.a.y = ship.y + math.sin(hCruiserRotation) * 100 + math.sin(hCruiserRotation) * 6 
	ship.shift.b.x = ship.x + math.cos(hCruiserRotation) * 100 + math.cos(hCruiserRotation + twothirdspi) * 6
	ship.shift.b.y = ship.y + math.sin(hCruiserRotation) * 100 + math.sin(hCruiserRotation + twothirdspi) * 6
	ship.shift.c.x = ship.x + math.cos(hCruiserRotation) * 100 + math.cos(hCruiserRotation - twothirdspi) * 6
	ship.shift.c.y = ship.y + math.sin(hCruiserRotation) * 100 + math.sin(hCruiserRotation - twothirdspi) * 6
	if drawshot == true then
		-- shotrot = hCruiserRotation
		-- How do I get this equal to the ship's rotation??
		shot.x = ship.x
		shot.y = ship.y
		shot.move = 19
		graphics.draw_line(shot.x + math.cos(shotrot) * 17, shot.y + math.sin(shotrot) * 17, shot.x + math.cos(shotrot) * 52, shot.y + math.sin(shotrot) * 52, 2)
		drawshot = false
		shotfired = true
	end
	if shotfired == true then
		shot.move = shot.move + 15
		if shot.move >= 120 then
			shotfired = false
		end
		graphics.draw_line(shot.x + math.cos(shotrot) * shot.move, shot.y + math.sin(shotrot) * shot.move, shot.x + math.cos(shotrot) * (40 + shot.move), shot.y + math.sin(shotrot) * (40 + shot.move), 2)
	end
	if firebullet == true then
		fire_bullet(ship.x, ship.y, hCruiserRotation)
		firebullet = false
		bulletfired = true
	end
	if bulletfired == true then
		
	end
	graphics.draw_line(ship.shift.a.x, ship.shift.a.y, ship.shift.b.x, ship.shift.b.y, 2)
	graphics.draw_line(ship.shift.b.x, ship.shift.b.y, ship.shift.c.x, ship.shift.c.y, 2)
	graphics.draw_line(ship.shift.c.x, ship.shift.c.y, ship.shift.a.x, ship.shift.a.y, 2)
	--]]
	-- this is hacky code, it should have a call to graphics.set_camera here
	--[[graphics.set_camera(0, 0, 640, 480)
	graphics.draw_image("Panels/SideLeft", 31, 240, 69.29, 480)
	graphics.draw_image("Panels/SideRight", 634, 240, 12.69, 480)
	--]]
	-- why did you change the dimensions to 640x480? They were fine before
    graphics.set_camera(-500, -500, 500, 500)
	graphics.draw_image("Panels/SideLeft", -435, 0, 129, 1000)
    graphics.draw_image("Panels/SideRight", 487, 0, 27, 1000)
	graphics.end_frame()
end



bullet = { x = 0, y = 0, dest = { x = 100, y = 50 }, velocity = 1, beta = 0, theta = 0, size = { x = 0, y = 0 }, turn_rate = 0.01, ammo = 5 }
bullet.size.x, bullet.size.y = graphics.sprite_dimensions("Weapons/WhiteYellowMissile")
firebullet = false
bulletfired = false

function fire_bullet(x, y, angle)
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

function keyup ( k )
    if k == "w" then
        keysDown.accelerate = false
    elseif k == "s" then
        keysDown.reverse = false
    elseif k == "a" then
        keysDown.left = false
    elseif k == "d" then
        keysDown.right = false
    end
end

function key ( k )
	if k == "w" then
		keysDown.accelerate = true
	elseif k == "s" then
		keysDown.reverse = true
	elseif k == "a" then
		keysDown.left = true
	elseif k == "d" then
		keysDown.right = true
	elseif k == "z" then
		firebullet = true
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
		-- drawshot = true;
	elseif k == "p" then
		carrierHealth = 0
	end
end
