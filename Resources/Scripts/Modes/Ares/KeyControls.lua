import('GlobalVars')
import('Console')
import('BoxDrawing')
import('KeyboardControl')

background = {	{ top = 170, left = -280, bottom = -60, right = 280, boxColour = ClutColour(10, 8) },
				{ top = -70, left = -280, bottom = -110, right = 280, boxColour = ClutColour(16, 6) },
				{ xCoord = -280, yCoord = -205, length = 100, text = "nodraw", boxColour = ClutColour(3, 6), textColour = ClutColour(13, 9), execute = nil, letter = "CANCEL" },
				{ xCoord = -265, yCoord = 170, length = 63, text = "nodraw", boxColour = ClutLighten(ClutColour(10, 8)), textColour = ClutColour(10, 8), execute = nil, letter = "Ship" },
				{ xCoord = -177, yCoord = 170, length = 93, text = "nodraw", boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = nil, letter = "Command" },
				{ xCoord = -54, yCoord = 170, length = 95, text = "nodraw", boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = nil, letter = "Shortcuts" },
				{ xCoord = 71, yCoord = 170, length = 71, text = "nodraw", boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = nil, letter = "Utility" },
				{ xCoord = 177, yCoord = 170, length = 87, text = "nodraw", boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = nil, letter = "HotKeys" },
				{ xCoord = 180, yCoord = -205, length = 100, text = "nodraw", boxColour = ClutColour(12, 6), textColour = ClutColour(13, 9), execute = nil, letter = "DONE" } }

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
	graphics.draw_image("Panels/PanelTop", { x = 0, y = 210 }, { x = 572, y = 28 })
	graphics.draw_image("Panels/PanelBottom", { x = 0, y = -242 }, { x = 572, y = 20 })
	graphics.draw_image("Panels/PanelLeft", { x = -302, y = -14 }, { x = 33, y = 476 })
	graphics.draw_image("Panels/PanelRight", { x = 303, y = -14 }, { x = 35, y = 476 })
	local num = 1
	while background[num] ~= nil do
		SwitchBox(background[num])
		num = num + 1
	end
	
	keyboardNum = 1
	numBoxes = 1
	while keyboard[keyboardNum][numBoxes] ~= nil do
		numBoxes = numBoxes + 1
	end
	rows = math.ceil(numBoxes / 2)
	num = 1
	local xCoord = 0
	local yShift = 0
	local adjust = 0
	
	keyboardNum = 1
	while keyboard[keyboardNum][num + 1] ~= nil do
		if num % rows ~= num then
			xCoord = 5
			adjust = rows - 1
		else
			adjust = 0
			xCoord = -250
		end
		if rows % 2 ~= 0 then -- odd number of rows
			yShift = -9
		else
			yShift = 9
		end
		SwitchBox( { xCoord = xCoord, yCoord = (math.ceil(numBoxes / 4) - (num - 1 - adjust)) * 36 + yShift, length = 245, text = keyboard[keyboardNum][num + 1].name, boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = nil, letter = keyboard[keyboardNum][num + 1].key } )
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
		mode_manager.switch('Ares/Options')
	end
end

function ChangeBoxColour(box, match, shade)
	local num = 1
	while box[num] ~= nil do
		if box[num].letter == match then
			box[num].boxColour = ClutLighten(box[num].boxColour, shade)
		end
		num = num + 1
	end
end

function key(k)
-- no key presses until I can assign them to values
	if k == "j" then
		if keyboardNum ~= 1 then
			ChangeBoxColour(background, keyboard[keyboardNum][1], -2)
			keyboardNum = keyboardNum - 1
			ChangeBoxColour(background, keyboard[keyboardNum][1], 2)
		end
	elseif k == "l" then
		if keyboard[keyboardNum] ~= nil then
			ChangeBoxColour(background, keyboard[keyboardNum][1], -2)
			keyboardNum = keyboardNum + 1
			ChangeBoxColour(background, keyboard[keyboardNum][1], 2)
		end
	end
end