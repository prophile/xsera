splash_shift = -135
top_of_splash = -14
fontsize = 18
splash_num = 0

function init()
	sound.stop_music()
end

function update()
	
end

function render()
	graphics.begin_frame()
	splash_num = 0
	graphics.set_camera(-320, -240, 320, 240)
    graphics.draw_image("Panels/MainTop", 0, 118, 640, 245)
    graphics.draw_image("Panels/MainBottom", 0, -227, 640, 24)
    graphics.draw_image("Panels/MainLeft", -231, -110, 178, 211)
    graphics.draw_image("Panels/MainRight", 230, -110, 180, 211)
	graphics.draw_text("P - Play", "CrystalClear", "left", splash_shift, top_of_splash + splash_num * (-fontsize - 1), fontsize)
	splash_num = splash_num + 1
	graphics.draw_text("M - Xsera Main Menu", "CrystalClear", "left", splash_shift, top_of_splash + splash_num * (-fontsize - 1), fontsize)
	splash_num = splash_num + 1
	graphics.draw_text("Q - Quit", "CrystalClear", "left", splash_shift, top_of_splash + splash_num * (-fontsize - 1), fontsize)
	graphics.end_frame()
end

function key(k)
	if k == "p" then
		mode_manager.switch("Demo2")
	elseif k == "m" then
		mode_manager.switch("MainMenu")
	elseif k == "q" then
		os.exit()
	end
end