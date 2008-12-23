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
ship = PhysicsObject(1000.0) -- a one thousand tonne ship

import('ShipLoad')
import('Math')
import('Bullet4Demo')

twothirdspi = 2.0 / 3.0 * math.pi
camera = { w = 1000, h = 1000 }

ships = {}
carrierRotation = 0
carrierHealth = 10
carrierExploded = false

drawshot = false
shotfired = 0
shot = { x = 0, y = 0, move = 0 }
local frame = 0

local bulletFired = false
local bulletRotation = 0

keysDown = { accelerate = false, reverse = false, left = false, right = false }

function init ()
    lastTime = mode_manager.time()
    ship:set_top_speed(400.0)
    ship:set_top_angular_velocity(math.pi * 2 * 100)
    ship:set_rotational_drag(0.5)
    ship:set_drag(0.0)
end

local arrowVar = (5.5 * math.sqrt(3))
local arrowDist = hypot(11, (300 - arrowVar))
local arrowAlpha = math.atan2(11, arrowDist)

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
	
	if firebullet == true then
		fire_bullet(dt)
		firebullet = false
		bulletFired = true
	end
	
	if bulletFired == true then
		local bulletLocation = physbullet:location()
		if math.floor(bulletLocation.x / 30) == math.floor(bullet.dest.x / 30) then
			if math.floor(bulletLocation.y / 30) == math.floor(bullet.dest.y / 30) then
				bulletFired = false
			end
		end
		local bulletVelocity = physbullet:velocity()
		bullet.alpha = find_angle({ x = 0, y = 0 }, physbullet:velocity())
		bullet.beta = find_angle(physbullet:location(), bullet.dest)
		print(bullet.alpha)
		print(bullet.beta)
		print(bullet.theta)
		print("________________")
		
		-- use a bullet4demo function
		if bullet.alpha ~= bullet.beta then
			guide_bullet()
		end
		
		bullet.force.x = math.cos(bullet.theta) * bullet.power
		bullet.force.y = math.sin(bullet.theta) * bullet.power
		
	--	physbullet:set_angle(bullet.theta)
		physbullet:update(dt, bullet.force, bullet.delta * 1000)
	end
end

starfielddepth = 0

function render ()
    graphics.begin_frame()
	shipLocation = ship:location()
	graphics.set_camera(shipLocation.x - 46 - (camera.w / 2.0), shipLocation.y - (camera.h / 2.0), shipLocation.x - 46 + (camera.w / 2.0), shipLocation.y + (camera.w / 2.0))
	graphics.draw_starfield(starfielddepth)
    if carrierHealth ~= 0 then
		graphics.draw_sprite("Gaitori/Carrier", carrierLocation.x, carrierLocation.y, Gai_Carrier_Size[1], Gai_Carrier_Size[2], carrierRotation)
    else
		if carrierExploded == false then
			if frame == 0 then
				sound.play("New/ExplosionCombo")
			end
			local explosion = {}
			explosion[1], explosion[2] = graphics.sprite_dimensions("Explosions/BestExplosion")
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation.x, carrierLocation.y, explosion[1], explosion[2], frame / 6 * math.pi)
			if frame == 12 then
				carrierExploded = true
			else
				frame = frame + 1
			end
		end
	end
	graphics.draw_sprite("Ishiman/HeavyCruiser", shipLocation.x, shipLocation.y, Ish_hCruiser_Size[1], Ish_hCruiser_Size[2], ship:angle())
	
	if shotfired == true then
		shot.move = shot.move + 15
		if shot.move >= 240 then
			shotfired = false
		end
		graphics.draw_line(shot.x + math.cos(bulletRotation) * shot.move, shot.y + math.sin(bulletRotation) * shot.move, shot.x + math.cos(bulletRotation) * (30 + shot.move), shot.y + math.sin(bulletRotation) * (30 + shot.move), 2)
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
	
	if bulletFired == true then
		local bulletLocation = physbullet:location()
		graphics.draw_sprite("Weapons/WhiteYellowMissile", bulletLocation.x, bulletLocation.y, bullet.size.x, bullet.size.y, physbullet:angle())
	end
	
	
	graphics.set_camera(-camera.w / 2.0 - 46, -camera.h / 2.0, camera.w / 2.0 - 46, camera.w / 2.0)
	graphics.draw_line(math.cos(arrowAlpha + ship:angle()) * arrowDist, math.sin(arrowAlpha + ship:angle()) * arrowDist, math.cos(ship:angle() - arrowAlpha) * arrowDist, math.sin(ship:angle() - arrowAlpha) * arrowDist, 2)
	graphics.draw_line(math.cos(ship:angle() - arrowAlpha) * arrowDist, math.sin(ship:angle() - arrowAlpha) * arrowDist, math.cos(ship:angle()) * (300 + arrowVar), math.sin(ship:angle()) * (300 + arrowVar), 2)
	graphics.draw_line(math.cos(ship:angle()) * (300 + arrowVar), math.sin(ship:angle()) * (300 + arrowVar), math.cos(arrowAlpha + ship:angle()) * arrowDist, math.sin(arrowAlpha + ship:angle()) * arrowDist, 2)
	--[[
	graphics.set_camera(0, 0, 640, 480)
	graphics.draw_image("Panels/SideLeft", 31, 240, 69.29, 480)
	graphics.draw_image("Panels/SideRight", 634, 240, 12.69, 480)
	--]]
	-- why did you change the dimensions to 640x480? They were fine before
	graphics.set_camera(-500, -500, 500, 500)
	graphics.draw_image("Panels/SideLeft", -435, 0, 129, 1012)
    graphics.draw_image("Panels/SideRight", 487, -2, 27, 1020)
	graphics.end_frame()
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
	elseif k == "y" then
		starfielddepth = starfielddepth + 10000.0
		print(starfielddepth)
	elseif k == "h" then
		starfielddepth = starfielddepth - 10000.0
		print(starfielddepth)
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
