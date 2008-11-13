#ifndef _SHIPDEF_H_
#define _SHIPDEF_H_

#include "entity.h"

typedef unsigned short int ShipType;
const ShipType Hum_Heavy_Cruiser = 1;

class ShipDef : public Entity
{
	public:
	
	ShipDef();
	
	~ShipDef();
};

#endif