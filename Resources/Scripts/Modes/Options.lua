import('GlobalVars')
import('Console')
import('BoxDrawing')

soundLevel = 8
soundMax = 8
background = {	{ coordx = -280, coordy = 140, length = 560, text = " ", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "Sound Options", underbox = -85 },
				{ coordx = -260, coordy = -30, length = 520, text = " ", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "VOLUME", underbox = -75 },
				{ coordx = 110, coordy = 20, length = 150, text = "nodraw", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "Volume Down" },
				{ coordx = 110, coordy = 100, length = 150, text = "nodraw", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "Volume Up" },
				{ coordx = -245, coordy = 100, length = 250, text = "nodraw", boxColour = ClutColour(14, 11), textColour = ClutColour(13, 9), execute = nil, letter = "Music During Action", radio = "off" },
				{ coordx = -245, coordy = 60, length = 250, text = "nodraw", boxColour = ClutColour(14, 11), textColour = ClutColour(13, 9), execute = nil, letter = "Music During Interlude", radio = "off" },
				{ coordx = -245, coordy = 20, length = 250, text = "nodraw", boxColour = ClutColour(4, 7), textColour = ClutColour(13, 9), execute = nil, letter = "Speak Network Messages", radio = "off" },
				{ coordx = -260, coordy = -205, length = 150, text = "Cancel", boxColour = ClutColour(3, 6), textColour = ClutColour(13, 9), execute = nil, letter = "ESC" },
				{ coordx = 110, coordy = -205, length = 150, text = "Done", boxColour = ClutColour(12, 6), textColour = ClutColour(13, 9), execute = nil, letter = "RTRN" },
				{ coordx = 110, coordy = -145, length = 150, text = "Key Controls", boxColour = ClutColour(10, 8), textColour = ClutColour(13, 9), execute = nil, letter = "K" } }

function init()
	sound.stop_music()
	graphics.set_camera(-480, -360, 480, 360)
end

function update()
	while background[num] ~= nil do
		if background[num].special == "click" then
			background[num].special = nil
		end
		num = num + 1
	end
	if soundLevel > soundMax then
		soundLevel = soundMax
	end
end

function render()
	graphics.begin_frame()
	-- Background
	graphics.draw_image("Panels/PanelTop", 0, 210, 572, 28)
	graphics.draw_image("Panels/PanelBottom", 0, -242, 572, 20)
	graphics.draw_image("Panels/PanelLeft", -302, -14, 33, 476)
	graphics.draw_image("Panels/PanelRight", 303, -14, 35, 476)
	local num = 1
	while background[num] ~= nil do
		switch_box(background[num])
		num = num + 1
	end
	num = 0
	while soundLevel > num do
		graphics.draw_box(-37, -242 + 62 * num, -63, -190 + 62 * num, 0, ClutLighten(ClutColour(6, 12), num))
		num = num + 1
	end
	-- Error Printing
	if errNotice ~= nil then
		graphics.draw_text(errNotice.text, "CrystalClear", "center", 0, -270, 28)
		if errNotice.start + errNotice.duration < mode_manager.time() then
			errNotice = nil
		end
	end
	graphics.end_frame()
end

function keyup(k)
	if k == "escape" then
		mode_manager.switch('AresSplash')
	elseif k == "return" then
		mode_manager.switch('AresSplash')
	elseif k == "k" then
		mode_manager.switch('KeyControls')
	end
end

function key(k)
	if k == "escape" then
		change_special("ESC", "click", background)
	elseif k == "return" then
		change_special("RTRN", "click", background)
	elseif k == "k" then
		change_special("K", "click", background)
	end
end