#ifndef __xsera_game_player_h
#define __xsera_game_player_h

#include "Race.h"

class Player
{
private:
    Race* race;
    unsigned long id;
public:
	Player ( unsigned long id, Race* race );
	virtual ~Player();
};

#endif