import('Actions')
import('Animation')
import('ObjectLoad')
import('GlobalVars')
import('Math')
import('Scenarios')
import('PrintRecursive')
import('KeyboardControl')
import('Interfaces')

trackingTarget = {x = 0.0, y = 0.0}

function init()
	physics.open(0.6)
	start_time = mode_manager.time()
	last_time = mode_manager.time()
	loadingEntities = true
	
	scen = LoadScenario(demoLevel)

	trackingTarget = GetMouseCoords()
	loadingEntities = false
end

function key( k )
	if k == "q" or k == "escape" then
		mode_manager.switch("Xsera/MainMenu")
--[[	elseif k == "=" then
		camera.w = camera.w / 2
		camera.h = camera.h / 2
	elseif k == "-" then
		camera.w = camera.w * 2
		camera.h = camera.h * 2--]]
	elseif k == "/" then
		printTable(scen.playerShip)
		print(scen.playerShip.physics.mass)
	elseif k == "[" then
		if scen.playerShipId == 1 then
			scen.playerShipId = #scen.objects
		else
			scen.playerShipId = scen.playerShipId - 1
		end
		
		ChangePlayerShip()
	elseif k == "]" then
		if scen.playerShipId == #scen.objects then
			scen.playerShipId = 1
		else
			scen.playerShipId = scen.playerShipId + 1
		end
		
		ChangePlayerShip()
	elseif k == "backspace" then
		scen.playerShip.health = scen.playerShip.health - 1000
		if scen.playerShip.health < 0 then
			scen.playerShip.health = 0
		end
	elseif k == "backslash" then
		shipSeek = not(shipSeek)
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

	trackingTarget = GetMouseCoords()
	KeyDoActivated()

--[[------------------
	Camera Code
------------------]]--
	
	if cameraChanging == true then
		x = x - dt
		if x < 0 then
			x = 0
			cameraChanging = false
			scen.playerShip.weapon.beam.width = cameraRatio
			soundJustPlayed = false
		end
		if x >= 0 then
			cameraRatio = cameraRatioOrig + cameraRatioOrig * multiplier * math.pow(math.abs((x - timeInterval) / timeInterval), 2)  --[[* (((x - timeInterval) * (x - timeInterval) * math.sqrt(math.abs(x - timeInterval))) / (timeInterval * timeInterval * math.sqrt(math.abs(timeInterval))))--]]
		end
		camera = { w = 640 / cameraRatio, h }
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

	for i = 1, #scen.objects do
		local o = scen.objects[i]
		if o.attributes["can-collide"] == true then

			if o.beam ~= nil then
				if o.beam.kind == "bolt-relative"
				or o.beam.kind == "static-relative" then
					o.physics.position = VecAdd(o.src.position, o.offset)
				elseif o.beam.kind == "bolt-to-object"
					or o.beam.kind == "static-to-object" then
					o.physics.position = VecAdd(VecMul(NormalizeVec(VecSub(o.target.position,o.src.position)), math.min(o.beam.range,find_hypot(o.src.position,o.target.position))),o.src.position)
				end
			end
			
			for i2 = i + 1, #scen.objects do
				local o2 = scen.objects[i2]
				if o2.attributes["can-collide"] == true
				and o.owner ~= o2.owner and physics.collisions(o.physics, o2.physics, 0) == true then
--[[
Equation for 1D elastic collision:
v1 = (m1v1 + m2v2 + m1C(v2-v1))/(m1+m2)

OR

Nathan's Method:
dist = dist(v1,v2)
angle = angleto(pos1,pos2)
momentMag = dist * m1/(m1+m2)
v1 = Polar2Rect(1,angle) * dist * m1 / (m1 + m2)
v2 = Polar2Rect(1,angle+180) * dist * m2 / (m1 + m2)
--]]
					if o.attributes["occupies-space"] and o2.attributes["occupies-space"] then
						local p = o.physics
						local p2 = o2.physics
						v1 = deepcopy(p.velocity)
						m1 = p.mass
						v2 = deepcopy(p2.velocity)
						m2 = p2.mass
--[[
						p.velocity = {
							x = (m1 * v1.x + m2 *v2.x + m1 * RESTITUTION_COEFFICIENT * ( v2.x - v1.x))/(m1+m2);
							y = (m1 * v1.y + m2 *v2.y + m1 * RESTITUTION_COEFFICIENT * ( v2.y - v1.y))/(m1+m2);
						}
						
						p2.velocity = {
							x = (m1 * v1.x + m2 *v2.x + m2 * RESTITUTION_COEFFICIENT * ( v1.x - v2.x))/(m1+m2);
							y = (m1 * v1.y + m2 *v2.y + m2 * RESTITUTION_COEFFICIENT * ( v1.y - v2.y))/(m1+m2);
						}
--]]

						local dist = find_hypot(p.velocity, p2.velocity)
						local angle = find_angle(p.position,p2.position)
						p.velocity = RotatePoint({y = 0,x = dist * m1 / (m1+m2)}, angle)
						p2.velocity = RotatePoint({y = 0,x = dist * m2 / (m1+m2)}, angle+math.pi)
					end

					CollideTrigger(o,o2)
					CollideTrigger(o2,o)

					if o2.damage ~= nil then
						o.health = o.health - o2.damage
					end
					if o.damage ~= nil then
						o2.health = o2.health - o.damage
					end


				end
			end
		end
		
		if o.health <= 0 and o.healthMax ~= 0 then
			DestroyTrigger(o)
			o.dead = true
		end
		
		if o.energy ~= nil then
			if o.energy < o.energyMax
			and o.battery > dt then
				o.energy = o.energy + dt * ENERGY_RECHARGE_RATE
				o.battery = o.battery - dt * ENERGY_RECHARGE_RATE
			end
			
			if o.health ~= nil
			and o.health <= o.healthMax * SHIELD_RECHARGE_MAX
			and	o.energy > SHIELD_RECHARGE_RATIO * SHIELD_RECHARGE_RATE * dt then
				o.health = o.health + SHIELD_RECHARGE_RATIO * SHIELD_RECHARGE_RATE * dt
				o.energy = o.energy - SHIELD_RECHARGE_RATE * dt
		end
			
		end

		--Lifetimer
		if o.age ~= nil then
			if o.age + o.created <= newTime then
				ExpireTrigger(o)
				o.dead = true
			end
		end
		
		if o.attributes["can-engage"] == true then
			if o ~= scen.playerShip then
				if o.owner == scen.playerShip.owner and (shipSeek == true or o.attributes["is-guided"] == true) then
					DumbSeek(o,trackingTarget)
				else
					o.control.left = false
					o.control.right = false
					o.control.accel = false
					o.control.decel = true
				end
			end
			
			if o.trigger.activateInterval ~= 0 then
				if o.trigger.nextActivate <= newTime then
					ActivateTrigger(o)
					o.trigger.nextActivate = newTime + o.trigger.activateInterval + math.random(0,o.trigger.activateRange)
				end
			end
		else
			o.control.accel = true
		end
		
		--Fire weapons
		if o.weapon ~= nil then
			if o.control.pulse == true
			and o.weapon.pulse ~= nil then
				ActivateTrigger(o.weapon.pulse, o)
			end

			if o.control.beam == true
			and o.weapon.beam ~= nil then
				ActivateTrigger(o.weapon.beam, o)
			end

			if o.control.special == true
			and o.weapon.special ~= nil then
				ActivateTrigger(o.weapon.special, o)
			end
		end
		
	--[[------------------
		Movement
	------------------]]--

		local rvel
		if o.attributes["can-turn"] == true then
			rvel = o.rotation["max-turn-rate"]
		else
			rvel = DEFAULT_ROTATION_RATE
		end
		
		if o.control.left == true then
			o.physics.angular_velocity = rvel * 2.0
		elseif o.control.right == true then
			o.physics.angular_velocity = -rvel * 2.0
		else
			o.physics.angular_velocity = 0
		end
			
		if o["max-thrust"] ~= nil then
			if o.control.accel == true then
				-- apply a forward force in the direction the ship is facing
				local angle = o.physics.angle
				--Multiply by 60 because the thrust value in the data is given per FRAME not per second.

				local thrust = o["max-thrust"] * TIME_FACTOR * SPEED_FACTOR
				local force = { x = thrust * math.cos(angle), y = thrust * math.sin(angle) }
				o.physics:apply_force(force)
			end
			
			if o.control.decel == true
			or hypot1(o.physics.velocity) >= o["max-velocity"] * SPEED_FACTOR then
			
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
						if dt * hypot1(force) / o.physics.mass > hypot1(o.physics.velocity) then
							o.physics.velocity = { x = 0, y = 0 }
						else
							o.physics:apply_force(force)
						end
					end
				end
			end
		end
	end
	physics.update(dt)
	RemoveDead()
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
	
--[[------------------
	Grid Drawing
------------------]]--
	do
		local i = 0
		while i * GRID_DIST_BLUE - 10 < camera.w + 10 + GRID_DIST_BLUE do
			local grid_x = math.floor((i * GRID_DIST_BLUE + scen.playerShip.physics.position.x - (camera.w / 2.0)) / GRID_DIST_BLUE) * GRID_DIST_BLUE
			
			if grid_x % GRID_DIST_LIGHT_BLUE == 0 then
				if grid_x % GRID_DIST_GREEN == 0 then
					graphics.draw_line({ x = grid_x, y = scen.playerShip.physics.position.y - (camera.h / 2.0) }, { x = grid_x, y = scen.playerShip.physics.position.y + (camera.h / 2.0) }, 1, ClutColour(5, 1))
				else
					graphics.draw_line({ x = grid_x, y = scen.playerShip.physics.position.y - (camera.h / 2.0) }, { x = grid_x, y = scen.playerShip.physics.position.y + (camera.h / 2.0) }, 1, ClutColour(14, 9))
				end
			else
				if cameraRatio > 1 / 8 then
					graphics.draw_line({ x = grid_x, y = scen.playerShip.physics.position.y - (camera.h / 2.0) }, { x = grid_x, y = scen.playerShip.physics.position.y + (camera.h / 2.0) }, 1, ClutColour(4, 11))
				end
			end
			i = i + 1
		end
		
		i = 0
		while i * GRID_DIST_BLUE - 10 < camera.h + 10 + GRID_DIST_BLUE do
			local grid_y = math.floor((i * GRID_DIST_BLUE + scen.playerShip.physics.position.y - (camera.h / 2.0)) / GRID_DIST_BLUE) * GRID_DIST_BLUE
			if grid_y % GRID_DIST_LIGHT_BLUE == 0 then
				if grid_y % GRID_DIST_GREEN == 0 then
					graphics.draw_line({ x = scen.playerShip.physics.position.x - shipAdjust - (camera.w / 2.0), y = grid_y }, { x = scen.playerShip.physics.position.x - shipAdjust + (camera.w / 2.0), y = grid_y }, 1, ClutColour(5, 1))
				else
					graphics.draw_line({ x = scen.playerShip.physics.position.x - shipAdjust - (camera.w / 2.0), y = grid_y }, { x = scen.playerShip.physics.position.x - shipAdjust + (camera.w / 2.0), y = grid_y }, 1, ClutColour(14, 9))
				end
			else
				if cameraRatio > 1 / 8 then
					graphics.draw_line({ x = scen.playerShip.physics.position.x - shipAdjust - (camera.w / 2.0), y = grid_y }, { x = scen.playerShip.physics.position.x - shipAdjust + (camera.w / 2.0), y = grid_y }, 1, ClutColour(4, 11))
				end
			end
			i = i + 1
		end
	end
	
	if scen ~= nil and scen.objects ~= nil then
		for obId = 1, #scen.objects do
			local o = scen.objects[obId]
			
			if o.sprite ~= nil then
				if camera.w <= 5120 then
					if o.animation ~= nil then
						graphics.draw_sprite_frame("Id/"..o.sprite, o.physics.position, o.spriteDim, Animate(o))
					else
						graphics.draw_sprite("Id/"..o.sprite, o.physics.position, o.spriteDim, o.physics.angle)
					end
				else
					local color
					
					if o.owner == -1 then
						color = ClutColour(4,1)
					elseif o.owner == scen.playerShip.owner then
						color = ClutColour(5,1)
					else
						color = ClutColour(16,1)
					end
					
					local iconScale = 1/cameraRatio
					if o["tiny-shape"] == "solid-square" then
						graphics.draw_rbox(o.physics.position, o["tiny-size"] * iconScale, color)
					elseif o["tiny-shape"] == "plus" then
						graphics.draw_rplus(o.physics.position, o["tiny-size"] * iconScale, color)
					elseif o["tiny-shape"] == "triangle" then
						graphics.draw_rtri(o.physics.position, o["tiny-size"] * iconScale, color)
					elseif o["tiny-shape"] == "diamond" then
						graphics.draw_rdia(o.physics.position, o["tiny-size"] * iconScale, color)
					elseif o["tiny-shape"] == "framed-square" then
						graphics.draw_rbox(o.physics.position, o["tiny-size"] * iconScale, color)
					end
				end
			elseif o.beam ~= nil then
				if o.beam.kind == "kinetic" then
					local p1 = o.physics.position
					local p2 = RotatePoint({x=BEAM_LENGTH,y=0},o.physics.angle)
					graphics.draw_line(p1,{x=p1.x+p2.x,y=p1.y+p2.y},1,ClutColour(o.beam.color))
				elseif o.beam.kind == "bolt-relative" then
					graphics.draw_lightning(o.src.position, o.physics.position, 1.0, 10.0, false,ClutColour(o.beam.color))
				elseif o.beam.kind == "bolt-to-object" then
					graphics.draw_lightning(o.src.position, o.physics.position, 1.0, 10.0, false,ClutColour(o.beam.color))
				elseif o.beam.kind == "static-relative" then
					graphics.draw_line(o.src.position, o.physics.position, 3.0, ClutColour(o.beam.color))
				elseif o.beam.kind == "static-to-object" then
					graphics.draw_line(o.src.position, o.physics.position, 3.0, ClutColour(o.beam.color))
				end
			end
		end
	end
	
	graphics.draw_particles()
	DrawArrow()
	DrawPanels()
	graphics.end_frame()
end


function quit()
	physics.close()
end


function RemoveDead()
	--Remove destroyed or expired objects
	--Count backwards because the array is shifted with each deletion
	local i
	for i = #scen.objects, 1, -1 do
		local o = scen.objects[i]
		if o.dead == true then
			if scen.playerShipId >= i and i ~= 1 then
				scen.playerShipId = scen.playerShipId - 1
			end
			physics.destroy_object(scen.objects[i].physics)
			ChangePlayerShip()
			table.remove(scen.objects,i)
			i = i - 1
		end
	end
	
end

function DumbSeek(object, target)
	object.control.accel = true
	local ang = find_angle(target,object.physics.position) - object.physics.angle

	ang = radian_range(ang)
--[[	if ang < math.pi / 2 then
		object.control.accel = true 
		object.control.decel = false
	else 
		object.control.accel = false
		object.control.decel = true
	end]]
	
	if math.abs(ang) < 0.1 then
		object.control.left = false
		object.control.right = false
	elseif ang <= math.pi then
		object.control.left = true
		object.control.right = false
	else
		object.control.left = false
		object.control.right = true
	end
	
end


function GetMouseCoords()
	local x, y = mouse_position()
	return {
	x = scen.playerShip.physics.position.x -shipAdjust + camera.w * x - camera.w / 2;
	y = scen.playerShip.physics.position.y  + camera.h * y - camera.h / 2;
	}
end


function ChangePlayerShip()
	if scen.playerShipId > #scen.objects then
		scen.playerShipId = #scen.objects
	end

	scen.playerShip = scen.objects[scen.playerShipId]
		
	scen.playerShip.control = {
		accel = false;
		decel = false;
		left = false;
		right = false;
		beam = false;
		pulse = false;
		special = false;
		warp = false;
	}
end
