splash_shift = -135
top_of_splash = -14
fontsize = 18
splash_num = 0

function init()
	sound.stop_music()
end

function update()
	
end

execs = nil

function clickable_box(top, bottom, left, right, text, justify, boxColor, textColor, execute, mid, letter)
	if mid ~= nil then
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
	num = num - 1
	execs[num] = { top, bottom, left, right, text, justify, boxColor, textColor, execute, mid, letter, start_point }
end

function render()
	graphics.begin_frame()
	splash_num = 0
	graphics.set_camera(-320, -240, 320, 240)
    graphics.draw_image("Panels/MainTop", 0, 118, 640, 245)
    graphics.draw_image("Panels/MainBottom", 0, -227, 640, 24)
    graphics.draw_image("Panels/MainLeft", -231, -110, 178, 211)
    graphics.draw_image("Panels/MainRight", 230, -110, 180, 211)
	graphics.draw_text("P - Play", "CrystalClear", "left", splash_shift, top_of_splash + splash_num * (-fontsize - 1), fontsize)
	splash_num = splash_num + 1
	graphics.draw_text("M - Xsera Main Menu", "CrystalClear", "left", splash_shift, top_of_splash + splash_num * (-fontsize - 1), fontsize)
	splash_num = splash_num + 1
	graphics.draw_text("C - Xsera Credits", "CrystalClear", "left", splash_shift, top_of_splash + splash_num * (-fontsize - 1), fontsize)
	splash_num = splash_num + 1
	graphics.draw_text("Q - Quit", "CrystalClear", "left", splash_shift, top_of_splash + splash_num * (-fontsize - 1), fontsize)
	if execs ~= nil then
		local num = 1
		while execs[num] ~= nil do
			graphics.draw_box(execs[num].top, execs[num].left, execs[num].bottom, execs[num].right, 1, execs[num].boxColor.r, execs[num].boxColor.g, execs[num].boxColor.b, execs[num].boxColor.a)
			graphics.draw_text(execs[num].text, "CrystalClear", execs[num].justify, execs[num].start_point.x, execs[num].start_point.y, execs[num].top -execs[num]. bottom - 2) -- execs[num].textColor.r, execs[num].textColor.g, execs[num].textColor.b, execs[num].textColor.a) (put in when text coloring is implemented)
			if mid ~= nil then
				graphics.draw_line(execs[num].top, execs[num].mid, execs[num].bottom, execs[num].mid, 1, execs[num].boxColor.r + 0.3, execs[num].boxColor.g + 0.3, execs[num].boxColor.b + 0.3, execs[num].boxColor.a + 0.3)
				graphics.draw_text(execs[num].letter, "CrystalClear", "center", (execs[num].left + execs[num].mid) / 2, execs[num].start_point.y, execs[num].top - execs[num].bottom - 2) -- execs[num].textColor.r, execs[num].textColor.g, execs[num].textColor.b, execs[num].textColor.a) (put in when text coloring is implemented)
			end
		end
	end
	graphics.end_frame()
end

function key(k)
	if k == "p" then
		mode_manager.switch("Demo2")
	elseif k == "m" then
		mode_manager.switch("MainMenu")
	elseif k == "C" then
		mode_manager.switch("Credits")
	elseif k == "q" then
		os.exit()
	end
end