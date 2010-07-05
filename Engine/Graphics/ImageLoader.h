#ifndef __apollo_graphics_image_loader_h
#define __apollo_graphics_image_loader_h

#include "Apollo.h"
#include <OpenGL/gl.h>
#include <SDL/SDL.h>
#include <SDL_image/SDL_image.h>

namespace Graphics
{

namespace ImageLoader
{

SDL_Surface* Zip(SDL_Surface* colour, SDL_Surface* alpha);
SDL_Surface* LoadImage ( const std::string& path );
GLuint CreateTexture ( SDL_Surface* surface, bool autofree, bool rectangle = true, bool invert = false );
SDL_Surface* CreateBumpMap(SDL_Surface* heightMap);

}

}

#endif
