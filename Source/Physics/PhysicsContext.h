#ifndef __xsera_physics_context_h
#define __xsera_physics_context_h

#include <vector>
#include <Utilities/Vec2.h>

namespace Physics
{

class Object;

void Open ( float friction );
void Close ();

void Update ( float timestep );

Object* NewObject ( float mass );
void DestroyObject ( Object* object );

Object* ObjectWithID ( unsigned objID );

typedef std::pair<Object*, Object*> Collision;

std::vector<Collision> GetCollisions ();

}

#endif