#ifndef _PLANETDEF_H_
#define _PLANETDEF_H_

#include "entity.h"

typedef unsigned int weap_type;
typedef double reload_time;

typedef struct
{
	int pulse_ammo;
	int beam_ammo;
	int special_ammo;
	weap_type w_pulse;
	weap_type w_beam;
	weap_type w_special;
	reload_time pulse_rt;
	reload_time beam_rt;
	reload_time special_rt;
} weapons;

class PlanetDef : public Entity 	//definitions for different types of planets? If only declaring one class, 
{									//couldn't I just lump it in with Planet? If declaring 2 versions of that
	public:							//class, how do I translate that to class Planet?
	
	bool invincible;
	int resources;
	weapons weapon;
	int capture;	//which ship you can capture this with
	
	PlanetDef();
	
	~PlanetDef();
};

#endif