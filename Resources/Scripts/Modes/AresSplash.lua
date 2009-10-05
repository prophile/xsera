import('GlobalVars')
import('PrintRecursive')
import('Console')
import('BoxDrawing')

SPLASH_SHIFT_LEFT = -140
SPLASH_SHIFT_RIGHT = 138
TOP_OF_SPLASH = -28
SPLASH_STRIDE = 26

local execs = {	{ coordx = SPLASH_SHIFT_LEFT, coordy = TOP_OF_SPLASH, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Start New Game", justify = "left", boxColour = ClutColour(8, 6), textColour = ClutColour(13, 9), execute = nil, letter = "S" },
	{ coordx = SPLASH_SHIFT_LEFT, coordy = TOP_OF_SPLASH - 1 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Start Network Game", justify = "left", boxColour = ClutColour(5, 5), textColour = ClutColour(13, 9), execute = nil, letter = "N" },
	{ coordx = SPLASH_SHIFT_LEFT, coordy = TOP_OF_SPLASH - 2 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Replay Intro", justify = "left", boxColour = ClutColour(1, 8), textColour = ClutColour(13, 9), execute = nil, letter = "R" },
	{ coordx = SPLASH_SHIFT_LEFT, coordy = TOP_OF_SPLASH - 3 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Demo", justify = "left", boxColour = ClutColour(1, 6), textColour = ClutColour(13, 9), execute = nil, letter = "D" },
	{ coordx = SPLASH_SHIFT_LEFT, coordy = TOP_OF_SPLASH - 4 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Options", justify = "left", boxColour = ClutColour(12, 6), textColour = ClutColour(13, 9), execute = nil, letter = "O" },
	{ coordx = SPLASH_SHIFT_LEFT, coordy = TOP_OF_SPLASH - 5 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "About Ares and Xsera", justify = "left", boxColour = ClutColour(1, 6), textColour = ClutColour(13, 9), execute = nil, letter = "A" },
	{ coordx = SPLASH_SHIFT_LEFT, coordy = TOP_OF_SPLASH - 6 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Xsera Main Menu", justify = "left", boxColour = ClutColour(9, 6), textColour = ClutColour(13, 9), execute = nil, letter = "M" },
	{ coordx = SPLASH_SHIFT_LEFT, coordy = TOP_OF_SPLASH - 7 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Quit", justify = "left", boxColour = ClutColour(8, 4), textColour = ClutColour(13, 9), execute = nil, letter = "Q" } }

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
		LogError("This command currently has no code.", 10)
		local num = 1
		while execs[num] ~= nil do
			if execs[num].special == "click" then
				execs[num].special = nil
			end
			num = num + 1
		end
	elseif k == "r" then
		sound.play("NaughtyBeep")
		LogError("This command currently has no code.", 10)
		local num = 1
		while execs[num] ~= nil do
			if execs[num].special == "click" then
				execs[num].special = nil
			end
			num = num + 1
		end
	elseif k == "d" then
		sound.play("NaughtyBeep")
		LogError("This command currently has no code.", 10)
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