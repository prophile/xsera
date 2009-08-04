import('GlobalVars')
import('PrintRecursive')
import('PopDownConsole')

splash_shift_left = -140
splash_shift_right = 138
top_of_splash = -28
fontsize = 22
splash_stride = 26
splash_num = 0

function init()
	sound.stop_music()
	clickable_box(splash_shift_left, top_of_splash - splash_num * splash_stride, splash_shift_right - splash_shift_left, "Start New Game", "left", c_lightRed, c_purple, nil, splash_shift_left + 60, "S")
--
	splash_num = splash_num + 1
	clickable_box(splash_shift_left, top_of_splash - splash_num * splash_stride, splash_shift_right - splash_shift_left, "Start Network Game", "left", c_lightRed, c_purple, nil, splash_shift_left + 60, "N")
	splash_num = splash_num + 1
	clickable_box(splash_shift_left, top_of_splash - splash_num * splash_stride, splash_shift_right - splash_shift_left, "Replay Intro", "left", c_lightRed, c_purple, nil, splash_shift_left + 60, "R")
	splash_num = splash_num + 1
	clickable_box(splash_shift_left, top_of_splash - splash_num * splash_stride, splash_shift_right - splash_shift_left, "Demo", "left", c_lightRed, c_purple, nil, splash_shift_left + 60, "D")
	splash_num = splash_num + 1
	clickable_box(splash_shift_left, top_of_splash - splash_num * splash_stride, splash_shift_right - splash_shift_left, "Options", "left", c_lightRed, c_purple, nil, splash_shift_left + 60, "O")
	splash_num = splash_num + 1
	clickable_box(splash_shift_left, top_of_splash - splash_num * splash_stride, splash_shift_right - splash_shift_left, "About Ares and Xsera", "left", c_lightRed, c_purple, nil, splash_shift_left + 60, "A")
	splash_num = splash_num + 1
	clickable_box(splash_shift_left, top_of_splash - splash_num * splash_stride, splash_shift_right - splash_shift_left, "Xsera Main Menu", "left", c_lightRed, c_purple, nil, splash_shift_left + 60, "M")
	splash_num = splash_num + 1
	clickable_box(splash_shift_left, top_of_splash - splash_num * splash_stride, splash_shift_right - splash_shift_left, "Quit", "left", c_lightRed, c_purple, nil, splash_shift_left + 60, "Q")
--]]
end

function update()
	
end

execs = {}

--[[
function clickable_box(top, bottom, left, right, text, justify, boxColor, textColor, execute, mid, letter)
	if mid ~= nil then
		if justify == "left" then
			start_point = { x = mid + 20, y = (top + bottom) / 2 }
		elseif justify == "right" then
			start_point = { x = right - 20, y = (top + bottom) / 2 }
		elseif justify == "center" then
			start_point = { x = (mid + right) / 2, y = (top + bottom) / 2 }
		end
	else
		if justify == "left" then
			start_point = { x = left + 20, y = (top + bottom) / 2 }
		elseif justify == "right" then
			start_point = { x = right - 20, y = (top + bottom) / 2 }
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
--]]

function clickable_box(coordx, coordy, length, text, justify, boxColor, textColor, execute, mid, letter)
	local num = 1
	if execs ~= nil then
		while execs[num] ~= nil do
			num = num + 1
		end
	end
	execs[num] = { coordx = coordx, coordy = coordy, length = length, text = text, justify = justify, boxColor = { r = boxColor.r, g = boxColor.g, b = boxColor.b, a = boxColor.a }, textColor = { r = textColor.r, g = textColor.g, b = textColor.b, a = textColor.a }, execute = execute, mid = mid, letter = letter }
end

function render()
	graphics.begin_frame()
	graphics.set_camera(-320, -240, 320, 240)
--	graphics.set_camera(-480, -320, 480, 320)
    graphics.draw_image("Panels/MainTop", 0, 118, 640, 245)
    graphics.draw_image("Panels/MainBottom", 0, -227, 640, 24)
    graphics.draw_image("Panels/MainLeft", -231, -110, 178, 211)
    graphics.draw_image("Panels/MainRight", 230, -110, 180, 211)
	if execs ~= nil then
		local num = 1
		while execs[num] ~= nil do
			-- inner box and details
			graphics.draw_box(execs[num].coordy + 13, execs[num].coordx + 11, execs[num].coordy + 5, execs[num].coordx + 10 + (execs[num].length - 20) / 3.5, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
			graphics.draw_box(execs[num].coordy + 13, execs[num].coordx + 11 + (execs[num].length - 20) / 3.5, execs[num].coordy + 5, execs[num].coordx + execs[num].length - 11, 0, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
			graphics.draw_text(execs[num].letter, "CrystalClear", "center", execs[num].coordx + 11 + (execs[num].length - 20) / 7, execs[num].coordy + 9, 13) 
			graphics.draw_text(execs[num].text, "CrystalClear", "center", execs[num].coordx + 11 + (execs[num].length - 20) / 3.5 + (execs[num].length - 20) * 5 / 14, execs[num].coordy + 9, 13) 
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