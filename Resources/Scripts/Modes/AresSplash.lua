import('GlobalVars')
import('PrintRecursive')
import('Console')

splash_shift_left = -140
splash_shift_right = 138
top_of_splash = -28
fontsize = 22
splash_stride = 26
splash_num = 0

local execs = {}

function init()
	sound.stop_music()
	local num = 1
	graphics.set_camera(-320, -240, 320, 240)
--	graphics.set_camera(-480, -360, 480, 360)
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Start New Game", justify = "left", boxColour = c_lightYellow, textColor = c_purple, execute = nil, letter = "S" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Start Network Game", justify = "left", boxColour = CDGREEN, textColor = c_purple, execute = nil, letter = "N" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Replay Intro", justify = "left", boxColour = CGREY, textColor = c_purple, execute = nil, letter = "R" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Demo", justify = "left", boxColour = CGREYBROWN, textColor = c_purple, execute = nil, letter = "D" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Options", justify = "left", boxColour = c_lightGreen, textColor = c_purple, execute = nil, letter = "O" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "About Ares and Xsera", justify = "left", boxColour = CGREYBROWN, textColor = c_purple, execute = nil, letter = "A" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Xsera Main Menu", justify = "left", boxColour = c_lightYellow, textColor = c_purple, execute = nil, letter = "M" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Quit", justify = "left", boxColour = c_lightRed, textColor = c_purple, execute = nil, letter = "Q" }
end

function update()

end

function render()
	graphics.begin_frame()
    graphics.draw_image("Panels/MainTop", 0, 118, 640, 245)
    graphics.draw_image("Panels/MainBottom", 0, -227, 640, 24)
    graphics.draw_image("Panels/MainLeft", -231, -110, 178, 211)
    graphics.draw_image("Panels/MainRight", 230, -110, 180, 211)
	local num = 1
	while execs[num] ~= nil do
		local col_mix = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }
		if execs[num].special ~= nil then
			if execs[num].special == "click" then
				col_mix = { r = 0.1, g = 0.1, b = 0.1, a = 1.0 }
				draw_interface_box(execs[num], c_black, col_mix)
			elseif execs[num].special == "disabled" then
				col_mix = { r = -0.3, g = -0.3, b = -0.3, a = 1.0 }
				draw_interface_box(execs[num], col_mix, col_mix)
			end
		else
			draw_interface_box(execs[num], c_black, c_black)
		end
		num = num + 1
	end
	-- Error Printing
	if errNotice ~= nil then
		graphics.draw_text(errNotice.text, "CrystalClear", "left", -315, 225, 28)
		if errNotice.start + errNotice.duration < mode_manager.time() then
			errNotice = nil
		end
	end
	graphics.end_frame()
end

function draw_interface_box(box, col_mod_all, col_mod_click)
	-- inner box and details
	if box.text ~= " " then
		graphics.draw_box(box.coordy + 13, box.coordx + 11, box.coordy + 5, box.coordx + 10 + (box.length - 20) / 3.5, 0, colour_add(box.boxColour, c_lighten, col_mod_all))
		graphics.draw_box(box.coordy + 13, box.coordx + 11 + (box.length - 20) / 3.5, box.coordy + 5, box.coordx + box.length - 11, 0, colour_add(box.boxColour, c_darken, col_mod_click))
		graphics.draw_text(box.text, "CrystalClear", "center", box.coordx + 11 + (box.length - 20) / 3.5 + (box.length - 20) * 5 / 14, box.coordy + 9, 14, colour_add(box.boxColour, c_lighten, col_mod_all)) 
	else
		graphics.draw_box(box.coordy + 13, box.coordx + 11, box.coordy + 5, box.coordx + 10 + (box.length - 20) / 3.5, 0, colour_add(box.boxColour, c_darken))
		graphics.draw_box(box.coordy + 13, box.coordx + 11 + (box.length - 20) / 3.5, box.coordy + 5, box.coordx + box.length - 11, 0, colour_add(box.boxColour, c_lighten))
	end
	if box.special ~= "disabled" then
		graphics.draw_text(box.letter, "CrystalClear", "center", box.coordx + 11 + (box.length - 20) / 7, box.coordy + 9, 14) 
	end
	-- frame boxes
	graphics.draw_box(box.coordy + 5, box.coordx, box.coordy + 3, box.coordx + 10, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 5, box.coordx + box.length - 10, box.coordy + 3, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 3, box.coordx, box.coordy, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 15, box.coordx, box.coordy + 13, box.coordx + 10, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 15, box.coordx + box.length - 10, box.coordy + 13, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 18, box.coordx, box.coordy + 15, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 12, box.coordx, box.coordy + 6, box.coordx + 10, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 12, box.coordx + box.length - 10, box.coordy + 6, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	-- under box, if it exists
	if box.underbox ~= nil then
		-- left side
		graphics.draw_box(box.coordy - 1, box.coordx, (box.coordy + box.underbox + 4) / 2, box.coordx + 10, 0, box.boxColour)
		graphics.draw_box((box.coordy + box.underbox + 2) / 2, box.coordx, box.underbox + 4, box.coordx + 10, 0, colour_add(box.boxColour, c_darken))
		-- right side
		graphics.draw_box(box.coordy - 1, box.coordx + box.length - 10, (box.coordy + box.underbox + 4) / 2, box.coordx + box.length, 0, box.boxColour)
		graphics.draw_box((box.coordy + box.underbox + 2) / 2, box.coordx + box.length - 10, box.underbox + 4, box.coordx + box.length, 0, colour_add(box.boxColour, c_darken))
		-- bottom
		graphics.draw_box(box.underbox + 3, box.coordx, box.underbox, box.coordx + box.length, 0, box.boxColour)
	end
end

function keyup(k)
	if k == "s" then
		mode_manager.switch('Demo2')
	elseif k == "n" then
		if release_build == true then
			sound.play('NaughtyBeep')
			errLog("This command currently has no code.", 10)
			local num = 1
			while execs[num] ~= nil do
				if execs[num].special == "click" then
					execs[num].special = nil
				end
				num = num + 1
			end
		else
			mode_manager.switch('Briefing')
		end
	elseif k == "r" then
		sound.play("NaughtyBeep")
		errLog("This command currently has no code.", 10)
		local num = 1
		while execs[num] ~= nil do
			if execs[num].special == "click" then
				execs[num].special = nil
			end
			num = num + 1
		end
	elseif k == "d" then
		sound.play("NaughtyBeep")
		errLog("This command currently has no code.", 10)
		local num = 1
		while execs[num] ~= nil do
			if execs[num].special == "click" then
				execs[num].special = nil
			end
			num = num + 1
		end
	elseif k == "m" then
		mode_manager.switch('MainMenu')
	elseif k == "o" then
		sound.play("NaughtyBeep")
		errLog("This command currently has no code.", 10)
		local num = 1
		while execs[num] ~= nil do
			if execs[num].special == "click" then
				execs[num].special = nil
			end
			num = num + 1
		end
	elseif k == "a" then
		mode_manager.switch('Credits')
	elseif k == "q" then
		os.exit()
	end
end

function key(k)
	if k == "s" then
		local num = 1
		while execs[num] ~= nil do
			if execs[num].letter == "S" then
				execs[num].special = "click"
			end
			num = num + 1
		end
	elseif k == "n" then
		local num = 1
		while execs[num] ~= nil do
			if execs[num].letter == "N" then
				execs[num].special = "click"
			end
			num = num + 1
		end
	elseif k == "r" then
		local num = 1
		while execs[num] ~= nil do
			if execs[num].letter == "R" then
				execs[num].special = "click"
			end
			num = num + 1
		end
	elseif k == "d" then
		local num = 1
		while execs[num] ~= nil do
			if execs[num].letter == "D" then
				execs[num].special = "click"
			end
			num = num + 1
		end
	elseif k == "m" then
		local num = 1
		while execs[num] ~= nil do
			if execs[num].letter == "M" then
				execs[num].special = "click"
			end
			num = num + 1
		end
	elseif k == "o" then
		local num = 1
		while execs[num] ~= nil do
			if execs[num].letter == "O" then
				execs[num].special = "click"
			end
			num = num + 1
		end
	elseif k == "a" then
		local num = 1
		while execs[num] ~= nil do
			if execs[num].letter == "A" then
				execs[num].special = "click"
			end
			num = num + 1
		end
	elseif k == "q" then
		local num = 1
		while execs[num] ~= nil do
			if execs[num].letter == "Q" then
				execs[num].special = "click"
			end
			num = num + 1
		end
	end
end