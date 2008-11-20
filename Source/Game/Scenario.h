#ifndef _SCENARIO_H_
#define _SCENARIO_H_

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
	
	Map Tutorial1;	Map Tutorial2;	Map Tutorial3;
	Map Level1;		Map Level2;		Map Level3;		Map Level4;		Map Level5;
	Map Level6;		Map Level7;		Map Level8;		Map Level9;		Map Level10;
	Map Level11;	Map Level12;	Map Level13;	Map Level14;	Map Level15;
	Map Level16;	Map Level17;	Map Level18;	Map Level19;	Map Level20;
	
	#ifdef MULTIPLAYER
		//support for 20 players on multiplayer
		HumanPlayer Player1;	HumanPlayer Player2;	HumanPlayer Player3;	HumanPlayer Player4;
		HumanPlayer Player5;	HumanPlayer Player6;	HumanPlayer Player7;	HumanPlayer Player8;
		HumanPlayer Player9;	HumanPlayer Player10;	HumanPlayer Player11;	HumanPlayer Player12;
		HumanPlayer Player13;	HumanPlayer Player14;	HumanPlayer Player15;	HumanPlayer Player16;
		HumanPlayer Player17;	HumanPlayer Player18;	HumanPlayer Player19;	HumanPlayer Player20;
	#else
		HumanPlayer Admiral;
		//support for 20 Comp players per scenario
		AiPlayer Comp1;		AiPlayer Comp2;		AiPlayer Comp3;		AiPlayer Comp4;		AiPlayer Comp5;
		AiPlayer Comp6;		AiPlayer Comp7;		AiPlayer Comp8;		AiPlayer Comp9;		AiPlayer Comp10;
		AiPlayer Comp11;	AiPlayer Comp12;	AiPlayer Comp13;	AiPlayer Comp14;	AiPlayer Comp15;
		AiPlayer Comp16;	AiPlayer Comp17;	AiPlayer Comp18;	AiPlayer Comp19;	AiPlayer Comp20;
	#endif	//should comps be allowed in MP?	
};

#endif