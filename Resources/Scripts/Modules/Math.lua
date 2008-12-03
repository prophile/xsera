function hypot(x, y)
    return math.sqrt(x * x + y * y)
end

function find_angle(origin, dest)
	if dest.y > origin.y then
		if dest.x > origin.x then
			return (math.atan((dest.y - origin.y) / (dest.x - origin.x)) + math.pi)
		else
			return math.atan((dest.y - origin.y) / (dest.x - origin.x))
		end
	else
		if dest.x > origin.x then
			return (math.atan((dest.y - origin.y) / (dest.x - origin.x)) + math.pi)
		else
			return math.atan((dest.y - origin.y) / (dest.x - origin.x))
		end
	end
end