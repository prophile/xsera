import('Math')

physicsSystem = { friction, gravity, gravityIsLoc, gravMass }
GRAVITY = 6.6742e-11

function NewPhysicsObject()
	return { velocity = vec2(0, 0), angle = 0, angularVelocity = 0, torque = 0, mass = 0, position = vec2(0, 0), force = vec2(0, 0) }
end

function ApplyImpulse(obj, impulse)
	obj.velocity = obj.velocity + (impulse / obj.mass)
end

function ApplyAngularImpulse(obj, impulse)
	obj.angularVelocity = obj.angularVelocity + impulse
end

function SetVelocity(obj, newVelocity)
	obj.velocity = newVelocity
end

function UpdateSystem(dt)
	if physicsObjects ~= {} then
		for i, o in pairs(scen.objects) do
			if physicsSystem.gravityIsLoc then
				local distX = o.position.x - physicsSystem.gravity.x
				local distY = o.position.y - physicsSystem.gravity.y
				local hypot = hypot(distX, distY)
				local grav = GRAVITY * (physicsSystem.gravMass * o.mass) / (distX^2 + distY^2)
				UpdateObject(o, dt, physicsSystem.friction, { x = grav / hypot * distX, y = grav / hypot * distY } )
				-- the above line really needs to be tested
			else
				UpdateObject(physicsObjects[i], dt, physicsSystem.friction, physicsSystem.gravity)
			end
		end
	end
end

function UpdateObject(obj, dt, friction, gravity)
	force = force + gravity * dt * dt - friction
	force.y = force.y + gravity.y * dt * dt - friction.y
	
	obj.velocity = obj.velocity + (force * dt)
	obj.position = obj.position + (obj.velocity * dt)
	
	obj.angularVelocity = obj.angularVelocity + (obj.torque * dt)
	obj.angle = obj.angle + (obj.angularVelocity * dt)
	
	if obj.angle > (2 * math.pi) then
		obj.angle = obj.angle % (2 * math.pi)
	end
	while obj.angle < 0 do
		obj.angle = obj.angle + 2 * math.pi
	end
	
	obj.torque = 0
	obj.force = vec2(0, 0)
end

function NewPhysicsSystem(friction, gravity, gravityIsLoc, gravMass)
	if friction == nil then
		friction = 0
	end
	if gravity == nil then
	physicsSystem = { friction = friction, gravity = gravity, gravityIsLoc = gravityIsLoc, gravMass = gravMass }
end