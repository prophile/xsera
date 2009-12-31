import('GlobalVars')
import('Console')
import('BoxDrawing')

soundLevel = 8
soundMax = 8
background = {	{ xCoord = -280, yCoord = 140, length = 560, text = " ", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "Sound Options", underbox = -85 },
				{ xCoord = -260, yCoord = -30, length = 520, text = " ", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "VOLUME", underbox = -75 },
				{ xCoord = 110, yCoord = 20, length = 150, text = "nodraw", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "Volume Down" },
				{ xCoord = 110, yCoord = 100, length = 150, text = "nodraw", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "Volume Up" },
				{ xCoord = -245, yCoord = 100, length = 250, text = "nodraw", boxColour = ClutColour(14, 11), textColour = ClutColour(13, 9), execute = nil, letter = "Music During Action", radio = "off" },
				{ xCoord = -245, yCoord = 60, length = 250, text = "nodraw", boxColour = ClutColour(14, 11), textColour = ClutColour(13, 9), execute = nil, letter = "Music During Interlude", radio = "off" },
				{ xCoord = -245, yCoord = 20, length = 250, text = "nodraw", boxColour = ClutColour(4, 7), textColour = ClutColour(13, 9), execute = nil, letter = "Speak Network Messages", radio = "off" },
				{ xCoord = -260, yCoord = -205, length = 150, text = "Cancel", boxColour = ClutColour(3, 6), textColour = ClutColour(13, 9), execute = nil, letter = "ESC" },
				{ xCoord = 110, yCoord = -205, length = 150, text = "Done", boxColour = ClutColour(12, 6), textColour = ClutColour(13, 9), execute = nil, letter = "RTRN" },
				{ xCoord = 110, yCoord = -145, length = 150, text = "Key Controls", boxColour = ClutColour(10, 8), textColour = ClutColour(13, 9), execute = nil, letter = "K" } }

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
	graphics.draw_image("Panels/PanelTop", { x = 0, y = 210 }, { x = 572, y = 28 })
	graphics.draw_image("Panels/PanelBottom", { x = 0, y = -242 }, { x = 572, y = 20 })
	graphics.draw_image("Panels/PanelLeft", { x = -302, y = -14 }, { x = 33, y = 476 })
	graphics.draw_image("Panels/PanelRight", { x = 303, y = -14 }, { x = 35, y = 476 })
	local num = 1
	while background[num] ~= nil do
		SwitchBox(background[num])
		num = num + 1
	end
	num = 0
	while soundLevel > num do
		graphics.draw_box(-37, -242 + 62 * num, -63, -190 + 62 * num, 0, ClutLighten(ClutColour(6, 12), num))
		num = num + 1
	end
	-- Error Printing
	if errNotice ~= nil then
		graphics.draw_text(errNotice.text, "CrystalClear", "center", { x = 0, y = -270 }, 28)
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
		ChangeSpecial("ESC", "click", background)
	elseif k == "return" then
		ChangeSpecial("RTRN", "click", background)
	elseif k == "k" then
		ChangeSpecial("K", "click", background)
	end
end