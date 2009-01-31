#ifndef __apollo_physics_object_h
#define __apollo_physics_object_h

#include <Utilities/Vec2.h>

namespace Physics
{

class Object
{
public:
    float mass;
    vec2 position;
    vec2 velocity;
    vec2 force;
    float angle;
    float angularVelocity;
    float torque;
    float collisionRadius;
    unsigned objectID;
    
    void ApplyImpulse ( vec2 impulse );
    void ApplyAngularImpulse ( float impulse );
	void SetVelocity ( vec2 velocityNew );
    void Update ( float timestep, float friction );
	bool Collision( vec2 obj1, vec2 obj2, float radius );
	bool Collision( vec2 obj1, vec2 obj2, float radius1, float radius2 );
};

}

#endif