#ifndef __apollo_graphics_spritesheet_h
#define __apollo_graphics_spritesheet_h

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
	bool rotational;
	void MakeResident ();
public:
	SpriteSheet ( const std::string& name );
	~SpriteSheet ();
	
	bool IsRotational () const { return rotational; }
	
	int SheetTilesX () const { return sheetTilesX; }
	int SheetTilesY () const { return sheetTilesY; }
	
	int TileSizeX () const { return tileSizeX; }
	int TileSizeY () const { return tileSizeY; }
	
	void Draw ( int x, int y, const vec2& size );
	void DrawRotation ( const vec2& size, float angle ); // 0...2π from east
};

}

#endif