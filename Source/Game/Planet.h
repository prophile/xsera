#ifndef __xsera_game_planet_h
#define __xsera_game_planet_h

#include <string>
#include "Entity.h"
#include "PlanetDef.h"
#include "Bullet.h"
#include "Player.h"

class Planet : public Entity
{
private:
    PlanetDef* definition;
    Player* owner;
public:
	Planet(Player* _owner, PlanetDef* _definition);
	~Planet();
};

#endif