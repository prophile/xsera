#ifndef __apollo_graphics_object3d_h
#define __apollo_graphics_object3d_h

#ifdef WIN32
#include <gl/gl.h>
#include <SDL/SDL_image.h>
#else
#include <OpenGL/gl.h>
#include <SDL_image/SDL_image.h>
#endif

#include <SDL/SDL.h>
#include <Utilities/Vec2.h>
#include <string>
#include <vector>

namespace Graphics
{

class Object3D
{
private:
	GLuint vertexVBO;
	GLuint normalsVBO;
	GLuint texVBO;
	GLuint texture;
	unsigned int nverts;
	void LoadObject ( const std::string& name );
	void LoadTexture ( const std::string& name );
public:
	Object3D ( const std::string& name );
	~Object3D ();
	
	std::string ShaderType () { return "D"; }
	
	void BindTextures ();
	void Draw ( float scale, float angle, float bank = 0.0f );
};

}

#endif
