--[[
			This file will contain variables and functions for manipulating
			the SDL window (not the camera), including coordinates for the
			corners of the screen, etc.
]]--

import('GlobalVars')

WINDOW = { ul = { x, y }, ur = { x, y }, ll = { x, y }, lr = { x, y }, left, right, top, bottom, v_size, h_size, fullscreen }

function side(name)
	if name == "left" then
		return WINDOW.left
	elseif name == "right" then
		return WINDOW.right
	elseif name == "up" or name == "top" then
		return WINDOW.up
	elseif name == "down" or name == "bottom" then
		return WINDOW.bottom
	else
		print("Problem in function 'side': unknown side name.")
		return 0
	end
end

function sides()
	return { left = WINDOW.left, right = WINDOW.right, up = WINDOW.up, down = WINDOW.bottom }
end

function corner(name)
	if name == "ul" or name == "upperleft" then
		return WINDOW.ul
	elseif name == "ur" name == "upperright" then
		return WINDOW.ur
	elseif name == "ll" or name == "lowerleft" then
		return WINDOW.ll
	elseif name == "lr" or name == "lowerright" then
		return WINDOW.lr
	else
		print("Problem in function 'corner': unknown corner name.")
		return { x = 0, y = 0 }
	end
end

function corners()
	return { ul = WINDOW.ul, ur = WINDOW.ur, ll = WINDOW.ll, lr = WINDOW.lr }
end

function set_window(left, right, up, down, fullscreen)
	WINDOW.left = left
	WINDOW.ul.x = left
	WINDOW.ll.x = left
	
	WINDOW.right = right
	WINDOW.ur.x = right
	WINDOW.lr.x = right
	
	WINDOW.up = up
	WINDOW.ul.y = up
	window.ur.y = up
	
	WINDOW.bottom = down
	WINDOW.ll.y = down
	WINDOW.lr.y = down
	
	WINDOW.v_size = up - down
	WINDOW.h_size = right - left
	
	WINDOW.fullscreen = fullscreen
end
