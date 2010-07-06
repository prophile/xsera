#include "ImageLoader.h"
#include "Utilities/ResourceManager.h"

namespace Graphics
{

namespace ImageLoader
{

SDL_Surface* Zip(SDL_Surface* colour, SDL_Surface* alpha)
{
	if (alpha)
	{
		assert(colour->w == alpha->w);
		assert(colour->h == alpha->h);
	}
	SDL_Surface* sfc = SDL_CreateRGBSurface(SDL_SWSURFACE, colour->w, colour->h, 32,
	                                        0x000000FF,
	                                        0x0000FF00,
	                                        0x00FF0000,
	                                        0xFF000000);
	const char* cpixels = static_cast<const char*>(colour->pixels);
	const char* apixels = alpha ? static_cast<const char*>(alpha->pixels) : NULL;
	char* dpixels = static_cast<char*>(sfc->pixels);
	int pixcount = colour->w * colour->h;
	for (int i = 0; i < pixcount; ++i)
	{
		uint8_t cR, cG, cB, aR = 0x00, dead;
		uint32_t res;
		SDL_GetRGBA(*(uint32_t*)cpixels, colour->format, &cR, &cG, &cB, &dead);
		if (alpha)
			SDL_GetRGBA(*(uint32_t*)apixels, alpha->format, &aR, &dead, &dead, &dead);
		res = SDL_MapRGBA(sfc->format, cR, cG, cB, aR);
		memcpy(dpixels, &res, sfc->format->BytesPerPixel);
		cpixels += colour->format->BytesPerPixel;
		if (alpha)
			apixels += alpha->format->BytesPerPixel;
		dpixels += sfc->format->BytesPerPixel;
	}
	return sfc;
}

SDL_Surface* LoadImage ( const std::string& path )
{
	SDL_RWops* rwops = ResourceManager::OpenFile(path);
	if (!rwops)
		return NULL;
	SDL_Surface* surface = IMG_LoadTyped_RW(rwops, 1, const_cast<char*>("PNG"));
	return surface;
}

static SDL_Surface* InvertSurface(SDL_Surface* surface)
{
	int scanlines = surface->h, pitch = surface->pitch;
	SDL_Surface* copy = SDL_CreateRGBSurface(SDL_SWSURFACE, surface->w, surface->h, surface->format->BitsPerPixel,
	                                         surface->format->Rmask,
	                                         surface->format->Gmask,
	                                         surface->format->Bmask,
	                                         surface->format->Amask);
	assert(pitch == copy->pitch);
	for (int i = 0; i < scanlines; ++i)
	{
		int sourceLine = i;
		int destLine = scanlines - i - 1;
		char* dstBase = (char*)(copy->pixels) + (pitch * destLine);
		const char* srcBase = (const char*)(surface->pixels) + (pitch * sourceLine);
		memcpy(dstBase, srcBase, pitch);
	}
	return copy;
}

GLuint CreateTexture ( SDL_Surface* surface, bool autofree, bool rectangle, bool invert )
{
	GLuint texID;
	if (invert)
	{
		SDL_Surface* inverted = InvertSurface(surface);
		texID = CreateTexture(inverted, true, rectangle, false);
	}
	else
	{
		glGenTextures(1, &texID);
		GLenum target = rectangle ? GL_TEXTURE_RECTANGLE_ARB : GL_TEXTURE_2D;
		glBindTexture(target, texID);
		bool mipmaps = !rectangle && strstr((const char*)glGetString(GL_EXTENSIONS), "GL_SGIS_generate_mipmap");
		glTexParameteri(target, GL_TEXTURE_MIN_FILTER, mipmaps ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR);
		glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		if (mipmaps)
			glTexParameteri(target, GL_GENERATE_MIPMAP_SGIS, GL_TRUE);
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
	}
	if (autofree)
		SDL_FreeSurface(surface);
	return texID;
}

static inline uint8_t heightAt(SDL_Surface* surface, int x, int y)
{
	if (!surface) return 0;
	if (x < 0) x = 0;
	if (y < 0) y = 0;
	if (x >= surface->w) x = surface->w - 1;
	if (y >= surface->h) y = surface->h - 1;
	return *((unsigned char*)surface->pixels + surface->format->BytesPerPixel*(surface->w*y + x));
}

#define HEIGHTAT(x, y) *((unsigned char*)heightMap->pixels + bpp*(width*(y) + x))

SDL_Surface* CreateBumpMap(SDL_Surface* heightMap)
{
	int width  = heightMap ? heightMap->w : 1;
	int height = heightMap ? heightMap->h : 1;
	SDL_Surface* surface = SDL_CreateRGBSurface(SDL_SWSURFACE, width, height, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000);
	for (int y = 0; y < height; ++y)
	{
		for (int x = 0; x < width; ++x)
		{
			short Vdiff, Hdiff;
			float VdiffF, HdiffF;
			float TC;
			unsigned char L, R, U, D;
			Uint32 rgba;
			L = heightAt(heightMap, x - 1, y);
			R = heightAt(heightMap, x + 1, y);
			U = heightAt(heightMap, x, y - 1);
			D = heightAt(heightMap, x, y + 1);
			Vdiff = (short)D - (short)U;
			Hdiff = (short)R - (short)L;
			VdiffF = Vdiff / 255.0f;
			HdiffF = Hdiff / 255.0f;
			TC = sqrtf(VdiffF*VdiffF + HdiffF*HdiffF - 1.0f);
			VdiffF += 1.0f; VdiffF *= 0.5f;
			HdiffF += 1.0f; HdiffF *= 0.5f;
			TC     += 1.0f; TC     *= 0.5f;
			rgba = SDL_MapRGBA(surface->format, HdiffF, VdiffF, TC, heightAt(heightMap, x, y));
			*((Uint32*)surface->pixels + y*width + x) = rgba;
		}
	}
	return surface;
}

}

}
