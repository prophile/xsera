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

SDL_Surface* LoadImage ( const std::string& path );
GLuint CreateTexture ( SDL_Surface* surface, bool autofree );

}

}

#endif
