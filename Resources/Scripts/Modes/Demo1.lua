-- demo script: Player is Ishiman Heavy Cruiser, opponent is Gaitori Carrier.
-- Carrier has no AI, so it just sits there. Player must warp to Carrier's position
-- and can destroy it using both seeking and non-seeking weapons. Script ends when
-- Carrier is destroyed.

import('EntityLoad')
import('Math')

local cameraRatio = 1
local aspectRatio = 4 / 3
camera = { w = 640 / cameraRatio, h }
camera.h = camera.w / aspectRatio
local shipAdjust = .045 * camera.w

firepulse = false
showVelocity = false
showAngles = false
frame = 0
printFPS = false
waitTime = 0.0
local soundLength = 0.25
local arrowLength = 135
local arrowVar = (3 * math.sqrt(3))
local arrowDist = hypot(6, (arrowLength - arrowVar))
local arrowAlpha = math.atan2(6, arrowDist)
local gridDistBlue = 300
local gridDistLightBlue = 2400
local gridDistGreen = 4800

keyControls = { left = false, right = false, forward = false, brake = false }

--[[----------------------------
	--{{--------------------
		Bullet Collision
	--------------------}}--
----------------------------]]--

function bullet_collision(bulletObject, bNum, bulletData, shipObject)
	table.remove(bulletObject, bNum)
	shipObject.life = shipObject.life - bulletData.damage
end

--[[--------------------------
	--{{------------------
		Initialization
	------------------}}--
--------------------------]]--

-- ALISTAIR: REQUEST: could init run BEFORE update, and not simultaneously with it?
-- When that's done, I'll re-add computerShip to init
	computerShip = NewShip("Gaitori/Carrier")
		computerShip.physicsObject.position = { x = 2200, y = 2700 }
		computerShip.physicsObject.angle = math.pi - 0.2
		computerShip.exploded = false

function init ()
	sound.stop_music()
    lastTime = mode_manager.time()
    physics.open(0.6)
    playerShip = NewShip("Ishiman/HeavyCruiser")
		playerShip.warp = { warping = false, start = { bool = false, time = nil, engine = false, sound = false, isStarted = false }, endTime = 0.0, disengage = 2.0, finished = true, soundNum = 0 }
		playerShip.switch = true
		playerShip.cMissile = NewBullet("cMissile", playerShip)
			playerShip.cMissile.delta = 0.0
			playerShip.cMissile.dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
			playerShip.cMissile.size = { x, y }
			playerShip.cMissile.size.x, playerShip.cMissile.size.y = graphics.sprite_dimensions("Weapons/cMissile")
			playerShip.cMissile.fired = false
			playerShip.cMissile.start = 0
			playerShip.cMissile.force = { x, y }
		playerShip.cMissileWeap = { { {} } }
		table.remove(playerShip.cMissileWeap, 1)
		playerShip.pkBeam = NewBullet("PKBeam", playerShip)
			playerShip.pkBeam.width = cameraRatio
			playerShip.pkBeam.fired = false
			playerShip.pkBeam.start = 0
			playerShip.pkBeam.firing = false
		playerShip.pkBeamWeap = { { {} } }
		table.remove(playerShip.pkBeamWeap, 1)
	bestExplosion = NewExplosion("BestExplosion")
end

--[[--------------------
	--{{------------
		Updating
	------------}}--
--------------------]]--

function update ()
	local newTime = mode_manager.time()
	dt = newTime - lastTime
	lastTime = newTime
	if printFPS == true then
		print(1 / dt) -- fps counter! whoa... o.O
	end
	
	-- victory condition
	if computerShip.exploded == true then
		waitTime = waitTime + dt
		if waitTime >= 2.5 then
			mode_manager.switch("Credits")
		end
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
	
	weapon_manage(playerShip.cMissile, playerShip.cMissileWeap, playerShip)
	--seeking code
	local wNum = 1
	while wNum <= playerShip.cMissile.max_bullets do
		if playerShip.cMissileWeap[wNum] ~= nil then
			if playerShip.cMissileWeap[wNum].isSeeking == true then
				playerShip.cMissileWeap[wNum].theta = find_angle(playerShip.cMissileWeap[wNum].physicsObject.position, playerShip.cMissile.dest)
				if playerShip.cMissileWeap[wNum].physicsObject.angle ~= playerShip.cMissileWeap[wNum].theta then
					playerShip.cMissileWeap[wNum].delta = playerShip.cMissileWeap[wNum].theta - playerShip.cMissileWeap[wNum].physicsObject.angle
					if math.abs(playerShip.cMissileWeap[wNum].delta) > math.pi then -- need to go through 0
						if playerShip.cMissileWeap[wNum].delta > 0.0 then
							playerShip.cMissileWeap[wNum].delta = 2 * math.pi - playerShip.cMissileWeap[wNum].delta
						else
							playerShip.cMissileWeap[wNum].delta = 2 * math.pi + playerShip.cMissileWeap[wNum].delta
						end
					end
					if math.abs(playerShip.cMissileWeap[wNum].delta) > playerShip.cMissileWeap[wNum].turningRate * dt then
						if playerShip.cMissileWeap[wNum].delta > playerShip.cMissileWeap[wNum].turningRate * dt then
							playerShip.cMissileWeap[wNum].delta = -playerShip.cMissileWeap[wNum].turningRate * dt
						else
							playerShip.cMissileWeap[wNum].delta = playerShip.cMissileWeap[wNum].turningRate * dt
						end
					end
				else
					playerShip.cMissileWeap[wNum].delta = 0.0
				end
			else
				playerShip.cMissileWeap[wNum].delta = 0.0
			end
			playerShip.cMissileWeap[wNum].physicsObject.angle = playerShip.cMissileWeap[wNum].physicsObject.angle + playerShip.cMissileWeap[wNum].delta
			playerShip.cMissileWeap[wNum].force = { x = math.cos(playerShip.cMissileWeap[wNum].physicsObject.angle) * playerShip.cMissile.thrust / playerShip.cMissile.physicsObject.mass, y = math.sin(playerShip.cMissileWeap[wNum].physicsObject.angle) * playerShip.cMissile.thrust / playerShip.cMissile.physicsObject.mass }
			playerShip.cMissileWeap[wNum].physicsObject:apply_force(playerShip.cMissileWeap[wNum].force)
			if showAngles == true then
				print("For cMissile #" .. wNum .. ":")
				print(playerShip.cMissileWeap[wNum].physicsObject.angle)
				print(playerShip.cMissileWeap[wNum].theta)
				print(playerShip.cMissileWeap[wNum].delta)
				print("----------------")
			end
			wNum = playerShip.cMissile.max_bullets
		end
		wNum = wNum + 1
	end
	--/seeking code
	
-- PKBeam Firing
	
	weapon_manage(playerShip.pkBeam, playerShip.pkBeamWeap, playerShip)
	
	physics.update(dt)
end

--[[-------------------------
	--{{-----------------
		Weapon Firing
	-----------------}}--
-------------------------]]--

function weapon_manage(weapon, weapData, weapOwner)
-- handling of new projectile	
	if weapon.firing == true then
		local wNum = 0
		if weapon.class == "beam" then
			if playerShip.energy < weapon.cost then
				return
			end
		elseif weapon.class == "pulse" then
			return
		elseif weapon.class == "special" then
			if weapOwner.special.ammo == 0 then
				return
			end
		end
		
		if weapon.start / 1000 + weapon.cooldown / 1000 <= mode_manager.time() then
			local cNum -- current number (for when wNum gets wiped)
			sound.play(weapon.sound)
			weapon.start = mode_manager.time() * 1000
			weapon.fired = true
			wNum = 1
			while wNum <= weapon.max_bullets do
				if weapData[wNum] == nil then
					-- I would rather load from memory, but we don't have a function that preloads yet. Oh well. [DEMO2, ADAM, ALISTAIR]
					weapData[wNum] = NewBullet(weapon.shortName, weapOwner)
					if weapon.class ~= "special" then
						weapData[wNum].physicsObject.angle = weapOwner.physicsObject.angle
						if weapOwner.switch == true then
							weapData[wNum].physicsObject.position = { x = playerShip.physicsObject.position.x + math.cos(weapData[wNum].physicsObject.angle + 0.17) * (weapon.length - 3), y = playerShip.physicsObject.position.y + math.sin(weapData[wNum].physicsObject.angle + 0.17) * (weapon.length - 3) }
							weapOwner.switch = false
						else
							weapData[wNum].physicsObject.position = { x = playerShip.physicsObject.position.x + math.cos(weapData[wNum].physicsObject.angle - 0.17) * (weapon.length - 3), y = playerShip.physicsObject.position.y + math.sin(weapData[wNum].physicsObject.angle - 0.17) * (weapon.length - 3) }
							weapOwner.switch = true
						end
						weapData[wNum].physicsObject.velocity = { x = weapon.velocity.total * math.cos(weapData[wNum].physicsObject.angle) + playerShip.physicsObject.velocity.x, y = weapon.velocity.total * math.sin(weapData[wNum].physicsObject.angle) + playerShip.physicsObject.velocity.y }
					else
						weapData[wNum].dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
						weapData[wNum].physicsObject.angle = playerShip.physicsObject.angle
						weapData[wNum].physicsObject.position = { x = playerShip.physicsObject.position.x, y = playerShip.physicsObject.position.y }
						weapData[wNum].physicsObject.velocity = { x = playerShip.physicsObject.velocity.x, y = playerShip.physicsObject.velocity.y }
					end
					weapData[wNum].start = mode_manager.time() * 1000
					cNum = wNum
					wNum = weapon.max_bullets -- exit while loop
				end
				wNum = wNum + 1
			end
			
			-- weapon fired, take away cost (and seek if necessary)
			if weapon.class == "beam" then
				playerShip.energy = playerShip.energy - weapon.cost
			elseif weapon.class == "pulse" then
				return
			elseif weapon.class == "special" then
				weapOwner.special.ammo = weapOwner.special.ammo - 1
				sound.play("RocketLaunchr")
				-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included for troubleshooting)
				if computerShip.exploded == true then
					weapData[cNum].isSeeking = false
				end
				
				if weapData[cNum].isSeeking == true then
					local bulletTravel = { x, y, dist }
					bulletTravel.dist = (weapData[cNum].thrust * weapon.life * weapon.life / 1000000) / (2 * weapData[cNum].physicsObject.mass)
					bulletTravel.x = math.cos(weapData[cNum].physicsObject.angle) * (bulletTravel.dist + weapData[cNum].physicsObject.velocity.x)
					bulletTravel.y = math.sin(weapData[cNum].physicsObject.angle) * (bulletTravel.dist + weapData[cNum].physicsObject.velocity.y)
					if find_hypot(weapData[cNum].physicsObject.position, weapData[cNum].dest) <= hypot(bulletTravel.x, bulletTravel.y) then
						if showAngles == true then
							print(find_angle(weapData[cNum].dest, weapData[cNum].physicsObject.position))
							print(weapData[cNum].physicsObject.angle)
							print(find_angle(weapData[cNum].dest, weapData[cNum].physicsObject.position) - weapData[cNum].physicsObject.angle)
						end
						local angle = find_angle(weapData[cNum].dest, weapData[cNum].physicsObject.position) - weapData[cNum].physicsObject.angle
						if math.abs(angle) > math.pi then -- need to go through 0
							if angle > 0.0 then
								angle = 2 * math.pi - angle
							else
								angle = 2 * math.pi + angle
							end
						end
						if math.abs(angle) > weapon.maxSeek then
							weapData[cNum].isSeeking = false
						end
					else
						weapData[cNum].isSeeking = false
					end
				else
					weapData[cNum].isSeeking = false
				end
			end
		end
	end
	
-- handling for collisions and age

	wNum = 1
	while wNum <= weapon.max_bullets do
		if weapData[wNum] ~= nil then
			if computerShip.exploded == false then
				local x = computerShip.physicsObject.position.x - weapData[wNum].physicsObject.position.x
				local y = computerShip.physicsObject.position.y - weapData[wNum].physicsObject.position.y
				if hypot (x, y) <= computerShip.physicsObject.collision_radius * 2 / 7 then
					bullet_collision(weapData, wNum, weapon, computerShip)
					return
				end
			end
			if (mode_manager.time() * 1000) - weapData[wNum].start >= weapon.life then
				table.remove(weapData, wNum)
				if weapData[1] ~= nil then
					weapon.fired = true
				else
					weapon.fired = false
				end
			end
		end
		wNum = wNum + 1
	end
end

--[[---------------------
	--{{-------------
		Rendering
	-------------}}--
---------------------]]--

function render ()
    graphics.begin_frame()
--	print(playerShip.physicsObject.position.x)
--	print(playerShip.physicsObject.position.y)
	graphics.set_camera(-playerShip.physicsObject.position.x + shipAdjust - (camera.w / 2.0), -playerShip.physicsObject.position.y - (camera.h / 2.0), -playerShip.physicsObject.position.x + shipAdjust + (camera.w / 2.0), -playerShip.physicsObject.position.y + (camera.h / 2.0))
	graphics.draw_starfield(0.4)
	--graphics.draw_starfield(0.0)
	graphics.draw_starfield(-0.5)
	
--[[------------------
	Grid Drawing
------------------]]--
	
	local i = 0
	while i ~= 500 do
		if (i * gridDistBlue) % gridDistLightBlue == 0 then
			if (i * gridDistBlue) % gridDistGreen == 0 then
				graphics.draw_line(-60000, -i * gridDistBlue, 60000, -i * gridDistBlue, 1, 0.1, 0.7, 0.1, 1) -- this green
				graphics.draw_line(-60000, i * gridDistBlue, 60000, i * gridDistBlue, 1, 0.1, 0.7, 0.1, 1)
				graphics.draw_line(-i * gridDistBlue, -60000, -i * gridDistBlue, 60000, 1, 0.1, 0.7, 0.1, 1)
				graphics.draw_line(i * gridDistBlue, -60000, i * gridDistBlue, 60000, 1, 0.1, 0.7, 0.1, 1)
			else
				graphics.draw_line(-60000, -i * gridDistBlue, 60000, -i * gridDistBlue, 1, 0.1, 0.1, 0.8, 1) -- this light blue
				graphics.draw_line(-60000, i * gridDistBlue, 60000, i * gridDistBlue, 1, 0.1, 0.1, 0.8, 1)
				graphics.draw_line(-i * gridDistBlue, -60000, -i * gridDistBlue, 60000, 1, 0.1, 0.1, 0.8, 1)
				graphics.draw_line(i * gridDistBlue, -60000, i * gridDistBlue, 60000, 1, 0.1, 0.1, 0.8, 1)
			end
		else
			if cameraRatio ~= 1 / 16 then
				graphics.draw_line(-60000, -i * gridDistBlue, 60000, -i * gridDistBlue, 1, 0.0, 0.0, 0.65, 1) -- this blue
				graphics.draw_line(-60000, i * gridDistBlue, 60000, i * gridDistBlue, 1, 0.0, 0.0, 0.65, 1)
				graphics.draw_line(-i * gridDistBlue, -60000, -i * gridDistBlue, 60000, 1, 0.0, 0.0, 0.65, 1)
				graphics.draw_line(i * gridDistBlue, -60000, i * gridDistBlue, 60000, 1, 0.0, 0.0, 0.65, 1)
			end
		end
		i = i + 1
	end
	
--[[------------------
	Ship Drawing
------------------]]--

    if computerShip.life > 0 then
		graphics.draw_sprite("Gaitori/Carrier", computerShip.physicsObject.position.x, computerShip.physicsObject.position.y, computerShip.size.x, computerShip.size.y, computerShip.physicsObject.angle)
    else
		if computerShip.exploded == false then
			if frame == 0 then
				sound.play("New/ExplosionCombo")
			end
			if frame >= 12 then
				computerShip.exploded = true
			else
				frame = frame + dt * 50
			end
			graphics.draw_sprite("Explosions/BestExplosion", computerShip.physicsObject.position.x, computerShip.physicsObject.position.y, bestExplosion.size.x, bestExplosion.size.y, frame / 6 * math.pi)
		end
	end
	
	graphics.draw_sprite(playerShip.image, playerShip.physicsObject.position.x, playerShip.physicsObject.position.y, playerShip.size.x, playerShip.size.y, playerShip.physicsObject.angle)
	
--[[------------------
	PKBeam Firing
------------------]]--
	
	if playerShip.pkBeam.fired == true then
		local wNum = 1
		while wNum <= playerShip.pkBeam.max_bullets do
			if playerShip.pkBeamWeap[wNum] ~= nil then		
				graphics.draw_line(playerShip.pkBeamWeap[wNum].physicsObject.position.x, playerShip.pkBeamWeap[wNum].physicsObject.position.y, playerShip.pkBeamWeap[wNum].physicsObject.position.x - math.cos(playerShip.pkBeamWeap[wNum].physicsObject.angle) * playerShip.pkBeam.length, playerShip.pkBeamWeap[wNum].physicsObject.position.y - math.sin(playerShip.pkBeamWeap[wNum].physicsObject.angle) * playerShip.pkBeam.length, playerShip.pkBeam.width, 0.1, 0.7, 0.1, 1)
			end
			wNum = wNum + 1
		end
	end
	
--[[------------------
	C-Missile Firing
------------------]]--
	
	if playerShip.cMissile.fired == true then
		local wNum = 1
		while wNum <= playerShip.pkBeam.max_bullets do
			if playerShip.cMissileWeap[wNum] ~= nil then		
				graphics.draw_sprite("Weapons/cMissile", playerShip.cMissileWeap[wNum].physicsObject.position.x, playerShip.cMissileWeap[wNum].physicsObject.position.y, playerShip.cMissileWeap[wNum].size.x, playerShip.cMissileWeap[wNum].size.y, playerShip.cMissileWeap[wNum].physicsObject.angle)
			end
			wNum = wNum + 1
		end
	end
	
--[[------------------
	Arrow and Panels
------------------]]--
	
	local angle = playerShip.physicsObject.angle
	graphics.draw_line(math.cos(arrowAlpha + angle) * arrowDist + playerShip.physicsObject.position.x, math.sin(arrowAlpha + angle) * arrowDist + playerShip.physicsObject.position.y, math.cos(angle - arrowAlpha) * arrowDist + playerShip.physicsObject.position.x, math.sin(angle - arrowAlpha) * arrowDist + playerShip.physicsObject.position.y, 1.5, 0.1, 0.7, 0.1, 1)
	graphics.draw_line(math.cos(angle - arrowAlpha) * arrowDist + playerShip.physicsObject.position.x, math.sin(angle - arrowAlpha) * arrowDist + playerShip.physicsObject.position.y, math.cos(angle) * (arrowLength + arrowVar) + playerShip.physicsObject.position.x, math.sin(angle) * (arrowLength + arrowVar) + playerShip.physicsObject.position.y, 1.5, 0.1, 0.7, 0.1, 1)
	graphics.draw_line(math.cos(angle) * (arrowLength + arrowVar) + playerShip.physicsObject.position.x, math.sin(angle) * (arrowLength + arrowVar) + playerShip.physicsObject.position.y, math.cos(arrowAlpha + angle) * arrowDist + playerShip.physicsObject.position.x, math.sin(arrowAlpha + angle) * arrowDist + playerShip.physicsObject.position.y, 1.5, 0.1, 0.7, 0.1, 1)
	graphics.set_camera(-500, -500, 500, 500)
	graphics.draw_image("Panels/SideLeft", -435, 0, 129, 1012)
    graphics.draw_image("Panels/SideRight", 487, -2, 27, 1020)
	graphics.end_frame()
end

--[[------------------------
	--{{----------------
		Key Handling
	----------------}}--
------------------------]]--

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
        playerShip.pkBeam.firing = false
	elseif k == "x" then
		firepulse = false
    elseif k == "z" then
		playerShip.cMissile.firing = false
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
			playerShip.pkBeam.width = cameraRatio
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
			playerShip.pkBeam.width = cameraRatio
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
			playerShip.pkBeam.firing = true
		end
	elseif k == "x" then
		if playerShip.pulseName ~= nil then
			firepulse = true
		end
	elseif k == "z" then
		if playerShip.specialName ~= nil then
			playerShip.cMissile.firing = true
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
