#ifndef _MAP_H_
#define _MAP_H_

#include <string>
#include "planet.h"
#include "aiplayer.h"
#include "humanplayer.h"

using namespace std;

typedef unsigned short int Location;
const Location SOL = 1;				const Location PROXIMA = 2;
const Location CENTAURI = 3;		const Location LALANDE = 4;
const Location SER = 5;				const Location THASERO = 6;
const Location SECOREM = 7;			const Location BOKLEO = 8;
const Location HESHAC = 9;			const Location FANSI = 10;
const Location SPIRST = 11;			const Location PALYOS_BELT = 12;
const Location PROTEUS = 13;		const Location PHILEMON = 14;
const Location HADES = 15;			const Location AENEAS = 16;
const Location DEMETER = 17;		const Location ELYSIUM = 18;
const Location MYRMIDON = 19;		const Location CHARON = 20;
const Location OMISHA = 21;

//support for 30 additional locations, possibly more later
const Location LOC_1 = 31;			const Location LOC_2 = 32;
const Location LOC_3 = 33;			const Location LOC_4 = 34;
const Location LOC_5 = 35;			const Location LOC_6 = 36;
const Location LOC_7 = 37;			const Location LOC_8 = 38;
const Location LOC_9 = 39;			const Location LOC_10 = 40;
const Location LOC_11 = 41;			const Location LOC_12 = 42;
const Location LOC_13 = 43;			const Location LOC_14 = 44;
const Location LOC_15 = 45;			const Location LOC_16 = 46;
const Location LOC_17 = 47;			const Location LOC_18 = 48;
const Location LOC_19 = 49;			const Location LOC_20 = 50;
const Location LOC_21 = 51;			const Location LOC_22 = 52;
const Location LOC_23 = 53;			const Location LOC_24 = 54;
const Location LOC_25 = 55;			const Location LOC_26 = 56;
const Location LOC_27 = 57;			const Location LOC_28 = 58;
const Location LOC_29 = 59;			const Location LOC_30 = 60;

class Map
{
	public:
	
	std::string name;
	
	Map();
	
	~Map();
	
	private:
	//support for 20 planets per scenario
	Planet planet1;		Planet planet2;		Planet planet3;		Planet planet4;		Planet planet5;
	Planet planet6;		Planet planet7;		Planet planet8;		Planet planet9;		Planet planet10;
	Planet planet11;	Planet planet12;	Planet planet13;	Planet planet14;	Planet planet15;
	Planet planet16;	Planet planet17;	Planet planet18;	Planet planet19;	Planet planet20;
};

extern Map Tutorial1;	extern Map Tutorial2;	extern Map Tutorial3;
extern Map Level1;	extern Map Level2;	extern Map Level3;	extern Map Level4;	extern Map Level5;
extern Map Level6;	extern Map Level7;	extern Map Level8;	extern Map Level9;	extern Map Level10;
extern Map Level11;	extern Map Level12;	extern Map Level13;	extern Map Level14;	extern Map Level15;
extern Map Level16;	extern Map Level17;	extern Map Level18;	extern Map Level19;	extern Map Level20;

#endif