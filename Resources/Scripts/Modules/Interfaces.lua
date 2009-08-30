-- temp import - pushing to demo soon, I want to make sure interfaces gets all it needs
import('PrintRecursive')
import('GlobalVars')
import('EntityLoad')
import('Math')
import('Panels')
import('PopDownConsole')
import('CaptainAI')
import('BoxDrawing')
import('KeyboardControl')

function interface_display(menu_display, down)
	if menu_display ~= nil then
		if menu_display == "esc_menu" then
			drawEscapeMenu()
		elseif menu_display == "defeat_menu" then
			drawDefeatMenu()
		elseif menu_display == "info_menu" then
			drawInfoMenu()
		elseif menu_display == "victory_menu" then
			drawVictoryMenu()
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
		mode_manager.switch('Demo2')
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
		mode_manager.switch('Demo2')
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
	while key_menu[num] ~= nil do
		local subnum = 1
		graphics.draw_box(line_num * -15 + 260, -257, line_num * -15 + 245, 277, 0, c_grey)
		graphics.draw_text(key_menu[num][1], "CrystalClear", "left", -252, line_num * -15 + 253, 16)
		line_num = line_num + 1
		local xcoord = 0
		local yshift = 0
		local adjust = 0
		local numBoxes = 1
		while key_menu[num][numBoxes] ~= nil do
			numBoxes = numBoxes + 1
		end
		local rows = math.ceil(numBoxes / 2)
		while key_menu[num][subnum + 1] ~= nil do
			if subnum % rows ~= subnum then
				xcoord = 50
				adjust = (rows - 1) * 15
			else
				adjust = 0
				xcoord = -212
			end
			graphics.draw_text(key_menu[num][subnum + 1].name, "CrystalClear", "left", xcoord, line_num * -15 + 254 + adjust, 16)
			if key_menu[num][subnum + 1].key_display == nil then
				graphics.draw_text(key_menu[num][subnum + 1].key, "CrystalClear", "center", xcoord - 24, line_num * -15 + 254 + adjust, 16)
			else
				graphics.draw_text(key_menu[num][subnum + 1].key_display, "CrystalClear", "center", xcoord - 24, line_num * -15 + 254 + adjust, 16)
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