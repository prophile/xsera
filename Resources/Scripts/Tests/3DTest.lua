function key(k)
	if k == "escape" then
		mode_manager.switch("Xsera/MainMenu")
	elseif k == "1" then
		object = "Cube"
		fullOrbit = true
	elseif k == "2" then
		object = "Cabinet"
		fullOrbit = true
	elseif k == "3" then
		object = "Teapot"
		fullOrbit = true
	elseif k == "4" then
		object = "ObishCruiser"
		fullOrbit = false
	elseif k == "w" then
		scale = scale + 10.0
	elseif k == "s" then
		scale = scale - 10.0
	end
end

object = "Cube"
scale = 60.0
fullOrbit = true

function render()
	graphics.begin_frame()
		graphics.draw_starfield()
		if fullOrbit then
			graphics.draw_3d_ambient(object, {x=0, y=0}, scale, mode_manager.time(), mode_manager.time() * 5.0)
		else
			graphics.draw_3d_ambient(object, {x=0, y=0}, scale, mode_manager.time(), 0.0)
		end
	graphics.end_frame()
end
