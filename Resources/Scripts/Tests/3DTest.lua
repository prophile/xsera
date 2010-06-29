function key(k)
	if k == "escape" then
		mode_manager.switch("Xsera/MainMenu")
	elseif k == "1" then
		object = "Cube"
	elseif k == "2" then
		object = "Cabinet"
	elseif k == "3" then
		object = "Teapot"
	end
end

object = "Cube"

function render()
	graphics.begin_frame()
		graphics.draw_3d_ambient(object, {x=0, y=0}, 60.0, mode_manager.time(), mode_manager.time() * 5.0)
	graphics.end_frame()
end
