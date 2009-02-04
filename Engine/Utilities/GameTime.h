#ifndef __apollo_utilities_gametime_h
#define __apollo_utilities_gametime_h

#ifdef WIN32
#include "SDL.h"
#else
#include <SDL/SDL.h>
#endif

/**
 * Returns the number of seconds since the start of the application
 */
inline float GameTime ()
	{ return SDL_GetTicks() / 1000.0f; }

#endif