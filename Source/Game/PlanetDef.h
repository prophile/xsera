#ifndef __xsera_game_planetdef_h
#define __xsera_game_planetdef_h

#include "Entity.h"

/*typedef struct
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
} weapons;*/

class PlanetDef
{
private:
	bool invincible;
	float resourceRate;
	//weapons weapon;
	//int capture;	//which ship you can capture this with

public:
	PlanetDef();
	~PlanetDef();
};

#endif