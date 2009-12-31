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
	
	scen = LoadScenario(1)

	loadingEntities = false

	graphics.set_camera(-75000,-0,75000,150000)

end

function key( k )
	print(k)
	if k == "q" or k == "escape" then
		mode_manager.switch("MainMenu")
	else
		KeyActivate(k)
	end
end

normal_key = key
normal_keyup = keyup

function keyup(k)
	KeyDeactivate(k)
end

function update()
	local newTime = mode_manager.time()
	dt = newTime - last_time
	last_time = newTime
	physics.update(dt)
end


function render()
local shipAdjust = 0.0
local camera = {w = 1000.0, h = 1000.0}
	graphics.begin_frame()
	graphics.set_camera(-scen.playerShip.physics.position.x + shipAdjust - (camera.w / 2.0), -scen.playerShip.physics.position.y - (camera.h / 2.0), -scen.playerShip.physics.position.x + shipAdjust + (camera.w / 2.0), -scen.playerShip.physics.position.y + (camera.h / 2.0))
	
	
	if scen ~= nil and scen.objects ~= nil then
	for obId = 0, #scen.objects-1 do
		local o = scen.objects[obId]
		graphics.draw_sprite("Id/"..o.sprite,
		o.physics.position,
		{x=40,y=40},
		o.physics.angle)
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