#ifndef __xsera_graphics_spritesheet_h
#define __xsera_graphics_spritesheet_h

#include <SDL/SDL.h>
#include <SDL_image/SDL_image.h>
#include <OpenGL/gl.h>
#include <Utilities/Vec2.h>
#include <string>

namespace Graphics
{

class SpriteSheet
{
private:
	SDL_Surface* surface;
	GLuint texID;
	int sheetTilesX, sheetTilesY;
	int tileSizeX, tileSizeY;
	void MakeResident ();
public:
	SpriteSheet ( const std::string& name );
	~SpriteSheet ();
	
	int SheetTilesX () const { return sheetTilesX; }
	int SheetTilesY () const { return sheetTilesY; }
	
	void Draw ( int x, int y, const vec2& size );
};

}

#endif