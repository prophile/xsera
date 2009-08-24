--[[-------------------------
	--{{-----------------
		Colour Tables
	-----------------}}--
-------------------------]]--

--RED
c_lightRed = { r = 0.8, g = 0.4, b = 0.4, a = 1.0 }
c_lightRed2 = { r = 0.7, g = 0.4, b = 0.4, a = 1.0 }
c_red = { r = 0.6, g = 0.15, b = 0.15, a = 1.0 }
c_pureRed = { r = 1.0, b = 0.0, g = 0.0, a = 1.0 }
c_pink = { r = 0.8, g = 0.5, b = 0.5, a = 1.0 }
c_rust = { r = 0.6, g = 0.1, b = 0.0, a = 1.0 }

--BLUE
c_lightBlue = { r = 0.15, g = 0.15, b = 0.6, a = 1.0 }
c_lightBlue2 = { r = 0.4, g = 0.4, b = 0.8, a = 1.0 }
c_lightBlue4 = { r = 0.2, g = 0.2, b = 0.6, a = 1.0 }
c_blue = { r = 0.35, g = 0.35, b = 0.7, a = 1.0 }
c_darkBlue = { r = 0.0, g = 0.0, b = 0.65, a = 1.0 }
c_blue2 = { r = 0.1, g = 0.1, b = 0.8, a = 1.0 }

--GREEN
c_laserGreen = { r = 0.1, g = 0.7, b = 0.1, a = 1.0 }
c_lightGreen = { r = 0.3, g = 0.7, b = 0.3, a = 1.0 }
c_lightGreen2 = { r = 0.4, g = 0.8, b = 0.4, a = 0.5 }
c_green = { r = 0.0, g = 0.4, b = 0.0, a = 1.0 }
c_green2 = { r = 0.2, g = 0.5, b = 0.2, a = 1.0 }
c_green3 = { r = 0.1, g = 0.5, b = 0.1, a = 1.0 }
c_green4 = { r = 0.4, g = 0.7, b = 0.4, a = 1.0 }
c_green5 = { r = 0.0, g = 0.4, b = 0.0, a = 1.0 }
c_darkGreen = { r = 0.1, g = 0.75, b = 0.1, a = 1.0 }

--YELLOW
c_lightYellow = { r = 0.7, g = 0.7, b = 0.4, a = 1.0 }
c_lightYellow2 = { r = 0.7, g = 0.7, b = 0.3, a = 1.0 }
c_yellow = { r = 0.6, g = 0.6, b = 0.15, a = 1.0 }
c_yellow2 = { r = 0.5, g = 0.5, b = 0.2, a = 1.0 }
c_brightYellow = { r = 0.7, g = 0.7, b = 0.0, a = 1.0 }

--PURPLE
c_lightPurple = { r = 0.8, g = 0.5, b = 0.7, a = 1.0 }
c_purple = { r = 0.7, g = 0.4, b = 0.6, a = 1.0 }
c_purple2 = { r = 0.6, g = 0.3, b = 0.5, a = 1.0 }
c_purpleBlue = { r = 0.4, g = 0.2, b = 0.5, a = 1.0 }
c_darkPurple = { r = 0.3, g = 0.0, b = 0.2, a = 1.0 }

--TEAL
c_teal = { r = 0.15, g = 0.55, b = 0.55, a = 1.0 }

--OTHER
c_grey = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 }
c_clear = { r = 0.0, g = 0.0, b = 0.0, a = 0.0 }
c_black = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }
c_white = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
CGREY = { r = 0.6, b = 0.65, g = 0.55, a = 1.0 }
CGREYBROWN = { r = 0.7, b = 0.7, g = 0.7, a = 1.0 }

--NON-COLOUR
c_darken = { r = -0.1, g = -0.1, b = -0.1, a = 1.0 }
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