import('GlobalVars')
import('PrintRecursive')
import('PopDownConsole')

splash_shift_left = -140
splash_shift_right = 138
top_of_splash = -28
fontsize = 22
splash_stride = 26
splash_num = 0

local execs = {}

CYELLOW = { r = 0.7, g = 0.7, b = 0.4, a = 1.0 }
CDGREEN = { r = 0.1, g = 0.75, b = 0.1, a = 1.0 }
CGREY = { r = 0.6, b = 0.65, g = 0.55, a = 1.0 }
CGREYBROWN = { r = 0.7, b = 0.7, g = 0.7, a = 1.0 }
CLGREEN = { r = 0.3, g = 0.6, b = 0.3, a = 1.0 }

function init()
	sound.stop_music()
	local num = 1
	graphics.set_camera(-320, -240, 320, 240)
--	graphics.set_camera(-480, -360, 480, 360)
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Start New Game", justify = "left", boxColor = CYELLOW, textColor = c_purple, execute = nil, letter = "S" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Start Network Game", justify = "left", boxColor = CDGREEN, textColor = c_purple, execute = nil, letter = "N" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Replay Intro", justify = "left", boxColor = CGREY, textColor = c_purple, execute = nil, letter = "R" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Demo", justify = "left", boxColor = CGREYBROWN, textColor = c_purple, execute = nil, letter = "D" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Options", justify = "left", boxColor = CLGREEN, textColor = c_purple, execute = nil, letter = "O" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "About Ares and Xsera", justify = "left", boxColor = CGREYBROWN, textColor = c_purple, execute = nil, letter = "A" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Xsera Main Menu", justify = "left", boxColor = CYELLOW, textColor = c_purple, execute = nil, letter = "M" }
	num = num + 1
	execs[num] = { coordx = splash_shift_left, coordy = top_of_splash - (num - 1) * splash_stride, length = splash_shift_right - splash_shift_left, text = "Quit", justify = "left", boxColor = c_lightRed, textColor = c_purple, execute = nil, letter = "Q" }
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
		-- inner box and details
		graphics.draw_box(execs[num].coordy + 13, execs[num].coordx + 11, execs[num].coordy + 5, execs[num].coordx + 10 + (execs[num].length - 20) / 3.5, 0, execs[num].boxColor.r + 0.1, execs[num].boxColor.g + 0.1, execs[num].boxColor.b + 0.1, execs[num].boxColor.a + 0.1)
		graphics.draw_box(execs[num].coordy + 13, execs[num].coordx + 11 + (execs[num].length - 20) / 3.5, execs[num].coordy + 5, execs[num].coordx + execs[num].length - 11, 0, execs[num].boxColor.r - 0.1, execs[num].boxColor.g - 0.1, execs[num].boxColor.b - 0.1, execs[num].boxColor.a - 0.1)
		graphics.draw_text(execs[num].letter, "CrystalClear", "center", execs[num].coordx + 11 + (execs[num].length - 20) / 7, execs[num].coordy + 9, 13) 
		graphics.draw_text(execs[num].text, "CrystalClear", "center", execs[num].coordx + 11 + (execs[num].length - 20) * 9 / 14, execs[num].coordy + 9, 13) 
		-- frame boxes
		graphics.draw_box(execs[num].coordy + 5, execs[num].coordx, execs[num].coordy + 3, execs[num].coordx + 10, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
		graphics.draw_box(execs[num].coordy + 5, execs[num].coordx + execs[num].length - 10, execs[num].coordy + 3, execs[num].coordx + execs[num].length, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
		graphics.draw_box(execs[num].coordy + 3, execs[num].coordx, execs[num].coordy, execs[num].coordx + execs[num].length, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
		graphics.draw_box(execs[num].coordy + 15, execs[num].coordx, execs[num].coordy + 13, execs[num].coordx + 10, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
		graphics.draw_box(execs[num].coordy + 15, execs[num].coordx + execs[num].length - 10, execs[num].coordy + 13, execs[num].coordx + execs[num].length, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
		graphics.draw_box(execs[num].coordy + 18, execs[num].coordx, execs[num].coordy + 15, execs[num].coordx + execs[num].length, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
		graphics.draw_box(execs[num].coordy + 12, execs[num].coordx, execs[num].coordy + 6, execs[num].coordx + 10, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
		graphics.draw_box(execs[num].coordy + 12, execs[num].coordx + execs[num].length - 10, execs[num].coordy + 6, execs[num].coordx + execs[num].length, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
		num = num + 1
	end
	if errNotice ~= nil then
		graphics.draw_text(errNotice.text, "CrystalClear", "left", -310, 230, 20)
		if errNotice.start + errNotice.duration < mode_manager.time() then
			errNotice = nil
		end
	end
	graphics.end_frame()
end

function key(k)
	if k == "s" then
		mode_manager.switch("Demo2")
	elseif k == "n" then
		if release_build == true then
			sound.play("NaughtyBeep")
			errLog("This command currently has no code.", 10)
		else
			mode_manager.switch("Briefing")
		end
	elseif k == "r" then
		sound.play("NaughtyBeep")
		errLog("This command currently has no code.", 10)
	elseif k == "d" then
		sound.play("NaughtyBeep")
		errLog("This command currently has no code.", 10)
	elseif k == "m" then
		mode_manager.switch("MainMenu")
	elseif k == "o" then
		sound.play("NaughtyBeep")
		errLog("This command currently has no code.", 10)
	elseif k == "a" then
		mode_manager.switch("Credits")
	elseif k == "q" then
		os.exit()
	end
end