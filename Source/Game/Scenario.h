#ifndef __xsera_game_scenario_h
#define __xsera_game_scenario_h

#include "map.h"
#include "entity.h"
#include "planet.h"
#include "ship.h"
#include "bullet.h"
#include "aiplayer.h"
#include "humanplayer.h"

class Scenario
{
	public:
	
	Scenario();
	
	~Scenario();
	
	private:
	
	std::vector<Map*> maps;
	std::vector<HumanPlayer*> hplayers;
	std::vector<AiPlayer*> cplayers;
	std::vector<BulletDef*> bullets;
};

#endif