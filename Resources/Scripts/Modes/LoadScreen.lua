import('EntityLoad')
import('GlobalVars')
import('Panels')

function init()
	sound.stop_music()
	loading_percent = 0.0
end

function update()
	
end

function render()
	graphics.begin_frame()
	graphics.set_camera(-400, -300, 400, 300)
	graphics.draw_box(-275, -375, -265, 375, 2, 0, 0, 0.4, 1)
	graphics.draw_box(-275, -375, -265, 375 - loading_percent * 7.5, 0, 0.3, 0.3, 0.7, 1)
	graphics.end_frame()
end

function key(k)
	if k == "escape" then
		if mode_manager.query() ~= "MainMenu" then
			mode_manager.switch("MainMenu")
		end
	end
end