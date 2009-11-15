function key ( k )
	if k == "q" then
		mode_manager.switch("MainMenu")
	elseif k == "p" then
		graphics.add_particles("Sparks", 20, 0, 0, 0, 0, 2, 2, 0, 0.6, 3, 1)
	end
end

function render ()
	graphics.begin_frame()
	
	graphics.set_camera(-100.0, -100.0, 100.0, 100.0)
	
	graphics.draw_starfield(3.4)
	graphics.draw_starfield(1.8)
	graphics.draw_starfield(0.6)
	graphics.draw_starfield(-0.3)
	graphics.draw_starfield(-0.9)
	
	graphics.draw_lightning(-90.0, 0.0, 90.0, 0.0, 1.0, 3.0, false)
	graphics.draw_particles()
	
	graphics.end_frame()
end
