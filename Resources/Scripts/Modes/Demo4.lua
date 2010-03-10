import('GlobalVars')
import('Actions')
import('Conditions')
import('Animation')
import('ObjectLoad')
--import('Math')
import('Scenarios')
import('PrintRecursive')
import('KeyboardControl')
import('PilotAI')
import('Interfaces')
--[[
trackingTarget = {
	position = vec(0,0);
	velocity = vec(0,0);
	mass = 1.0;
	collision_radius = 1.0;
	angle = 0.0;
	angular_velocity = 0.0;
}]]

mdown = false
mrad = MOUSE_RADIUS / cameraRatio
aimMethod = "smart"


TEMPVAR1 = false
TEMPVAR2 = false

function init()
	physics.open(0.6)
	start_time = mode_manager.time()
	last_time = mode_manager.time()
	
--	local tmp = physics.new_object(1.0)
--	physics.destroy_object(tmp)

--	trackingTarget.collision_radius = MOUSE_RADIUS

	scen = LoadScenario(demoLevel)

	selection.control = scen.playership
	selection.target = nil

--	trackingTarget.position = GetMouseCoords()
end

function key( k )
	if k == "q" or k == "escape" then
		mode_manager.switch("Xsera/MainMenu")
	elseif k == "-" then -- [TEMP] 
		-- create a blinking pointer box that says "LOOK HERE"
		TEMPVAR1 = not TEMPVAR1
	elseif k == "=" then -- [TEMP]
		-- create a non-blinking pointer box that says "LOOK THERE"
		TEMPVAR2 = not TEMPVAR2
	elseif k == "x" then
		aimMethod = aimMethod == "smart" and "dumb" or "smart"
		print(aimMethod)
	elseif k == "/" then
		printTable(scen.playerShip)
	elseif k == "backspace" then
		scen.playerShip.status.health = scen.playerShip.status.health - 1000
		if scen.playerShip.status.health < 0 then
			scen.playerShip.status.health = 0
		end
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
--		trackingTarget.collision_radius = MOUSE_RADIUS / cameraRatio
		mrad = MOUSE_RADIUS / cameraRatio
		if (cameraRatio < 1 / 8 and cameraRatioOrig > 1 / 8) or (cameraRatio > 1 / 8 and cameraRatioOrig < 1 / 8) then
			if soundJustPlayed == false then
				sound.play("ZoomChange")
				soundJustPlayed = true
			end
		end
	end

	local cols = physics.collisions()
	
	for idx, pair in pairs(cols) do
--		if pair[1] == 1 then
--[==[
			if mdown == true then
				if keyboard[2][5].active == true then
					print("TARGET SELECT")
					selection.target = scen.objects[pair[2] ]
				else
					print("CONTROL SELECT")
					selection.control = scen.objects[pair[2] ]
				end
				mdown = false
			end
--]==]
--		else
			local a = scen.objects[pair[1]]
			local b = scen.objects[pair[2]]

			if a.base.attributes["can-collide"] == true
			and b.base.attributes["can-collide"] == true
			and a.ai.owner ~= b.ai.owner then
				Collide(a,b)
			end
--		end
	end
	mdown = false

	for i, o in pairs(scen.objects) do
		if o.type == "beam" then
			if o.base.beam.kind == "bolt-relative"
			or o.base.beam.kind == "static-relative" then
				local src = o.gfx.source.position
				local off = o.gfx.offset
				local rel = o.gfx.relative
				local a = src;
				a = a + off
				a = a + rel
				o.physics.position = src + off + rel
				
			elseif o.base.beam.kind == "bolt-to-object"
				or o.base.beam.kind == "static-to-object" then
				local from = o.gfx.offset + o.gfx.source.position
				local dir = NormalizeVec(o.gfx.target.position - o.gfx.source.position)
				local len = math.min(o.base.beam.range,find_hypot(from,o.gfx.target.position))
				
				o.physics.position = dir * len
			end
		end
		
		if o.status.health <= 0 and o.status.healthMax >= 1 then
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
				for wid,weap in pairs(o.weapons) do
					if weap.ammo ~= -1
					and weap.base.device["restock-cost"] > 0
					and weap.ammo < weap.base.device.ammo / 2
					and weap.lastRestock + weap.base.device["restock-cost"] * BASE_RECHARGE_RATE * WEAPON_RESTOCK_RATE / TIME_FACTOR <= newTime
					and o.status.energy >= weap.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO then
						o.status.energy = o.status.energy - weap.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO
						weap.ammo = weap.ammo + 1
						weap.lastRestock = newTime 
					end
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
		
		if o ~= scen.playerShip then
		 Think(o)
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
						force = -force * thrust / velocityMag

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
	RemoveDead()
	TestConditions(scen)
	GenerateStatusLines(scen)
--	trackingTarget.position = GetMouseCoords()
	physics.update(dt)
end

local tv1Box = { message = "This is as long as a message can be at font 20: not long..", font = MAIN_FONT, size = 20, top = 0, bottom = -20, left = -200, right = 150, pointFrom = { x = 0, y = -20 }, pointTo = { x = -50, y = -70 }, colour = ClutColour(2, 5), flashing = false }
local tv2Box = { message = "LOOK THERE", font = MAIN_FONT, size = 16, top = 50, bottom = 20, left = 50, right = 150, pointFrom = { x = 50, y = 20 }, pointTo = { x = 50, y = -70 }, colour = ClutColour(4, 5), flashing = true }

function Win()
	print("\\ \\     /\\    / /   |__  __|   |   \\ | |")
	print(" \\ \\   /  \\  / /       | |     | |\ \\| |")
	print("  \\ \\_/ /\ \\/ /     ___| |__   | | \    |")
	print("   \\____/  \___/      |______|   |_|  \\__|")
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
	
	DrawGrid()
	
	for obId, o in pairs(scen.objects) do
		if o.type == "beam" then
			if o.base.beam.kind == "kinetic" then
				local p1 = o.physics.position
				local p2 = PolarVec(BEAM_LENGTH,o.physics.angle)
				graphics.draw_line(p1, p1 + p2,1,ClutColour(o.base.beam.color))
			else
				local from = o.gfx.source.position + o.gfx.offset
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
	DrawMouse1()
	DrawPanels()
	DrawMouse2()
	
	if TEMPVAR1 then
		DrawPointerBox(tv1Box, dt)
	end
	
	if TEMPVAR2 then
		DrawPointerBox(tv2Box, dt)
	end
	
	graphics.end_frame()
end

function mouse(button,x,y)
	if button == "wheel_up" then
		DoScaleIn(0.2)
	elseif button == "wheel_down" then
		DoScaleOut(0.2)
	else
		mdown = true
	end
end

function mouse_up()
	mdown = false

	local mousePos = GetMouseCoords()
	for i, o in pairs(scen.objects) do
		if find_hypot(o.physics.position, mousePos) <= o.physics.collision_radius + mrad == true then
			if keyboard[2][5].active == true then
				print("TARGET SELECT")
				selection.target = scen.objects[i]
			else
				print("CONTROL SELECT")
				selection.control = scen.objects[i]
			end
		end
	end
end

function shutdown()
	physics.close()
end

function RemoveDead()
	--Remove destroyed or expired objects
	for i, o in pairs(scen.objects) do
		if o.status.dead == true then
			if scen.playerShipId == i then
				ChangePlayerShip()
			end
			physics.destroy_object(o.physics)
			scen.objects[i] = nil
		end
	end
end

function ChangePlayerShip()
	
	scen.playerShip = scen.objects[scen.playerShipId]
	if scen.playerShip == nil then
	scen.playerShipId, scen.playerShip = next(scen.objects,scen.playerShipId)
		if scen.playerShip == nil then
			scen.playerShipId, scen.playerShip = next(scen.objects)
		end
	end
			
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

function Collide(a,b)
local o = a
local other = b
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
