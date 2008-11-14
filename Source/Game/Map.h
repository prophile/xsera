#ifndef _MAP_H_
#define _MAP_H_

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