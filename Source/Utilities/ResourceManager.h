#ifndef __xsera_utilities_resourcemanager_h
#define __xsera_utilities_resourcemanager_h

#include <SDL/SDL.h>

namespace ResourceManager
{

// utility function for reading from a RWops in full
void* ReadFull ( size_t* length, SDL_RWops* ops, int autoclose );

SDL_RWops* OpenFile ( const std::string& name ); // separate paths with /, they will be converted automatically
void WriteFile ( const std::string& name, const void* data, size_t len );

void Init ();

}

#endif
