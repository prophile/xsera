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

const float fluidDragRho = 1.204; // this is the density of air at 20 degrees celsius

void Object::Update ( float timestep, float friction )
{
    // step 1: apply resistive force
    vec2 dragForce = -velocity.UnitVector() * fluidDragRho * velocity.ModulusSquared() * (2.0f * M_PI * collisionRadius) * friction;
    force = dragForce;
    // step 2: update velocity from force
    velocity += (force * timestep);
    // step 3: update position from velocity
    position += (velocity * timestep);
    // step 4: update angular velocity from torque
    angularVelocity += (torque * timestep);
    // step 5: update angle from angular velocity
    angle += (torque * timestep);
    // step 6: limit angle to 0...2pi
    if (angle > 2.0f*M_PI)
        angle = fmodf(angle, 2.0f*M_PI);
    while (angle < 0.0f)
        angle += 2.0f*M_PI;
    // step 7: clear torque and force
    torque = 0.0f;
    force = vec2(0.0f, 0.0f);
}

}
