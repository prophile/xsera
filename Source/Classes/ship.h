#ifndef _SHIP_H_
#define _SHIP_H_

#include "entity.h"
#include "planet.h"
#include "shipdef.h"
#include "bullet.h"
#include "SDL_OpenGL.h"

typedef struct color
{
	GLfloat red;
	GLfloat green;
	GLfloat blue;
};

class Ship : public ShipDef
{
	public:
	
	weapons weapon;
	
	GLfloat max_turn_rate;		//the greatest rate at which a ship can turn
	GLfloat turn_acceleration;	//the rate at which it approaches that rate
	int ship_class;
	int max_velocity;
	int max_warp_velocity;
	int health;
	int energy;
	int battery;
	int cost;
	int damage;
	int radar_symbol;
	//"pulsePositionNum"??
	int build_time;
	int distance_from_player;
	color shield;
	int longest_weap_range;
	int shortest_weap_range;
	int engage_range;
	
	void hit_cloaked();
	void cloak();
	void destroyed();	//display death animation, varying for different ships
	
	Ship();
	
	~Ship();
};

#endif