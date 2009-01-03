#ifndef __apollo_utilities_gametime_h
#define __apollo_utilities_gametime_h

#include <SDL/SDL.h>

/**
 * Returns the number of seconds since the start of the application
 */
inline float GameTime ()
	{ return SDL_GetTicks() / 1000.0f; }

#endif