import('Actions')
import('ObjectLoad')
import('GlobalVars')
import('Math')
import('Scenarios')
import('PrintRecursive')
import('KeyboardControl')

function init()
	physics.open(0.6)
	start_time = mode_manager.time()
	last_time = mode_manager.time()
	loadingEntities = true
	
	scen = LoadScenario(2)

	loadingEntities = false
end

local camera = {w = 3000.0, h = 3000.0}
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
	elseif k == " " then
		DeviceActivate(scen.playerShip.weapon.pulse,scen.playerShip)
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
	Movement
------------------]]--
	
    if keyboard[1][4].active == true then
		if key_press_f6 ~= true then
			scen.playerShip.physics.angular_velocity = scen.playerShip.rotation["max-turn-rate"]*2.0
		else
			scen.playerShip.physics.angular_velocity = scen.playerShip.rotation["max-turn-rate"] * 4.0
		end
    elseif keyboard[1][5].active == true then
		if key_press_f6 ~= true then
			scen.playerShip.physics.angular_velocity = -scen.playerShip.rotation["max-turn-rate"] * 2.0
		else
			scen.playerShip.physics.angular_velocity = -scen.playerShip.rotation["max-turn-rate"] * 4.0
		end
    else
        scen.playerShip.physics.angular_velocity = 0
    end
	
	if keyboard[1][2].active == true then
        -- apply a forward force in the direction the ship is facing
        local angle = scen.playerShip.physics.angle
        local thrust = scen.playerShip["max-thrust"] * 10000
		local force = { x = thrust * math.cos(angle), y = thrust * math.sin(angle) }
		scen.playerShip.physics:apply_force(force)
	elseif keyboard[1][3].active == true then
        -- apply a reverse force in the direction opposite the direction the ship is MOVING
        local thrust = scen.playerShip["max-thrust"] * 10000
        local force = scen.playerShip.physics.velocity
		if force.x ~= 0 or force.y ~= 0 then
			if hypot(scen.playerShip.physics.velocity.x, scen.playerShip.physics.velocity.y) <= 10 then
				scen.playerShip.physics.velocity = { x = 0, y = 0 }
			else
				local velocityMag = hypot1(force)
				force.x = -force.x / velocityMag
				force.y = -force.y / velocityMag
				force.x = force.x * thrust
				force.y = force.y * thrust
				if hypot1(force) > hypot1(scen.playerShip.physics.velocity) then
					scen.playerShip.physics.velocity = { x = 0, y = 0 }
				else
					scen.playerShip.physics:apply_force(force)
				end
			end
		end
    end
	
	physics.update(dt)
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
			if camera.w < 3000 then
				graphics.draw_sprite("Id/"..o.sprite,
				o.physics.position,
				o.spriteDim,
				o.physics.angle)
			else
				graphics.draw_rbox(o.physics.position, 70)
			end
		end
	end
	
	
	--Draw temporary status display
	local fs = 30
	local ox = camera.w/fs + scen.playerShip.physics.position.x - camera.w / 2
	local oy = -camera.w/fs + scen.playerShip.physics.position.y + camera.h / 2
	local vstep = -camera.w/fs * 1.5
	
	graphics.draw_text("Health: " .. scen.playerShip.health, "CrystalClear", "left", {x = ox, y = oy}, camera.w/fs)
	graphics.draw_text("Energy: " .. scen.playerShip.energy, "CrystalClear", "left", {x = ox, y = oy + vstep}, camera.w/fs)
	
	if scen.playerShip.weapon.beam ~= nil and scen.playerShip.weapon.beam.ammo ~= -1 then
		graphics.draw_text("Beam Ammo: " .. scen.playerShip.weapon.beam.ammo, "CrystalClear", "left", {x = ox, y = oy + 3 * vstep}, camera.w/fs)
	end
	
	if scen.playerShip.weapon.pulse ~= nil and scen.playerShip.weapon.pulse.ammo ~= -1 then
		graphics.draw_text("Pulse Ammo: " .. scen.playerShip.weapon.pulse.ammo, "CrystalClear", "left", {x = ox, y = oy + 4 * vstep}, camera.w/fs)
	end
	
	if scen.playerShip.weapon.special ~= nil and scen.playerShip.weapon.special.ammo ~= -1 then
		graphics.draw_text("Special Ammo: " .. scen.playerShip.weapon.special.ammo, "CrystalClear", "left", {x = ox, y = oy + 4 * vstep}, camera.w/fs)
	end
	
	graphics.end_frame()
end


function quit()
	physics.close()
end


function DeviceActivate(device, owner)
	if xor(owner == nil, owner.energy >= device.device["energy-cost"])
	and xor(device.ammo == -1, device.ammo > 0) then
--TODO: add cooldown support
			if device.ammo ~= -1 then
				device.ammo = device.ammo - 1
			end
			
			if owner ~= nil then
				owner.energy = owner.energy - device.device["energy-cost"]
			end
			
			
			if device.position.last == #device.position then
				device.position.last = 1
			else
				device.position.last = device.position.last + 1
			end
			
			callAction(device.trigger["activate"],device,nil)
				
	end
end