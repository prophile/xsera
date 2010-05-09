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
import('PopDownConsole')
import('Camera')
import('Physics')
import('Effects')

mdown = false
mrad = MOUSE_RADIUS / cameraRatio.current
aimMethod = "smart"

function init()
	Physics.NewSystem()
	start_time = mode_manager.time()
	realTime = mode_manager.time()
	last_time = mode_manager.time()

	scen = LoadScenario(demoLevel)

	selection.control = scen.playership
	selection.target = nil
	
	window.mouse_toggle()
end

function key( k )
	if RELEASE_BUILD ~= true then
		if k == "e" then
			consoleDraw = true
		end
	end
	if k == "escape" then
		menu_display = "esc_menu"
		keyup = escape_keyup
		key = escape_key
	elseif k == "q" then
		mode_manager.switch("Xsera/MainMenu")
	elseif k == "x" then
		aimMethod = aimMethod == "smart" and "dumb" or "smart"
		print(aimMethod)
	elseif k == "f" then
		AddEffects("flash", 1, 0.25,{})
	elseif k == "g" then
		blinkMode = (blinkMode == "triangle" and "flash" or "triangle")
		print(blinkMode)
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

	if menu_display == nil and consoleDraw == false then
		if keyboard[4][7].active == true then
			dt = dt * 50
		end

		realTime = realTime + dt
		
		CameraInterpolate(dt)
		
		KeyDoActivated()

		--[[ commenting out due to new physics system (which currently lacks collision detection)
		local cols = physics.collisions()
		
		for idx, pair in pairs(cols) do
			local a = scen.objects[pair[1] ]
			local b = scen.objects[pair[2] ]

			if a.base.attributes["can-collide"] == true
			and b.base.attributes["can-collide"] == true
			and a.ai.owner ~= b.ai.owner then
				Collide(a,b)
			end
		end
		mdown = false--]]
		
		--It might be better to do this in Physics.UpdateSystem
		for ai, a in pairs(scen.objects) do
			for bi, b in pairs(scen.objects) do
				if ai > bi then
					if a.base.attributes["can-collide"] == true
					and b.base.attributes["can-collide"] == true
					and a.ai.owner ~= b.ai.owner
					and hypot2(a.physics.position,b.physics.position) <= (a.physics.collision_radius + b.physics.collision_radius) then
						Collide(a,b)
					end
				end
			end
		end

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
					local len = math.min(o.base.beam.range,hypot2(from,o.gfx.target.position))
					
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
						and weap.lastRestock + weap.base.device["restock-cost"] * BASE_RECHARGE_RATE * WEAPON_RESTOCK_RATE / TIME_FACTOR <= realTime
						and o.status.energy >= weap.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO then
							o.status.energy = o.status.energy - weap.base.device["restock-cost"] * WEAPON_RESTOCK_RATIO
							weap.ammo = weap.ammo + 1
							weap.lastRestock = realTime
						end
					end
				end
			end

			--Lifetimer
			if o.age ~= nil then
				if o.age.lifeSpan + o.age.created <= realTime then
					ExpireTrigger(o)
					o.status.dead = true
				end
			end
			
			if o ~= scen.playerShip then
			 Think(o)
			end
			
			if o.triggers.periodic ~= nil
			and o.triggers.periodic.interval ~= 0
			and o.triggers.periodic.next <= realTime then
				ActivateTrigger(o)
				o.triggers.periodic.next = realTime + o.triggers.periodic.interval + math.random(0,o.triggers.periodic.range)
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
			Warp(o)

			local rvel
			if o.base.attributes["can-turn"] == true then
				rvel = o.base.rotation["max-turn-rate"]
			else
				rvel = DEFAULT_ROTATION_RATE
			end

			if o.control.left == true then
				o.physics.angularVelocity = rvel * 2.0
			elseif o.control.right == true then
				o.physics.angularVelocity = -rvel * 2.0
			else
				o.physics.angularVelocity = 0
			end

			if o.base["max-thrust"] ~= nil then
				if o.warp.stage < WARP_RUNNING then
					if o.control.accel == true then
						-- apply a forward force in the direction the ship is facing
						local angle = o.physics.angle
						local thrust = o.base["max-thrust"] * SPEED_FACTOR
						local force = vec(thrust * math.cos(angle), thrust * math.sin(angle))
						Physics.ApplyImpulse(o.physics, force)
					end

					if o.control.decel == true
						or hypot1(o.physics.velocity) >= o.base["max-velocity"] * SPEED_FACTOR then
						-- apply a reverse force in the direction opposite the direction the ship is MOVING
						local thrust = o.base["max-thrust"] * SPEED_FACTOR
						local force = o.physics.velocity
						if force.x ~= 0 or force.y ~= 0 then
							if hypot1(o.physics.velocity) <= 10 then
								o.physics.velocity = vec(0, 0)
							else
								local velocityMag = hypot1(force)
								force = -force * thrust / velocityMag
								if dt * velocityMag / o.physics.mass > velocityMag then
									o.physics.velocity = vec(0, 0)
								else
									Physics.ApplyImpulse(o.physics, force)
								end
							end
						end
					end
				elseif o.base["warp-speed"] ~= nil then
					local velocityMag = math.max(o.warp.factor * o.base["warp-speed"], o.base["max-velocity"]) * SPEED_FACTOR
					o.physics.velocity = PolarVec(velocityMag, o.physics.angle)
				end
			end
		end
		
		RemoveDead()
		TestConditions(scen)
		GenerateStatusLines(scen)
		
		UpdateEffects(dt)
		Physics.UpdateSystem(dt, scen.objects)
	end
end

function Win()
	print("\\ \\     /\\    / /   |__  __|   |   \\ | |")
	print(" \\ \\   /  \\  / /       | |     | |\ \\| |")
	print("  \\ \\_/ /\ \\/ /     ___| |__   | | \    |")
	print("   \\____/  \___/      |______|   |_|  \\__|")
end

function render()
	graphics.begin_frame()

	CameraToObject(scen.playerShip)

	graphics.begin_warp(scen.playerShip.warp.factor,scen.playerShip.physics.angle, cameraRatio.current)
	
	graphics.draw_starfield(3.4)
	graphics.draw_starfield(1.8)
	graphics.draw_starfield(0.6)
	graphics.draw_starfield(-0.3)
	graphics.draw_starfield(-0.9)
	
	DrawGrid()
	
	for objectId, object in pairs(scen.objects) do
		if objectId ~= scen.playerShipId then
			DrawObject(object)
		end
	end

	graphics.draw_particles()

--	DEBUG version, keep:
--	graphics.end_warp(scen.playerShip.warp.factor, scen.playerShip.physics.angle, cameraRatio.current, scen.playerShip.physics.position)
	graphics.end_warp()
		
	DrawObject(scen.playerShip)
	DrawEffects()
	
	DrawArrow()
	DrawMouse1()
	DrawPanels()
	
	local cam = CameraToWindow()
	graphics.set_camera(cam[1], cam[2], cam[3], cam[4])
	DrawMouse2()
	
	InterfaceDisplay(dt)
	PopDownConsole()
	
	--debug
	local zoomLevels = {
	"[2:1]","[1:1]","[1:2]","[1:4]","[1:16]","[closest hostile]", "[closest object]", "[all objects]"}
	graphics.draw_text(zoomLevels[cameraRatio.target], MAIN_FONT, "left", {x=100, y=100},30)
	graphics.end_frame()
end

function mouse(button, x, y)
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
		if hypot2(o.physics.position, mousePos) <= o.physics.collision_radius + mrad == true then
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
--	physics.close() -- what would I do in a closing physics function? [ADAM] [CLEANUP]
--It was because the old physics system needed to be explicitly cleared when changing modes.
end

function RemoveDead()
	--Remove destroyed or expired objects
	for i, o in pairs(scen.objects) do
		if o.status.dead == true then
			if scen.playerShipId == i then
				AddPlayerBody()
			end
			scen.objects[i] = nil
		end
	end
end

function AddPlayerBody()
	local body = NewObject(22)--[SCOTT][HARDCODE]
	body.ai.owner = scen.playerShip.ai.owner
	body.physics.velocity = scen.playerShip.physics.velocity
	body.physics.position = scen.playerShip.physics.position
	body.physics.angle = scen.playerShip.physics.angle

	scen.playerShipId = body.physics.object_id
	scen.objects[body.physics.object_id] = body
	--[SCOTT] We need a module for ship selection.
	ChangePlayerShip()
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

		local dist = hypot2(v1, v2)
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

function Warp(object)
	local warp = object.warp

	if object.control.warp == true
	and warp.stage < WARP_COOLING then
		if warp.factor < 1.0 then
			warp.stage = WARP_SPOOLING
			warp.factor = warp.factor + dt / WARP_TIME
			if warp.factor >= warp.lastPlayed / 4 then
				warp.lastPlayed = warp.lastPlayed + 1
				sound.play("Warp"..warp.lastPlayed)
			end
			if warp.factor >= 1.0 then
				warp.stage = WARP_RUNNING
				warp.factor = 1.0
				warp.lastPlayed = 5

				local flare = NewObject(32)--[SCOTT][HARDCODE]
				flare.physics.position = object.physics.position + PolarVec(-object.physics.collision_radius*1.5,object.physics.angle)
				CreateTrigger(flare)
				scen.objects[flare.physics.object_id] = flare
			end
		end
	elseif warp.stage >= WARP_ABORTING then
		if warp.factor > 0.0 then
			warp.factor = warp.factor - dt / WARP_OUT_TIME
			if warp.stage == WARP_ABORTING then
				warp.factor = warp.factor - dt / WARP_OUT_TIME * 4
			end
			if warp.factor <= 0.0 then
				warp.factor = 0.0
				warp.lastPlayed = 0
				if warp.stage == WARP_COOLING then
					local flare = NewObject(33)--[SCOTT][HARDCODE]
				flare.physics.position = object.physics.position + PolarVec(-object.physics.collision_radius*1.5,object.physics.angle)
				CreateTrigger(flare)
				scen.objects[flare.physics.object_id] = flare
				end
				warp.stage = WARP_IDLE
			end
		end
	end
end

function DrawObject(o)
	if o.type == "beam" then
		if o.base.beam.kind == "kinetic" then
			local p1 = o.physics.position
			local p2 = PolarVec(BEAM_LENGTH,o.physics.angle)
			graphics.draw_line(p1, p1 + p2, 1, ClutColour(o.base.beam.color))
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
		if cameraRatio.current >= 1 / 4 then
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

			local iconScale = 1.0/cameraRatio.current
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
