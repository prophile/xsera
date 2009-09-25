import('GlobalVars')
import('PrintRecursive')
import('Console')
import('BoxDrawing')

splash_shift_left = -140
splash_shift_right = 138
top_of_splash = -28
fontsize = 22
splash_stride = 26
splash_num = 0

local execs = {	{ coordx = splash_shift_left, coordy = top_of_splash, length = splash_shift_right - splash_shift_left, text = "Start New Game", justify = "left", boxColour = clut_colour(8, 6), textColour = clut_colour(13, 9), execute = nil, letter = "S" },
	{ coordx = splash_shift_left, coordy = top_of_splash - 1 * splash_stride, length = splash_shift_right - splash_shift_left, text = "Start Network Game", justify = "left", boxColour = clut_colour(5, 5), textColour = clut_colour(13, 9), execute = nil, letter = "N" },
	{ coordx = splash_shift_left, coordy = top_of_splash - 2 * splash_stride, length = splash_shift_right - splash_shift_left, text = "Replay Intro", justify = "left", boxColour = clut_colour(1, 8), textColour = clut_colour(13, 9), execute = nil, letter = "R" },
	{ coordx = splash_shift_left, coordy = top_of_splash - 3 * splash_stride, length = splash_shift_right - splash_shift_left, text = "Demo", justify = "left", boxColour = clut_colour(1, 6), textColour = clut_colour(13, 9), execute = nil, letter = "D" },
	{ coordx = splash_shift_left, coordy = top_of_splash - 4 * splash_stride, length = splash_shift_right - splash_shift_left, text = "Options", justify = "left", boxColour = clut_colour(12, 6), textColour = clut_colour(13, 9), execute = nil, letter = "O" },
	{ coordx = splash_shift_left, coordy = top_of_splash - 5 * splash_stride, length = splash_shift_right - splash_shift_left, text = "About Ares and Xsera", justify = "left", boxColour = clut_colour(1, 6), textColour = clut_colour(13, 9), execute = nil, letter = "A" },
	{ coordx = splash_shift_left, coordy = top_of_splash - 6 * splash_stride, length = splash_shift_right - splash_shift_left, text = "Xsera Main Menu", justify = "left", boxColour = clut_colour(9, 6), textColour = clut_colour(13, 9), execute = nil, letter = "M" },
	{ coordx = splash_shift_left, coordy = top_of_splash - 7 * splash_stride, length = splash_shift_right - splash_shift_left, text = "Quit", justify = "left", boxColour = clut_colour(8, 4), textColour = clut_colour(13, 9), execute = nil, letter = "Q" } }

function init()
	sound.stop_music()
	local num = 1
	graphics.set_camera(-320, -240, 320, 240)
--	graphics.set_camera(-480, -360, 480, 360)
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
		switch_box(execs[num])
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

function keyup(k)
	if k == "s" then
		mode_manager.switch('Briefing')
	elseif k == "n" then
		sound.play('NaughtyBeep')
		errLog("This command currently has no code.", 10)
		local num = 1
		while execs[num] ~= nil do
			if execs[num].special == "click" then
				execs[num].special = nil
			end
			num = num + 1
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
		mode_manager.switch('Options')
	elseif k == "a" then
		mode_manager.switch('Credits')
	elseif k == "q" then
		os.exit()
	end
end

function key(k)
	if k == "s" then
		change_special("S", "click", execs)
	elseif k == "n" then
		change_special("N", "click", execs)
	elseif k == "r" then
		change_special("R", "click", execs)
	elseif k == "d" then
		change_special("D", "click", execs)
	elseif k == "m" then
		change_special("M", "click", execs)
	elseif k == "o" then
		change_special("O", "click", execs)
	elseif k == "a" then
		change_special("A", "click", execs)
	elseif k == "q" then
		change_special("Q", "click", execs)
	end
end