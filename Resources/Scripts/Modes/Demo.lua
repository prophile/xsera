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
ship = PhysicsObject(1000.0, { x = 0, y = 0 }, { x = 0, y = 0 }, 0) -- a one thousand tonne ship

import ('ShipLoad')
import('Bullet4Demo')

twothirdspi = 2.0 / 3.0 * math.pi
fivesqrt3 = (5 * math.sqrt(3))
camera = { width = 1000, height = 1000 }

ships = {}
carrierLocation = { 100, 50 }
carrierRotation = 0
carrierHealth = 10
carrierExploded = false

drawshot = false
shotfired = 0
shot = { x = 0, y = 0, move = 0 }
local frame = 0

local bulletFired = false
local bulletRotation = 0
local newTime = 0
local dt = 0
local lastTime = 0

keysDown = { accelerate = false, reverse = false, left = false, right = false }

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

local arrowDist = hypot(10, (100 - fivesqrt3))
local arrowAlpha = math.atan2(10, 100 - fivesqrt3)

function update ()
	newTime = mode_manager.time()
    dt = newTime - lastTime
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
    
	if firebullet == true then
		fire_bullet()
		firebullet = false
		bulletFired = true
	end
	
    ship:set_angular_velocity(angularVelocity)
    ship:update(dt, force, 0.0)
end

function render ()
    graphics.begin_frame()
	
	shipLocation = ship:location()
	graphics.set_camera(shipLocation.x - (camera.width / 2.0), shipLocation.y - (camera.height / 2.0), shipLocation.x + (camera.width / 2.0), shipLocation.y + (camera.width / 2.0))
    if carrierHealth ~= 0 then
		graphics.draw_sprite("Gaitori/Carrier", carrierLocation[1], carrierLocation[2], Gai_Carrier_Size[1], Gai_Carrier_Size[2], carrierRotation)
    else
		if carrierExploded == false then
			if frame == 0 then
				sound.play("New/ExplosionCombo")
			end
			local explosion = {}
			explosion[1], explosion[2] = graphics.sprite_dimensions("Explosions/BestExplosion")
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation[1], carrierLocation[2], explosion[1], explosion[2], frame / 6 * math.pi)
			if frame == 12 then
				carrierExploded = true
			else
				frame = frame + 1
			end
		end
	end
	graphics.draw_sprite("Ishiman/HeavyCruiser", shipLocation.x, shipLocation.y, Ish_hCruiser_Size[1], Ish_hCruiser_Size[2], ship:angle())
	
	if bulletFired == true then
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
		
		bullet.theta = bullet.theta % (math.pi * 2)
		force = { x = 0, y = 0 }
		force.x = math.cos(bullet.theta) * physbullet:speed()
		force.y = math.sin(bullet.theta) * physbullet:speed()
--		force.x = math.cos(bullet.theta) * shipVelocity.x
--		force.y = math.sin(bullet.theta) * shipVelocity.y

		physbullet:set_angle(bullet.theta)
		physbullet:update(dt, force, 0.0)

		--I have a feeling that here I need to update the bullet somehow
		local bulletLocation = physbullet:location()
		graphics.draw_sprite("Weapons/WhiteYellowMissile", bulletLocation.x, bulletLocation.y, bullet.size.x, bullet.size.y, physbullet:angle())
	end
	
	
	if shotfired == true then
		shot.move = shot.move + 15
		if shot.move >= 120 then
			shotfired = false
		end
		graphics.draw_line(shot.x + math.cos(bulletRotation) * shot.move, shot.y + math.sin(bulletRotation) * shot.move, shot.x + math.cos(bulletRotation) * (40 + shot.move), shot.y + math.sin(bulletRotation) * (40 + shot.move), 2)
	end
	if drawshot == true then
		bulletRotation = ship:angle()
		shot.x = shipLocation.x
		shot.y = shipLocation.y
		shot.move = 19
		graphics.draw_line(shot.x + math.cos(bulletRotation) * 17, shot.y + math.sin(bulletRotation) * 17, shot.x + math.cos(bulletRotation) * 52, shot.y + math.sin(bulletRotation) * 52, 2)
		drawshot = false
		shotfired = true
	end
	
	
	graphics.set_camera(-camera.width / 2.0, -camera.height / 2.0, camera.width / 2.0, camera.width / 2.0)
	
	graphics.draw_line(math.cos(arrowAlpha + ship:angle()) * arrowDist, math.sin(arrowAlpha + ship:angle()) * arrowDist, math.cos(ship:angle() - arrowAlpha) * arrowDist, math.sin(ship:angle() - arrowAlpha) * arrowDist, 2)
	graphics.draw_line(math.cos(ship:angle() - arrowAlpha) * arrowDist, math.sin(ship:angle() - arrowAlpha) * arrowDist, math.cos(ship:angle()) * (100 + fivesqrt3), math.sin(ship:angle()) * (100 + fivesqrt3), 2)
	graphics.draw_line(math.cos(ship:angle()) * (100 + fivesqrt3), math.sin(ship:angle()) * (100 + fivesqrt3), math.cos(arrowAlpha + ship:angle()) * arrowDist, math.sin(arrowAlpha + ship:angle()) * arrowDist, 2)
	-- graphics.draw_line(math.cos(ship:angle()) * (100 + fivesqrt3), math.sin(ship:angle()) * (100 + fivesqrt3), 0, 0, 2)
	--[[graphics.set_camera(0, 0, 640, 480)
	graphics.draw_image("Panels/SideLeft", 31, 240, 69.29, 480)
	graphics.draw_image("Panels/SideRight", 634, 240, 12.69, 480)
	--]]
	-- why did you change the dimensions to 640x480? They were fine before
	graphics.set_camera(-camera.width / 2.0, -camera.height / 2.0, camera.width / 2.0, camera.width / 2.0)
	graphics.draw_image("Panels/SideLeft", -435, 0, 129, 1000)
    graphics.draw_image("Panels/SideRight", 487, 0, 27, 1000)
	graphics.end_frame()
end

--[[

bullet = { x = 0, y = 0, dest = { x = 100, y = 50 }, lock = { x = false, y = false }, velocity = 1, beta = 0, theta = 0, size = { x = 0, y = 0 }, turn_rate = 0.01, ammo = 50 }
bullet.size.x, bullet.size.y = graphics.sprite_dimensions("Weapons/WhiteYellowMissile")
firebullet = false

function fire_bullet()
	if bullet.ammo > 0 then
		local shipLocation = ship:location()
		local shipVelocity = ship:speed()
		physbullet = PhysicsObject(1.0, ship:location(), ship:velocity(), ship:angle())
		physbullet:set_top_speed(50.0)
		physbullet:set_top_angular_velocity(bullet.turn_rate)
		physbullet:set_rotational_drag(0.2)
		physbullet:set_drag(0.0)
		
		bullet.x = shipLocation.x + math.cos(ship:angle()) * 100
		bullet.y = shipLocation.y + math.sin(ship:angle()) * 100
		bullet.dest.x = 100
		bullet.dest.y = 50
		bullet.beta = math.atan2(bullet.dest.y - bullet.y, bullet.dest.x - bullet.x)
		bullet.theta = ship:angle()
		-- theta is the true angle of the bullet, and beta is the desired angle
		
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
		
		bullet.theta = bullet.theta % (math.pi * 2)
		force = { x = 0, y = 0 }
		force.x = math.cos(bullet.theta) * physbullet:speed()
		force.y = math.sin(bullet.theta) * physbullet:speed()
--		force.x = math.cos(bullet.theta) * shipVelocity.x
--		force.y = math.sin(bullet.theta) * shipVelocity.y

		physbullet:set_angle(bullet.theta)
		physbullet:update(dt, force, 0.0)

		bullet.ammo = bullet.ammo - 1
		sound.play("RocketLaunchr")
		-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included in git for troubleshooting)
	end
end

function moving_bullet()
	bullet.beta = math.atan2(bullet.dest.y - bullet.y, bullet.dest.x - bullet.x)
	if bullet.beta >= bullet.turn_rate then --this if chain changes the angle at which the bullet is going, if necessary
		bullet.theta = bullet.theta + bullet.turn_rate
	elseif bullet.beta <= bullet.turn_rate then
		bullet.theta = bullet.theta - bullet.turn_rate
	elseif bullet.beta < bullet.turn_rate then 
		if bullet.beta > 0 then
			bullet.theta = bullet.theta + bullet.beta
		end
	elseif bullet.beta > bullet.turn_rate then
		if bullet.beta < 0 then
			bullet.theta = bullet.theta - bullet.beta
		end
	end
	bullet.x = bullet.x + math.cos(bullet.beta) * bullet.velocity
	bullet.y = bullet.y + math.sin(bullet.beta) * bullet.velocity
	bullet.theta = bullet.theta % (math.pi * 2)
end
--]] -- this code is the old code (currently unnecessary, any reason to keep it?)

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
		drawshot = true;
	elseif k == "p" then
		carrierHealth = 0
	elseif k == "escape" then
		-- exit()
	end
end
