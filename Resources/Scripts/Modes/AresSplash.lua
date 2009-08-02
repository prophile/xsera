import('GlobalVars')
import('PrintRecursive')
import('PopDownConsole')

splash_shift_left = -140
splash_shift_right = 138
top_of_splash = -8
fontsize = 22
splash_stride = 26
splash_num = 0

function init()
	sound.stop_music()
	clickable_box(top_of_splash - splash_num * splash_stride, top_of_splash - splash_num * splash_stride - fontsize, splash_shift_left, splash_shift_right, "Start New Game", "left", c_lightRed, c_purple, nil, splash_shift_left + 20, "S")
	splash_num = splash_num + 1
	clickable_box(top_of_splash - splash_num * splash_stride, top_of_splash - splash_num * splash_stride - fontsize, splash_shift_left, splash_shift_right, "Start Network Game", "left", c_lightRed, c_purple, nil, splash_shift_left + 20, "N")
	splash_num = splash_num + 1
	clickable_box(top_of_splash - splash_num * splash_stride, top_of_splash - splash_num * splash_stride - fontsize, splash_shift_left, splash_shift_right, "Replay Intro", "left", c_lightRed, c_purple, nil, splash_shift_left + 20, "R")
	splash_num = splash_num + 1
	clickable_box(top_of_splash - splash_num * splash_stride, top_of_splash - splash_num * splash_stride - fontsize, splash_shift_left, splash_shift_right, "Demo", "left", c_lightRed, c_purple, nil, splash_shift_left + 20, "D")
	splash_num = splash_num + 1
	clickable_box(top_of_splash - splash_num * splash_stride, top_of_splash - splash_num * splash_stride - fontsize, splash_shift_left, splash_shift_right, "Options", "left", c_lightRed, c_purple, nil, splash_shift_left + 20, "O")
	splash_num = splash_num + 1
	clickable_box(top_of_splash - splash_num * splash_stride, top_of_splash - splash_num * splash_stride - fontsize, splash_shift_left, splash_shift_right, "About Ares and Xsera", "left", c_lightRed, c_purple, nil, splash_shift_left + 20, "A")
	splash_num = splash_num + 1
	clickable_box(top_of_splash - splash_num * splash_stride, top_of_splash - splash_num * splash_stride - fontsize, splash_shift_left, splash_shift_right, "Xsera Main Menu", "left", c_lightRed, c_purple, nil, splash_shift_left + 20, "M")
	splash_num = splash_num + 1
	clickable_box(top_of_splash - splash_num * splash_stride, top_of_splash - splash_num * splash_stride - fontsize, splash_shift_left, splash_shift_right, "Quit", "left", c_lightRed, c_purple, nil, splash_shift_left + 20, "Q")
end

function update()
	
end

execs = {}

function clickable_box(top, bottom, left, right, text, justify, boxColor, textColor, execute, mid, letter)
	if mid ~= nil then
		if justify == "left" then
			start_point = { x = left + 30, y = (top + bottom) / 2 }
		elseif justify == "right" then
			start_point = { x = right - 30, y = (top + bottom) / 2 }
		elseif justify == "center" then
			start_point = { x = (left + 30 + right) / 2, y = (top + bottom) / 2 }
		end
	else
		if justify == "left" then
			start_point = { x = left + 10, y = (top + bottom) / 2 }
		elseif justify == "right" then
			start_point = { x = right - 10, y = (top + bottom) / 2 }
		elseif justify == "center" then
			start_point = { x = (left + right) / 2, y = (top + bottom) / 2 }
		end
	end
	local num = 1
	if execs ~= nil then
		while execs[num] ~= nil do
			num = num + 1
		end
	end
	execs[num] = { top = top, bottom = bottom, left = left, right = right, text = text, justify = justify, boxColor = { r = boxColor.r, g = boxColor.g, b = boxColor.b, a = boxColor.a }, textColor = { r = textColor.r, g = textColor.g, b = textColor.b, a = textColor.a }, execute = execute, mid = mid, letter = letter, start_point = start_point }
end

function render()
	graphics.begin_frame()
	graphics.set_camera(-320, -240, 320, 240)
    graphics.draw_image("Panels/MainTop", 0, 118, 640, 245)
    graphics.draw_image("Panels/MainBottom", 0, -227, 640, 24)
    graphics.draw_image("Panels/MainLeft", -231, -110, 178, 211)
    graphics.draw_image("Panels/MainRight", 230, -110, 180, 211)
	if execs ~= nil then
		local num = 1
		while execs[num] ~= nil do
			graphics.draw_box(execs[num].top, execs[num].left, execs[num].bottom, execs[num].right, 1, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
			graphics.draw_text(execs[num].text, "CrystalClear", execs[num].justify, execs[num].start_point.x, execs[num].start_point.y, execs[num].top -execs[num].bottom - 2) -- execs[num].textColor.r, execs[num].textColor.g, execs[num].textColor.b, execs[num].textColor.a) (put in when text coloring is implemented)
			if execs[num].mid ~= nil then
				graphics.draw_line(execs[num].mid, execs[num].top, execs[num].mid, execs[num].bottom, 1, execs[num].boxColor.r + 0.3, execs[num].boxColor.g + 0.3, execs[num].boxColor.b + 0.3, execs[num].boxColor.a + 0.3)
				graphics.draw_text(execs[num].letter, "CrystalClear", "center", (execs[num].left + execs[num].mid) / 2, execs[num].start_point.y, execs[num].top - execs[num].bottom - 2) -- execs[num].textColor.r, execs[num].textColor.g, execs[num].textColor.b, execs[num].textColor.a) [TEXTCOLOR]
			end
			num = num + 1
		end
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
		sound.play("NaughtyBeep")
		errLog("This command currently has no code.", 10)
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