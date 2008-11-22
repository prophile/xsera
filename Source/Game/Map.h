#ifndef __xsera_game_map_h
#define __xsera_game_map_h

#include <string>
#include <vector>
#include "Planet.h"
#include "Player.h"

class Map
{
private:
	std::string name;
	std::vector<PlanetDef*> planets;

public:
	Map();	
	~Map();
};

#endif