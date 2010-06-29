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

GLuint CreateTexture ( SDL_Surface* surface, bool autofree, bool rectangle )
{
	GLuint texID;
	glGenTextures(1, &texID);
	GLenum target = rectangle ? GL_TEXTURE_RECTANGLE_ARB : GL_TEXTURE_2D;
	glBindTexture(target, texID);
	glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	if (surface->format->BytesPerPixel == 3)
	{
		GLenum format = (surface->format->Rmask) != 0xFF ? GL_BGR_EXT : GL_RGB;
		glTexImage2D(target, 0, GL_RGB,
					 surface->w, surface->h, 0,
					 format, GL_UNSIGNED_BYTE, surface->pixels);
	}
	else
	{
		GLenum format = (surface->format->Rmask) != 0xFF ? GL_BGRA_EXT : GL_RGBA;
		glTexImage2D(target, 0, GL_RGBA,
					 surface->w, surface->h, 0,
					 format, GL_UNSIGNED_BYTE, surface->pixels);
	}
	if (autofree)
		SDL_FreeSurface(surface);
	return texID;
}

}

}
