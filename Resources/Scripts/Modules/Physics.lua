-- physics engine
class "PhysicsObject"

function PhysicsObject:initialize(baseMass, location, velocity, angle)
	self._location = location
	self._velocity = velocity
	self._top_speed = 1.0
	self._angle = angle
	self._angular_velocity = 0.0
	self._top_angular_velocity = 1.0
	self._mass = baseMass
	self._drag = 0.0
	self._rotational_drag = 0.0
end

function PhysicsObject:apply_impulse ( impulse )
    -- update _velocity
	self._velocity.x = self._velocity.x + (impulse.x / self._mass)
	self._velocity.y = self._velocity.y + (impluse.y / self._mass)
	-- cap _velocity to _top_speed
	local speed_squared = self._velocity.x*self._velocity.x + self._velocity.y*self._velocity.y
	local _top_speed_squared = self._top_speed * self._top_speed
	if speed_squared > _top_speed_squared then
		local speed = math.sqrt(speed_squared)
		self._velocity.x = (self._velocity.x / speed) * self._top_speed
		self._velocity.y = (self._velocity.y / speed) * self._top_speed
	end
end

function PhysicsObject:rotational_drag ()
    return self._rotational_drag
end

function PhysicsObject:set_rotational_drag ( rotational_drag )
    self._rotational_drag = rotational_drag
end

function PhysicsObject:speed ()
--	return math.sqrt(self._velocity.x * self._velocity.x + self._velocity.y * self._velocity.y)
	return self._velocity.x, self._velocity.y
end

function PhysicsObject:drag ()
    return self._drag
end

function PhysicsObject:set_drag ( drag )
    self._drag = drag
end

function PhysicsObject:top_angular_velocity ()
    return self._top_angular_velocity
end

function PhysicsObject:set_top_angular_velocity ( top_angular_velocity )
    self._top_angular_velocity = top_angular_velocity
end

function PhysicsObject:set_top_speed ( top_speed )
    self._top_speed = top_speed
end

function PhysicsObject:top_speed ()
    return self._top_speed
end

function PhysicsObject:mass ()
    return self._mass
end

function PhysicsObject:angular_velocity ()
    return self._angular_velocity
end

function PhysicsObject:set_angular_velocity ( angular_velocity )
    self._angular_velocity = angular_velocity
end

function PhysicsObject:location ()
    return self._location
end

function PhysicsObject:set_location ( location )
    self._location = location
end

function PhysicsObject:velocity ()
    return self._velocity
end

function PhysicsObject:set_velocity ( velocity )
    self._velocity = velocity
end

function PhysicsObject:angle ()
    return self._angle
end

function PhysicsObject:set_angle ( angle )
    self._angle = angle
end

function PhysicsObject:update ( dt, force, torque )
	-- update _velocity
	local acceleration = { x = force.x / self._mass, y = force.y / self._mass }
	acceleration.x = acceleration.x - (self._velocity.x * self._drag)
	acceleration.y = acceleration.y - (self._velocity.y * self._drag)
	self._velocity.x = self._velocity.x + (acceleration.x * dt)
	self._velocity.y = self._velocity.y + (acceleration.y * dt)
	-- cap _velocity to _top_speed
	local speed_squared = self._velocity.x*self._velocity.x + self._velocity.y*self._velocity.y
	local _top_speed_squared = self._top_speed * self._top_speed
	if speed_squared > _top_speed_squared then
		local speed = math.sqrt(speed_squared)
		self._velocity.x = (self._velocity.x / speed) * self._top_speed
		self._velocity.y = (self._velocity.y / speed) * self._top_speed
	end
	-- update _location
	self._location.x = self._location.x + (self._velocity.x * dt)
	self._location.y = self._location.y + (self._velocity.y * dt)
	-- update angular _velocity
	local angular_acceleration = (torque / self._mass)
	angular_acceleration = angular_acceleration - (self._angular_velocity * self._rotational_drag)
	self._angular_velocity = self._angular_velocity + ((torque / self._mass) * dt)
	-- cap angular _velocity to _top_angular_velocity
	if (self._angular_velocity > self._top_angular_velocity) or (self._angular_velocity < -self._top_angular_velocity) then
		if self._angular_velocity < 0 then
			self._angular_velocity = -self._top_angular_velocity
		else
			self._angular_velocity = self._top_angular_velocity
		end
	end
	-- update _angle
	self._angle = self._angle + (self._angular_velocity * dt)
	-- force _angle to be within the domain [0...2pi]
	if self._angle >= (math.pi * 2.0) then
		self._angle = self._angle - (math.pi * 2.0)
	elseif self._angle < 0 then
		self._angle = self._angle + (math.pi * 2.0)
	end
end

