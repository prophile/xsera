#ifndef __xsera_game_bullet_h
#define __xsera_game_bullet_h

#include "Entity.h"
#include "BulletDef.h"

class Bullet : public BulletDef
{
private:
	bool seeking;
	float maxlife;
	
public:
	Bullet();
	~Bullet();
};

#endif