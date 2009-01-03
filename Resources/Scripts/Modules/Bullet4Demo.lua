-- Bullet handling for demo. Initial versions will only allow one bullet, subsequent versions should allow more.

carrierLocation = { x = 200, y = 300 }
bullet = { dest = { x = carrierLocation.x, y = carrierLocation.y }, force = { x = 0, y = 0 }, power = 5000, velocity = 1, alpha = 0, beta = 0, delta = 0, theta = 0, size = { x = 0, y = 0 }, turn_rate = 0.1, max_seek_angle = 0.5, max_seek_dist = 20000, ammo = 50 }
bullet.size.x, bullet.size.y = graphics.sprite_dimensions("Weapons/WhiteYellowMissile")
firebullet = false

function fire_bullet()
--[[ here's what this function should look like when finished:
1- Find all possible targets in missile range
2- Select best target and seek it
(Update with new target if necessary when updating)
--]]
	if bullet.ammo > 0 then
		
		bullet.ammo = bullet.ammo - 1
		sound.play("RocketLaunchr")
		-- temp sound file, should be "RocketLaunch" but for some reason, that file gets errors (file included in git for troubleshooting)
	end
end


function within_barrier(angle, dest)
	local shipLocation = playerShip.physicsObject.position
	local partone = false -- test if it's within line one
	local parttwo = false -- test if it's within line two
	local partthree = false -- test if it's within line three
	local quad_angle_minus, quad_angle, quad_angle_plus = find_quadrant_range2(angle, bullet.max_seek_angle)
	if math.tan(bullet.theta + bullet.max_seek_angle / 2) > 0 then
		if dest.y + shipLocation.y <= math.tan(bullet.theta + bullet.max_seek_angle / 2) * dest.x + shipLocation.x then
			return true
		end
	else
		if dest.y + shipLocation.y >= math.tan(bullet.theta + bullet.max_seek_angle / 2) * dest.x + shipLocation.x then
			return true
		end
	end
	if math.sin(bullet.theta) > 0 then
		if dest.y + shipLocation.y + math.sin(bullet.theta) * bullet.max_seek_dist <= (-1 / math.tan(bullet.theta)) * dest.x + shipLocation.x + math.cos(bullet.theta) * bullet.max_seek_dist then
			return true
		end
	else
		if dest.y + shipLocation.y + math.sin(bullet.theta) * bullet.max_seek_dist >= (-1 / math.tan(bullet.theta)) * dest.x + shipLocation.x + math.cos(bullet.theta) * bullet.max_seek_dist then
			return true
		end
	end
	if math.tan(bullet.theta - bullet.max_seek_angle / 2) < 0 then
		if dest.y + shipLocation.y >= math.tan(bullet.theta - bullet.max_seek_angle / 2) * dest.x + shipLocation.x then
			return true
		end
	else
		if dest.y + shipLocation.y <= math.tan(bullet.theta - bullet.max_seek_angle / 2) * dest.x + shipLocation.x then
			return true
		end
	end
	if partone == true then
		if parttwo == true then
			if partthree == true then
				return true
			end
		end
	end
	return false
end

function guide_bullet()
	if within_barrier(bullet.max_seek_angle, carrierLocation) == true then
		local big_angle = bigger_angle(bullet.alpha, bullet.beta)
		local small_angle = smaller_angle(bullet.alpha, bullet.beta)
		if big_angle - small_angle > math.pi then
			bullet.delta = 2 * math.pi - big_angle + small_angle
		else
			bullet.delta = big_angle - small_angle
		end
		
		if math.abs(bullet.delta) > bullet.turn_rate then
			if bullet.delta > bullet.turn_rate then
				bullet.delta = -bullet.turn_rate
			else
				bullet.delta = bullet.turn_rate
			end
		end
	else
		bullet.delta = 0
	end
end