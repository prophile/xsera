import('GlobalVars')
import('Console')
import('BoxDrawing')

background = {	{ top = 170, left = -280, bottom = -60, right = 280, boxColour = c_teal },
				{ top = -70, left = -280, bottom = -110, right = 280, boxColour = c_rust },
				{ coordx = -280, coordy = -205, length = 100, text = "nodraw", boxColour = c_brightYellow, textColour = c_purple, execute = nil, letter = "CANCEL" },
				{ coordx = -265, coordy = 170, length = 63, text = "nodraw", boxColour = c_teal, textColour = c_teal, execute = nil, letter = "Ship" },
				{ coordx = -177, coordy = 170, length = 93, text = "nodraw", boxColour = c_teal, textColour = c_teal, execute = nil, letter = "Command" },
				{ coordx = -54, coordy = 170, length = 95, text = "nodraw", boxColour = c_teal, textColour = c_teal, execute = nil, letter = "Shortcuts" },
				{ coordx = 71, coordy = 170, length = 71, text = "nodraw", boxColour = c_teal, textColour = c_teal, execute = nil, letter = "Utility" },
				{ coordx = 177, coordy = 170, length = 87, text = "nodraw", boxColour = c_teal, textColour = c_teal, execute = nil, letter = "HotKeys" },
				{ coordx = 180, coordy = -205, length = 100, text = "nodraw", boxColour = c_lightGreen, textColour = c_purple, execute = nil, letter = "DONE" } }

key_menu_num = 1
key_menu = { { "Ship",
				{ key = "KP8", name = "Accelerate" },
				{ key = "KP5", name = "Decelerate" }, 
				{ key = "KP4", name = "Turn Counter-Clockwise" }, 
				{ key = "KP6", name = "Turn Clockwise" }, 
				{ key = "MaltL", name = "Fire Weapon 1" }, 
				{ key = "MctrlL", name = "Fire Weapon 2" }, 
				{ key = " ", name = "Fire/Activate Special" }, 
				{ key = "Tab", name = "Warp" } },
			{ "Command", 
				{ key = "pgdn", name = "Select Friendly" }, 
				{ key = "KPequals", name = "Select Hostile" }, 
				{ key = "KPdivide", name = "Select Base" }, 
				{ key = "MshiftL", name = "Target" }, 
				{ key = "MctrlL", name = "Move Order" }, 
				{ key = "KPplus", name = "Scale In" }, 
				{ key = "KPminus", name = "Scale Out" }, 
				{ key = "up", name = "Computer Previous" }, 
				{ key = "down", name = "Computer Next" }, 
				{ key = "right", name = "Computer Accept/Select/Do" }, 
				{ key = "left", name = "Computer Cancel/Back Up" } },
			{ "Shortcuts",
				{ key = "F8", name = "Transfer Control" }, 
				{ key = "F9", name = "Zoom to 1:1" }, 
				{ key = "F10", name = "Zoom to 1:2" }, 
				{ key = "F11", name = "Zoom to 1:4" }, 
				{ key = "F12", name = "Zoom to 1:16" }, 
				{ key = "ins", name = "Zoom to Closest Hostile" }, 
				{ key = "home", name = "Zoom to Closest Object" }, 
				{ key = "pgup", name = "Zoom to All" }, 
				{ key = "del", name = "Message Next Page / Clear" } },
			{ "Utility",
				{ key = "F1", name = "Help" }, 
				{ key = "F2", name = "Lower Volume" }, 
				{ key = "F3", name = "Raise Volume" }, 
				{ key = "F4", name = "Mute Music" }, 
				{ key = "F5", name = "Expert Net Settings" }, 
				{ key = "F6", name = "Fast Motion" } }, 
			{ "HotKeys",
				{ key = "1", name = "HotKey 1" }, 
				{ key = "2", name = "HotKey 2" }, 
				{ key = "3", name = "HotKey 3" }, 
				{ key = "4", name = "HotKey 4" }, 
				{ key = "5", name = "HotKey 5" }, 
				{ key = "6", name = "HotKey 6" }, 
				{ key = "7", name = "HotKey 7" }, 
				{ key = "8", name = "HotKey 8" }, 
				{ key = "9", name = "HotKey 9" }, 
				{ key = "0", name = "HotKey 10" } } }

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
	numBoxes = 1
	while key_menu[key_menu_num][numBoxes] ~= nil do
		numBoxes = numBoxes + 1
	end
	rows = math.ceil(numBoxes / 2)
	num = 1
	local xcoord = 0
	local yshift = 0
	local adjust = 0
	while key_menu[key_menu_num][num + 1] ~= nil do
		if num % rows ~= num then
			xcoord = 5
			adjust = rows - 1
		else
			adjust = 0
			xcoord = -250
		end
		if rows % 2 ~= 0 then
			yshift = -9
		else
			yshift = -27
		end
		switch_box( { coordx = xcoord, coordy = (math.ceil(numBoxes / 4) - (num - 1 - adjust)) * 36 + yshift, length = 245, text = key_menu[key_menu_num][num + 1].name, boxColour = c_teal, textColour = c_teal, execute = nil, letter = key_menu[key_menu_num][num + 1].key } )
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
		mode_manager.switch('Options')
	end
end

function key(k)
-- no key presses until I can assign them to values
end