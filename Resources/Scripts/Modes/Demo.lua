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
camera = { w = 640 / cameraRatio, h = 0 }
camera.h = camera.w / aspectRatio
local shipAdjust = .045 * camera.w


--tempvars
carrierLocation = { x = 2200, y = 2700 }
carrierRotation = math.pi / 2
carrierExploded = false
firebullet = false
firepulse = false
drawShot = false
showVelocity = false
showAngles = false
--/tempvars


playerShip = nil
cMissile = nil
pkBeam = nil
bestExplosion = nil

local warp = { warping = false, length = 0.5, start = { bool = false, time = 0.0, engine = false, sound = false }, endTime = 0.0, disengage = 2.0, finished = true, soundNum = 0 }
local soundLength = 0.5

local arrowLength = 135
local arrowVar = (3 * math.sqrt(3))
local arrowDist = hypot(6, (arrowLength - arrowVar))
local arrowAlpha = math.atan2(6, arrowDist)
local gridDistBlue = 300
local gridDistLightBlue = 1200
local gridDistGreen = 4800

keyControls = { left = false, right = false, forward = false, brake = false }

function fire_bullet()
--[[ here's what this function should look like when finished:
1- Find all possible targets in missile range
2- Select best target and seek it
(Update with new target if necessary when updating?)
--]]
	if playerShip.special.ammo > 0 then
		playerShip.special.ammo = playerShip.special.ammo - 1
		sound.play("RocketLaunchr")
		-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included for troubleshooting)
		cMissile.isSeeking = should_seek()
		cMissile.location = { x, y }
		cMissile.physicsObject.position = playerShip.physicsObject.position
		cMissile.physicsObject.angle = playerShip.physicsObject.angle
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
		
		if math.abs(cMissile.delta) > cMissile.turningRate then
			if cMissile.delta > cMissile.turningRrate then
				cMissile.delta = -cMissile.turningRate / dt
			else
				cMissile.delta = cMissile.turningRate / dt
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

function init ()
	sound.stop_music()
    lastTime = mode_manager.time()
    physics.open(0.6)
    playerShip = NewShip("Ishiman/HeavyCruiser")
		playerShip.energy = 50000
	computerShip = NewShip("Gaitori/Carrier")
	cMissile = NewBullet("cMissile")
		cMissile.dest = { x = carrierLocation.x, y = carrierLocation.y }
		cMissile.size = { x, y }
		cMissile.size.x, cMissile.size.y = graphics.sprite_dimensions("Weapons/cMissile")
		cMissile.isSeeking = true
		cMissile.fired = false
		cMissile.start = 0
		cMissile.force = { x, y }
	pkBeam = NewBullet("PKBeam")
		pkBeam.width = cameraRatio
		pkBeam.fired = false
		pkBeam.length = 30
		pkBeam.location = { x, y }
		pkBeam.start = 0
		pkBeam.firing = false
	bestExplosion = NewExplosion("BestExplosion")
end

function update ()
	--DEMOFINAL: put each section into its own function in THIS file, if possible
	local newTime = mode_manager.time()
	dt = newTime - lastTime
	lastTime = newTime
--	print(1 / dt) -- fps counter! whoa... o.O
	
--[[------------------
	Warping Code
------------------]]-- it's a pair of lightsabers!

	if warp.endTime ~= 0.0 then -- temporary code while I wait to be able to use deceleration...
		if newTime - warp.endTime >= warp.disengage then
			warp.endTime = 0.0
			sound.play("WarpOut")
			warp.finished = true
		end
	end
	
	if warp.start.bool == true then
		if warp.start.engine == false then -- once per warp init
			warp.start.engine = true
			warp.start.time = mode_manager.time()
		end
		if warp.start.isStarted == true then
			if mode_manager.time() - warp.start.time - warp.soundNum * soundLength >= soundLength then
				warp.start.isStarted = false
			end
		elseif warp.start.isStarted == false then
			warp.start.isStarted = true
			warp.soundNum = warp.soundNum + 1
			if warp.soundNum <= 4 then
				sound.play("Warp" .. warp.soundNum)
			elseif warp.soundNum == 5 then
				sound.play("WarpIn")
				warp.warping = true
				warp.finished = false
				warp.start.bool = false
			end
		end
	end
	
	if warp.finished == false then
		playerShip.physicsObject.velocity = { x = playerShip.warpSpeed * math.cos(playerShip.physicsObject.angle), y = playerShip.warpSpeed * math.sin(playerShip.physicsObject.angle) }
	else	
		if hypot (playerShip.physicsObject.velocity.x, playerShip.physicsObject.velocity.y) > playerShip.maxSpeed then
			local xNorm = normalize(playerShip.physicsObject.velocity.x, playerShip.physicsObject.velocity.y)
			local yNorm = normalize(playerShip.physicsObject.velocity.y, playerShip.physicsObject.velocity.x)
			playerShip.physicsObject.velocity = { x = playerShip.maxSpeed * xNorm, y = playerShip.maxSpeed * yNorm }
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
			if hypot(playerShip.physicsObject.velocity.x, playerShip.physicsObject.velocity.y) <= 1 then
				playerShip.physicsObject.velocity = { x = 0, y = 0 }
			else
				local velocityMag = hypot(force.x, force.y)
				force.x = -force.x / velocityMag
				force.y = -force.y / velocityMag
				local thrust = playerShip.reverseThrust
				force.x = force.x * thrust
				force.y = force.y * thrust
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
		--[[ not yet implemented
		for playerShip, cMissile in physics.collisions() do
			bullet_collision(cMissile, computerShip)
		end
		--]]	
		cMissile.theta = find_angle(cMissile.physicsObject.position, cMissile.dest)
		if showAngles == true then
			print(cMissile.physicsObject.angle)
			print(cMissile.delta)
			print(cMissile.theta)
			print("________________")
		end
		if cMissile.physicsObject.angle ~= cMissile.theta then
			guide_bullet()
			cMissile.theta = cMissile.theta + cMissile.delta
		end
		
		cMissile.force.x = math.cos(cMissile.physicsObject.angle) * cMissile.thrust
		cMissile.force.y = math.sin(cMissile.physicsObject.angle) * cMissile.thrust
		cMissile.physicsObject.angle = cMissile.theta
		cMissile.physicsObject:apply_force(cMissile.force)
	end
	
	if firebullet == true then
		if cMissile.start / 1000 + cMissile.cooldown / 1000 <= mode_manager.time() then
			cMissile.start = mode_manager.time() * 1000
			fire_bullet()
			cMissile.fired = true
		end
	end
	
--[[------------------
	PKBeam Firing
------------------]]--
	
	if pkBeam.firing == true then
		if pkBeam.start / 1000 + pkBeam.cooldown / 1000 <= mode_manager.time() then
			if playerShip.energy >= 10 then
				playerShip.energy = playerShip.energy - 10
				sound.play("ShotC")
				drawShot = true
			end
		end
	end
	
	physics.update(dt)
end

function render ()
	local angle = playerShip.physicsObject.angle
    graphics.begin_frame()
	graphics.set_camera(-playerShip.physicsObject.position.x + shipAdjust - (camera.w / 2.0), -playerShip.physicsObject.position.y - (camera.h / 2.0), -playerShip.physicsObject.position.x + shipAdjust + (camera.w / 2.0), -playerShip.physicsObject.position.y + (camera.h / 2.0))
--	print(playerShip.physicsObject.position.x)
--	print(playerShip.physicsObject.position.y)
	graphics.draw_starfield()
	
--[[------------------
	Grid Drawing
------------------]]--
	
	local i = 0
	while i ~= 10 do
		if (i * gridDistBlue) % gridDistLightBlue == 0 then
			if (i * gridDistBlue) % gridDistGreen == 0 then
				graphics.draw_line(-6000, -i * gridDistBlue, 6000, -i * gridDistBlue, 1)
				graphics.draw_line(-6000, i * gridDistBlue, 6000, i * gridDistBlue, 1)
				graphics.draw_line(-i * gridDistBlue, -6000, -i * gridDistBlue, 6000, 1)
				graphics.draw_line(i * gridDistBlue, -6000, i * gridDistBlue, 6000, 1)
			else
				graphics.draw_line(-6000, -i * gridDistBlue, 6000, -i * gridDistBlue, 1)
				graphics.draw_line(-6000, i * gridDistBlue, 6000, i * gridDistBlue, 1)
				graphics.draw_line(-i * gridDistBlue, -6000, -i * gridDistBlue, 6000, 1)
				graphics.draw_line(i * gridDistBlue, -6000, i * gridDistBlue, 6000, 1)
			end
		else
			if cameraRatio ~= 1 / 16 then
				graphics.draw_line(-6000, -i * gridDistBlue, 6000, -i * gridDistBlue, 1)
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

    if computerShip.life ~= 0 then
		graphics.draw_sprite("Gaitori/Carrier", carrierLocation.x, carrierLocation.y, computerShip.size.x, computerShip.size.y, carrierRotation)
    else
		if carrierExploded == false then
			if frame == 0 then
				sound.play("New/ExplosionCombo")
			end
			if frame == 12 then
				carrierExploded = true
			else
				frame = frame + 0.5
			end
			graphics.draw_sprite("Explosions/BestExplosion", carrierLocation.x, carrierLocation.y, bestExplosion.size.x, bestExplosion.size.y, frame / 6 * math.pi)
		end
	end
	graphics.draw_sprite(playerShip.image, playerShip.physicsObject.position.x, playerShip.physicsObject.position.y, playerShip.size.x, playerShip.size.y, playerShip.physicsObject.angle)
	
--[[------------------
	PKBeam Firing
------------------]]--
	
	if pkBeam.fired == true then
		pkBeam.age = (mode_manager.time() * 1000) - pkBeam.start
		if pkBeam.age >= pkBeam.life then
			pkBeam.fired = false
		end
		--[[ not yet implemented
		for pkBeam, playerShip in physics.collisions() do
			bullet_collision(pkBeam, playerShip)
		end
		--]]
		graphics.draw_line(pkBeam.location.x + math.cos(pkBeam.angle) * pkBeam.age, pkBeam.location.y + math.sin(pkBeam.angle) * pkBeam.age, pkBeam.location.x + math.cos(pkBeam.angle) * (pkBeam.length + pkBeam.age), pkBeam.location.y + math.sin(pkBeam.angle) * (pkBeam.length + pkBeam.age), pkBeam.width)
	end
	
	if drawShot == true then
		pkBeam.start = mode_manager.time() * 1000
		pkBeam.angle = playerShip.physicsObject.angle
		pkBeam.location.x = playerShip.physicsObject.position.x + math.cos(pkBeam.angle) * pkBeam.length
		pkBeam.location.y = playerShip.physicsObject.position.y + math.sin(pkBeam.angle) * pkBeam.length
		graphics.draw_line(pkBeam.location.x, pkBeam.location.y, pkBeam.location.x + math.cos(angle) * (pkBeam.length / 2), pkBeam.location.y + math.sin(angle) * (pkBeam.length / 2), pkBeam.width)
		drawShot = false
		pkBeam.fired = true
	end
	
--[[------------------
	C-Missile Firing
------------------]]--
	
	if cMissile.fired == true then
		graphics.draw_sprite("Weapons/cMissile", cMissile.physicsObject.position.x, cMissile.physicsObject.position.y, cMissile.size.x, cMissile.size.y, cMissile.physicsObject.angle)
	end
	
--[[------------------
	Panels and Arrow
------------------]]--
	
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
		warp.start.bool = false
		warp.start.time = nil
		warp.start.engine = false
		warp.start.isStarted = false
		soundLength = 0.25
		warp.soundNum = 0.0
		if warp.warping == true then
			warp.warping = false
			warp.endTime = mode_manager.time()
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
			camera = { w = 640 / cameraRatio, h = 0 }
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
			camera = { w = 640 / cameraRatio, h = 0 }
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
		warp.start.bool = true
	elseif k == " " then
		if playerShip.beamName ~= nil then
			pkBeam.firing = true
		end
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