function get_third(x, y)
	local dist = y - x
	local xthird = x + dist * 2 / 5
	local ythird = y - dist * 2 / 5
	return xthird, ythird
end

function drawline(a, b, f)
	graphics.draw_line(a, 450 - 5 * f, b, 450 - 5 * f, 2)
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
	local x = { one = 0, two = 0, three = 0, four = 0, five = 0, six = 0, seven = 0, eight = 0, nine = 0, ten = 0, eleven = 0, twelve = 0, thirteen = 0, fourteen = 0 }
	local blah = 0
    graphics.begin_frame()
	graphics.set_camera(-500, -500, 500, 500)
	leftend = -400 -- x.one should be -166
	rightend = 400
	drawline(leftend, rightend, 0)
	x.one, x.two = fractalize(leftend, rightend, 1)
	
	x.three, x.four = fractalize(x.one, leftend, 2)
	x.five, x.six = fractalize(x.two, rightend, 2)
	
	x.seven, x.eight = fractalize(leftend, x.four, 3)
	x.nine, x.ten = fractalize(x.three, x.one, 3)
	x.eleven, x.twelve = fractalize(x.six, rightend, 3)
	x.thirteen, x.fourteen = fractalize(x.five, x.two, 3)
	
	blah, blah = fractalize(leftend, x.seven, 4)
	blah, blah = fractalize(x.eight, x.four, 4)
	blah, blah = fractalize(x.nine, x.three, 4)
	blah, blah = fractalize(x.ten, x.one, 4)
	blah, blah = fractalize(x.two, x.fourteen, 4)
	blah, blah = fractalize(x.thirteen, x.five, 4)
	blah, blah = fractalize(x.eleven, x.six, 4)
	blah, blah = fractalize(rightend, x.twelve, 4)
	graphics.end_frame()
end