#ifndef __xsera_utilities_gametime_h
#define __xsera_utilities_gametime_h

#include <SDL/SDL.h>

inline float GameTime ()
	{ return SDL_GetTicks() / 1000.0f; }

#endif