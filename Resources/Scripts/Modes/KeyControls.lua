import('GlobalVars')
import('Console')
import('BoxDrawing')

background = {	{ top = 170, left = -280, bottom = -60, right = 280, boxColour = c_teal },
				{ top = -70, left = -280, bottom = -100, right = 280, boxColour = c_rust },
				{ coordx = -280, coordy = -205, length = 100, text = "nodraw", boxColour = c_brightYellow, textColour = c_purple, execute = nil, letter = "CANCEL" },
				{ coordx = 180, coordy = -205, length = 100, text = "nodraw", boxColour = c_lightGreen, textColour = c_purple, execute = nil, letter = "DONE" } }

function init()
	sound.stop_music()
	graphics.set_camera(-480, -360, 480, 360)
end

function update()
	while background[num] ~= nil do
		if background[num].special == "click" then
			background[num].special = nil
		end
		num = num + 1
	end
end

function render()
	graphics.begin_frame()
	-- Background
	graphics.draw_image("Panels/PanelTop", 0, 210, 572, 28)
	graphics.draw_image("Panels/PanelBottom", 0, -242, 572, 20)
	graphics.draw_image("Panels/PanelLeft", -302, -14, 33, 476)
	graphics.draw_image("Panels/PanelRight", 303, -14, 35, 476)
	local num = 1
	while background[num] ~= nil do
		switch_box(background[num])
		num = num + 1
	end
	-- Error Printing
	if errNotice ~= nil then
		graphics.draw_text(errNotice.text, "CrystalClear", "center", 0, -270, 28)
		if errNotice.start + errNotice.duration < mode_manager.time() then
			errNotice = nil
		end
	end
	graphics.end_frame()
end

function keyup(k)
	if k == "escape" then
		mode_manager.switch('Options')
	end
end

function key(k)
-- no key presses until I can assign them to values
end