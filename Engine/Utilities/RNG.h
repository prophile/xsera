#ifndef __apollo_utilities_rng_h
#define __apollo_utilities_rng_h

#include <inttypes.h>
#include <time.h>

class RNG
{
private:
	uint32_t state;
public:
	RNG () : state(time(NULL)) {}
	RNG ( uint32_t seed ) : state(seed) {}
	
	static const uint32_t MAX = 0x40000000;
	
	void Reseed () { state = time(NULL); }
	void Reseed ( uint32_t seed ) { state = seed; }
	
	uint32_t GetState () { return state; }
	uint32_t Generate ( uint32_t max = -1U )
	{
		state = 1103515245*state + 12345;
		return (state & 0x3FFFFFFF) % max;
	}
	
	float RandomFloat ( float min = 0.0f, float max = 1.0f )
	{
		float range = max - min;
		float value = Generate() / (float)MAX;
		value *= range;
		return value + min;
	}
};

#endif
