import('ColourHandle')
import('PrintRecursive')

function draw_interface_box(box, col_mod_all, col_mod_click)
	-- inner box and details
	if box.text ~= " " then
		graphics.draw_box(box.coordy + 13, box.coordx + 11, box.coordy + 5, box.coordx + 10 + (box.length - 20) / 3.5, 0, colour_add(box.boxColour, c_lighten, col_mod_all))
		graphics.draw_box(box.coordy + 13, box.coordx + 11 + (box.length - 20) / 3.5, box.coordy + 5, box.coordx + box.length - 11, 0, colour_add(box.boxColour, c_darken, col_mod_click))
		graphics.draw_text(box.text, "CrystalClear", "center", box.coordx + 11 + (box.length - 20) / 3.5 + (box.length - 20) * 5 / 14, box.coordy + 9, 14, colour_add(box.boxColour, c_lighten, col_mod_all)) 
	else
		graphics.draw_box(box.coordy + 13, box.coordx + 11, box.coordy + 5, box.coordx + 10 + (box.length - 20) / 3.5, 0, colour_add(box.boxColour, c_darken))
		graphics.draw_box(box.coordy + 13, box.coordx + 11 + (box.length - 20) / 3.5, box.coordy + 5, box.coordx + box.length - 11, 0, colour_add(box.boxColour, c_lighten))
	end
	if box.special ~= "disabled" then
		graphics.draw_text(box.letter, "CrystalClear", "center", box.coordx + 11 + (box.length - 20) / 7, box.coordy + 9, 14) 
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
	-- connecting lines
	graphics.draw_line(box.sidecar.x, box.sidecar.y + box.sidecar.size.y, (box.sidecar.x + box.coordx + box.length) / 2, box.sidecar.y + box.sidecar.size.y, 1, box.boxColour)
	graphics.draw_line((box.sidecar.x + box.coordx + box.length) / 2, box.sidecar.y + box.sidecar.size.y, (box.sidecar.x + box.coordx + box.length) / 2, box.coordy + 17, 1, box.boxColour)
	graphics.draw_line((box.sidecar.x + box.coordx + box.length) / 2, box.coordy + 17, box.coordx + box.length, box.coordy + 17, 1, box.boxColour)
	graphics.draw_line(box.sidecar.x, box.sidecar.y, (box.sidecar.x + box.coordx + box.length) / 2, box.sidecar.y, 1, box.boxColour)
	graphics.draw_line((box.sidecar.x + box.coordx + box.length) / 2, box.underbox + 1, (box.sidecar.x + box.coordx + box.length) / 2, box.sidecar.y, 1, box.boxColour)
	graphics.draw_line(box.coordx + box.length, box.underbox + 1, (box.sidecar.x + box.coordx + box.length) / 2, box.underbox + 1, 1, box.boxColour)
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
	graphics.draw_text(box.desc, "CrystalClear", "left", box.left + 10, box.top - 55, 18, c_black)
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

function change_special(k, set, temp_table)
--	print_table(temp_table)
	local num = 1
	while temp_table[num] ~= nil do
		if temp_table[num].letter == k then
			temp_table[num].special = set
		end
		num = num + 1
	end
end --