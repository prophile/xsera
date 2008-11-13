#ifndef _RACE_H_
#define _RACE_H_

#include <string>

using namespace std;

typedef unsigned short int RaceNumber;
const RaceNumber AUDEMEDON = 1;
const RaceNumber BAZIDANESE = 2;
const RaceNumber CANTHARAN = 3;
const RaceNumber ELEJEETIAN = 4;
const RaceNumber GAITORI = 5;
const RaceNumber GROLK = 6;
const RaceNumber HUMAN = 7;
const RaceNumber ISHIMAN = 8;
const RaceNumber OBISH = 9;
const RaceNumber SALRILIAN = 10;

const std::string S_AUD = "Audemedon";
const std::string S_BAZ = "Bazidanese";
const std::string S_CAN = "Cantharan";
const std::string S_ELE = "Elejeetian";
const std::string S_GAI = "Gaitori";
const std::string S_GRO = "Grolk";
const std::string S_HUM = "Human";
const std::string S_ISH = "Ishiman";
const std::string S_OBI = "Obish";
const std::string S_SAL = "Salrilian";

class Race
{
	public:
		
	std::string name_short;
	std::string name_long;
	std::string name_military;
	std::string homeworld;
	
	RaceNumber race_num;
	float advantage;
	
	Race();
	
	~Race();
};

#endif