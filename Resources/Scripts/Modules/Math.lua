function hypot(x, y)
    return math.sqrt(x * x + y * y)
end

function hypot1(xAndY)
	return math.sqrt(xAndY.x * xAndY.x + xAndY.y * xAndY.y)
end

function normalize(componentA, componentB)
	return componentA / hypot(componentA, componentB)
end

function find_angle(origin, dest)
	local angle = math.atan2(origin.y - dest.y, origin.x - dest.x)
--	if angle < 0.0 then
--		angle = angle + 2 * math.pi
--	end
	return angle
end

function find_hypot(point1, point2)
	return (math.sqrt((point1.y - point2.y) * (point1.y - point2.y) + (point1.x - point2.x) * (point1.x - point2.x)))
end

function find_quadrant(angle)
	if angle % (math.pi / 2) == 0 then
		if angle == math.pi then
			return 2.5
		elseif angle == math.pi / 2 then
			return 1.5
		elseif angle == math.pi / 2 * 3 then
			return 3.5
		else
			return 0
		end
	end
	if angle > math.pi then
		if angle < (3 / 2 * math.pi) then
			return 3
		else
			return 4
		end
	else
		if angle < (math.pi / 2) then
			return 1
		else
			return 2
		end
	end
end

function find_quadrant_range(angle, range)
	return find_quadrant(angle - range / 2), find_quadrant(angle), find_quadrant(angle + range / 2)
end

function reference_angle(angle)
	local quad = find_quadrant(angle)
	if quad == 2 then
		angle = math.pi - angle
	elseif quad == 3 then
		angle = angle - math.pi
	elseif quad == 4 then
		angle = 2 * math.pi - angle
	end
	return angle
end

function radian_range(angle)
	if angle < 0 then
		angle = 2 * math.pi - angle
	elseif angle > 2 * math.pi then
		angle = angle - 2 * math.pi
	end
	return angle
end

function RandomReal ( min, max )
    return (math.random() * (max - min)) + min
end

function xor(p,q)
	return (p and not q) or (not p and q)
end
