#ifndef __apollo_graphics_text_renderer_h
#define __apollo_graphics_text_renderer_h

#include <string>
#include <OpenGL/gl.h>
#include "Utilities/Vec2.h"

namespace Graphics
{

namespace TextRenderer
{

vec2 TextDimensions ( const std::string& font, const std::string& text );
GLuint TextObject ( const std::string& font, const std::string& text );
void Prune ();
void Flush ();

}

}

#endif