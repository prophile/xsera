import('Actions')
import('ObjectLoad')
import('GlobalVars')
import('Math')
import('Scenarios')
import('PrintRecursive')
import('KeyboardControl')
import('Interfaces')

function init()
	physics.open(0.6)
	start_time = mode_manager.time()
	last_time = mode_manager.time()
	loadingEntities = true
	
	scen = LoadScenario(25)
	
	loadingEntities = false
end

function key( k )
	if k == "q" or k == "escape" then
		mode_manager.switch("MainMenu")
	elseif k == "[" then
		if scen.playerShipId == 0 then
			scen.playerShipId = #scen.objects
		else
			scen.playerShipId = scen.playerShipId - 1
		end
		
		scen.playerShip = scen.objects[scen.playerShipId]
	elseif k == "]" then
		if scen.playerShipId == #scen.objects then
			scen.playerShipId = 0
		else
			scen.playerShipId = scen.playerShipId + 1
		end
		
		scen.playerShip = scen.objects[scen.playerShipId]
--	elseif k == " " then
--		DeviceActivate(scen.playerShip.weapon.beam,scen.playerShip)
	else
		KeyActivate(k)
	end
end

function keyup(k)
	KeyDeactivate(k)
end

normal_key = key
normal_keyup = keyup

function update()
	local newTime = mode_manager.time()
	dt = newTime - last_time
	last_time = newTime

--[[------------------
	Panels
------------------]]--
	
	resourceTime = resourceTime + dt
	if resourceTime > 1 then
		resourceTime = resourceTime - 1
		cash = cash + 20
		resourceBars = math.floor(cash / 20000)
		resources = math.floor((cash % 20000) / 200)
	end
	
	--[[ can't use this yet - don't need it yet
	if buildTimerRunning == true then
		scen.planet.buildqueue.current = scen.planet.buildqueue.current + dt
		scen.planet.buildqueue.percent = scen.planet.buildqueue.current / scen.planet.buildqueue.factor * 100
		if planet.buildqueue.percent > 100.0 then
			local num = 1
			if otherShip == nil then
				otherShip = {}
			end
			while otherShip[num] ~= nil do
				num = num + 1
			end
			if num == 3 and otherShip[2] == nil then -- I don't know why this works, but it does
				num = num - 1
			end
			otherShip[num] = NewEntity(shipBuilding.p, shipBuilding.n, "Ship", shipBuilding.r)
		--	print(otherShip[num], playerShip)
			planet.buildqueue.percent = 100
			buildTimerRunning = false
			sound.play("ComboBeep")
		end

	if o.trigger.activateInterval ~= 0 then
		if o.trigger.nextActivate <= newTime then
			ActivateTrigger(o)
			o.trigger.nextActivate = newTime + o.trigger.activateInterval + math.random(0,o.trigger.activateRange)
		end
	end
	
	--Fire weapons
	if o.control.pulse == true then
		ActivateTrigger(o.weapon.pulse, o)
	end

	if o.control.beam == true then
		ActivateTrigger(o.weapon.beam, o)
	end

	if o.control.special == true then
		ActivateTrigger(o.weapon.special, o)
	end
	--]]
	
	if scen.playerShip.energy.current / scen.playerShip.energy.max ~= 1.0 then
		rechargeTimer = rechargeTimer + dt
		if rechargeTimer >= 0.5 then
			if scen.playerShip.battery.current / scen.playerShip.battery.max ~= 0.0 then
				scen.playerShip.battery.current = scen.playerShip.battery.current - 1
				scen.playerShip.energy.current = scen.playerShip.energy.current + 1
				rechargeTimer = rechargeTimer - 0.5
			end
		end
	end
	
	local i
	for i = 0, #scen.objects do
		local o = scen.objects[i]
		
		--Lifetimer
		if o.age ~= nil then
			if o.age + o.created <= newTime then
				ExpireTrigger(o)
				table.insert(scen.destroyQueue, i)
			end
		end
		
		--Fire weapons
		if o.control.pulse == true then
			ActivateTrigger(o.weapon.pulse, o)
		end

		if o.control.beam == true then
			ActivateTrigger(o.weapon.beam, o)
		end

		if o.control.special == true then
			ActivateTrigger(o.weapon.special, o)
		end
		
		
	--[[------------------
		Movement
	------------------]]--
		if o["max-thrust"] ~= nil then
			local v = o.physics.velocity
			if hypot1(v) > o["max-velocity"] * SPEED_FACTOR then
				o.physics.velocity = {
				x = o["max-velocity"] * normalize(v.x,v.y) * SPEED_FACTOR;
				y = o["max-velocity"] * normalize(v.y,v.x) * SPEED_FACTOR;
				}
				
			end
		end
		
		if o.attributes["can-turn"] == true then
			if o.control.left == true then
				if key_press_f6 ~= true then
					o.physics.angular_velocity = o.rotation["max-turn-rate"] * 2.0
				else
					o.physics.angular_velocity = o.rotation["max-turn-rate"] * 4.0
				end
			elseif o.control.right == true then
				if key_press_f6 ~= true then
					o.physics.angular_velocity = -o.rotation["max-turn-rate"] * 2.0
				else
					o.physics.angular_velocity = -o.rotation["max-turn-rate"] * 4.0
				end
			else
				o.physics.angular_velocity = 0
			end
		end 
		if o.control.accel == true then
			-- apply a forward force in the direction the ship is facing
			local angle = o.physics.angle
			--Multiply by 60 because the thrust value in the data is given per FRAME not per second.
			local thrust = o["max-thrust"] * TIME_FACTOR * SPEED_FACTOR
			local force = { x = thrust * math.cos(angle), y = thrust * math.sin(angle) }
			o.physics:apply_force(force)
		elseif o.control.decel == true then
			-- apply a reverse force in the direction opposite the direction the ship is MOVING
			local thrust = o["max-thrust"] * TIME_FACTOR * SPEED_FACTOR
			local force = o.physics.velocity
			if force.x ~= 0 or force.y ~= 0 then
				if hypot(o.physics.velocity.x, o.physics.velocity.y) <= 10 then
					o.physics.velocity = { x = 0, y = 0 }
				else
					local velocityMag = hypot1(force)
					force.x = -force.x / velocityMag
					force.y = -force.y / velocityMag
					force.x = force.x * thrust
					force.y = force.y * thrust
					if hypot1(force) > hypot1(o.physics.velocity) then
						o.physics.velocity = { x = 0, y = 0 }
					else
						o.physics:apply_force(force)
					end
				end
			end
		end
	end

-- camera stuffs
	if cameraChanging == true then
		x = x - dt
		if x < 0 then
			x = 0
			cameraChanging = false
			scen.playerShip.beam.width = cameraRatio
			soundJustPlayed = false
		end
		if x >= 0 then
			cameraRatio = cameraRatioOrig + cameraRatioOrig * multiplier * math.pow(math.abs((x - timeInterval) / timeInterval), 2)  --[[* (((x - timeInterval) * (x - timeInterval) * math.sqrt(math.abs(x - timeInterval))) / (timeInterval * timeInterval * math.sqrt(math.abs(timeInterval))))--]]
		end
		camera = { w = 1024 / cameraRatio, h }
		camera.h = camera.w / aspectRatio
		shipAdjust = .045 * camera.w
		arrowLength = ARROW_LENGTH / cameraRatio
		arrowVar = ARROW_VAR / cameraRatio
		arrowDist = ARROW_DIST / cameraRatio
		if (cameraRatio < 1 / 8 and cameraRatioOrig > 1 / 8) or (cameraRatio > 1 / 8 and cameraRatioOrig < 1 / 8) then
			if soundJustPlayed == false then
				sound.play("ZoomChange")
				soundJustPlayed = true
			end
		end
	end

	--Remove destroyed or expired objects
	--Count backwards because the array is shifted with each deletion
	if #scen.destroyQueue > 0 then
		for i = #scen.destroyQueue, 1, -1 do
			scen.objects[scen.destroyQueue[i]].dead = true
			physics.destroy_object(scen.objects[scen.destroyQueue[i]].physics)
--			scen.objects[scen.destroyQueue[i]].physics:destroy()
			table.remove(scen.objects,scen.destroyQueue[i])
		end
	end
	scen.destroyQueue = {}
	
-- Fast speed vs regular
	if menu_display == nil then
		if keyboard[4][7].active == false then
			physics.update(dt)
		else
			physics.update(dt * 30)
		end
	end
	
	KeyDoActivated()
end



function render()
	graphics.begin_frame()

	graphics.set_camera(
	-scen.playerShip.physics.position.x + shipAdjust - (camera.w / 2.0),
	-scen.playerShip.physics.position.y - (camera.h / 2.0),
	-scen.playerShip.physics.position.x + shipAdjust + (camera.w / 2.0),
	-scen.playerShip.physics.position.y + (camera.h / 2.0))

	graphics.draw_starfield(3.4)
	graphics.draw_starfield(1.8)
	graphics.draw_starfield(0.6)
	graphics.draw_starfield(-0.3)
	graphics.draw_starfield(-0.9)
	
	if scen ~= nil and scen.objects ~= nil then
		for obId = 0, #scen.objects do
			local o = scen.objects[obId]
			
			if o.sprite ~= nil then
				if camera.w < 16384 then
					graphics.draw_sprite("Id/"..o.sprite,
					o.physics.position,
					o.spriteDim,
					o.physics.angle)
				else
					local iconScale = camera.w/1024
					if o["tiny-shape"] == "solid-square" then
						graphics.draw_rbox(o.physics.position, o["tiny-size"] * iconScale)
					elseif o["tiny-shape"] == "plus" then
						graphics.draw_rplus(o.physics.position, o["tiny-size"] * iconScale)
					elseif o["tiny-shape"] == "triangle" then
						graphics.draw_rtri(o.physics.position, o["tiny-size"] * iconScale)
					elseif o["tiny-shape"] == "diamond" then
						graphics.draw_rdia(o.physics.position, o["tiny-size"] * iconScale)
					elseif o["tiny-shape"] == "framed-square" then
						graphics.draw_rbox(o.physics.position, o["tiny-size"] * iconScale)
					end
				end
			elseif o.beam ~= nil then
				if o.beam.kind == 512
				or o.beam.kind == 9472
				or o.beam.kind == "kinetic"
				then --Kinetic Bolt

				local p1 = o.physics.position
				local p2 = RotatePoint({x=BEAM_LENGTH,y=0},o.physics.angle)
				graphics.draw_line(p1,{x=p1.x+p2.x,y=p1.y+p2.y},1,ClutColour(o.beam.color))
				end
			end
		end
	end
	
	
	--[[Draw temporary status display [ADAM] commented out because of panels
	local fs = 30
	local ox = camera.w/fs + scen.playerShip.physics.position.x - camera.w / 2
	local oy = -camera.w/fs + scen.playerShip.physics.position.y + camera.h / 2
	local vstep = -camera.w/fs * 1.5
	
	graphics.draw_text("Health: " .. scen.playerShip.health, "CrystalClear", "left", {x = ox, y = oy}, camera.w/fs)
	
	if scen.playerShip.energy ~= nil then
		graphics.draw_text("Energy: " .. scen.playerShip.energy, "CrystalClear", "left", {x = ox, y = oy + vstep}, camera.w/fs)
	end--]]

	graphics.draw_particles()
	DrawArrow()
	DrawPanels()
	graphics.end_frame()
end


function quit()
	physics.close()
end
