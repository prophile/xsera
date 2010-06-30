import('GlobalVars')
import('Console')
import('BoxDrawing')
import('KeyboardControl')

background = {	{ top = 170, left = -280, bottom = -60, right = 280, boxColour = ClutColour(10, 8) },
				{ top = -70, left = -280, bottom = -110, right = 280, boxColour = ClutColour(16, 6) },
				{ xCoord = -280, yCoord = -205, length = 100, text = "nodraw", boxColour = ClutColour(3, 6), textColour = ClutColour(13, 9), execute = function() mode_manager.switch("Ares/Options") end, letter = "CANCEL" },
				{ xCoord = -265, yCoord = 170, length = 63, text = "nodraw", boxColour = ClutColour(10, 4), textColour = ClutColour(10, 8), execute = function() keyboardNum = 1; resetTabColours(keyboardNum + 3); switchTabs() end, letter = "Ship" },
				{ xCoord = -177, yCoord = 170, length = 93, text = "nodraw", boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = function() keyboardNum = 2; resetTabColours(keyboardNum + 3); switchTabs() end, letter = "Command" },
				{ xCoord = -54, yCoord = 170, length = 95, text = "nodraw", boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = function() keyboardNum = 3; resetTabColours(keyboardNum + 3); switchTabs() end, letter = "Shortcuts" },
				{ xCoord = 71, yCoord = 170, length = 71, text = "nodraw", boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = function() keyboardNum = 4; resetTabColours(keyboardNum + 3); switchTabs() end, letter = "Utility" },
				{ xCoord = 177, yCoord = 170, length = 87, text = "nodraw", boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = function() keyboardNum = 5; resetTabColours(keyboardNum + 3); switchTabs() end, letter = "HotKeys" },
				{ xCoord = 180, yCoord = -205, length = 100, text = "nodraw", boxColour = ClutColour(12, 6), textColour = ClutColour(13, 9), execute = function() mode_manager.switch("Ares/Options") end, letter = "DONE" } }

currPanel = {}
assignKey = false
keyboardNum = 1

function resetTabColours(tabNum)
	for i = 3, 8 do
		if i ~= tabNum then
			background[i].boxColour = ClutColour(10, 8)
		else
			background[i].boxColour = ClutColour(10, 4)
		end
	end
end

function switchTabs()
	rows = math.ceil((#keyboard[keyboardNum] + 1) / 2)
	num = 1
	local xCoord = 0
	local yShift = 0
	local adjust = 0
	
	currPanel = {}
	for i = 1, #keyboard[keyboardNum] - 1 do -- I should be doing this every time I switch, not every frame
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
		if currPanel ~= nil and currPanel ~= {} then
			currPanel[#currPanel + 1] = {
				xCoord = xCoord, yCoord = (math.ceil((#keyboard[keyboardNum] + 1) / 4) - (num - 1 - adjust)) * 36 + yShift,
				length = 245,
				text = keyboard[keyboardNum][num + 1].name,
				boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = nil,
				letter = keyboard[keyboardNum][num + 1].key }
		else
			currPanel = { { xCoord = xCoord, yCoord = (math.ceil((#keyboard[keyboardNum] + 1) / 4) - (num - 1 - adjust)) * 36 + yShift, length = 245, text = keyboard[keyboardNum][num + 1].name, boxColour = ClutColour(10, 8), textColour = ClutColour(10, 8), execute = nil, letter = keyboard[keyboardNum][num + 1].key } }
		end
		num = num + 1
	end
end

function init()
	sound.stop_music()
	resetTabColours(3)
	graphics.set_camera(-240 * aspectRatio, -240, 240 * aspectRatio, 240)
end

function update()
	while background[num] ~= nil do
		if background[num].special == "click" then
			background[num].special = nil
		end
		num = num + 1
	end
	
	-- mouse button handling
	if mup then
		mup = false
		mousePos = input.mouse_position()
		mousePos.x = mousePos.x * 480 * aspectRatio - 240 * aspectRatio
		mousePos.y = mousePos.y * 480 - 240
		ChangeSpecialByLoc(mousePos, nil, background)
		-- here's what I want to do here:
		-- we need to do a similar check to ChangeSpecialByLoc, but if there's a
		-- button there (that's one of the keyboard bindings) then I need to pop
		-- up a dialogue to tell the user to press the new key for that function
		ChangeSpecialByLoc(mousePos, nil, currPanel)
	elseif mdown then
		mousePos = input.mouse_position()
		mousePos.x = mousePos.x * 480 * aspectRatio - 240 * aspectRatio
		mousePos.y = mousePos.y * 480 - 240
		ChangeSpecialByLoc(mousePos, "click", background)
		-- here's what I want to do here:
		-- we need to do a similar check to ChangeSpecialByLoc, but if there's a
		-- button there (that's one of the keyboard bindings) then I need to pop
		-- up a dialogue to tell the user to press the new key for that function
		ChangeSpecialByLoc(mousePos, "click", currPanel)
	end
end

function render()
	graphics.begin_frame()
	-- Background
	graphics.draw_image("Panels/PanelTop", { x = 0, y = 223 }, { x = 572, y = 28 })
	graphics.draw_image("Panels/PanelBottom", { x = 0, y = -229 }, { x = 572, y = 20 })
	graphics.draw_image("Panels/PanelLeft", { x = -302, y = -1 }, { x = 33, y = 476 })
	graphics.draw_image("Panels/PanelRight", { x = 303, y = -1 }, { x = 35, y = 476 })
	
	-- Background button drawing
	for num = 1, #background do
		SwitchBox(background[num])
	end
	
	-- Foreground button drawing
	for num = 1, #currPanel do
		SwitchBox(currPanel[num])
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

function ChangeBoxColour(box, match, shade)
	local num = 1
	while box[num] ~= nil do
		if box[num].letter == match then
			box[num].boxColour = ClutLighten(box[num].boxColour, shade)
		end
		num = num + 1
	end
end

function keyup(k)
	
end

function key(k)
	-- no key presses until I can assign them to values
	if assignKey then
		
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