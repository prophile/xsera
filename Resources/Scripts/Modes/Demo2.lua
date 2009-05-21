-- demo script (for demo 1.1): Player is Ishiman Heavy Cruiser, opponent is Gaitori Carrier.
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
import('Scenario')
import('PanelMenus')
-- import('MouseHandle')

local cameraRatio = 1
local aspectRatio = 4 / 3
camera = { w = 640 / cameraRatio, h }
camera.h = camera.w / aspectRatio
local shipAdjust = .045 * camera.w

--color tables
c_lightRed = { r = 0.8, g = 0.4, b = 0.4, a = 1 }
c_red = { r = 0.6, g = 0.15, b = 0.15, a = 1 }
c_lightBlue = { r = 0.15, g = 0.15, b = 0.6, a = 1 }
c_blue = { r = 0.15, g = 0.15, b = 0.6, a = 1 }
c_lightGreen = { r = 0.3, g = 0.7, b = 0.3, a = 1 }
c_green = { r = 0.0, g = 0.4, b = 0.0, a = 1 }
c_lightYellow = { r = 0.8, g = 0.8, b = 0.4, a = 1 }
c_yellow = { r = 0.6, g = 0.6, b = 0.15, a = 1 }
c_pink = { r = 0.8, g = 0.5, b = 0.5, a = 1 }
c_lightPurple = { r = 0.8, g = 0.5, b = 0.7, a = 1 }
c_purple = { r = 0.7, g = 0.4, b = 0.6, a = 1 }
--/color tables

--tempvars
firepulse = false
showVelocity = false
showAngles = false
frame = 0
printFPS = false
waitTime = 0.0
resources = 10
resource_bars = 1
NEW_RES = 2
resource_time = 0
recharge_timer = 0.0
--/tempvars

local soundLength = 0.25

local arrowLength = 135
local arrowVar = (3 * math.sqrt(3))
local arrowDist = hypot(6, (arrowLength - arrowVar))
local arrowAlpha = math.atan2(6, arrowDist)
local gridDistBlue = 300
local gridDistLightBlue = 2400
local gridDistGreen = 4800

keyControls = { left = false, right = false, forward = false, brake = false }

--[[--------------------------------
	--{{------------------------
		Projectile Collision
	------------------------}}--
--------------------------------]]--

function projectile_collision(projectileObject, pNum, projectileData, shipObject)
	table.remove(projectileObject, pNum)
	shipObject.life = shipObject.life - projectileData.damage
end

--[[--------------------------
	--{{------------------
		Initialization
	------------------}}--
--------------------------]]--

-- ALISTAIR: REQUEST: could init run BEFORE update, and not simultaneously with it?
-- When that's done, I'll re-add to init
	computerShip = NewShip("Gaitori/Carrier")
		computerShip.physicsObject.position = { x = 2200, y = 2700 }
		computerShip.physicsObject.angle = math.pi - 0.2
		computerShip.exploded = false
	
    playerShip = NewShip("Ishiman/HeavyCruiser")
		playerShip.warp = { warping = false, start = { bool = false, time = nil, engine = false, sound = false, isStarted = false }, endTime = 0.0, disengage = 2.0, finished = true, soundNum = 0 }
		playerShip.switch = true
		playerShip.battery = { total = 1000, level = 1000, percent = 1.0 }
		playerShip.charge = { total = 1000, level = 1000, percent = 1.0 }
		playerShip.shields = { total = 1000, level = 1000, percent = 1.0 }
		playerShip.cMissile = NewWeapon("Special", "cMissile")
			playerShip.cMissile.delta = 0.0
			playerShip.cMissile.dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
			playerShip.cMissile.size.x, playerShip.cMissile.size.y = graphics.sprite_dimensions("Weapons/cMissile")
			playerShip.cMissile.fired = false
			playerShip.cMissile.start = 0
			playerShip.cMissile.force = { x, y }
		playerShip.cMissileWeap = { { {} } }
		table.remove(playerShip.cMissileWeap, 1)
		playerShip.pkBeam = NewWeapon("Beam", "PKBeam")
			playerShip.pkBeam.width = cameraRatio
			playerShip.pkBeam.fired = false
			playerShip.pkBeam.start = 0
			playerShip.pkBeam.firing = false
		playerShip.pkBeamWeap = { { {} } }
		table.remove(playerShip.pkBeamWeap, 1)
-------
    --------
        -------- new weapon loading (after bullet -> projectile)
    --------
-------
		playerShip.special = NewWeapon("Special", "cMissile")
			playerShip.special.delta = 0.0
			playerShip.special.dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
			playerShip.special.size.x, playerShip.special.size.y = graphics.sprite_dimensions("Weapons/cMissile")
			playerShip.special.fired = false
			playerShip.special.start = 0
			playerShip.special.force = { x, y }
		playerShip.specialWeap = { { {} } }
		table.remove(playerShip.specialWeap, 1)
		playerShip.beam = NewWeapon("Beam", "PKBeam")
			playerShip.beam.width = cameraRatio
			playerShip.beam.fired = false
			playerShip.beam.start = 0
			playerShip.beam.firing = false
		playerShip.beamWeap = { { {} } }

function init ()
	sound.stop_music()
    lastTime = mode_manager.time()
    physics.open(0.6)
	bestExplosion = NewExplosion("BestExplosion")
end

--[[--------------------
	--{{------------
		Updating
	------------}}--
--------------------]]--

function update ()
	--DEMO2: put each section (marked by small lightsaber braces) into its own function in THIS file, if possible
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
	
	if playerShip.special ~= nil then
		weapon_manage(playerShip.special, playerShip.specialWeap, playerShip)
		--seeking code
		local wNum = 1
		while wNum <= playerShip.special.max_projectiles do
			if playerShip.specialWeap[wNum] ~= nil then
				if playerShip.specialWeap[wNum].isSeeking == true then
					playerShip.specialWeap[wNum].theta = find_angle(playerShip.specialWeap[wNum].physicsObject.position, playerShip.special.dest)
					if playerShip.specialWeap[wNum].physicsObject.angle ~= playerShip.specialWeap[wNum].theta then
						playerShip.specialWeap[wNum].delta = playerShip.specialWeap[wNum].theta - playerShip.specialWeap[wNum].physicsObject.angle
						if math.abs(playerShip.specialWeap[wNum].delta) > math.pi then -- need to go through 0
							if playerShip.specialWeap[wNum].delta > 0.0 then
								playerShip.specialWeap[wNum].delta = 2 * math.pi - playerShip.specialWeap[wNum].delta
							else
								playerShip.specialWeap[wNum].delta = 2 * math.pi + playerShip.specialWeap[wNum].delta
							end
						end
						if math.abs(playerShip.specialWeap[wNum].delta) > playerShip.specialWeap[wNum].turningRate * dt then
							if playerShip.specialWeap[wNum].delta > playerShip.specialWeap[wNum].turningRate * dt then
								playerShip.specialWeap[wNum].delta = -playerShip.specialWeap[wNum].turningRate * dt
							else
								playerShip.specialWeap[wNum].delta = playerShip.specialWeap[wNum].turningRate * dt
							end
						end
					else
						playerShip.specialWeap[wNum].delta = 0.0
					end
				else
					playerShip.specialWeap[wNum].delta = 0.0
				end
				playerShip.specialWeap[wNum].physicsObject.angle = playerShip.specialWeap[wNum].physicsObject.angle + playerShip.specialWeap[wNum].delta
				playerShip.specialWeap[wNum].force = { x = math.cos(playerShip.specialWeap[wNum].physicsObject.angle) * playerShip.special.thrust / playerShip.special.mass, y = math.sin(playerShip.specialWeap[wNum].physicsObject.angle) * playerShip.special.thrust / playerShip.special.mass }
				playerShip.specialWeap[wNum].physicsObject:apply_force(playerShip.specialWeap[wNum].force)
				if showAngles == true then
					print("For special #" .. wNum .. ":")
					print(playerShip.specialWeap[wNum].physicsObject.angle)
					print(playerShip.specialWeap[wNum].theta)
					print(playerShip.specialWeap[wNum].delta)
					print("----------------")
				end
				wNum = playerShip.special.max_projectiles
			end
			wNum = wNum + 1
		end
		--/seeking code
	end
	
-- PKBeam Firing
	
	weapon_manage(playerShip.beam, playerShip.beamWeap, playerShip)

--[[------------------
	Update Panels
------------------]]--
	
	resource_time = resource_time + dt
	if resource_time > resource_time % NEW_RES then
		resource_time = resource_time % NEW_RES
		resources = resources + 1
		if resources == 100 then
			if resource_bars ~= 7 then
				resources = 0
				resource_bars = resource_bars + 1
			end
		end
	end
	
	playerShip.battery.percent = playerShip.battery.level / playerShip.battery.total
	playerShip.charge.percent = playerShip.charge.level / playerShip.charge.total
	playerShip.shields.percent = playerShip.shields.level / playerShip.shields.total
	if playerShip.charge.percent ~= 1.0 then
		recharge_timer = recharge_timer + dt
		if recharge_timer >= 0.5 then
			if playerShip.battery.percent ~= 0.0 then
				playerShip.battery.level = playerShip.battery.level - 1
				playerShip.charge.level = playerShip.charge.level + 1
				recharge_timer = 0.0
			end
		end
	end
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
			if weapOwner.battery.level < weapon.cost then
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
			while wNum <= weapon.max_projectiles do
				if weapData[wNum] == nil then
					-- I would rather load from memory, but we don't have a function that preloads yet. Oh well. [DEMO2, ADAM, ALISTAIR]
					weapData[wNum] = NewProjectile(weapon.shortName, weapon.class, weapOwner)
					cNum = wNum
					wNum = weapon.max_projectiles -- exit while loop
				end
				wNum = wNum + 1
			end
			
			-- weapon fired, take away cost (and seek if necessary)
			if weapon.class == "special" then
				weapOwner.special.ammo = weapOwner.special.ammo - 1
				sound.play("RocketLaunchr")
				-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included for troubleshooting)
				if computerShip.exploded == true then
					weapData[cNum].isSeeking = false
				end
				
				if weapData[cNum].isSeeking == true then
					local projectileTravel = { x, y, dist }
					projectileTravel.dist = (weapon.thrust * weapon.life * weapon.life / 1000000) / (2 * weapon.mass)
					projectileTravel.x = math.cos(weapData[cNum].physicsObject.angle) * (projectileTravel.dist + weapData[cNum].physicsObject.velocity.x)
					projectileTravel.y = math.sin(weapData[cNum].physicsObject.angle) * (projectileTravel.dist + weapData[cNum].physicsObject.velocity.y)
					if find_hypot(weapData[cNum].physicsObject.position, weapData[cNum].dest) <= hypot(projectileTravel.x, projectileTravel.y) then
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
	while wNum <= playerShip.special.max_projectiles do
		if weapData[wNum] ~= nil then
			if weapData[wNum].physicsObject == nil then
				-- this object needs to be deleted
				table.remove(weapData, wNum)
			else
				if computerShip.exploded == false then
					local x = computerShip.physicsObject.position.x - weapData[wNum].physicsObject.position.x
					local y = computerShip.physicsObject.position.y - weapData[wNum].physicsObject.position.y
					-- put in real collision code here [ALISTAIR, DEMO2]
					if hypot (x, y) <= computerShip.physicsObject.collision_radius * 2 / 7 then
						projectile_collision(weapData, wNum, weapon, computerShip)
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
				graphics.draw_line(-60000, -i * gridDistBlue, 60000, -i * gridDistBlue, 1, 0.1, 0.7, 0.1, 1)
				graphics.draw_line(-60000, i * gridDistBlue, 60000, i * gridDistBlue, 1, 0.1, 0.7, 0.1, 1)
				graphics.draw_line(-i * gridDistBlue, -60000, -i * gridDistBlue, 60000, 1, 0.1, 0.7, 0.1, 1)
				graphics.draw_line(i * gridDistBlue, -60000, i * gridDistBlue, 60000, 1, 0.1, 0.7, 0.1, 1)
			else
				graphics.draw_line(-60000, -i * gridDistBlue, 60000, -i * gridDistBlue, 1, 0.3, 0.3, 0.8, 1)
				graphics.draw_line(-60000, i * gridDistBlue, 60000, i * gridDistBlue, 1, 0.3, 0.3, 0.8, 1)
				graphics.draw_line(-i * gridDistBlue, -60000, -i * gridDistBlue, 60000, 1, 0.3, 0.3, 0.8, 1)
				graphics.draw_line(i * gridDistBlue, -60000, i * gridDistBlue, 60000, 1, 0.3, 0.3, 0.8, 1)
			end
		else
			if cameraRatio ~= 1 / 16 then
				graphics.draw_line(-60000, -i * gridDistBlue, 60000, -i * gridDistBlue, 1, 0.0, 0.0, 0.65, 1)
				graphics.draw_line(-60000, i * gridDistBlue, 60000, i * gridDistBlue, 1, 0.0, 0.0, 0.65, 1)
				graphics.draw_line(-i * gridDistBlue, -60000, -i * gridDistBlue, 60000, 1, 0.0, 0.0, 0.65, 1)
				graphics.draw_line(i * gridDistBlue, -60000, i * gridDistBlue, 60000, 1, 0.0, 0.0, 0.65, 1)
			end
		end
		i = i + 1
	end
	
--[[------------------
	Planet Drawing
------------------]]--
	
	aex, aey = graphics.sprite_dimensions("Planets/AnotherEarth")
	graphics.draw_sprite("Planets/AnotherEarth", scen.planet.location.x, scen.planet.location.y, aex, aey, 1, 0.0, 1.0, 1.0, 1.0)

--[[------------------
	Ship Drawing
------------------]]--

    if computerShip.life > 0 then
		graphics.draw_sprite("Gaitori/Carrier", computerShip.physicsObject.position.x, computerShip.physicsObject.position.y, computerShip.size.x, computerShip.size.y, computerShip.physicsObject.angle)
    else
		-- This explosion code is a hack. We need a way to deal with explosions in a better method. Let's figure
		-- it out when we get Sfiera's data [ADAM, SFIERA]
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
	
	if playerShip.beam.fired == true then
		local wNum = 1
		while wNum <= playerShip.beam.max_projectiles do
			if playerShip.beamWeap[wNum] ~= nil then
				graphics.draw_line(playerShip.beamWeap[wNum].physicsObject.position.x, playerShip.beamWeap[wNum].physicsObject.position.y, playerShip.beamWeap[wNum].physicsObject.position.x - math.cos(playerShip.beamWeap[wNum].physicsObject.angle) * playerShip.beam.length, playerShip.beamWeap[wNum].physicsObject.position.y - math.sin(playerShip.beamWeap[wNum].physicsObject.angle) * playerShip.beam.length, playerShip.beam.width, 0.1, 0.7, 0.1, 1)
			end
			wNum = wNum + 1
		end
	end
	
--[[------------------
	C-Missile Firing
------------------]]--
	
	if playerShip.special.fired == true then
		local wNum = 1
		while wNum <= playerShip.special.max_projectiles do
			if playerShip.specialWeap[wNum] ~= nil then		
				graphics.draw_sprite("Weapons/cMissile", playerShip.specialWeap[wNum].physicsObject.position.x, playerShip.specialWeap[wNum].physicsObject.position.y, playerShip.special.size.x, playerShip.special.size.y, playerShip.specialWeap[wNum].physicsObject.angle)
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
	graphics.set_camera(-400, -300, 400, 300)
	graphics.draw_image("Panels/SideLeft", -349, 0, 103, 607)
	graphics.draw_image("Panels/SideRight", 387, -2, 26, 608)
-- Battery (red)
	graphics.draw_box(107, 379, 29, 386, 0, 0.6, 0.15, 0.15, 1)
	graphics.draw_box(playerShip.battery.percent * 78 + 29, 379, 29, 386, 0, 0.8, 0.4, 0.4, 1)
-- Charge (yellow)
	graphics.draw_box(6, 379, -72.5, 386, 0, 0.6, 0.6, 0.15, 1)
	graphics.draw_box(playerShip.charge.percent * 78.5 - 72.5, 379, -72.5, 386, 0, 0.8, 0.8, 0.4, 1)
-- Shields (blue)
	graphics.draw_box(-96, 379, -173, 386, 0, 0.15, 0.15, 0.6, 1)
	graphics.draw_box(playerShip.shields.percent * 77 - 173, 379, -173, 386, 0, 0.15, 0.15, 0.6, 1)
-- Radar box (green)
	graphics.draw_box(184, -394, 100, -308, 1, 0.0, 0.4, 0.0, 1)
-- Factory resources (green)
	count = 0
	while count <= 100 do
		if count > resources then
			graphics.draw_box(151 - 3.15 * count, 394, 149 - 3.15 * count, 397, 0, 0.2, 0.5, 0.2, 1)
		else
			graphics.draw_box(151 - 3.15 * count, 394, 149 - 3.15 * count, 397, 0, 0.4, 0.7, 0.4, 1)
		end
		count = count + 1
	end
-- Factory resource bars (yellow)
	count = 1
	while count <= 7 do
		if count <= resource_bars then
			graphics.draw_box(154.5 - 4.5 * count, 384, 151 - 4.5 * count, 392, 0, 0.7, 0.7, 0.4, 1)
		else
			graphics.draw_box(154.5 - 4.5 * count, 384, 151 - 4.5 * count, 392, 0, 0.5, 0.5, 0.2, 1)
		end
		count = count + 1
	end
-- Factory build bar
	planet = true
	planet_build = { factor = 10, current = 0, percent = 0.7 }
	if planet == true then
		graphics.draw_line(382, 181, 392, 181, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(382, 181, 382, 177, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(392, 177, 392, 181, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(382, 159, 392, 159, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(382, 163, 382, 159, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(392, 159, 392, 163, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_box(179, 384, 161, 390, 0, 0.7, 0.4, 0.6, 1)
		graphics.draw_box(18 * planet_build.percent + 161, 384, 161, 390, 0, 0.8, 0.5, 0.7, 1)
	end
-- Communications panels (green)
	display_menu()
	graphics.draw_box(-63, -392, -158, -304, 0, 0.0, 0.4, 0.0, 1)
	graphics.draw_line(-391, -74, -305, -74, 1, 0.4, 0.8, 0.4, 0.5)
	graphics.draw_box(-165.5, -389.5, -185, -311, 0, 0.0, 0.4, 0.0, 1)
	display_menu()
-- Weapon (special) ammo count
	graphics.draw_text(string.format('%03d', playerShip.special.ammo), "CrystalClear", -311, 60, 13) -- GREEN
	control = true
	target = true
	if control == true then
		graphics.draw_box(49, -392, 39, -305, 0, 0.8, 0.8, 0.4, 1)
		graphics.draw_text("CONTROL", "CrystalClear", -370, 44, 13) -- LEFT JUSTIFY, BLACK
		graphics.draw_line(-387, 26, -372, 26, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, 24, -387, 26, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-372, 24, -372, 26, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, 9, -372, 9, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-372, 11, -372, 9, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, 11, -387, 9, 0.5, 1.0, 1.0, 1.0, 1)
	end
	if target == true then
		graphics.draw_box(-8, -392, -18, -305, 0, 0.2, 0.2, 0.6, 1)
		graphics.draw_text("TARGET", "CrystalClear", -370, -13, 13) -- LEFT JUSTIFY, BLACK
		graphics.draw_line(-387, -32, -372, -32, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-372, -34, -372, -32, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, -34, -387, -32, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, -49, -372, -49, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-372, -47, -372, -49, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, -47, -387, -49, 0.5, 1.0, 1.0, 1.0, 1)
	end
	if menu_level == menu_options then
		graphics.draw_box(-165.5, -389.5, -175.5, -358, 0, 0.15, 0.15, 0.6, 1)
		graphics.draw_text("RIGHT", "CrystalClear", -377, -171, 13) -- LEFT JUSTIFY, BLUE
		graphics.draw_text("Select", "CrystalClear", -337, -171, 13) -- LEFT JUSTIFY, BLUE
	else
		graphics.draw_box(-165.5, -389.5, -175.5, -358, 0, 0.15, 0.15, 0.6, 1)
		graphics.draw_text("RIGHT", "CrystalClear", -377, -171, 13) -- LEFT JUSTIFY, BLUE
		graphics.draw_text("Select", "CrystalClear", -337, -171, 13) -- LEFT JUSTIFY, BLUE
		graphics.draw_box(-175.5, -389.5, -185.5, -358, 0, 0.15, 0.15, 0.6, 1)
		graphics.draw_text("LEFT", "CrystalClear", -377, -181, 13) -- LEFT JUSTIFY, BLUE
		graphics.draw_text("Go Back", "CrystalClear", -337, -181, 13) -- LEFT JUSTIFY, BLUE
	end
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
		if playerShip.beamName ~= nil then
			playerShip.beam.firing = false
		end
	elseif k == "x" then
		if playerShip.pulseName ~= nil then
			playerShip.pulse.firing = false
		end
	elseif k == "z" then
		if playerShip.specialName ~= nil then
			playerShip.special.firing = false
		end
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
	elseif k == "i" then
		change_menu(menu_level, "i")
	elseif k == "k" then
		change_menu(menu_level, "k")
	elseif k == "j" then
		change_menu(menu_level, "j")
	elseif k == "l" then
		change_menu(menu_level, "l")
	elseif k == "tab" then
		playerShip.warp.start.bool = true
	elseif k == " " then
		if playerShip.beamName ~= nil then
			playerShip.beam.firing = true
		end
	elseif k == "x" then
		if playerShip.pulseName ~= nil then
			playerShip.pulse.firing = true
		end
	elseif k == "z" then
		if playerShip.specialName ~= nil then
			playerShip.special.firing = true
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
