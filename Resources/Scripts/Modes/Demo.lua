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
import('Bullet4Demo')
import('MouseHandle')

local cameraRatio = 1
local aspectRatio = 4 / 3
camera = { w = 640 / cameraRatio, h = 0 }
camera.h = camera.w / aspectRatio
local shipAdjust = .045 * camera.w


--tempvars
carrierLocation = { x = 2200, y = 2700 }
carrierRotation = math.pi / 2
carrierHealth = 10
carrierExploded = false
firebullet = false
--/tempvars


playerShip = nil
cMissile = nil
pkBeam = nil
bestExplosion = nil

local warpStart = false
local startTime = 0.0
local startEngine = false
local soundStarted = false
local timeSinceStart = 0.0
local soundLength = 0.5
local soundNum = 0
local warping = false
local endWarp = 0.0
local warpSlow = 2.0
local warpSpeed = 2.0

drawShot = false
shot = { x = 0, y = 0, rotate = 0, timeStart = 0, fired = false, length = 30 }

local arrowLength = 125
local arrowVar = (3.5 * math.sqrt(3))
local arrowDist = hypot(7, (arrowLength - arrowVar))
local arrowAlpha = math.atan2(7, arrowDist)

keyControls = { left = false, right = false, forward = false, brake = false }

function init ()
	sound.stop_music()
    lastTime = mode_manager.time()
    physics.open(0.6)
    playerShip = NewShip("Ishiman/HeavyCruiser")
	computerShip = NewShip("Gaitori/Carrier")
	cMissile = NewBullet("WhiteYellowMissile")
		cMissile.dest = { x = carrierLocation.x, y = carrierLocation.y }
		cMissile.size = { x, y }
		cMissile.size.x, cMissile.size.y = graphics.sprite_dimensions("Weapons/WhiteYellowMissile")
		cMissile.isSeeking = true
		cMissile.fired = false
	pkBeam = NewBullet("PKBeam")
		pkBeam.width = 3 * cameraRatio;
	bestExplosion = NewExplosion("BestExplosion")
end

function update ()
	--DEMOFINAL: put each section into its own function in THIS file, if possible
	local newTime = mode_manager.time()
	local dt = newTime - lastTime
	lastTime = newTime
	
--[[------------------
	Warping Code
------------------]]-- it's a pair of lightsabers!

	if endWarp ~= 0.0 then -- temporary code while I wait to be able to use deceleration...
		if newTime - endWarp >= warpSlow then
			endWarp = 0.0
			sound.play("WarpOut")
		end
	end
	
	if warpStart == true then
		if startEngine == false then -- once per warp init
			startEngine = true
			startTime = mode_manager.time()
		end
		timeSinceStart = mode_manager.time() - startTime
		if soundStarted == true then
			if timeSinceStart - soundNum * soundLength >= soundLength then
				soundStarted = false
			end
		elseif soundStarted == false then
			soundStarted = true
			soundNum = soundNum + 1
			if soundNum <= 4 then
				sound.play("Warp" .. soundNum)
			elseif soundNum == 5 then
				sound.play("WarpIn")
				warping = true
				warpStart = false
			end
		end
	end
	
	if warping == true then
		local velocity = { x = warpSpeed * math.cos(playerShip.physicsObject.angle), y = warpSpeed * math.sin(playerShip.physicsObject.angle) }
	--	playerShip.physicsObject:apply_force(force)
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
	--	playerShip.physicsObject:apply_force(force)
	elseif keyControls.brake then
        -- apply a reverse force in the direction opposite the direction the ship is MOVING
        local velocityVector = playerShip.physicsObject.velocity
		if velocityVector.x ~= 0 or velocityVector.y ~= 0 then
			local velocityMag = hypot(velocityVector.x, velocityVector.y)
			velocityVector.x = -velocityVector.x / velocityMag
			velocityVector.y = -velocityVector.y / velocityMag
			local thrust = playerShip.reverseThrust
			velocityVector.x = velocityVector.x * thrust
			velocityVector.y = velocityVector.y * thrust
		--	playerShip.physicsObject:apply_force(velocityVector)
		end
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
		print(cMissile.physicsObject.angle)
		print(cMissile.delta)
		print(cMissile.theta)
		print("________________")
		
		if cMissile.physicsObject.angle ~= cMissile.theta then
			guide_bullet()
		end
		
	--	cMissile.force.x = math.cos(cMissile.theta) * cMissile.thrust
	--	cMissile.force.y = math.sin(cMissile.theta) * cMissile.thrust
	end
	
	if firebullet == true then
		fire_bullet()
		firebullet = false
		cMissile.fired = true
	end
	
	physics.update(dt)
end

function render ()
	local angle = playerShip.physicsObject.angle
    graphics.begin_frame()
	graphics.set_camera(playerShip.physicsObject.position.x + shipAdjust - (camera.w / 2.0), playerShip.physicsObject.position.y - (camera.h / 2.0), playerShip.physicsObject.position.x + shipAdjust + (camera.w / 2.0), playerShip.physicsObject.position.y + (camera.h / 2.0))
--	print(playerShip.physicsObject.position.x)
--	print(playerShip.physicsObject.position.y)
	graphics.draw_starfield()
    if carrierHealth ~= 0 then
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
	
	if shot.fired == true then
		pkBeam.age = (mode_manager.time() * 1000) - pkBeam.start
		if pkBeam.age >= pkBeam.life then
			shot.fired = false
		end
	--	for pkBeam, playerShip in physics.collisions() do
	--		bullet_collision(pkBeam, playerShip)
	--	end
		graphics.draw_line(shot.x + math.cos(pkBeam.angle) * pkBeam.age, shot.y + math.sin(pkBeam.angle) * pkBeam.age, shot.x + math.cos(pkBeam.angle) * (shot.length + pkBeam.age), shot.y + math.sin(pkBeam.angle) * (shot.length + pkBeam.age), pkBeam.width)
	end
	
	if drawShot == true then
		pkBeam.start = mode_manager.time() * 1000
		pkBeam.angle = playerShip.physicsObject.angle
		shot.x = playerShip.physicsObject.position.x + math.cos(pkBeam.angle) * shot.length
		shot.y = playerShip.physicsObject.position.y + math.sin(pkBeam.angle) * shot.length
		graphics.draw_line(shot.x, shot.y, shot.x + math.cos(angle) * (shot.length / 2), shot.y + math.sin(angle) * (shot.length / 2), 2)
		drawShot = false
		shot.fired = true
	end
	
	if cMissile.fired == true then
		local bulletLocation = cMissile.physicsObject.position
		graphics.draw_sprite("Weapons/WhiteYellowMissile", bulletLocation.x, bulletLocation.y, cMissile.size.x, cMissile.size.y, cMissile.physicsObject.angle)
	end
	
	graphics.draw_line(math.cos(arrowAlpha + angle) * arrowDist, math.sin(arrowAlpha + angle) * arrowDist, math.cos(angle - arrowAlpha) * arrowDist, math.sin(angle - arrowAlpha) * arrowDist, 2)
	graphics.draw_line(math.cos(angle - arrowAlpha) * arrowDist, math.sin(angle - arrowAlpha) * arrowDist, math.cos(angle) * (arrowLength + arrowVar), math.sin(angle) * (arrowLength + arrowVar), 2)
	graphics.draw_line(math.cos(angle) * (arrowLength + arrowVar), math.sin(angle) * (arrowLength + arrowVar), math.cos(arrowAlpha + angle) * arrowDist, math.sin(arrowAlpha + angle) * arrowDist, 2)
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
    elseif k == "tab" then
		warpStart = false
		startTime = nil
		startEngine = false
		soundStarted = false
		timeSinceStart = 0.0
		soundLength = 0.25
		soundNum = 0.0
		if warping == true then
			warping = false
			endWarp = mode_manager.time()
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
	elseif k == "z" then
		firebullet = true
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
			pkBeam.width = 3 * cameraRatio;
			if pkBeam.width < 1 then
				pkBeam.width = 1
			end
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
			pkBeam.width = 3 * cameraRatio;
			if pkBeam.width < 1 then
				pkBeam.width = 1
			end
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
		warpStart = true
	elseif k == " " then
		sound.play("ShotC")
		drawShot = true
	elseif k == "p" then
		carrierHealth = 0
	elseif k == "escape" then
		mode_manager.switch("MainMenu")
	end
end

function quit ()
    physics.close()
end