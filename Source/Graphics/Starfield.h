#ifndef __xsera_graphics_starfield_h
#define __xsera_graphics_starfield_h

#include <Utilities/Vec2.h>
#include <OpenGL/gl.h>

namespace Graphics
{

const unsigned STARFIELD_WIDTH  = 2048;
const unsigned STARFIELD_HEIGHT = 2048;

class Starfield
{
public:
	GLuint texID;
	Starfield ();
	~Starfield ();
	vec2 Dimensions ( float depth );
	void Draw ( float depth, vec2 centre );
};

}

#endif