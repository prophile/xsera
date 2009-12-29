import('Actions')
import('ObjectLoad')
import('GlobalVars')
import('Math')
import('Scenarios')
import('PrintRecursive')
import('KeyboardControl')

local playerShip = nil

function init()
	physics.open(0.6)
	start_time = mode_manager.time()
	last_time = mode_manager.time()
	loadingEntities = true
	
	scen = LoadScenario(2)

	loadingEntities = false
	
	for obId = 0, #scen.objects - 1 do
		printTable(scen.objects[obId])
		if scen.objects[obId].name == "Cruiser" and scen.objects[obId].race == 100 then
			scen.objects[obId].velocity = { x = 0, y = 0 }
			scen.objects[obId].angular_velocity = 0
			playerShip = scen.objects[obId]
		end
	end
end

local camera = {w = 3000.0, h = 3000.0}
local shipAdjust = 0

function key( k )
	if --[[k == "q" or]] k == "escape" then
		mode_manager.switch("MainMenu")
	elseif k == "=" then
		camera.w = camera.w * 2
		camera.h = camera.h * 2
	elseif k == "-" then
		camera.w = camera.w / 2
		camera.h = camera.h / 2
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
			playerShip.physics.angular_velocity = 1.0 -- [HARDCODE]
		else
			playerShip.physics.angular_velocity = 0.1 -- [HARDCODE]
		end
    elseif keyboard[1][5].active == true then
		if key_press_f6 ~= true then
			playerShip.physics.angular_velocity = -1.0 -- [HARDCODE]
		else
			playerShip.physics.angular_velocity = -0.1 -- [HARDCODE]
		end
    else
        playerShip.physics.angular_velocity = 0
    end
	
	if keyboard[1][2].active == true then
        -- apply a forward force in the direction the ship is facing
        local angle = playerShip.physics.angle
        local thrust = playerShip["max-thrust"] * 10000
		local force = { x = thrust * math.cos(angle), y = thrust * math.sin(angle) }
		playerShip.physics:apply_force(force)
	elseif keyboard[1][3].active == true then
        -- apply a reverse force in the direction opposite the direction the ship is MOVING
        local thrust = playerShip["max-thrust"] * 10000
        local force = playerShip.physics.velocity
		if force.x ~= 0 or force.y ~= 0 then
			if hypot(playerShip.physics.velocity.x, playerShip.physics.velocity.y) <= 10 then
				playerShip.physics.velocity = { x = 0, y = 0 }
			else
				local velocityMag = hypot1(force)
				force.x = -force.x / velocityMag
				force.y = -force.y / velocityMag
				force.x = force.x * thrust
				force.y = force.y * thrust
				if hypot1(force) > hypot1(playerShip.physics.velocity) then
					playerShip.physics.velocity = { x = 0, y = 0 }
				else
					playerShip.physics:apply_force(force)
				end
			end
		end
    end
	
	physics.update(dt)
end



function render()
	graphics.begin_frame()
	graphics.set_camera(-scen.playerShip.physics.position.x + shipAdjust - (camera.w / 2.0), -scen.playerShip.physics.position.y - (camera.h / 2.0), -scen.playerShip.physics.position.x + shipAdjust + (camera.w / 2.0), -scen.playerShip.physics.position.y + (camera.h / 2.0))
	
	
	if scen ~= nil and scen.objects ~= nil then
		for obId = 0, #scen.objects-1 do
			local o = scen.objects[obId]
			if shipAdjust < 1.0 then
				graphics.draw_sprite("Id/"..o.sprite,
				o.physics.position.x,
				o.physics.position.y,
				40,40,
				o.physics.angle)
			else
				graphics.draw_rbox(o.physics.position.x, o.physics.position.y, 70)
			end
		end
	end
	
	graphics.draw_starfield(3.4)
	graphics.draw_starfield(1.8)
	graphics.draw_starfield(0.6)
	graphics.draw_starfield(-0.3)
	graphics.draw_starfield(-0.9)
	
	graphics.end_frame()
end


function quit()
	physics.close()
end