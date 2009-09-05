import('GlobalVars')
import('Console')
import('BoxDrawing')
import('KeyboardControl')

background = {	{ top = 170, left = -280, bottom = -60, right = 280, boxColour = c_teal },
				{ top = -70, left = -280, bottom = -110, right = 280, boxColour = c_rust },
				{ coordx = -280, coordy = -205, length = 100, text = "nodraw", boxColour = c_brightYellow, textColour = clut_colour(13, 9), execute = nil, letter = "CANCEL" },
				{ coordx = -265, coordy = 170, length = 63, text = "nodraw", boxColour = colour_add(c_teal, c_lighten2), textColour = c_teal, execute = nil, letter = "Ship" },
				{ coordx = -177, coordy = 170, length = 93, text = "nodraw", boxColour = c_teal, textColour = c_teal, execute = nil, letter = "Command" },
				{ coordx = -54, coordy = 170, length = 95, text = "nodraw", boxColour = c_teal, textColour = c_teal, execute = nil, letter = "Shortcuts" },
				{ coordx = 71, coordy = 170, length = 71, text = "nodraw", boxColour = c_teal, textColour = c_teal, execute = nil, letter = "Utility" },
				{ coordx = 177, coordy = 170, length = 87, text = "nodraw", boxColour = c_teal, textColour = c_teal, execute = nil, letter = "HotKeys" },
				{ coordx = 180, coordy = -205, length = 100, text = "nodraw", boxColour = c_lightGreen, textColour = clut_colour(13, 9), execute = nil, letter = "DONE" } }

keyboard_num = 1

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
	while keyboard[keyboard_num][numBoxes] ~= nil do
		numBoxes = numBoxes + 1
	end
	rows = math.ceil(numBoxes / 2)
	num = 1
	local xcoord = 0
	local yshift = 0
	local adjust = 0
	while keyboard[keyboard_num][num + 1] ~= nil do
		if num % rows ~= num then
			xcoord = 5
			adjust = rows - 1
		else
			adjust = 0
			xcoord = -250
		end
		if rows % 2 ~= 0 then -- odd number of rows
			yshift = -9
		else
			yshift = 9
		end
		switch_box( { coordx = xcoord, coordy = (math.ceil(numBoxes / 4) - (num - 1 - adjust)) * 36 + yshift, length = 245, text = keyboard[keyboard_num][num + 1].name, boxColour = c_teal, textColour = c_teal, execute = nil, letter = keyboard[keyboard_num][num + 1].key } )
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

function change_box_colour(box, match, shade)
	local num = 1
	while box[num] ~= nil do
		if box[num].letter == match then
			box[num].boxColour = colour_add(box[num].boxColour, shade)
		end
		num = num + 1
	end
end

function key(k)
-- no key presses until I can assign them to values
	if k == "j" then
		if keyboard_num ~= 1 then
			change_box_colour(background, keyboard[keyboard_num][1], c_darken2)
			keyboard_num = keyboard_num - 1
			change_box_colour(background, keyboard[keyboard_num][1], c_lighten2)
		end
	elseif k == "l" then
		if keyboard[keyboard_num] ~= nil then
			change_box_colour(background, keyboard[keyboard_num][1], c_darken2)
			keyboard_num = keyboard_num + 1
			change_box_colour(background, keyboard[keyboard_num][1], c_lighten2)
		end
	end
end