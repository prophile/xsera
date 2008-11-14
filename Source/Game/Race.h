#ifndef __xsera_game_race_h
#define __xsera_game_race_h

#include <string>

class Race
{
private:
	std::string shortName;
	std::string longName;
	std::string militaryName;
	std::string homeworld;
	float advantage;
	
public:
	Race();
	~Race();
};

#endif