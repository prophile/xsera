#ifndef __xsera_game_ship_h
#define __xsera_game_ship_h

#include "Entity.h"
#include "Player.h"
#include "ShipDef.h"
#include "Bullet.h"
#include "Utilities/Colour.h"
#include "Utilities/Vec2.h"

class Ship : public Entity
{
private:
	ShipDef* definition;
	Player* owner;
	//weapons weapon;
	
	float energy;
	float health;
	float turnRate;
	vec2 velocity;
	vec2 position;
public:
	Ship(Player* _owner, ShipDef* _definition);
	~Ship();
};

#endif