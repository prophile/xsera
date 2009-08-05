import('GlobalVars')

local execs = {}
CBYELLOW = { r = 0.7, g = 0.7, b = 0.0, a = 1.0 }
CLGREEN = { r = 0.3, g = 0.6, b = 0.3, a = 1.0 }
CTEAL = { r = 0.2, g = 0.6, b = 0.6, a = 1.0 }

function init()
	sound.stop_music()
	graphics.set_camera(-480, -360, 480, 360)
	local num = 1
	execs[num] = { coordx = -260, coordy = -205, length = 150, text = "Cancel", boxColor = CBYELLOW, textColor = c_purple, execute = nil, letter = "ESC" }
	num = num + 1
	execs[num] = { coordx = 100, coordy = -205, length = 150, text = "Begin", boxColor = CLGREEN, textColor = c_purple, execute = nil, letter = "RTRN" }
	num = num + 1
	execs[num] = { coordx = -260, coordy = -105, length = 150, text = "Previous", boxColor = CTEAL, textColor = c_purple, execute = nil, letter = "LEFT" }
	num = num + 1
	execs[num] = { coordx = 100, coordy = -105, length = 150, text = "Next", boxColor = CTEAL, textColor = c_purple, execute = nil, letter = "RGHT" }
end

function update()

end

function render()
	graphics.begin_frame()
	graphics.draw_image("Panels/PanelTop", 0, 210, 572, 28)
	graphics.draw_image("Panels/PanelBottom", 0, -242, 572, 20)
	graphics.draw_image("Panels/PanelLeft", -302, -14, 33, 476)
	graphics.draw_image("Panels/PanelRight", 303, -14, 35, 476)
	local num = 1
	while execs[num] ~= nil do
		-- inner box and details
		graphics.draw_box(execs[num].coordy + 13, execs[num].coordx + 11, execs[num].coordy + 5, execs[num].coordx + 10 + (execs[num].length - 20) / 3.5, 0, execs[num].boxColor.r + 0.1, execs[num].boxColor.g + 0.1, execs[num].boxColor.b + 0.1, execs[num].boxColor.a + 0.1)
		graphics.draw_box(execs[num].coordy + 13, execs[num].coordx + 11 + (execs[num].length - 20) / 3.5, execs[num].coordy + 5, execs[num].coordx + execs[num].length - 11, 0, execs[num].boxColor.r - 0.1, execs[num].boxColor.g - 0.1, execs[num].boxColor.b - 0.1, execs[num].boxColor.a - 0.1)
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
		-- under box, if it exists
		if execs[num].underbox ~= nil then
			graphics.draw_box(execs[num]coordy - 1, execs[num].coordx, execs[num].underbox, execs[num].coordx + 11)
		end
		num = num + 1
	end
	graphics.end_frame()
end

function key(k)
	if k == "escape" then
		mode_manager.switch('AresSplash')
	end
end