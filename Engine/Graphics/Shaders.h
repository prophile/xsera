#ifndef __xsera_graphics_shaders_h
#define __xsera_graphics_shaders_h

#include <string>
#include <OpenGL/gl.h>

namespace Graphics
{

namespace Shaders
{

void SetShader ( const std::string& name );
GLuint UniformLocation ( const std::string& name );

}

}

#endif