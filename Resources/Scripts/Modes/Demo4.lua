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
		scen.playerShip.status.health = scen.playerShip.status.health - 1000
		if scen.playerShip.status.health < 0 then
			scen.playerShip.status.health = 0
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
--			scen.playerShip.weapon.beam.width = cameraRatio
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
		if o.base.attributes["can-collide"] == true then

			if o.type == "beam" then
				if o.base.beam.kind == "bolt-relative"
				or o.base.beam.kind == "static-relative" then
					local src = o.gfx.source.position
					local off = o.gfx.offset
					local rel = o.gfx.relative.position
					
					o.physics.position = {
						x = src.x + off.x + rel.x;
						y = src.y + off.y + rel.y;
					}
				elseif o.base.beam.kind == "bolt-to-object"
					or o.base.beam.kind == "static-to-object" then
					local from = VecAdd(o.gfx.offset,o, gfx.source.position)
					local dir = NormalizeVec(VecSub(o.gfx.target.position,o.gfx.source.position))
					local len = math.min(o.base.beam.range,find_hypot(from,o.gfx.target.position))
					
					o.physics.position = {
						x = dir.x * len;
						y = dir.y * len;
					}
				end
			end
			
			for i2 = i + 1, #scen.objects do
				local other = scen.objects[i2]
				if other.base.attributes["can-collide"] == true
				and o.ai.owner ~= other.ai.owner and physics.collisions(o.physics, other.physics, 0) == true then
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
					if o.base.attributes["occupies-space"]
					and other.base.attributes["occupies-space"] then
						local p = o.physics
						local p2 = other.physics
						v1 = p.velocity
						m1 = p.mass
						v2 = p2.velocity
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

						local dist = find_hypot(v1, v2)
						local angle = find_angle(p.position,p2.position)
						p.velocity = PolarVec(dist * m1 / (m1+m2), angle)
						p2.velocity = PolarVec(dist * m2 / (m1+m2), angle+math.pi)
					end

					CollideTrigger(o,other)
					CollideTrigger(other,o)

					if other.base.damage ~= nil then
						o.status.health = o.status.health - other.base.damage
					end
					if o.base.damage ~= nil then
						other.status.health = other.status.health - o.base.damage
					end


				end
			end
		end
		
		if o.status.health <= 0 and o.status.healthMax ~= 0 then
			DestroyTrigger(o)
			o.status.dead = true
		end
		
		if o.status.energy ~= nil then
			if o.status.energy < o.status.energyMax
			and o.status.battery > dt * ENERGY_RECHARGE_RATIO / BASE_RECHARGE_RATE then
				o.status.energy = o.status.energy + dt * ENERGY_RECHARGE_RATIO / BASE_RECHARGE_RATE
				o.status.battery = o.status.battery - dt * ENERGY_RECHARGE_RATIO / BASE_RECHARGE_RATE
			end
			
			if o.status.health ~= nil
			and o.status.health <= o.status.healthMax * SHIELD_RECHARGE_MAX
			and	o.status.energy > SHIELD_RECHARGE_RATIO * dt / BASE_RECHARGE_RATE then
				o.status.health = o.status.health + dt / BASE_RECHARGE_RATE
				o.status.energy = o.status.energy - SHIELD_RECHARGE_RATIO * dt / BASE_RECHARGE_RATE
			end
			
			if o.weapons ~= nil then
				if o.weapons.pulse ~= nil
				and o.weapons.pulse.ammo ~= -1
				and o.weapons.pulse.ammo < o.weapons.pulse.base.device.ammo / 2
				and o.weapons.pulse.lastRestock + o.weapons.pulse.base.device["restock-cost"] * BASE_RECHARGE_RATE * WEAPON_RESTOCK_RATE / TIME_FACTOR<= newTime
				and o.status.energy >= o.weapons.pulse.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO then
					o.status.energy = o.status.energy - o.weapons.pulse.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO
					o.weapons.pulse.ammo = o.weapons.pulse.ammo + 1
					o.weapons.pulse.lastRestock = newTime
				end
				
				if o.weapons.beam ~= nil
				and o.weapons.beam.ammo ~= -1
				and o.weapons.beam.ammo < o.weapons.beam.base.device.ammo / 2
				and o.weapons.beam.lastRestock + o.weapons.beam.base.device["restock-cost"] * BASE_RECHARGE_RATE * WEAPON_RESTOCK_RATE / TIME_FACTOR <= newTime
				and o.status.energy >= o.weapons.beam.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO then
					o.status.energy = o.status.energy - o.weapons.beam.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO
					o.weapons.beam.ammo = o.weapons.beam.ammo + 1
					o.weapons.beam.lastRestock = newTime
				end
				
				if o.weapons.special ~= nil
				and o.weapons.special.ammo ~= -1
				and o.weapons.special.ammo < o.weapons.special.base.device.ammo / 2
				and o.weapons.special.lastRestock + o.weapons.special.base.device["restock-cost"] * BASE_RECHARGE_RATE * WEAPON_RESTOCK_RATE / TIME_FACTOR <= newTime
				and o.status.energy >= o.weapons.special.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO then
					o.status.energy = o.status.energy - o.weapons.special.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO
					o.weapons.special.ammo = o.weapons.special.ammo + 1
					o.weapons.special.lastRestock = newTime
				end
			end
		end

		--Lifetimer
		if o.age ~= nil then
			if o.age.lifeSpan + o.age.created <= newTime then
				ExpireTrigger(o)
				o.status.dead = true
			end
		end
		
		if o.base.attributes["can-engage"] == true then
			if o ~= scen.playerShip then
				if o.ai.owner == scen.playerShip.ai.owner
				and (shipSeek == true
				or o.base.attributes["is-guided"] == true) then
					DumbSeek(o,trackingTarget)
				else
					o.control.left = false
					o.control.right = false
					o.control.accel = false
					o.control.decel = true
				end
			end
		else
			o.control.accel = true
		end
		
		if o.triggers.periodic ~= nil
		and o.triggers.periodic.interval ~= 0
		and o.triggers.periodic.next <= newTime then
			ActivateTrigger(o)
			o.triggers.periodic.next = newTime + o.triggers.periodic.interval + math.random(0,o.triggers.periodic.range)
		end
		
		
		--Fire weapons
		if o.weapons ~= nil then
			if o.control.pulse == true
			and o.weapons.pulse ~= nil then
				ActivateTrigger(o.weapons.pulse, o)
			end

			if o.control.beam == true
			and o.weapons.beam ~= nil then
				ActivateTrigger(o.weapons.beam, o)
			end

			if o.control.special == true
			and o.weapons.special ~= nil then
				ActivateTrigger(o.weapons.special, o)
			end
		end
		
	--[[------------------
		Movement
	------------------]]--

		local rvel
		if o.base.attributes["can-turn"] == true then
			rvel = o.base.rotation["max-turn-rate"]
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
			
		if o.base["max-thrust"] ~= nil then
			if o.control.accel == true then
				-- apply a forward force in the direction the ship is facing
				local angle = o.physics.angle
				--Multiply by 60 because the thrust value in the data is given per FRAME not per second.

				local thrust = o.base["max-thrust"] * TIME_FACTOR * SPEED_FACTOR
				local force = { x = thrust * math.cos(angle), y = thrust * math.sin(angle) }
				o.physics:apply_force(force)
			end
			
			if o.control.decel == true
			or hypot1(o.physics.velocity) >= o.base["max-velocity"] * SPEED_FACTOR then
			
				-- apply a reverse force in the direction opposite the direction the ship is MOVING
				local thrust = o.base["max-thrust"] * TIME_FACTOR * SPEED_FACTOR
				local force = o.physics.velocity
				if force.x ~= 0 or force.y ~= 0 then
					if hypot1(o.physics.velocity) <= 10 then
						o.physics.velocity = { x = 0, y = 0 }
					else
						local velocityMag = hypot1(force)
						force.x = -force.x / velocityMag
						force.y = -force.y / velocityMag
						force.x = force.x * thrust
						force.y = force.y * thrust
						if dt * hypot1(force) / o.physics.mass > velocityMag then
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
	
	for obId = 1, #scen.objects do
		local o = scen.objects[obId]
		if o.type == "beam" then
			if o.base.beam.kind == "kinetic" then
				local p1 = o.physics.position
				local p2 = PolarVec(BEAM_LENGTH,o.physics.angle)
				graphics.draw_line(p1,{x=p1.x+p2.x,y=p1.y+p2.y},1,ClutColour(o.base.beam.color))
			else
				local from = VecAdd(o.gfx.source.position, o.gfx.offset)
				if o.base.beam.kind == "bolt-relative" then
					graphics.draw_lightning(from, o.physics.position, 1.0, 10.0, false,ClutColour(o.base.beam.color))
				elseif o.base.beam.kind == "bolt-to-object" then
					graphics.draw_lightning(from, o.physics.position, 1.0, 10.0, false,ClutColour(o.base.beam.color))
				elseif o.base.beam.kind == "static-relative" then
					graphics.draw_line(from, o.physics.position, 3.0, ClutColour(o.base.beam.color))
				elseif o.base.beam.kind == "static-to-object" then
					graphics.draw_line(from, o.physics.position, 3.0, ClutColour(o.base.beam.color))
				end
			end
		else
			if cameraRatio >= 1.0/8.0 then--[FIX]
				if o.type == "animation" then
					graphics.draw_sprite_frame(o.gfx.sprite, o.physics.position, o.gfx.dimensions, Animate(o))
				else -- Rotational
					graphics.draw_sprite(o.gfx.sprite, o.physics.position, o.gfx.dimensions, o.physics.angle)
				end
			else
				local color
				
				if o.ai.owner == -1 then
					color = ClutColour(4,1)
				elseif o.ai.owner == scen.playerShip.ai.owner then
					color = ClutColour(5,1)
				else
					color = ClutColour(16,1)
				end
				
				local iconScale = 1.0/cameraRatio
				if o.base["tiny-shape"] == "solid-square" then
					graphics.draw_rbox(o.physics.position, o.base["tiny-size"] * iconScale, color)
				elseif o.base["tiny-shape"] == "plus" then
					graphics.draw_rplus(o.physics.position, o.base["tiny-size"] * iconScale, color)
				elseif o.base["tiny-shape"] == "triangle" then
					graphics.draw_rtri(o.physics.position, o.base["tiny-size"] * iconScale, color)
				elseif o.base["tiny-shape"] == "diamond" then
					graphics.draw_rdia(o.physics.position, o.base["tiny-size"] * iconScale, color)
				elseif o.base["tiny-shape"] == "framed-square" then --NOT IMPLEMENTED
					graphics.draw_rbox(o.physics.position, o.base["tiny-size"] * iconScale, color)
				end
			end
		end
		
	end

	
	graphics.draw_particles()
	DrawArrow()
	
	ship = scen.playerShip.physics.position
	mousePos = GetMouseCoords()
	if mouseMovement == nil then
		if mousePos.x > 260 / cameraRatio + ship.x then
			mousePos.x = 260 / cameraRatio + ship.x
		elseif mousePos.x < -320 / cameraRatio + ship.x - shipAdjust then
			mousePos.x = -320 / cameraRatio + ship.x - shipAdjust
		end
		
		if mousePos.y > 230 / cameraRatio + ship.y then
			mousePos.y = 230 / cameraRatio + ship.y
		elseif mousePos.y < -220 / cameraRatio + ship.y then
			mousePos.y = -220 / cameraRatio + ship.y
		end
		graphics.draw_line({ x = - camera.w / 2 + ship.x, y = mousePos.y }, { x = mousePos.x - 20 / cameraRatio, y = mousePos.y }, 1.0, ClutColour(4, 8))
		graphics.draw_line({ x = camera.w / 2 + ship.x, y = mousePos.y }, { x = mousePos.x + 20 / cameraRatio, y = mousePos.y }, 1.0, ClutColour(4, 8))
		graphics.draw_line({ x = mousePos.x, y = -camera.h / 2 + ship.y }, { x = mousePos.x, y = mousePos.y - 20 / cameraRatio }, 1.0, ClutColour(4, 8))
		graphics.draw_line({ x = mousePos.x, y = camera.h / 2 + ship.y }, { x = mousePos.x, y = mousePos.y + 20 / cameraRatio }, 1.0, ClutColour(4, 8))
		-- check to see if it's over the panels
		-- if it is, draw the cursor
		if mousePos.x < -260 / cameraRatio + ship.x then
			local cursor = graphics.sprite_dimensions("Misc/Cursor")
			graphics.draw_sprite("Misc/Cursor", mousePos, cursor, 0)
		end
	end
	
	DrawPanels()
	-- Mouse, pt 2
	if mouseMovement == nil and mousePos.x < -260 / cameraRatio + ship.x then
		graphics.set_camera( -- should I have to do this? [ADAM, HACK]
			-scen.playerShip.physics.position.x + shipAdjust - (camera.w / 2.0),
			-scen.playerShip.physics.position.y - (camera.h / 2.0),
			-scen.playerShip.physics.position.x + shipAdjust + (camera.w / 2.0),
			-scen.playerShip.physics.position.y + (camera.h / 2.0))
	
		local cursor = graphics.sprite_dimensions("Misc/Cursor")
		graphics.draw_sprite("Misc/Cursor", mousePos, cursor, 0)
		-- check mouse idleness timer
		--if mode_manager.time() - mouseStart >= 2.0 then
		--	mouseMovement = false
		--end
	end
	
	graphics.end_frame()
end

function quit()
	physics.close()
end


function RemoveDead()
	--Remove destroyed or expired objects
	for i = 1, #scen.objects do
		local o = scen.objects[i]
		if o == nil then
			break
		end

		if o.status.dead == true then
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
	object.control.decel = false
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
