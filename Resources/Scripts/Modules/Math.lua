function hypot(x, y)
    return math.sqrt(x * x + y * y)
end

function find_angle(origin, dest)
	return math.atan2(dest.y - origin.y, dest.x - origin.x)
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

-- man, this function is a heckofalot neater than find_quadrant_range()-and if necessary, I could fix it easy
function find_quadrant_range2(angle, range)
	return find_quadrant(angle - range / 2), find_quadrant(angle), find_quadrant(angle + range / 2)
end

function find_quadrant_range(angle, range)
	if angle > math.pi then	-- QIII
		if angle < (3 / 2 * math.pi) then
			if (angle + range / 2) > math.pi then
				if (angle - range / 2) < (3 / 2 * math.pi) then
					return 3
				else
					return 2.5
				end
			else
				return 3.5
			end
		else -- QIV
			if (angle + range / 2) > (3 / 2 * math.pi) then
				if (angle - range / 2) < 2 * math.pi then
					return 4
				else
					return 3.5
				end
			else
				return 0
			end
		end
	else -- QI
		if angle < (math.pi / 2) then
			if (angle + range / 2) < math.pi / 2 then
				if angle > range / 2 then
					-- special exception - if the range is greater than the angle, then it's leaning over
					return 1
				else
					return 0
				end
			else
				return 1.5
			end
		else -- QII
			if (angle + range / 2) < math.pi then
				if (angle - range / 2) > math.pi / 2 then
					return 2
				else
					return 1.5
				end
			else
				return 2.5
			end
		end
	end
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

function bigger_angle(angle1, angle2)
	if angle1 > angle2 then
		return angle1
	else
		return angle2
	end
end

function smaller_angle(angle1, angle2)
	if angle1 < angle2 then
		return angle1
	else
		return angle2
	end
end

function radian_range(angle)
	if angle < 0 then
		angle = 2 * math.pi - angle
	elseif angle > 2 * math.pi then
		angle = angle - 2 * math.pi
	end
	return angle
end

function normalize(componentA, componentB)
	return componentA / hypot(componentA, componentB)
end