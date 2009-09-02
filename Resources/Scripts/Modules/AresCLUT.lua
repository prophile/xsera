--[[-------------------------
	--{{-----------------
		Colour Tables
	-----------------}}--
-------------------------]]--

import('ColourHandle') -- unfortunately, yes - but only for now

-- CLUT VALUES
clut = { { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }, -- white
		{ r = 1.0, g = 0.5, b = 0.0 }, -- orange
		{ r = 1.0, g = 1.0, b = 0.0 }, -- yellow
		{ r = 0.0, g = 0.0, b = 1.0 }, -- blue
		{ r = 0.0, g = 1.0, b = 0.0 }, -- green
		{ r = 0.5, g = 0.0, b = 1.0 }, -- purple
		{ r = 0.5, g = 0.5, b = 1.0 }, -- grey-blue
		{ r = 1.0, g = 0.5, b = 0.5 }, -- rose
		{ r = 1.0, g = 1.0, b = 0.5 }, -- light-yellow
		{ r = 0.0, g = 1.0, b = 1.0 }, -- teal
		{ r = 1.0, g = 0.0, b = 0.5 }, -- hot-pink
		{ r = 0.5, g = 1.0, b = 0.5 }, -- light-green
		{ r = 1.0, g = 0.5, b = 1.0 }, -- light-pink
		{ r = 0.0, g = 0.5, b = 1.0 }, -- aqua-marine
		{ r = 1.0, g = 1.0, b = 0.8 }, -- peach
		{ r = 1.0, g = 0.0, b = 0.0 } } -- red

modifier = { 1.0, 0.941, 0.878, 0.816, 0.753, 0.690, 0.627, 0.565, 0.502, 0.439, 0.376, 0.251, 0.188, 0.125, 0.063 }

function clut_colour(clutnum, modnum)
	return { r = clut[clutnum].r * modifier.modnum, g = clut[clutnum].g * modifier.modnum, b = clut[clutnum].b * modifier.modnum, a = 1.0 }
end

-- OTHER VALUES
c_black = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }

-- NON-COLOUR VALUES
c_clear = { r = 0.0, g = 0.0, b = 0.0, a = 0.0 }
c_half_clear = { r = 0.0, g = 0.0, b = 0.0, a = 0.5 }
c_darken = { r = -0.1, g = -0.1, b = -0.1, a = 1.0 }
c_darken2 = { r = -0.2, g = -0.2, b = -0.2, a = 1.0 }
c_lighten = { r = 0.1, g = 0.1, b = 0.1, a = 1.0 }
c_lighten2 = { r = 0.2, g = 0.2, b = 0.2, a = 1.0 }

--[[-------------------------------
	--{{-----------------------
		Colour Manipulation
	-----------------------}}--
-------------------------------]]--

function fix_colour(colour)
	if colour.r > 1 then
		colour.r = 1
	elseif colour.r < 0 then
		colour.r = 0
	end
	if colour.g > 1 then
		colour.g = 1
	elseif colour.g < 0 then
		colour.g = 0
	end
	if colour.b > 1 then
		colour.b = 1
	elseif colour.b < 0 then
		colour.b = 0
	end
	if colour.a > 1 then
		colour.a = 1
	elseif colour.a < 0 then
		colour.a = 0
	end
	return colour
end

function colour_add(col1, col2, col3)
	if col3 ~= nil then
		return fix_colour({ r = col1.r + col2.r + col3.r, g = col1.g + col2.g + col3.g, b = col1.b + col2.b + col3.b, a = col1.a * col2.a * col3.a })
	else
		return fix_colour({ r = col1.r + col2.r, g = col1.g + col2.g, b = col1.b + col2.b, a = col1.a * col2.a })
	end
end