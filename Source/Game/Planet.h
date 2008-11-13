#ifndef _PLANET_H_
#define _PLANET_H_

#include <string>
#include "entity.h"
#include "planetdef.h"
#include "bullet.h"

using namespace std;

typedef unsigned short int PlanetName;
const PlanetName EARTH = 1;

const std::string S_EARTH = "Earth";
//continue above two lines for all planets

class Planet : public PlanetDef
{
	public:
	
	Planet();
	
	~Planet();
};

#endif