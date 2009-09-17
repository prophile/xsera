import('PrintRecursive')
import('GlobalVars')
import('EntityLoad')
import('BoxDrawing')

loading_entities = true
if scen == nil then
	scen = NewEntity(nil, "demo", "Scenario")
end
loading_entities = false

control = scen.planet -- [HARDCODED]
target = nil

menu_shift = -391
top_of_menu = -69
menu_stride = -11
ship_selected = false
menu_shipyard = { "BUILD", {} }

function make_ship()
	shipBuilding = { p = shipQuerying.p, n = shipQuerying.n, r = shipQuerying.r, c = shipQuerying.c, t = shipQuerying.t }
	if shipBuilding.c > cash or scen.planet.buildqueue.percent ~= 100 then
		sound.play("NaughtyBeep")
		return
	end
	scen.planet.buildqueue.factor = shipBuilding.t
	scen.planet.buildqueue.time = mode_manager.time()
	scen.planet.buildqueue.current = mode_manager.time() - scen.planet.buildqueue.time
	cash = cash - shipBuilding.c
	build_timer_running = true
end

function shipyard()
	menu_level = menu_shipyard
	local num = 1
	while scen.planet.build[num] ~= nil do
		menu_shipyard[num + 1] = {}
		menu_shipyard[num + 1][1] = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%2")
		if num ~= 1 then
			menu_shipyard[num + 1][2] = false
		else
			menu_shipyard[num + 1][2] = true
			ship_selected = true
			shipQuerying.p = scen.planet
			shipQuerying.n = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%2")
			shipQuerying.r = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%1")
			shipQuerying.c = scen.planet.buildCost[num]
			shipQuerying.t = scen.planet.buildTime[num]
		end
		menu_shipyard[num + 1][3] = make_ship
		menu_shipyard[num + 1][4] = {}
		menu_shipyard[num + 1][4][1] = scen.planet
		menu_shipyard[num + 1][4][2] = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%2")
		menu_shipyard[num + 1][4][3] = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%1")
		num = num + 1
	end
	ship_selected = true
end

menu_special = { "SPECIAL ORDERS",
	{ "Transfer Control", true, transfer_control },
	{ "Hold Position", false, hold_position },
	{ "Go To My Position", false, go_to_my_position },
	{ "Fire Weapon 1", false, fire_weapon_1 },
	{ "Fire Weapon 2", false, fire_weapon_2 },
	{ "Fire Special", false, fire_special }
}

function special()
	menu_level = menu_special
end

menu_messages = { "MESSAGES",
	{ "Next Page/Clear", true, next_page_clear },
	{ "Previous Page", false, previous_page },
	{ "Last Message", false, last_message }
}

function messages()
	menu_level = menu_messages
end

function mission_status()
	menu_level = { "MISSION STATUS",
		{ scen.briefing, false } }
end

menu_options = { "MAIN MENU",
	{ "<Build>", true, shipyard },
	{ "<Special Orders>", false, special },
	{ "<Messages>", false, messages },
	{ "<Mission Status>", false, mission_status }
}
menu_level = menu_options

function interface_display(dt)
	if menu_display ~= nil then
		if menu_display == "esc_menu" then
			drawEscapeMenu()
		elseif menu_display == "defeat_menu" then
			drawDefeatMenu()
		elseif menu_display == "info_menu" then
			drawInfoMenu()
		elseif menu_display == "victory_menu" then
			drawVictoryMenu()
		elseif menu_display == "pause_menu" then
			drawPauseMenu(dt)
		end
	end
end

function drawEscapeMenu()
	switch_box( { top = 85, left = -140, bottom = -60, right = 140, boxColour = c_teal } )
	graphics.draw_text("Resume, start chapter over, or quit?", "CrystalClear", "left", -125, 65, 16)
	if down.esc == true then
		switch_box( { coordx = -125, coordy = 30, length = 250, text = "Resume", boxColour = colour_add(c_lightGreen, c_lighten), textColour = c_lightGreen, execute = nil, letter = "ESC" } )
	elseif down.esc == "act" then
		keyup = normal_keyup
		key = normal_key
		down.esc = false
		menu_display = nil
	else
		switch_box( { coordx = -125, coordy = 30, length = 250, text = "Resume", boxColour = c_lightGreen, textColour = c_lightGreen, execute = nil, letter = "ESC" } )
	end
	if down.rtrn == true then
		switch_box( { coordx = -125, coordy = 0, length = 250, text = "Start Chapter Over", boxColour = colour_add(c_lightYellow, c_lighten), textColour = c_lightYellow, execute = nil, letter = "RTRN" } )
	elseif down.rtrn == "act" then
		mode_manager.switch('Demo3')
		down.rtrn = false
	else
		switch_box( { coordx = -125, coordy = 0, length = 250, text = "Start Chapter Over", boxColour = c_lightYellow, textColour = c_lightYellow, execute = nil, letter = "RTRN" } )
	end
	if down.q == true then
		switch_box( { coordx = -125, coordy = -30, length = 250, text = "Quit to Main Menu", boxColour = colour_add(c_lightRed, c_lighten), textColour = c_lightRed, execute = nil, letter = "Q" } )
	elseif down.q == "act" then
		menu_display = nil
		mode_manager.switch('MainMenu')
	else
		switch_box( { coordx = -125, coordy = -30, length = 250, text = "Quit to Main Menu", boxColour = c_lightRed, textColour = c_lightRed, execute = nil, letter = "Q" } )
	end
end

function drawDefeatMenu()
	switch_box( { top = 85, left = -140, bottom = -60, right = 140, boxColour = c_rust } )
	graphics.draw_text("You lost your Heavy Cruiser and failed.", "CrystalClear", "left", -125, 26, 16)
	graphics.draw_text("Start chapter over, or quit?", "CrystalClear", "left", -125, 10, 16)
	if down.rtrn == true then
		switch_box( { coordx = -125, coordy = -20, length = 250, text = "Start Chapter Over", boxColour = colour_add(c_lightYellow, c_lighten), textColour = c_lightYellow, execute = nil, letter = "RTRN" } )
	elseif down.rtrn == "act" then
		menu_display = nil
		mode_manager.switch('Demo3')
	else
		switch_box( { coordx = -125, coordy = -20, length = 250, text = "Start Chapter Over", boxColour = c_lightYellow, textColour = c_lightYellow, execute = nil, letter = "RTRN" } )
	end
	if down.q == true then
		switch_box( { coordx = -125, coordy = -50, length = 250, text = "Quit to Main Menu", boxColour = colour_add(c_lightRed, c_lighten), textColour = c_lightRed, execute = nil, letter = "Q" } )
	elseif down.q == "act" then
		menu_display = nil
		mode_manager.switch('MainMenu')
	else
		switch_box( { coordx = -125, coordy = -50, length = 250, text = "Quit to Main Menu", boxColour = c_lightRed, textColour = c_lightRed, execute = nil, letter = "Q" } )
	end
end

stored_time = 0.0

function drawVictoryMenu()
	switch_box( { coordx = -125, coordy = 100, length = 290, text = " ", boxColour = c_yellow, textColour = c_yellow, execute = nil, letter = "Results", underbox = -100 } )
	graphics.draw_text("You did it! Congratulations!", "CrystalClear", "left", -110, 90, 16)
	switch_box( { top = 31, left = -75, bottom = -50, right = 115, boxColour = c_yellow, background = c_darkYellow } )
	local startx = 113
	local starty = 28
	local xcheck = 1
	local ycheck = 1
	local xshift = 0
	local xlength = 0
	while endGameData[ycheck] ~= nil do
		local xcheck = 1
		while endGameData[ycheck][xcheck] ~= nil do
			if xcheck == 1 then
				xcoord = 121
				xlength = 64
			else
				xcoord = 60 * (3 - xcheck) + 1
				xlength = 60
			end
			if endGameData[ycheck][xcheck][1] == true then
				if endGameData[ycheck][xcheck][2] ~= c_clear then
					graphics.draw_box(starty - (ycheck - 1) * 15, startx - xcoord - xlength, starty - ycheck * 15, startx - xcoord, 0, endGameData[ycheck][xcheck][2])
					graphics.draw_text(endGameData[ycheck][xcheck][3], "CrystalClear", "left", startx - xcoord - xlength + 2, starty - (ycheck - 1) * 15 - 6, 16)
				else
					graphics.draw_text(endGameData[ycheck][xcheck][3], "CrystalClear", "left", startx - xcoord - xlength + 2, starty - (ycheck - 1) * 15 - 6, 16)
				end
			else
				stored_time = stored_time + dt
				if stored_time >= 0.07 then
					stored_time = stored_time - 0.07
					if endGameData[ycheck][xcheck][1] == "inprogress" then
						if position == nil then
							position = 1
						end
						if position == 1 then
							graphics.draw_box(starty - (ycheck - 1) * 15, startx - xcoord - xlength / 2 - 5, starty - ycheck * 15, startx - xcoord - xlength / 2 + 5, 0, c_yellow)
							position = 2
						elseif position == 2 then
							graphics.draw_box(starty - (ycheck - 1) * 15, startx - xcoord - 10, starty - ycheck * 15, startx - xcoord, 0, c_yellow)
							endGameData[ycheck][xcheck][1] = true
							position = nil
						end
						sound.play("ITeletype")
					elseif endGameData[ycheck][xcheck][1] == false then
						endGameData[ycheck][xcheck][1] = "inprogress"
						sound.play("ITeletype")
						graphics.draw_box(starty - (ycheck - 1) * 15, startx - xcoord - xlength, starty - ycheck * 15, startx - xcoord - xlength + 10, 0, c_yellow)
					end
				end
				ycheck = 5
				xcheck = 4
			end
			xcheck = xcheck + 1
		end
		ycheck = ycheck + 1
	end
end

function drawInfoMenu()
	switch_box( { top = 250, left = -260, bottom = -250, right = 280, boxColour = c_grey } )
	if down.esc == true then
		switch_box( { coordx = -255, coordy = -240, length = 530, text = "Done", boxColour = colour_add(c_grey, c_lighten), textColour = c_grey, execute = nil, letter = "ESC" } )
	elseif down.esc == "act" then
		keyup = normal_keyup
		key = normal_key
		down.esc = false
		menu_display = nil
	else
		switch_box( { coordx = -255, coordy = -240, length = 530, text = "Done", boxColour = c_grey, textColour = c_grey, execute = nil, letter = "ESC" } )
	end
	local x = 245
	local col_switch = true
	while x - 15 >= -188 do
		if col_switch == false then
			col_switch = true
			graphics.draw_box(x, -257, x - 15, 277, 0, c_red)
		else
			col_switch = false
			graphics.draw_box(x, -257, x - 15, 277, 0, c_darkRed)
		end
		graphics.draw_box(x, -257, x - 15, -217, 0, c_pureRed)
		graphics.draw_box(x, 5, x - 15, 45, 0, c_pureRed)
		x = x - 15
	end
	local num = 1
	local line_num = 1
	while keyboard[num] ~= nil do
		local subnum = 1
		graphics.draw_box(line_num * -15 + 260, -257, line_num * -15 + 245, 277, 0, c_grey)
		graphics.draw_text(keyboard[num][1], "CrystalClear", "left", -252, line_num * -15 + 253, 16)
		line_num = line_num + 1
		local xcoord = 0
		local yshift = 0
		local adjust = 0
		local numBoxes = 1
		while keyboard[num][numBoxes] ~= nil do
			numBoxes = numBoxes + 1
		end
		local rows = math.ceil(numBoxes / 2)
		while keyboard[num][subnum + 1] ~= nil do
			if subnum % rows ~= subnum then
				xcoord = 50
				adjust = (rows - 1) * 15
			else
				adjust = 0
				xcoord = -212
			end
			graphics.draw_text(keyboard[num][subnum + 1].name, "CrystalClear", "left", xcoord, line_num * -15 + 254 + adjust, 16)
			if keyboard[num][subnum + 1].key_display == nil then
				graphics.draw_text(keyboard[num][subnum + 1].key, "CrystalClear", "center", xcoord - 24, line_num * -15 + 254 + adjust, 16)
			else
				graphics.draw_text(keyboard[num][subnum + 1].key_display, "CrystalClear", "center", xcoord - 24, line_num * -15 + 254 + adjust, 16)
			end
			line_num = line_num + 1
			subnum = subnum + 1
		end
		if numBoxes % 2 == 0 then
			line_num = line_num - rows + 1
		else
			line_num = line_num - rows + 2
		end
		num = num + 1
	end
end

local time_elapsed = 0

function drawPauseMenu(dt)
	if down.o == true then
		menu_display = nil
		return
	end
	time_elapsed = time_elapsed + dt
	if time_elapsed % 0.8 > 0.4 then
		switch_box( { top = 20, left = -80, bottom = -20, right = 140, boxColour = c_green, background = c_half_clear } )
		graphics.draw_text("> CAPS LOCK - PAUSED <", "CrystalClear", "center", 30, 0, 23, c_green)
	end
end

menu_level = menu_options

function drawPanels()
	graphics.set_camera(-400, -300, 400, 300)
	graphics.draw_image("Panels/SideLeft", -346, 0, 109, 607)
	graphics.draw_image("Panels/SideRight", 387, -2, 26, 608)

--[[------------------
	Right Panel
------------------]]--

-- Battery (red)
	graphics.draw_box(107, 379, 29, 386, 0, c_red)
	graphics.draw_box(playerShip.battery.percent * 78 + 29, 379, 29, 386, 0, c_lightRed)
-- Energy (yellow)
	graphics.draw_box(6, 379, -72.5, 386, 0, c_yellow)
	graphics.draw_box(playerShip.energy.percent * 78.5 - 72.5, 379, -72.5, 386, 0, c_lightYellow)
-- Shield (blue)
	graphics.draw_box(-96, 379, -173, 386, 0, c_lightBlue)
	graphics.draw_box(playerShip.shield.percent * 77 - 173, 379, -173, 386, 0, c_blue)
-- Factory resources (green - mostly)
	count = 1
	if ship_selected == true then
		if cash >= shipQuerying.c then
			local drawGreen = math.floor((cash - shipQuerying.c) / 200)
			local drawBlue = math.ceil((shipQuerying.c) / 200) + drawGreen
		--	print(count, "=>", drawGreen, "-[", ((cash - shipQuerying.c) / 200), "]-")
			while count <= drawGreen do
				graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, clut_colour(12, 3))
				count = count + 1
			end
		--	print(count, drawGreen, drawBlue)
			while count <= drawBlue do
				graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, clut_colour(14, 5))
				count = count + 1
			end
		--	print(count, drawBlue)
		else
			local drawGreen = math.floor(cash / 200)
			local drawRed = math.ceil(shipQuerying.c / 200)
		--	print(count, "=>", drawGreen, "-[", (cash / 200), "]-")
			while count <= drawGreen do
				graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, clut_colour(12, 3))
				count = count + 1
			end
		--	print(count, drawGreen, drawRed)
			while count <= drawRed do
				graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, clut_colour(2, 9))
				count = count + 1
			end
		--	print(count, drawRed)
		end
	end
	while count <= 100 do
		if count > resources then
			graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, clut_colour(12, 14))
		else
			graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, clut_colour(12, 3))
		end
		count = count + 1
	end
-- Factory resource bars (yellow)
	count = 1
	while count <= 7 do
		if count <= resource_bars then
			graphics.draw_box(154.5 - 4.5 * count, 384, 151 - 4.5 * count, 392, 0, clut_colour(3, 3))
		else
			graphics.draw_box(154.5 - 4.5 * count, 384, 151 - 4.5 * count, 392, 0, clut_colour(9, 13))
		end
		count = count + 1
	end
-- Factory build bar (purple)
	planet = scen.planet
	if planet ~= nil then
		graphics.draw_line(382, 181, 392, 181, 0.5, clut_colour(13, 9))
		graphics.draw_line(382, 181, 382, 177, 0.5, clut_colour(13, 9))
		graphics.draw_line(392, 177, 392, 181, 0.5, clut_colour(13, 9))
		graphics.draw_line(382, 159, 392, 159, 0.5, clut_colour(13, 9))
		graphics.draw_line(382, 163, 382, 159, 0.5, clut_colour(13, 9))
		graphics.draw_line(392, 159, 392, 163, 0.5, clut_colour(13, 9))
		graphics.draw_box(179, 384, 161, 390, 0, clut_colour(13, 9))
		graphics.draw_box(18 * (100 - planet.buildqueue.percent) / 100 + 161, 384, 161, 390, 0, clut_colour(13, 5))
	end
	
--[[------------------
	Left Panel
------------------]]--
	
-- Radar box (green)
	graphics.draw_box(184, -394, 100, -303, 1, c_green5)
-- Communications panels (green)
	graphics.draw_box(-63, -393, -158, -297, 0, c_green5)
	graphics.draw_line(-391, -74, -298, -74, 1, c_lightGreen2)
	graphics.draw_box(-165, -389.5, -185.5, -304, 0, c_green5)
-- Menu drawing
	local shift = 1
	local num = 1
	graphics.draw_text(menu_level[1], "CrystalClear", "left", menu_shift, top_of_menu, 13)
	while menu_level[num] ~= nil do
		if menu_level[num][1] ~= nil then
			if menu_level[num][2] == true then
				graphics.draw_box(top_of_menu + menu_stride * shift + 4, -392, top_of_menu + menu_stride * shift - 5, -298, 0, c_green3)
			end
			graphics.draw_text(menu_level[num][1], "CrystalClear", "left", menu_shift, top_of_menu + menu_stride * shift, 13)
			shift = shift + 1
		end
		num = num + 1
	end
	if text_being_drawn == true then
		graphics.draw_text(scen.text[textnum], "CrystalClear", "center", 0, -250, 30)
	end
-- Weapon (special) ammo count
	graphics.draw_text(string.format('%03d', playerShip.special.ammo), "CrystalClear", "left", -314, 60, 13, c_laserGreen)
	control = playerShip -- [HARDCODE]
	if control ~= nil then
		graphics.draw_box(49, -392, 40, -297, 0, c_lightYellow)
		graphics.draw_text("CONTROL", "CrystalClear", "left", -389, 44, 12, c_black)
		if control.type == "Planet" then
			graphics.draw_text(control.name, "CrystalClear", "left", -389, 35, 12)
		else
			graphics.draw_text(control.shortName, "CrystalClear", "left", -389, 35, 12)
		end
		if control.ctrlObject ~= nil then
			if control.owner == "Human/Ishiman" then
				graphics.draw_text(control.ctrlObject.name, "CrystalClear", "left", -389, 3, 12, c_green)
			else
				graphics.draw_text(control.ctrlObject.name, "CrystalClear", "left", -389, 3, 12, c_pureRed)
			end
		end
		if control.energy ~= nil then
			graphics.draw_line(-357, 28, -347, 28, 0.5, c_yellow)
			graphics.draw_line(-357, 27, -357, 28, 0.5, c_yellow)
			graphics.draw_line(-347, 27, -347, 28, 0.5, c_yellow)
			graphics.draw_line(-357, 9, -347, 9, 0.5, c_yellow)
			graphics.draw_line(-357, 10, -357, 9, 0.5, c_yellow)
			graphics.draw_line(-347, 10, -347, 9, 0.5, c_yellow)
			graphics.draw_box(27, -356, 10, -348, 0, c_yellow)
			graphics.draw_box(17 * control.energy.percent + 10, -356, 10, -348, 0, c_lightYellow)
		end
		if control.shield ~= nil then
			graphics.draw_line(-369, 28, -359, 28, 0.5, c_lightBlue)
			graphics.draw_line(-369, 27, -369, 28, 0.5, c_lightBlue)
			graphics.draw_line(-359, 27, -359, 28, 0.5, c_lightBlue)
			graphics.draw_line(-369, 9, -359, 9, 0.5, c_lightBlue)
			graphics.draw_line(-369, 10, -369, 9, 0.5, c_lightBlue)
			graphics.draw_line(-359, 10, -359, 9, 0.5, c_lightBlue)
			graphics.draw_box(27, -367.5, 10, -360, 0, c_lightBlue)
			graphics.draw_box(17 * control.shield.percent + 10, -367.5, 10, -360, 0, c_blue)
		end
		if control.type == "Planet" then
			graphics.draw_sprite(control.type .. "s/" .. control.image, -380, 19, 17, 17, 0)
		else
			graphics.draw_sprite(control.image, -380, 19, 17, 17, 3.14 / 2.0)
		end
		graphics.draw_line(-387, 28, -372, 28, 0.5, c_white)
		graphics.draw_line(-387, 27, -387, 28, 0.5, c_white)
		graphics.draw_line(-372, 27, -372, 28, 0.5, c_white)
		graphics.draw_line(-387, 9, -372, 9, 0.5, c_white)
		graphics.draw_line(-372, 10, -372, 9, 0.5, c_white)
		graphics.draw_line(-387, 10, -387, 9, 0.5, c_white)
	end
	if target ~= nil then
		graphics.draw_box(-8, -392, -17, -297, 0, c_lightBlue4)
		graphics.draw_text("TARGET", "CrystalClear", "left", -389, -13, 12, c_black)
		graphics.draw_line(-387, -32, -372, -32, 0.5, c_white)
		graphics.draw_line(-372, -34, -372, -32, 0.5, c_white)
		graphics.draw_line(-387, -34, -387, -32, 0.5, c_white)
		graphics.draw_line(-387, -49, -372, -49, 0.5, c_white)
		graphics.draw_line(-372, -47, -372, -49, 0.5, c_white)
		graphics.draw_line(-387, -47, -387, -49, 0.5, c_white)
	end
	graphics.draw_box(-165.5, -389.5, -175.5, -358, 0, c_lightBlue)
	graphics.draw_text("RIGHT", "CrystalClear", "left", -388, -170, 13, c_blue)
	graphics.draw_text("Select", "CrystalClear", "left", -354, -170, 13, c_blue)
	if menu_level ~= menu_options then
		graphics.draw_box(-175.5, -389.5, -185.5, -358, 0, c_lightBlue)
		graphics.draw_text("LEFT", "CrystalClear", "left", -388, -180, 13, c_blue)
		graphics.draw_text("Go Back", "CrystalClear", "left", -354, -180, 13, c_blue)
	end
end

-- Special Orders

function transfer_control()
	errLog("This command currently has no code.", 6)
	--[[ pseudocode!!! I don't have the concept of allies yet, need that before I can implement this
	if controlShip.ally == true then
		playerShip, controlShip = playerShip, controlShip
	end --]]
end

function hold_position()
	errLog("This command currently has no code.", 6)
end

function go_to_my_position()
	errLog("This command currently has no code.", 6)
end

function fire_weapon_1()
	errLog("This command currently has no code.", 6)
end

function fire_weapon_2()
	errLog("This command currently has no code.", 6)
end

function fire_special()
	errLog("This command currently has no code.", 6)
end

-- Message menu

text_being_drawn = false
text_was_drawn = false
textnum = 0

function next_page_clear()
	errLog("This command currently has no code.", 6)
	--[[
	if text_being_drawn == true then
		if scen.text[textnum + 1] ~= nil then
			textnum = textnum + 1
		else
			text_being_drawn = false
			text_was_drawn = true
		end
	else
		text_being_drawn = true
		textnum = textnum + 1
	end
	--]]
end

function previous_page()
	errLog("This command currently has no code.", 6)
	--[[
	if text_being_drawn == true then
		if textnum ~= 1 then
			textnum = textnum - 1
		else
			text_being_drawn = false
			textnum = 0
		end
	end
	--]]
end

function last_message()
	errLog("This command currently has no code.", 6)
	--[[
	if text_was_drawn == true then
		text_being_drawn = true
	end
	--]]
end

function change_menu(menu, direction)
	local num = 2
	if direction == "i" then
		while menu[num][2] ~= true do
			num = num + 1
		end
		if num ~= 2 then
			menu[num][2] = false
			num = num - 1
			menu[num][2] = true
			if menu == menu_shipyard then
				shipQuerying.p = menu_shipyard[num][4][1]
				shipQuerying.n = menu_shipyard[num][4][2]
				shipQuerying.r = menu_shipyard[num][4][3]
				shipQuerying.c = scen.planet.buildCost[num - 1]
				shipQuerying.t = scen.planet.buildTime[num - 1]
			end
		end
	elseif direction == "k" then
		while menu[num][2] ~= true do
			num = num + 1
		end
		if menu[num + 1] ~= nil then
			menu[num][2] = false
			num = num + 1
			menu[num][2] = true
			if menu == menu_shipyard then
				shipQuerying.p = menu_shipyard[num][4][1]
				shipQuerying.n = menu_shipyard[num][4][2]
				shipQuerying.r = menu_shipyard[num][4][3]
				shipQuerying.c = scen.planet.buildCost[num - 1]
				shipQuerying.t = scen.planet.buildTime[num - 1]
			end
		end
	elseif direction == "j" then
		if menu ~= menu_options then
			menu_level = menu_options
			ship_selected = false
		end
	elseif direction == "l" then
		while menu[num][2] ~= true do
			num = num + 1
		end
		if menu[num][3] ~= nil then
			menu[num][3]()
		end
	end
end