import('ColourHandle')
import('PrintRecursive')

function draw_interface_box(box, col_mod_all, col_mod_click)
	if box.underbox ~= nil then
		graphics.draw_box(box.coordy + 18, box.coordx, box.underbox, box.coordx + box.length, 0, c_black)
	else
		graphics.draw_box(box.coordy + 18, box.coordx, box.coordy, box.coordx + box.length, 0, c_black)
	end
	if box.special ~= "disabled" then
		if box.text == "nodraw" then
			txtlength = (box.length - 22) / 2
		elseif ((box.length - 20) / 3.5) < graphics.text_length(box.letter, "CrystalClear", 14) then
			txtlength = (graphics.text_length(box.letter, "CrystalClear", 14) + 20) / 2
		else
			txtlength = (box.length - 20) / 7
		end
	else
		txtlength = (box.length - 20) / 7
	end
	-- inner box and details
	if (box.text ~= " ") and (box.text ~= "nodraw") then
		graphics.draw_box(box.coordy + 14, box.coordx + 11, box.coordy + 4, box.coordx + 10 + txtlength * 2, 0, colour_add(box.boxColour, c_lighten, col_mod_all))
		graphics.draw_box(box.coordy + 14, box.coordx + 11 + txtlength * 2, box.coordy + 4, box.coordx + box.length - 11, 0, colour_add(box.boxColour, c_darken, col_mod_click))
		graphics.draw_text(box.text, "CrystalClear", "center", box.coordx + 11 + txtlength * 9 / 2, box.coordy + 9, 14, colour_add(box.boxColour, c_lighten, col_mod_all)) 
	else
		graphics.draw_box(box.coordy + 14, box.coordx + 11, box.coordy + 4, box.coordx + 10 + txtlength * 2, 0, colour_add(box.boxColour, c_darken, c_darken))
		graphics.draw_box(box.coordy + 14, box.coordx + 11 + txtlength * 2, box.coordy + 4, box.coordx + box.length - 11, 0, colour_add(box.boxColour, c_lighten))
	end
	if box.special ~= "disabled" then
		graphics.draw_text(box.letter, "CrystalClear", "center", box.coordx + 11 + txtlength, box.coordy + 9, 14) 
	end
	if box.radio == "off" then
		graphics.draw_box(box.coordy + 13, box.coordx - 2, box.coordy + 4, box.coordx + 5, 0, colour_add(box.boxColour, col_mod_all))
		graphics.draw_box(box.coordy + 15, box.coordx - 5, box.coordy + 3, box.coordx - 3, 0, colour_add(box.boxColour, col_mod_all))
		graphics.draw_box(box.coordy + 15, box.coordx - 15, box.coordy + 3, box.coordx - 13, 0, colour_add(box.boxColour, col_mod_all))
		graphics.draw_box(box.coordy + 15, box.coordx - 15, box.coordy + 13, box.coordx - 3, 0, colour_add(box.boxColour, col_mod_all))
		graphics.draw_box(box.coordy + 5, box.coordx - 15, box.coordy + 3, box.coordx - 3, 0, colour_add(box.boxColour, col_mod_all))
	elseif box.radio == "on" then
		graphics.draw_box(box.coordy + 13, box.coordx - 2, box.coordy + 4, box.coordx + 5, 0, colour_add(box.boxColour, col_mod_all))
		graphics.draw_box(box.coordy + 15, box.coordx - 5, box.coordy + 3, box.coordx - 3, 0, colour_add(box.boxColour, col_mod_all))
		graphics.draw_box(box.coordy + 15, box.coordx - 15, box.coordy + 3, box.coordx - 13, 0, colour_add(box.boxColour, col_mod_all))
		graphics.draw_box(box.coordy + 15, box.coordx - 15, box.coordy + 13, box.coordx - 3, 0, colour_add(box.boxColour, col_mod_all))
		graphics.draw_box(box.coordy + 5, box.coordx - 15, box.coordy + 3, box.coordx - 3, 0, colour_add(box.boxColour, col_mod_all))
		graphics.draw_box(box.coordy + 11, box.coordx - 11, box.coordy + 7, box.coordx - 7, 0, colour_add(box.boxColour, col_mod_all))
	end
	-- frame boxes
	graphics.draw_box(box.coordy + 3, box.coordx, box.coordy + 2, box.coordx + 10, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 3, box.coordx + box.length - 10, box.coordy + 2, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 2, box.coordx, box.coordy, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 16, box.coordx, box.coordy + 14, box.coordx + 10, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 16, box.coordx + box.length - 10, box.coordy + 14, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 18, box.coordx, box.coordy + 16, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 13, box.coordx, box.coordy + 4, box.coordx + 10, 0, colour_add(box.boxColour, col_mod_all))
	graphics.draw_box(box.coordy + 13, box.coordx + box.length - 10, box.coordy + 4, box.coordx + box.length, 0, colour_add(box.boxColour, col_mod_all))
	-- under box, if it exists
	if box.underbox ~= nil then
		-- left side
		graphics.draw_box(box.coordy + 1, box.coordx, box.coordy - 1, box.coordx + 10, 0, box.boxColour)
		graphics.draw_box(box.coordy - 2, box.coordx, (box.coordy + box.underbox + 4) / 2, box.coordx + 10, 0, box.boxColour)
		graphics.draw_box((box.coordy + box.underbox + 2) / 2, box.coordx, box.underbox + 6, box.coordx + 10, 0, colour_add(box.boxColour, c_darken))
		graphics.draw_box(box.underbox + 5, box.coordx, box.underbox, box.coordx + 10, 0, box.boxColour)
		-- right side
		graphics.draw_box(box.coordy + 1, box.coordx + box.length - 10, box.coordy - 1, box.coordx + box.length, 0, box.boxColour)
		graphics.draw_box(box.coordy - 2, box.coordx + box.length - 10, (box.coordy + box.underbox + 4) / 2, box.coordx + box.length, 0, box.boxColour)
		graphics.draw_box((box.coordy + box.underbox + 2) / 2, box.coordx + box.length - 10, box.underbox + 6, box.coordx + box.length, 0, colour_add(box.boxColour, c_darken))
		graphics.draw_box(box.underbox + 5, box.coordx + box.length - 10, box.underbox, box.coordx + box.length, 0, box.boxColour)
		-- bottom
		graphics.draw_box(box.underbox + 3, box.coordx, box.underbox, box.coordx + box.length, 0, box.boxColour)
		if box.uboxText ~= nil then
			graphics.draw_text(box.uboxText, "CrystalClear", "left", box.coordx + 12, box.coordy - 6, 14)
		end
	end
end

function draw_box_with_sidecar(box)
	draw_interface_box(box, c_black, c_black)
	-- sidecar: a box of a particular size that surrounds a particular object
	-- box itself
	graphics.draw_line(box.sidecar.x, box.sidecar.y + box.sidecar.size.y, box.sidecar.x + box.sidecar.size.x, box.sidecar.y + box.sidecar.size.y, 1, box.boxColour)
	graphics.draw_line(box.sidecar.x, box.sidecar.y, box.sidecar.x + box.sidecar.size.x, box.sidecar.y, 1, box.boxColour)
	graphics.draw_line(box.sidecar.x, box.sidecar.y, box.sidecar.x, box.sidecar.y + box.sidecar.size.y, 1, box.boxColour)
	graphics.draw_line(box.sidecar.x + box.sidecar.size.x, box.sidecar.y, box.sidecar.x + box.sidecar.size.x, box.sidecar.y + box.sidecar.size.y, 1, box.boxColour)
	-- connecting lines - differ if box is on the left or the right
	if box.sidecar.x > box.coordx then
		graphics.draw_line(box.sidecar.x, box.sidecar.y + box.sidecar.size.y, (box.sidecar.x + box.coordx + box.length) / 2, box.sidecar.y + box.sidecar.size.y, 1, box.boxColour)
		graphics.draw_line((box.sidecar.x + box.coordx + box.length) / 2, box.sidecar.y + box.sidecar.size.y, (box.sidecar.x + box.coordx + box.length) / 2, box.coordy + 17, 1, box.boxColour)
		graphics.draw_line((box.sidecar.x + box.coordx + box.length) / 2, box.coordy + 17, box.coordx + box.length, box.coordy + 17, 1, box.boxColour)
		graphics.draw_line(box.sidecar.x, box.sidecar.y, (box.sidecar.x + box.coordx + box.length) / 2, box.sidecar.y, 1, box.boxColour)
		graphics.draw_line((box.sidecar.x + box.coordx + box.length) / 2, box.underbox + 1, (box.sidecar.x + box.coordx + box.length) / 2, box.sidecar.y, 1, box.boxColour)
		graphics.draw_line(box.coordx + box.length, box.underbox + 1, (box.sidecar.x + box.coordx + box.length) / 2, box.underbox + 1, 1, box.boxColour)
	else
		graphics.draw_line(box.coordx, box.coordy + 17, (box.coordx + box.sidecar.x + box.sidecar.size.x) / 2, box.coordy + 17, 1, box.boxColour)
		graphics.draw_line((box.coordx + box.sidecar.x + box.sidecar.size.x) / 2, box.coordy + 17, (box.coordx + box.sidecar.x + box.sidecar.size.x) / 2, box.sidecar.y + box.sidecar.size.y, 1, box.boxColour)
		graphics.draw_line((box.coordx + box.sidecar.x + box.sidecar.size.x) / 2, box.sidecar.y + box.sidecar.size.y, box.sidecar.x + box.sidecar.size.x, box.sidecar.y + box.sidecar.size.y, 1, box.boxColour)
		graphics.draw_line(box.sidecar.x + box.sidecar.size.x, box.sidecar.y, (box.coordx + box.sidecar.x + box.sidecar.size.x) / 2, box.sidecar.y, 1, box.boxColour)
		graphics.draw_line((box.coordx + box.sidecar.x + box.sidecar.size.x) / 2, box.sidecar.y, (box.coordx + box.sidecar.x + box.sidecar.size.x) / 2, box.underbox + 1, 1, box.boxColour)
		graphics.draw_line((box.coordx + box.sidecar.x + box.sidecar.size.x) / 2, box.underbox + 1, box.coordx, box.underbox + 1, 1, box.boxColour)
	end
end

function draw_small_box(box)
	local backgroundCol = c_black
	if box.background ~= nil then
		backgroundCol = box.background
	end
	graphics.draw_box(box.top, box.left, box.bottom, box.right, 0, backgroundCol)
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
	if box.title ~= nil then
		graphics.draw_box(box.top - 5, box.left + 4, box.top - 25, box.right - 4, 0, colour_add(box.boxColour, c_lighten2, c_lighten))
		graphics.draw_text(box.title, "CrystalClear", "left", box.left + 10, box.top - 15, 18, c_black)
	end
	if box.subtitle ~= nil then
		graphics.draw_text(box.subtitle, "CrystalClear", "left", box.left + 10, box.top - 35, 18, c_black)
	end
--	graphics.draw_text(box.desc, "CrystalClear", "left", box.left + 10, box.top - 55, 18, c_black) [TEXTFIX] re-enable when text is fixed
end

function switch_box(box)
	if box.text ~= nil and box.letter ~= nil then
		local col_mix = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }
		if box.special ~= nil then
			if box.special == "click" then
				col_mix = { r = 0.1, g = 0.1, b = 0.1, a = 1.0 }
				draw_interface_box(box, c_black, col_mix)
			elseif box.special == "disabled" then
				col_mix = { r = -0.3, g = -0.3, b = -0.3, a = 1.0 }
				draw_interface_box(box, col_mix, col_mix)
			elseif box.special == "sidecar" then
				draw_box_with_sidecar(box)
			end
		else
			draw_interface_box(box, c_black, c_black)
		end
	else
		draw_small_box(box)
	end
end

function change_special(k, set, table)
	local num = 1
	while table[num] ~= nil do
		if table[num].letter == k then
			table[num].special = set
		end
		num = num + 1
	end
end --