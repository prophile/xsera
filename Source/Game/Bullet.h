#ifndef _BULLET_H_
#define _BULLET_H_

#include "bulletdef.h"

class Bullet : public BulletDef
{
	public:
	
	bool seeking;
	float maxlife;
	
	Bullet();
	
	~Bullet();
};

#endif