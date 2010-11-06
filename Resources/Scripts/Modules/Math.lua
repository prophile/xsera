--[[[
	- @function hypot
	- Finds the distance between two given sides, x and y.
	- @param x
		The length of one of the sides.
	- @param y
		The length of the other side.
	- @return val
		The hypotenuse of the triangle given by sides x and y.
--]]
function hypot(x, y)
    return math.sqrt(x * x + y * y)
end

function normalizeAngle(angle)
    return angle % (2 * math.pi)
end

--[[[
	- @function hypot1
	- Taking a @ref vector, finds the hypotenuse as if those sides were lengths
		of a right triangle.
	- @param vec
		The vector to calculate the hypotenuse from.
	- @return val
		The hypotenuse of the triangle given by sides vec.x and vec.y.
--]]
function hypot1(xAndY)
	return math.sqrt(xAndY.x * xAndY.x + xAndY.y * xAndY.y)
end

--[[[
	- @function hypot2
	- Finds the distance between two vectors.
	- @param point1
		The first vector to calculate the distance from.
	- @param point2
		The second vector to calculate the distance from.
	- @return val
		The distance from point1 to point2.
--]]
function hypot2(point1, point2)
	return (math.sqrt((point1.y - point2.y)^2 + (point1.x - point2.x)^2))
end

--[[[
	- @function normalize
	- Takes the two components and returns the first component "normalized" so
		that when added to the second "normalized" component, makes a vector of
		length 1.0.
	- @param comp1
		The component to be normalized.
	- @param comp2
		The component against which comp1 is normalized (the other part of the
		triangle).
	- @return val
		The first component, normalized.
--]]
function normalize(comp1, comp2)
	return comp1 / hypot(comp1, comp2)
end

function findAngle(origin, dest)
	local angle = normalizeAngle(math.atan2(origin.y - dest.y, origin.x - dest.x))
	return angle
end

function RandomReal(min, max)
    return (math.random() * (max - min)) + min
end

function RandomVec(ranges)
	return vec(
		RandomReal(ranges.x[1],ranges.x[2]),
		RandomReal(ranges.y[1],ranges.y[2])
	)
end

function RotatePoint(point, angle)
	return vec(
	point.x*math.cos(angle)-point.y*math.sin(angle),
	point.x*math.sin(angle)+point.y*math.cos(angle)
	)
end

function PolarVec(mag, angle)
	return vec(mag*math.cos(angle),mag*math.sin(angle))
end


function NormalizeVec(v)
	return v/hypot1(v)
end

function xor(p,q)
	return (p and not q) or (not p and q)
end