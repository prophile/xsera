import('GlobalVars')
import('Console')
import('BoxDrawing')

soundLevel = 8
soundMax = 8
background = {	{ xCoord = -280, yCoord = 155, length = 560, text = " ", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "Sound Options", underbox = -85 },
				{ xCoord = -260, yCoord = -15, length = 520, text = " ", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = nil, letter = "VOLUME", underbox = -75 },
				{ xCoord = 110, yCoord = 35, length = 150, text = "nodraw", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = function() soundLevel = soundLevel - 1 end, letter = "Volume Down" },
				{ xCoord = 110, yCoord = 115, length = 150, text = "nodraw", boxColour = ClutColour(13, 9), textColour = ClutColour(13, 9), execute = function() soundLevel = soundLevel + 1; if soundLevel > soundMax then soundLevel = soundMax end end, letter = "Volume Up" },
				{ xCoord = -245, yCoord = 115, length = 250, text = "nodraw", boxColour = ClutColour(14, 11), textColour = ClutColour(13, 9), execute = function() if background[5].radio == "off" then background[5].radio = "on" else background[5].radio = "off" end end, letter = "Music During Action", radio = "off" },
				{ xCoord = -245, yCoord = 75, length = 250, text = "nodraw", boxColour = ClutColour(14, 11), textColour = ClutColour(13, 9), execute = function() if background[6].radio == "off" then background[6].radio = "on" else background[6].radio = "off" end end, letter = "Music During Interlude", radio = "off" },
				{ xCoord = -245, yCoord = 35, length = 250, text = "nodraw", boxColour = ClutColour(4, 7), textColour = ClutColour(13, 9), execute = function() if background[7].radio == "off" then background[7].radio = "on" else background[7].radio = "off" end end, letter = "Speak Network Messages", radio = "off" },
				{ xCoord = -260, yCoord = -190, length = 150, text = "Cancel", boxColour = ClutColour(3, 6), textColour = ClutColour(13, 9), execute = function() mode_manager.switch("Ares/Splash") end, letter = "ESC" },
				{ xCoord = 110, yCoord = -190, length = 150, text = "Done", boxColour = ClutColour(12, 6), textColour = ClutColour(13, 9), execute = function() mode_manager.switch("Ares/Splash") end, letter = "RTRN" },
				{ xCoord = 110, yCoord = -130, length = 150, text = "Key Controls", boxColour = ClutColour(10, 8), textColour = ClutColour(13, 9), execute = function() mode_manager.switch("Ares/KeyControls") end, letter = "K" } }

function init()
	sound.stop_music()
	graphics.set_camera(-240 * aspectRatio, -240, 240 * aspectRatio, 240)
end

function update()
	if soundLevel > soundMax then
	--	soundLevel = soundMax
	elseif soundLevel < 0 then
		soundLevel = 0
	end
	
	for num = 1, #background do
		if background[num].special == "click" then
			background[num].special = nil
		end
	end
	
	-- mouse button handling
	if mup then
		mup = false
		mousePos = input.mouse_position()
		mousePos.x = mousePos.x * 480 * aspectRatio - 240 * aspectRatio
		mousePos.y = mousePos.y * 480 - 240
		ChangeSpecialByLoc(mousePos, nil, background)
	elseif mdown then
		mousePos = input.mouse_position()
		mousePos.x = mousePos.x * 480 * aspectRatio - 240 * aspectRatio
		mousePos.y = mousePos.y * 480 - 240
		ChangeSpecialByLoc(mousePos, "click", background)
	end
end

function render()
	graphics.begin_frame()
	-- Background
	graphics.draw_image("Panels/PanelTop", { x = 0, y = 223 }, { x = 572, y = 28 })
	graphics.draw_image("Panels/PanelBottom", { x = 0, y = -229 }, { x = 572, y = 20 })
	graphics.draw_image("Panels/PanelLeft", { x = -302, y = -1 }, { x = 33, y = 476 })
	graphics.draw_image("Panels/PanelRight", { x = 303, y = -1 }, { x = 35, y = 476 })
	
	for num = 1, #background do
		SwitchBox(background[num])
	end
	for num = 0, soundLevel - 1 do
		graphics.draw_box(-37, -242 + 62 * num, -63, -190 + 62 * num, 0, ClutLighten(ClutColour(6, 12), -num))
	end
	-- Error Printing
	if errNotice ~= nil then
		graphics.draw_text(errNotice.text, MAIN_FONT, "center", { x = 0, y = -270 }, 28)
		if errNotice.start + errNotice.duration < mode_manager.time() then
			errNotice = nil
		end
	end
	graphics.end_frame()
end

function keyup(k)
	ChangeSpecial(k:upper(), nil, background)
	if k == "escape" then
		ChangeSpecial("ESC", nil, background)
	elseif k == "return" then
		ChangeSpecial("RTRN", nil, background)
	end
end

function key(k)
	ChangeSpecial(k:upper(), "click", background)
	if k == "escape" then
		ChangeSpecial("ESC", "click", background)
	elseif k == "return" then
		ChangeSpecial("RTRN", "click", background)
	end
end

function mouse(button, x, y)
	if button ~= "wheel_up" and button ~= "wheel_down" then
		mdown = true
	end
end

function mouse_up(button, mbX, mbY)
	if button ~= "wheel_up" and button ~= "wheel_down" then
		mup = true
		mdown = false
	end
end