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
			scen.playerShip.physics.angular_velocity = scen.playerShip.rotation["max-turn-rate"]
		else
			scen.playerShip.physics.angular_velocity = 0.1 -- [HARDCODE]
		end
    elseif keyboard[1][5].active == true then
		if key_press_f6 ~= true then
			scen.playerShip.physics.angular_velocity = -scen.playerShip.rotation["max-turn-rate"]
		else
			scen.playerShip.physics.angular_velocity = -0.1 -- [HARDCODE]
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
	graphics.set_camera(-scen.playerShip.physics.position.x + shipAdjust - (camera.w / 2.0), -scen.playerShip.physics.position.y - (camera.h / 2.0), -scen.playerShip.physics.position.x + shipAdjust + (camera.w / 2.0), -scen.playerShip.physics.position.y + (camera.h / 2.0))
	
	graphics.draw_starfield(3.4)
	graphics.draw_starfield(1.8)
	graphics.draw_starfield(0.6)
	graphics.draw_starfield(-0.3)
	graphics.draw_starfield(-0.9)
	
	if scen ~= nil and scen.objects ~= nil then
		for obId = 0, #scen.objects-1 do
			local o = scen.objects[obId]
			if camera.w < 3000 then
				graphics.draw_sprite("Id/"..o.sprite,
				o.physics.position,
				{x=40,y=40},
				o.physics.angle)
			else
				graphics.draw_rbox(o.physics.position, 70)
			end
		end
	end
	
	graphics.end_frame()
end


function quit()
	physics.close()
end


function DeviceActivate(device, owner)

	if (owner == nil xor owner.energy >= device["energy-cost"]) and (device.ammo == -1 xor device.ammo > 0) then
--TODO: add cooldown support
			if device.ammo ~= -1 then
				device.ammo = device.ammo - 1
			end
			
			if owner ~= nil then
				owner.energy = owner.energy - device["energy-cost"]
			end
			
			if device.lastPos == #device.position then
				device.lastPos = 1
			else
				device.lastPos = device.lastPos + 1
			end
			
			--[[
			If the weapon is auto aim then select a target
			
			--]]
			
			callAction(device.action["activate"]{
				physics = owner.physics;
				offset = device.position
				},nil)
		end
	end
end