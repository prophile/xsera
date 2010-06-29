function key(k)
	if k == "escape" then
		mode_manager.switch("Xsera/MainMenu")
	end
end

function render()
	graphics.begin_frame()
		graphics.draw_3d_ambient("Teapot", {x=0, y=0}, 120.0, mode_manager.time(), mode_manager.time() * 5.0)
	graphics.end_frame()
end
