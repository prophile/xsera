#include "PhysicsObject.h"
#include <math.h>

namespace Physics
{

void Object::ApplyImpulse ( vec2 impulse )
{
    velocity += (impulse / mass);
}

void Object::ApplyAngularImpulse ( float impulse )
{
    angularVelocity += (impulse / mass);
}

void Object::SetVelocity ( vec2 velocityNew )
{
	velocity = velocityNew;
}

const float fluidDragRho = 1.204; // this is the density of air at 20 degrees celsius

void Object::Update ( float timestep, float friction )
{
    // step 1: apply resistive force
	vec2 dragForce = -velocity.UnitVector() * fluidDragRho * velocity.ModulusSquared() */* (2.0f * M_PI * collisionRadius) */ friction;
	//ALASTAIR: what's this 2*pi*r stuff? It's what's causing the problem! Also, velocity.ModulusSquared() makes things very slow.
	//on second thought, why is there drag in space??
//	force += dragForce;
    // step 2: update velocity from force
    velocity += (force * timestep);
    // step 3: update position from velocity
    position += (velocity * timestep);
    // step 4: update angular velocity from torque
    angularVelocity += (torque * timestep);
    // step 5: update angle from angular velocity
    angle += (angularVelocity * timestep);
    // step 6: limit angle to 0...2pi
    if (angle > 2.0f*M_PI)
        angle = fmodf(angle, 2.0f*M_PI);
    while (angle < 0.0f)
        angle += 2.0f*M_PI;
    // step 7: clear torque and force
    torque = 0.0f;
    force = vec2(0.0f, 0.0f);
}

/*
obj1 is the ship or planet, while obj2 is the projectile (which has an insignificant radius)
*/
bool Object::Collision( vec2 obj1, vec2 obj2, float radius )
{
	if (sqrt( (obj1.x + obj2.x) * (obj1.x + obj2.x) + (obj1.y + obj2.y) * (obj1.y + obj2.y) ) <= radius)
	{
		return true;
	}
	return false;
}

/*
obj1 and obj2 both have radii (ship to ship, ship to planet collisions)
*/
bool Object::Collision( vec2 obj1, vec2 obj2, float radius1, float radius2 )
{
	if (sqrt( (obj1.x + obj2.x) * (obj1.x + obj2.x) + (obj1.y + obj2.y) * (obj1.y + obj2.y) ) <= radius1 + radius2)
	{
		return true;
	}
	return false;
}

}
