import('Actions')
import('ObjectLoad')
import('GlobalVars')
import('Math')
import('Scenarios')
import('PrintRecursive')


cid = 0

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
	if k == "q" then
		mode_manager.switch("MainMenu")
	elseif k =="w" then
		cid = cid + 1
	elseif k == "s" then
		cid = cid - 1
	elseif k == "return" then
		
	end
end

function update()
	local newTime = mode_manager.time()
	dt = newTime - last_time
	last_time = newTime
	physics.update(dt)
end


function render()
	graphics.begin_frame()
	if scen ~= nil and scen.objects ~= nil then
	for obId = 0, #scen.objects-1 do
		local o = scen.objects[obId]
		graphics.draw_sprite(o.sprite,
		o.physics.position.x,
		o.physics.position.y,
		4000,4000,
		o.physics.angle)
		end
	end
	graphics.end_frame()
end


function quit()
	physics.close()
end