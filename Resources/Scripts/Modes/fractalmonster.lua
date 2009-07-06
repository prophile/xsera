function get_third(x, y)
	local dist = y - x
	local xthird = x + dist * 3 / 7
	local ythird = y - dist * 3 / 7
	return xthird, ythird
end

function drawline(a, b, f)
	graphics.draw_box(460 - 30 * f, b, 435 - 30 * f, a, 0)
end

function fractalize(a, b, f)
	local c = 0
	local d = 0
	c, d = get_third(a, b)
	drawline(a, c, f * 2)
	drawline(b, d, f * 2)
	return c, d
end

function render()
	local x = {}
	local blah = 0
    graphics.begin_frame()
	graphics.set_camera(-500, -500, 500, 500)
	x[1] = -400
	x[2] = 400
	drawline(x[1], x[2], 0)
	x[3], x[4] = fractalize(x[1], x[2], 1)
	
	x[5], x[6] = fractalize(x[3], x[1], 2)
	x[7], x[8] = fractalize(x[4], x[2], 2)
	
	x[9], x[10] = fractalize(x[1], x[6], 3)
	x[13], x[14] = fractalize(x[2], x[8], 3)
	x[11], x[12] = fractalize(x[3], x[5], 3)
	x[15], x[16] = fractalize(x[4], x[7], 3)
	
	-- FIGURE OUT AN ALGORITHM FOR THIS
	blah, blah = fractalize(x[1], x[9], 4)
	blah, blah = fractalize(x[10], x[6], 4)
	blah, blah = fractalize(x[11], x[5], 4)
	blah, blah = fractalize(x[12], x[3], 4)
	blah, blah = fractalize(x[4], x[16], 4)
	blah, blah = fractalize(x[15], x[7], 4)
	blah, blah = fractalize(x[13], x[8], 4)
	blah, blah = fractalize(x[2], x[14], 4)
	graphics.end_frame()
end