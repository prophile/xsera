#ifndef _ENTITY_H_
#define _ENTITY_H_

#include "SDL_OpenGL.h"

class Entity
{
	public:
	
	int position_x;
	int position_y;
	GLfloat rotation;
	
	Entity();
	
	~Entity();
};

#endif