#include "ImageLoader.h"
#include "Utilities/ResourceManager.h"

namespace Graphics
{

namespace ImageLoader
{

SDL_Surface* LoadImage ( const std::string& path )
{
	SDL_RWops* rwops = ResourceManager::OpenFile(path);
	if (!rwops)
		return NULL;
	SDL_Surface* surface = IMG_LoadTyped_RW(rwops, 1, const_cast<char*>("PNG"));
	return surface;
}

GLuint CreateTexture ( SDL_Surface* surface, bool autofree )
{
	GLuint texID;
	glGenTextures(1, &texID);
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texID);
	if (surface->format->BytesPerPixel == 3)
	{
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGB,
					 surface->w, surface->h, 0,
					 GL_RGB, GL_UNSIGNED_BYTE, surface->pixels);
	}
	else
	{
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA,
					 surface->w, surface->h, 0,
					 GL_RGBA, GL_UNSIGNED_BYTE, surface->pixels);
	}
	if (autofree)
		SDL_FreeSurface(surface);
	return texID;
}

}

}
