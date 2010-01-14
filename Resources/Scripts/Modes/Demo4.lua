import('Actions')
import('Animation')
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
	
	scen = LoadScenario(demoLevel)

	loadingEntities = false
end

local camera = {w = 1024, h = 768}
local shipAdjust = 0

function key( k )
	if k == "q" or k == "escape" then
		mode_manager.switch("MainMenu")
	elseif k == "=" then
		camera.w = camera.w / 2
		camera.h = camera.h / 2
	elseif k == "-" then
		camera.w = camera.w * 2
		camera.h = camera.h * 2
	elseif k == "/" then
		printTable(scen.playerShip)
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
	elseif k == "backspace" then
		scen.playerShip.health = scen.playerShip.health - 1000
		if scen.playerShip.health < 0 then
			scen.playerShip.health = 0
		end
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

	KeyDoActivated()

local i
for i = 0, #scen.objects do
	local o = scen.objects[i]
	local i2
	for i2 = i + 1, #scen.objects do
		local o2 = scen.objects[i2]
--		print(i..", "..i2)
		if o.owner ~= o2.owner and physics.collisions(o.physics, o2.physics, 0) == true then
--			if o.owner ~= o2.owner then
				local p = o.physics

				p.velocity = {x = -p.velocity.x, y = -p.velocity.y}
				local p2 = o2.physics
				p2.velocity = {x = -p2.velocity.x, y = -p2.velocity.y}
				
				CollideTrigger(o,o2)
				CollideTrigger(o2,o)
				if o2.damage ~= nil then
				o.health = o.health - o2.damage
				end
				if o.damage ~= nil then
				o2.health = o2.health - o.damage
				end
	--			local dx = math.cos(p.position,p2.position)
	--			print("A")
--			end
		end
	end
	
	if o.health <= 0 then
		DestroyTrigger(o)
		o.dead = true
	end
	--Lifetimer
	if o.age ~= nil then
		if o.age + o.created <= newTime then
			ExpireTrigger(o)
			o.dead = true
		end
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
				o.physics.angular_velocity = o.rotation["max-turn-rate"]*2.0
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
	
	if scen ~= nil and scen.objects ~= nil then
		for obId = 0, #scen.objects do
			local o = scen.objects[obId]
			
			if o.sprite ~= nil then
				if camera.w < 16384 then
					if o.animation ~= nil then
						local frame = Animate(o,obId)
						local d = o.animation["last-shape"]
						if o.animation["last-shape"] == 0 then
							d = 1
						end
						graphics.draw_sprite("Id/"..o.sprite,
						o.physics.position,
						o.spriteDim,
						2.0 * math.pi * frame / d) --This a kludgy way of supplying the desired frame. Need function that takes a frame index instead of angle.
					else
						graphics.draw_sprite("Id/"..o.sprite,
						o.physics.position,
						o.spriteDim,
						o.physics.angle)
					end
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
				or o.beam.kind == 7680
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
	
	
	--Draw temporary status display
	local fs = 30
	local ox = camera.w/fs + scen.playerShip.physics.position.x - camera.w / 2
	local oy = -camera.w/fs + scen.playerShip.physics.position.y + camera.h / 2
	local vstep = -camera.w/fs * 1.5
	
	graphics.draw_text("Health: " .. scen.playerShip.health, "CrystalClear", "left", {x = ox, y = oy}, camera.w/fs)
	
	if scen.playerShip.energy ~= nil then
		graphics.draw_text("Energy: " .. scen.playerShip.energy, "CrystalClear", "left", {x = ox, y = oy + vstep}, camera.w/fs)
	end
	

	
	graphics.draw_particles()
	DrawPanels()
	DrawArrow()
	graphics.end_frame()
	
--	RemoveDead()
end


function quit()
	physics.close()
end


function RemoveDead()
	--Remove destroyed or expired objects
	--Count backwards because the array is shifted with each deletion
	local i
	for i = #scen.objects, 0, -1 do
		local o = scen.objects[i]
		if o.dead == true then
			physics.destroy_object(scen.objects[i].physics)
			table.remove(scen.objects,i)
			i = i - 1
--	if scen.destroyQueue > 0 then
--		for i = #scen.destroyQueue, 1, -1 do
--			scen.objects[scen.destroyQueue[i]].dead = true

--			scen.objects[scen.destroyQueue[i]].physics:destroy()
--			table.remove(scen.objects,scen.destroyQueue[i])
		end
		
	end
--	scen.destroyQueue = {}
end
