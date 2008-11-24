-- physics engine
class "PhysicsObject"

function PhysicsObject:initialize()
	self.location = { x = 0.0, y = 0.0 }
	self.velocity = { x = 0.0, y = 0.0 }
	self.top_speed = 1.0
	self.angle = 0.0
	self.angular_velocity = 0.0
	self.top_angular_velocity = 1.0
	self.mass = 50.0
end

function PhysicsObject:update ( dt, force, torque )
	-- update velocity
	local acceleration = { x = force.x / self.mass, y = force.y / self.mass }
	self.velocity.x = self.velocity.x + (acceleration.x * dt)
	self.velocity.y = self.velocity.y + (acceleration.y * dt)
	-- cap velocity to top_speed
	local speed_squared = self.velocity.x*self.velocity.x + self.velocity.y*self.velocity.y
	local top_speed_squared = self.top_speed * self.top_speed
	if speed_squared > top_speed_squared then
		local speed = math.sqrt(speed_squared)
		self.velocity.x = (self.velocity.x / speed) * self.top_speed
		self.velocity.y = (self.velocity.y / speed) * self.top_speed
	end
	-- update location
	self.location.x = self.location.x + (self.velocity.x * dt)
	self.location.y = self.location.y + (self.velocity.y * dt)
	-- update angular velocity
	self.angular_velocity = self.angular_velocity + ((torque / self.mass) * dt)
	-- cap angular velocity to top_angular_velocity
	if (self.angular_velocity > self.top_angular_velocity) or (self.angular_velocity < -self.top_angular_velocity) then
		if self.angular_velocity < 0 then
			self.angular_velocity = -self.top_angular_velocity
		else
			self.angular_velocity = self.top_angular_velocity
		end
	end
	-- update angle
	self.angle = self.angle + (self.angular_velocity * dt)
	-- force angle to be within the domain [0...2pi]
	if self.angle >= (math.pi * 2.0) then
		self.angle = self.angle - (math.pi * 2.0)
	elseif self.angle < 0 then
		self.angle = self.angle + (math.pi * 2.0)
	end
end

