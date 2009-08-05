import('GlobalVars')

local execs = {}

function init()
	sound.stop_music()
	graphics.set_camera(-480, -360, 480, 360)
	local num = 1
	execs[num] = { coordx = -260, coordy = -205, length = 150, text = "Cancel", boxColour = CBYELLOW, textColor = c_purple, execute = nil, letter = "ESC" }
	num = num + 1
	execs[num] = { coordx = 110, coordy = -205, length = 150, text = "Begin", boxColour = c_lightGreen, textColor = c_purple, execute = nil, letter = "RTRN" }
	num = num + 1
	execs[num] = { coordx = -260, coordy = -105, length = 150, text = "Previous", boxColour = CTEAL, textColor = c_purple, execute = nil, letter = "LEFT" }
	num = num + 1
	execs[num] = { coordx = 110, coordy = -105, length = 150, text = "Next", boxColour = CTEAL, textColor = c_purple, execute = nil, letter = "RGHT", special = "disabled" }
	num = num + 1
	execs[num] = { coordx = -280, coordy = 140, length = 560, text = " ", boxColour = CTEAL, textColor = c_purple, execute = nil, letter = "Select Level", underbox = -145 }
	num = num + 1
	execs[num] = { top = 120, left = -260, bottom = -55, right = 260, boxColour = CTEAL, title = "CHAPTER 6", subtitle = "...Into the Fire", desc = "Capture the planet Hades Beta while destroying as many Gaitori power stations as possible and saving as many of the Obish stations as you can." }
end

c_lighten2 = { r = 0.2, g = 0.2, b = 0.2, a = 1.0 }
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
		if execs[num].text ~= nil and execs[num].letter ~= nil then
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
		else
			draw_small_box(execs[num])
		end
		num = num + 1
	end
	graphics.end_frame()
end

function draw_interface_box(box, col_mod_all, col_mod_click)
	-- inner box and details
	if box.text ~= " " then
		graphics.draw_box(box.coordy + 13, box.coordx + 11, box.coordy + 5, box.coordx + 10 + (box.length - 20) / 3.5, 0, colour_add(box.boxColour, c_lighten, col_mod_all))
		graphics.draw_box(box.coordy + 13, box.coordx + 11 + (box.length - 20) / 3.5, box.coordy + 5, box.coordx + box.length - 11, 0, colour_add(box.boxColour, c_darken, col_mod_click))
		graphics.draw_text(box.text, "CrystalClear", "center", box.coordx + 11 + (box.length - 20) / 3.5 + (box.length - 20) * 5 / 14, box.coordy + 9, 13, colour_add(box.boxColour, c_lighten, col_mod_all)) 
	else
		graphics.draw_box(box.coordy + 13, box.coordx + 11, box.coordy + 5, box.coordx + 10 + (box.length - 20) / 3.5, 0, colour_add(box.boxColour, c_darken))
		graphics.draw_box(box.coordy + 13, box.coordx + 11 + (box.length - 20) / 3.5, box.coordy + 5, box.coordx + box.length - 11, 0, colour_add(box.boxColour, c_lighten))
	end
	if box.special ~= "disabled" then
		graphics.draw_text(box.letter, "CrystalClear", "center", box.coordx + 11 + (box.length - 20) / 7, box.coordy + 9, 13) 
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
	while execs[num] ~= nil do
		if execs[num].special == "click" then
			execs[num].special = nil
		end
		num = num + 1
	end
end

function draw_small_box(box)
	graphics.draw_box(box.top, box.left, box.top - 3, box.right, 0, box.boxColour)
	graphics.draw_box(box.top, box.left, box.top - 4, box.left + 3, 0, box.boxColour)
	graphics.draw_box(box.top, box.right - 3, box.top - 4, box.right, 0, box.boxColour)
	graphics.draw_box(box.top - 5, box.left, (box.top + box.bottom) / 2, box.left + 3, 0, colour_add(box.boxColour, c_lighten))
	graphics.draw_box((box.top + box.bottom) / 2 - 1, box.left, box.bottom + 5, box.left + 3, 0, colour_add(box.boxColour, c_darken))
	graphics.draw_box(box.bottom + 3, box.left, box.bottom, box.right, 0, box.boxColour)
	graphics.draw_box(box.bottom + 4, box.left, box.bottom, box.left + 3, 0, box.boxColour)
	graphics.draw_box(box.bottom + 4, box.right - 3, box.bottom, box.right, 0, box.boxColour)
	graphics.draw_box(box.top - 5, box.right - 3, (box.top + box.bottom) / 2, box.right, 0, colour_add(box.boxColour, c_lighten))
	graphics.draw_box((box.top + box.bottom) / 2 - 1, box.right - 3, box.bottom + 5, box.right, 0, colour_add(box.boxColour, c_darken))
	graphics.draw_box(box.top - 5, box.left + 4, box.top - 25, box.right - 4, 0, colour_add(box.boxColour, c_lighten2, c_lighten))
	graphics.draw_text(box.title, "CrystalClear", "left", box.left + 10, box.top - 15, 18, c_black)
	graphics.draw_text(box.subtitle, "CrystalClear", "left", box.left + 10, box.top - 35, 18, c_black)
end

function keyup(k)
	if k == "escape" then
		mode_manager.switch('AresSplash')
	end
end

function key(k)
	if k == "escape" then
		local num = 1
		while execs[num] ~= nil do
			if execs[num].letter == "ESC" then
				execs[num].special = "click"
			end
			num = num + 1
		end
	end
end