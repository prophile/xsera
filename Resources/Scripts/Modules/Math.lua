function hypot(x, y)
    return math.sqrt(x * x + y * y)
end

--[[ what was I on when I made this code?
function find_angle(origin, dest)
	if dest.y > origin.y then
		if dest.x > origin.x then -- QI
			return (math.atan(diff.y / diff.x) + math.pi)
		else -- Q2
			return math.atan(diff.y / diff.x)
		end
	else
		if dest.x > origin.x then -- Q3
			return math.atan(diff.y / diff.x)
		else -- Q4
			return (math.atan(diff.y / diff.x) + math.pi)
		end
	end
end
--]]

--[[ are we there yet?
function find_angle(origin, dest)
	local diff = { x = dest.x - origin.x, y = dest.y - origin.y }
	if diff.y > 0 then -- the difference in y is positive
		if diff.x > 0 then -- QI
			return math.atan(diff.y / diff.x)
		else -- QII
			return (math.pi - math.atan(diff.y / diff.x))
		end
	else -- the difference in y is negative
		if diff.x > 0 then -- QIV
			return (math.atan(diff.y / diff.x) + math.pi)
		else -- QIII
			return ((2* math.pi) - math.atan(diff.y / diff.x))
		end
	end
end
--]]

-- find the angle NAO
function guide_bullet(a, b)
	local alpha = a + 2 * math.pi
	local beta = b + 2 * math.pi
	if beta > alpha then -- real angle is less than desired angle
		if (beta - alpha) > bullet.turn_rate then
			bullet.theta = bullet.theta + bullet.turn_rate
		else
			bullet.theta = bullet.beta
		end
	else -- real angle is greater than desired angle
		if (beta - alpha) > bullet.turn_rate then
			bullet.theta = bullet.theta + bullet.turn_rate
		else
			bullet.theta = bullet.alpha
		end
	end
end
--]]

-- what the heck?
function find_angle(origin, dest)
	local diff = { x = dest.x - origin.x, y = dest.y - origin.y }
	return math.atan(diff.y / diff.x)
end
--]]