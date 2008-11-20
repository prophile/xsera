#ifndef __xsera_game_shipdef_h
#define __xsera_game_shipdef_h

#include "Entity.h"

enum ShipRadarSymbol
{
    SYMBOL_SMALL,
    SYMBOL_MEDIUM,
    SYMBOL_LARGE
};

class ShipDef
{
private:
    float maxTurnRate;
    float turnAcceleration;
    float maxVelocity;
    float maxWarpVelocity;
    float startingHealth;
    float startingEnergy;
    unsigned cost;
    unsigned buildTime;
    float engageRange;
    ShipRadarSymbol radarSymbol;
public:
	ShipDef();
	~ShipDef();
};

#endif