-- demo script: Player is Ishiman Heavy Cruiser, opponent is Gaitori Carrier.
-- Carrier has no AI, so it just sits there. Player must warp to Carrier's position
-- and can destroy it using both seeking and non-seeking weapons. Script ends when
-- Carrier is destroyed.

-- Future possible script variations:
-- Using autopilot to find Carrier.
-- Carrier has a "fleeing" AI, and runs away when attacked, possibly warping away.
-- Carrier has other AIs.
-- Implement planets.
-- Use other Heavy Cruisers (possibly built on planets) to destroy Carrier, using attack command.

import('EntityLoad')
import('Math')
import('MouseHandle')

local cameraRatio = 1
local aspectRatio = 4 / 3
camera = { w = 640 / cameraRatio, h }
camera.h = camera.w / aspectRatio
local shipAdjust = .045 * camera.w


--tempvars
carrierLocation = { x = 2200, y = 2700 }
--carrierLocation = { x = 200, y = 250 }
carrierRotation = math.pi / 2
carrierExploded = false
firebullet = false
firepulse = false
firespecial = false
showVelocity = false
showAngles = true
frame = 0
printFPS = false
--/tempvars


playerShip = nil
cMissile = nil
pkBeam = nil
pkBeam1 = nil
pkBeam2 = nil
bestExplosion = nil

local soundLength = 0.25

local arrowLength = 135
local arrowVar = (3 * math.sqrt(3))
local arrowDist = hypot(6, (arrowLength - arrowVar))
local arrowAlpha = math.atan2(6, arrowDist)
local gridDistBlue = 300
local gridDistLightBlue = 1200
local gridDistGreen = 4800

keyControls = { left = false, right = false, forward = false, brake = false }

function fire_bullet(missile, ship)
--[[ here's what this function should look like when finished:
1- Find all possible targets in missile range
2- Select best target and seek it
(Update with new target if necessary when updating?)

ADAM:
RIGHT NOW:
This is flawed for two reasons:
<<FIXED>> Bullet does not start with ship's velocity
2. Velocity is not taken into account when testing for seeking
how to take velocity into account:
- greatest possible velocity is during warping
- if you take the velocity of the ship during warping, multiply that by the life of the bullet, plus the max distance already calculated, you will find its upper limit
--]]
	if ship.special.ammo > 0 then
		sound.play("RocketLaunchr")
		-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included for troubleshooting)
		ship.special.ammo = ship.special.ammo - 1
		missile.start = mode_manager.time() * 1000
		missile.physicsObject.angle = ship.physicsObject.angle
		missile.physicsObject.velocity = ship.physicsObject.velocity
		if missile.isSeeking ~= false then
			local partone = false -- test if it's within line one
			local parttwo = false -- test if it's within line two
			local partthree = false -- test if it's within line three
			local quad_angle_minus, quad_angle, quad_angle_plus = find_quadrant_range(missile.physicsObject.angle, missile.max_seek_angle)
			if math.tan(missile.physicsObject.angle + missile.max_seek_angle / 2) > 0 then
				if missile.dest.y + ship.physicsObject.position.y <= math.tan(missile.physicsObject.angle + missile.max_seek_angle / 2) * missile.dest.x + ship.physicsObject.position.x then
					partone = true
				end
			else
				if missile.dest.y + ship.physicsObject.position.y >= math.tan(missile.physicsObject.angle + missile.max_seek_angle / 2) * missile.dest.x + ship.physicsObject.position.x then
					partone = true
				end
			end
			if math.sin(missile.physicsObject.angle) > 0 then
				if missile.dest.y + ship.physicsObject.position.y + math.sin(missile.physicsObject.angle) * missile.life <= (-1 / math.tan(missile.physicsObject.angle)) * missile.dest.x + ship.physicsObject.position.x + math.cos(missile.physicsObject.angle) * missile.life then
					parttwo = true
				end
			else
				if missile.dest.y + ship.physicsObject.position.y + math.sin(missile.physicsObject.angle) * missile.life >= (-1 / math.tan(missile.physicsObject.angle)) * missile.dest.x + ship.physicsObject.position.x + math.cos(missile.physicsObject.angle) * missile.life then
					parttwo = true
				end
			end
			if math.tan(missile.physicsObject.angle - missile.max_seek_angle / 2) < 0 then
				if missile.dest.y + ship.physicsObject.position.y >= math.tan(missile.physicsObject.angle - missile.max_seek_angle / 2) * missile.dest.x + ship.physicsObject.position.x then
					partthree = true
				end
			else
				if missile.dest.y + ship.physicsObject.position.y <= math.tan(missile.physicsObject.angle - missile.max_seek_angle / 2) * missile.dest.x + ship.physicsObject.position.x then
					partthree = true
				end
			end
			if partone == true then
				if parttwo == true then
					if partthree == true then
						missile.isSeeking = true
					end
				end
			end
			if missile.isSeeking ~= true then
				missile.isSeeking = false
			end
		end
		missile.location = { x, y }
		missile.physicsObject.position = ship.physicsObject.position
		missile.physicsObject.angle = ship.physicsObject.angle
		missile.fired = true
	end
end

--function guide_bullet(missile, target)
function guide_bullet(missile)
	if missile.isSeeking == true then
		missile.theta = find_angle(missile.physicsObject.position, missile.dest)
		if missile.physicsObject.angle ~= missile.theta then
			local angle_sep = missile.physicsObject.angle - missile.theta
			if math.abs(angle_sep) > math.pi then -- need to go through 0
				if angle_sep > 0.0 then
					missile.delta = 2 * math.pi - angle_sep
				else
					missile.delta = -2 * math.pi + angle_sep
				end
			else
				missile.delta = angle_sep
			end
			if math.abs(missile.delta) > missile.turningRate * dt then
				if missile.delta > missile.turningRate then
					missile.delta = -missile.turningRate * dt
				else
					missile.delta = missile.turningRate * dt
				end
			end
		else
			missile.delta = 0
		end
	end
end

function bullet_collision(bulletObject, shipObject)
	bulletObject.fired = false
	shipObject.life = shipObject.life - bulletObject.damage
end

function init ()
	sound.stop_music()
    lastTime = mode_manager.time()
    physics.open(0.6)
    playerShip = NewShip("Ishiman/HeavyCruiser")
		playerShip.warp = { warping = false, start = { bool = false, time = nil, engine = false, sound = false, isStarted = false }, endTime = 0.0, disengage = 2.0, finished = true, soundNum = 0 }
	computerShip = NewShip("Gaitori/Carrier")
		computerShip.physicsObject.position = carrierLocation
	cMissile = NewBullet("cMissile", playerShip)
		cMissile.delta = 0.0
		cMissile.dest = { x = carrierLocation.x, y = carrierLocation.y }
		cMissile.size = { x, y }
		cMissile.size.x, cMissile.size.y = graphics.sprite_dimensions("Weapons/cMissile")
		cMissile.isSeeking = true
		cMissile.fired = false
		cMissile.start = 0
		cMissile.force = { x, y }
		cMissile.damage = 10
	pkBeam = NewBullet("PKBeam", playerShip)
		pkBeam.width = cameraRatio
		pkBeam.fired = false
		pkBeam.start = 0
		pkBeam.firing = false
	pkBeamWeap = { }
		table.insert(pkBeamWeap, pkBeam)
		table.insert(pkBeamWeap, pkBeam)
	bestExplosion = NewExplosion("BestExplosion")
end

function update ()
	--DEMOFINAL: put each section into its own function in THIS file, if possible
	local newTime = mode_manager.time()
	dt = newTime - lastTime
	lastTime = newTime
	if printFPS == true then
		print(1 / dt) -- fps counter! whoa... o.O
	end
	
--[[------------------
	Warping Code
------------------]]-- it's a pair of lightsabers!

	if playerShip.warp.endTime ~= 0.0 then
		if newTime - playerShip.warp.endTime >= playerShip.warp.disengage then
			sound.play("WarpOut")
			playerShip.warp.endTime = 0.0
			playerShip.warp.finished = true
		end
	end
	
	if playerShip.warp.start.bool == true then
		if playerShip.warp.start.engine == false then -- once per warp init
			playerShip.warp.start.engine = true
			playerShip.warp.start.time = mode_manager.time()
		end
		if playerShip.warp.start.isStarted == true then
			if mode_manager.time() - playerShip.warp.start.time - playerShip.warp.soundNum * soundLength >= soundLength then
				playerShip.warp.start.isStarted = false
			end
		elseif playerShip.warp.start.isStarted == false then
			playerShip.warp.start.isStarted = true
			playerShip.warp.soundNum = playerShip.warp.soundNum + 1
			if playerShip.warp.soundNum <= 4 then
				sound.play("Warp" .. playerShip.warp.soundNum)
			elseif playerShip.warp.soundNum == 5 then
				sound.play("WarpIn")
				playerShip.warp.warping = true
				playerShip.warp.finished = false
				playerShip.warp.start.bool = false
			end
		end
	end
	
	if playerShip.warp.finished == false then
		playerShip.physicsObject.velocity = { x = playerShip.warpSpeed * math.cos(playerShip.physicsObject.angle), y = playerShip.warpSpeed * math.sin(playerShip.physicsObject.angle) }
	else	
		if hypot (playerShip.physicsObject.velocity.x, playerShip.physicsObject.velocity.y) > playerShip.maxSpeed then
			playerShip.physicsObject.velocity = { x = playerShip.maxSpeed * normalize(playerShip.physicsObject.velocity.x, playerShip.physicsObject.velocity.y), y = playerShip.maxSpeed * normalize(playerShip.physicsObject.velocity.y, playerShip.physicsObject.velocity.x) }
		end
	end
	
--[[------------------
	Movement
------------------]]--
	
    if keyControls.left then
        playerShip.physicsObject.angular_velocity = playerShip.turningRate
    elseif keyControls.right then
        playerShip.physicsObject.angular_velocity = -playerShip.turningRate
    else
        playerShip.physicsObject.angular_velocity = 0
    end
	
	if keyControls.forward then
        -- apply a forward force in the direction the ship is facing
        local angle = playerShip.physicsObject.angle
        local thrust = playerShip.thrust
        local force = { x = thrust * math.cos(angle), y = thrust * math.sin(angle) }
		playerShip.physicsObject:apply_force(force)
	elseif keyControls.brake then
        -- apply a reverse force in the direction opposite the direction the ship is MOVING
        local force = playerShip.physicsObject.velocity
		if force.x ~= 0 or force.y ~= 0 then
			if hypot(playerShip.physicsObject.velocity.x, playerShip.physicsObject.velocity.y) <= 10 then
				playerShip.physicsObject.velocity = { x = 0, y = 0 }
			else
				local velocityMag = hypot(force.x, force.y)
				force.x = -force.x / velocityMag
				force.y = -force.y / velocityMag
				force.x = force.x * playerShip.reverseThrust
				force.y = force.y * playerShip.reverseThrust
				playerShip.physicsObject:apply_force(force)
			end
		end
    end
	
	if showVelocity == true then
		print(playerShip.physicsObject.velocity.x)
		print(playerShip.physicsObject.velocity.y)
	end
	
--[[------------------
	C-Missile Firing
------------------]]--

	if cMissile.fired == true then
		local bulletLocation = playerShip.physicsObject.position
		if carrierExploded == false then
			--	ADAM/ALASTAIR: Why doesn't this work?
			--	for demo: leave as is, hypot works
		--	if physics.collisions(computerShip.physicsObject, cMissile.physicsObject, 1) == true then
			local x = computerShip.physicsObject.position.x - cMissile.physicsObject.position.x
			local y = computerShip.physicsObject.position.y - cMissile.physicsObject.position.y
			if hypot (x, y) <= computerShip.physicsObject.collision_radius * 2 / 7 then
				bullet_collision(cMissile, computerShip)
			end
			guide_bullet(cMissile)
			if showAngles == true then
				print(cMissile.physicsObject.angle)
				print(cMissile.theta)
				print("----------------")
			end
		end
		
		cMissile.physicsObject.angle = cMissile.physicsObject.angle + cMissile.delta
		cMissile.force.x = math.cos(cMissile.physicsObject.angle) * cMissile.thrust
		cMissile.force.y = math.sin(cMissile.physicsObject.angle) * cMissile.thrust
		cMissile.physicsObject:apply_force(cMissile.force)
	end
	
	if firebullet == true then
		if cMissile.start / 1000 + cMissile.cooldown / 1000 <= mode_manager.time() then
			fire_bullet(cMissile, playerShip)
		end
	end
	
--[[------------------
	PKBeam Firing
------------------]]--
	
	if pkBeam.firing == true then
		if pkBeam.start / 1000 + pkBeam.cooldown / 1000 <= mode_manager.time() then
			if playerShip.energy >= pkBeam.cost then
				sound.play("ShotC")
				table.insert(pkBeamWeap, pkBeam)
				playerShip.energy = playerShip.energy - pkBeam.cost
				local wNum = #pkBeamWeap
				pkBeamWeap[wNum].physicsObject.angle = playerShip.physicsObject.angle
				pkBeamWeap[wNum].physicsObject.position = { x = playerShip.physicsObject.position.x + math.cos(pkBeamWeap[wNum].physicsObject.angle) * pkBeam.length, y = playerShip.physicsObject.position.y + math.sin(pkBeamWeap[wNum].physicsObject.angle) * pkBeam.length }
				pkBeamWeap[wNum].physicsObject.velocity = { x = pkBeam.velocity.total * math.cos(pkBeamWeap[wNum].physicsObject.angle) + playerShip.physicsObject.velocity.x, y = pkBeam.velocity.total * math.sin(pkBeamWeap[wNum].physicsObject.angle) + playerShip.physicsObject.velocity.y }
				pkBeamWeap[wNum].start = mode_manager.time() * 1000
			end
		end
	end
	local num = 1
	while pkBeamWeap[num] ~= nil do
		firepkBeam(pkBeamWeap[1])
		if(
		pkBeam.age = (mode_manager.time() * 1000) - pkBeam.start
		if pkBeam.age >= pkBeam.life then
			table.remove(pkBeamWeap, num)
		end
		if carrierExploded == false then
			local x = computerShip.physicsObject.position.x - pkBeam.physicsObject.position.x
			local y = computerShip.physicsObject.position.y - pkBeam.physicsObject.position.y
			if hypot (x, y) <= computerShip.physicsObject.collision_radius * 2 / 7 then
				bullet_collision(pkBeam, computerShip)
			end
		end
		num = num + 1
	end
	
	physics.update(dt)
end

function render ()
    graphics.begin_frame()
--	print(playerShip.physicsObject.position.x)
--	print(playerShip.physicsObject.position.y)
	graphics.set_camera(-playerShip.physicsObject.position.x + shipAdjust - (camera.w / 2.0), -playerShip.physicsObject.position.y - (camera.h / 2.0), -playerShip.physicsObject.position.x + shipAdjust + (camera.w / 2.0), -playerShip.physicsObject.position.y + (camera.h / 2.0))
	graphics.draw_starfield()
	
--[[------------------
	Grid Drawing
------------------]]--
	
	local i = 0
	while i ~= 10 do
		if (i * gridDistBlue) % gridDistLightBlue == 0 then
			if (i * gridDistBlue) % gridDistGreen == 0 then
				graphics.draw_line(-6000, -i * gridDistBlue, 6000, -i * gridDistBlue, 1) -- this green
				graphics.draw_line(-6000, i * gridDistBlue, 6000, i * gridDistBlue, 1)
				graphics.draw_line(-i * gridDistBlue, -6000, -i * gridDistBlue, 6000, 1)
				graphics.draw_line(i * gridDistBlue, -6000, i * gridDistBlue, 6000, 1)
			else
				graphics.draw_line(-6000, -i * gridDistBlue, 6000, -i * gridDistBlue, 1) -- this light blue
				graphics.draw_line(-6000, i * gridDistBlue, 6000, i * gridDistBlue, 1)
				graphics.draw_line(-i * gridDistBlue, -6000, -i * gridDistBlue, 6000, 1)
				graphics.draw_line(i * gridDistBlue, -6000, i * gridDistBlue, 6000, 1)
			end
		else
			if cameraRatio ~= 1 / 16 then
				graphics.draw_line(-6000, -i * gridDistBlue, 6000, -i * gridDistBlue, 1) -- this blue
				graphics.draw_line(-6000, i * gridDistBlue, 6000, i * gridDistBlue, 1)
				graphics.draw_line(-i * gridDistBlue, -6000, -i * gridDistBlue, 6000, 1)
				graphics.draw_line(i * gridDistBlue, -6000, i * gridDistBlue, 6000, 1)
			end
		end
		i = i + 1
	end
	
--[[------------------
	Ship Drawing
------------------]]--

    if computerShip.life > 0 then
		graphics.draw_sprite("Gaitori/Carrier", carrierLocation.x, carrierLocation.y, computerShip.size.x, computerShip.size.y, carrierRotation)
    else
		if carrierExploded == false then
			if frame == 0 then
				sound.play("New/ExplosionCombo")
			end
			if frame >= 12 then
				carrierExploded = true
			else
				frame = frame + dt * 50
			end
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation.x, carrierLocation.y, bestExplosion.size.x, bestExplosion.size.y, frame / 6 * math.pi)
		end
	end
	
	graphics.draw_sprite(playerShip.image, playerShip.physicsObject.position.x, playerShip.physicsObject.position.y, playerShip.size.x, playerShip.size.y, playerShip.physicsObject.angle)
	
--[[------------------
	PKBeam Firing
------------------]]--
	
	if pkBeam.fired == true then
		graphics.draw_line(pkBeam.physicsObject.position.x, pkBeam.physicsObject.position.y, pkBeam.physicsObject.position.x - math.cos(pkBeam.physicsObject.angle) * pkBeam.length, pkBeam.physicsObject.position.y - math.sin(pkBeam.physicsObject.angle) * pkBeam.length, pkBeam.width)
	end
	
--[[------------------
	C-Missile Firing
------------------]]--
	
	if cMissile.fired == true then
		cMissile.age = (mode_manager.time() * 1000) - cMissile.start
		if cMissile.age >= cMissile.life then
			cMissile.fired = false
		end
		graphics.draw_sprite("Weapons/cMissile", cMissile.physicsObject.position.x, cMissile.physicsObject.position.y, cMissile.size.x, cMissile.size.y, cMissile.physicsObject.angle)
	end
	
--[[------------------
	Arrow and Panels
------------------]]--
	
	local angle = playerShip.physicsObject.angle
	graphics.draw_line(math.cos(arrowAlpha + angle) * arrowDist + playerShip.physicsObject.position.x, math.sin(arrowAlpha + angle) * arrowDist + playerShip.physicsObject.position.y, math.cos(angle - arrowAlpha) * arrowDist + playerShip.physicsObject.position.x, math.sin(angle - arrowAlpha) * arrowDist + playerShip.physicsObject.position.y, 1.5)
	graphics.draw_line(math.cos(angle - arrowAlpha) * arrowDist + playerShip.physicsObject.position.x, math.sin(angle - arrowAlpha) * arrowDist + playerShip.physicsObject.position.y, math.cos(angle) * (arrowLength + arrowVar) + playerShip.physicsObject.position.x, math.sin(angle) * (arrowLength + arrowVar) + playerShip.physicsObject.position.y, 1.5)
	graphics.draw_line(math.cos(angle) * (arrowLength + arrowVar) + playerShip.physicsObject.position.x, math.sin(angle) * (arrowLength + arrowVar) + playerShip.physicsObject.position.y, math.cos(arrowAlpha + angle) * arrowDist + playerShip.physicsObject.position.x, math.sin(arrowAlpha + angle) * arrowDist + playerShip.physicsObject.position.y, 1.5)
	graphics.set_camera(-500, -500, 500, 500)
	graphics.draw_image("Panels/SideLeft", -435, 0, 129, 1012)
    graphics.draw_image("Panels/SideRight", 487, -2, 27, 1020)
	graphics.end_frame()
end

function keyup ( k )
    if k == "w" then
        keyControls.forward = false
    elseif k == "s" then
        keyControls.brake = false
    elseif k == "a" then
        keyControls.left = false
    elseif k == "d" then
        keyControls.right = false
    elseif k == " " then
        pkBeam.firing = false
	elseif k == "x" then
		firepulse = false
    elseif k == "z" then
		firebullet = false
    elseif k == "tab" then
		playerShip.warp.start.bool = false
		playerShip.warp.start.time = nil
		playerShip.warp.start.engine = false
		playerShip.warp.start.isStarted = false
		playerShip.warp.soundNum = 0.0
		if playerShip.warp.warping == true then
			playerShip.warp.warping = false
			playerShip.warp.endTime = mode_manager.time()
		end
	end
end

function key ( k )
    if k == "w" then
        keyControls.forward = true
    elseif k == "s" then
        keyControls.brake = true
    elseif k == "a" then
        keyControls.left = true
    elseif k == "d" then
        keyControls.right = true
	elseif k == "r" then
		showVelocity = true
	elseif k == "t" then
		showVelocity = false
	elseif k == "y" then
		if cameraRatio ~= 2 then
			cameraRatio = cameraRatio * 2
			if cameraRatio == 1 / 8 then -- there is no 1:8, make it 1:4
				cameraRatio = cameraRatio * 2
				arrowLength = arrowLength / 2
				arrowVar = arrowVar / 2
				arrowDist = arrowDist / 2
			end
			camera = { w = 640 / cameraRatio, h }
			camera.h = camera.w / aspectRatio
			shipAdjust = .045 * camera.w
			arrowLength = arrowLength / 2
			arrowVar = arrowVar / 2
			arrowDist = arrowDist / 2
			pkBeam.width = cameraRatio
		end
	elseif k == "h" then
		if cameraRatio ~= 1 / 16 then
			cameraRatio = cameraRatio / 2
			if cameraRatio == 1 / 8 then -- there is no 1:8, make it 1:16
				cameraRatio = cameraRatio / 2
				arrowLength = arrowLength * 2
				arrowVar = arrowVar * 2
				arrowDist = arrowDist * 2
			end
			camera = { w = 640 / cameraRatio, h }
			camera.h = camera.w / aspectRatio
			shipAdjust = .045 * camera.w
			arrowLength = arrowLength * 2
			arrowVar = arrowVar * 2
			arrowDist = arrowDist * 2
			pkBeam.width = cameraRatio
		end
	--[[ temporarily commented (currently unnecessary)
	elseif k == "l" then
		playerShip.physicsObject.angle = 0
	elseif k == "i" then
		playerShip.physicsObject.angle = math.pi / 2
	elseif k == "j" then
		playerShip.physicsObject.angle = math.pi
	elseif k == "k" then
		playerShip.physicsObject.angle = 3 * math.pi / 2
	--]]
	elseif k == "tab" then
		playerShip.warp.start.bool = true
	elseif k == " " then
		if playerShip.beamName ~= nil then
			pkBeam.firing = true
		end
	-- ALASTAIR: Please investigate why firing the pkBeam makes the screen flash...
	elseif k == "x" then
		if playerShip.pulseName ~= nil then
			firepulse = true
		end
	elseif k == "z" then
		if playerShip.specialName ~= nil then
			firebullet = true
		end
	elseif k == "p" then
		computerShip.life = 0
	elseif k == "escape" then
		mode_manager.switch("MainMenu")
	end
end

function quit ()
    physics.close()
end